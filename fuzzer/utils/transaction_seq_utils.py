import random

import networkx as nx
from slither import Slither

from slither.core.declarations import FunctionContract

from fuzzer.utils import settings
from slither.core.declarations import Contract, Function

DEBUG_MODE = False
init = False
sv_prepare = set()


define_table = dict()

use_table = dict()
has_data_info_func = dict()
function_can_not_call = set()
visited_find_inner_call_by_constractor = set()
storage_slot_id_2_var_name_maps = dict()


def check_cross_init():
    return init


def storage_slot_id_2_var_name(_sl: Slither):

    c = _sl.get_contract_from_name(settings.MAIN_CONTRACT_NAME)[0]
    for index, sv in enumerate(c.state_variables):
        storage_slot_id_2_var_name_maps[index] = sv.name
    print("===storage slot id to var name=====")
    print(storage_slot_id_2_var_name_maps)


def get_var_set_by_storage_slot_ids(_storage_slot_id: set):

    var_set = set()
    for id in _storage_slot_id:
        var_set.add(storage_slot_id_2_var_name_maps[id])
    return var_set


def extract_read_write_edge(contract, func, g):
    for sv_read in func.state_variables_read:
        g.add_edge(contract.name + "." + func.name, contract.name + "." + sv_read.name, type="sv_read", color="red")
    for sv_written in func.state_variables_written:
        g.add_edge(contract.name + "." + func.name, contract.name + "." + sv_written.name, type="sv_written",
                   color="blue")
    for high_level_call in func.high_level_calls:


        try:


            dest_contract_name = None
            if isinstance(high_level_call[0], Contract):
                dest_contract_name = high_level_call[0].name
            elif isinstance(high_level_call[0], str):
                dest_contract_name = high_level_call[0]


            dest_func_name = None
            if isinstance(high_level_call[1], Function):
                dest_func_name = high_level_call[1].name
            elif isinstance(high_level_call[1], str):
                dest_func_name = high_level_call[1]

            if dest_contract_name and dest_func_name:

                g.add_edge(
                    contract.name + "." + func.name,
                    dest_contract_name + "." + dest_func_name,
                    type="call"
                )

            else:

                pass

        except (IndexError, TypeError) as e:


            continue
    for internal_call in func.internal_calls:
        if isinstance(internal_call, FunctionContract):
            g.add_edge(contract.name + "." + func.name, contract.name + "." + internal_call.name, type="internal_call",
                       color="yellow")


def change_sha3_to_name(_sh3, _interface_mapper, func_address):
    contract_invoked = ""
    for c_name, deploy_add in settings.DEPLOYED_CONTRACT_ADDRESS.items():
        if deploy_add == func_address:
            contract_invoked = c_name
            break
    for f_name, sha3 in _interface_mapper[contract_invoked].items():
        if sha3 == _sh3:

            return contract_invoked + "." + f_name[:f_name.find("(")]


def deep_find_inner_call(_func, _contract):
    if _contract.name + "." + _func.name in visited_find_inner_call_by_constractor:
        return set()
    visited_find_inner_call_by_constractor.add(_contract.name + "." + _func.name)
    sv = set([_contract.name + "." + n.name for n in _func.state_variables_written])
    for internal_call in _func.internal_calls:
        if isinstance(internal_call, FunctionContract):
            sv.update(deep_find_inner_call(internal_call, _contract))
    return sv


def init_func(sol_path):
    global sv_prepare, use_table, define_table, has_data_info_func, init, function_can_not_call
    solc_path = settings.SOLC_PATH_CROSS
    g = nx.MultiDiGraph()
    sl = Slither(sol_path, solc=solc_path)
    storage_slot_id_2_var_name(sl)
    for contract in sl.contracts:
        for st in contract.state_variables:
            g.add_node(contract.name + "." + st.name, type="state", contract=contract.name, shape="box")
        for func in contract.functions:
            if func.is_constructor_variables:
                continue
            if func.visibility == "private" or func.visibility == "internal":
                function_can_not_call.add(contract.name + "." + func.name)
            if func.is_constructor:
                sv_by_constractor = deep_find_inner_call(func, contract)
                sv_prepare.update(sv_by_constractor)
                continue
            if func.is_fallback:
                continue
            g.add_node(contract.name + "." + func.name, type="func", contract=contract.name, visibility=func.visibility)
            extract_read_write_edge(contract, func, g)
            for modifier in func.modifiers:
                g.add_node(contract.name + "." + modifier.name, type="modifier", contract=contract.name)
                extract_read_write_edge(contract, modifier, g)
                g.add_edge(contract.name + "." + func.name, contract.name + "." + modifier.name, type="modifier",
                           color="black")
    if DEBUG_MODE:
        nx.drawing.nx_pydot.write_dot(g, "A_NX.dot")

    func_nodes = [n for n in g.nodes if g.nodes[n]["type"] == "func"]

    state_nodes = [n for n in g.nodes if g.nodes[n]["type"] == "state"]
    data_infos = []

    for func in func_nodes:
        for sv in state_nodes:

            paths = nx.all_simple_paths(g, func, sv)
            for path in paths:
                edges = []
                for i in range(len(path) - 1):
                    for each_edge in g[path[i]][path[i + 1]]:
                        edges.append(g[path[i]][path[i + 1]][each_edge]["type"])
                for edge in edges:
                    if edge == "sv_written":
                        data_infos.append((func, sv, "write"))
                    elif edge == "sv_read":
                        data_infos.append((func, sv, "read"))
    for func, sv, data_type in data_infos:
        temp_dict = has_data_info_func.get(func, {})
        temp_set = temp_dict.get(data_type, set())
        temp_set.add(sv)
        temp_dict[data_type] = temp_set
        has_data_info_func[func] = temp_dict

    base_pairs = []
    for func in has_data_info_func:
        sv_func_write = has_data_info_func[func].get("write", set())
        for other_func in has_data_info_func:
            if other_func == func:
                continue
            sv_other_func_read = has_data_info_func[other_func].get("read", set())
            if len(sv_func_write & sv_other_func_read) > 0:
                base_pairs.append((func, sv_func_write & sv_other_func_read, other_func))


    for setter, sv_set, getter in base_pairs:
        setter_set = define_table.get(setter, set())
        setter_set.update(sv_set)
        define_table[setter] = setter_set
        getter_set = use_table.get(getter, set())
        getter_set.update(sv_set)
        use_table[getter] = getter_set


    init = True


def get_write_read_by_indv(_indv, _index: int, _method: str):
    try:
        s = get_var_set_by_storage_slot_ids(
            settings.GLOBAL_DATA_INFO[_indv.hash][_index][_method]
        )
        return s
    except (KeyError, TypeError):
        return set()


def gen_trans(_bad_trans, interface_mapper):
    this_trans = []
    indv, index = _bad_trans
    chromosome = indv.chromosome
    target_func_call = chromosome[index]["arguments"][0]
    target_func_address = chromosome[index]["contract"]
    target_func_call = change_sha3_to_name(target_func_call, interface_mapper, target_func_address)
    already_executed_func_call = chromosome[:index]
    v_predefine = sv_prepare
    for index_1, already_exe in enumerate(already_executed_func_call):
        call = already_exe["arguments"][0]
        call_address = already_exe["contract"]
        call = change_sha3_to_name(call, interface_mapper, call_address)
        this_trans.append(call)
        v_predefine = v_predefine | get_write_read_by_indv(indv, index_1, "write")

    max_supply_length = settings.MAX_INDIVIDUAL_LENGTH - len(chromosome)
    visited = set(this_trans)
    while max_supply_length > 0:
        max_supply_length -= 1
        scores = []
        for func in has_data_info_func.keys():
            if func in function_can_not_call:
                continue
            if settings.DUPLICATION:
                if func in visited:
                    continue
            v_define_f = define_table.get(func, set())
            v_use_f = use_table.get(func, set())
            v_use_exp = get_write_read_by_indv(indv, index, "read")
            s_define = v_define_f - v_predefine
            s_provide = v_use_f & v_use_exp - v_predefine
            s_use = v_use_f - v_use_exp
            score = len(s_define) + len(s_provide) - len(s_use)
            scores.append((func, score))
        if len(scores) == 0:
            break
        scores.sort(key=lambda x: x[1], reverse=True)

        max_score = scores[0][1]
        scores = [score for score in scores if score[1] == max_score]
        scores = random.sample(scores, 1)
        this_trans.append(scores[0][0])
        v_predefine = v_predefine | define_table.get(scores[0][0], set())
        visited.add(scores[0][0])
        if len(use_table.get(target_func_call, set()) - v_predefine) == 0:
            break
    this_trans.append(target_func_call)
    return this_trans
