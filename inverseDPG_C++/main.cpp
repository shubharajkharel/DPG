#pragma comment(lib, "C:/Program Files (x86)/LEMON/lib/lemon.lib")

#include <lemon/list_graph.h>

#include <lemon/dimacs.h>
#include "DPGGraph.h"
#include "IO.h"
#include "batch.h"
#include "helper.h"

#include <lemon/core.h>      //GraphCopy
#include <lemon/matching.h>  //MaxMatching

#include <fstream>
#include <iostream>
#include <iterator>
#include <string>

using namespace lemon;
using namespace std;

int main(int arg_count, char *arg_vector[]) {
  if (arg_count > 1) {
    auto file_name = arg_vector[1];
    int repeat = stoi(arg_vector[2]);
    if (arg_count == 3) {
      BatchDPR(file_name, repeat);
    } else if (arg_count == 4) {
      int file_index = stoi(arg_vector[3]);
      BatchDPR(file_name, repeat, file_index);
    }
  }

  getchar();
  return 0;
}