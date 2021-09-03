#include "IO.h"

void CircularEmbedding(const ListGraph &g, ListGraph::NodeMap<dim2::Point<double>> &c,
                       double r) {
  int count = 0;
  double del_theta = 2 * 3.14159 / countNodes(g);
  for (auto n = ListGraph::NodeIt(g); n != INVALID; ++n, count++) {
    double x = r * cos(count * del_theta);
    double y = r * sin(count * del_theta);
    c[n] = dim2::Point<double>(x, y);
  }
}

void SaveToEPS(const ListGraph &g, string file_name) {
  // 2d points in circular embeddings
  typedef dim2::Point<double> Point2D;
  typedef ListGraph::NodeMap<Point2D> coords2D;
  coords2D n_coords(g);
  CircularEmbedding(g, n_coords);

  // id of nodes
  IdMap<ListGraph, ListGraph::Node> id(g);

  // filename
  string extension(".eps");
  for (auto const &s : extension) file_name += s;

  // saving
  graphToEps(g, file_name)
      //.title("Sample .eps figure (fits to A4)")
      .scaleToA4()
      //.absoluteNodeSizes()
      //.absoluteArcWidths()
      //.nodeScale(0.5)
      //.nodeSizes(sizes)
      .coords(n_coords)
      //.nodeShapes(shapes)
      //.nodeColors(composeMap(palette, colors))
      //.arcColors(composeMap(palette, acolors))
      //.arcWidthScale(.3)
      //.arcWidths(widths)
      .nodeTexts(id)
      .nodeTextSize(.05)
      //.enableParallel()
      //.parArcDist(1)
      //.drawArrows()
      //.arrowWidth(1)
      //.arrowLength(1)
      .run();
}
