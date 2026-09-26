#!/usr/bin/env python


from ..metaclasses import MutationMeta


class Mutation(metaclass=MutationMeta):


    pm = 0.1

    def mutate(self, individual, engine):

        raise NotImplementedError
