;-------------------------------------------------------------
;+
; NAME:
;       RES_TO_STRUCT
; PURPOSE:
;       Read a RES file into a structure.
; CATEGORY:
; CALLING SEQUENCE:
;       res_to_struct, resfile, struct
; INPUTS:
;       resfile = name of RES file.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         IGNORE=ignore Optional list of tags to be ignored.
;           List may be a text array or in a string like 'A B C'.
;         /NOCOMMENTS means do not incude RES file comments in
;           returned structure.
;         /NOARRAYS means do not include any arrays in returned
;           structure.
;         /ARRAYS_ONLY means include only arrays in returned
;           structure. Still can ignore specified tags.
;         INCLUDE=include Optional list of tags to include.
;           Useful to include some arrays when /NOARRAYS is used, or
;           to include some non-arrays when /ARRAYS_ONLY is used.
;           List may be a text array or in a string like 'A B C'.
;         ERROR=err error flag: 0=ok.
; OUTPUTS:
;       struct = returned structure. out
; COMMON BLOCKS:
; NOTES:
;       Notes: Comments are included in tags named
;         _comm001, _comm002, ... where number of digits
;         depends on length res file header.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 20
;       R. Sterner, 2004 Jun 28 --- Fixed ndig calculation.
;       R. Sterner, 2004 Jun 28 --- Fixed to allow overwrite if 0.
;       R. Sterner, 2004 Sep 23 --- Added keyword IGNORE.
;       R. Sterner, 2004 Sep 27 --- Dropped overwrite check.
;       R. Sterner, 2004 Oct 11 --- Fixed to not read ignored items.
;       R. Sterner, 2004 Oct 11 --- Added keywords /NOARRAY, /ARRAYS
;       R. Sterner, 2004 Oct 12 --- Comments with = were broke, fixed.
;       R. Sterner, 2005 May 06 --- Added keyword INCLUDE.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro res_to_struct, resfile, s, error=err, $
	  nocomments=nocom, noarrays=noarr, arrays_only=arr_only, $
	  ignore=ignore0, include=include0, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Read a RES file into a structure.'
	  print,' res_to_struct, resfile, struct'
	  print,'   resfile = name of RES file.  in'
	  print,'   struct = returned structure. out'
	  print,' Keywords:'
	  print,'   IGNORE=ignore Optional list of tags to be ignored.'
	  print,"     List may be a text array or in a string like 'A B C'."
	  print,'   /NOCOMMENTS means do not incude RES file comments in'
	  print,'     returned structure.'
	  print,'   /NOARRAYS means do not include any arrays in returned'
	  print,'     structure.'
	  print,'   /ARRAYS_ONLY means include only arrays in returned'
	  print,'     structure. Still can ignore specified tags.'
	  print,'   INCLUDE=include Optional list of tags to include.'
	  print,'     Useful to include some arrays when /NOARRAYS is used, or'
	  print,'     to include some non-arrays when /ARRAYS_ONLY is used.'
	  print,"     List may be a text array or in a string like 'A B C'."
	  print,'   ERROR=err error flag: 0=ok.'
	  print,' Notes: Comments are included in tags named'
	  print,'   _comm001, _comm002, ... where number of digits'
	  print,'   depends on length res file header.'
	  return
	endif
 
	;--------------------------------------------------------
	;  Open RES file
	;--------------------------------------------------------
	resopen,resfile,err=err,header=h
	if err ne 0 then return
 
	;--------------------------------------------------------
	;  Set ignore list flag
	;--------------------------------------------------------
	if n_elements(ignore0) gt 0 then begin		; Any items to ignore?
	  iflag = 1					; Yes.
	  wordarray,ignore0,ignore			; Allow a string. 
	  ignore = strupcase(ignore)			; Ignore list in caps.
	endif else iflag=0				; No ignored items.
 
	;--------------------------------------------------------
	;  Make sure include list exists
	;--------------------------------------------------------
	if n_elements(include0) gt 0 then begin		; Any items to include?
	  wordarray,include0,include			; Allow a string. 
	  include = strupcase(include)			; Include list in caps.
	endif else include=['']				; Null list.
 
	;--------------------------------------------------------
	;  Set up to deal with any RES file comments
	;--------------------------------------------------------
	c1 = strmid(h,0,1)				; Grab first char.
	w = where(c1 eq '*',cnt)			; Get # comments.
	ndig = strtrim(ceil(alog10(1+cnt)),2)		; Digits in comments.
	fmt = '(I'+ndig+'.'+ndig+')'			; Format for digits.
	ccnt = -1					; Comments counter.
	cmt = '_COMM'					; Comment front.
 
	;--------------------------------------------------------
	;  Loop through header entries
	;--------------------------------------------------------
	new_flag = 1					; Structure starts new.
	n = n_elements(h)-1				; # lines in header.
 
	for i=0,n-1 do begin				; Loop thru all lines.
	  tag = getwrd(h(i),del='=')			; Tag for next item.
	  if strmid(tag,0,1) eq '*' then is_cmt=1 $	; Check if comment.
	    else is_cmt=0
	  if getwrd(h(i),1) eq '==' then is_arr=1 $	; Check if array.
	    else is_arr=0
	  ;-----------------------------------------------------
	  ;  Comment
	  ;-----------------------------------------------------
	  if is_cmt then begin				; Deal with a comment.
	    if keyword_set(nocom) then continue		; Ignore.
	    ccnt = ccnt + 1				; Comment counter.
	    val = strmid(h(i),1,999)			; Drop leading *.
	    tag = cmt+string(ccnt,form=fmt)		; Make structure tag.
	  endif
	  ;-----------------------------------------------------
	  ;  Arrays
	  ;
	  ;  If item IS AN ARRAY then check if arrays are to be
	  ;  excluded.  If so then ignore item unless it is on
	  ;  the include list.
	  ;
	  ;  If item IS NOT AN ARRAY then check if only arrays
	  ;  are to be included. If so ignore item unless it is
	  ;  on the include list.
	  ;-----------------------------------------------------
	  if is_arr then begin				; Item is an array.
	    if keyword_set(noarr) then begin		; But don't want arrays.
	      w = where(strupcase(tag) eq include,cnt)	; Include this tag?
	      if cnt eq 0 then continue			;   No.
	    endif
	  endif
	  if not is_arr then begin			; Item is not an array.
	    if keyword_set(arr_only) then begin		; But want only arrays.
	      w = where(strupcase(tag) eq include,cnt)	; Include this tag?
	      if cnt eq 0 then continue			;   No.
	    endif
	  endif
	  ;-----------------------------------------------------
	  ;  Ignore specified tags
	  ;-----------------------------------------------------
	  if iflag then begin				; Any ignore list?
	    w = where(strupcase(tag) eq ignore,cnt)	; Ignore this tag?
	    if cnt gt 0 then continue			; If so skip next.
	  endif
	  ;-----------------------------------------------------
	  ;  Add res file tag to structure
	  ;-----------------------------------------------------
	  resget,tag,val				; Grab i'th file item.
	  if new_flag then begin			; Create structure.
	    s = create_struct(tag,val)			;   First time only.
	    new_flag = 0				; No longer new.
	  endif else begin
	    s = create_struct(s,tag,val)		; Add new item.
	  endelse
 
	endfor						; Continue jumps here.
 
	resclose
 
	end
