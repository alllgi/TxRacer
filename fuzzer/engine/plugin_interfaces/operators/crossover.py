#!/usr/bin/env python


from ..metaclasses import CrossoverMeta


class Crossover(metaclass=CrossoverMeta):


    pc = 0.8

    def cross(self, father, mother):

        raise NotImplementedError
