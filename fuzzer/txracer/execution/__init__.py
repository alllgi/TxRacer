from .legacy import LegacyExecutionBackend


def create_execution_backend(name, eth_node_ip=None, eth_node_port=None):
    if name != "legacy":
        raise ValueError("Unsupported execution backend: " + str(name))
    return LegacyExecutionBackend(eth_node_ip, eth_node_port)


__all__ = ["LegacyExecutionBackend", "create_execution_backend"]
