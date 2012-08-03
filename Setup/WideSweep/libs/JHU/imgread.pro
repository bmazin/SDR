;-------------------------------------------------------------
;+
; NAME:
;       IMGREAD
; PURPOSE:
;       Read part of a large image.
; CATEGORY:
; CALLING SEQUENCE:
;       out = imgread( x1, y1, [x2, y2])
; INPUTS:
;       x1 = starting pixel (first=0).       in
;       y1 = starting image line (first=0).  in
;       x2 = optional last pixel.            in
;       y2 = optional last image line.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         SS=ss   subsample factor for x and y (1=every pixel=def).
;         XSS=sx  subsample factor in x.
;         YSS=sy  subsample factor in y.
;         NX=nx   number of output pixels in x (def=512).
;         NY=ny   number of output pixels in y (def=512).
;         /REBIN means average pixels instead of subsampling.
;           The averaged image will appear shifted from the
;           subsampled image by an amount depending on the number
;           of pixels averaged. This happens because the subsampled
;           pixels are from the lower left corner of the averaged
;           pixels.
;         VALUE=v value for out-of-range parts of subimage (def=0).
;           If VALUE is not given then output image is trimmed
;           to be within the image being read.
;         ERROR=err  error flag.
;             0: OK, -1: part of subimage falls outside main image.
;            -2: not open for read, -3: parameter value error.
;         SHOW=s print a dot after every s lines is read.
;         /EXAMPLES  lists some example calls.
;         /DEBUG  does a debug stop.
; OUTPUTS:
; COMMON BLOCKS:
;       img_com
; NOTES:
;       Notes: Image opened by IMGREAD. Image need not be closed.
;         If x2, y2 are given they take precedence over NX and NY.
;         If x2, y2 are given and subsample factor is not 1 then
;           x2, y2 may not be included in output image.
; MODIFICATION HISTORY:
;       Ray Sterner, 13 Mar, 1991
;       R. Sterner, 17 Sep, 1991 --- added /REBIN, modified common.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function imgread, x11, y11, x22, y22, ss=ss, xss=xss,$
	  yss=yss, nx=nx1, ny=ny1, error=err, value=value, $
	  help=hlp, examples=examp, debug=debug, show=show, rebin=rbin
 
	common img_com, name0, nx0, ny0, typ0, lun, off0
 
	;---------------------------------------------------------------;
	;                        Help                                   ;
	;---------------------------------------------------------------;
	if ((n_params(0) lt 2) or keyword_set(hlp)) and $
	  (not keyword_set(examp)) then begin
	  print,' Read part of a large image.'
	  print,' out = imgread( x1, y1, [x2, y2])'
	  print,'   x1 = starting pixel (first=0).       in'
	  print,'   y1 = starting image line (first=0).  in'
	  print,'   x2 = optional last pixel.            in'
	  print,'   y2 = optional last image line.       in'
	  print,' Keywords:'
	  print,'   SS=ss   subsample factor for x and y (1=every pixel=def).'
	  print,'   XSS=sx  subsample factor in x.'
	  print,'   YSS=sy  subsample factor in y.'
	  print,'   NX=nx   number of output pixels in x (def=512).'
	  print,'   NY=ny   number of output pixels in y (def=512).'
	  print,'   /REBIN means average pixels instead of subsampling.'
	  print,'     The averaged image will appear shifted from the'
	  print,'     subsampled image by an amount depending on the number'
	  print,'     of pixels averaged. This happens because the subsampled'
	  print,'     pixels are from the lower left corner of the averaged'
 	  print,'     pixels.'
	  print,'   VALUE=v value for out-of-range parts of subimage (def=0).'
	  print,'     If VALUE is not given then output image is trimmed'
	  print,'     to be within the image being read.'
	  print,'   ERROR=err  error flag.'
	  print,'       0: OK, -1: part of subimage falls outside main image.'
	  print,'      -2: not open for read, -3: parameter value error.'
	  print,'   SHOW=s print a dot after every s lines is read.'
	  print,'   /EXAMPLES  lists some example calls.'
	  print,'   /DEBUG  does a debug stop.'
	  print,' Notes: Image opened by IMGREAD. Image need not be closed.'
	  print,'   If x2, y2 are given they take precedence over NX and NY.'
	  print,'   If x2, y2 are given and subsample factor is not 1 then'
	  print,'     x2, y2 may not be included in output image.'
	  return, -1
	endif
 
	;---------------------------------------------------------------;
	;                        Examples                               ;
	;---------------------------------------------------------------;
	if keyword_set(examp) then begin
	  print,' Example calls to imgread:'
	  print,'   out = imgread(100,100)
	  print,'     returns a 512 x 512 sub-image starting at image'
	  print,'     location (100,100).'
	  print,'   out = imgread(100,100,ss=2)
	  print,'     returns a 512 x 512 result which covers an area of'
	  print,'     1024 x 1024 in the original image subsampled by a'
	  print,'     factor of 2.'
	  print,'   out = imgread(100,100,200,200)
	  print,'     returns a 101 x 101 sub-image starting at image'
	  print,'     location (100,100).'
	  print,'   out = imgread(100,100,200,200,ss=2)
	  print,'     returns a 51 x 51 sub-image starting at image'
	  print,'     location (100,100) and subsampling by 2.'
	  print,'   out = imgread(100,100,201,201,ss=2)
	  print,'     Exactly the same as last example.  Pixel 201 is not'
	  print,'     included in the out image.'
	  return, -1
	endif
 
	;---------------------------------------------------------------;
	;                        Image open?                            ;
	;---------------------------------------------------------------;
	if n_elements(name0) eq 0 then begin
	  print,' Error in imgread: image not open.'
	  err = -2
	  return, -1
	endif
 
	;---------------------------------------------------------------;
	;               Check for parameter numeric error               ;
	;---------------------------------------------------------------;
	on_ioerror, numerr
	x = x11 + 0
	x = y11 + 0
	if n_params(0) ge 4 then begin
	  x = x22 + 0
	  x = y22 + 0
	  if x22 lt x11 then goto, numerr
	  if y22 lt y11 then goto, numerr
	endif
 
	;---------------------------------------------------------------;
	;                      Set up defaults                          ;
	;       Want to end up with: x1, y1, nx, ny, xss, yss           ;
	;             x2, y2 used only to find nx, ny.                  ;
	;---------------------------------------------------------------;
	if n_elements(value) eq 0 then begin	; VALUE not given:
	  x1 = x11>0<(nx0-1)			; Trim output image
	  y1 = y11>0<(ny0-1)			; to be within main image
	  if n_params(0) ge 4 then begin
	    x2 = x22>0<(nx0-1)
	    y2 = y22>0<(ny0-1)
	  endif
	endif else begin			; VALUE given:
	  x1 = x11				; Allow output image to
	  y1 = y11				; extend outside main image.
	  if n_params(0) ge 4 then begin
	    x2 = x22
	    y2 = y22
	  endif
	endelse
	if n_elements(ss ) eq 0 then ss  = 1	; Default subsample factor.
	if n_elements(xss) eq 0 then xss = ss	; Default X ss fact.
	if n_elements(yss) eq 0 then yss = ss	; Default Y ss fact.
	if n_elements(nx1) eq 0 then nx1 = 512	; Default NX.
	if n_elements(ny1) eq 0 then ny1 = 512	; Default NY.
	on_ioerror, numerr			; Check validity of
	x = ss + 0				; ss, nx1, ny1.
	x = nx1 + 0
	x = ny1 + 0
	if nx1 lt 1 then goto, numerr
	if ny1 lt 1 then goto, numerr
	on_ioerror, null
	nx = nx1<fix(((nx0-1-x1)/(xss>1.)+.5))	; Keep nx, ny in bounds.
	ny = ny1<fix(((ny0-1-y1)/(yss>1.)+.5))
	if n_elements(x2) ne 0 then begin	; x2 given, find NX.
	  nx = fix(x2-x1)/(xss>1) + 1
	endif else begin
;	  x2 = x1 + (xss>1)*(nx-1)		; x2 not given, find it.
	  x2 = x1 + (xss>1)*nx-1		; x2 not given, find it.
	endelse
	if n_elements(y2) ne 0 then begin	; y2 given, find NY.
	  ny = fix(y2-y1)/(yss>1) + 1
	endif else begin
;	  y2 = y1 + (yss>1)*(ny-1)		; y2 not given, find it.
	  y2 = y1 + (yss>1)*ny-1		; y2 not given, find it.
	endelse
	if n_elements(value) eq 0 then value = 0.
 
	;---------------------------------------------------------------;
	;          Check rest of parameters for numeric error           ;
	;---------------------------------------------------------------;
	on_ioerror, numerr
	x = xss + 0
	x = yss + 0
	on_ioerror, null
 
	;---------------------------------------------------------------;
	;                   Set up output image                         ;
	;---------------------------------------------------------------;
	out = make_array(nx, ny, type=typ0, value=value)
 
	;---------------------------------------------------------------;
	;                 Set up image indexing arrays                  ;
	;---------------------------------------------------------------;
	ix = x1 + (xss>1)*indgen(nx)	; Indices of pixels in each line.
	iy = y1 + (yss>1)*indgen(ny)	; Assoc indices of lines.
	x0 = -(x1<0)/(xss>1)		; X start index in OUT.
	y0 = -(y1<0)/(yss>1)		; Y start index in OUT.
	err = 0				; Assume image in bounds.
	if x1 lt 0   then err = -1	; Check if out of bounds.
	if x2 ge nx0 then err = -1
	if y1 lt 0   then err = -1
	if y2 ge ny0 then err = -1
	w = where((ix ge 0) and (ix lt nx0))	; Keep image indices
	ix = ix(w)				; in bounds.
	w = where((iy ge 0) and (iy lt ny0))
	iy = iy(w)
 
 
	;---------------------------------------------------------------;
	;                         Read image                            ;
	;---------------------------------------------------------------;
	close, lun
	openr, lun, name0
	sflag = 0
	if n_elements(show) ne 0 then begin
	  print,' Reading ('+strtrim(n_elements(iy),2)+' lines, showing '+$
	    'a dot every '+strtrim(show,2)+' lines) ',form='($,a)'
	  sflag = 1
	endif
 
	if not keyword_set(rbin) then begin
	  aa = assoc(lun, make_array(nx0, type=typ0), off0)
	  for i = 0, n_elements(iy)-1 do begin
	    t = aa(iy(i))
	    if sflag then begin
	      if (i mod show) eq 0 then print,'.',form='($,a)'
	    endif
	    out(x0,i+y0) = t(ix)
	  endfor
	endif else begin
	  rx = (x2-x1+1)/xss	; Rebinned image size in X.
	  aa = assoc(lun, make_array(nx0, yss, type=typ0), off0+nx0*y1)
	  for i = 0, ny-1 do begin	; Loop thru output image Y indices.
	    t = aa(i)
	    if sflag then begin
	      if (i mod show) eq 0 then print,'.',form='($,a)'
	    endif
	    out(x0,i+y0) = rebin(t(x1:x2,*),rx,1)
	  endfor
	endelse
 
	if keyword_set(debug) then stop,' Debug stop.  .con to cntinue.'
	close, lun
	return, out
 
        ;---------------------------------------------------------------;
        ;                     Was a numeric error                       ;
        ;---------------------------------------------------------------;
numerr: print,' Error in parameter value in imgread:'
	print,'   Check for non-numeric or inconsistent values.'
        err = -3
        on_ioerror, null
        return, -1
 
	end
