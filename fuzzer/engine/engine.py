#!/usr/bin/env python3


import math
import random
import sys
import time
import logging

from functools import wraps


import cProfile
import pstats
import os


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/../'

sys.path.append(BASE_DIR)
from fuzzer.utils import settings
from fuzzer.txracer.reporting import StopOnFirstFinding

from .components import Individual, Population
from .plugin_interfaces.operators import Selection, Crossover, Mutation
from .plugin_interfaces.analysis import OnTheFlyAnalysis


def do_profile(filename, sortby='tottime'):


    def _do_profile(func):


        @wraps(func)
        def profiled_func(*args, **kwargs):


            DO_PROF = os.getenv('PROFILING')

            if DO_PROF:
                profile = cProfile.Profile()
                profile.enable()
                result = func(*args, **kwargs)
                profile.disable()
                ps = pstats.Stats(profile).sort_stats(sortby)
                ps.dump_stats(filename)
            else:
                result = func(*args, **kwargs)
            return result

        return profiled_func

    return _do_profile


class StatVar(object):
    def __init__(self, name):


        self.name = '_{}'.format(name)

    def __get__(self, engine, cls):

        stat_var = getattr(engine, self.name)
        if stat_var is None:
            if 'min' in self.name and 'ori' in self.name:
                stat_var = engine.population.min(engine.ori_fitness)
            elif 'min' in self.name:
                stat_var = engine.population.min(engine.fitness)
            elif 'max' in self.name and 'ori' in self.name:
                stat_var = engine.population.max(engine.ori_fitness)
            elif 'max' in self.name:
                stat_var = engine.population.max(engine.fitness)
            elif 'mean' in self.name and 'ori' in self.name:
                stat_var = engine.population.mean(engine.ori_fitness)
            elif 'mean' in self.name:
                stat_var = engine.population.mean(engine.fitness)
            setattr(engine, self.name, stat_var)
        return stat_var

    def __set__(self, engine, value):

        setattr(engine, self.name, value)


class EvolutionaryFuzzingEngine(object):

    fmax, fmin, fmean = StatVar('fmax'), StatVar('fmin'), StatVar('fmean')
    ori_fmax, ori_fmin, ori_fmean = (StatVar('ori_fmax'),
                                     StatVar('ori_fmin'),
                                     StatVar('ori_fmean'))

    def __init__(self, population, selection, crossover, mutation, fitness=None, analysis=None, mapping=None):

        logger_name = 'engine.{}'.format(self.__class__.__name__)
        self.logger = logging.getLogger(logger_name)


        self.population = population
        self.fitness = fitness
        self.selection = selection
        self.crossover = crossover
        self.mutation = mutation
        self.analysis = [] if analysis is None else [a() for a in analysis]
        self.mapping = mapping


        self._fmax, self._fmin, self._fmean = None, None, None
        self._ori_fmax, self._ori_fmin, self._ori_fmean = None, None, None


        self.ori_fitness = None if self.fitness is None else self.fitness


        self.current_generation = -1


        self.stop_finding_id = None


        self._check_parameters()

    @do_profile(filename='engine_run.prof')
    def run(self, ng):

        try:
            execution_begin = time.time()

            if self.fitness is None:
                raise AttributeError('No fitness function in GA engine')


            for a in self.analysis:
                a.setup(ng=ng, engine=self)


            g = 0
            while g < ng or settings.GLOBAL_TIMEOUT:
                print("Evolution iteration: ", g)
                if settings.GLOBAL_TIMEOUT and time.time() - execution_begin >= settings.GLOBAL_TIMEOUT:
                    break

                self.current_generation = g

                indvs = []

                size = self.population.size // 3


                if settings.TRANS_MODE == "cross" and len(settings.TRANS_CROSS_BAD_INDVS) > 0:
                    new_pop = self.population.new()
                    new_pop.size = size
                    indv = new_pop.init()
                    if settings.TRANS_SUPPORT_MODE == 1:
                        for child in indv:
                            child.append_other()
                    indvs.extend(indv)
                size = (self.population.size - len(indvs)) // 2
                for _ in range(size):

                    parents = self.selection.select(self.population, fitness=self.fitness)

                    children = self.crossover.cross(*parents)

                    children = [self.mutation.mutate(child, self) for child in children]
                    if settings.TRANS_SUPPORT_MODE == 1:
                        for child in children:
                            child.append_other()

                    indvs.extend(children)


                if settings.ASSET_STATE_FEEDBACK:
                    pipeline = getattr(
                        self.analysis[0].env, "state_feedback_pipeline", None) \
                        if self.analysis else None
                    if pipeline is not None and indvs:
                        state_seeds = pipeline.state_corpus_seeds()
                        coverage_pool = [
                            getattr(indv, "hash", "indv-%d" % i)
                            for i, indv in enumerate(indvs)
                        ]
                        for i in range(len(indvs)):
                            side, seed = pipeline.dual.choose_seed(
                                state_seeds, coverage_pool, generation=g)
                            if side == "state" and seed is not None and \
                                    seed.get("chromosome"):
                                rebuilt = self._individual_from_seed(seed)
                                if rebuilt is not None:
                                    indvs[i] = rebuilt

                settings.TRANS_MODE = "origin"
                settings.TRANS_CROSS_BAD_INDVS = []
                settings.TRANS_CROSS_BAD_INDVS_HASH = set()

                self.population.individuals = indvs

                for a in self.analysis:
                    if g % a.interval == 0:
                        a.register_step(g=g, population=self.population, engine=self)


                if settings.ASSET_STATE_FEEDBACK:
                    pipeline = getattr(
                        self.analysis[0].env, "state_feedback_pipeline", None) \
                        if self.analysis else None
                    if pipeline is not None:
                        env = self.analysis[0].env
                        coverage_count = len(
                            getattr(env, "code_coverage", set()) or set())
                        choices = pipeline.dual.drain_choices()
                        state_selected = sum(
                            1 for c in choices if c["side"] == "state")
                        coverage_selected = sum(
                            1 for c in choices if c["side"] == "coverage")
                        empty_selected = sum(
                            1 for c in choices if c["side"] == "empty")

                        state_fallback = sum(
                            1 for c in choices
                            if c["side"] == "coverage"
                            and c.get("state_size", 0) == 0)
                        pipeline.finalize_generation(
                            generation=g, new_coverage=coverage_count,
                            state_corpus_pool=pipeline.state_corpus_seeds(),
                            coverage_pool=indvs,
                            state_selected=state_selected,
                            coverage_selected=coverage_selected,
                            state_fallback=state_fallback,
                            coverage_fallback=empty_selected,
                            choices=choices)
                        if pipeline.dual.rebuild_requested:
                            self.population.individuals = []
                            self.population.init(no_cross=True)
                            pipeline.dual.mark_rebuild_done()
                            self.logger.info(
                                "Phase 4 dual corpus: population rebuilt "
                                "after coverage stagnation")

                g += 1
        except StopOnFirstFinding as stop_finding:


            self.stop_finding_id = str(stop_finding)
            self.logger.info("Stop-on-first-finding consumed: %s", self.stop_finding_id)
        except Exception as e:

            msg = '{} exception is catched'.format(type(e).__name__)
            self.logger.exception(msg)
            raise e
        finally:

            for a in self.analysis:
                a.finalize(population=self.population, engine=self)

    def _individual_from_seed(self, seed):

        from copy import deepcopy
        IndvType = self.population.indv_template.__class__
        try:
            indv = IndvType(
                generator=self.population.indv_generator,
                other_generators=self.population.other_generators)
            indv.init(chromosome=deepcopy(seed.get("chromosome")))
            return indv
        except Exception as rebuild_error:
            self.logger.warning(
                "Phase 4 dual corpus: seed rebuild failed: %s",
                rebuild_error)
            return None

    def _update_statvars(self):


        self.ori_fmax = self.population.max(self.ori_fitness)
        self.ori_fmin = self.population.min(self.ori_fitness)
        self.ori_fmean = self.population.mean(self.ori_fitness)


        self.fmax = self.population.max(self.fitness)
        self.fmin = self.population.min(self.fitness)
        self.fmean = self.population.mean(self.fitness)

    def _check_parameters(self):

        if not isinstance(self.population, Population):
            raise TypeError('population must be a Population object')
        if not isinstance(self.selection, Selection):
            raise TypeError('selection operator must be a Selection instance')
        if not isinstance(self.crossover, Crossover):
            raise TypeError('crossover operator must be a Crossover instance')
        if not isinstance(self.mutation, Mutation):
            raise TypeError('mutation operator must be a Mutation instance')

        for ap in self.analysis:
            if not isinstance(ap, OnTheFlyAnalysis):
                msg = '{} is not subclass of OnTheFlyAnalysis'.format(ap.__name__)
                raise TypeError(msg)


    def fitness_register(self, fn):


        @wraps(fn)
        def _fn_with_fitness_check(indv):


            if not isinstance(indv, Individual):
                raise TypeError('indv\'s class must be Individual or a subclass of Individual')


            fitness = fn(indv)
            is_invalid = (type(fitness) is not float) or (math.isnan(fitness))
            if is_invalid:
                msg = 'Fitness value(value: {}, type: {}) is invalid'
                msg = msg.format(fitness, type(fitness))
                raise ValueError(msg)
            return fitness

        self.fitness = _fn_with_fitness_check
        if self.ori_fitness is None:
            self.ori_fitness = _fn_with_fitness_check

    def analysis_register(self, analysis_cls):

        if not issubclass(analysis_cls, OnTheFlyAnalysis):
            raise TypeError('analysis class must be subclass of OnTheFlyAnalysis')


        analysis = analysis_cls()
        self.analysis.append(analysis)


    def linear_scaling(self, target='max', ksi=0.5):


        def _linear_scaling(fn):

            self.ori_fitness = fn

            @wraps(fn)
            def _fn_with_linear_scaling(indv):

                f = fn(indv)


                if target == 'max':
                    f_prime = f - self.ori_fmin + ksi
                elif target == 'min':
                    f_prime = self.ori_fmax - f + ksi
                else:
                    raise ValueError('Invalid target type({})'.format(target))
                return f_prime

            return _fn_with_linear_scaling

        return _linear_scaling

    def dynamic_linear_scaling(self, target='max', ksi0=2, r=0.9):


        def _dynamic_linear_scaling(fn):

            self.ori_fitness = fn

            @wraps(fn)
            def _fn_with_dynamic_linear_scaling(indv):
                f = fn(indv)
                k = self.current_generation + 1

                if target == 'max':
                    f_prime = f - self.ori_fmin + ksi0 * (r ** k)
                elif target == 'min':
                    f_prime = self.ori_fmax - f + ksi0 * (r ** k)
                else:
                    raise ValueError('Invalid target type({})'.format(target))
                return f_prime

            return _fn_with_dynamic_linear_scaling

        return _dynamic_linear_scaling

    def minimize(self, fn):


        @wraps(fn)
        def _minimize(indv):
            return -fn(indv)

        return _minimize
