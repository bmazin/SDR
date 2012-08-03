;-------------------------------------------------------------
;+
; NAME:
;       FINDFILE3
; PURPOSE:
;       Find files and sort them.
; CATEGORY:
; CALLING SEQUENCE:
;       f = findfile3(pat)
; INPUTS:
;       pat = filename or wildcard pattern.   in
;             See notes below.
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=e error flag: 0=ok, 1=pattern error,
;           2=no files found.
;         /QUIET means do not display no files found message.
; OUTPUTS:
;       f = sorted array of found file names. out
; COMMON BLOCKS:
; NOTES:
;       Notes: The normal wildcard character that matches
;         anything is *.  Using this character implies that
;         no sort will be done.  Using $ in place of * means
;         sort on that field.  Using # in place of * means
;         first convert that field to a number, then sort on it.
;         The wild card characters $ and # may not both be used
;         together, but * may be used with either, but may not
;         be adjacent. Must use the correct case (upper for VMS)
;         The wildcard processing ability is limited.
; MODIFICATION HISTORY:
;       R. Sterner, 8 Jul, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function findfile3, pat, error=err, quiet=quiet, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find files and sort them.'
	  print,' f = findfile3(pat)'
	  print,'   pat = filename or wildcard pattern.   in'
	  print,'         See notes below.'
	  print,'   f = sorted array of found file names. out'
	  print,' Keywords:'
	  print,'   ERROR=e error flag: 0=ok, 1=pattern error,'
	  print,'     2=no files found.'
	  print,'   /QUIET means do not display no files found message.'
	  print,' Notes: The normal wildcard character that matches'
	  print,'   anything is *.  Using this character implies that'
	  print,'   no sort will be done.  Using $ in place of * means'
	  print,'   sort on that field.  Using # in place of * means'
	  print,'   first convert that field to a number, then sort on it.'
	  print,'   The wild card characters $ and # may not both be used'
	  print,'   together, but * may be used with either, but may not'
	  print,'   be adjacent. Must use the correct case (upper for VMS)'
	  print,'   The wildcard processing ability is limited.'
	  return, ''
	endif
 
	;------  Check pattern for special symbols  --------
	b1 = (byte('*'))(0)	; Look for normal wildcard.
	b2 = (byte('$'))(0)	; Look for sort wildcard.
	b3 = (byte('#'))(0)	; Look for numeric sort wildcard.
 
	w1 = where(byte(pat) eq b1, c1)	; Where are *s?
	w2 = where(byte(pat) eq b2, c2)	; Where are $s?
	wild = 0			; Assume wildcard at 0.
	if c2 gt 0 then wild = w2(0)	; Wildcard at $.
	w3 = where(byte(pat) eq b3, c3)	; Where are #s?
	if c3 gt 0 then wild = w3(0)	; Wildcard at #.
 
	if (c2+c3) gt 1 then begin
	  print,' Error in findfile3: file name pattern error.'
	  print,'   Pattern = '+pat
	  err = 1
	  return, ''
	endif
 
	;----  Allow wildcard patterns like ...*xxx$yyy*...
	;----  Pick off the strings xxx and yyy and use them
	;----  to find the string $ (or #). Adjacent wildcards
	;----  are not allowed: xxx*$yyy.
	wlt = where(w1 lt wild, clt)	; Allow multiple *s. *s before wild.
	wgt = where(w1 gt wild, cgt)	; *s after wild.
	if clt eq 0 then begin
	  wlt = [-1]			; Force something rational.
	endif else begin
	  wlt = w1(wlt)
	endelse
	if cgt eq 0 then begin
	  wgt = [999]
	endif else begin
	  wgt = w1(wgt)
	endelse
	front = strsub(pat,wlt(n_elements(wlt)-1)+1,wild-1) ; Front delim str.
	lfront = strlen(front)
	back = strsub(pat, wild+1, wgt(0)-1)	; Back delimiter string.
 
	;-------  modify special patterns  --------
	pat2 = pat
	if c2 gt 0 then pat2 = repchr(pat2,'$','*')
	if c3 gt 0 then pat2 = repchr(pat2,'#','*')
 
 
	;-------  Search for files  -----------
	f = findfile(pat2)			; Find files.
	if f(0) eq '' then begin		; Any found?
	  if not keyword_set(quiet) then print,' No files found.'
	  err=2
	  return, f				; Return null array.
	endif
 
	;------  Cut off directory  -----------
	nf = n_elements(f)
	vos = strupcase(!version.os)
	case vos of
'VMS':	  dd = ']'
'PCDOS':  dd = '\'
else:     begin
	    dd = '/'
	    ;----  Also get rid of unix recursive listing  -----
	    dir = dd+getwrd(f(0),delim=dd,-99,-1,/last)	; Get directory.
	    for i = 0, nf-1 do if strpos(f(i),dir) lt 0 then f(i)='#'
	    f = f(where(f ne '#'))
	    nf = n_elements(f)
	  end
	endcase
	for i = 0, nf-1 do f(i) = getwrd(f(i),delim=dd,/last)
	if vos eq 'VMS' then for i = 0, nf-1 do f(i) = getwrd(f(i),delim=';')
 
	;-------  Extract sort field  ----------
	if (c2 gt 0) or (c3 gt 0) then begin
	  stxt = strarr(nf)
	  for i = 0, nf-1 do begin
	    tmp = f(i)
	    p1 = strpos(tmp, front)
	    if back eq '' then begin
	      p2 = 99
	    endif else begin
	      p2 = strpos(tmp, back, p1+lfront)
	    endelse
	    stxt(i) = strsub(tmp,p1+lfront, p2-1)
	  endfor
	  if c2 gt 0 then begin
	    is = sort(stxt)
	  endif else begin
	    on_ioerror, trap
	    is = sort(stxt+0.)
	    on_ioerror, null
	  endelse
	  f = f(is)
	endif
 
	return, f				; Return files.
 
trap:	print,' Error in findfile3: Non-numeric sort field found'
	print,'   in a # wildcard field. Use the $ wildcard for'
	print,'   non-numeric fields.'
	err = 1
	return, ''
 
	end
