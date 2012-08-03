;-------------------------------------------------------------
;+
; NAME:
;       AUTOCOLOR
; PURPOSE:
;       Print text on an image using automatic colors.
; CATEGORY:
; CALLING SEQUENCE:
;       autocolor, x, y, text
; INPUTS:
;       x,y = coordinates for text.  in
;       text = text to print.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         NX=nx, NY=ny: region of image from lower left corner
;           to use to determine print colors.  Def: nx=500, ny=300.
;         BOLD=b Thickness of text.  A background 2 pixels wider
;           will be plotted in a darker color.
;         TH=th  Contrast difference desired (def=0.33).
;         /ANTIALIASED does antialiased text (slow).
;         Most XYOUTB keywords may be given.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: The intention is to use colors from the image for
;         the text.  No attempt is made to see how common an image
;         color is so unexpected colors may show up.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Mar 23
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro autocolor, x, y, text, nx=nx, ny=ny, th=th0, $
	  bold=bold, antialiased=anti, _extra=extra, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Print text on an image using automatic colors.'
	  print,' autocolor, x, y, text'
	  print,'   x,y = coordinates for text.  in'
	  print,'   text = text to print.        in'
	  print,' Keywords:'
	  print,'   NX=nx, NY=ny: region of image from lower left corner'
	  print,'     to use to determine print colors.  Def: nx=500, ny=300.'
	  print,'   BOLD=b Thickness of text.  A background 2 pixels wider'
	  print,'     will be plotted in a darker color.'
	  print,'   TH=th  Contrast difference desired (def=0.33).'
	  print,'   /ANTIALIASED does antialiased text (slow).'
	  print,'   Most XYOUTB keywords may be given.'
	  print,' Notes: The intention is to use colors from the image for'
	  print,'   the text.  No attempt is made to see how common an image'
	  print,'   color is so unexpected colors may show up.'
	  return
	endif
 
	;-----  read image  ---------
	img = tvrd(tr=3)
	img_shape, img, nx=xs, ny=ys
 
	;-----  Color search area  ------
	if n_elements(nx) eq 0 then nx=500<xs
	if n_elements(ny) eq 0 then ny=300<ys
 
	;-----  Find colors to use  -----
	r = img(0:nx-1,0:ny-1,0)			; R
	g = img(0:nx-1,0:ny-1,1)			; G
	b = img(0:nx-1,0:ny-1,2)			; B
	lum = 0.3*r + 0.59*g + 0.11*b			; Compute luminance.
	wmn = (where(lum eq min(lum)))(0)		; Darkest color.
	wmx = (where(lum eq max(lum)))(0)		; Brightest color.
	color_convert, r, g, b, h, s, v, /rgb_hsv	; Convert to HSV.
	hmn = h(wmn)					; Dark.
	smn = s(wmn)
	vmn = v(wmn)
	hmx = h(wmx)					; Bright.
	smx = s(wmx)
	vmx = v(wmx)
	if n_elements(th0) eq 0 then th0=0.33
	th = th0<1.>0.
	dv = vmx-vmn
	md = midv([vmn,vmx])				; Mid-value.
	f = th/dv					; Factor needed.
	vmx = (md+f*dv/2)<1.				; New vmx.
	vmn = vmx - th					; New vmn.
	if vmn lt 0 then begin				; Keep > 0.
	  vmn = 0
	  vmx = th
	endif
	cmn = tarclr(/hsv,hmn,smn,vmn)			; Min color.
	cmx = tarclr(/hsv,hmx,smx,vmx)			; Max color.
 
	;------  Print text on image  -------
	if n_elements(bold) eq 0 then bold=1
 
	if keyword_set(anti) then begin
	  img = img_text(img,x,y,text,_extra=extra,charthick=bold+4,$
	    /anti,col=cmn)
	  img = img_text(img,x,y,text,_extra=extra,charthick=bold,$
	    /anti,col=cmx)
	  tv,img,tr=3
	endif else begin
	  xyoutb, x, y, text, _extra=extra, bold=bold+2, col=cmn ; Background.
	  xyoutb, x, y, text, _extra=extra, bold=bold, col=cmx	 ; Text.
	endelse
 
	end
