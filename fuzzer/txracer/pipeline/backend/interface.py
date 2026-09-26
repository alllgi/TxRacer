from abc import ABC, abstractmethod


class ExecutionBackend(ABC):
    @abstractmethod
    def fund(self, address, balance):
        pass

    @abstractmethod
    def balance(self, address):
        pass

    @abstractmethod
    def read_call(self, sender, contract, calldata):
        pass

    @abstractmethod
    def configure_asset_queries(self, accounts, token_addresses=()):
        pass

    @abstractmethod
    def deploy(self, sender, bytecode, value=0, gas=8000000):
        pass

    @abstractmethod
    def snapshot(self, name):
        pass

    @abstractmethod
    def restore(self, baseline):
        pass

    @abstractmethod
    def execute_transaction(self, transaction, tx_id):
        pass

    @abstractmethod
    def execute_sequence(self, sequence, baseline, tx_ids=None):
        pass
