;-------------------------------------------------------------
;+
; NAME:
;       INVINTERP
; PURPOSE:
;       Inverse interpolation.
; CATEGORY:
; CALLING SEQUENCE:
;       x0 = invinterp(y, y0)
; INPUTS:
;       y = values (monotonic) along the y axis.           in
;       y0 = specific y value to be inverse interpolated.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         X = x Optional x axis values corresponding to y. If omitted,
;         x is assumed to be a sequence of integers starting with 0.
;         ERROR=err  error flag.  0 if there is no error.
; OUTPUTS:
;       x0 = interpolated value coresponding to y0.        out
; COMMON BLOCKS:
; NOTES:
;       Notes:
;        Input y must be monotonic.
; MODIFICATION HISTORY:
;       B. L. Gotwols, 2000 Oct 15 --- Creation.
;       B. L. Gotwols, 2001 Sep 18 --- Added documentationand help.
;
; Copyright (C) 2000, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
    function invinterp, y, y0, x=x, err=err, help=hlp
    err=1
    if keyword_set(hlp) or n_params() ne 2 then begin
      print,' Inverse interpolation.'
      print,' x0 = invinterp(y, y0)'
      print,'   y = values (monotonic) along the y axis.           in'
      print,'   y0 = specific y value to be inverse interpolated.  in'
      print,'   x0 = interpolated value coresponding to y0.        out'
      print,' Keywords:
      print,'   X = x Optional x axis values corresponding to y. If omitted,
      print,'   x is assumed to be a sequence of integers starting with 0.
      print,'   ERROR=err  error flag.  0 if there is no error.
      print,' Notes:'
      print,'  Input y must be monotonic.'  
      return,-1
    endif
 
    if n_elements(x) eq 0 then x = lindgen(n_elements(y)) 
    yd = double(y)  ; Ensure double
    j = where(yd ge y0, cnt)
 
    if cnt lt 1 then begin         ; y0 is out of range
        print,'invinterp: y0 is out of range'
        return, -1
    endif
 
    j = j[0]                       ; Want only the first point
    if j eq 0 and y0 eq yd[0] then begin  ; Special case: 1st point is exact
        err=0
        return,0
    endif
 
    if j eq 0 then return,-1
 
    delx = x[1] - double(x[0])
    err=0
    return, double(x[j-1]) + ((y0-yd[j-1])/(yd[j]-yd[j-1]))*delx
    end
 
