;-------------------------------------------------------------
;+
; NAME:
;       TXT_KEYSECTION
; PURPOSE:
;       Extract a section of a text array between given keys.
; CATEGORY:
; CALLING SEQUENCE:
;       txtkeysection, txt
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         AFTER=k1  Section to extract starts after this key.
;         BEFORE=k2 Section to extract ends before this key.
;           A key is text that matches an element of txt.
;         /MATCH_CASE means match case, else case is ignored.
;         /INVERSE  Return all lines but the section between
;           the AFTER and BEFORE keys (keys not included).
;         COUNT=cnt Number of elements returned.
;         /QUIET inhibit some error messages.
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
;       txt = Text array to modify.        in, out
; COMMON BLOCKS:
; NOTES:
;       Notes: The text array txt is modified if the given
;       keys are found.  An example.  Let txt be:
;         Line 1
;         Line 2
;         Line 3
;         <windows_start>
;         Line 4
;         Line 5
;         Line 6
;         <windows_end>
;         Line 7
;       txt_keysection,txt,after='<windows_start>', $
;         before='<windows_end>'
;         Returns lines 4,5,6.
;       txt_keysection,txt,after='<windows_start>', $
;         before='<windows_end>',/inverse
;         Returns lines 1,2,3,7.
;       Error in txt_keysection: Must give AFTER key.
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Sep 06
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro txt_keysection, txt, after=k1, before=k2, match_case=mcase, $
	  inverse=inv, error=err, count=cnt, quiet=quiet, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Extract a section of a text array between given keys.'
	  print,' txtkeysection, txt'
	  print,'   txt = Text array to modify.        in, out'
	  print,' Keywords:'
	  print,'   AFTER=k1  Section to extract starts after this key.'
	  print,'   BEFORE=k2 Section to extract ends before this key.'
	  print,'     A key is text that matches an element of txt.'
	  print,'   /MATCH_CASE means match case, else case is ignored.'
	  print,'   /INVERSE  Return all lines but the section between'
	  print,'     the AFTER and BEFORE keys (keys not included).'
	  print,'   COUNT=cnt Number of elements returned.'
	  print,'   /QUIET inhibit some error messages.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Notes: The text array txt is modified if the given'
	  print,' keys are found.  An example.  Let txt be:'
	  print,'   Line 1'
	  print,'   Line 2'
	  print,'   Line 3'
	  print,'   <windows_start>'
	  print,'   Line 4'
	  print,'   Line 5'
	  print,'   Line 6'
	  print,'   <windows_end>'
	  print,'   Line 7'
	  print," txt_keysection,txt,after='<windows_start>', $"
	  print,"   before='<windows_end>'"
	  print,'   Returns lines 4,5,6.'
	  print," txt_keysection,txt,after='<windows_start>', $"
	  print,"   before='<windows_end>',/inverse"
	  print,'   Returns lines 1,2,3,7.'
	  return
	end
 
	;------------------------------------------------------------
	;  Check for needed parameters
	;------------------------------------------------------------
	err = 0
	cnt = 0
	if n_elements(k1) eq 0 then begin
	  print,' Error in txt_keysection: Must give AFTER key.'
	  err = 1
	  return
	endif
	if n_elements(k2) eq 0 then begin
	  print,' Error in txt_keysection: Must give BEFORE key.'
	  err = 1
	  return
	endif
 
	;------------------------------------------------------------
	;  Deal with case
	;------------------------------------------------------------
	if keyword_set(mcase) then begin
	  txt2 = strtrim(txt,2)
	  k12 = strtrim(k1,2)
	  k22 = strtrim(k2,2)
	endif else begin
	  txt2 = strtrim(strupcase(txt),2)
	  k12 = strtrim(strupcase(k1),2)
	  k22 = strtrim(strupcase(k2),2)
	endelse
 
	;------------------------------------------------------------
	;  Initialize
	;------------------------------------------------------------
	n = n_elements(txt)
	flag = bytarr(n)
 
	;------------------------------------------------------------
	;  Locate keys
	;------------------------------------------------------------
	w1 = (where(txt2 eq k12, c1))(0)
	if c1 eq 0 then begin
	  if not keyword_set(quiet) then $
	    print,' Error in txt_keysection: AFTER key not found.  Was '+k1
	  err = 1
	  return
	endif
	w2 = (where(txt2 eq k22, c2))(0)
	if c2 eq 0 then begin
	  if not keyword_set(quiet) then $
	    print,' Error in txt_keysection: BEFORE key not found.  Was '+k2
	  err = 1
	  return
	endif
 
	;------------------------------------------------------------
	;  Flag and extract requested section
	;------------------------------------------------------------
	if keyword_set(inv) then begin
	  flag(w1:w2) = 1
	  w = where(flag ne 1, cnt)
	  if cnt eq 0 then begin
	    txt = ''
	  endif else begin
	    txt = txt(w)
	  endelse
	endif else begin
	  lo = w1+1
	  hi = w2-1
	  if lo gt hi then begin
	    err = 1
	    cnt = 0
	    txt = ''
	    return
	  endif
	  flag(lo:hi) = 1
	  w = where(flag eq 1, cnt)
	  txt = txt(w)
	endelse
 
	return
 
	end
