;-------------------------------------------------------------
;+
; NAME:
;       TAGS_COMP
; PURPOSE:
;       Compare tag values from two structures.
; CATEGORY:
; CALLING SEQUENCE:
;       tags_comp, s1, s2, [list]
; INPUTS:
;       s1, s2 = two structures to compare.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         LIST=list = optional list of tags to compare.
;           May be a text array of space delimited list.
;           If list is not given then all matching
;           tags are compared.
;         OUT=txt Returned listing as a text array.
;         /QUIET  Do not display tag values.
;         /NOFLAG means do not flag unequality of the two values.
;           Default is to indicate which pairs are unequal.
;         /EQUAL flag when equal instead of unequal.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2005 May 20
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tags_comp, s1, s2, list=list0, out=out, quiet=quiet, $
	  equal=equal, noflag=noflag, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Compare tag values from two structures.'
	  print,' tags_comp, s1, s2, [list]'
	  print,' s1, s2 = two structures to compare.       in'
	  print,' Keywords:'
	  print,'   LIST=list = optional list of tags to compare.'
	  print,'     May be a text array of space delimited list.'
	  print,'     If list is not given then all matching'
	  print,'     tags are compared.'
	  print,'   OUT=txt Returned listing as a text array.'
	  print,'   /QUIET  Do not display tag values.'
	  print,'   /NOFLAG means do not flag unequality of the two values.'
	  print,'     Default is to indicate which pairs are unequal.'
	  print,'   /EQUAL flag when equal instead of unequal.'
	  return
	endif
 
	;----------------------------------------------------
	;  Make sure list exists
	;  Force into a text array.
	;  Format of list0: ['a','b','c','d'] or 'a b c d'
	;----------------------------------------------------
	if n_elements(list0) eq 0 then tags_match,s1,s2,list0,/q
	wordarray,list0,list
 
	;----------------------------------------------------
	;  Structure names if possible
	;  If names not available make them up.
	;----------------------------------------------------
	if float(!version.release) ge 6.1 then begin
	  nam1 = scope_varname(s1,lev=-1,count=c)
	  nam2 = scope_varname(s2,lev=-1,count=c)
	  if nam1 eq '' then nam1='Struct_1'
	  if nam2 eq '' then nam2='Struct_2'
	endif else begin
	  nam1 = 'Struct_1'
	  nam2 = 'Struct_2'
	endelse
 
	;----------------------------------------------------
	;  Loop through items
	;----------------------------------------------------
	nsp = 20				; Spacing between values.
	tprint,/init				; Start internal print.
	tprint,' '
	tprint,' Structure:                '+nam1+spc(nsp,nam1)+nam2
	tprint,' Tag                       Value 1             Value 2'
	for i=0,n_elements(list)-1 do begin	; Loop through tags.
	  tag = list(i)				; Tag name.
	  t1 = tag_value(s1,tag)		; Values.
	  t2 = tag_value(s2,tag)
	  pre = '   '
	  if keyword_set(equal) then begin	; Deal with = or != flag.
	    if t1 eq t2 then pre=' = '		; Show = when equal.
	  endif else begin
	    if t1 ne t2 then pre='!= '		; Show != when not equal.
	  endelse
	  if keyword_set(noflag) then pre='   '	; No flag.
	  if n_elements(t1) gt 1 then begin	; Deal with arrays.
	    v1 = datatype(t1,/des)		; Array description.
	  endif else begin			; Deal with scalar.
	    v1 = strtrim(t1,2)			; Convert value to string.
	  endelse
	  if n_elements(t2) gt 1 then begin
	    v2 = datatype(t2,/des)
	  endif else begin
	    v2 = strtrim(t2,2)
	  endelse
	  v2 = pre + v2				; Add = or != flag.
	  if strlen(v1) gt nsp-2 then begin	; Strings too long to
	    tprint,' '+tag+spc(nsp+6,tag)+v1	;   print side by side
	    tprint,' '+spc(nsp+6)+spc(nsp-3)+v2	;   go on two lines.
	  endif else begin			; Can print both on line.
	    tprint,' '+tag+spc(nsp+6,tag)+v1+spc(nsp-3,v1)+v2
	  endelse
	endfor
 
	if not keyword_set(quiet) then tprint,/print
	tprint,out=out
 
	end
