;-------------------------------------------------------------
;+
; NAME:
;       INTERPX
; PURPOSE:
;       Interpolate data with possible gaps and missing (bad) values.
; CATEGORY:
; CALLING SEQUENCE:
;       yy = interp1(x,y,xx)
; INPUTS:
;       x,y = input points.            in
;         x is assumed monotonically increasing.
;       xx = desired x values.         in
;         xx need not be monotonically increasing.
; KEYWORD PARAMETERS:
;       Keywords:
;         BAD=b  Values GREATER THAN b are considered missing.
;         GAP=g  Gaps in x greater than or equal to this
;           are broken by setting the output curve points
;           in the gaps to a flag value of 32000 or BAD if given.
;         /FIXBAD  means interpolate across bad data between
;           closest good points on each side.  Otherwise the
;           bad points are flagged with the value specified
;           for BAD.
; OUTPUTS:
;       yy = interpolated y values.    out
; COMMON BLOCKS:
; NOTES:
;       Notes: Flagged values may be used to break a plotted
;          curve using MAX_VALUE in the PLOT or OPLOT command:
;          plot,x,y,max_value=999
;          SLOW for more than a few thousand points.
; MODIFICATION HISTORY:
;       R. Sterner, 12 Aug, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function interpx, x,y,xx, help=hlp, bad=bad, $
	  gap=gap, fixbad=xbad
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Interpolate data with possible gaps and missing (bad) values.'
	  print,' yy = interp1(x,y,xx)'
	  print,'   x,y = input points.            in'
	  print,'     x is assumed monotonically increasing.'
	  print,'   xx = desired x values.         in'
	  print,'     xx need not be monotonically increasing.'
	  print,'   yy = interpolated y values.    out'
	  print,' Keywords:'
	  print,'   BAD=b  Values GREATER THAN b are considered missing.'
	  print,'   GAP=g  Gaps in x greater than or equal to this'
	  print,'     are broken by setting the output curve points'
	  print,'     in the gaps to a flag value of 32000 or BAD if given.'
	  print,'   /FIXBAD  means interpolate across bad data between'
	  print,'     closest good points on each side.  Otherwise the'
	  print,'     bad points are flagged with the value specified'
	  print,'     for BAD.'
	  print,' Notes: Flagged values may be used to break a plotted'
	  print,'    curve using MAX_VALUE in the PLOT or OPLOT command:'
	  print,'    plot,x,y,max_value=999'
	  print,'    SLOW for more than a few thousand points.'
	  return,-1
	endif
 
	;--------  Find any data gaps  ------------------------------
	;  Data gaps are where the X coordinate jumps by more than a
	;  specified amount.  Save the index of the point just before
	;  the gap in glo and the index of the point just above the
	;  gap in ghi (= next point).
	;------------------------------------------------------------
	cntg = 0				; Assume no gaps.
	if n_elements(gap) ne 0 then begin	; Gap value given.
	  glo = where(x(1:*)-x gt gap, cntg)	; Index of 1st pt below gap.
	  ghi = glo + 1				; Index of 1st pt above gap.
	endif
 
	;--------  Find any bad points  -----------------------------------
	;  It is assumed that bad points have been tagged with a flag value
	;  before calling this routine.  Any points with a value less than
	;  or equal to the flag value are assumed to be good.  The indices
	;  of the good points on either side are saved in lo and hi.
	;-----------------------------------------------------------------
	cntb = 0				; Assume no bad points.
	if n_elements(bad) ne 0 then begin	; Bad tag value given.
	  w = where(y le bad, cnt)		; Indices of good values.
	  if cnt gt 0 then begin		; Found some good points.
	    wb = where(w(1:*)-w gt 1, cntb)	; Look for index jumps > 1.
	  endif
	endif
	if cntb gt 0 then begin	; Found some bad point groups.
	  lo = w(wb)		; Index of ignore window bottom.
	  hi = w(wb+1)		; Index of ignore window top.
	endif
 
	;--------  Setup output y array and flag value  -------
	yy = make_array(n_elements(xx),type=datatype(y,2))
	flag = 32000.
	if n_elements(bad) ne 0 then flag = bad
 
	;-----  Handle bad points  -------------------------------
	;  Flag which points in the output arrays to ignore due to bad pts.
	;---------------------------------------------------------
	if not keyword_set(xbad) then begin
	  if cntb gt 0 then begin
	    for i = 0, n_elements(lo)-1 do begin  ; Loop thru bad point gaps.
	      w = where((xx gt x(lo(i))) and (xx lt x(hi(i))), cnt) ; In gap.
	      if cnt gt 0 then yy(w) = flag	  ; Flag those in bad pt gap.
	    endfor
	  endif
	endif
 
	;-----  Handle data gaps  ---------------------------------
	;  Flag which points in the output arrays to ignore due to data gaps.
	;----------------------------------------------------------
	if cntg gt 0 then begin
	  for i = 0, n_elements(glo)-1 do begin	; Loop thru gaps.
	    w = where((xx gt x(glo(i))) and (xx lt x(ghi(i))), cnt)
	    if cnt gt 0 then yy(w) = flag		; Flag those in gap.
	  endfor
	endif
 
	;-----  Linearly interpolate into x,y at xx to get yy --------
	;  Drop any bad points from input curve before interpolating.
	;  Then find input and output curve sizes.
	;  Finally interpolate needed points.
	;-------------------------------------------------------------
	cnt = 0
	if n_elements(bad) ne 0 then begin
	  w = where(y lt bad, cnt)			; Drop bad points
	endif
	if cnt eq 0 then w = lindgen(n_elements(x))	; before interpolation.
	x2 = x(w)
	y2 = y(w)
 
	lstxx = n_elements(xx) - 1		; Number of output points.
	lstx = n_elements(x2) - 1		; Number of good input points.
 
	for i = 0L, lstxx do begin		; Loop through output points.
	  if yy(i) eq flag then goto, skip	; Ignore flagged points.
	  j = (where(x2 ge xx(i)))(0)
	  case 1 of
j eq -1:    yy(i) = y2(lstx)			; After last input x.
j eq  0:    yy(i) = y2(0)			; Before first input x.
   else:    begin				; Must interpolate.
	      m = (y2(j) - y2(j-1))/(x2(j) - x2(j-1))	; Slope.
	      yy(i) = m*(xx(i) - x2(j-1)) + y2(j-1)	; y = m*x + b.
	    end
	  endcase
skip:
	endfor
 
	return, yy
	end
