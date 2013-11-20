//g++ darkness_constraints.cpp FreqTable.cpp EdgeConstraint.cpp -o dark
#include <iostream>
#include <fstream>
#include "FreqTable.h"
#include "EdgeConstraint.h"

using namespace std;
int main()
{   
    double min = 0;

    //ofstream log_file;
    //log_file.open("log.txt",ios::app|ios::out);
    //log_file << "Testing 23x11 layout for collisions" << endl;
    //log_file << "Grad\tPattern\tRandomAvg" << endl;
    vector<int> collision_vals;

    int N_collisions = 0;
    vector <double> grads;

    int rows_per_tile = 40;
    int cols_per_tile = 25;
    double desired_neighbor_separation = 70;
    FreqTable tile_top(time(NULL));
    FreqTable tile_bottom(time(NULL)+100);
    double bandwidth = 1800;//MHz

    //The center area, the 'sweet spot' will not have frequencies too close to the extremes (f<50 or f>bandwidth-50)
    double f_lb = 50;//center region's frequency lower bound
    double f_ub = bandwidth-f_lb;//center region's frequency upper bound 
    //also the sweet spot should not have frequencies too close to the LO frequency in the center of the bandwisth
    double if_sweet_hole_width = 50.0;
    double if_lb = bandwidth/2.0-if_sweet_hole_width/2.0;
    double if_ub = bandwidth/2.0+if_sweet_hole_width/2.0;
    double start_f_top = 0.0;
    double start_f_bottom = 2200.0;
    bool b_if_hole = true;

    //set basic requirements for the tiles
    tile_top.set_requirements(rows_per_tile,cols_per_tile,bandwidth,desired_neighbor_separation,start_f_top,b_if_hole);
    tile_bottom.set_requirements(rows_per_tile,cols_per_tile,bandwidth,desired_neighbor_separation,start_f_bottom,b_if_hole);


    int sweet_spot_first_row_top = 25;
    int sweet_spot_last_row_top = 39;
    int sweet_spot_first_row_bottom = 0;
    int sweet_spot_last_row_bottom = 14;
    int sweet_spot_first_col = 0;
    int sweet_spot_last_col = 24;

    //set constraint for sweet spot to only include frequencies far from extremes
    tile_top.add_rect_constraint(sweet_spot_first_row_top,sweet_spot_last_row_top,sweet_spot_first_col,sweet_spot_last_col,start_f_top+f_lb,start_f_top+f_ub,true);

    tile_bottom.add_rect_constraint(sweet_spot_first_row_bottom,sweet_spot_last_row_bottom,sweet_spot_first_col,sweet_spot_last_col,start_f_bottom+f_lb,start_f_bottom+f_ub,true);

    //set constraint for sweet spot to exclude frequencies in the wider if hole
    tile_top.add_rect_constraint(sweet_spot_first_row_top,sweet_spot_last_row_top,sweet_spot_first_col,sweet_spot_last_col,start_f_top+if_lb,start_f_top+if_ub,false);
    tile_bottom.add_rect_constraint(sweet_spot_first_row_bottom,sweet_spot_last_row_bottom,sweet_spot_first_col,sweet_spot_last_col,start_f_bottom+if_lb,start_f_bottom+if_ub,false);
    tile_top.add_edge_constraint(&tile_top,EdgeConstraint::MIDDLE_LEFT);
    tile_bottom.add_edge_constraint(&tile_bottom,EdgeConstraint::MIDDLE_RIGHT);


    //solve with constraints
    cout << "Looking for solution" << endl;
    fflush(stdout);
    tile_top.find_layout_solution(true);
    cout << "found solution for top panel" << endl;
    fflush(stdout);
    tile_bottom.find_layout_solution(false);
    cout << "found solution for bottom panel" << endl;
    fflush(stdout);


    ofstream top_file;
    top_file.open("top.txt");
    tile_top.pretty_print_clean_table(top_file);
    top_file.close();

    ofstream bottom_file;
    bottom_file.open("bottom.txt");
    tile_bottom.pretty_print_clean_table(bottom_file);
    bottom_file.close();



}


