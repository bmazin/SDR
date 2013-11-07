#ifndef EDGECONSTRAINT_H_
#define EDGECONSTRAINT_H_

using namespace std;


class FreqTable;
class EdgeConstraint
{
	public:
	enum position_t
	{
		ABOVE_LEFT,
		ABOVE_CENTER,
		ABOVE_RIGHT,
		MIDDLE_LEFT,
		MIDDLE_RIGHT,
		BELOW_LEFT,
		BELOW_CENTER,
		BELOW_RIGHT
	};
	EdgeConstraint(FreqTable* freq_table,position_t pos,double n_sep)
		:freq_table_at_position(freq_table),position(pos), required_min_neighbor_separation(n_sep){}
	bool obeys_constraint(int r, int c, double f);//assumes both freq tables have same dimensions

	private:
	position_t position;
	FreqTable* freq_table_at_position;
	double required_min_neighbor_separation;

	
};

#endif /*EDGECONSTRAINT_H_*/
