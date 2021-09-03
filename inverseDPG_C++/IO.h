#pragma once

#include <lemon/graph_to_eps.h>
#include <lemon/list_graph.h>
#include <lemon/maps.h>  // IdMap

#include <string>

using namespace lemon;
using namespace std;

void CircularEmbedding(const ListGraph &g, ListGraph::NodeMap<dim2::Point<double>> &c,
                       double r=1);

void SaveToEPS(const ListGraph &g, string file_name) ; 