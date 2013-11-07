#include "EdgeConstraint.h"
#include "FreqTable.h"
#include <vector>
#include <cmath>
#include <iostream>

using namespace std;

bool EdgeConstraint::obeys_constraint(int r, int c, double f)
{
		FreqTable* ft = freq_table_at_position;
        double sep = 0;
        if (position == ABOVE_LEFT && r==0 && c==0)
        {
            sep = abs(ft->real_table[(ft->NROWS)-1][(ft->NCOLS)-1]-f);
            //if (sep > required_min_neighbor_separation)
            //	cerr << "Compared " << f << " to " << ft->real_table[(ft->NROWS)-1][c] << endl;
            return  sep > required_min_neighbor_separation;
        }
        else if (position == ABOVE_CENTER && r==0)
        {
            sep = abs(ft->real_table[(ft->NROWS)-1][c]-f);
            return  sep > required_min_neighbor_separation;
        }
        else if (position == ABOVE_RIGHT && r==0 && c==(ft->NCOLS-1))
        {
            sep = abs(ft->real_table[(ft->NROWS)-1][0]-f);
            return  sep > required_min_neighbor_separation;
        }
        else if (position == MIDDLE_LEFT && c==0)
        {
            sep = abs(ft->real_table[r][(ft->NCOLS)-1]-f);
            return  sep > required_min_neighbor_separation;
        }
        else if (position == MIDDLE_RIGHT && c==(ft->NCOLS-1))
        {
            sep = abs(ft->real_table[r][0]-f);
            return  sep > required_min_neighbor_separation;
        }
        else if (position == BELOW_LEFT && r==(ft->NROWS-1) && c==0)
        {
            sep = abs(ft->real_table[0][(ft->NCOLS)-1]-f);
            return  sep > required_min_neighbor_separation;
        }
        else if (position == BELOW_CENTER && r==(ft->NROWS-1) )
        {
            sep = abs(ft->real_table[0][c]-f);
            return  sep > required_min_neighbor_separation;
        }
        else if (position == BELOW_RIGHT && r==(ft->NROWS-1)  && c==(ft->NCOLS-1))
        {
            sep = abs(ft->real_table[0][0]-f);
            return  sep > required_min_neighbor_separation;
        }
        else
            return true;
	}
