#ifndef FREQTABLE_H_
#define FREQTABLE_H_

#include <tr1/random>
#include <set>
#include <vector>
#include <fstream>
#include "EdgeConstraint.h"

class EdgeConstraint;
class RectConstraint;

class FreqTable
{
	private:
	double** clean_table;
	double** real_table;
	double required_min_neighbor_separation;
	double collision_threshold;
	double scatter_stddev;
	double gradient_magnitude;
	double gradient_angle;
	double intermediate_freq;
	double start_freq;
	int MAX_FREQ;
	int NROWS;
	int NCOLS;
	int num_bad_pixels;
	int num_attempts_to_solve;
	double min_neighbor_separation;
	bool solution_found;
	bool has_if_hole;
	std::tr1::ranlux64_base_01 random_engine;

	std::multiset<double> neighbor_freq_separations;
	std::vector<double> freq_list;
	std::vector<double> global_freq_separations;
	std::vector<RectConstraint> rect_constraints;
	std::vector<EdgeConstraint> edge_constraints;

	bool check_cell_neighbor_separation(int r, int c, double center_value,bool check_row_below);
	void build_freq_list();
	void set_random_grad_angle();
	void initialize_clean_table(bool work_backward);


	public:

	FreqTable(unsigned int seed);
	~FreqTable();
	void pretty_print_clean_table(ofstream& file);
	void print_freq_list();

	void clean_freq_table();
	void find_layout_solution(bool work_backward);


	void add_rect_constraint(int r_lb,int r_ub,int c_lb,int c_ub,int f_lb,int f_ub,bool inclusive);
	void add_edge_constraint(FreqTable* ft,EdgeConstraint::position_t pos);
	void remove_constraints();
	int get_num_rows() {return NROWS;}
	int get_num_cols() {return NCOLS;}
	double get_cell_freq(int row,int col) {return real_table[row][col];}
	void set_requirements(int num_rows,int num_cols,double bandwidth,double min_n_sep,double start_f,bool if_hole);
	friend class EdgeConstraint;
};


#endif /*FREQTABLE_H_*/

