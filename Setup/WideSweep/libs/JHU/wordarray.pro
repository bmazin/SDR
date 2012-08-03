;-------------------------------------------------------------
;+
; NAME:
;       WORDARRAY
; PURPOSE:
;       Convert text string or string array to 1-d array of words.
; CATEGORY:
; CALLING SEQUENCE:
;       wordarray, instring, outlist
; INPUTS:
;       instring = string or string array to process.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         IGNORE=string of characters to ignore (array allowed).
;           These characters are removed before processing.
;           Ex: wordarray,in,out,ignore=',;()'
;               wordarray,in,out,ignore=[',',';','(',')']
;         DELIMITERS = word delimiter characters, like IGNORE.
;         /WHITE means include white space (spaces,tabs) along
;           with the specified delimiters.
;         NUMBER=num Number of elements in returned array.
; OUTPUTS:
;       outlist = 1-d array of words in instring.      out
; COMMON BLOCKS:
; NOTES:
;       Notes: Words are assumed delimited by given delimiters
;        (defaults are spaces and/or tabs)
;        Non-delimiters are returned as part of the words.
;        Delimiters not needed at the front and end of the strings.
;        See commalist for a near inverse.
; MODIFICATION HISTORY:
;       R. Sterner, 29 Nov, 1989
;       BLG --- Modified June 22,1991 to include tabs as delimiters
;       R. Sterner, 11 Dec, 1992 --- fixed to handle pure white space.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       R. Sterner, 1998 Apr 1 --- Added DELIMITER.  Modified IGNORE.
;       R. Sterner, 1998 Jul 31 --- Added NUMBER=nwds.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro wordarray, in, out, ignore=ign, delimiters=del, $
	  white=white, number=nwds, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert text string or string array to 1-d array of words.'
	  print,' wordarray, instring, outlist'
	  print,'   instring = string or string array to process.  in'
	  print,'   outlist = 1-d array of words in instring.      out'
	  print,' Keywords:'
	  print,'   IGNORE=string of characters to ignore (array allowed).'
	  print,'     These characters are removed before processing.'
	  print,"     Ex: wordarray,in,out,ignore=',;()'"
	  print,"         wordarray,in,out,ignore=[',',';','(',')']"
	  print,'   DELIMITERS = word delimiter characters, like IGNORE.'
	  print,'   /WHITE means include white space (spaces,tabs) along'
	  print,'     with the specified delimiters.'
	  print,'   NUMBER=num Number of elements in returned array.'
	  print,' Notes: Words are assumed delimited by given delimiters'
	  print,'  (defaults are spaces and/or tabs)'
	  print,'  Non-delimiters are returned as part of the words.'
	  print,'  Delimiters not needed at the front and end of the strings.' 
	  print,'  See commalist for a near inverse.'
	  return
	endif
 
	;-----  Deal with characters to ignore  --------
	nig = n_elements(ign)
	ign2 = ''
	if nig gt 0 then for i=0,nig-1 do ign2=ign2+ign(i)  ; Want 1 string.
	bign2 = byte(ign2)				    ; As byte array.
 
	;-----  Deal with delimiters  -------------
	ndl = n_elements(del)
	if ndl eq 0 then bdel2=[9B,32B]		; Default is Tab and Space.
	if ndl gt 0 then begin
	  del2 = ''
	  if ndl gt 0 then for i=0,ndl-1 do del2=del2+del(i)  ; Want 1 string.
	  bdel2 = byte(del2)				    ; As byte array.
	  if keyword_set(white) then bdel2=[bdel2,9B,32B]   ; Add white space.
	endif
 
	;------  Set up a marker characters (CTR-A, CTR-B)  --------
	mrk  = 1B		; Marker character for delimiters.
	mrk2 = 2B		; Marker character for ignore.
	smrk  = string(mrk)	; Same as a string.
 
	;------  Mark ends of lines  ---------
	t = smrk + in + smrk		; Force delimiters on ends
 
	;------  Convert to byte array and ignore line breaks  -----
	b = byte(t)			; Convert to byte array.
	w = where(b ne 0, count)	; Find non-null chars.
	if count gt 0 then b = b(w)	; Extract non-null characters.
 
	;------  Deal with characters to be ignored  --------------
	for i=0,n_elements(bign2)-1 do begin	; Loop through chars to ignore.
	  w = where(b eq bign2(i), c)	; Look for i'th one.
	  if c gt 0 then b(w)=mrk2	; Mark any found.
	endfor
	w = where(b ne mrk2, c)		; Any ignore marks?
	if c gt 0 then b=b(w)		; Yes, drop them.
 
	;------  Deal with word delimiters  ----------------------
        for i=0,n_elements(bdel2)-1 do begin	; Loop through delimiter chars.
          w = where(b eq bdel2(i), c)   ; Look for i'th one.
          if c gt 0 then b(w)=mrk       ; Mark any found.
        endfor
 
	;------  Look for non-delimiter characters  ------------
	x = b ne mrk			; non-delimiter chars.
	x = [0,x,0]			; tack 0s at ends.
	if total(x) eq 0 then begin	; All white space.
	  out = ''
	  return
	endif
 
	;-------  Find word/noon-word transitions  -------------
	y = (x-shift(x,1)) eq 1		; Look for transitions.
	z = where(shift(y,-1) eq 1)
	y2 = (x-shift(x,-1)) eq 1
	z2 = where(shift(y2,1) eq 1)
 
	;--------  Word number, locations, and lengths  --------
	nwds = total(y)			; Total words in IN.
	loc = z				; Word start positions.
	len = z2 - z - 1		; Word lengths.
 
	;--------  Setup and fill in output array  ------------
	out = bytarr(max(len), nwds)	; Set up output array.
	if nwds gt 1 then begin
	  for i = 0L, nwds-1L do begin
	    out(0,i) = b(loc(i):(loc(i)+len(i)-1L))
	  endfor
	  out = string(out)
	endif else begin
	  out(0) = b(loc(0):(loc(0)+len(0)-1L))
	  out = string(out)
	endelse
 
	return
 
	end
