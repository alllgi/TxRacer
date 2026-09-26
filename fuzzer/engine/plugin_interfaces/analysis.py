#!/usr/bin/env python


from .metaclasses import AnalysisMeta


class OnTheFlyAnalysis(metaclass=AnalysisMeta):


    master_only = False


    interval = 1

    def setup(self, ng, engine):

        raise NotImplementedError

    def register_step(self, g, population, engine):

        raise NotImplementedError

    def finalize(self, population, engine):

        raise NotImplementedError
