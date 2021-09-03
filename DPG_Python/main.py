'''
Description:
    This projects implements a network growth model called DPG.
    DPG grows a network by adding one node at and time and does so without
    chaning the degrees of the exisiting nodes. 
    Degree of a node is number of neighbour of a node. 
    
    Use class GraphDPG to create DPG graphs:
        G = GraphDPG()    # Empty DPG graph
        G + 1 + 1            # adds 2 nodes with degress 1
        Alternaives representation:
            G.DPG([1,1])
            G + [1,1]
            G + (1,1)
        Use show() function to see the network plot:
            G.show()
    
    There are 3 models of DPG currently defined:
        1. regular DPG:
            Creates graphs with where all nodes have same degree.
            example:
                DPG.regularDPG(10,2)    # creates 2-regular graph with 10 nodes 
        
        2. iconfigDPG:
            Creates graphs whose degree sequence is given.
            example:
                DPG.iconfigDPG([2,2,2])   #creates a triangle
                
        3. linDPG:
            Creates linear DPG graphs with paramter c.
            example:
                DPG.linDPG(20,0.5)   # linear DPG graphs with 10 nodes and c=0.5

Tested in:
    Python 3.9, NetworkX 2.5
    Runs TestAll.py to run all unit test.

Acknowledgements:
    Prof. Davis J. Freund:
        for teaching us to to write better code.
    J. Freund:
        for helpful feedbacks and suggesting pep8

'''

# ======================= Practicing Programming Project ======================
#                                      DPG
# =============================================================================

import networkx as nx
import DPG

if __name__ == "__main__":
    # Create regular graphs for different degrees using DPG
    # All nodes in reugular graph have same degree
    # degree of a node is number of neighbour it has
    DPG.regularDPG(10, 2).show()
    # TODO: figure out why sometimes deg 2 is coming
    DPG.regularDPG(10, 3).show()
    DPG.regularDPG(10, 4).show()

    # create random graphical degree sequence
    # and then generate graph with same degree sequence using DPG
    degrees = [x[1] for x in nx.erdos_renyi_graph(10, 0.25).degree]
    DPG.iconfigDPG(degrees).show()

    # create random graphical degree sequence
    # and then generate graph with same degree sequence using DPG
    degrees = [x[1] for x in nx.erdos_renyi_graph(10, 0.75).degree]
    DPG.iconfigDPG(degrees).show()

    # generate linDPG Graph with different parameter
    # first parameter is number of nodes
    # second parameter is related with density and splittance of final graph
    DPG.linDPG(40, 0.25).show()
    DPG.linDPG(40, 0.5).show()
    DPG.linDPG(40, 0.75).show()
    DPG.linDPG(40, 1).show()  # equivalent to maxDPG
