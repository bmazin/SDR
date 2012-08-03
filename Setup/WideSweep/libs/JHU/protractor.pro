;-------------------------------------------------------------
;+
; NAME:
;       PROTRACTOR
; PURPOSE:
;       Measure angles on the screen.
; CATEGORY:
; CALLING SEQUENCE:
;       protractor
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ANGLE=a     measured angle returned.
;         LENGTH=len  measured lengths returned as 2 element array.
;         FACTOR=f    Length conversion factor (def=1).
;         COLOR=c     Plot color to use (def=!p.color).
;         /QUIET      suppresses messages.
; OUTPUTS:
; COMMON BLOCKS:
;       protractor_com
; NOTES:
;       Notes: lengths are listed and returned in pixels unless
;         over-ridden by FACTOR.
; MODIFICATION HISTORY:
;       R. Sterner, 12 Feb, 1993 (inspired by Bob Taylor's angle.pro).
;       R. Sterner, 16 Mar, 1993 --- added no erase exit.
;       R. Sterner, 16 Mar, 1993 --- added exit coordinate list.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro protractor, angle=ang, length=len, color=color, quiet=quiet, $
	  factor=fctr, help=hlp, initialize=init
 
	common protractor_com, xa, ya, xb, yb, xc, yc
 
	if keyword_set(hlp) then begin
	  print,' Measure angles on the screen.'
	  print,' protractor'
	  print,'   All args are output keywords.'
	  print,' Keywords:'
	  print,'   ANGLE=a     measured angle returned.'
	  print,'   LENGTH=len  measured lengths returned as 2 element array.'
	  print,'   FACTOR=f    Length conversion factor (def=1).'
	  print,'   COLOR=c     Plot color to use (def=!p.color).'
	  print,'   /QUIET      suppresses messages.'
	  print,' Notes: lengths are listed and returned in pixels unless'
	  print,'   over-ridden by FACTOR.'
	  return
	endif
 
	scrn = tvrd()		; Read screen image.
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(fctr) eq 0 then fctr = 1.
	cflag = 1		; Change flag.  Start with yes.
	flag = 3		; Active point flag (1=A, 2=B, 3=C).
	;----------------------------------------------------------------
	;  Protractor has 2 sides: AC and BC where C is center of angle
	;  and A and B are side endpoints.
	;----------------------------------------------------------------
 
	;---------  Initialize common  -----------
	if (n_elements(xa) eq 0) or keyword_set(init) then begin
	  xsz = !d.x_size	; Screen size in x and y.
	  ysz = !d.y_size
	  xc = xsz/2		; Center of protractor.
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
	  print,' Protractor: measure angles on the screen.'
	  print,' Left mouse button: drag one of the three protractor points.'
	  print,' Middle button exits, erases protractor.'
	  print,' Right button exits, without erasing protractor.'
	  print,' '
	endif
 
	;==============  Main loop  ========================
	;-----------------  Plot  --------------------------
loop:	plots,[xa,xc,xb], [ya,yc,yb], color=color, /dev	; Plot vectors.	
	case flag of					; Plot active point.
1:	  plots,[xa],[ya],psym=2, /dev
2:	  plots,[xb],[yb],psym=2, /dev
3:	  plots,[xc],[yc],psym=2, /dev
	endcase
 
	;-----------------  Compute and display  --------------
	if cflag eq 1 then begin
	  dx1 = float(xa-xc)
	  dy1 = float(ya-yc)
	  dx2 = float(xb-xc)
	  dy2 = float(yb-yc)
	  dp = dx1*dx2+dy1*dy2
	  cp = dy1*dx2-dx1*dy2
	  ang = atan(cp,dp)*!radeg
	  len = fctr*sqrt(([xa,xb]-xc)^2 + ([ya,yb]-yc)^2)
	  if not keyword_set(quiet) then begin
	    ta = '  '
	    tb = '  '
	    tc = '  '
	    case flag of
1:	      ta = ' *'
2:	      tb = ' *'
3:	      tc = ' *'
	    endcase
	    print,' Angle, length_1, length_2: ',ang,tc,len(0),ta,len(1),tb
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
 
	d2 = (x-[xa,xb,xc])^2 + (y-[ya,yb,yc])^2	; Find closest point.
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
3:	    begin
	      xc = x
	      yc = y
	    end
	  endcase
	  cflag = 1					; Set change flag.
	endif ; !mouse
 
	goto, loop
 
done:	print,' '
	print,' Angle point x,y: ',fix(.5+xc),fix(.5+yc)
	print,' Arm 1 point x,y: ',fix(xa+.5),fix(.5+ya)
	print,' Arm 2 point x,y: ',fix(.5+xb),fix(.5+yb)
	return
 
	end
