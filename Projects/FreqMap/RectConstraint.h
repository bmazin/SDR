#ifndef RECTCONSTRAINT_H_
#define RECTCONSTRAINT_H_

class RectConstraint
{
	private:
	public:
	int r_lower_bound;
	int r_upper_bound;
	int c_lower_bound;
	int c_upper_bound;
	double f_lower_bound;
	double f_upper_bound;
	bool include_freq_range;

    bool in_rect;
	RectConstraint()
		:r_lower_bound(0),r_upper_bound(0),c_lower_bound(0),c_upper_bound(0),f_lower_bound(0),f_upper_bound(0),include_freq_range(true) {}
	RectConstraint(int r_lb,int r_ub,int c_lb,int c_ub,int f_lb,int f_ub,bool include)
		:r_lower_bound(r_lb),r_upper_bound(r_ub),c_lower_bound(c_lb),c_upper_bound(c_ub),
		f_lower_bound(f_lb),f_upper_bound(f_ub),include_freq_range(include) {}
	bool obeys_constraint(int r, int c, double f)
	{
		in_rect = r >= r_lower_bound && r<= r_upper_bound && c >= c_lower_bound && c <= c_upper_bound;
		if (in_rect == true)
		{
			if (include_freq_range == true)
			{
				return f >= f_lower_bound && f <= f_upper_bound;
			}
			else
			{
				return f <= f_lower_bound || f >= f_upper_bound;
			}
		}
		else
			return true;
	}
};

#endif /*RECTCONSTRAINT_H_*/
