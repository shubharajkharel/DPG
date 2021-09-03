#pragma once

#include <lemon/adaptors.h>    //FilterNodes
#include <lemon/edge_set.h>    //ListEdgeSet
#include <lemon/lgf_reader.h>  //graphReader
#include <lemon/lgf_writer.h>  //graphWriter
#include <lemon/list_graph.h>
#include <lemon/matching.h>

#include <algorithm>  //shuffle
#include <fstream>    //ifstream
#include <iterator>
#include <random>  //random_device, unifrom_int_distribution

#include <map>
#include <sstream>  //stringstream
#include "IO.h"

using namespace lemon;
using namespace std;

typedef ListGraph::Node Node;
typedef ListGraph::Edge Edge;
typedef vector<tuple<Node, Node>> EdgeList;

class DPGGraph : public ListGraph {
 public:
  DPGGraph() {
    stub = INVALID;
    node_count = 0;
  }

  Node stub;
  int node_count;
  std::mt19937 rnd_generator{std::random_device{}()};

  // helper functions
  inline int deg(const Node& n) { return countIncEdges(*this, n); }

  // overrided functions
  Edge addEdge(Node u, Node v);
  void erase(Node n);
  Node addNode();

  // DPR functions
  void DPR(int max_step = -1);
  bool DPRStep();
  bool findRndDPRNode(Node& n, EdgeList& new_edges, Node& new_stub);
  bool isDPRFeasible(const Node& n, EdgeList& new_edges, Node& new_stub);
  bool isDPRFeasibleEven(const Node& n, EdgeList& new_edges, Node& new_stub);
  bool isDPRFeasibleOdd(const Node& n, EdgeList& new_edges, Node& new_stub);

  // matching functions
  void compNeighMatching(const Node& n, EdgeList& matched_edges,
                         const Node& n_umatched = INVALID, int size = -1);
  static vector<Edge> findRndMatching(const ListGraph& g,
                                      std::mt19937& rnd_generator,
                                      int size = -1);
  static vector<Edge> rndGreedyMatching(const ListGraph& g,
                                        std::mt19937& rnd_generator,
                                        int size = -1);
  // rnd functions
  int rndInt(int a, int b);
  ListGraph::NodeIt rndNode();

  // io functions
  void save(string file_name, string dir = "./graphs/");
  void load(string file_name, string dir = "./graphs/");

};
