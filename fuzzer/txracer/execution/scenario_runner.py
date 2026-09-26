import sys

from fuzzer.txracer.execution import rw_trace
from fuzzer.txracer.execution.rw_trace import TxExecutionInternalError
from fuzzer.txracer.oracles.assets import erc20_asset, eth_asset
from fuzzer.utils import settings
from eth_abi import encode_abi
from eth_utils import to_canonical_address

from fuzzer.txracer.compat import legacy_keyword_aliases


class ScenarioExecutionError(Exception):
    pass


class ScheduleResult(object):


    @legacy_keyword_aliases(victim_addr='user_addr')
    def __init__(self, input_schedule, tx_results, assets, user_addr=None, attacker_addr=None):
        self.input_schedule = list(input_schedule)
        self.tx_results = list(tx_results)
        self.assets = dict(assets)
        self.user_addr = user_addr
        self.attacker_addr = attacker_addr

    @property
    def victim_addr(self):

        return self.user_addr

    @victim_addr.setter
    def victim_addr(self, value):
        self.user_addr = value



    @property
    def schedule(self):

        return self.input_schedule

    def to_dict(self):
        from fuzzer.txracer.oracles.assets import serialize_snapshot
        return {

            "input_schedule": self.input_schedule,

            "tx_results": [
                record.to_dict() for record in self.tx_results
            ],
            "assets": {
                role: serialize_snapshot(snapshot)
                for role, snapshot in self.assets.items()
            },
        }


def default_asset_reader(evm, chain_id, account_address):

    assets = {
        eth_asset(chain_id): int(
            evm.get_balance(to_canonical_address(account_address))
        ),
    }
    balance_of = "0x70a08231" + encode_abi(["address"], [account_address]).hex()
    for _name, address in settings.DEPLOYED_CONTRACT_ADDRESS.items():
        output = evm.safe_read_call(account_address, address, balance_of)
        if output:
            assets[erc20_asset(address)] = int.from_bytes(output, "big")
    return assets


class ScenarioRunner(object):


    def __init__(self, evm, chain_id=1, asset_reader=None):
        self.evm = evm
        self.chain_id = chain_id
        self.asset_reader = asset_reader or default_asset_reader

    @legacy_keyword_aliases(victim_addr='user_addr')
    def _execute(self, schedule, user_addr, attacker_addr, tx_ids=None):
        results = []
        if tx_ids is None:
            tx_ids = ["schedule-%d" % i for i in range(len(schedule))]
        if len(tx_ids) != len(schedule):
            raise ScenarioExecutionError(
                "tx_ids count %d does not match schedule length %d"
                % (len(tx_ids), len(schedule))
            )
        for i, tx_input in enumerate(schedule):
            try:
                record = rw_trace.execute_transaction_with_rw_trace(
                    self.evm,
                    tx_input,
                    tx_id=tx_ids[i],
                )
            except TxExecutionInternalError as internal_error:
                raise ScenarioExecutionError(
                    "schedule tx %d (%s) internal failure: %s"
                    % (i, tx_ids[i], internal_error)
                )
            results.append(record)
        assets = {
            "victim": self._read_assets("user", user_addr),
            "attacker": self._read_assets("attacker", attacker_addr),
        }
        return ScheduleResult(schedule, results, assets, user_addr, attacker_addr)

    def _read_assets(self, role, account_address):

        try:
            return self.asset_reader(self.evm, self.chain_id, account_address)
        except Exception as read_error:
            raise ScenarioExecutionError(
                "asset read failed for %s (%s) after schedule execution: %s"
                % (role, account_address, read_error)
            )

    @legacy_keyword_aliases(victim_sequence='user_sequence', victim_addr='user_addr', victim_ids='user_ids')
    def run_baseline(self, user_sequence, attacker_sequence, user_addr, attacker_addr,
                     user_ids=None, attacker_ids=None):

        self._restore_clean()
        full = list(user_sequence) + list(attacker_sequence)
        tx_ids = None
        if user_ids is not None or attacker_ids is not None:
            if user_ids is None:
                user_ids = ["trace-%d" % i for i in range(len(user_sequence))]
            if attacker_ids is None:
                attacker_ids = ["trace-%d" % i for i in range(len(attacker_sequence))]
            tx_ids = list(user_ids) + list(attacker_ids)
        return self._execute(full, user_addr, attacker_addr, tx_ids=tx_ids)

    @legacy_keyword_aliases(victim_addr='user_addr')
    def run_candidate(self, candidate_sequence, user_addr, attacker_addr, tx_ids=None):

        self._restore_clean()
        return self._execute(list(candidate_sequence), user_addr, attacker_addr,
                             tx_ids=tx_ids)

    def execute_sequence(self, sequence, tx_ids=None):

        self._restore_clean()
        if tx_ids is None:
            tx_ids = ["trace-%d" % i for i in range(len(sequence))]
        if len(tx_ids) != len(sequence):
            raise ScenarioExecutionError(
                "tx_ids count %d does not match sequence length %d"
                % (len(tx_ids), len(sequence))
            )
        results = []
        for i, tx_input in enumerate(sequence):
            try:
                record = rw_trace.execute_transaction_with_rw_trace(
                    self.evm,
                    tx_input,
                    tx_id=tx_ids[i],
                )
            except TxExecutionInternalError as internal_error:
                raise ScenarioExecutionError(
                    "trace tx %d (%s) internal failure: %s"
                    % (i, tx_ids[i], internal_error)
                )
            results.append(record)
        return results

    def _restore_clean(self):
        try:
            self.evm.restore_from_snapshot()
        except Exception as restore_error:
            raise ScenarioExecutionError(
                "snapshot restore failed: %s" % restore_error
            )


__all__ = [
    "ScenarioExecutionError",
    "ScheduleResult",
    "ScenarioRunner",
    "default_asset_reader",
]
