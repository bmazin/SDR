;-------------------------------------------------------------
;+
; NAME:
;       IMG_MERGE
; PURPOSE:
;       Merge color components into a 24-bit color image.
; CATEGORY:
; CALLING SEQUENCE:
;       img = img_merge(c1, c2, c3)
; INPUTS:
;       c1 = color component 1.   in
;       c2 = color component 2.   in
;       c3 = color component 3.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /HSV means color components are HSV (def RGB).
;         TRUE=tr Specify dimension to interleave (1, 2, or 3=def).
;         NX=nx, NY=ny Returned image dimensions.
;         ERROR=err error flag: 0=ok, 1=input not 2-D
; OUTPUTS:
;       img = Output image.       out
;          By default c1,c2,c3 = Red, Green, Blue.
;          /HSV means c1, c2, c3 =  Hue, Saturation, Value.
; COMMON BLOCKS:
; NOTES:
;       Note: input color components are 2-D.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jun 21
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_merge, c1, c2, c3, true=typ, nx=nx, ny=ny, $
	  hsv=hsv, error=err, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Merge color components into a 24-bit color image.'
	  print,' img = img_merge(c1, c2, c3)'
	  print,'   c1 = color component 1.   in'
	  print,'   c2 = color component 2.   in'
	  print,'   c3 = color component 3.   in'
	  print,'   img = Output image.       out'
	  print,'      By default c1,c2,c3 = Red, Green, Blue.'
	  print,'      /HSV means c1, c2, c3 =  Hue, Saturation, Value.'
	  print,' Keywords:'
	  print,'   /HSV means color components are HSV (def RGB).'
	  print,'   TRUE=tr Specify dimension to interleave (1, 2, or 3=def).'
	  print,'   NX=nx, NY=ny Returned image dimensions.'
	  print,'   ERROR=err error flag: 0=ok, 1=input not 2-D'
	  print,' Note: input color components are 2-D.'
	  return,''
	endif
 
	err = 0
 
	;--------  Find image dimensions  --------------
	nd1 = (size(c1))(0)
	nd2 = (size(c2))(0)
	nd3 = (size(c3))(0)
	nd = [nd1,nd2,nd3]
	if (min(nd) lt 2) or (max(nd) gt 2) then begin
	  err = 1
	  print,' Error in img_merge: input color arrays must be 2-D.'
	  return,''
	endif
	sz = size(c1)
	nx = sz(1)		; Image dimensions.
	ny = sz(2)
	dtyp = sz(sz(0)+1)	; Incoming data type.
 
	if n_elements(typ) eq 0 then typ=3
 
	if keyword_set(hsv) then begin
	  color_convert,c1,c2,c3,r,g,b,/hsv_rgb
	endif else begin
	  r = c1
	  g = c2
	  b = c3
	endelse
 
	;-------  Recombine as requested  --------------
	case typ of
1:	begin
	  out = make_array(3,nx,ny,type=dtyp)
	  out(0,*,*) = r
	  out(1,*,*) = g
	  out(2,*,*) = b
	end
2:	begin
	  out = make_array(nx,3,ny,type=dtyp)
	  out(*,0,*) = r
	  out(*,1,*) = g
	  out(*,2,*) = b
	end
3:	begin
	  out = make_array(nx,ny,3,type=dtyp)
	  out(*,*,0) = r
	  out(*,*,1) = g
	  out(*,*,2) = b
	end
	endcase
 
	return, out
 
	end
