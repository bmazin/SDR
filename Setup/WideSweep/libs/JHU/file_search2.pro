;-------------------------------------------------------------
;+
; NAME:
;       FILE_SEARCH2
; PURPOSE:
;       Find files and sort them.
; CATEGORY:
; CALLING SEQUENCE:
;       f = file_search2(pat)
; INPUTS:
;       pat = filename or wildcard pattern.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         DIR=dir Directory or array of directories to search.
;         /SORT means sort file names numerically.
;         COUNT=c  Returned number of files found.
; OUTPUTS:
;       f = sorted array of found file names. out
; COMMON BLOCKS:
; NOTES:
;       Note: Any file_search keywords may be given.
;         Without the keywords DIR or /SORT this routine has
;         very nearly identical speed to file_search.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jan 06
;       R. Sterner, 2004 Jul 19 --- Added keyword DIR=dir.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function file_search2, pat, help=hlp, sort=srt, dir=dir, $
	  count=cnt, _extra=extra
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find files and sort them.'
	  print,' f = file_search2(pat)'
	  print,'   pat = filename or wildcard pattern.   in'
	  print,'   f = sorted array of found file names. out'
	  print,' Keywords:'	
	  print,'   DIR=dir Directory or array of directories to search.'
	  print,'   /SORT means sort file names numerically.'
	  print,'   COUNT=c  Returned number of files found.'
	  print,' Note: Any file_search keywords may be given.'
	  print,'   Without the keywords DIR or /SORT this routine has'
	  print,'   very nearly identical speed to file_search.'
	  return, ''
	endif
 
	nd = n_elements(dir)			; Directoy list given?
 
	if nd gt 0 then begin
	  cnt = 0
	  ff = ['']
	  for i=0,nd-1 do begin
	    pat2 = filename(dir(i),pat,/nosym)	; Look in directory i.
	    f = file_search(pat2,count=c,_extra=extra)	; Search for files.
	    if c gt 0 then begin		; Found some.
	      cnt = cnt + c			; Count them.
	      ff = [ff,f]			; Add them to list.
	    endif
	  endfor
	  if cnt gt 0 then f=ff(1:*)		; Drop seed value.
	endif else begin
	  f = file_search(pat,count=cnt,_extra=extra)	; Find files.
	  if cnt eq 0 then begin		; Any found?
	    print,' No files found.'		; No.
	    return, f				; Return null array.
	  endif
	endelse
 
	if keyword_set(srt) then begin		; Sort?
	  ff = strarr(cnt)			; New file names.
	  for l = 0, cnt-1 do begin		; Generate new file names.
	    namenum, f(l), patt, i, j, k	;   Find file name pattern.
	    ff(l) = numname(patt, i, j, k, digits=5) ;   name with 5 digit #s.
 	  endfor
	  is = sort(ff)				; Sort extracted numbers.
	  f = f(is)				; Sort files the same.
	endif
 
	return, f				; Return files.
	end
