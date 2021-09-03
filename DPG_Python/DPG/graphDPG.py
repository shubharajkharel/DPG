# -*- coding: utf-8 -*-
"""
Created on Mon Jan 11 06:29:13 2021
#TODO: Add Description
@author: Shubha Raj Kharel
"""
import random
from math import ceil
import networkx as nx
from matplotlib import pyplot as plt
from multipledispatch import dispatch
from collections.abc import Iterable

# TODO: find alternative to  this quick hack
if __name__ == "__main__":
    from matching import Matching, smallMatchingSizeError

if __name__ == "DPG.graphDPG":
    from DPG.matching import Matching, smallMatchingSizeError


class GraphDPG(nx.Graph):
    """ Graph class from DPG-graphs.
    DPG graphs are simple graphs which also can contain an auxiliary node.
    """

    def __init__(self, graph=None, aNode=None, **attr):
        """Initialization of DPG graph using base class for simple Graph. 
            Base class allows self loops but DPG graphs do not."""
        # Do not allow self loops
        if graph != None and nx.number_of_selfloops(graph) != 0:
            raise TypeError("DPG graphs cannot have self-loops.")
        super().__init__(graph, **attr)     # Initialize base class
        self.auxNode = aNode                  # call to setter function

    @property
    def auxNode(self):
        """Getter for auxilliary node whose value can be None."""
        return self.__auxNode

    @auxNode.setter
    def auxNode(self, auxNode):
        """Setter for auxNode.
            Checks if node really exists.
            Checks if node degree is exactly 1."""
        if auxNode != None:
            if self.has_node(auxNode) == False:
                raise ValueError("Auxiliary node is not present in DPG Graph.")
            if self.degree(auxNode) != 1:
                raise ValueError("Auxillary node has degree other than one.")
        self.__auxNode = auxNode

    def hasAuxNode(self):
        """Check is auxilliary node is present.
        Useful when defining cases for DPG and inverse-DPG"""
        return self.auxNode != None

    def removeAuxNode(self):
        """ Removes auxilliary node from form DPG graphs"""
        if self.auxNode == None:
            raise ValueError("Auxilliary node does not exists.")
        self.remove_node(self.auxNode)
        self.auxNode = None

    def clear(self):
        """Clears the graph elements including auxNode"""
        self.auxNode = None
        super().clear()

    def show(self, layout=nx.kamada_kawai_layout, labelsQ=True):
        """ Draws the DPG graph using force based layout.
        Useful for quick testing."""
        plt.clf()
        nx.draw_networkx(self, layout(self), with_labels=labelsQ)
        plt.show()

    def add_edge(self, u, v, **attr):
        """Adds edges disallowing the self loops. 
        Mutiedges is not allowed by base class function"""
        if u == v:
            raise ValueError(f"DPG graphs cannot have self loops.")
        super().add_edge(u, v, **attr)

#    # TODO : figure out why overriding this function creates error in graph initialization
#    def add_edges_from(self,ebunch_to_add,**attr):
#        """ Adds edges from list of edges avoiding self loops"""
#        for u,v in ebunch_to_add:
#            self.add_edge(u,v)

    def __repr__(self):
        s = f"DPG Graph: "
        s += f"{self.number_of_nodes()} nodes, "
        s += f"{self.number_of_edges()} edges \n"
        s += f"Degrees = {[self.degree[n] for n in self.nodes()]}"
        return s

    def __add__(self, d):
        """Add node with degree or list of nodes with degrees d into DPG graph"""
        return self.DPG(d)

    @dispatch(Iterable)  # handles list and generators of degrees
    def DPG(self, degree_list):
        """Grows graph G by adding nodes in degree_list using DPG"""
        for d in degree_list:
            self.DPG(d)
        return self

    @dispatch(int)
    def DPG(self, d: int):
        """Grows graph G by adding node with degree d using DPG"""
        if d < 0:
            raise ValueError(f"Degree ({d}) must be non-negative integer.")
        if (d % 2) == 0:
            return self._EvenDPG(d)
        else:  # odd degree
            if self.hasAuxNode():
                return self._OddDPGWithAux(d)
            else:
                return self._OddDPGWithoutAux(d)

    def _EvenDPG(self, d, *args, **kwargs):
        """Grows G by DPG-adding new node with even degree d"""
        try:
            M = Matching(self, d//2)
        except Exception:
            raise DPGfeasibilityError(d)
        dpg_node = self._newNodeName()
        self._DPGJoin(M, dpg_node)
        return self

    def _OddDPGWithAux(self, d):
        """Grows G without aux node by DPG-adding new node with odd degree d"""
        subG = nx.subgraph_view(self,
                                filter_node=lambda n: n != self.auxNode)
        try:
            M = Matching(subG, d//2)
        except smallMatchingSizeError:
            raise DPGfeasibilityError(d)
        dpg_node = self._newNodeName()
        self._DPGJoin(M, dpg_node)
        self.add_edge(dpg_node,
                      next(self.neighbors(self.auxNode)))  # neighbor of aux Node
        self.removeAuxNode()
        return self

    def _OddDPGWithoutAux(self, d, aux_location=None):
        """Grows G wit aux node by DPG-adding new node with odd degree d"""
        # Determine where aux node is to be connected (dpg_node, dpg_neighbour)
        if aux_location == None:  # pick randomly if no prefrence is given
            aux_location = random.choices(['dpg_node', 'dpg_neighbour'],
                                          weights=[1, d+1])[0]  # gives equal prob. to outcomes
            return self._OddDPGWithoutAux(d, aux_location)
        if aux_location == 'dpg_neighbour':  # connect aux node to neighbour of dpg node
            # if matching size is not enough
            # for aux node to be connected with the neighbour of dpg_node
            # try to put aux node in dpg_node itself (includes empty graph)
            try:
                M = Matching(self, ceil(d/2))
            except smallMatchingSizeError:
                return self._OddDPGWithoutAux(d, 'dpg_node')
            random.shuffle(M)  # does in-place shuffling
            # aux node will join with one node in this edge
            rnd_edge = list(M.pop())
            # add DPG node
            dpg_node = self._newNodeName()
            self._DPGJoin(M, dpg_node)
            # handle the connection with randomly selected edge
            aux_node_name = self._newNodeName()
            random.shuffle(rnd_edge)
            neigh_dpg, neigh_aux = rnd_edge
            self.add_edge(neigh_dpg, dpg_node)
            self.add_edge(neigh_aux, aux_node_name)
            self.remove_edge(neigh_dpg, neigh_aux)
            self.auxNode = aux_node_name
        if aux_location == 'dpg_node':  # connect aux node to new dpg node
            try:
                M = Matching(self, d//2)
            except smallMatchingSizeError:
                raise DPGfeasibilityError(d)
            dpg_node = self._newNodeName()
            self._DPGJoin(M, dpg_node)
            aux_node_name = self._newNodeName()
            self.add_edge(dpg_node, aux_node_name)
            self.auxNode = aux_node_name
        return self

    def _DPGJoin(self, matching, dpg_node):
        """Helper function that removes edges in matching and joins the dpg_node with the nodes in M"""
        self.add_node(
            dpg_node)  # redundant in most cases except when d=1 and G=empty
        for u, v in matching:
            self.add_edge(dpg_node, u)
            self.add_edge(dpg_node, v)
            self.remove_edge(u, v)

    def _newNodeName(self, *args, **kwargs):
        """Finds a unique name for new node"""
        # TODO: find better way
        new_node_name = self.order() + 1
        while new_node_name in self.nodes:
            new_node_name += 1
        return new_node_name


class DPGfeasibilityError(Exception):
    """Raised when node cannot be added through DPG"""

    def __init__(self, d=None):
        if d == None:
            self.message = "Node cannot be DPG-added."
        else:
            self.message = f"Node with degree {d} could not be DPG-added."
        super().__init__(self.message)


if __name__ == "__main__":
    G = GraphDPG()
    G.DPG(1).show()
