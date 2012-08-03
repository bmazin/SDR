;-------------------------------------------------------------
;+
; NAME:
;       XYOUTB
; PURPOSE:
;       Bold text version of xyouts.
; CATEGORY:
; CALLING SEQUENCE:
;       xyoutb, x, y, text
; INPUTS:
;       x,y = text position.           in
;       text = text string to plot.    in
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA use data coordinates (default).
;         /DEVICE use device coordinates.
;         /NORM use normalized coordinates.
;         BOLD=N  Text is replotted N X N times,
;           shifting by P pixel in x or y each time.
;           Default N=2.  For hardcopy try about 5.
;           BOLD may also be set to an N x M array which defines
;           a brush stroke by non-zero elements.  For example:
;           BOLD=shift(dist(3),-2,-2) lt 1.2
;         PIXELS=P number of pixels to use for each shift (def=1).
;           For hardcopy try 5 or 10.
;         SHIFT=shft 2 element array giving pixel shift for each
;           value of bold and color (def=0).  Good for drop shadows.
;         Other keywords: ALIGNMENT,COLOR,FONT,ORIENTATION,CHARSIZE.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: BOLD and COLOR may be 1-d arrays to outline text in
;         one or more colors.  Put thickest first.
; MODIFICATION HISTORY:
;       R. Sterner, 21 June, 1990
;       R. Sterner, 1994 Apr 4 --- Allowed 2-d BOLD.
;       R. Sterner, 2000 Aug 4 --- Fixed bug for bold=0.
;       R. Sterner, 2000 Nov 14 --- Added SHIFT for drop shadows.
;       R. Sterner, 2002 Feb 04 --- Made default font be !p.font.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xyoutb, x, y, text, help=hlp,alignment=ka,color=kc,data=kda,$
	    device=kde,font=kf,normal=kn,orientation=ko,size=ks,bold=kb, $
	    pixels=px, charsize=charsize, shift=shft
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Bold text version of xyouts.'
	  print,' xyoutb, x, y, text'
	  print,'   x,y = text position.           in'
	  print,'   text = text string to plot.    in'
	  print,' Keywords:'
	  print,'   /DATA use data coordinates (default).'
	  print,'   /DEVICE use device coordinates.'
	  print,'   /NORM use normalized coordinates.'
	  print,'   BOLD=N  Text is replotted N X N times,'
	  print,'     shifting by P pixel in x or y each time.'
	  print,'     Default N=2.  For hardcopy try about 5.''
	  print,'     BOLD may also be set to an N x M array which defines'
	  print,'     a brush stroke by non-zero elements.  For example:'
	  print,'     BOLD=shift(dist(3),-2,-2) lt 1.2'
	  print,'   PIXELS=P number of pixels to use for each shift (def=1).'
	  print,'     For hardcopy try 5 or 10.'
	  print,'   SHIFT=shft 2 element array giving pixel shift for each'
	  print,'     value of bold and color (def=0).  Good for drop shadows.'
	  print,'   Other keywords: ALIGNMENT,COLOR,FONT,ORIENTATION,CHARSIZE.'
	  print,'   Notes: BOLD and COLOR may be 1-d arrays to outline text in'
	  print,'     one or more colors.  Put thickest first.'
	  return
	endif
 
	;--------  Check if multiple thicknesses requested  ---------
	if n_elements(shft) eq 0 then shft=[0,0]
	if n_elements(shft) eq 1 then shft=[shft,0]
	if n_elements(kc) eq 0 then kc=!p.color
	lst = n_elements(kc)-1			; Last color.
	if (size(kb))(0) eq 1 then begin	; Use recursion.
	  for i=0, n_elements(kb)-1 do begin 
	    xyoutb, x, y, text, alignment=ka,color=kc(i<lst),data=kda,$
	      device=kde,font=kf,normal=kn,orientation=ko,size=ks,bold=kb(i), $
	      pixels=px, charsize=charsize, shift=i*[shft(0),shft(1)]
	  endfor
	  return
	endif
	;-------------------------------------------------------------
 
	if n_elements(charsize) ne 0 then ks = charsize
 
	;-------  Find text position in device coordinates  ------
	if keyword_set(kde) then begin		; /DEV.
	  xdv = x
	  ydv = y
	endif else begin
	  if keyword_set(kn) then begin
	    todev, x, y, xdv, ydv, /norm	; /NORM.
	  endif else todev, x, y, xdv, ydv      ; /DATA.
	endelse
 
	;---------  Offset by shift  ---------------------
	xdv = xdv + shft(0)
	ydv = ydv + shft(1)
 
	;---------  Handle brush  ----------
	if n_elements(kb) eq 0 then kb = 2		; Default is bold=2.
	kb = kb>1					; Min is 1.
	sz = size(kb)
	if sz(0) le 1 then br=bytarr(kb,kb)+1 else br=kb  ; Define brush.
	sz = size(br)					; Brush size in x and y.
	nx = sz(1)
	ny = sz(2)
	w = where(br ne 0, cnt)				; Find brush shape.
	if cnt eq 0 then begin
	  bell
	  print,' Error in xyoutb: BOLD was set to a 2-d array.  Must'
	  print,'   have at least 1 non-zero element.'
	  return
	endif
	one2two, w, br, xx, yy				; Want 2-d shifts.
	xx = xx-(nx-1)/2				; Shift table.
	yy = yy-(ny-1)/2
	n = n_elements(xx)				; Number of shifts.
 
	if n_elements(px) eq 0 then px = 1		; Def. pixels.
	xx = xx*px					; Shift size.
	yy = yy*px
 
	if n_elements(ka) eq 0 then ka = 0.		; Def. align
	if n_elements(kc) eq 0 then begin
	  if !d.name ne 'PS' then begin			; Def. color
	    kc = !p.color				;   If not PS.
	  endif else begin
	    kc = 0					; For PS.
	  endelse
	endif
;	if n_elements(kf) eq 0 then kf = -1		; Def. font
	if n_elements(kf) eq 0 then kf = !p.font	; Def. font
	if n_elements(ko) eq 0 then ko = 0.		; Def. orient
	if n_elements(ks) eq 0 then ks = 1.		; Def. size
 
	for i = 0, n-1 do begin
	  xyouts, xdv+xx(i), ydv+yy(i), text, /dev, align=ka, color=kc, $
	    font=kf, orient=ko, size=ks
	endfor
 
	return
	end
