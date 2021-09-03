import networkx as nx
from DPG.graphDPG import GraphDPG
from DPG.matching import GreedyMatching, Matching
import unittest
import sys
import os
sys.path.append(os.path.abspath('../'))


class TestMatching(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_GreedyMatching(self):
        n = 4
        G = GraphDPG(nx.cycle_graph(n))
        M = GreedyMatching(G.edges(), 2)
        self.assertEqual(len(M), 2)
        matched_nodes = set()
        for u, v in M:
            self.assertNotIn(u, matched_nodes)
            self.assertNotIn(v, matched_nodes)
            matched_nodes.add(u)
            matched_nodes.add(v)

    def test_Matching(self):
        n = 12
        G = GraphDPG(nx.cycle_graph(n))
        self.assertEqual(len(Matching(G, 3)), 3)
        self.assertEqual(len(Matching(G, 6)), 6)
        with self.assertRaises(Exception):
            Matching(G, 7)


#
# Executing the tests in the above test case class
if __name__ == "__main__":
    unittest.main()
