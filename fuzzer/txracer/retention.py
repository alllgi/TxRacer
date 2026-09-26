from collections import Counter


class History(list):
    def __init__(self, limit=None):
        if limit is not None and (type(limit) is not int or limit < 0):
            raise ValueError("History limit must be a nonnegative integer or None")
        super().__init__()
        self.limit, self.total = limit, 0

    def append(self, value):
        self.total += 1
        if self.limit == 0:
            return
        super().append(value)
        if self.limit is not None and len(self) > self.limit:
            del self[:len(self) - self.limit]

    def extend(self, values):
        for value in values:
            self.append(value)

    @property
    def dropped(self):
        return self.total - len(self)

    def retention(self):
        return {"total": self.total, "retained": len(self), "dropped": self.dropped,
                "limit": self.limit}


class EventHistory(History):
    def __init__(self, limit=1024):
        super().__init__(limit)
        self.counts = Counter()

    def append(self, event):
        self.counts[event.get("event", event.get("operator", "unknown"))] += 1
        super().append(event)
