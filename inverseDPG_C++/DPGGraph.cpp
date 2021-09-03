#include "DPGGraph.h"

void DPGGraph::erase(Node n) {
  node_count--;
  ListGraph::erase(n);
}

Node DPGGraph::addNode() {
  node_count++;
  return ListGraph::addNode();
}

Edge DPGGraph::addEdge(Node u, Node v) {
  if (!ListGraph::valid(u) || !ListGraph::valid(v)) {
    cout << "addEdge: Nodes do not exists!" << endl;
  }
  if (findEdge(*this, u, v) == INVALID) {
    if (u == v) {
      cout << "Loops not permitted." << endl;
      return INVALID;
    } else {
      return ListGraph::addEdge(u, v);  // base function
    }
  } else {
    cout << "Edge already exists." << endl;
    return INVALID;
  }
};

void DPGGraph::save(string file_name, string dir) {
  graphWriter(*this, dir + file_name + ".lgf").run();
}

void DPGGraph::load(string file_name, string dir) {
  ListGraph::clear();
  graphReader(*this, dir + file_name + ".lgf").run();
  node_count = countNodes(*this);
}


ListGraph::NodeIt DPGGraph::rndNode() {
  // returns INVALID if graph is empty
  ListGraph::NodeIt rnd_n(*this);
  {
    int rnd_int = (node_count <= 1) ? 0 : rndInt(0, node_count - 1);
    while (rnd_int > 0) {
      --rnd_int;
      ++rnd_n;
    }
  }
  return rnd_n;
}

int DPGGraph::rndInt(int a, int b) {
  uniform_int_distribution<> unifrom_dist(a, b);
  return unifrom_dist(rnd_generator);
}
