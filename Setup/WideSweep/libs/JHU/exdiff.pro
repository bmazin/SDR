;------  exdiff.pro = Return difference between array extremes  ------- 
	function exdiff, x, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return difference between array extremes.'
	  print,' diff = exdiff(a)' 
	  print,'   a = array.                      in'
	  print,'   diff = max(a)-min(a)            out'
	  print,' Note: simplifies dealing with range arrays.'
	  print,'   Example: plot window (spanned by axes) in pixels:'
	  print,'     nx = exdiff(!x.window)*!d.x_size'
	  print,'     ny = exdiff(!y.window)*!d.y_size'
	  print,' '
	  return, ''
	end
 
	return, max(x) - min(x)
	end
