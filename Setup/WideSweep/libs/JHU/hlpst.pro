;-------------------------------------------------------------
;+
; NAME:
;       HLPST
; PURPOSE:
;       List structure elements.  Gives array min/max.
; CATEGORY:
; CALLING SEQUENCE:
;       hlpst, s
; INPUTS:
;       s = Input structure.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         OUT=out Return descriptive text.
;         /QUIET  Do not print text.
;         LEV=lv  Recursion level (def=0).
;         TAG=tag Name of item.  If not given find it.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Recurses through internal structures.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Apr 29
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro hlpst, s, out=out, quiet=quiet, lev=lv, tag=tag0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' List structure elements.  Gives array min/max.'
	  print,' hlpst, s'
	  print,'   s = Input structure.    in'
	  print,' Keywords:'
	  print,'   OUT=out Return descriptive text.'
	  print,'   /QUIET  Do not print text.'
	  print,'   LEV=lv  Recursion level (def=0).'
	  print,'   TAG=tag Name of item.  If not given find it.'
	  print,' Notes: Recurses through internal structures.'
	  return
	endif
 
	;------------------------------------
	;  Recursion level
	;------------------------------------
	if n_elements(lv) eq 0 then lv=1
 
	;------------------------------------
	;  Structure name and details
	;------------------------------------
	txt = ['']
	if n_elements(tag0) gt 0 then begin
	  nam = tag0
	endif else begin
	  nam = scope_varname(s,lev=-1,count=c)
	endelse
	if strlen(nam) le 12 then nam=string(nam,form='(A12)')
	ind = ' '+spc(3*(lv-1))	; Structure name indent.
	if n_elements(s) eq 0 then begin
	  out = ind+nam+': Undefined'
	  goto, skip
	endif else begin
	  snam = tag_names(s,/structure_name)
	  if snam eq '' then snam='Anonymous'
	  slen = n_tags(s,/length)
	  snum = n_tags(s)
	  sinfo = 'Name='+snam+', # Tags='+strtrim(snum,2)+$
	    ', # Bytes='+strtrim(slen,2)
	  txt = [txt,ind+nam+': Structure. '+sinfo]
	endelse
	ind = ' '+spc(3*lv)	; Element indent.
 
	;------------------------------------
	;  Number and names of tags
	;------------------------------------
	n = n_tags(s)
	t = tag_names(s)
 
	;------------------------------------
	;  Right justify names
	;------------------------------------
	w = where(strlen(t) le 12, c)
	if c gt 0 then t(w)=string(t(w),form='(A12)')
 
	;------------------------------------
	;  Loop through elements
	;------------------------------------
	for i=0, n-1 do begin
	  tag = t(i)		; Element name.
	  val = s.(i)		; Element value.
	  typ = datatype(val)	; Element type.
	  if typ ne 'STC' then begin	; Single item.
	    hlp2, val, des=des, /quiet
	    txt = [txt,ind+tag+': '+des]
	  endif else begin		; Nested Structure.
	    hlpst, val, out=out, /quiet, lev=lv+1, tag=tag
	    txt = [txt, out]
	  endelse
 
	endfor
	out = txt(1:*)
 
skip:
	if not keyword_set(quiet) then more,out,lines=100
 
	end
