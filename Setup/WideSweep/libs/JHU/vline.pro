;-------------------------------------------------------------
;+
; NAME:
;       VLINE
; PURPOSE:
;       Plot a vertical line after erasing last plotted line.
; CATEGORY:
; CALLING SEQUENCE:
;       vline, [x]
; INPUTS:
;       x = x coordinate of new line.   in
;         If x not given last line is erased.
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE means use device coordinates (default).
;         /DATA means use data coordinates.
;         /NORM means use normalized coordinates.
;         /NOERASE means don't try to erase last line.
;         /ERASE means just erase last line without plotting another.
;         /RESET means reset erase and return.  Skips next erase.
;           Use /RESET for a new window size.
;         RANGE=[ymin, ymax] min and max y coordinates of line.
;         NUMBER=n line number (0 to 9, def=0).
;         COLOR=c set plot color.
;         LINESTYLE=s set line style.
;         /XMODE use XOR mode (faster).
; OUTPUTS:
; COMMON BLOCKS:
;       vline_com
; NOTES:
; MODIFICATION HISTORY:
;       R. sterner, 5 June, 1992
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;       R. Sterner, 2002 Sep 06 --- Added /XMODE, /RESET.
;       R. Sterner, 2002 Sep 09 --- Added empty to avoid some minor artifacts.
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro vline, x0, range=range, noerase=noerase, erase=erase, $
	  device=device, data=data, norm=norm, number=num, $
	  color=color, linestyle=linestyle, help=hlp, xmode=xmode, $
	  reset=reset
 
	common vline_com, sx, sy, xlst, clst, eflag
 
	if keyword_set(hlp) then begin
	  print,' Plot a vertical line after erasing last plotted line.'
	  print,' vline, [x]'
	  print,'   x = x coordinate of new line.   in'
	  print,'     If x not given last line is erased.'
	  print,' Keywords:'
	  print,'   /DEVICE means use device coordinates (default).'
	  print,'   /DATA means use data coordinates.'
	  print,'   /NORM means use normalized coordinates.'
	  print,"   /NOERASE means don't try to erase last line."
	  print,'   /ERASE means just erase last line without plotting another.'
	  print,'   /RESET means reset erase and return.  Skips next erase.'
	  print,'     Use /RESET for a new window size.'
	  print,'   RANGE=[ymin, ymax] min and max y coordinates of line.'
	  print,'   NUMBER=n line number (0 to 9, def=0).'
	  print,'   COLOR=c set plot color.'
	  print,'   LINESTYLE=s set line style.'
	  print,'   /XMODE use XOR mode (faster).'
	  return
	endif
 
	if n_elements(x0) eq 0 then x=0 else x=x0
 
        ;------  Erase last line before doing next?  -------
        if n_elements(eflag) eq 0 then eflag=1  ; Normal erase last line.
        if keyword_set(reset) then begin        ; Reset command.
          eflag = 0                             ; Don't erase last line.
	  sx = !d.x_size	; Screen size in X.
	  sy = !d.y_size	; Screen size in Y.
	  xlst = intarr(10)-1	; X of last line plotted.
	  clst = intarr(10,sy)	; Column under last line plotted.
          return
        endif
        if keyword_set(noerase) then eflag=0    ; Don't erase last line.
 
	;------  Define plot values  ------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(linestyle) eq 0 then linestyle = 0
	if n_elements(num) eq 0 then num = 0
	clr = color
 
	;--------  XOR mode  ---------------
	if keyword_set(xmode) then begin
	  device,get_graph=old,set_graph=6
	  device,get_decomp=olddecomp
	  device,decomp=0
	  clr = 255
	endif
 
	;------  Determine coordinate system  -----
	if n_elements(device) eq 0 then device = 0	; Define flags.
	if n_elements(data)   eq 0 then data   = 0
	if n_elements(norm)   eq 0 then norm   = 0
	if device+data+norm eq 0 then device = 1	; Default to device.
 
	;-----  Init common  -----
	if n_elements(sx) eq 0 then begin
	  sx = !d.x_size	; Screen size in X.
	  sy = !d.y_size	; Screen size in Y.
	  xlst = intarr(10)-1	; X of last line plotted.
	  clst = intarr(10,sy)	; Column under last line plotted.
	endif
 
	;-----  Set Y range -------
	if device eq 1 then begin
	  range0 = [0,sy-1]
	endif
	if data eq 1 then begin
	  range0 = !y.crange
	endif
	if norm eq 1 then begin
	  range0 = [0.,1.]
	endif
	if n_elements(range) eq 0 then range = range0
 
	;-----  Convert X and range to device -------
	if device eq 1 then begin
	  xc = x
	  y1 = range(0)
	  y2 = range(1)
	endif
	if data eq 1 then begin
	  range0 = !y.crange
	  t = convert_coord([x,x],range, /data, /to_device)
	  xc = t(0,0)
	  y1 = t(1,0)
	  y2 = t(1,1)
	endif
	if norm eq 1 then begin
	  range0 = [0.,1.]
	  t = convert_coord([x,x],range, /norm, /to_device)
	  xc = t(0,0)
	  y1 = t(1,0)
	  y2 = t(1,1)
	endif
	xc = fix(xc+.5)
	y1 = fix(y1+.5)
	y2 = fix(y2+.5)
 
	;------  Just erase last line  ------
	if n_elements(x0) eq 0 then erase = 1	; If no x given erase last line.
	if keyword_set(erase) then begin
	  if keyword_set(xmode) then begin	; XOR mode.
	    plots, /device, color=clr, $
	      linestyle=linestyle, [xlst(num),xlst(num)], [y1,y2]
	    empty
	  endif else begin			; Normal mode.
	    tv, clst(num,*), xlst(num), 0
	  endelse
	  goto, done
	endif
 
	;-----  Erase last line  ------
	if eflag eq 1 then begin
	  xl = xlst(num)
	  if (xl ge 0) and (xl lt sx) then begin
	    if keyword_set(xmode) then begin	; XOR mode.
	      plots, /device, color=clr, $
	        linestyle=linestyle, [xl,xl], [y1,y2]
	      empty
	    endif else begin			; Normal mode.
	      tv, clst(num,*), xl, 0
	    endelse
	  endif
	endif
	xlst(num) = xc
 
	;-----  Read new line  --------
	if not keyword_set(xmode) then begin
	  if (xc ge 0) and (xc lt sx) then begin
	    t = tvrd(xc,0,1,sy)
	    clst(num,0) = t
	  endif
	endif
 
	;-----  Plot new line  ----------
	plots, /device, color=clr, $
	  linestyle=linestyle, [xc,xc], [y1,y2]
	empty
 
	;--------  XOR mode  ---------------
done:	if keyword_set(xmode) then begin
	  device,set_graph=old
	  device,decomp=olddecomp
	endif
 
	eflag = 1
 
	end
