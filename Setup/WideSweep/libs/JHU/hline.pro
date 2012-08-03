;-------------------------------------------------------------
;+
; NAME:
;       HLINE
; PURPOSE:
;       Plot a horizontal line after erasing last plotted line.
; CATEGORY:
; CALLING SEQUENCE:
;       hline, [y]
; INPUTS:
;       y = y coordinate of new line.   in
;         If y not given last line is erased.
; KEYWORD PARAMETERS:
;       Keywords:
;         /DEVICE means use device coordinates (default).
;         /DATA means use data coordinates.
;         /NORM means use normalized coordinates.
;         /NOERASE means don't try to erase last line.
;         /ERASE means just erase last line without plotting another.
;         /RESET means reset erase and return.  Skips next erase.
;           Use /RESET for a new window size.
;         RANGE=[xmin, xmax] min and max x coordinates of line.
;         NUMBER=n line number (0 to 9, def=0).
;         COLOR=c set plot color.
;         LINESTYLE=s set line style.
;         /XMODE use XOR mode (faster).
; OUTPUTS:
; COMMON BLOCKS:
;       hline
; NOTES:
; MODIFICATION HISTORY:
;       R. sterner, 5 June, 1992
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;       R. Sterner, 2002 Sep 05 --- Fixed erase bug.
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
 
	pro hline, y0, range=range, noerase=noerase, erase=erase, $
	  device=device, data=data, norm=norm, number=num, $
	  color=color, linestyle=linestyle, help=hlp, xmode=xmode, $
	  reset=reset
 
	common hline, sx, sy, ylst, rlst, eflag
 
	if keyword_set(hlp) then begin
	  print,' Plot a horizontal line after erasing last plotted line.'
	  print,' hline, [y]'
	  print,'   y = y coordinate of new line.   in'
	  print,'     If y not given last line is erased.'
	  print,' Keywords:'
	  print,'   /DEVICE means use device coordinates (default).'
	  print,'   /DATA means use data coordinates.'
	  print,'   /NORM means use normalized coordinates.'
	  print,"   /NOERASE means don't try to erase last line."
	  print,'   /ERASE means just erase last line without plotting another.'
	  print,'   /RESET means reset erase and return.  Skips next erase.'
	  print,'     Use /RESET for a new window size.'
	  print,'   RANGE=[xmin, xmax] min and max x coordinates of line.'
	  print,'   NUMBER=n line number (0 to 9, def=0).'
	  print,'   COLOR=c set plot color.'
	  print,'   LINESTYLE=s set line style.'
	  print,'   /XMODE use XOR mode (faster).'
	  return
	endif
 
	if n_elements(y0) eq 0 then y=0 else y=y0
 
	;------  Erase last line before doing next?  -------
	if n_elements(eflag) eq 0 then eflag=1	; Normal erase last line.
	if keyword_set(reset) then begin	; Reset command.
	  eflag = 0				; Don't erase last line.
	  sx = !d.x_size	; Screen size in X.
	  sy = !d.y_size	; Screen size in Y.
	  ylst = intarr(10)-1	; Y of last line plotted.
	  rlst = intarr(sx,10)	; Row under last line plotted.
	  return
	endif
	if keyword_set(noerase) then eflag=0	; Don't erase last line.
 
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
	  ylst = intarr(10)-1	; Y of last line plotted.
	  rlst = intarr(sx,10)	; Row under last line plotted.
	endif
 
	;-----  Set X range -------
	if device eq 1 then begin
	  range0 = [0,sx-1]
	endif
	if data eq 1 then begin
	  range0 = !x.crange
	endif
	if norm eq 1 then begin
	  range0 = [0.,1.]
	endif
	if n_elements(range) eq 0 then range = range0
 
	;-----  Convert Y and range to device -------
	if device eq 1 then begin
	  yc = y
	  x1 = range(0)
	  x2 = range(1)
	endif
	if data eq 1 then begin
	  range0 = !x.crange
	  t = convert_coord(range,[y,y], /data, /to_device)
	  yc = t(1,0)
	  x1 = t(0,0)
	  x2 = t(0,1)
	endif
	if norm eq 1 then begin
	  range0 = [0.,1.]
	  t = convert_coord(range,[y,y], /norm, /to_device)
	  yc = t(1,0)
	  x1 = t(0,0)
	  x2 = t(0,1)
	endif
	yc = fix(yc+.5)
	x1 = fix(x1+.5)
	x2 = fix(x2+.5)
 
	;------  Just erase last line  ------
	if n_elements(y0) eq 0 then erase = 1	; If no y given erase last line.
	if keyword_set(erase) then begin
	  if keyword_set(xmode) then begin      ; XOR mode.
	    plots, /device, color=clr, $
	      linestyle=linestyle, [x1,x2], [ylst(num),ylst(num)]
	    empty
	  endif else begin                      ; Normal mode.
	    tv, rlst(*,num), 0, ylst(num)
	  endelse
	  goto, done
	endif
 
	;-----  Erase last line  ------
	if eflag eq 1 then begin
	  yl = ylst(num)
	  if (yl ge 0) and (yl lt sy) then begin
	    if keyword_set(xmode) then begin    ; XOR mode.
	      plots, /device, color=clr, $
	        linestyle=linestyle, [x1,x2], [yl,yl]
	      empty
	    endif else begin                    ; Normal mode.
	      tv, rlst(*,num), 0, yl
	    endelse
	  endif
	endif
	ylst(num) = yc
 
	;-----  Read new line  --------
	if not keyword_set(xmode) then begin
	  if (yc ge 0) and (yc lt sy) then begin
	    t = tvrd(0,yc,sx,1)
	    rlst(0,num) = t
	  endif
	endif
 
	;-----  Plot new line  ----------
	plots, /device, color=clr, $
	  linestyle=linestyle, [x1,x2], [yc,yc]
	empty
 
        ;--------  XOR mode  ---------------
done:   if keyword_set(xmode) then begin
          device,set_graph=old
	  device,decomp=olddecomp
        endif
 
	eflag = 1
 
	end
