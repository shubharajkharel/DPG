# -*- coding: utf-8 -*-
"""
Created on Mon Jan 11 06:28:28 2021

@author: Shubha Raj Kharels
"""

import networkx as nx
import random


def Matching(G, size, *args, **kwargs):
    """ Finds the independent edges of give size in G.
        First tries greedy approach.
        If not sufficent then switches to sample subset of maximum matchig."""

    M = GreedyMatching(G.edges, size)

    if len(M) < size:
        # TODO: Implement Blossom algorithm
        M = nx.algorithms.matching.max_weight_matching(G, True)

    if len(M) >= size:
        M = random.sample(M, size)
    else:
        raise smallMatchingSizeError(size)
#        raise Exception("Matching of size {} not found".format(size))
    return M


def GreedyMatching(edges, max_count: int):
    """Find matching greedily.
       Edges are picked sequentially from top of input.
       So, useful for greedy matching with weights as well."""
    M = set()
    matched_nodes = set()
    for u, v in edges:
        if u not in matched_nodes and v not in matched_nodes:
            matched_nodes.add(u)
            matched_nodes.add(v)
            M.add((u, v))
            if len(M) == max_count:
                return M
    return M

# TODO: Implement Blossom algorithm


def FindAugmentingPath(G, matching):
    pass


def Augment(path, matching):
    pass


class smallMatchingSizeError(Exception):
    """Raised when matching of required size cannot be found"""

    def __init__(self, size):
        self.message = f"Matching of size {size} not found"
        super().__init__(self.message)

# %%


if __name__ == "__main__":
    from utils import ERGraph
    from graphDPG import GraphDPG
    # Find matching in Erdos-Reyni Graph
    G = GraphDPG(ERGraph(10, 1))
    M = Matching(G, 3)
    print(M)

    # should raise error
#    Matching(G,10)
