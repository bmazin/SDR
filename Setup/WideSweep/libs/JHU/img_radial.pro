;-------------------------------------------------------------
;+
; NAME:
;       IMG_RADIAL
; PURPOSE:
;       Radially distort a 2-D or 3-D image array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_radial(in)
; INPUTS:
;       in = Input image.           in
; KEYWORD PARAMETERS:
;       Keywords:
;         COEFF=coeff Array of 4 coefficients.
;           [a,b,c,d] where d scales image by 1/d,
;           a,b,c distort image.
;         Can use RED=red, GRN=grn, BLU=blu to set different
;           corrections for each color.  If coeffecients not given
;           then that color is not changed.  Use COEFF if same
;           for all 3 colors.
;         XOPT=x, YOPT=y image pixel of optical axis (else centered).
;         ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,
;           2=wrong number of color channels for 3-D array.
;         /TEST test mode.  Returns needed radial values along
;           source image x axis only.  Input image must be a 1-d
;           array of normalized x values (0 to 1, or -1 to 1).
;           XOPT may be given (normalized, def=0).  Plot returned
;           result to see the effects of a,b,c, and d values.
; OUTPUTS:
;       out = Resized image.        out
; COMMON BLOCKS:
;       img_radial_remap_com
; NOTES:
;       Note: deals with 2-D or 3-D image arrays and distorts
;         correct image planes.
;         Based on algorithm given in:
;         http://www.fh-furtwangen.de/~dersch/barrel/barrel.html
; MODIFICATION HISTORY:
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_radial_test, img, coeff, xopt=xopt
 
	if n_elements(coeff) eq 0 then begin
	  print,' Error in img_radial /TEST mode: Must give COEFF array.'
	  return, img
	endif
 
	nx = n_elements(img)
	if n_elements(xopt) eq 0 then begin
	  xc = 0			  ; Assume optical axis centered.
	endif else begin
	  xc = xopt			  ; If optical axis x given use it.
	endelse
 
	x1 = img-xc			  ; Offset to 0 at center.
	r1 = abs(x1)
	a=coeff(0) & b=coeff(1) & c=coeff(2) & d=coeff(3)
 
	r2 = r1*(a*r1^3 + b*r1^2 + c*r1 + d)
 
	return, r2
 
	end
 
;---------------------------------------------------------
;	img_radial_remap = Do remapping
;	  /last to use last mapping arrays.
;---------------------------------------------------------
 
	function img_radial_remap, img, nx,ny,coeff, $
	  last=last, xopt=xopt, yopt=yopt
 
	common img_radial_remap_com, x2, y2
 
	if n_elements(last) eq 0 then begin	; New mapping arrays.
	  if n_elements(coeff) eq 0 then return, img	; No coeff, no change.
	  makexy,0,nx-1,1,0,ny-1,1,x0,y0  ; Index arrays.
	  if n_elements(xopt) eq 0 then begin
	    xc = (nx-1.)/2.		  ; Assume optical axis centered.
	  endif else begin
	    xc = xopt			  ; If optical axis x given use it.
	  endelse
	  if n_elements(yopt) eq 0 then begin
	    yc = (ny-1.)/2.		  ; Assume optical axis centered.
	  endif else begin
	    yc = yopt			  ; If optical axis y given use it.
	  endelse
	  x1 = x0-xc			  ; Offset to 0 at center.
	  y1 = y0-yc
	  recpol,x1,y1,r1,a1		  ; Convert to polar.
	  r1n = r1/((nx<ny)-1.)		  ; Normalized radius.
	  a=coeff(0) & b=coeff(1) & c=coeff(2) & d=coeff(3)
	  r2 = r1*(a*r1n^3 + b*r1n^2 + c*r1n + d)
	  polrec,r2,a1,x2,y2
	  x2 = x2 + xc
	  y2 = y2 + yc
	endif
 
	out = interpolate(img,x2,y2,cubic=-0.5,miss=0)
 
	return, out
 
	end
 
;---------------------------------------------------------
;	img_radial.pro = Radial image distortion
;	R. Sterner, 2001 Jan 26
;---------------------------------------------------------
 
	function img_radial, img, coeff=coeff, red=red, grn=grn, blu=blu, $
	  xopt=xopt, yopt=yopt, error=err, test=test, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Radially distort a 2-D or 3-D image array.'
	  print,' out = img_radial(in)'
	  print,'   in = Input image.           in'
	  print,'   out = Resized image.        out'
	  print,' Keywords:'
	  print,'   COEFF=coeff Array of 4 coefficients.'
	  print,'     [a,b,c,d] where d scales image by 1/d,'
	  print,'     a,b,c distort image.'
	  print,'   Can use RED=red, GRN=grn, BLU=blu to set different'
	  print,'     corrections for each color.  If coeffecients not given'
	  print,'     then that color is not changed.  Use COEFF if same'
	  print,'     for all 3 colors.'
	  print,'   XOPT=x, YOPT=y image pixel of optical axis (else centered).'
	  print,'   ERROR=err error flag: 0=ok, 1=not 2-D or 3-D,'
	  print,'     2=wrong number of color channels for 3-D array.'
	  print,'   /TEST test mode.  Returns needed radial values along'
	  print,'     source image x axis only.  Input image must be a 1-d'
	  print,'     array of normalized x values (0 to 1, or -1 to 1).'
	  print,'     XOPT may be given (normalized, def=0).  Plot returned'
	  print,'     result to see the effects of a,b,c, and d values.'
	  print,' Note: deals with 2-D or 3-D image arrays and distorts'
	  print,'   correct image planes.'
	  print,'   Based on algorithm given in:'
	  print,'   http://www.fh-furtwangen.de/~dersch/barrel/barrel.html'
	  return, ''
	endif
 
	;--------  Special 1-d test mode  ------------------
	if keyword_set(test) then begin
	  sz = size(img)
	  ndim = sz(0)	
	  if ndim ne 1 then begin
	    print,' Error in img_radial /test mode: input image must actually'
	    print,'   be normalized values along the output x axis.'
	    print,'   For example, from image center to edge img contains a'
	    print,'   1-d array of values from 0 to 1.  For a cut through'
	    print,'   the image (along x) img is 1-d with values from -1 to 1.'
	    print,'   Returns 1-d indices into source image (along x).'
	    print,'   May give XOPT=xopt (X only).'
	  endif
	  out = img_radial_test(img, coeff, xopt=xopt)
	  return, out
	endif
 
	err = 0
 
	;--------  Find image dimensions  --------------
	sz = size(img)
	ndim = sz(0)
	if (ndim lt 2) or (ndim gt 3) then begin
	  err = 1
	  print,' Error in img_radial: given array must 2-D or 3-D.'
	  return, img
	endif
	dtyp = sz(sz(0)+1)
 
	;--------  2-D image  --------------------------
	if ndim eq 2 then begin
	  nx = sz(1)			  ; X size.
	  ny = sz(2)			  ; Y size.
	  out = img_radial_remap(img, nx,ny, coeff, xopt=xopt, yopt=yopt)
	  return, out
	endif
 
	;---------  Default coeffecients  --------------
	if n_elements(coeff) gt 0 then begin	  ; Use coeff if same for all
	  if n_elements(red) eq 0 then red=coeff  ; color channels.
	  if n_elements(grn) eq 0 then grn=coeff
	  if n_elements(blu) eq 0 then blu=coeff
	endif
 
	;--------  3-D image  --------------------------
	typ = 0
	if sz(1) eq 3 then typ=1  ; Find which dimension interleaved.
	if sz(2) eq 3 then typ=2
	if sz(3) eq 3 then typ=3
	if typ eq 0 then begin
	  err = 2
	  print,' Error in img_radial: given array must have a dimension of 3.'
	  return, img
	endif
 
	case typ of
1:	begin
	  nx = sz(2)
	  ny = sz(3)
	  r = reform(img(0,*,*))
	  g = reform(img(1,*,*))
	  b = reform(img(2,*,*))
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = img_radial_remap(r,nx,ny,red,xopt=xopt,yopt=yopt)
	  out(1,*,*) = img_radial_remap(g,nx,ny,grn,xopt=xopt,yopt=yopt)
	  out(2,*,*) = img_radial_remap(b,nx,ny,blu,xopt=xopt,yopt=yopt)
	end
2:	begin
	  nx = sz(1)
	  ny = sz(3)
	  r = reform(img(*,0,*))
	  g = reform(img(*,1,*))
	  b = reform(img(*,2,*))
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = img_radial_remap(r,nx,ny,red,xopt=xopt,yopt=yopt)
	  out(*,1,*) = img_radial_remap(g,nx,ny,grn,xopt=xopt,yopt=yopt)
	  out(*,2,*) = img_radial_remap(b,nx,ny,blu,xopt=xopt,yopt=yopt)
	end
3:	begin
	  nx = sz(1)
	  ny = sz(2)
	  r = reform(img(*,*,0))
	  g = reform(img(*,*,1))
	  b = reform(img(*,*,2))
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = img_radial_remap(r,nx,ny,red,xopt=xopt,yopt=yopt)
	  out(*,*,1) = img_radial_remap(g,nx,ny,grn,xopt=xopt,yopt=yopt)
	  out(*,*,2) = img_radial_remap(b,nx,ny,blu,xopt=xopt,yopt=yopt)
	end
	endcase
 
	return, out
 
	end
