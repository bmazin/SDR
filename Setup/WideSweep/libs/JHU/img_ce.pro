;-------------------------------------------------------------
;+
; NAME:
;       IMG_CE
; PURPOSE:
;       Color image contrast enhancement.
; CATEGORY:
; CALLING SEQUENCE:
;       img_ce, in, sc
; INPUTS:
;       in = input image to scale.  Need not be 8 bit.  in
;          Allowed data types: Byte, Int, Uint.
;          8-bit images are 2-D, full color images are
;          3-D, interleaved in dimension 1, 2, or 3 as
;          usual even if they are INT or UINT data type.
;       sc = image scaling structure.                   in
;          This structure is made by img_ice.
;          Structure: {rx:rx,ry:ry,gx:gx,gy:gy,bx:bx,by:by}
;          These values are from -1 to 1.
;          x is related to brightness, y to contrast.
;          For 8-bit images only rx and ry are needed and used.
; KEYWORD PARAMETERS:
;       Keywords:
;         OUT=out  Returned scaled image (BYTE).  out
;         /DISP display resulting image.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 12
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_ce_scale, in, ch, sc, x_in, x_mn
 
	;-------  scaling values  ---------
	case ch of
1:	begin	; RED
	  x = sc.rx
	  y = sc.ry
	end
2:	begin	; GREEN
	  x = sc.gx
	  y = sc.gy
	end
3:	begin	; BLUE
	  x = sc.bx
	  y = sc.by
	end
	endcase
 
	;------  Compute new scaling function  ---------
	yy = (90*y)<90>(-90)		; Angle.
	slp = tan(yy/!radeg)		; Slope
	if slp eq 0 then slpr=1000. else slpr=1/abs(slp)
	off = x*(1+slpr)		; Offset.
 
	;------  Scale color component  ------------------
	v = slp*(x_in-off)>(-1)<1
	y_out = byte(round(127.5*(v+1)))
	out = y_out(in-x_mn)		; Scale color component.
	
	return, out
 
	end
 
 
;-------------------------------------------------------------------------------
;	img_ce.pro = Image contrast enhancement
;-------------------------------------------------------------------------------
 
	pro img_ce, img, sc, out=out, display=display, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Color image contrast enhancement.'
	  print,' img_ce, in, sc'
	  print,'   in = input image to scale.  Need not be 8 bit.  in'
	  print,'      Allowed data types: Byte, Int, Uint.'
	  print,'      8-bit images are 2-D, full color images are'
	  print,'      3-D, interleaved in dimension 1, 2, or 3 as'
	  print,'      usual even if they are INT or UINT data type.'
	  print,'   sc = image scaling structure.                   in'
	  print,'      This structure is made by img_ice.'
	  print,'      Structure: {rx:rx,ry:ry,gx:gx,gy:gy,bx:bx,by:by}'
	  print,'      These values are from -1 to 1.'
	  print,'      x is related to brightness, y to contrast.'
	  print,'      For 8-bit images only rx and ry are needed and used.'
	  print,' Keywords:'
	  print,'   OUT=out  Returned scaled image (BYTE).  out'
	  print,'   /DISP display resulting image.'
	  return
	endif
 
	;--------  Check image type and get type values  ---------
	typ = datatype(img)
	ityp = ''
	case typ of
'BYT':	begin
	  ityp = typ
	  x_mn = 0
	  x_n = 256
	  x_n = 256
	end
'INT':	begin
	  ityp = typ
	  x_mn = -32768
	  x_n = 65536
	end
'UIN':	begin
	  ityp = typ
	  x_mn = 0
	  x_n = 65536
	end
else:
	endcase
	if ityp eq '' then begin
	  print,' Error in img_ce: Allowed image types are'
	  print,'   BYT, INT, UINT.'
	  return
	endif
	x_in = maken(-1.,1.,x_n)	; Image input.
 
	;--------  Image components  ----------------
	img_split, img, r, g, b, true=tr	; tr=0 if 8-bit.
 
	if tr ne 0 then begin
	  rr = img_ce_scale(r, 1, sc, x_in, x_mn)
	  gg = img_ce_scale(g, 2, sc, x_in, x_mn)
	  bb = img_ce_scale(b, 3, sc, x_in, x_mn)
	  out = img_merge(rr,gg,bb,true=tr)
	endif else begin
	  out = img_ce_scale(r, 1, sc, x_in, x_mn)
	endelse
 
	;--------  Display  --------------------------
	if keyword_set(display) then img_disp, out
 
	end
