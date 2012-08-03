;-------------------------------------------------------------
;+
; NAME:
;       XPRINT
; PURPOSE:
;       Print text on graphics device.  After initializing use just like print.
; CATEGORY:
; CALLING SEQUENCE:
;       xprint, item1, [item2, ..., item10]
; INPUTS:
;       txt = text string to print.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c set text color.
;         ALIGNMENT=a set text alignment.
;         /INIT to initialize xprint.
;           xprint,/INIT,x,y
;             x,y = coord. of upper-left corner of first line of text.    in
;         /DATA use data coordinates (def). Only needed on /INIT.
;         /DEVICE use device coordinates. Only needed on /INIT.
;         /NORM use normalized coordinates. Only needed on /INIT.
;         /NWIN use normalized window coordinates. Only needed
;           on /INIT.  NWIN coordinates are linear 0 to 1
;           inside plot window (inside axes box).
;         CHARSIZE=sz  Text size to use. On /INIT only.
;         CHARTHICK=thk  Text thickness to use. On /INIT only.
;           Text is thickened by shifting and overplotting.
;           Thk is total number of overplots wanted. To shift by
;           > 1 pixel per plot do CHARTHICK=[thk,step]
;           where step is in pixels (def=1).
;         DY=factor.  Adjust auto line space by this factor. On /INIT only
;           Try DY=1.5 for PS plots with the printer fonts (not PSINIT,/VECT).
;         YSPACE=out return line spacing in Y.
;         x0=x0 return graphics x-position of text in normalized coordinates.
;         y0=y0 return graphics y-position of text in normalized coordinates.
; OUTPUTS:
; COMMON BLOCKS:
;       xprint_com
; NOTES:
;       Notes: Initialization sets text starting location and text size.
;         All following xprint calls work just like print normally does except
;         text is output on the graphics device.
; MODIFICATION HISTORY:
;       R. Sterner, 9 Oct, 1989.
;       H. Cohl, 19 Jun, 1991.  (x0, y0)
;       R. Sterner, 25 Sep, 1991 --- fixed a bug that made line spacing
;       wrong when the window Y size varied from the normal value. The
;       bug showed up for psinit,/full with !p.multi=[0,1,2,0,0] where
;       the line spacing appeared to be 2 times too much.  Was using
;       xyouts to print a dummy letter to get its size.  Now just use
;       the value !d.y_ch_size (dev coord) as a good guess.
;       R. Sterner, 10 Mar, 1992 --- added CHARTHICK.
;       R. Sterner, 18 Mar, 1992 --- Modified CHARTHICK to do shifted
;       overplots and added shift size in pixels.
;       R. Sterner, 27 Mar, 1992 --- fixed a bug added with the modified
;       CHARTHICK.
;       R. Sterner, 20 May, 1993 --- Allowed CHARSIZE.
;       R. Sterner, 30 Jul, 1993 --- coordinate system used only to set
;       initial point, not needed for each print.
;       Handle log axes.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xprint, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, $
	  help=hlp, init=nit, dy=dy2, size=size, color=color, debug=debug, $
	  alignment=alignment, data=data,device=device,norm=norm,nwin=nwin,$
	  yspace=yspace,x0=x0,y0=y0, charthick=charthick, charsize=charsize
 
	common xprint_com, xc, yc, szc, clo, chi, cst, px, py, dy
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Print text on graphics device.  After initializing '+$
	    'use just like print.'
	  print,' xprint, item1, [item2, ..., item10]'
	  print,'   txt = text string to print.     in'
	  print,' Keywords:'
	  print,'   COLOR=c set text color.'
	  print,'   ALIGNMENT=a set text alignment.'
	  print,'   /INIT to initialize xprint.'
	  print,'     xprint,/INIT,x,y'
	  print,'       x,y = coord. of upper-left corner of first '+$
	    'line of text.    in'
	  print,'   /DATA use data coordinates (def). Only needed on /INIT.'
	  print,'   /DEVICE use device coordinates. Only needed on /INIT.'
	  print,'   /NORM use normalized coordinates. Only needed on /INIT.'
	  print,'   /NWIN use normalized window coordinates. Only needed'
	  print,'     on /INIT.  NWIN coordinates are linear 0 to 1'
	  print,'     inside plot window (inside axes box).'
	  print,'   CHARSIZE=sz  Text size to use. On /INIT only.'
	  print,'   CHARTHICK=thk  Text thickness to use. On /INIT only.'
	  print,'     Text is thickened by shifting and overplotting.'
	  print,'     Thk is total number of overplots wanted. To shift by'
	  print,'     > 1 pixel per plot do CHARTHICK=[thk,step]'
	  print,'     where step is in pixels (def=1).'
	  print,'   DY=factor.  Adjust auto line space by this factor. '+$
	    'On /INIT only.
	  print,'     Try DY=1.5 for PS plots with the printer fonts '+$
	    '(not PSINIT,/VECT).'
	  print,'   YSPACE=out return line spacing in Y.'
          print,'   x0=x0 return graphics x-position of text in normalized'+$
	    ' coordinates.'
          print,'   y0=y0 return graphics y-position of text in normalized'+$
	    ' coordinates.'
	  print,' Notes: Initialization sets text starting location and '+$
	    'text size.'
	  print,'   All following xprint calls work just like print '+$
	    'normally does except'
	  print,'   text is output on the graphics device.'
	  return
	endif
 
	;------  Set defaults  -------
	;-----  Other defaults  -----
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(alignment) eq 0 then alignment = 0.
 
	;--------  /INIT  ----------------
	if keyword_set(nit) then begin
	  if n_params(0) lt 2 then begin
	    print,' Must give both x and y in normalized coordinates.'
	    return
	  endif
	  ;------  Char size and thickness  --------
	  szc = 1.	; Use size=1 to figure spacing.
	  if n_elements(charsize) ne 0 then size=charsize
	  if n_elements(size) ne 0 then szc = size
	  cthk = 1	; Default text thickness (pixels).
	  if n_elements(charthick) gt 0 then cthk = charthick(0)
	  cst = 1L	; Default thickness step size (pixels).
	  if n_elements(charthick) gt 1 then cst = long(charthick(1))
	  clo = -long((cthk-1)/2) ; Thick text: step from clo to chi by cst.
	  chi = long(cthk/2)
	  ;------  Get pixel and line spacing in normalized coordinates  ---
	  aa = convert_coord([0,1],[0,1], /dev, /to_norm)
	  px = aa(0,1) - aa(0,0)
	  py = aa(1,1) - aa(1,0)
	  dy = py*!d.y_ch_size*szc
	  if n_elements(dy2) gt 0 then dy = dy*dy2  ; Line spacing over-ride.
	  yspace = dy				    ; Output line spacing.
 
	  ;-- Get text starting point in normalized coord. 
	  case 1 of
keyword_set(device): begin			; Device.
	      aa = convert_coord([p1],[p2], /dev, /to_norm)
	      xc = aa(0)  & yc = aa(1)
	    end
keyword_set(norm): begin			; Normalized.
	      xc = p1  & yc = p2
	    end
keyword_set(nwin): begin			; Normalized window.
	      nwin, p1, p2, xc, yc, /to_norm
	    end
else:       begin				; Data (def).
	      aa = convert_coord([p1],[p2], /data, /to_norm)
	      xc = aa(0)  & yc = aa(1)
	    end
	  endcase
	  return
	endif
	;-----------  End /INIT  ---------
 
	;----------  Process output  ---------
	;---  Build up output string from procedure parameters ---- 
	txt = ''
	for i = 1, n_params(0) do begin
	  j = execute('t = p'+strtrim(i,2))
	  txt = txt + string(t)
	endfor
 
 	for iy = clo, chi do begin
	  yy = yc+iy*cst*py
	  for ix = clo, chi do begin
	    xx = xc+ix*cst*px
	    xyouts, xx, yy, txt, size=szc, color=color, $
	      alignment=alignment, /norm
	  endfor
	endfor
 
        x0=xc & y0=yc		; Returned text position.
	yc = yc - dy		; Next line position.
 
if keyword_set(debug) then stop
 
	return
	end
