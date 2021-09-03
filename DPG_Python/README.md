# Project 1-3: DPG

### Objectives:

- Port the code for network growth model called DPG.
- Code will be ported from C++ and Mathematica
- Special focus will be given on writing clean, scalable and well-documented code.

#### Description:

Projects implements a network growth model called DPG. DPG grows a network by adding one node at and time and does so without changing the degrees of the existing nodes. Degree of a node is number of neighbor of a node. 

Use class ```GraphDPG``` to create DPG graphs:

```python
G = GraphDPG()    # Empty DPG graph
G + 1 + 1         # adds 2 nodes with degress 1
```

    G.DPG([1,1])
    G + [1,1]
    G + (1,1)

Use ```show()``` function to see the network plot.

There are <u>3 models of DPG</u> currently defined:

1. regular DPG: Creates graphs with where all nodes have same degree 

   ```python
    DPG.regularDPG(10,2)    # creates 2-regular graph with 10 nodes 
   ```

2. iconfigDPG: Creates graphs whose degree sequence is given. example:
   
    ```python
    DPG.iconfigDPG([2,2,2])   #creates a triangle
    ```
    
3. linDPG: Creates linear DPG graphs with parameter c.

    ```python
    DPG.linDPG(20,0.5)   # linear DPG graphs with 10 nodes and c=0.5
    DPG.linDPG(20,1)   # linear DPG graphs with 10 nodes and c=1 (maxDPG)
    ```

#### Tested in:

​    Python 3.9, NetworkX 2.5
​    Run TestAll.py to run all unit tests.

#### Acknowledgements:

- Prof. Davis J. Freund for teaching us to to write better code.