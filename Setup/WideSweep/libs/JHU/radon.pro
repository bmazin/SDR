;-------------------------------------------------------------
;+
; NAME:
;       RADON
; PURPOSE:
;       Compute the Radon Transform using the FFT method.
; CATEGORY:
; CALLING SEQUENCE:
;       t = radon(img)
; INPUTS:
;       img = input image.  Must be square.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         EMBED=n  size of zero image to embed given image in.
;           Def=no embed.
;         START=a1  start angle in degrees, default=0.
;         STOP=a2  stop angle in degrees, default=179.
;         STEP=da  angle step in degrees, default=1.
;         ANGLES=ang  returned list of angles used.
;         /DEBUG does a debug stop.
; OUTPUTS:
;       t = Radon Transform of img.           out
; COMMON BLOCKS:
;       radon_com
; NOTES:
;       Notes: Images must be byte.
;         No preprocessing is done.
;         It may be useful to subtract the mean.
;         Ref: Linear feature detection and enhancement in noisy
;           images via the Radon transform,
;           Lesley M. Murphy, Patt. Rec. Letters 4 (1986) 279.
; MODIFICATION HISTORY:
;       R. Sterner, 16 Oct, 1990
;       R. Sterner, 1998 Mar 10 --- Cleaned up a bit, no longer byte only.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function radon, z0, start=a1, stop=a2, step=da, angles=ang, $
	  help=hlp, debug=debug, embed=nx0
 
	common radon_com, xt0, yt0, nx00, a10, a20, da0
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Compute the Radon Transform using the FFT method.'
	  print,' t = radon(img)'
	  print,'   img = input image.  Must be square.   in'
	  print,'   t = Radon Transform of img.           out'
	  print,' Keywords:'
	  print,'   EMBED=n  size of zero image to embed given image in.'
	  print,'     Def=no embed.'
	  print,'   START=a1  start angle in degrees, default=0.'
	  print,'   STOP=a2  stop angle in degrees, default=179.'
	  print,'   STEP=da  angle step in degrees, default=1.'
	  print,'   ANGLES=ang  returned list of angles used.'
	  print,'   /DEBUG does a debug stop.'
	  print,' Notes: Images must be byte.'
	  print,'   No preprocessing is done.'
	  print,'   It may be useful to subtract the mean.'
	  print,'   Ref: Linear feature detection and enhancement in noisy'
	  print,'     images via the Radon transform,'
	  print,'     Lesley M. Murphy, Patt. Rec. Letters 4 (1986) 279.'
	  return, -1
	endif
 
	;-----  Byte images only  --------
;	if datatype(z0) ne 'BYT' then begin
;	  print,' Error in radon: for byte images only.'
;	  return, -1
;	endif
 
	;-----  Get image size  -------
	sz = size(z0)			; Size of image.
	nx = sz(1)			; Size of side.
	ny = sz(2)
 
	;-----  Embed in a large image to get better spectral resolution  ----
	if n_elements(nx0) eq 0 then nx0 = nx
	if (nx>ny) gt nx0 then begin
	  print,' Error in Radon: embed size must be larger than image size.'
	  return, -1
	endif
	print,' Embedding image in a larger image . . .', nx0
;	z = bytarr(nx0,nx0)		; Embed in large image.
	z = fltarr(nx0,nx0)		; Embed in large image.
	h = nx0/2			; Half size.
	z(h-nx/2,h-ny/2) = z0
 
	;-------  Make sure all parameters have values  -----
	if n_elements(a1) eq 0 then a1 = 0.		; Def start angle = 0.
	if n_elements(a2) eq 0 then a2 = 179.		; Def stop angle = 179.
	if n_elements(da) eq 0 then da = 1.		; Def angle step = 1.
	if n_elements(nx00) eq 0 then begin		; Handle first call.
	  nx00 = 0
	  a10 = 0.
	  a20 = 0.
	  da0 = 0.
	endif
 
	;-------  Check if new indices must be generated  --------
	iflag = 0					; Assme old indices ok.
	if a1 ne a10 then iflag = 1			; New start angle.
	if a2 ne a20 then iflag = 1			; New stop angle.
	if da ne da0 then iflag = 1			; New angle step.
	if nx0 ne nx00 then iflag = 1			; New embed size.
 
	;--------  Save new values  ------
	a10 = a1					; Start angle.
	a20 = a2					; Stop angle.
	da0 = da					; Angle step.
	nx00 = nx0					; Embed size.
 
;	numang = fix(a2 - a1)/fix(da) + 1		; Number of angles.
	numang = round((a2 - a1)/da) + 1		; Number of angles.
;	ang = makex(a1, a2, da)				; List of angles used.
	ang = maken(a1, a2, numang)			; List of angles used.
 
	;-------  Make FFT cut indices once (remake if new image size) ----
	if iflag eq 1 then begin		; New indices needed?
	  print,' Generating indices . . .'
	  x = makex(1.-h, h-1., 1.)		; Initial cut (at 0 ang).
	  y= 0.*x
	  xt0 = fltarr(nx0, numang)		; Set up space to save indices
	  yt0 = xt0				;   for all FFT cuts.
	  ia = 0				; Index into index arrays.
;	  for a = a1, a2, da do begin		; Want a cut every da degrees.
	  for j = 0, numang-1 do begin		; Want a cut every angle.
	    a = ang(j)
	    rotate_xy, x, y, a/!radeg, 0., 0., xt, yt	;   Rotate initial cut.
	    xt = xt + h				;   Force indices in range.
	    yt = yt + h
	    xt0(0,ia) = xt			;   Cut indices for angle A.
	    yt0(0,ia) = yt
	    ia = ia + 1
	  endfor   ; Angle loop.
	endif   ; Cut Indices generation.
 
	;------  Shift image  ----------
	print,' Shifting image . . .'
	z = shift(z,-h,-h)
 
	;-----  Do FFT  ------
	print,' Doing FFT . . .'
	f = fft(z,-1)				; FFT of image.
	f = shift(f,h,h)			; Center DC.
 
	;------  Pull out all cuts from FFT  ------
	print,' Extracting cuts . . .'
	s = bilinear(f, xt0, yt0)		; Extract cuts.
 
	;-------  Inverse FFT each cut  ------
	print,' Doing inverse FFT . . .'
	r = float(s*0.)				; Storage space.
	for ia = 0, numang-1 do begin		; Loop through angles.
	  t = shift(s(*,ia),1-h)		; Extract and shift.
	  rt = float(fft(t,1))			; Inverse transform.
	  r(0,ia) = shift(rt,-h)		; Shift to center.
	endfor
 
	if keyword_set(debug) then begin
	  print,' RADON debug stop:'
	  print,'   f = DC centered FFT.'
	  print,'   r = radon transform.'
	  print,'   z0 = original image.'
	  print,'   s = radon transform before 1-d inverse FFT.'
	  stop
	endif
 
	lo = h-nx/2				; Trim off unused parts.
	hi = lo + nx - 1
	r = r(lo:hi, *)
 
	return, r
 
	end
