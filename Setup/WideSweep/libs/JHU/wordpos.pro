;-------------------------------------------------------------
;+
; NAME:
;       WORDPOS
; PURPOSE:
;       Find position of a word in a string.
; CATEGORY:
; CALLING SEQUENCE:
;       pos = wordpos( ref, wd, st)
; INPUTS:
;       ref = reference string to search.    in
;       wd = word to find.                   in
;       st = optional search start (def=0).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         MAX=mx Max search position (def=end of string).
;         /CHAR  Positions are character positions (from
;            0=first char), else word numbers (0=first word).
;         OFFSET=off  Word offset.  Off=0 means wd, off=1 means
;           the word after wd, off=-1 means the word before wd, ...
;         /IGNORE_CASE means ignore case.
; OUTPUTS:
;       pos = Position where wd was found.   out
;         pos = -1 if wd not found in ref.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Mar 25
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function wordpos, ref0, wd0, s1, max=s2, offset=off, char=char, $
	  ignore_case=ig, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find position of a word in a string.'
	  print,' pos = wordpos( ref, wd, st)'
	  print,'   ref = reference string to search.    in'
	  print,'   wd = word to find.                   in'
	  print,'   st = optional search start (def=0).  in'
	  print,'   pos = Position where wd was found.   out'
	  print,'     pos = -1 if wd not found in ref.'
	  print,' Keywords:'
	  print,'   MAX=mx Max search position (def=end of string).'
	  print,'   /CHAR  Positions are character positions (from'
	  print,'      0=first char), else word numbers (0=first word).'
	  print,'   OFFSET=off  Word offset.  Off=0 means wd, off=1 means'
	  print,'     the word after wd, off=-1 means the word before wd, ...'
	  print,'   /IGNORE_CASE means ignore case.'
	  return,''
	endif
 
	;------  Null strings  --------------------------------
	if ref0 eq '' then return, -1
	if wd0 eq '' then return, -1
 
	;------  Copy strings  --------------------------------
	if keyword_set(ig) then begin
	  ref = strlowcase(ref0)
	  wd = strlowcase(wd0)
	endif else begin
	  ref = ref0
	  wd = wd0
	endelse
	wd = strtrim(wd,2)	; Drop any spaces (working with words).
 
	;------  Find parts of reference string  --------------
	fndwrd, ref, nwrds, loc, len		; Word positions and lengths.
	ind = indgen(nwrds)			; Word index into ref.
 
	;-------  Defaults  -------------------
	flag = 1				; Position flag: 0=char, 1=word.
	if keyword_set(char) then flag=0
	if n_elements(s1) eq 0 then s1=0	; Search start.
	if n_elements(s2) eq 0 then begin
	  if flag eq 0 then s2=strlen(ref)-1 else s2=nwrds-1
	endif
	if n_elements(off) eq 0 then off=0		; Word offset.
 
	;--------  Work in char position  -------
	if flag eq 0 then begin
	  p1 = s1
	  p2 = s2
	endif else begin
	  if (s1 ge n_elements(loc)) or (s1 lt 0) then return,-1
	  if (s2 ge n_elements(loc)) or (s2 lt 0) then return,-1
	  p1 = loc(s1)
	  p2 = loc(s2)
	endelse
	
	;-------  Restrict arrays to search region  ---------
	w = where((loc ge p1) and (loc le p2), cnt)
	if cnt eq 0 then return, -1	; None.
	loc2 = loc(w)
	len2 = len(w)
	ind2 = ind(w)
	nwrds2 = cnt
 
	;----  Further restrict the search to words of the correct length  ----
	lenwd = strlen(wd)
	w = where(len2 eq lenwd, cnt)
	if cnt eq 0 then return, -1	; None.
	loc2 = loc2(w)
	len2 = len2(w)
	ind2 = ind2(w)
	nwrds2 = cnt
 
	;-------  Now check for first exact match  -----------
	for i=0, cnt-1 do begin
	  if strmid(ref,loc2(i),len2(i)) eq wd then begin  ; Match.
	    inw = ind2(i) + off				; Word index.
	    if inw lt 0 then return, -1			; Out of range.
	    if inw ge nwrds then return, -1		; Out of range.
	    if keyword_set(char) then return,loc(inw) else return,inw
	  endif
	endfor
	return, -1			; None.
 
	end
