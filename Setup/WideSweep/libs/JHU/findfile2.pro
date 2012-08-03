;-------------------------------------------------------------
;+
; NAME:
;       FINDFILE2
; PURPOSE:
;       Find files and sort them.
; CATEGORY:
; CALLING SEQUENCE:
;       f = findfile2(pat)
; INPUTS:
;       pat = filename or wildcard pattern.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /SORT means sort file names numerically.
;         COUNT=c  Returned number of files found.
; OUTPUTS:
;       f = sorted array of found file names. out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Mar, 1990
;       R. Sterner, 1996 Sep 17 --- Added COUNT=c keyword.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function findfile2, pat, help=hlp, sort=srt, count=cnt
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find files and sort them.'
	  print,' f = findfile2(pat)'
	  print,'   pat = filename or wildcard pattern.   in'
	  print,'   f = sorted array of found file names. out'
	  print,' Keywords:'	
	  print,'   /SORT means sort file names numerically.'
	  print,'   COUNT=c  Returned number of files found.'
	  return, ''
	endif
 
	f = findfile(pat,count=cnt)		; Find files.
	f = f					; Force list to be an array.
	if f(0) eq '' then begin		; Any found?
	  print,' No files found.'		; No.
	  return, f				; Return null array.
	endif
 
	if keyword_set(srt) then begin		; Sort?
	  ff = strarr(cnt)			; New file names.
	  for l = 0, cnt-1 do begin		; Generate new file names.
	    namenum, f(l), pat, i, j, k		;   Find file name pattern.
	    ff(l) = numname(pat, i, j, k, digits=5) ;   name with 5 digit #s.
 	  endfor
	  is = sort(ff)				; Sort extracted numbers.
	  f = f(is)				; Sort files the same.
	endif
 
	return, f				; Return files.
	end
