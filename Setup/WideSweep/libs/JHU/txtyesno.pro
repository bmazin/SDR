;-------------------------------------------------------------
;+
; NAME:
;       TXTYESNO
; PURPOSE:
;       Ask a yes/on question and read the answer.
; CATEGORY:
; CALLING SEQUENCE:
;       ans = txtyesno(txt)
; INPUTS:
;       txt = string or string array containing question.   in
; KEYWORD PARAMETERS:
;       Keywords:
;        /NOCLEAR inhibits the screen clear but will erase
;          displayed text on exit.
;        X=x text starting column (def=centered around col 40).
;        Y=y text starting line (def=centered around line 10).
; OUTPUTS:
;       ans = answer: 0=no, 1=yes.                          out
; COMMON BLOCKS:
; NOTES:
;       Note: must enter Y for yes or N for no (case insensitive).
; MODIFICATION HISTORY:
;       R. Sterner, 26 Feb, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function txtyesno, txt, x=x, y=y, noclear=noclear, help=hlp
;	R. Sterner, 26 Feb, 1992
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Ask a yes/on question and read the answer.'
	  print,' ans = txtyesno(txt)'
	  print,'   txt = string or string array containing question.   in'
	  print,'   ans = answer: 0=no, 1=yes.                          out'
	  print,' Keywords:'
          print,'  /NOCLEAR inhibits the screen clear but will erase'
          print,'    displayed text on exit.'
          print,'  X=x text starting column (def=centered around col 40).'
          print,'  Y=y text starting line (def=centered around line 10).'
	  print,' Note: must enter Y for yes or N for no (case insensitive).
	  return,-1
	end
 
        ntxt = n_elements(txt)                  ; # lines in message.
 
        ;---------  Starting column  ------------
        if n_elements(x) ne 0 then begin
          xp0 = x
        endif else begin
          maxl = max(strlen(txt))               ; Max line length.
          xp0 = 40 - maxl/2                     ; Center around column 40.
        endelse
        xp = xp0
 
        ;---------  Starting line  ----------
        if n_elements(y) ne 0 then begin
          yp0 = y                               ; Given start line.
        endif else begin
          yp0 = 10 - ntxt/2                     ; Center around line 10.
        endelse
	yp = yp0
 
        if not keyword_set(noclear) then printat,1,1,/clear     ; Clear screen.
 
        ;-------- Display message  ---------
	for i = 0, ntxt-1 do begin	; Loop through lines.
	  printat,xp,yp,txt(i)		; Display a line.
	  yp = yp + 1			; Move down 1.
	endfor
	ktxt = 'Press Y for yes and N for no'	; Prompt text.
	xp = 40 - strlen(ktxt)/2	; Center prompt text.
	if n_elements(x) ne 0 then xp = xp0
	printat,xp,yp+1,ktxt		; Display it.
	printat,1,1
 
	;--------  read answer  -------
loop:	k = strupcase(get_kbrd(1))	; Wait for a key.
	if (k ne 'Y') and (k ne 'N') then goto, loop
 
        ;-------  Clear message  -----------
        if keyword_set(noclear) then begin
          yp = yp0
	  xp = xp0
          for i = 0, ntxt-1 do begin                    ; Loop through lines.
            printat,xp,yp,spc(strlen(txt(i)))           ; Erase.
            yp = yp + 1                                 ; Move down 1.
          endfor
	  xp = 40 - strlen(ktxt)/2			; Prompt text position.
	  if n_elements(x) ne 0 then xp = xp0
	  printat,xp,yp+1,spc(strlen(ktxt))		; Erase it.
        endif else begin
          printat, 1,1,/clear                           ; Clear screen.
        endelse
 
	;-----  Return answer  -------
	return, k eq 'Y'
 
	end
