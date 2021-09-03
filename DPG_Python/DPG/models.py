# -*- coding: utf-8 -*-
"""
@author: Shubha Raj Kharel
"""
import networkx as nx
# TODO: fix this quick hack
if __name__ == "__main__":
    from graphDPG import GraphDPG
    from utils import timeIt
elif __name__ == "DPG.models":
    from DPG.graphDPG import GraphDPG
    from DPG.utils import timeIt

from collections.abc import Iterable
from math import ceil

# @timeIt


def regularDPG(n: int, d: int):
    """"A DPG model that grows regular graph with n nodes degree d"""
    if n < d+1:
        raise ValueError("Order of d-regular graph must be at least d+1")
    G0 = GraphDPG(nx.complete_graph(d+1))  # seed graph
    return G0 + (d for _ in range(n-d-1))
#    return iconfigDPG((d for _ in range(n-d-1)))


def iconfigDPG(deg_generator: Iterable, G0=None):
    """Configurational DPG from seed graph G0 using degree generator"""
    degree_list = list(deg_generator)
    degree_list.sort()
    # generate seed graph, if no seed graph is given
    if G0 == None:
        for n0 in range(1, len(degree_list)+1):
            if nx.is_graphical(degree_list[:n0]):
                G0 = GraphDPG(
                    nx.generators.degree_seq.havel_hakimi_graph(  # use havel hakimi algo
                        degree_list[:n0]))
                degree_list = degree_list[n0:]
                break
    return G0 + degree_list


def linDPG(n: int, c: float, G0=None):
    """Does linDPG from G0 with parameter c"""

    if c <= 0 or c > 1:
        raise ValueError("Value of c must be in range (0,1]")
    G = G0 if G0 != None else (GraphDPG()+1)
    for _ in range(n-2):
        matching_number = len(
            nx.algorithms.matching.max_weight_matching(G, True))
        degree = 2 * ceil(c*matching_number)
        G + degree
    return G


if __name__ == "__main__":
    # Create Regular graphs for different degrees
    regularDPG(10, 2).show()
    regularDPG(10, 3).show()  # TODO: figure out why sometimes deg 2 is coming

    # create random graphical degree sequence
    degrees = [x[1] for x in nx.erdos_renyi_graph(10, 0.5).degree]
    # generate graph with same degree sequence using DPG
    iconfigDPG(degrees).show()

    # create random graphical degree sequence
    degrees = [x[1] for x in nx.erdos_renyi_graph(10, 0.8).degree]
    # generate graph with same degree sequence using DPG
    iconfigDPG(degrees).show()

    # generate linDPG Graph with different parameter
    linDPG(40, 0.25).show()
    linDPG(40, 0.5).show()
    linDPG(40, 0.75).show()
    linDPG(40, 1).show()  # equivalent to maxDPG
