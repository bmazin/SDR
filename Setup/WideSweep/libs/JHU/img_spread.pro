;-------------------------------------------------------------
;+
; NAME:
;       IMG_SPREAD
; PURPOSE:
;       Spread image values over total range of image data type.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_spread(in)
; INPUTS:
;       in = Input color image. May be Byte Int, Uint.  in
; KEYWORD PARAMETERS:
;       Keywords:
;       MISSING=miss Values to ignore for processing.  Restore
;         when done.
;       WMISS=wmiss  1-d indices into each color component
;         where data missing (-1 if no missing data).
;       WGOOD=wgood  1-d indices into each color component
;         where data is good.
;       HIST=[lo,hi] Use histogram scaling.  Must give a two
;         element array with percentages to cut off the low and
;         high end of the histogram.  To cut off the low and high
;         1% give HIST=[1,1].  Give HIST=[0,0] to scale from image
;         min to max.  Histogram scaling operates channel by channel.
; OUTPUTS:
;       out = Returned image of same type.		    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 13
;       R. Sterner, 2002 Jun 21 --- Added histogram scaling, HIST=hst.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_spread, in, missing=miss, wmiss=wmiss, wgood=w, $
	  hist=hst, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Spread image values over total range of image data type.'
	  print,' out = img_spread(in)'
	  print,'   in = Input color image. May be Byte Int, Uint.  in'
	  print,'   out = Returned image of same type.		    out'
	  print,' Keywords:'
	  print,' MISSING=miss Values to ignore for processing.  Restore'
	  print,'   when done.'
	  print,' WMISS=wmiss  1-d indices into each color component'
	  print,'   where data missing (-1 if no missing data).'
	  print,' WGOOD=wgood  1-d indices into each color component'
	  print,'   where data is good.'
	  print,' HIST=[lo,hi] Use histogram scaling.  Must give a two'
	  print,'   element array with percentages to cut off the low and'
	  print,'   high end of the histogram.  To cut off the low and high'
	  print,'   1% give HIST=[1,1].  Give HIST=[0,0] to scale from image'
	  print,'   min to max.  Histogram scaling operates channel by channel.'
	  return, ''
	endif
 
	;--------  Check image type and get type values  ---------
	typ = datatype(in)
	ityp = ''
	case typ of
'BYT':	begin
	  ityp = typ
	  x_mn = 0
	  x_mx = 255
	end
'INT':	begin
	  ityp = typ
	  x_mn = -32768
	  x_mx = 32767
	end
'UIN':	begin
	  ityp = typ
	  x_mn = 0
	  x_mx = 65535
	end
else:
	endcase
	if ityp eq '' then begin
	  print,' Error in img_spread: Allowed image types are'
	  print,'   BYT, INT, UINT.'
	  return, ''
	endif
 
	;-------  Split image into components  ------
	img_split, in, r,g,b,true=tr
 
	;-------  Deal with histogram scaling method  -------
	if n_elements(hst) eq 2 then begin
	  lo = hst(0)		; Grab histogram cutoffs.
	  hi = hst(1)
	  r2 = ls2(r,lo,hi,miss=miss,wmiss=wmiss,wgood=w)  ; Scale red.
	  if tr eq 0 then begin		; 8-bit image.
	    case ityp of		; Return as correct type.
'BYT':	    out = byte(r2)
'INT':	    out = fix(r2)
'UIN':	    out = uint(r2)
	    endcase
	    return, out
	  endif
	  g2 = ls2(g,lo,hi,miss=miss,wmiss=wmiss,wgood=w)  ; Scale green.
	  b2 = ls2(b,lo,hi,miss=miss,wmiss=wmiss,wgood=w)  ; Scale blue.
	  case ityp of		; Remerge as correct type.
'BYT':	  out = byte(img_merge(r2,g2,b2,true=tr))
'INT':	  out = fix(img_merge(r2,g2,b2,true=tr))
'UIN':	  out = uint(img_merge(r2,g2,b2,true=tr))
	  endcase
	  return, out
	endif
 
	;-------  Deal with MISSING (w = good elements) -----
	if n_elements(miss) eq 0 then begin
	  cnt = n_elements(r)
	  w = lindgen(cnt)
	  wmiss = -1
	endif else begin
	  w = where(r ne miss,cnt)
	  wmiss = where(r eq miss,cnt)
	endelse
 
	;--------  Find overall min/max  ----------------
	imn = min(r(w)<g(w)<b(w))
	imx = max(r(w)>g(w)>b(w))
 
	;--------  Scale image values to full range  -------
	case ityp of
'BYT':	out = byte(scalearray(in,imn,imx,x_mn,x_mx)>x_mn<x_mx)
'INT':	out = fix(scalearray(in,imn,imx,x_mn,x_mx)>x_mn<x_mx)
'UIN':	out = uint(scalearray(in,imn,imx,x_mn,x_mx)>x_mn<x_mx)
	endcase
 
	return, out
 
	end
