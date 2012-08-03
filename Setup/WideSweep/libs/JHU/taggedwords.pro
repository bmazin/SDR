;-------------------------------------------------------------
;+
; NAME:
;       TAGGEDWORDS
; PURPOSE:
;       Extract and returned words tagged with a specified symbol.
; CATEGORY:
; CALLING SEQUENCE:
;       taggedwords, txt, tw
; INPUTS:
;       txt = Input text string.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         TAG=tag Special symbol at front of tagged words (def='#').
;         /REMOVE Remove tags from words in txt.
;         /UNIQUE Only return one occurence of each tagged word.
;         COUNT=ntag Optionally returned number of tagged words.
;           Useful as an error flag, 0 means no tags found.
; OUTPUTS:
;       tw = Returned array of tagged words. out
; COMMON BLOCKS:
; NOTES:
;       Notes: Words are tagged by putting a special symbol at
;       their front, like #cat, #dog, ...  Multiple groups of tagged
;       words may be handled by using different tags:
;       #cat, $fish, #dog, $bird.  Each group may then be accessed
;       independently.  The tagged words may be names of variables.
;       In that case the /REMOVE keyword can be used to remove the
;       tags from the string after finding the list of tagged words.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 May 13
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro taggedwords, txt, tw, count=ntag, tag=tag, $
	  remove=rem, unique=unique, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Extract and returned words tagged with a specified symbol.'
	  print,' taggedwords, txt, tw'
	  print,'   txt = Input text string.             in'
	  print,'   tw = Returned array of tagged words. out'
	  print,' Keywords:'
	  print,"   TAG=tag Special symbol at front of tagged words (def='#')."
	  print,'   /REMOVE Remove tags from words in txt.'
	  print,'   /UNIQUE Only return one occurence of each tagged word.'
	  print,'   COUNT=ntag Optionally returned number of tagged words.'
	  print,'     Useful as an error flag, 0 means no tags found.'
	  print,' Notes: Words are tagged by putting a special symbol at'
	  print,' their front, like #cat, #dog, ...  Multiple groups of tagged'
	  print,' words may be handled by using different tags:'
	  print,' #cat, $fish, #dog, $bird.  Each group may then be accessed'
	  print,' independently.  The tagged words may be names of variables.'
	  print,' In that case the /REMOVE keyword can be used to remove the'
	  print,' tags from the string after finding the list of tagged words.'
	  return
	endif
 
	;-------------------------------------------------------
	;  Locate tags
	;-------------------------------------------------------
	if n_elements(tag) eq 0 then tag='#'	; Default tag.
	ch = (byte(tag))(0)			; Ascii of tag.
	b = byte(txt)				; Ascii of text string.
	wtag = where(b eq ch,ntag)		; Count tags.
	if ntag eq 0 then return
	if keyword_set(rem) then $
	  txt=stress(txt,'D',0,tag)		; Remove tags from string.
 
	;-------------------------------------------------------
	;  Grab tagged words after blanking special characters
	;
	;  Blank any characters other than:
	;    0-9, A-Z, a-z.
	;-------------------------------------------------------
	w = where(b lt 48,cnt)			; Chars before 0.
	if cnt gt 0 then b(w) = 32B		; Blank them.
	w = where((b gt 57) and (b lt 65),cnt)	; Chars between 9 and A.
	if cnt gt 0 then b(w) = 32B		; Blank them.
	w = where((b gt 90) and (b lt 97),cnt)	; Chars between Z and a.
	if cnt gt 0 then b(w) = 32B		; Blank them.
	w = where(b gt 122,cnt)			; Chars after z.
	if cnt gt 0 then b(w) = 32B		; Blank them.
 
	t2 = string(b)				; Edited string.
	tw = strarr(ntag)			; Space for names.
	for i=0,ntag-1 do begin			; Loop through tagged words.
	  tmp = strmid(t2,wtag(i)+1,99)		; Grab from word start on.
	  tw(i) = getwrd(tmp)			; Grab up to next space.
	endfor
 
	;-------------------------------------------------------
	;  Deal with unique tagged words
	;-------------------------------------------------------
	if not keyword_set(unique) then return
	ss = tw(sort(tw))			; Sort word list.
	tw = ss(uniq(ss))			; Keep only unique words.
	ntag = n_elements(tw)			; Update count.
 
	end
