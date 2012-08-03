;-------------------------------------------------------------
;+
; NAME:
;       JPEG_MAG
; PURPOSE:
;       Change size of a JPEG image.
; CATEGORY:
; CALLING SEQUENCE:
;       jpeg_mag, in, out
; INPUTS:
;       in = name of input JPEG image.   in
;       out = name of output JPEG image. in
;         Default is *_.jpg where * is input image name.
; KEYWORD PARAMETERS:
;       Keywords:
;         MAG=mag  Mag factor, def=1/4.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Meant for reducing JPEG images to thumbnail versions.
; MODIFICATION HISTORY:
;       R. Sterner, 1995
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro jpeg_mag, in, out, mag=mag, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Change size of a JPEG image.'
	  print,' jpeg_mag, in, out'
	  print,'   in = name of input JPEG image.   in'
	  print,'   out = name of output JPEG image. in'
	  print,'     Default is *_.jpg where * is input image name.'
	  print,' Keywords:'
	  print,'   MAG=mag  Mag factor, def=1/4.'
	  print,' Notes: Meant for reducing JPEG images to thumbnail versions.'
	  return
	endif
 
	if n_elements(out) eq 0 then $
	  out=getwrd(in,-99,-1,/last,delim='.')+'_.jpg'
	if n_elements(mag) eq 0 then mag=0.25
 
        ;--------  Read input image  -------------
        print,' Reading '+in
        read_jpeg,in,a,ct,/dither,/two_pass,colors=256
 
	;-----  Split into RGB components and pack into 3-d array  --------
	r=ct(*,0) & g=ct(*,1) & b=ct(*,2)
	sz=size(a) & nx=sz(1) & ny=sz(2)
	nxs=mag*nx & nys=mag*ny
        img = bytarr(nx,ny,3)
        img(0,0,0) = r(a)       ; Extract and insert red component.
        img(0,0,1) = g(a)       ; Extract and insert grn component.
        img(0,0,2) = b(a)       ; Extract and insert blu component.
 
	;--------  Write output image  ----------
	print,' Writing '+out
	write_jpeg,out,congrid(img,nxs,nys,3),true=3
 
	return
	end
