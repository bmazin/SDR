;-------------------------------------------------------------
;+
; NAME:
;       RES_FROM_STRUCT
; PURPOSE:
;       Write a RES file from an unnested structure.
; CATEGORY:
; CALLING SEQUENCE:
;       res_from_struct, resfile, struct
; INPUTS:
;       resfile = name of RES file.  in
;       struct = returned structure. in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Comments to write to the RES file are from structure
;         tags named _comm001, _comm002, ... where number of digits
;         does not matter (anything after _comm is ignored).
; MODIFICATION HISTORY:
;       R.Sterner, 2003 Aug 20
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro res_from_struct, resfile, s, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Write a RES file from an unnested structure.'
	  print,' res_from_struct, resfile, struct'
	  print,'   resfile = name of RES file.  in'
	  print,'   struct = returned structure. in'
	  print,' Keywords:'
	  print,'   ERROR=err error flag: 0=ok.'
	  print,' Notes: Comments to write to the RES file are from structure'
	  print,'   tags named _comm001, _comm002, ... where number of digits'
	  print,'   does not matter (anything after _comm is ignored).'
	  return
	endif
 
	;-----  Open RES file  -----------
	resopen,resfile,err=err,/write
	if err ne 0 then return
 
	;-----  Loop through structure items  ---------
	n = n_tags(s)					; # tags in structure.
	tags = tag_names(s)				; Tag names.
	for i=0, n-1 do begin				; Loop through tags.
	  name = tags(i)				; RES file item name.
	  val = s.(i)					; RES file item value.
	  if strupcase(strmid(name,0,5)) eq '_COMM' then begin
	    resput,comm=val
	  endif else begin
	    resput,name,val
	  endelse
	endfor
 
	resclose
 
	end
