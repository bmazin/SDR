//g++ random_frequencies.cpp; ./a.out|python&
//g++ sci5_512MHz.cpp FreqTable.cpp EdgeConstraint.cpp; ./a.out|python&
#include <iostream>
#include "FreqTable.h"
#include "EdgeConstraint.h"

using namespace std;
int main()
{	
	cout << "#!/usr/bin/env python" << endl;
	cout << "from numpy import *" << endl;
	cout << "from pylab import *" << endl;
	double min = 0;

	//ofstream log_file;
	//log_file.open("log.txt",ios::app|ios::out);
	//log_file << "Testing 23x11 layout for collisions" << endl;
	//log_file << "Grad\tPattern\tRandomAvg" << endl;
	vector<int> collision_vals;

	int N_collisions = 0;
	vector <double> grads;

	int rows_per_tile = 46;
	int cols_per_tile = 6;
	double desired_neighbor_separation = 70;
	FreqTable tile_left;
	FreqTable tile_right;
    double bandwidth = 512;

    //The center area, the 'sweet spot' will not have frequencies too close to the extremes (f<50 or f>
	double f_lb = 50;//center region's frequency lower bound
	double f_ub = bandwidth-f_lb;//center region's frequency upper bound 
    double if_sweet_hole_width = 50.0;
	double if_lb = bandwidth/2.0-if_sweet_hole_width/2.0;
	double if_ub = bandwidth/2.0+if_sweet_hole_width/2.0;
	double start_f = 0.0;

    //set basic requirements for the tiles
	tile_left.set_requirements(rows_per_tile,cols_per_tile,bandwidth,desired_neighbor_separation,start_f,true);
	tile_right.set_requirements(rows_per_tile,cols_per_tile,bandwidth,desired_neighbor_separation,start_f,true);

	tile_left.print_freq_list();
	tile_right.print_freq_list();

    int tile_left_ragged_col = 5;
    int tile_right_ragged_col = 0;
    int tile_left_ragged_first_row = 23;
    int tile_left_ragged_last_row = 45;
    int tile_right_ragged_first_row = 0;
    int tile_right_ragged_last_row = 22;

    //constrain left and right tile in unused portion of ragged edge
    tile_left.add_rect_constraint(tile_left_ragged_first_row,tile_left_ragged_last_row,tile_left_ragged_col,tile_left_ragged_col,530,30000,true);
    tile_right.add_rect_constraint(tile_right_ragged_first_row,tile_right_ragged_last_row,tile_right_ragged_col,tile_right_ragged_col,530,30000,true);

    int sweet_spot_first_row = 13;
    int sweet_spot_last_row = 32;
    int sweet_spot_first_col_left = 0;
    int sweet_spot_last_col_left = 4;
    int sweet_spot_first_col_right = 1;
    int sweet_spot_last_col_right = 5;

    //set constraint for sweet spot to only include frequencies far from extremes
	tile_left.add_rect_constraint(sweet_spot_first_row,sweet_spot_last_row,sweet_spot_first_col_left,sweet_spot_last_col_left,start_f+f_lb,start_f+f_ub,true);
	tile_left.add_rect_constraint(sweet_spot_first_row,22,5,5,start_f+f_lb,start_f+f_ub,true);
	tile_right.add_rect_constraint(sweet_spot_first_row,sweet_spot_last_row,sweet_spot_first_col_right,sweet_spot_last_col_right,start_f+f_lb,start_f+f_ub,true);
	tile_right.add_rect_constraint(23,sweet_spot_last_row,0,0,start_f+f_lb,start_f+f_ub,true);

    //set constraint for sweet spot to exclude frequencies in the wider if hole
	tile_left.add_rect_constraint(sweet_spot_first_row,sweet_spot_last_row,sweet_spot_first_col_left,sweet_spot_last_col_left,if_lb,if_ub,false);
	tile_right.add_rect_constraint(sweet_spot_first_row,sweet_spot_last_row,sweet_spot_first_col_right,sweet_spot_last_col_right,if_lb,if_ub,false);



    //solve with constraints
    cerr << "Looking for solution" << endl;
    fflush(stderr);
	tile_left.find_layout_solution(true);
	cerr << "found solution for left panel" << endl;
    fflush(stderr);
	tile_right.find_layout_solution(false);
	cerr << "found solution for right panel" << endl;
    fflush(stderr);


	cerr << "512MHz Left tile: " << endl;
	tile_left.pretty_print_clean_table();
	cerr << "512MHz Right tile: " << endl;
	tile_right.pretty_print_clean_table();

	cerr << endl << endl;
    tile_left.graph_neighbor_separations();
	tile_left.graph_global_separations();

    tile_right.graph_neighbor_separations();
    tile_right.graph_global_separations();



	cout << "show()" << endl;


}


