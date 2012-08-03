;-------------------------------------------------------------
;+
; NAME:
;       WIN_SIZE_SHAPE
; PURPOSE:
;       Find window size & shape needed to display a specified image.
; CATEGORY:
; CALLING SEQUENCE:
;       win_size_shape, nx, ny
; INPUTS:
;       nx, ny = Image size in x and y (pixels).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         MAXIMG=mx Longest side of displayed image (pixels),
;           default is longest image side.
;         XWIN=xsz,YWIN=ysz Returned needed window size in
;          x and y (pixels).
;         POSITION=pos  Returned plot area position.
;           Use for izoom.
;         /DEVICE Return pos in device coordinates, else normalized.
;         XMAR1=xm1, XMAR2=xm2 Left and right margins (def=70,30).
;         YMAR1=ym1, YMAR2=ym2 Bottom and top margins (def=60,30).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Intended to find the size and shape of a window
;         used to display an array using izoom.  Can also use for
;         the plot command.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Apr 22
;       R. Sterner, 2007 Jan 16 --- Made default MAXIMG = longest image side.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro win_size_shape, nx, ny, maximg=mx, $
	  xmar1=xmar1, xmar2=xmar2, ymar1=ymar1, ymar2=ymar2, $
	  xwin=xwin, ywin=ywin, position=pos, $
	  device=dev, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Find window size & shape needed to display a specified image.'
	  print,' win_size_shape, nx, ny'
	  print,'   nx, ny = Image size in x and y (pixels).  in'
	  print,' Keywords:'
	  print,'   MAXIMG=mx Longest side of displayed image (pixels),'
	  print,'     default is longest image side.'
	  print,'   XWIN=xsz,YWIN=ysz Returned needed window size in'
	  print,'    x and y (pixels).' 
	  print,'   POSITION=pos  Returned plot area position.'
	  print,'     Use for izoom.'
	  print,'   /DEVICE Return pos in device coordinates, else normalized.'
	  print,'   XMAR1=xm1, XMAR2=xm2 Left and right margins (def=70,30).'
	  print,'   YMAR1=ym1, YMAR2=ym2 Bottom and top margins (def=60,30).'
	  print,' Notes: Intended to find the size and shape of a window'
	  print,'   used to display an array using izoom.  Can also use for'
	  print,'   the plot command.'
	  return
	endif
 
	;-------------------------------------------
	;  Set defaults
	;-------------------------------------------
;	if n_elements(mx)    eq 0 then mx   =900
	if n_elements(mx)    eq 0 then mx=nx>ny
	if n_elements(xmar1) eq 0 then xmar1=70
	if n_elements(xmar2) eq 0 then xmar2=30
	if n_elements(ymar1) eq 0 then ymar1=60
	if n_elements(ymar2) eq 0 then ymar2=30
 
	;-------------------------------------------
	;  Window size and shape
	;
	;  Set longest side of final image to mx
	;  and compute shorter side.
	;-------------------------------------------
	;---  Landscape shape  ---------
	if nx gt ny then begin
	  idx = mx
	  idy = round((float(ny)/nx)*mx)
	;---  Portrait shape  ---------
	endif else begin
	  idx = round((float(nx)/ny)*mx)
	  idy = mx
	endelse
	xwin = idx + xmar1 + xmar2
	ywin = idy + ymar1 + ymar2
 
	;-------------------------------------------
	;  Position
	;-------------------------------------------
	pos = [xmar1, ymar1, xmar1+idx, ymar1+idy]	; In dev coord.
	if not keyword_set(dev) then begin
	  pos = pos/float([xwin,ywin,xwin,ywin])	; in norm coord.
	endif
 
	end
