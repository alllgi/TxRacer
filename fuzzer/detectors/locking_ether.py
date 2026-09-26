#!/usr/bin/env python3


class LockingEtherDetector():
    def __init__(self):
        self.init()

    def init(self):
        self.swc_id = 132
        self.severity = "Medium"

    def detect_locking_ether(self, cfg, current_instruction, individual, transaction_index):

        if not cfg.can_send_ether:

            if current_instruction["op"] == "STOP" and individual.solution[transaction_index]["transaction"]["value"] > 0:
                return current_instruction["pc"], transaction_index
        return None, None
