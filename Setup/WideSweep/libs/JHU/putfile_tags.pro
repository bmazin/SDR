;-------------------------------------------------------------
;+
; NAME:
;       PUTFILE_TAGS
; PURPOSE:
;       Update selected tags in a control/defaults file.
; CATEGORY:
; CALLING SEQUENCE:
;       putfile_tags, file, tags
; INPUTS:
;       file = name of control/defaults file.       in
;         May also be a text array as if from file.
;       tags = structure with tags to update.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err Error flag: 0=ok.
;         /ADD add any tags new to the file (else ignore).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Only updates tags found in the tags structure
;         with the values found there.  If a tag in the given
;         structure does not occur in the file it is ignored
;         by default.  Use /ADD to add them to the end of
;         the file.  Any other text in the file is not changed.
;         If the file does not exist it will be created.  Make
;         sure to use /ADD to add tags to the new file.
;         See getfile_tags for reading tags from a text file.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Apr 14
;       R. Sterner, 2006 Apr 17 --- Modified to create file if not there.
;       R. Sterner, 2006 Jun 19 --- Added note pointing to getfile_tags.
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro putfile_tags_front, in, out, err=err
 
	p = strpos(in,'=')		; Find =.
	if p lt 0 then begin		; Wasn't one.
	  err = 1			; Not good.
	  return
	endif
 
	b = byte(strmid(in, p+1, 999))	; Look for white space.
	w = where((b ne 9B) and (b ne 32B), cnt) ; Next non-tab, non-space.
	len = p + w(0) + 1		; Length of front end.
	err = 0
	out = strmid(in,0,len)		; Grab front.
 
	end
 
 
	;-------------------------------------------------
	;  Main routine
	;-------------------------------------------------
	pro putfile_tags, file, tags, error=err, add=add, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Update selected tags in a control/defaults file.'
	  print,' putfile_tags, file, tags'
	  print,'   file = name of control/defaults file.       in'
	  print,'     May also be a text array as if from file.'
	  print,'   tags = structure with tags to update.       in'
	  print,' Keywords:'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,'   /ADD add any tags new to the file (else ignore).'
	  print,' Notes: Only updates tags found in the tags structure'
	  print,'   with the values found there.  If a tag in the given'
	  print,'   structure does not occur in the file it is ignored'
	  print,'   by default.  Use /ADD to add them to the end of'
	  print,'   the file.  Any other text in the file is not changed.'
	  print,'   If the file does not exist it will be created.  Make'
	  print,'   sure to use /ADD to add tags to the new file.'
	  print,'   See getfile_tags for reading tags from a text file.'
	  return
	endif
 
	;-------------------------------------------------
	;  Read file into a string array
	;-------------------------------------------------
	if n_elements(file) gt 1 then begin
	  t = file
	endif else begin
	  t = getfile(file,err=err)		; Read file into string array.
;	  if err ne 0 then return		; If error quit.
	endelse
	strfind,t,'=',index=in,/quiet,count=cnt	; Find lines .
	if cnt gt 0 then begin
	  t2 = drop_comments(t(in),index=in2)	; Find tag=val lines.
	  ind = in(in2)				; Indices in t of tag=val lines.
	  n0 = n_elements(ind)			; Number of file tag=val lines.
	  tag0 = strarr(n0)			; Array for all tags in file.
	  for i=0,n0-1 do tag0(i)=getwrd(t2(i),del='=')	; Grab all tags.
	  tag0 = strupcase(tag0)		; Force upper case.
	endif else begin
	  n0 = 0				; No tag=val lines.
	  tag0 = ''				; Null string.
	endelse
 
	;-------------------------------------------------
	;  Find tags to update
	;-------------------------------------------------
	taglist = tag_names(tags)		; List of tags to update.
	n = n_elements(taglist)			; Number tags to update.
 
	;-------------------------------------------------
	;  Update tags in file
	;-------------------------------------------------
	for i=0,n-1 do begin			; Loop through tags to update.
	  tagu = taglist(i)			; Tag to update.
	  w = where(tag0 eq tagu, cnt)		; Locate in file.
	  j = w(0)				; Index where matched.
	  val = tags.(i)			; New value.
	  dtyp = datatype(val)			; Type dependent precision.
          if dtyp eq 'BYT' then val = fix(val)  ; Scalar byte -> int.
          if dtyp eq 'FLO' then val = string(val,form='(G16.8)')
          if dtyp eq 'DOU' then val = string(val,form='(G26.17)')
	  val = strtrim(val,2)			; Final value.
	  if cnt gt 0 then begin		; Match actually found?
	    putfile_tags_front,t(ind(j)),out,err=err ; Grab front of line.
	    if err ne 0 then begin		; Had a problem:
	      out = tagu+' = '+val		;   Construct new line.
	    endif else begin			; Was ok:
	      out = out + val			;   Just replace value.
	    endelse
	    t(ind(j)) = out			; Update line.
	  endif else begin			; No match.
	    if keyword_set(add) then begin	; Add at end?
	      t = [t,tagu + ' = '+val]		; Yes.
	    endif
	  endelse ; cnt
	endfor ; i
 
	;-------------------------------------------------
	;  Save updated file
	;-------------------------------------------------
	if n_elements(file) eq 1 then begin	; Working with a file.
	  putfile, file, t			; Save updated version.
	endif else begin			; Working with text array.
	  file = t				; Return it.
	endelse
 
	end
