;-------------------------------------------------------------
;+
; NAME:
;       GETWRD
; PURPOSE:
;       Return the n'th word from a text string.
; CATEGORY:
; CALLING SEQUENCE:
;       wrd = getwrd(txt, n, [m])
; INPUTS:
;       txt = text string to extract from.         in
;         The first element is used if txt is an array.
;       n = word number to get (first = 0 = def).  in
;       m = optional last word number to get.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         LOCATION = l.  Return word n string location.
;         DELIMITER = d. Set word delimiter (def = space & tab).
;         /LAST means n is offset from last word.  So n=0 gives
;           last word, n=-1 gives next to last, ...
;           If n=-2 and m=0 then last 3 words are returned.
;         /NOTRIM suppresses whitespace trimming on ends.
;         NWORDS=n.  Returns number of words in string.
; OUTPUTS:
;       wrd = returned word or words.              out
; COMMON BLOCKS:
;       getwrd_com
; NOTES:
;       Note: If a NULL string is given (txt="") then the last string
;             given is used.  This saves finding the words again.
;             If m > n wrd will be a string of words from word n to
;             word m.  If no m is given wrd will be a single word.
;             n<0 returns text starting at word abs(n) to string end
;             If n is out of range then a null string is returned.
;             See also nwrds.
; MODIFICATION HISTORY:
;       Ray Sterner,  6 Jan, 1985.
;       R. Sterner, Fall 1989 --- converted to SUN.
;       R. Sterner, Jan 1990 --- added delimiter.
;       R. Sterner, 18 Mar, 1990 --- added /LAST.
;       R. Sterner, 31 Jan, 1991 --- added /NOTRIM.
;       R. Sterner, 20 May, 1991 --- Added common and NULL string.
;       R. Sterner, 13 Dec, 1992 --- Made tabs equivalent to spaces.
;       R. Sterner,  4 Jan, 1993 --- Added NWORDS keyword.
;       R. Sterner, 2001 Jan 15 --- Fixed to use first element if not a scalar.
;       R. Sterner, 2006 Mar 07 --- Added /KEEP_LEADING_DEL, /KEEP_TRAILING_DEL.
;       Also cleaned up some.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	FUNCTION GETWRD, TXTSTR, NTH, MTH, help=hlp, location=ll,$
	   delimiter=delim, notrim=notrim, last=last, nwords=nwords, $
	   keep_leading_del=keep_lead, keep_trailing_del=keep_trail
 
	common getwrd_com, txtstr0, nwds, loc, len, ddel, pre, post
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print," Return the n'th word from a text string."
	  print,' wrd = getwrd(txt, n, [m])'
	  print,'   txt = text string to extract from.         in'
	  print,'     The first element is used if txt is an array.'
	  print,'   n = word number to get (first = 0 = def).  in'
	  print,'   m = optional last word number to get.      in'
	  print,'   wrd = returned word or words.              out'
	  print,' Keywords:'
	  print,'   LOCATION = l.  Return word n string location.'
	  print,'   DELIMITER = d. Set word delimiter (def = space & tab).'
	  print,'   /LAST means n is offset from last word.  So n=0 gives'
	  print,'     last word, n=-1 gives next to last, ...'
	  print,'     If n=-2 and m=0 then last 3 words are returned.'
	  print,'   /NOTRIM suppresses whitespace trimming on ends.'
	  print,'   NWORDS=n.  Returns number of words in string.'
	  print,'Note: If a NULL string is given (txt="") then the last string'
	  print,'      given is used.  This saves finding the words again.'
	  print,'      If m > n wrd will be a string of words from word n to'
	  print,'      word m.  If no m is given wrd will be a single word.'
	  print,'      n<0 returns text starting at word abs(n) to string end'
	  print,'      If n is out of range then a null string is returned.'
	  print,'      See also nwrds.'
	  return, -1
	endif
 
	;-------------------------------------
	;  Defaults
	;-------------------------------------
	if n_params(0) lt 2 then nth = 0		; Def is first word.
	if n_params(0) lt 3 then mth = nth		; Def is one word.
 
	;-------------------------------------
	;  Initialize
	;-------------------------------------
	if strlen(txtstr(0)) gt 0 then begin		; Non-null arg.
	  ddel = ' '					; Def del is a space.
	  if n_elements(delim) ne 0 then ddel = delim	; Use given delimiter.
	  tst = (byte(ddel))(0)				; Del to byte value.
	  tb = byte(txtstr(0))				; String to bytes.
	  if ddel eq ' ' then begin		        ; Check for tabs?
	    w = where(tb eq 9B, cnt)			; Yes.
	    if cnt gt 0 then tb(w) = 32B		; Convert any to space.
	  endif
	  x = tb NE tst					; Non-delchar (=words).
	  x = [0,X,0]					; 0s at ends.
 
	  Y = (x-shift(x,1)) eq 1			; Diff=1: word start.
	  z = where(shift(y,-1) eq 1)			; Word start locations.
	  y2 = (x-shift(x,-1)) eq 1			; Diff=1: word end.
	  z2 = where(shift(y2,1) eq 1)			; Word end locations.
 
	  txtstr0 = txtstr(0)				; Move string to common.
	  nwds = LONG(total(y))				; Number of words.
	  loc = z					; Word start locations.
	  len = z2 - z - 1				; Word lengths.
	
	  ;-----  Deal with /keep_* keywords ----- 
	  pre = ''					; Prefix.
	  post = ''					; Postfix.
	  if strmid(txtstr0,0,1) eq ddel then pre=ddel	; Leading delimiter?
	  if strmid(txtstr0,strlen(txtstr0)-1,1) $	; Trailing delimiter?
	    eq ddel then post=ddel
	endif else begin
	  if n_elements(nwds) eq 0 then begin		; Check if first call.
	    print,' Error in getwrd: must give a '+$
	      'non-NULL string on the first call.'
	    return, -1					; -1 = error flag.
	  endif
	endelse
 
	nwords = nwds					; Set nwords
 
	;-------------------------------------
	;  Offset from last word
	;-------------------------------------
	if keyword_set(last) then begin			; Offset from last.
	  lst = nwds - 1
	  in = lst + nth				; Nth word.
	  im = lst + mth				; Mth word.
	  if (in lt 0) and (im lt 0) then return, ''	; Out of range.
	  in = in > 0					; Smaller of in and im
	  im = im > 0					;  to zero.
	  if (in gt lst) and (im gt lst) then return,'' ; Out of range.
	  in = in < lst					; Larger of in and im
	  im = im < lst					;  to be last.
	  ll = loc(in)					; Nth word start.
	  out = strmid(txtstr0,ll,loc(im)-loc(in)+len(im))
	  ;-----  Deal with /keep_* keywords ----- 
	  if in gt 0 then pre2=ddel else pre2=pre	; Not at first word.
	  if im lt lst then post2=ddel else post2=post	; Not at last word.
	  if keyword_set(keep_lead) then out=pre2+out
	  if keyword_set(keep_trail) then out=out+post2
	  if keyword_set(notrim) then return, out
	  return, strtrim(out,2)
	endif
 
	;-------------------------------------
	;  Offset from first word
	;-------------------------------------
	n = abs(nth)					; Allow nth<0.
	if n gt nwds-1 then return,''			; out of range, null.
	ll = loc(n)					; N'th word position.
	mth = mth<(nwds-1)				; Words to end.
	if nth lt 0 then begin				; Handle nth<0.
	  out = strmid(txtstr0,ll,9999)
	endif else begin				; nth=>0
	  out = strmid(txtstr0,LL,loc(mth)-loc(nth)+len(mth))
	endelse
	;-----  Deal with /keep_* keywords ----- 
	if n gt 0 then pre2=ddel else pre2=pre		; Not at first word.
	if mth lt (nwds-1) then post2=ddel else post2=post ; Not at last word.
	if keyword_set(keep_lead) then out=pre2+out
	if keyword_set(keep_trail) then out=out+post2
	if keyword_set(notrim) then return, out
	return, strtrim(out,2)
 
	end
