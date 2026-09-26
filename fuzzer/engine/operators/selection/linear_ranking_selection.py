#!/usr/bin/env python3


from random import random, shuffle, choice
from itertools import accumulate
from bisect import bisect_right

from ...plugin_interfaces.operators.selection import Selection

class LinearRankingSelection(Selection):
    def __init__(self, pmin=0.1, pmax=0.9):


        self.pmin, self.pmax = pmin, pmax

    def select(self, population, fitness):


        all_fits = population.all_fits(fitness)
        indvs = population.individuals
        sorted_indvs = sorted(indvs, key=lambda indv: all_fits[indvs.index(indv)])


        NP = len(population)


        p = lambda i: (self.pmin + (self.pmax - self.pmin)*(i-1)/(NP-1))
        probabilities = [self.pmin] + [p(i) for i in range(2, NP)] + [self.pmax]


        psum = sum(probabilities)
        wheel = list(accumulate([p/psum for p in probabilities]))


        father_idx = bisect_right(wheel, random())
        father = sorted_indvs[father_idx]
        mother_idx = (father_idx + 1) % len(wheel)
        mother = sorted_indvs[mother_idx]

        return father, mother
