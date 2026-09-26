"""Search state is never evicted by retention limits."""

from dataclasses import dataclass


@dataclass(frozen=True)
class MemoryConfig:
    observations: int = 16
    pairs: int = 4
    findings: int = 16
    events: int = 1024
    validation_log: int = 256
    evidence_log: int = 256

    def __post_init__(self):
        for name, value in vars(self).items():
            if type(value) is not int or value < 0:
                raise ValueError("%s retention must be a nonnegative integer" % name)


def release_computations(result):

    if result is not None:
        for record in result.records:
            object.__setattr__(record, "computation", None)
