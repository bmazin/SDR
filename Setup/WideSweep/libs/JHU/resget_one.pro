;-------------------------------------------------------------
;+
; NAME:
;       RESGET_ONE
; PURPOSE:
;       Function to get one item from a res file.
; CATEGORY:
; CALLING SEQUENCE:
;       val = resget_one(resfile, tag)
; INPUTS:
;       resfile = Name of res file.    in
;       tag = Tag name of item to get. in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  Error flag, 0=ok.
; OUTPUTS:
;       val = Returned value.          out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Dec 08
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function resget_one, rfile, tag, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Function to get one item from a res file.'
	  print,' val = resget_one(resfile, tag)'
	  print,'   resfile = Name of res file.    in'
	  print,'   tag = Tag name of item to get. in'
	  print,'   val = Returned value.          out'
	  print,' Keywords:'
	  print,'   ERROR=err  Error flag, 0=ok.'
	  return,''
	endif
 
	resopen,rfile,err=err
	if err ne 0 then return,''
	resget, tag, val, error=err
	resclose
	return, val
 
	end
