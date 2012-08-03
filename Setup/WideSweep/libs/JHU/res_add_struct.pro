;-------------------------------------------------------------
;+
; NAME:
;       RES_ADD_STRUCT
; PURPOSE:
;       Add items from given unnested structure to an open res file.
; CATEGORY:
; CALLING SEQUENCE:
;       res_add_struct, struct
; INPUTS:
;       struct = given structure. in
; KEYWORD PARAMETERS:
;       Keywords:
;         FD=fd optional file descriptor.
;         ERROR=err error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Comments to write to the res file are from structure
;         tags named _comm001, _comm002, ... where number of digits
;         does not matter (anything after _comm is ignored).
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Oct 28
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro res_add_struct, s, error=err, $
	  fd=fd, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Add items from given unnested structure to an open res file.'
	  print,' res_add_struct, struct'
	  print,'   struct = given structure. in'
	  print,' Keywords:'
	  print,'   FD=fd optional file descriptor.'
	  print,'   ERROR=err error flag: 0=ok.'
	  print,' Notes: Comments to write to the res file are from structure'
	  print,'   tags named _comm001, _comm002, ... where number of digits'
	  print,'   does not matter (anything after _comm is ignored).'
	  return
	endif
 
	;-----  Is res file open?  -----------
	rescom,getlun=lun
	if lun lt 0 then begin
	  print,' Error in res_add_struct: no res file open.'
	  err = 1
	  return
	endif else err=0
 
	;-----  Loop through structure items  ---------
	n = n_tags(s)					; # tags in structure.
	tags = tag_names(s)				; Tag names.
	for i=0, n-1 do begin				; Loop through tags.
	  name = tags(i)				; RES file item name.
	  val = s.(i)					; RES file item value.
	  if strupcase(strmid(name,0,5)) eq '_COMM' then begin
	    resput,fd=fd,comm=val
	  endif else begin
	    resput,fd=fd,name,val
	  endelse
	endfor
 
	end
