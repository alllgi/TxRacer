from typing import Dict, Optional, Tuple

from eth_utils import to_normalized_address

AssetId = Tuple[str, str, Optional[int]]
AssetSnapshot = Dict[AssetId, int]

_LEGACY_ASSET_TYPES = ("ERC20", "ERC721", "ERC1155")


def normalize_token_address(token_address):

    return to_normalized_address(token_address)


def eth_asset(chain_id):
    return ("ETH", str(chain_id), None)


def erc20_asset(token_address):
    return ("ERC20", normalize_token_address(token_address), None)


def erc721_asset(token_address, token_id):
    return ("ERC721", normalize_token_address(token_address), int(token_id))


def erc1155_asset(token_address, token_id):
    return ("ERC1155", normalize_token_address(token_address), int(token_id))


def asset_snapshot_from_state(state, chain_id):

    snapshot = {}
    assets = state.get("assets", {}) if isinstance(state, dict) else {}
    for key, balance in assets.items():
        if key == "ETH":
            snapshot[eth_asset(chain_id)] = int(balance)
        elif "@" in key:
            asset_type, address = key.split("@", 1)
            if asset_type == "ERC20":
                snapshot[("ERC20", normalize_token_address(address), None)] = int(balance)
            elif asset_type in ("ERC721", "ERC1155"):
                raise ValueError(
                    "legacy %s asset key %r lacks a token id; "
                    "token-id granularity is required (fail fast)" % (asset_type, key)
                )
            else:
                raise ValueError("unsupported asset type in state: %r" % key)
        else:
            raise ValueError("unexpected legacy asset key: %r" % key)
    return snapshot


def asset_deltas(baseline, candidate):

    keys = set(baseline) | set(candidate)
    return {
        key: candidate.get(key, 0) - baseline.get(key, 0)
        for key in keys
    }


def _sort_key(asset_id):
    standard, contract, token_id = asset_id
    return (standard, contract, -1 if token_id is None else token_id)


def sorted_asset_ids(snapshot):
    return sorted(snapshot.keys(), key=_sort_key)


def serialize_snapshot(snapshot):

    serialized = []
    for asset_id in sorted_asset_ids(snapshot):
        standard, contract, token_id = asset_id
        serialized.append([standard, contract, token_id, int(snapshot[asset_id])])
    return serialized


__all__ = [
    "AssetId",
    "AssetSnapshot",
    "asset_deltas",
    "asset_snapshot_from_state",
    "erc1155_asset",
    "erc20_asset",
    "erc721_asset",
    "eth_asset",
    "normalize_token_address",
    "serialize_snapshot",
    "sorted_asset_ids",
]
