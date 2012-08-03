;-------------------------------------------------------------
;+
; NAME:
;       SHOW_BOX
; PURPOSE:
;       Used by MOVBOX to display current box size and position.
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  26 July, 1989.
;	R. Sterner,  16 Mar, 1992 --- modified to use printat.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	PRO SHOW_BOX, X0, Y0, DX0, DY0, code, yreverse=yrev, $
	  position=pos, xfactor=xfact, yfactor=yfact, title=title, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Used by MOVBOX to display current box size and position.'
	  return
	endif
 
	line = pos>2
	if n_elements(title) eq 0 then title = ''

	x = x0				; Copy input device coordinates.
	y = y0
	dx = dx0
	dy = dy0

	x = fix(.5 + x*xfact)		; Scale device coordinates.
	dx = fix(.5 + dx*xfact)
	y = fix(.5 + y*yfact)
	dy = fix(.5 + dy*yfact)

	X2 = X + DX - 1			; Box corner.
	Y2 = Y + DY - 1
	if keyword_set(yrev) then begin	; Y is 0 at top.
	  y2 = yfact*!d.y_size - y2 - 1
	  y = yfact*!d.y_size - y - 1
	endif
	xcenter = fix((.5+x+x2)/2.)	; Box center coordinates.
	ycenter = fix((.5+y+y2)/2.)
	sxc = (xfact*!d.x_size-1)/2		; Screen center.
	syc = (yfact*!d.y_size-1)/2

 
;	PRINT,'     array('+STRTRIM(X,2)+':'+STRTRIM(X2,2)+','+STRTRIM(Y,2)+$
;	  ':'+STRTRIM(Y2,2)+')'+'  box size: '+STRTRIM(DX,2)+$
;	  ' X '+STRTRIM(DY,2)

	if n_elements(code) eq 0 then code = 0
	if code eq 0 then begin
	  printat,1,1,/clear
	  printat,2,line,title
	  printat,7,line+3,  '*--+--*'
	  printat,7,line+4,  '+     |'
	  printat,7,line+5,  '*-----*'
	  printat,19,line+3,'Box Size'
	  printat,22,line+4,'by'
	  code = 1
	endif

	printat,1,line+3,string(y2,form='(I4)')
	printat,1,line+4,string(ycenter,form='(I4)')
	printat,1,line+5,string(y,form='(I4)')
	printat,5,line+6,string(x,form='(I4)')
	printat,12,line+6,string(x2,form='(I4)')
	printat,8,line+2,string(xcenter,form='(I4)')
	printat,17,line+4,string(dx,form='(I4)')
	printat,25,line+4,string(dy,form='(I4)')

	if sxc gt xcenter then printat,10,line+3,'>'
	if sxc lt xcenter then printat,10,line+3,'<'
	if sxc eq xcenter then printat,10,line+3,'='
 
	ygt = '^'
	ylt = 'v'
	if keyword_set(yrev) then begin
	  ygt = 'v'
	  ylt = '^'
	endif
	if syc gt ycenter then printat,7,line+4,ygt
	if syc lt ycenter then printat,7,line+4,ylt
	if syc eq ycenter then printat,7,line+4,'='

	RETURN
	END
