#include "DPGGraph.h"

void DPGGraph::DPR(int max_step) {
  int steps = 0;
  while (steps++ != max_step) {
    if (!DPRStep()) break;
    // SaveToEPS(*this, to_string(steps));  // TODO remove this
  }
}

bool DPGGraph::DPRStep() {
  Node n, new_stub;
  EdgeList new_edges;
  if (findRndDPRNode(n, new_edges, new_stub)) {
    for (auto e : new_edges) {
      addEdge(get<0>(e), get<1>(e));
    }
    erase(n);
    stub = new_stub;
    /*cout << id(n) << " " << id(new_stub) << endl;*/ // TODO remove this
    return true;
  } else {
    return false;
  }
}

bool DPGGraph::findRndDPRNode(Node& n, EdgeList& new_edges, Node& new_stub) {
  {  // picks random starting location for node iterator to check DPR
    if (node_count < 1) return false;
    ListGraph::NodeIt rnd_n = rndNode();
    ListGraph::NodeIt test_n = rnd_n;
    while (!isDPRFeasible(test_n, new_edges, new_stub)) {
      ++test_n;
      if (test_n == INVALID)
        test_n = NodeIt(*this);           // start from beginin if reached end
      if (test_n == rnd_n) return false;  // allnodes tested condition
    }
    n = test_n;
    return true;
  }

  //{  // alternative slower implementation that chooses node unifromly randomly
  //  vector<Node> shuffled_nodes;  // costly for large graphs
  //  {
  //    for (auto n = NodeIt(*this); n != INVALID; ++n) {
  //      shuffled_nodes.push_back(n);
  //    }
  //    shuffle(shuffled_nodes.begin(), shuffled_nodes.end(), rnd_generator);
  //  }

  //  for (auto s_n : shuffled_nodes) {
  //    if (isDPRFeasible(s_n, new_edges, new_stub)) {
  //      n = s_n;
  //      return true;
  //    }
  //  }
  //  return false;
  //}
}

bool DPGGraph::isDPRFeasible(const Node& n, EdgeList& new_edges,
                             Node& new_stub) {
  if (deg(n) % 2) {
    return isDPRFeasibleOdd(n, new_edges, new_stub);
  } else {
    return isDPRFeasibleEven(n, new_edges, new_stub);
  }
}

bool DPGGraph::isDPRFeasibleEven(const Node& n, EdgeList& new_edges,
                                 Node& new_stub) {
  compNeighMatching(n, new_edges);
  if (2 * new_edges.size() == deg(n)) {
    new_stub = n == stub ? INVALID : stub;
    return true;
  } else {
    return false;
  }
}

bool DPGGraph::isDPRFeasibleOdd(const Node& n, EdgeList& new_edges,
                                Node& new_stub) {
  vector<Node> adj_nodes;
  {
    // shuffle adj_nodes that is left to be unmatched so that complement
    // neighbourhood near perfect matching is varies in different runs
    for (auto e = IncEdgeIt(*this, n); e != INVALID; ++e) {
      auto adj_n = oppositeNode(n, e);
      if (adj_n == stub) return false;
      adj_nodes.push_back(adj_n);
    }
    std::shuffle(adj_nodes.begin(), adj_nodes.end(), rnd_generator);
  }

  for (auto adj_n : adj_nodes) {
    
    if ((stub != INVALID) && (stub != n) &&
        (findEdge(*this, stub, adj_n) != INVALID))
      continue;  // avoids multi edge

    compNeighMatching(n, new_edges, adj_n);
    if (2 * new_edges.size() == deg(n) - 1) {
      if (stub == INVALID) {
        new_stub = adj_n;  // stub creation during DPG
      } else {
        if (stub == n) {
          new_stub =
              adj_n;  // stub transfer from odd to even dgree node during DPG
        } else {
          new_edges.push_back(make_pair(stub, adj_n));
          new_stub = INVALID;  // stub removal on adding odd degree node to
                               // graph with stub
        }
      }
      return true;
    }
  }
  return false;
}
