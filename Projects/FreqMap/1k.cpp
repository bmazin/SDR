//g++ random_frequencies.cpp; ./a.out|python&
#include <iostream>
#include <iomanip>
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

	int num_rows_per_subarr = 23;
	int num_cols_per_subarr = 11;
	double desired_neighbor_separation = 70;
	double bandwidth_per_subarr = 1100;//MHz
	FreqTable ft_top;
	FreqTable ft_bottom;
	double f_lb = 50;//center region's frequency lower bound
	double f_ub = 500;//center region's frequency upper bound 
	double if_lb = 250;
	double if_ub = 300;
	double top_start_f = 600;

	ft_bottom.set_requirements(num_rows_per_subarr,num_cols_per_subarr,bandwidth_per_subarr,desired_neighbor_separation,0,false);
	//ft_top.set_requirements(num_rows_per_subarr,num_cols_per_subarr,desired_neighbor_separation,top_start_f,false);

	//ft_top.add_rect_constraint(13,22,0,10,f_lb,f_ub,true);
	//ft_top.add_rect_constraint(13,22,0,10,if_lb,if_ub,false);
	//ft_bottom.add_rect_constraint(0,9,0,10,f_lb,f_ub,true);
	//ft_bottom.add_rect_constraint(0,9,0,10,if_lb,if_ub,false);

	//ft_top.add_edge_constraint(&ft_bottom,EdgeConstraint::BELOW_CENTER);
	//ft_bottom.add_edge_constraint(&ft_top,EdgeConstraint::ABOVE_CENTER);


	ft_bottom.find_layout_solution(false);
	cerr << "found solution for bottom panel" << endl;
	//ft_top.find_layout_solution(true);
	//cerr << "found solution for top panel" << endl;

	//ft_bottom.print_freq_list();
	//ft_top.print_freq_list();

	//cerr << "1GHz Top tile: " << endl;
	//ft_top.pretty_print_clean_table();
	//cerr << "1GHz Bottom tile: " << endl;
	//ft_bottom.pretty_print_clean_table();

	//cerr << endl << endl;

	cout << "badTable=";
	cout << "mat(\"";
	
	int bad_pixels = 0;
	double frac_bad = 0;
	for (double mag = 0.0; mag < .35; mag+=0.01)
	{
		if (mag != 0.0)
			cout << ";";
		for (double ang = 0; ang < 90.0; ang+=1.0)
		{
			ft_bottom.clean_freq_table();
			ft_bottom.add_gradient(mag,ang);
			ft_bottom.add_scatter(0.5);
			//ft_bottom.graph_global_separations();
			bad_pixels = ft_bottom.get_num_bad_pixels();
			frac_bad = 1.0*bad_pixels / (1.0*num_rows_per_subarr *num_cols_per_subarr );
			cout << setw(4) << frac_bad << " ";
			//cerr << setw(4) << frac_bad << " ";
		}
		//cerr << endl;
	}
	cout << "\")" << endl;
	//cout << "print \"badTable\",badTable" << endl;
	cout << "matshow(badTable)" << endl;
	cout << "colorbar()" << endl;
	cout << "show()" << endl;


}


