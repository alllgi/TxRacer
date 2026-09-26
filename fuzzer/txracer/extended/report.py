import hashlib
import json

REPORT_SCHEMA_VERSION = 1

DISPLAY_ONLY_PRICES = {
    "ETH": {"display_name": "Ether", "decimals": 18},
    "ERC721": {"display_name": "ERC721 token", "decimals": 0},
    "ERC1155": {"display_name": "ERC1155 token", "decimals": 0},
}


def read_token_decimals(evm, contract_address):

    decimals_selector = "0x313ce567"
    try:
        output = evm.safe_read_call(
            "0x" + "00" * 20, contract_address, decimals_selector)
    except Exception as read_error:  # noqa: BLE001
        return None, "decimals_read_failed:%s" % (read_error,)
    if not output:
        return None, "decimals_unavailable:no_return_data"
    try:
        from eth_abi import decode_abi
        decoded = decode_abi(["uint8"], output)
        return int(decoded[0]), None
    except Exception as decode_error:  # noqa: BLE001
        return None, "decimals_decode_failed:%s" % (decode_error,)


def price_display_row(asset_id, raw_amount, decimals=None,
                      decimals_diagnostic=None, price_source=None,
                      asset_source=None):

    standard, contract, token_id = asset_id
    info = DISPLAY_ONLY_PRICES.get(standard, {})
    if standard == "ERC20":
        default_decimals = None
    else:
        default_decimals = info.get("decimals", 0)
    return {
        "asset": list(asset_id),
        "raw_amount": raw_amount,
        "display_decimals": (decimals if decimals is not None
                             else default_decimals),
        "decimals_diagnostic": decimals_diagnostic,
        "display_name": info.get("display_name", standard),
        "display_only": True,
        "price_source": price_source,
        "asset_source": asset_source,
        "price_unavailable": price_source is None,
        "note": "display-only; never used in finding confirmation; "
                "decimals read from the verified read-only interface, "
                "null when unreadable; price_source is a real price "
                "provider or null; no fabricated prices",
    }


def economic_finding_key(record):

    accounts = record.get("accounts") or {}
    schedule = record.get("schedule_order_key")
    baseline_schedule = record.get("baseline_schedule")
    baseline_assets = {}
    if isinstance(baseline_schedule, dict):
        baseline_assets = baseline_schedule.get("assets") or {}
    asset_dimensions = set()
    for asset in ((record.get("oracle") or {}).get(
            "confirmed_assets") or []):
        asset_dimensions.add(str(asset))
    for role in ("victim", "attacker"):
        role_assets = baseline_assets.get(role) or []
        if isinstance(role_assets, dict):
            for asset in role_assets.keys():
                asset_dimensions.add(str(asset))
        else:
            for entry in role_assets:
                if isinstance(entry, (list, tuple)) and entry:
                    asset_dimensions.add(str(list(entry[:3])))
                else:
                    asset_dimensions.add(str(entry))
    core = {
        "finding_type": record.get("finding_type"),


        "target": {
            "source_hash": (record.get("target") or {}).get(
                "source_hash"),
            "contract": (record.get("target") or {}).get(
                "contract_addresses"),
        },
        "accounts": {
            "victim": accounts.get("victim"),
            "attacker": accounts.get("attacker"),
        },
        "asset_dimensions": sorted(asset_dimensions),
        "schedule_order_key": [list(entry) for entry in (schedule or [])],
        "extra_schedule": bool(record.get("extra_schedule")),
    }
    return json.dumps(core, sort_keys=True, default=str)


def compare_findings(paper_records, extended_records):

    paper = {economic_finding_key(r): r for r in paper_records}
    extended = {economic_finding_key(r): r for r in extended_records}
    if not paper:
        return {
            "comparison_valid": False,
            "reason": "empty_paper_baseline",
            "paper_count": 0,
            "extended_count": len(extended),
            "shared_keys": [],
            "only_paper_keys": [],
            "only_extended_keys": sorted(set(extended)),
            "paper_preserved": False,
            "identical": False,
        }
    shared = sorted(set(paper) & set(extended))
    only_paper = sorted(set(paper) - set(extended))
    only_extended = sorted(set(extended) - set(paper))
    paper_non_extra = {
        key for key, record in paper.items()
        if not record.get("extra_schedule")}
    extended_non_extra = {
        key for key, record in extended.items()
        if not record.get("extra_schedule")}
    preserved = paper_non_extra.issubset(extended_non_extra)
    return {
        "comparison_valid": True,
        "reason": None,
        "paper_count": len(paper),
        "extended_count": len(extended),
        "shared_keys": shared,
        "only_paper_keys": only_paper,
        "only_extended_keys": only_extended,
        "paper_preserved": bool(preserved),
        "identical": bool(preserved and not only_extended
                           and paper_non_extra == extended_non_extra),
    }


class ExtendedReport(object):


    def __init__(self, mode, seed, chain_id, extension_flags,
                 cache_manager=None, price_reporting=False):
        self.schema_version = REPORT_SCHEMA_VERSION
        self.mode = mode
        self.seed = seed
        self.chain_id = chain_id
        self.extension_flags = dict(extension_flags)
        self.cache_manager = cache_manager
        self.price_reporting = bool(price_reporting)
        self.intent_record_count = 0
        self.intent_classifications = {}
        self.price_rows = []
        self.campaign_assets = {}
        self.extra_seed_schedules = 0

    def note_intent_record(self, classification):
        self.intent_record_count += 1
        self.intent_classifications[classification] = (
            self.intent_classifications.get(classification, 0) + 1)

    def set_campaign_assets(self, assets):

        self.price_rows = list(assets or [])
        self.campaign_assets = {"price_rows": len(self.price_rows)}

    def to_dict(self, paper_findings=None, extended_findings=None):
        report = {
            "schema_version": self.schema_version,
            "mode": self.mode,
            "seed": self.seed,
            "chain_id": self.chain_id,
            "extensions": dict(self.extension_flags),
            "extensions_enabled": [
                name for name, enabled in sorted(
                    self.extension_flags.items()) if enabled
            ],
            "intent": {
                "enabled": bool(self.extension_flags.get(
                    "intent_oracle", False)),
                "record_count": self.intent_record_count,
                "classifications": dict(self.intent_classifications),
                "note": "intent records are separate; they never change "
                        "the paper FRONT_RUNNING_PROFIT set",
            },
            "price_reporting": {
                "enabled": self.price_reporting,
                "display_only": True,
                "rows": list(self.price_rows),
            },
            "extra_seed_schedules": self.extra_seed_schedules,
            "cache": (self.cache_manager.to_dict()
                      if self.cache_manager is not None else None),
            "campaign_assets": dict(self.campaign_assets),
        }
        if paper_findings is not None and extended_findings is not None:
            report["paper_vs_extended"] = compare_findings(
                paper_findings, extended_findings)
        return report

    def write(self, path):
        payload = self.to_dict()
        with open(path, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2, sort_keys=True,
                      default=str)
            handle.write("\n")
        return payload


__all__ = [
    "REPORT_SCHEMA_VERSION",
    "ExtendedReport",
    "compare_findings",
    "economic_finding_key",
    "price_display_row",
]
