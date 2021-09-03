#include "DPGGraph.h"

// TODO optimize this
vector<Edge> DPGGraph::rndGreedyMatching(const ListGraph& g,
                                         std::mt19937& rnd_generator,
                                         int size) {
  // make vector with shuffled edges
  vector<Edge> edges, matched_edges;
  map<Edge, bool> matched_tag;
  {
    for (auto e = EdgeIt(g); e != INVALID; ++e) {
      edges.push_back(e);
      // TODO following line is using 5% of CPU runtime
      matched_tag.insert({e, true});

    }
    std::shuffle(edges.begin(), edges.end(), rnd_generator);
  }

  // find matching greedily by tagging adj edges
  for (auto e : edges) {
    // for each tagged edge
    if (matched_tag[e] == true) {
      matched_edges.push_back(e);
      if (matched_edges.size() == size) return matched_edges;
      // remove adjacent edges from matching tag
      {
        for (auto adj_e = ListGraph::IncEdgeIt(g, g.u(e)); adj_e != INVALID;
             ++adj_e) {
          matched_tag[adj_e] = false;
        }
        for (auto adj_e = ListGraph::IncEdgeIt(g, g.v(e)); adj_e != INVALID;
             ++adj_e) {
          matched_tag[adj_e] = false;
        }
      }
      // add edge itself to matching
      matched_tag[e] = true;
    }
  }
  return matched_edges;
}

vector<Edge> DPGGraph::findRndMatching(const ListGraph& g,
                                       std::mt19937& rnd_generator, int size) {
  // find matching in greedy way
  vector<Edge> matched_edges = rndGreedyMatching(g, rnd_generator, size);

  // return if enough matching edges found
  if (matched_edges.size() == size) return matched_edges;

  // greedy algorithm must get at least one matching
  // if not then graph must have no edge or node as well
  // creating MaxMatching with graph without node will cause error
  // following line avoids initializing both cases avoiding error
  if (matched_edges.size() == 0) return matched_edges;

  // else use edmond's algorithm to extend matching
  MaxMatching<ListGraph> match(g);
  EdgeMap<bool> matching_init(g, false);
  for (auto e : matched_edges) {
    matching_init[e] = true;
  }
  if (!match.matchingInit(matching_init)) {
    cout << "invalid matching init." << endl;
  }
  match.startSparse();  // Blossom's algorithm

  // return format
  matched_edges.clear();
  for (auto e = EdgeIt(g); e != INVALID; ++e) {
    if (match.matching(e)) {
      matched_edges.push_back(e);
      if (matched_edges.size() == size) return matched_edges;
    }
  }
  return matched_edges;
}

void DPGGraph::compNeighMatching(const Node& n, EdgeList& matched_edges,
                                 const Node& n_umatched, int size) {
  // creating new graph with node references
  ListGraph comp_neigh_g;
  //int d = deg(n);
  //comp_neigh_g.reserveNode(d);
  //comp_neigh_g.reserveEdge(d*(d-1)/2);

  map<Node, Node> node_ref;
  map<Node, Node> node_cross_ref;
  for (auto e = IncEdgeIt(*this, n); e != INVALID; ++e) {
    auto adj_n = oppositeNode(n, e);
    if (adj_n != n_umatched) {
      Node new_node = comp_neigh_g.addNode();
      node_ref.insert({adj_n, new_node});
      node_cross_ref.insert({new_node, adj_n});
    }
  }

  // adding edge in between nodes of nodes of new graph that are not connected
  // in original graph
  for (auto n1 = node_ref.begin(); n1 != node_ref.end(); ++n1) {
    auto n2 = n1;
    for (++n2; n2 != node_ref.end(); ++n2) {
      Edge e = findEdge(*this, n1->first, n2->first);
      if (e == INVALID) {
        comp_neigh_g.addEdge(n1->second, n2->second);
      }
    }
  }

  // finding matching in complement neigh graph and returning output nodes in
  // terms of nodes of original graph
  matched_edges.clear();
  for (auto e : findRndMatching(comp_neigh_g, rnd_generator, size)) {
    matched_edges.push_back(make_tuple(node_cross_ref[comp_neigh_g.u(e)],
                                       node_cross_ref[comp_neigh_g.v(e)]));
  }
}

