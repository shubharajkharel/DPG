# -*- coding: utf-8 -*-

import networkx as nx
from DPG.graphDPG import GraphDPG, DPGfeasibilityError
import unittest
import sys
import os
sys.path.append(os.path.abspath('../'))


class TestGraphDPG(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_init(self):
        G = nx.Graph()
        G.add_edges_from([(1, 2), (2, 3)])
        G = GraphDPG(G, 1)
        self.assertEqual(list(G.nodes), [1, 2, 3])
        self.assertEqual(list(G.edges), [(1, 2), (2, 3)])
        self.assertEqual(G.auxNode, 1)

    def test_auxNodeSetter(self):
        with self.assertRaises(ValueError):
            G = GraphDPG()
            G.auxNode = 1  # aux node no present
        with self.assertRaises(ValueError):
            G = GraphDPG()
            G.add_node(1)
            G.auxNode = 1  # aux node has diferent deg than 1

    def test_selfLoops(self):
        # cannot initialize DPG graph with multiedges
        with self.assertRaises(TypeError):
            G = nx.Graph()
            G.add_edge(1, 1)
            GraphDPG(G)

    def test_DPG(self):
        def degList(G): return [deg[1] for deg in list(G.degree)]
        G = GraphDPG()
        G + 0  # zero deg vertex
        self.assertEqual(degList(G), [0])
        self.assertEqual(G.hasAuxNode(), False)
        G + 1  # odd without aux
        self.assertEqual(degList(G), [0, 1, 1])
        self.assertEqual(G.hasAuxNode(), True)
        G + 1  # odd with aux
        self.assertEqual(degList(G), [0, 1, 1])
        self.assertEqual(G.hasAuxNode(), False)
        G + 2  # even wihtout aux
        self.assertEqual(degList(G), [0, 1, 1, 2])
        self.assertEqual(G.hasAuxNode(), False)
        with self.assertRaises(DPGfeasibilityError):
            G + 4  # infeasible when even
        with self.assertRaises(DPGfeasibilityError):
            G + 5  # infeasible when odd
        G + 3  # odd when no aux but not enough matching
        self.assertEqual(degList(G), [0, 1, 1, 2, 3, 1])
        self.assertEqual(G.hasAuxNode(), True)
        G+2  # even with aux
        self.assertEqual(degList(G), [0, 1, 1, 2, 3, 1, 2])
        self.assertEqual(G.hasAuxNode(), True)
        G + 3  # odd with aux
        self.assertEqual(degList(G), [0, 1, 1, 2, 3, 2, 3])
        self.assertEqual(G.hasAuxNode(), False)


if __name__ == "__main__":
    unittest.main()
