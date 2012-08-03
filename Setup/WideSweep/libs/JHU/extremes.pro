;-------------------------------------------------------------
;+
; NAME:
;       EXTREMES
; PURPOSE:
;       Find all the local extremes of a 1-d array.
; CATEGORY:
; CALLING SEQUENCE:
;       ind = extremes(y, flag)
; INPUTS:
;       y = 1-d array to search.                      in
;       flag = min/max flag: -1 for min, 1 for max.   in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ind = indices of local extremes (-1 if none). out
; COMMON BLOCKS:
; NOTES:
;       Notes: if the curve has flat topped regions local
;        maxes are returned at both the start and end of
;        the regions.  Similarly for flat bottomed regions
;        local mins are returned at both the start and end of
;        the regions.
; MODIFICATION HISTORY:
;       R. Sterner, 22 Sep, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
        function extremes, y, flag, help=hlp
 
        if (n_params(0) lt 2) or keyword_set(hlp) then begin
          print,' Find all the local extremes of a 1-d array.'
          print,' ind = extremes(y, flag)'
          print,'   y = 1-d array to search.                      in'
          print,'   flag = min/max flag: -1 for min, 1 for max.   in'
          print,'   ind = indices of local extremes (-1 if none). out'
          print,' Notes: if the curve has flat topped regions local'
          print,'  maxes are returned at both the start and end of'
          print,'  the regions.  Similarly for flat bottomed regions'
          print,'  local mins are returned at both the start and end of'
          print,'  the regions.'
          return, -1
        endif
 
        d = y - shift(y,1)                      ; Find slope.
        s = fix(d gt 0) - fix(d lt 0)           ; Sign of slope.        
        w = where((shift(s,1)-s)>(-1)<1 eq flag); Find jumps in slope sign.
 
        if n_elements(w) gt 1 then begin
          if w(0) le 1 then return, w(1:*)-1 else return, w-1
        endif else begin
          if w(0) le 1 then return, -1 else return, w-1
        endelse
 
        end
