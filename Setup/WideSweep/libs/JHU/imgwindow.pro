;-------------------------------------------------------------
;+
; NAME:
;       IMGWINDOW
; PURPOSE:
;       Compute plot window needed to display given image.
; CATEGORY:
; CALLING SEQUENCE:
;       t = imgwindow(img, xmn,xmx,ymn,ymx)
; INPUTS:
;       img = Image. For size only.               in
;       xmn, xmx = Normalized X for plot window.  in
;       ymn, ymx = Normalized Y for plot window.  in
;          One and only one of xmn,xmx,ymn, or ymx
;          must be -1.  This is the value to be computed.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: May use result with the routine set_window:
;         set_window,x1,x2,y1,y2,xnrange=[xmn,xmx],ynrange=[ymn,ymx]
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Oct 31
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function imgwindow, img, xmn,xmx,ymn,ymx, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Compute plot window needed to display given image.'
	  print,' t = imgwindow(img, xmn,xmx,ymn,ymx)'
	  print,'   img = Image. For size only.               in'
	  print,'   xmn, xmx = Normalized X for plot window.  in'
	  print,'   ymn, ymx = Normalized Y for plot window.  in'
	  print,'      One and only one of xmn,xmx,ymn, or ymx'
	  print,'      must be -1.  This is the value to be computed.'
	  print,' Notes: May use result with the routine set_window:'
	  print,'   set_window,x1,x2,y1,y2,xnrange=[xmn,xmx],ynrange=[ymn,ymx]'
	  return,''
	endif
 
	;------  Check for flag value  ---------
	t = [xmn,xmx,ymn,ymx]
	w = where(t eq -1, cnt)
	if cnt ne 1 then begin
	  print,' Error in imgwindow: must set one of xmn,xmx,ymn,ymx'
	  print,'   to -1.  That indicates which value to compute.'
	  return,-1
	endif
 
	;-------  Get shape of image  ---------
	sz = size(img)
	nx = sz(1)
	ny = sz(2)
 
	;-------  Compute xmn  ----------------
	if xmn eq -1 then begin
	  t = convert_coord([0,xmx],[ymn,ymx],/norm,/to_dev)
	  iy1 = t(1,0)
	  iy2 = t(1,1)
	  ix2 = t(0,1)
	  idy = iy2 - iy1
	  idx = float(nx)/ny*idy
	  ix1 = round(ix2-idx)
	  t = convert_coord([ix1,ix2],[iy1,iy2],/dev,/to_norm)
	  return, t(0,0)
	endif
 
	;-------  Compute xmx  ----------------
	if xmx eq -1 then begin
	  t = convert_coord([xmn,1],[ymn,ymx],/norm,/to_dev)
	  iy1 = t(1,0)
	  iy2 = t(1,1)
	  ix1 = t(0,0)
	  idy = iy2 - iy1
	  idx = float(nx)/ny*idy
	  ix2 = round(ix1+idx)
	  t = convert_coord([ix1,ix2],[iy1,iy2],/dev,/to_norm)
	  return, t(0,1)
	endif
 
	;-------  Compute ymn  ----------------
	if ymn eq -1 then begin
	  t = convert_coord([xmn,xmx],[0,ymx],/norm,/to_dev)
	  ix1 = t(0,0)
	  ix2 = t(0,1)
	  iy2 = t(1,1)
	  idx = ix2 - ix1
	  idy = float(ny)/nx*idx
	  iy1 = round(iy2-idy)
	  t = convert_coord([ix1,ix2],[iy1,iy2],/dev,/to_norm)
	  return, t(1,0)
	endif
 
	;-------  Compute ymx  ----------------
	if ymx eq -1 then begin
	  t = convert_coord([xmn,xmx],[ymn,1],/norm,/to_dev)
	  ix1 = t(0,0)
	  ix2 = t(0,1)
	  iy1 = t(1,0)
	  idx = ix2 - ix1
	  idy = float(ny)/nx*idx
	  iy2 = round(iy1+idy)
	  t = convert_coord([ix1,ix2],[iy1,iy2],/dev,/to_norm)
	  return, t(1,1)
	endif
 
	end
