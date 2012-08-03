;-------------------------------------------------------------
;+
; NAME:
;       TXTPUTKEY
; PURPOSE:
;       Write a structure out in keyword/value pair form.
; CATEGORY:
; CALLING SEQUENCE:
;       txtputkey, file, s
; INPUTS:
;       file = Name of file to write.    in
;       s = Structure to write.          in
; KEYWORD PARAMETERS:
;       keyword/value pair where the keyword is the field
;       tag name and the value is the tag definition (or value).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: will save each field in the structure as a
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jun 02
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro txtputkey, file, s, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Write a structure out in keyword/value pair form.'
	  print,' txtputkey, file, s'
	  print,'   file = Name of file to write.    in'
	  print,'   s = Structure to write.          in'
	  print,' Notes: will save each field in the structure as a'
	  print,' keyword/value pair where the keyword is the field'
	  print,' tag name and the value is the tag definition (or value).'
	  return
	endif
 
	n = n_tags(s)			; Number of tags.
	tag = tag_names(s)		; Names of tags.
 
	openw,lun,file,/get_lun		; Open output file.
 
	for i=0, n-1 do begin		; Loop through tags.
	  val = strtrim(s.(i),2)	; Grab value.
	  nv =  n_elements(val)
	  if nv gt 1 then begin		; Repeated keyword.
	    for j=0,nv-1 do printf,lun,tag(i)+' = '+val(j)
	  endif else begin		; Single keyword.
	    printf,lun,tag(i)+' = '+val
	  endelse
	endfor
 
	free_lun, lun
 
	end
