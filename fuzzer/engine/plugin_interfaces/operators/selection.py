#!/usr/bin/env python


from ..metaclasses import SelectionMeta

class Selection(metaclass=SelectionMeta):


    def select(self, population):

        raise NotImplementedError
