;-------------------------------------------------------------
;+
; NAME:
;       CYPH
; PURPOSE:
;       Construct a cycle/phase array from time series data.
; CATEGORY:
; CALLING SEQUENCE:
;       cyph, data, time
; INPUTS:
;       data = time series data.             in
;       time = time tag of each data point.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         CPOUT=z  Returned reformatted data image.
;         TOUT=t   Returned time for bottom line image.
;         OFFSET=frac  Given starting offset into data as fraction
;           of time slice size (def=0).
;         SLICE=dx  Given slice size in samples (may be fractional).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: See also xcyph, a widget based interactive version.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Mar 2.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
        pro cyph, data, time, cpout=z0, tout=x, help=hlp, $
          offset=frac, slice=dx 
 
        if (n_params(0) lt 2) or keyword_set(hlp) then begin
          print,' Construct a cycle/phase array from time series data.'
          print,' cyph, data, time'
          print,'   data = time series data.             in'
          print,'   time = time tag of each data point.  in'
          print,' Keywords:'
          print,'   CPOUT=z  Returned reformatted data image.'
          print,'   TOUT=t   Returned time for bottom line image.'
          print,'   OFFSET=frac  Given starting offset into data as fraction'
          print,'     of time slice size (def=0).'
          print,'   SLICE=dx  Given slice size in samples (may be fractional).'
	  print,' Notes: See also xcyph, a widget based interactive version.'
          return
        endif
 
        mx = n_elements(data)
        if n_elements(frac) eq 0 then frac=0.
 
        if n_elements(dx) eq 0 then begin
          print,' Must give a cycle length.'
          return
        endif
        start = long(frac*dx)
        idx = fix(dx)
        dy = long((mx-start)/dx)
        z0 = dblarr(idx,dy)
        j = dblarr(idx,dy)
        off = dindgen(dy)*dx + start
        for i = 0, dy-1 do begin
          lo = long(off(i))
          hi = long(off(i)+idx)-1
          z0(0,i) = data(lo:hi)
          j(0,i) = time(lo:hi)
        endfor
        z0 = transpose(z0)
        j = transpose(j)
 
        x = j(*,0)              ; JS along image bottom.
        tr=[x(0),x(dy-1)]       ; Actual time range.
        x = maken(tr(0),tr(1),dy)  ; Correct time array.
 
        end
