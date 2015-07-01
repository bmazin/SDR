#include <set>
#include <vector>
#include "FreqTable.h"
#include "RectConstraint.h"
#include "EdgeConstraint.h"
#include <tr1/random>
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <cmath>
#include <ctime>
#include <iomanip>
#include <cstdio>
using namespace std;

FreqTable::FreqTable(unsigned int seed)
	:required_min_neighbor_separation(60),required_max_neighbor_separation(NULL),collision_threshold(0.5),scatter_stddev(0.5),gradient_magnitude(0),gradient_angle(0),num_bad_pixels(0),min_neighbor_separation(0),MAX_FREQ(512),NROWS(46),NCOLS(6),num_attempts_to_solve(0),solution_found(false),has_if_hole(false)
{
	clean_table = NULL;
	real_table = NULL;

	random_engine.seed(seed);
}

FreqTable::~FreqTable()
{
//	for (int r = 0; r < NROWS; ++r)
//	{
//		delete[] clean_table[r];
//		delete[] real_table[r];
//	}
//	delete[] clean_table;
//	delete[] real_table;

}

void FreqTable::set_requirements(int num_rows,int num_cols,double bandwidth,double min_n_sep,double start_f,bool if_hole) 
{
	NROWS = num_rows;
	NCOLS = num_cols;
	clean_table = new double*[NROWS];
	real_table = new double*[NROWS];

	for (int r = 0; r < NROWS; ++r)
	{
		clean_table[r] = new double[NCOLS];
		real_table[r] = new double[NCOLS];
	}
	MAX_FREQ = start_f+bandwidth;
	required_min_neighbor_separation = min_n_sep;
	start_freq = start_f;
	has_if_hole = if_hole;
	build_freq_list();
}


void FreqTable::set_basic_requirements(int num_rows,int num_cols) 
{
	NROWS = num_rows;
	NCOLS = num_cols;
	clean_table = new double*[NROWS];
	real_table = new double*[NROWS];

	for (int r = 0; r < NROWS; ++r)
	{
		clean_table[r] = new double[NCOLS];
		real_table[r] = new double[NCOLS];
	}
}

void FreqTable::set_freq_requirements(double bandwidth,double start_f,bool if_hole) 
{
	MAX_FREQ = start_f+bandwidth;
	start_freq = start_f;
	has_if_hole = if_hole;
	build_freq_list();
}

void FreqTable::add_neighbor_constraint(double neighbor_separation,bool separation_is_a_minimum) 
{
    if (separation_is_a_minimum)
        required_min_neighbor_separation = neighbor_separation;
    else
        required_max_neighbor_separation = neighbor_separation;
}

void FreqTable::remove_constraints()
{
	edge_constraints.clear();
	rect_constraints.clear();
}

bool FreqTable::check_min_neighbor_separation(int r, int c, double center_value,bool check_row_below)
{
	double min_dist = 100000;
	int r_neighbors[] = {-1,-1,-1,0};
	int c_neighbors[] = {-1,0,1,-1};

	if (check_row_below == true)
	{
		r_neighbors[0] = 1;
		c_neighbors[0] = 0;
		r_neighbors[1] = 1;
		c_neighbors[1] = 1;
		r_neighbors[2] = 0;
		c_neighbors[2] = 1;
		r_neighbors[3] = 1;
		c_neighbors[3] = -1;
	}
	int dr = 0;
	int dc = 0;
	double dist = 0;
	int N_neighbors = 4;
    
	for (int i = 0; i < N_neighbors; ++i)
	{
		dr = r_neighbors[i];
		dc = c_neighbors[i];
		if (r+dr >= 0 && r+dr < NROWS && c+dc >=0 && c+dc < NCOLS)
		{
			dist = abs(real_table[r+dr][c+dc]-center_value);
            //if (r == 16 || r == 17)
                //cout << r+dr << " " << c+dc << " " << real_table[r+dr][c+dc] << " " << dist << endl;
			if (dist < min_dist)
				min_dist = dist;
		}
	}
	return min_dist > required_min_neighbor_separation;
}

bool FreqTable::check_max_neighbor_separation(int r, int c, double center_value,bool check_row_below)
{
	double max_dist = 0;
	int r_neighbors[] = {0};
	int c_neighbors[] = {-1};

	if (check_row_below == true)
	{
		r_neighbors[0] = 0;
		c_neighbors[0] = 1;
	}
	int dr = 0;
	int dc = 0;
	double dist = 0;
	int N_neighbors = 1;
    
	for (int i = 0; i < N_neighbors; ++i)
	{
		dr = r_neighbors[i];
		dc = c_neighbors[i];
		if (r+dr >= 0 && r+dr < NROWS && c+dc >=0 && c+dc < NCOLS)
		{
			dist = abs(real_table[r+dr][c+dc]-center_value);
            //if (r == 16 || r == 17)
                //cout << r+dr << " " << c+dc << " " << real_table[r+dr][c+dc] << " " << dist << endl;
			if (dist > max_dist)
				max_dist = dist;
		}
	}
	return max_dist < required_max_neighbor_separation;
}

void FreqTable::find_layout_solution(bool work_backward)
{
	initialize_clean_table(work_backward);
}

void FreqTable::initialize_clean_table(bool work_backward)
{
	int N_table_attempts = 0;
	vector <double> available_freq_list(freq_list);
	bool good_placement = false;
	bool give_up = false;
	bool solved = false;
    int give_up_row = 0;
    int give_up_col = 0;
	while (solved == false)
	{

		if (N_table_attempts % 10000 == 0)
		{
			//random_engine.seed(clock());
			cout << "attempt " << N_table_attempts << endl;
			cout << "row " << give_up_row << "col " << give_up_col << endl;
            fflush(stdout);
		}
		++N_table_attempts;
		int random_index = 0;
		double freq = 0;
		available_freq_list.clear();
		available_freq_list = freq_list;
		int r_start = 0;
		int r_end =  NROWS - 1;
		int r_increment = 1;
        int c_start = 0;
        int c_end = NCOLS - 1;
        int c_increment = 1;
		if (work_backward == true)
		{
			r_end = 0;
			r_start = NROWS - 1;
			r_increment = -1;
            c_end = 0;
            c_start = NCOLS - 1;
            c_increment = -1;

		}
        for (int r = r_start; (!work_backward && r <= r_end) || (work_backward && r>= r_end); r+=r_increment)
		{
            for (int c = c_start; (!work_backward && c <= c_end) || (work_backward && c>= c_end); c+=c_increment)
			{
				int N_tries = 0;
				good_placement = false;
				give_up = false;
				tr1::uniform_int<int> random_index_engine(0,100*freq_list.size());
				while (good_placement == false && give_up == false)
				{
					give_up = N_tries >= available_freq_list.size()*3;
					random_index = random_index_engine(random_engine) % available_freq_list.size();
					freq = available_freq_list[random_index];
					good_placement = check_min_neighbor_separation(r,c,freq,work_backward);
					good_placement = good_placement && check_max_neighbor_separation(r,c,freq,work_backward);

                    /*
					for (int iConstraint = 0; iConstraint < neighbor_constraints.size(); ++iConstraint)
					{
						good_placement = good_placement && neighbor_constraints[iConstraint].obeys_constraint(r,c,freq,work_backward);
					}
                    */

					for (int iConstraint = 0; iConstraint < rect_constraints.size(); ++iConstraint)
					{
						good_placement = good_placement && rect_constraints[iConstraint].obeys_constraint(r,c,freq);
					}
					for (int iConstraint = 0; iConstraint < edge_constraints.size(); ++iConstraint)
					{
						good_placement = good_placement && edge_constraints[iConstraint].obeys_constraint(r,c,freq);
					}
					if (good_placement == true)
					{
						clean_table[r][c] = freq;
						real_table[r][c] = freq;
                        //cout << "0(" << r << "," << c << ")" << clean_table[r][c] << " " << freq << endl;
						available_freq_list.erase(available_freq_list.begin()+random_index);
					}
                    //cout << "1 " << clean_table[39][24] << endl;
					++N_tries;
				}
                //cout << "2 " << clean_table[39][24] << endl;
				if (give_up == true)
				{
                    give_up_row = r;
                    give_up_col = c;
					break;
				}
			}
            //cout << "3 " << clean_table[39][24] << endl;
			if (give_up == true)
			{
				break;
			}
		}
        //cout << "4 " << clean_table[39][24] << endl;
		solved = !give_up;

	}
	solution_found = solved;
	num_attempts_to_solve = N_table_attempts;
}

void FreqTable::build_freq_list()
{
	freq_list.clear();
	double IF_freq_hole_width = 10;
	double IF_freq_hole_lower_bound = start_freq+(MAX_FREQ-start_freq)/2.0-IF_freq_hole_width/2.0;
    double num_freqs = NROWS*NCOLS;
    cout << "start_freq " << start_freq << endl;
    cout << "max_freq " << MAX_FREQ << endl;
    cout << "num_freqs " << num_freqs << endl;
    if (has_if_hole == true)
        cout << "IF_freq_hole_lower_bound " << IF_freq_hole_lower_bound << endl;

	double BANDWIDTH_PER_CHANNEL = (MAX_FREQ-start_freq - IF_freq_hole_width)/(num_freqs-2);
	double IF_freq_hole_skip = IF_freq_hole_width-BANDWIDTH_PER_CHANNEL;
	if (has_if_hole == false)
		BANDWIDTH_PER_CHANNEL = (MAX_FREQ-start_freq)/num_freqs;
    cout << "bandwidth per channel " << BANDWIDTH_PER_CHANNEL << endl;
	double freq = 0;
    bool found_IF_hole = false;
	for (int r = 0; r < NROWS; ++r)
	{
		for (int c = 0; c < NCOLS; ++c)
		{
			freq = start_freq+(r*NCOLS+c)*BANDWIDTH_PER_CHANNEL;
			if (has_if_hole == true)
			{
				if (freq >= IF_freq_hole_lower_bound)
                {
                    if (found_IF_hole == false)
                        cout << "lower freq " << freq;
					freq += IF_freq_hole_skip;
                    if (found_IF_hole == false)
                        cout << " becomes " << freq << endl;
                    found_IF_hole = true;
                }
			}
            freq_list.push_back(freq);
		}
	}
}




void FreqTable::pretty_print_clean_table(ofstream& file)
{
    file.setf( std::ios::fixed, std::ios::floatfield );
    file.precision( 3 );
    file.width( 7 );
	for (int r = 0; r < NROWS; ++r)
	{
		for (int c = 0; c < NCOLS; ++c)
		{
			file << clean_table[r][c] << " ";
		}
		file << endl;
	}
}

void FreqTable::print_freq_list()
{
	cout << "freqList:" << endl;
	for (int i = 0; i < freq_list.size(); ++i)
	{
			if (i != 0)
				cout << ",";
			cout << setw(3) << freq_list[i];

	}


}



void FreqTable::add_rect_constraint(int r_lb,int r_ub,int c_lb,int c_ub,int f_lb,int f_ub,bool inclusive)
{
	rect_constraints.push_back(RectConstraint(r_lb,r_ub,c_lb,c_ub,f_lb,f_ub,inclusive));
}

void FreqTable::add_edge_constraint(FreqTable* ft,EdgeConstraint::position_t pos)
{
	edge_constraints.push_back(EdgeConstraint(ft,pos,required_min_neighbor_separation));
}

void FreqTable::clean_freq_table()
{
	for (int r = 0; r < NROWS; ++r)
	{
		for (int c = 0; c < NCOLS; ++c)
		{
			real_table[r][c] = clean_table[r][c];
		}
	}
}




