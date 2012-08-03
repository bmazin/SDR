;-------------------------------------------------------------
;+
; NAME:
;       PICKCOLOR
; PURPOSE:
;       Allow user to pick a color from current color table.
; CATEGORY:
; CALLING SEQUENCE:
;       pickcolor, clr
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: if clr is given as an input it is the default.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Oct 7.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro pickcolor, in, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Allow user to pick a color from current color table.'
	  print,' pickcolor, clr'
	  print,'   clr = selected color index (-1 means none).   in,out'
	  print,' Notes: if clr is given as an input it is the default.'
	  return
	endif
 
	;--------  Set up selection window  ------------
	window,xs=512,ys=512+64,/free, title='Click mouse on a color'
	win = !d.window
	lum = ct_luminance(dark=dark, bright=bright)
	erase,bright
	tv,bytarr(512,64)+dark,0,512
	xyoutb,5,534,charsize=2.5,'Selected color',/dev
	mxc = topc()				; Top color.
	ptch = bytarr(128,64)			; Color patch.
	;------  Cancel button  ---------
	a=bytarr(191,64)			; Cancel button image.
	imgfrm,a,maken(dark,bright,10)		; Make frame around button.
	tv,a,321,512				; Display cancel button.
	xyoutb,416,534,charsize=2.5,'CANCEL',align=.5,/dev
 
 
	;--------  Display color choices  --------
	for i=0,mxc do begin			; Display each color choice.
	  b = bytarr(32,32)+i
          imgfrm,b,[bright,dark]		; Frame to make edges visible.
	  jx = (i*32) mod 512			; Find position.
	  jy = (i/16)*32
	  tv,b,jx,jy				; Display.
	endfor
 
	;-------  Pick a color  ----------
	lx = -10			; Last mouse position.
	ly = -10
	lin = -1			; Last color index.
	if n_elements(in) eq 0 then in = 0
	ix = ((in*32) mod 512) + 16
	iy = (in/16)*32 + 16
	tvcrs, ix, iy
	!mouse.button = 0		; Clear mouse button flag.
	while !mouse.button eq 0 do begin	; Main loop.
	  cursor, ix, iy, /dev, /nowait		; Check position.
	  if (ix eq lx) and (iy eq ly) then begin
	    cursor, ix, iy, /dev, /change	; Same as last, wait.
	  endif
	  lx = ix			; Save last position.
	  ly = iy
	  jx = ix/32			; Compute new color index.
	  jy = iy/32
	  in0 = jx + 16*jy
	  in = in0<mxc			; Clip to top color.
	  if in0 ne lin then begin	; New color.
	    tv, ptch+in, 192,512	; Display color.
	    intxt = strtrim(in,2)	;   and color number.
	    if (in0 ge 266) and (jx ge 10) then intxt = 'None'
	    xyoutb,/dev,256,530,align=.5,intxt,bold=5,col=dark,chars=4.5
	    xyoutb,/dev,256,530,align=.5,intxt,bold=3,col=bright,chars=4.5
	    lin = in0			; Save color index.
	  endif
	endwhile
 
	if intxt eq 'None' then in = -1
	wdelete, win			; Delete window.
	return
	end
