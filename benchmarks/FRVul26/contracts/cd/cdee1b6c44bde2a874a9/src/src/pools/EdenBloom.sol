// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Time} from "@utils/Time.sol";
import {Errors} from "@utils/Errors.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

struct WinnerRequest {
    uint128 upForGrabs; // To total rewards up for grabs at the time of requesting
    bool fulfilled; // Whether the request has been fullfilled
}

/**
 * @title EdenBloomPool
 * @dev A staking pool contract for managing participants, distributing rewards, and selecting winners based on randomness.
 */
contract EdenBloomPool is VRFConsumerBaseV2Plus, Errors {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 INTERVAL_TIME = 2 weeks;

    /// @notice Address of the staking contract
    address immutable staking;

    address public admin;

    bytes32 public keyHash;
    uint16 public requestConfirmations = 3;

    IERC20 immutable titanX;

    /// @notice Chainlink subscription ID for requesting randomness
    uint256 subscriptionId;

    /// @notice Stores the ID of the last randomness request
    uint256 lastRequestId;

    /// @notice Mapping from randomness request ID to WinnerRequest details
    mapping(uint256 requestId => WinnerRequest) requests;

    /// @notice Last timestamp when bi-weekly interval logic was called
    uint32 public lastIntervalCall;

    /// @notice The total amount of rewards available to be distributed
    uint128 public upForGrabs;

    /// @notice Set of participants in the pool
    EnumerableSet.AddressSet participants;

    /**
     * @dev Modifier to restrict function access to only the staking contract.
     */
    modifier onlyStaking() {
        _onlyStaking();
        _;
    }

    /**
     * @dev Modifier to ensure no pending randomness requests.
     * Reverts if a previous randomness request has not been fulfilled yet.
     */
    modifier noPendingRandomness() {
        _noPendingRandomness();
        _;
    }

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    /// @notice Error thrown when the caller is not the staking contract.
    error OnlyStaking();

    /// @notice Error thrown when randomness is requested but a previous request is still pending.
    error RandomnessAlreadyRequested();

    /// @notice Error thrown when an operation is called before the interval time has passed.
    error OnlyAfterIntervalTime();

    /// @notice Error thrown when trying to pick a winner, while having no rewards acumulated.
    error EmptyTreasury();

    /// @notice Error thrown when trying to pick a winner, while having no participants
    error NoParticipation();

    ///@notice Error thrown when a non-admin user is trying to access an admin function
    error OnlyAdmin();

    error InvalidRequestConfirmations();

    event WinnerSelected(address indexed winner, uint256 indexed amountWon);

    /**
     * @notice Initializes the contract with the staking contract address, VRF coordinator, subscription ID, and start timestamp.
     * @param _staking Address of the staking contract.
     * @param _vrfCoordinator Address of the Chainlink VRF coordinator.
     * @param _subscriptionId The Chainlink subscription ID for randomness requests.
     * @param _startTimestamp Start timestamp for the pool.
     */
    constructor(
        address _staking,
        address _vrfCoordinator,
        uint256 _subscriptionId,
        address _titanX,
        bytes32 _keyHash,
        address _admin,
        uint32 _startTimestamp
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        staking = _staking;
        titanX = IERC20(_titanX);
        lastIntervalCall = _startTimestamp;
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        admin = _admin;
    }

    /* == ADMIN == */
    function changeRequestConfirmations(uint16 _newRequestConfirmations)
        external
        notAmount0(_newRequestConfirmations)
        onlyAdmin
    {
        require(_newRequestConfirmations >= 3 && _newRequestConfirmations <= 10, InvalidRequestConfirmations());
        requestConfirmations = _newRequestConfirmations;
    }

    function changeSubscriptionId(uint256 _newSubId) external onlyAdmin {
        subscriptionId = _newSubId;
    }

    function changeKeyHash(bytes32 _newKeyHash) external onlyAdmin {
        keyHash = _newKeyHash;
    }

    function unblockPendingRequest() external onlyAdmin {
        WinnerRequest storage _winnerReq = requests[lastRequestId];

        _winnerReq.fulfilled = true;
    }

    /**
     * @notice Requests random words to determine the winner and distribute rewards.
     * @dev Ensures that the function is called only after the defined interval time has passed,
     * and no other randomness request is pending.
     * @return requestId The ID of the randomness request.
     */
    function pickWinner() external noPendingRandomness returns (uint256 requestId) {
        require(upForGrabs != 0, EmptyTreasury());
        require(lastIntervalCall + INTERVAL_TIME <= Time.blockTs(), OnlyAfterIntervalTime());
        require(participants.length() != 0, NoParticipation());

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: 250_000,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        lastRequestId = requestId;

        requests[requestId] = WinnerRequest({fulfilled: false, upForGrabs: upForGrabs});
    }

    /**
     * @notice Checks if a user is a participant in the pool.
     * @param _user Address of the user.
     * @return bool Returns true if the user is a participant.
     */
    function isParticipant(address _user) public view returns (bool) {
        return participants.contains(_user);
    }

    /**
     * @notice Fulfills the randomness request and selects a winner from the participants.
     * @param requestId The ID of the randomness request.
     * @param randomWords Array of random words provided by Chainlink VRF.
     */
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        WinnerRequest storage _winnerReq = requests[requestId];

        if (_winnerReq.fulfilled) return;

        uint256 missedIntervals = (Time.blockTs() - lastIntervalCall) / INTERVAL_TIME;

        lastIntervalCall = uint32(lastIntervalCall + (INTERVAL_TIME * missedIntervals));

        uint256 randomness = randomWords[0];

        address winner = participants.at(randomness % participants.length());

        upForGrabs -= _winnerReq.upForGrabs;

        titanX.transfer(winner, _winnerReq.upForGrabs);

        emit WinnerSelected(winner, _winnerReq.upForGrabs);

        _winnerReq.fulfilled = true;
    }

    /**
     * @notice Adds a participant to the pool.
     * @dev Can only be called by the staking contract.
     * @param _participant Address of the participant to add.
     */
    function participate(address _participant) external onlyStaking noPendingRandomness {
        participants.add(_participant);
    }

    /**
     * @notice Removes a participant from the pool.
     * @dev Can only be called by the staking contract.
     * @param _participant Address of the participant to remove.
     */
    function removeParticipant(address _participant) external onlyStaking noPendingRandomness {
        participants.remove(_participant);
    }

    /**
     * @notice Increases the reward pool by a specified amount.
     * @dev Can only be called by the staking contract.
     * @param _amount Amount to add to the reward pool.
     */
    function distributeRewards(uint128 _amount) external onlyStaking {
        upForGrabs += _amount;
    }

    /**
     * @dev Internal function to restrict access to only the staking contract.
     * @notice Throws OnlyStaking error if the caller is not the staking contract.
     */
    function _onlyStaking() internal view {
        require(msg.sender == staking, OnlyStaking());
    }

    /**
     * @dev Internal function to check that no pending randomness requests are active.
     * @notice Throws RandomnessAlreadyRequested if the last randomness request is still pending.
     */
    function _noPendingRandomness() internal view {
        WinnerRequest memory _lastReq = requests[lastRequestId];
        require(lastRequestId == 0 || _lastReq.fulfilled, RandomnessAlreadyRequested());
    }

    function _onlyAdmin() internal view {
        require(msg.sender == admin, OnlyAdmin());
    }
}
