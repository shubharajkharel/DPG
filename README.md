

# Degree Preserving Network Growth (DPG)

### What is DPG?

Following abstract from Nature Physics article (accepted  2021), that I am first author of, best summarizes the model.

> Real-world networks evolve over time via the addition or removal of nodes and edges. In current network evolution models, node degree varies or grows arbitrarily, yet there are many networks in which it saturates, such as the number of active contacts of a person, or it is fixed, such as the valence of an atom in a molecule, thus requiring an entirely different description. DPG is a novel family of network growth processes that preserve node degree, resulting in structures significantly different from previous ones. Despite it being an NP-hard problem in general, the exact structure of most real-world networks can be generated from degree-preserving growth. We show that this process can create scale-free networks with arbitrary exponents, however, without preferential attachment. We present applications to epidemics control via network immunization, viral marketing, knowledge dissemination and the design of molecular isomers with desired properties.

### What do these codes do?

Part of these codes were used to generate data for the research. Codes are organized into 3 folders:

- **DPG_Mathematica** folder contains packages related to DPG and is organized as follows. It was created using Mathematica 12.0.
  
  - **Examples.nb** is a Mathematica notebook file that demonstrates how to use all the packages in the directory. A pdf version of this file is included for viewing the content of this notebook without Mathematica.
  - **DPG.m** is a package that can be used to grow networks using the DPG process. The model is general enough to allow the insertion of odd degree nodes.
  - **DPGModels**.m includes implements several (but not all) models of DPG. 
  - **invDPG.m** package can be used to reduce the networks through the inverse-DPG process. The implemented method allows the reduction of graphs with odd degree nodes as well. 
  - **DPGAssortativty.m** package provides a function that can be used to grow networks through DPG while optimizing for degree assortativity. 
  - **DPR.m** package includes a function to rewire networks while preserving degree and optimizing for a given graph metric. 
  - **Blossom.m** algorithm contains an implementation of Edmonds [Blossom  alorithm](https://en.wikipedia.org/wiki/Blossom_algorithm) to find matching in a graph. This code can be optimized further.
  - **WeighedMatching.m** can be used to approximate weighted matching for small matching size in an ad-hoc way.
  - **Splittance.m** package contains the function to find splittance of graphs, as defined in the Nature Physics article.
  
- **DPG_python** folder contains Python code that includes a graphDPG class inherited from *Graph* class in [NetworkX](https://networkx.org/documentation/stable/reference/classes/graph.html#) and includes methods to add nodes using DPG. Some models of DPG are also implemented. Run *main.py* to see examples for calling the functions. 

- **InverseDPG_C++** folder contains high performance implementation of inverse-DPG (degree preserving reduction) function using C++. It can be used for fast reduction of large networks. Code uses [LEMON](https://lemon.cs.elte.hu/trac/lemon) graph library. Parameters used for compilation was ``` g++ -std=c++11 -Wall -J 4 -O3 -I ./lemon/include *.cpp -L./lemon/lib/ -lemon -o DPG``` .

  

---

### Author

Shubha Raj Kharel ([LinkedIN](https://www.linkedin.com/in/srkharel/))

