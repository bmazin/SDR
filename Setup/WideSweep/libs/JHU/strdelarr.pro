;-------------------------------------------------------------
;+
; NAME:
;       STRDELARR
; PURPOSE:
;       Convert a delimited byte array to string array.
; CATEGORY:
; CALLING SEQUENCE:
;       strdelarr, b, h
; INPUTS:
;       b = bytarr array with delimited entries.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         DELIMITER=del ASCII code of string delimiter (def=0).
;         /NONULL Do not return null strings.
; OUTPUTS:
;       h = string array with entries as elements.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Sep 07
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro strdelarr, b, h, delimiter=delim, nonull=nonull, help
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert a delimited byte array to string array.'
	  print,' strdelarr, b, h'
	  print,'   b = bytarr array with delimited entries.    in'
	  print,'   h = string array with entries as elements.  out'
	  print,' Keywords:'
	  print,'   DELIMITER=del ASCII code of string delimiter (def=0).'
	  print,'   /NONULL Do not return null strings.'
	  return
	endif
 
        ;----------  Convert byte array to a string array  ---------
        if n_elements(delim) eq 0 then delim=0  ; Lines use ascii 0 as delimtrs.
        w = where(b eq delim)   ; Find line breaks.
        n = n_elements(w)       ; How many?
        w = [-1,w]              ; This helps pick up first line.
	flag = string(200B)	; Flag value to ignore.
        h = strarr(n)+flag	; Set aside string array space.
	top = 0			; Top non-null.
 
        for i = 0L, n-1 do begin	; Loop through all possible strings.
          wlo = w(i)+1			; Start of text.
          whi = w(i+1)-1		; End of text.
	  df = whi-wlo
	  if keyword_set(nonull) and (df eq -1) then continue
          t = string(b(wlo:(whi>wlo)))	; Next string.
          h(i) = t			; Store it.
	  top = i
          if strupcase(strtrim(t,2)) eq 'END' then goto, next   ; Done?
        endfor
 
next:	h = h(0:top)		; Cut array size.
	w = where(h ne flag)	; Find all processed entries.
	h = h(w)		; Extract them.
 
	err = 0
	return
	end
