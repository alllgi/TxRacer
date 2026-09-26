#!/usr/bin/env python3

import random

from fuzzer.utils import settings
from fuzzer.engine.components.individual import Individual

from eth_utils import to_canonical_address, function_signature_to_4byte_selector
from fuzzer.utils import settings
from eth_abi import encode_abi
from web3 import Web3

class Individuals(object):


    def __init__(self, name):
        self.name = '_{}'.format(name)

    def __get__(self, instance, owner):
        return instance.__dict__[self.name]

    def __set__(self, instance, value):
        instance.__dict__[self.name] = value

        instance.update_flag()


class Population(object):


    individuals = Individuals('individuals')

    def __init__(self, indv_template, indv_generator, size=100, other_generators=None):


        if size % 2 != 0:
            raise ValueError('Population size must be an even number')
        self.size = size


        self.indv_template = indv_template


        self.indv_generator = indv_generator


        self._updated = False


        class IndvList(list):


            def __init__(this, *args):
                super(this.__class__, this).__init__(*args)

            """def __setitem__(this, key, value):
                '''
                Override __setitem__ in built-in list type.
                '''
                old_value = this[key]
                if old_value == value:
                    return
                super(this.__class__, self).__setitem__(key, value)
                # Update population flag.
                self.update_flag()"""

            def append(this, item):

                super(this.__class__, this).append(item)

                self.update_flag()

            def extend(this, iterable_item):
                if not iterable_item:
                    return
                super(this.__class__, this).extend(iterable_item)

                self.update_flag()


        self._individuals = IndvList()

        self.other_generators = other_generators if other_generators is not None else []

    def init(self, indvs=None, init_seed=False, no_cross=False):

        IndvType = self.indv_template.__class__

        if indvs is None:
            if init_seed:
                for g in self.other_generators + [self.indv_generator]:
                    for func_hash, func_args_types in g.interface.items():
                        indv = IndvType(generator=g, other_generators=g.other_generators).init(func_hash=func_hash, func_args_types=func_args_types, default_value=True)
                        if len(indv.chromosome) == 0:
                            if len(self.individuals) % 2 != 0:
                                indv_single = IndvType(generator=g, other_generators=g.other_generators).init(single=True, func_hash=func_hash, func_args_types=func_args_types, default_value=True)
                                self.individuals.append(indv_single)
                            else:
                                break
                        else:
                            self.individuals.append(indv)
            else:
                while len(self.individuals) < self.size:
                    chosen_generator = self.indv_generator
                    indv = IndvType(generator=chosen_generator, other_generators=chosen_generator.other_generators).init(no_cross=no_cross)
                    if len(indv.chromosome) == 0:
                        if len(self.individuals) % 2 != 0:
                            indv_single = IndvType(generator=chosen_generator, other_generators=chosen_generator.other_generators).init(single=True, no_cross=no_cross)
                            self.individuals.append(indv_single)
                        else:
                            break
                    else:
                        self.individuals.append(indv)
        else:

            if len(indvs) != self.size:
                raise ValueError('Invalid individuals number')
            for indv in indvs:


                if not isinstance(indv, Individual):
                    raise ValueError('individual class must be Individual or a subclass of Individual')
            self.individuals = indvs

        self._updated = True
        self.size = len(self.individuals)
        return self

    def update_flag(self):

        self._updated = True

    @property
    def updated(self):

        return self._updated

    def new(self):

        return self.__class__(indv_template=self.indv_template, size=self.size, indv_generator=self.indv_generator, other_generators=self.other_generators)

    def __getitem__(self, key):

        if key < 0 or key >= self.size:
            raise IndexError('Individual index({}) out of range'.format(key))
        return self.individuals[key]

    def __len__(self):

        return len(self.individuals)

    def best_indv(self, fitness):

        all_fits = self.all_fits(fitness)
        return max(self.individuals, key=lambda indv: all_fits[self.individuals.index(indv)])

    def worst_indv(self, fitness):

        all_fits = self.all_fits(fitness)
        return min(self.individuals, key=lambda indv: all_fits[self.individuals.index(indv)])

    def max(self, fitness):

        return max(self.all_fits(fitness))

    def min(self, fitness):

        return min(self.all_fits(fitness))

    def mean(self, fitness):

        all_fits = self.all_fits(fitness)
        return sum(all_fits) / len(all_fits)

    def all_fits(self, fitness):

        return [fitness(indv) for indv in self.individuals]


    def init_from_template(self, sequence_template):
        print(f"Initializing population from template by manually forging genes...")
        self.individuals = []

        IndvType = self.indv_template.__class__
        generator_map = {self.indv_generator.contract_name: self.indv_generator}
        for g in self.other_generators:
            generator_map[g.contract_name] = g

        for _ in range(self.size):
            new_indv = IndvType(generator=self.indv_generator, other_generators=self.other_generators)
            new_chromosome = []

            for task in sequence_template:
                target_contract_name = task.get('contract')
                func_sig = task.get('signature')
                if not target_contract_name or not func_sig: continue

                target_generator = generator_map.get(target_contract_name)
                if not target_generator:
                    print(f"Could not find generator for '{target_contract_name}'. Skipping.")
                    continue

                try:


                    func_hash, arg_types = target_generator.get_specific_function_with_argument_types(func_sig)


                    arguments = [func_hash]
                    for index, arg_type in enumerate(arg_types):

                        arguments.append(target_generator.get_random_argument(arg_type, func_hash, index))


                    correct_contract_address = settings.DEPLOYED_CONTRACT_ADDRESS.get(target_contract_name)
                    if not correct_contract_address:
                        print(f"Could not find DEPLOYED address for '{target_contract_name}'. Skipping.")
                        continue


                    gene = {
                        "account": target_generator.get_random_account(func_hash),
                        "contract": correct_contract_address,
                        "amount": target_generator.get_random_amount(func_hash),
                        "arguments": arguments,
                        "blocknumber": target_generator.get_random_blocknumber(func_hash),
                        "timestamp": target_generator.get_random_timestamp(func_hash),
                        "gaslimit": target_generator.get_random_gaslimit(func_hash),
                        "call_return": {}, "extcodesize": {}, "returndatasize": {}
                    }
                    new_chromosome.append(gene)

                except KeyError:
                    print(f"Sig '{func_sig}' not in '{target_generator.contract_name}' generator. Skipping.")
                except Exception as e:
                    print(f"Error forging gene for task '{task}': {e}")

            new_indv.init(chromosome=new_chromosome)
            self.individuals.append(new_indv)

        return self
