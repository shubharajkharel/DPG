# -*- coding: utf-8 -*-
"""
Created on Mon Jan 11 06:29:22 2021

@author: Shubha
"""
import networkx as nx


def timeIt(method):
    """Measures execution time of method in ms.
        Useful Decorator."""
    import time

    def timed(*args, **kw):
        t_start = time.perf_counter()
        result = method(*args, **kw)
        t_end = time.perf_counter()
        interval = (t_end-t_start)*1000
        fName = method.__name__
        print("Time taken ({}): {:.3f} ms".format(fName, interval))
        return result
    return timed


def ERGraph(n, p, **kwargs):
    """Erdos-reyni graph with n nodes and probabilty p"""
    return nx.fast_gnp_random_graph(n, p, **kwargs)
