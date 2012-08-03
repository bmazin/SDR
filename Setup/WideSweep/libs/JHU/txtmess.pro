;-------------------------------------------------------------
;+
; NAME:
;       TXTMESS
; PURPOSE:
;       Display a message on the screen and wait for any key.
; CATEGORY:
; CALLING SEQUENCE:
;       txtmess, txt
; INPUTS:
;       txt = string or string array.   in
; KEYWORD PARAMETERS:
;       Keywords:
;        /NOCLEAR inhibits the screen clear but will erase
;          displayed text on exit.
;        X=x message starting column (def=centered around col 40).
;        Y=y message starting line (def=centered around line 10).
;        PROMPT=txt set prompt text.
;          def=< Press any key to continue >
;        KEY=k returned value of key pressed.
;        WAIT=s message wait time in seconds.  This overides
;          the wait for a key press and times out.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 14 Feb, 1992
;       R. Sterner, 14 Feb, 1992 --- added WAIT, /NOCLEAR
;       R. Sterner, 16 Mar, 1992 --- added PROMPT=txt, KEY=k.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro txtmess, txt, help=hlp, x=x, y=y, wait=wt, noclear=noclear, $
          prompt=ptxt, key=k
 
	if (n_params(0) eq 0) or keyword_set(hlp) then begin
	  print,' Display a message on the screen and wait for any key.'
	  print,' txtmess, txt'
	  print,'   txt = string or string array.   in'
	  print,' Keywords:'
	  print,'  /NOCLEAR inhibits the screen clear but will erase'
	  print,'    displayed text on exit.'
	  print,'  X=x message starting column (def=centered around col 40).'
	  print,'  Y=y message starting line (def=centered around line 10).'
          print,'  PROMPT=txt set prompt text.'
          print,'    def=< Press any key to continue >'
          print,'  KEY=k returned value of key pressed.'
	  print,'  WAIT=s message wait time in seconds.  This overides'
	  print,'    the wait for a key press and times out.'
	  return
	end
 
	ntxt = n_elements(txt)			; # lines in message.
 
	;---------  Starting column  ------------
	if n_elements(x) ne 0 then begin
	  xp0 = x
	endif else begin
	  maxl = max(strlen(txt))		; Max line length.
	  xp0 = 40 - maxl/2			; Center around column 40.
	endelse
	xp = xp0
 
	;---------  Starting line  ----------
	if n_elements(y) ne 0 then begin
	  yp0 = y				; Given start line.
	endif else begin
	  yp0 = 10 - ntxt/2			; Center around line 10.
	endelse
 
	if not keyword_set(noclear) then printat,1,1,/clear	; Clear screen.
 
	;-------- Display message  ---------
	yp = yp0
	for i = 0, ntxt-1 do begin			; Loop through lines.
	  printat,xp,yp,txt(i)				; Display a line.
	  yp = yp + 1					; Move down 1.
	endfor
 
	;--------  Terminate message ---------
	if n_elements(wt) eq 0 then begin		; By key press.
	  ktxt = '< Press any key to continue >'	;   Prompt text.
          if n_elements(ptxt) ne 0 then ktxt = ptxt
	  xp2 = 40 - strlen(ktxt)/2			;   Center prompt text.
	  if n_elements(x) ne 0 then xp2 = xp0
	  printat,xp2,yp+1,ktxt				;   Display it.
	  k = get_kbrd(1)				;   Wait for a key.
	endif else begin				; By timeout.
	  wait, wt					;   Wait for wt seconds.
	endelse
 
	;-------  Clear message  -----------
	if keyword_set(noclear) then begin
	  yp = yp0
	  for i = 0, ntxt-1 do begin			; Loop through lines.
	    printat,xp,yp,spc(strlen(txt(i)))		; Erase.
	    yp = yp + 1					; Move down 1.
	  endfor
	  if n_elements(wt) eq 0 then printat,xp2,yp+1,spc(strlen(ktxt))
	endif else begin
	  printat, 1,1,/clear				; Clear screen.
	endelse
	
	return
	end
