//g++ random_frequencies.cpp; ./a.out|python&
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


	int num_subarr_rows = 2;
	int num_subarr_cols = 1;
	int num_rows_per_subarr = 23;
	int num_cols_per_subarr = 11;
	double desired_neighbor_separation = 70;
	FreqTable ft_top;
	FreqTable ft_bottom;
	double f_lb = 50;//center region's frequency lower bound
	double f_ub = 1100;//center region's frequency upper bound 
	double if_lb = 525;
	double if_ub = 625;
	double top_start_f = 600;

	ft_bottom.set_requirements(num_rows_per_subarr,num_cols_per_subarr,desired_neighbor_separation,0,false);
	ft_top.set_requirements(num_rows_per_subarr,num_cols_per_subarr,desired_neighbor_separation,top_start_f,false);

	ft_top.add_rect_constraint(13,22,0,10,f_lb,f_ub,true);
	ft_top.add_rect_constraint(13,22,0,10,if_lb,if_ub,false);
	//ft_bottom.add_rect_constraint(0,9,0,10,f_lb,f_ub,true);
	//ft_bottom.add_rect_constraint(0,9,0,10,if_lb,if_ub,false);

	ft_top.add_edge_constraint(&ft_bottom,EdgeConstraint::BELOW_CENTER);
	ft_bottom.add_edge_constraint(&ft_top,EdgeConstraint::ABOVE_CENTER);


	ft_bottom.find_layout_solution(false);
	cerr << "found solution for bottom panel" << endl;
	ft_top.find_layout_solution(true);
	cerr << "found solution for top panel" << endl;

	ft_bottom.print_freq_list();
	ft_top.print_freq_list();

	cerr << "1GHz Top tile: " << endl;
	ft_top.pretty_print_clean_table();
	cerr << "1GHz Bottom tile: " << endl;
	ft_bottom.pretty_print_clean_table();

	cerr << endl << endl;
	cout << "show()" << endl;


}


