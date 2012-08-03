;-------------------------------------------------------------
;+
; NAME:
;       ABS_PATH
; PURPOSE:
;       Convert a relative path to an absolute path.
; CATEGORY:
; CALLING SEQUENCE:
;       apath = abs_path(rpath)
; INPUTS:
;       rpath = Relative path, like ../../xx/yy.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         BASE=base  Base directory (def=current).
; OUTPUTS:
;       apath = Returned absolute path.            out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Apr 25
;       R. Sterner, 2006 May 11 --- Fixed to work for non-relative path.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function abs_path, rpath, base=base, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a relative path to an absolute path.'
	  print,' apath = abs_path(rpath)'
	  print,'   rpath = Relative path, like ../../xx/yy.   in'
	  print,'   apath = Returned absolute path.            out'
	  print,' Keywords:'
	  print,'   BASE=base  Base directory (def=current).'
	  return,''
	endif
 
	;----------------------------------------------
	;  Default base directory is current
	;----------------------------------------------
	if n_elements(base) eq 0 then cd,curr=base
 
	;----------------------------------------------
	;  Operating system dependent separator
	;----------------------------------------------
	sep = path_sep()
 
	;----------------------------------------------
	;  Count how many steps up (# of ..)
	;  If no .. then was not a relative path.
	;----------------------------------------------
	p = -1				; Position.
	c = -1				; Count.
	repeat begin
	  p = strpos(rpath,'..',p+1)
	  c += 1
	endrep until p lt 0
	if c eq 0 then return, rpath
 
	;----------------------------------------------
	;	Drop directories off end of base
	;----------------------------------------------
	front = sep + getwrd(base,del=sep,/last,-99,-c,/notrim) + sep
 
	;----------------------------------------------
	;	Drop up steps from rpath
	;----------------------------------------------
	back = getwrd(rpath,del=sep,c,99)
 
	;----------------------------------------------
	;	Merge and return
	;----------------------------------------------
	return, front + back
 
	end
