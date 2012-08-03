;-------------------------------------------------------------
;+
; NAME:
;       IMGLINE
; PURPOSE:
;       Interactive line on the screen.
; CATEGORY:
; CALLING SEQUENCE:
;       imgline
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         P1=p1       Returned screen x,y of endpoint 1.
;         P2=p2       Returned screen x,y of endpoint 2.
;         LENGTH=len  Returned line length.
;         FACTOR=f    Length conversion factor (def=1).
;         COLOR=col   Plot color.
;         /INITIALIZE Initialize.
;         /QUIET      suppresses messages.
; OUTPUTS:
; COMMON BLOCKS:
;       imgline_com
; NOTES:
;       Notes: length is listed and returned in pixels unless
;         over-ridden by FACTOR.
; MODIFICATION HISTORY:
;       R. Sterner, 18 Mar, 1993
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro imgline, p1=p1, p2=p2, color=color, quiet=quiet, $
	  factor=fctr, help=hlp, length=length, initialize=init
 
	common imgline_com, xa, ya, xb, yb
 
	if keyword_set(hlp) then begin
	  print,' Interactive line on the screen.'
	  print,' imgline'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   P1=p1       Returned screen x,y of endpoint 1.'
	  print,'   P2=p2       Returned screen x,y of endpoint 2.'
	  print,'   LENGTH=len  Returned line length.'
	  print,'   FACTOR=f    Length conversion factor (def=1).'
	  print,'   COLOR=col   Plot color.'
	  print,'   /INITIALIZE Initialize.'
	  print,'   /QUIET      suppresses messages.'
	  print,' Notes: length is listed and returned in pixels unless'
	  print,'   over-ridden by FACTOR.'
	  return
	endif
 
	for i=0,23 do print,' '
 
	scrn = tvrd()		; Read screen image.
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(fctr) eq 0 then fctr = 1.
	cflag = 1		; Change flag.  Start with yes.
	flag = 1		; Active point flag (1=A, 2=B).
	;--------------------------------
	;  line has 2 points: A and B
	;--------------------------------
 
	;---------  Initialize common  -----------
	if (n_elements(xa) eq 0) or keyword_set(init) then begin
	  xsz = !d.x_size	; Screen size in x and y.
	  ysz = !d.y_size
	  xc = xsz/2		; Center of screen.
	  yc = ysz/2
	  r = .3*(xsz<ysz)	; Some radius on screen.
	  polrec, r, 20, xa, ya, /degrees	; First point.
	  polrec, r, 40, xb, yb, /degrees	; Second point.
	  xa = xa + xc
	  ya = ya + yc
	  xb = xb + xc
	  yb = yb + yc
	endif
 
	;--------  Instructions  ---------------
	if not keyword_set(quiet) then begin
	  print,' '
	  print,' imgline: interactive line on the screen.'
	  print,' Left mouse button: drag one of the two line points.'
	  print,' Middle button exits, erases line.'
	  print,' Right button exits, without erasing line.'
	  print,' '
	endif
 
	;-----------  Screen setup  ------------------------
	printat,1,1,/clear
	printat,5,5,'Interactive image line'
	printat,5,7,'Length:'
	printat,5,9,'Point 1:'
	printat,5,11,'Point 2:'
	printat,5,13,'Angle from point 1 to point 2:'
 
 
	;==============  Main loop  ========================
	;-----------------  Plot  --------------------------
loop:	plots,[xa,xb], [ya,yb], color=color, /dev	; Plot vectors.	
	case flag of					; Plot active point.
1:	  plots,[xa],[ya],psym=2, /dev
2:	  plots,[xb],[yb],psym=2, /dev
	endcase
 
	;-----------------  Compute and display  --------------
	if cflag eq 1 then begin
	  dx = float(xb-xa)
	  dy = float(yb-ya)
	  ang = atan(dy,dx)*!radeg
	  len = fctr*sqrt(dx^2 + dy^2)
	  if not keyword_set(quiet) then begin
	    ta = '    '
	    tb = '    '
	    case flag of
1:	      ta = ' *  '
2:	      tb = ' *  '
	    endcase
	    printat,13,7,strtrim(len,2)
	    printat,14,9,'('+strtrim(fix(.5+xa),2)+','+$
	      strtrim(fix(.5+ya),2)+')'+ta
	    printat,14,11,'('+strtrim(fix(.5+xb),2)+','+$
	      strtrim(fix(.5+yb),2)+')'+tb
	    printat,36,13,strtrim(ang,2)
 
;	    print,' length, Point_1, Point_2: '+strtrim(len,2)+'  ('+$
;	      strtrim(xa,2)+','+strtrim(ya,2)+')'+ta+'   ('+$
;	      strtrim(xb,2)+','+strtrim(yb,2)+')'+tb
	  endif
	  cflag = 0				; Clear change flag.
	endif ; cflag
 
	;----------------  Cursor  -------------------------
	cursor, x, y, 2, /dev			; Read cursor position.
 
	;---------------  No Erase exit  --------------
	if !mouse.button gt 2 then goto, done		; Done.
 
	;----------------  Refresh screen  ------------------
	tv, scrn
 
	;---------------  Erase exit  --------------
	if !mouse.button gt 1 then goto, done		; Done.
 
	d2 = (x-[xa,xb])^2 + (y-[ya,yb])^2		; Find closest point.
	w = where(d2 eq min(d2))
 
	if d2(w(0)) le 400 then begin			; Activate point.
	  flag2 = w(0)+1				; Set active flag.
	  if flag2 ne flag then begin			; Did flag change?
	    flag = flag2
	    cflag = 1
	  endif
	endif
 
	if !mouse.button eq 1 then begin		; Move point.
	  case flag of
1:	    begin
	      xa = x
	      ya = y
	    end
2:	    begin
	      xb = x
	      yb = y
	    end
	  endcase
	  cflag = 1					; Set change flag.
	endif ; !mouse
 
	goto, loop
 
done:	print,' '
	print,' Point 1 x,y: ',fix(xa+.5),fix(.5+ya)
	print,' Point 2 x,y: ',fix(.5+xb),fix(.5+yb)
	p1 = [xa,ya]
	p2 = [xb,yb]
 
	return
 
	end
