// SPDX-License-Identifier: UNLICENSE
/*



https://x.com/SenLummis/status/1854208373740458432

*/

pragma solidity 0.8.28;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract STRATEGICBITCOINRESERVE is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;
    address payable private _devWallet;
    uint256 _devPortion = 0;

    uint256 private _initialBuyTax = 12;
    uint256 private _initialSellTax = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 20;
    uint256 private _reduceSellTaxAt = 20;
    uint256 private _preventSwapBefore = 20;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 21042069 * 10**_decimals;
    string private constant _name = unicode"STRATEGIC BITCOIN RESERVE";
    string private constant _symbol = unicode"SBR";
    uint256 public _maxTxAmount= (_tTotal * 13) / 1000;
    uint256 public _maxWalletSize= (_tTotal * 13) / 1000;
    uint256 public _taxSwapThreshold= (_tTotal * 1) / 100;
    uint256 public _maxTaxSwap= (_tTotal * 500) / 1000;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    uint256 public tradingOpenBlock=9999999999;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private sellCount = 0;
    uint256 private lastSellBlock = 0;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    event ClearToken(address TokenAddressCleared, uint256 Amount);
		event TradingOpened(uint256 timestamp, uint256 blockNumber);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

  constructor () {
        _taxWallet = payable(0xEba90A0EeC6859cF8480b42A0148B1c830242362);
        _devWallet = payable(0x221CbCe387aEA3f81b4BA2e74381d291C945f0f9);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;
        _isExcludedFromFee[0x221CbCe387aEA3f81b4BA2e74381d291C945f0f9] = true;
        
        _balances[0x221CbCe387aEA3f81b4BA2e74381d291C945f0f9] = 210420690000000;
        emit Transfer(address(0), 0x221CbCe387aEA3f81b4BA2e74381d291C945f0f9, 210420690000000);
        _balances[_msgSender()] = 20831648310000000;
        emit Transfer(address(0), _msgSender(), 20831648310000000);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

		function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (block.number < tradingOpenBlock) {
            require(
                _isExcludedFromFee[from] || _isExcludedFromFee[to],
                "Trading is not open yet and you are not authorized"
            );
        }
        uint256 taxAmount = 0;

        if (from != owner() && to != owner()) {
            

            if(_buyCount == 0){
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);
            }

            if(_buyCount > 0){
                taxAmount =amount.mul(_transferTax).div(100);
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this) ){
                taxAmount = amount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                if (block.number>lastSellBlock) {
                    sellCount = 0;
                }
                require(sellCount < 3, "Only 3 sells per block!");

                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }

                sellCount++;
                lastSellBlock =block.number;
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] = _balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this), taxAmount);
        }

        _balances[from]= _balances[from].sub(amount);
        _balances[to]= _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimit() external onlyOwner{
        _maxTxAmount =_tTotal;
        _maxWalletSize =_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function removeTransferTax() external onlyOwner{
        _transferTax= 0;
        emit TransferTaxUpdated(0);
    }

	function sendETHToFee(uint256 amount) private {
	    if (_devPortion == 0) {
	        (bool success,) = _taxWallet.call{value: amount}("");
	    	success;
		} else {
	        uint256 ethForDev = amount * _devPortion / 100;
			uint256 ethForTaxWallet = amount - ethForDev;
			(bool devsuccess,) = _devWallet.call{value: ethForDev}("");
			devsuccess;
			(bool success,)	= _taxWallet.call{value: ethForTaxWallet}("");
			success;
		}
	}

    function addLP() external onlyOwner() {
        require(tradingOpenBlock > block.number, "Trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this), balanceOf(address(this)), 0, 0, owner(), block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }
 
    function openTrading() external onlyOwner() {
        require(tradingOpenBlock > block.number, "Trading is already open");
        tradingOpenBlock = block.number;
        swapEnabled = true;
        emit TradingOpened(block.timestamp, block.number);
    }

    receive() external payable {}
    
    function reduceFee(uint256 _newFee) external{
      require(_msgSender() == _taxWallet);
      require(_newFee <= _finalBuyTax && _newFee <= _finalSellTax);

      _finalBuyTax =_newFee;
      _finalSellTax =_newFee;
    }

    function clearStuckToken(address tokenAddress, uint256 tokens) external returns (bool success) {
        require(_msgSender() == _taxWallet);

        if(tokens == 0){
            tokens = IERC20(tokenAddress).balanceOf(address(this));
        }

        emit ClearToken(tokenAddress,tokens);
        return IERC20(tokenAddress).transfer(_taxWallet, tokens);
    }

    function setExcludedFromFee(address account, bool excluded) external onlyOwner {
        require(account != address(0), "Cannot set zero address");
        _isExcludedFromFee[account] = excluded;
    }

 		function setExcludedFromFeeMulti(address[] calldata accounts, bool excluded) external onlyOwner {
        require(accounts.length > 0, "Empty array");
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "Cannot set zero address");
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }

    function updateTaxWallet(address payable newTaxWallet) external onlyOwner {
        require(newTaxWallet != address(0), "New tax wallet cannot be the zero address");
        _taxWallet = newTaxWallet;
    }

    function manualSend() external {
        require(_msgSender() == _taxWallet);

        uint256 ethBalance= address(this).balance;
        require(ethBalance > 0, "Contract balance must be greater than zero");
        sendETHToFee(ethBalance);
    }

    function manualSwap() external {
        require(_msgSender() == _taxWallet);

        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance > 0){
          swapTokensForEth(tokenBalance);
        }

        uint256 ethBalance = address(this).balance;
        if(ethBalance>0){ sendETHToFee(ethBalance); }
    }
}

