#pragma once

#include "DPGGraph.h"

#include <chrono>   // function call time measurement
#include <numeric>  // accummulate

void BatchDPR(string file_name, int repeat = 1, int file_index = -1) {
  DPGGraph g_original;
  g_original.load(file_name);

  vector<int> time_list, DPR_sizes;
  cout << "Reducing graph " << file_name << endl;
  cout << "N_initial = " << g_original.node_count << endl;
  cout << "N_final = ";
  while (repeat-- != 0) {
    DPGGraph g_reduced;
    graphCopy(g_original, g_reduced).run();

    // measure time to reduce graph
    {
      auto t1 = chrono::high_resolution_clock::now();
      g_reduced.DPR();
      auto t2 = chrono::high_resolution_clock::now();
      std::chrono::duration<double, std::milli> duration_ms = t2 - t1;
      time_list.push_back(duration_ms.count());
    }

    // save files
    { 
      string save_file_name = file_name + "_DPR_" + to_string(repeat);
      if (file_index != -1) save_file_name += "_" + to_string(file_index);
      g_reduced.save(save_file_name);
      // SaveToEPS(gg, to_string(repeat));
    }

    DPR_sizes.push_back(g_reduced.node_count);
    cout << g_reduced.node_count << " ";
  }

  // save reduced sizes to file
  {
    ofstream file("./graphs/" + file_name +
                  "_N0=" + to_string(g_original.node_count) + "_DPR.txt");
    for (auto val : DPR_sizes) file << val << endl;
  }

  // print average value
  {
    cout << endl;
    cout << "average time = "
         << accumulate(time_list.begin(), time_list.end(), 0) / time_list.size()
         << " ms" << endl;
  }
}
