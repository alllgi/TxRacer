"""Joint SMT assignments become canonical candidates directly, without pools."""

import copy
from dataclasses import dataclass, replace

import z3
from z3.z3util import get_vars

from fuzzer.utils.utils import convert_stack_value_to_int
from fuzzer.txracer.pipeline.backend.symbolic import SymbolicTaintAnalyzer


@dataclass(frozen=True)
class Binding:
    name: str
    transaction_index: int
    field: str
    argument_index: int = -1
    argument_type: str = "uint256"

    @property
    def symbol(self):
        return z3.BitVec(self.name, 256)


@dataclass(frozen=True)
class BranchConstraint:
    sequence: object
    baseline: object
    location: tuple
    prefix: tuple
    observed: object
    bindings: tuple


@dataclass(frozen=True)
class ConcreteAssignment:
    sequence: object
    values: tuple
    constraint_location: tuple


class ParameterSolver:
    def __init__(self, accounts, max_value=10 ** 18, timeout_ms=1000, mutate_sender=False, value_candidates=None):
        self.accounts = tuple(accounts)
        self.mutate_sender = mutate_sender
        self.max_value = None if max_value is None else int(max_value)
        self.timeout_ms, self.value_candidates = int(timeout_ms), value_candidates
        if self.max_value is None and value_candidates is None:
            raise ValueError("No-cap SMT construction requires explicit payment samples")
        self.diagnostics = []
        self.attempted = set()

    def collect(self, result):

        analyzer, bindings, branches, prefix = SymbolicTaintAnalyzer(), {}, [], []
        for tx_index, record in enumerate(result.records):
            if record.computation is None:
                continue
            storage_before = copy.deepcopy(analyzer.storage)
            analyzer.clear_callstack()
            transaction = record.transaction


            computation = record.computation
            message = getattr(computation, "msg", None)
            if (getattr(message, "depth", None) != 0
                    or getattr(message, "sender", None) != bytes.fromhex(transaction.sender[2:])
                    or any(raw.get("depth") != 1 for raw in computation.trace or [])):
                self.diagnostics.append((tx_index, "unverified_top_level_frame_binding"))
                break
            children = list(computation.children)
            while children:
                child = children.pop()
                if any(raw.get("op") == "CALLER" for raw in child.trace or []):
                    self.diagnostics.append((tx_index, "internal_caller_binding_unsupported",
                                             child.msg.depth))
                children.extend(child.children)


            simple_abi = all("[" not in t and "(" not in t and t not in ("bytes", "string")
                             for t in transaction.argument_types)
            if not simple_abi:
                self.diagnostics.append((tx_index, "dynamic_or_composite_smt_binding_unsupported"))
            try:
                for raw in record.computation.trace or []:
                    instruction = dict(raw)
                    analyzer.propagate_taint(instruction, transaction.contract)
                    op = instruction["op"]
                    binding = None
                    if op == "CALLDATALOAD" and simple_abi:
                        offset = convert_stack_value_to_int(instruction["stack"][-1])
                        index = (offset - 4) // 32
                        if offset >= 4 and (offset - 4) % 32 == 0 and index < len(transaction.arguments):
                            binding = Binding("argument_%d_%d" % (tx_index, index), tx_index,
                                              "argument", index, transaction.argument_types[index])
                    elif op in ("CALLER", "CALLVALUE", "NUMBER", "TIMESTAMP"):
                        field = {"CALLER": "sender", "CALLVALUE": "value", "NUMBER": "blocknumber",
                                 "TIMESTAMP": "timestamp"}[op]
                        binding = Binding("%s_%d" % (field, tx_index), tx_index, field)
                    if binding:
                        bindings[binding.name] = binding
                        analyzer.introduce_taint(binding.symbol, instruction)
                    if op == "JUMPI":
                        taint = analyzer.check_taint(instruction)
                        if taint and len(taint.stack) >= 2 and taint.stack[-2]:
                            expression = taint.stack[-2][0]
                            taken = convert_stack_value_to_int(instruction["stack"][-2]) != 0
                            observed = expression != 0 if taken else expression == 0
                            names = {str(v) for expr in tuple(prefix) + (observed,) for v in get_vars(expr)}
                            if names and names.issubset(bindings):
                                branches.append(BranchConstraint(result.sequence, result.baseline,
                                                (tx_index, transaction.contract, instruction["pc"]),
                                                tuple(prefix), observed, tuple(bindings[n] for n in sorted(names))))
                            prefix.append(observed)
            except (AssertionError, IndexError, KeyError, ValueError, TypeError, z3.Z3Exception) as error:
                self.diagnostics.append((tx_index, "symbolic_trace_limitation", str(error)))
                analyzer.clear_storage()

                break
            if record.status != "SUCCESS":
                analyzer.storage = storage_before


            if record.computation.children:
                analyzer.clear_storage()
        return branches

    def solve_constraints(self, sequence, bindings, constraints, location=()):
        names = {binding.name for binding in bindings}
        unbound = {str(v) for expression in constraints for v in get_vars(expression)} - names
        if unbound:
            self.diagnostics.append((location, "unbound_model_variables", sorted(unbound)))
            return None
        solver = z3.Solver()
        solver.set(timeout=self.timeout_ms, random_seed=0)
        solver.add(*constraints)
        for binding in bindings:
            symbol = binding.symbol
            if binding.field == "sender":
                if self.mutate_sender:
                    solver.add(z3.Or(*(symbol == int(account, 16) for account in self.accounts)))
                else:


                    solver.add(symbol == int(sequence[binding.transaction_index].sender, 16))
            elif binding.field == "value":
                if self.value_candidates is not None:
                    values = self.value_candidates(sequence[binding.transaction_index])
                    solver.add(z3.Or(*(symbol == value for value in values)))
                else:
                    solver.add(z3.ULE(symbol, self.max_value))
            elif binding.field == "argument":
                text = binding.argument_type
                if text.startswith("uint"):
                    solver.add(z3.ULE(symbol, 2 ** int(text[4:] or "256") - 1))
                elif text.startswith("int"):
                    bits = int(text[3:] or "256")
                    solver.add(symbol >= -(2 ** (bits - 1)), symbol <= 2 ** (bits - 1) - 1)
                elif text == "address":
                    solver.add(z3.ULE(symbol, 2 ** 160 - 1))
                elif text == "bool":
                    solver.add(z3.ULE(symbol, 1))
                else:
                    self.diagnostics.append((location, "unsupported_model_type", text))
                    return None
        outcome = solver.check()
        if outcome != z3.sat:
            if outcome == z3.unknown:
                self.diagnostics.append((location, "solver_unknown", solver.reason_unknown()))
            return None
        model, candidate, values = solver.model(), sequence, []
        for binding in bindings:
            integer = model.eval(binding.symbol, model_completion=True).as_long()
            tx = candidate[binding.transaction_index]
            value = integer
            if binding.field == "argument":
                text = binding.argument_type
                if text == "address":
                    value = "0x%040x" % integer
                elif text == "bool":
                    value = bool(integer)
                elif text.startswith("int") and integer >= 2 ** 255:
                    value = integer - 2 ** 256
                args = list(tx.arguments)
                args[binding.argument_index] = value
                tx = tx.changed(arguments=tuple(args))
            elif binding.field == "sender":
                value = "0x%040x" % integer
                tx = tx.changed(sender=value)
            elif binding.field == "value":
                tx = tx.changed(value=value)
            elif binding.field in ("blocknumber", "timestamp"):
                tx = tx.changed(environment=replace(tx.environment, **{binding.field: value}))
            else:
                raise ValueError("Unsupported SMT binding field")
            candidate = candidate.replace_transaction(binding.transaction_index, tx)
            values.append((binding.name, value))
        if candidate.identity == sequence.identity:
            return None
        return ConcreteAssignment(candidate, tuple(values), location)

    def candidates(self, result, limit=8):
        assignments = []
        for branch in self.collect(result):
            key = (result.baseline.fingerprint, result.sequence.identity, branch.location,
                   tuple(expr.sexpr() for expr in branch.prefix), branch.observed.sexpr())
            if key in self.attempted:
                continue
            self.attempted.add(key)
            assignment = self.solve_constraints(branch.sequence, branch.bindings,
                                                 branch.prefix + (z3.Not(branch.observed),), branch.location)
            if assignment is not None:
                assignments.append(assignment)
            if len(assignments) >= limit:
                break
        return assignments
