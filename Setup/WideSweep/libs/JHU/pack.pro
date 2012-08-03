;-------------------------------------------------------------
;+
; NAME:
;       PACK
; PURPOSE:
;       Find best packing of images (rectangles) on a page.
; CATEGORY:
; CALLING SEQUENCE:
;       pack
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /TOP   means display information to position images at
;           the top of each region, else center each image.
;         /CODE  display IDL code to position images.
;           Given code is only an example.  It assumes all the
;           images have been resized and placed in a 3-d array.
;           The JHU/APL library routine tvpos computes the
;           position to give tv for the given image and position.
; OUTPUTS:
; COMMON BLOCKS:
;       pack_com
; NOTES:
;       Notes: a new image size is computed to fit the given number
;         of images on the page or screen.  Look for the flags
;         *** Largest image ***, or *** Best fit ***,
;         whichever is more important (if both the same, no flag
;         is displayed).
; MODIFICATION HISTORY:
;       R. Sterner, 27 Aug, 1993.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro pack_best, w, h, nx, ny, mn, fx, fy, aa, bb, ww, hh, rat
	;              |--- Inputs ---|  |------- Outputs ---------|
 
	;--------  Derived constants  ---------
	n = 2*mn-1			; Number of factors to check.
	f = findgen(n)+1		; Possible numbers in each dimension.
	fx = rebin(f,n,n)		; Number of subimages in X dir.
	fy = rebin(transpose(f),n,n)	; Number of subimages in Y dir.
	ff = fx*fy			; Array of total subimages.
	r = h/w				; Image shape.
 
	;--------  Compute possible packings  -------------
	aa = rebin(nx/f,n,n)		; Possible subregion widths.
	bb = rebin(transpose(ny/f),n,n)	; Possible subregion heights.
	pm = bb/aa			; Array with subregion shapes: portrait.
	ww = pm				; Storage for  potential image widths.
	hh = pm				; Storage for potential image heights.
	wt = where(pm gt r, cnt)	; Handle regions thinner than image.
	if cnt gt 0 then begin
	  ww(wt) = aa(wt)		; Image width = dx.
	  hh(wt) = r*ww(wt)		; Image height = r*width.
	endif
	wt = where(pm le r, cnt)	; Handle regions fatter than image.
	if cnt gt 0 then begin
	  hh(wt) = bb(wt)		; Image height = dy.
	  ww(wt) = hh(wt)/r		; Image width = height/r.
	endif
	;--------  Select only cases with a minimum of mn regions.  ---
	wt = where(ff ge mn, cnt)
	ff = long(ff(wt))
	fx = long(fx(wt))
	fy = long(fy(wt))
	ww = long(ww(wt))
	hh = long(hh(wt))
	aa = long(aa(wt))
	bb = long(bb(wt))
	;---------  Want regions giving max image area  --------
	areai = ww*hh			; Find each region area.
	wt = where(areai eq max(areai))	; Pick region with largest subimage.
	ff = ff(wt)
	fx = fx(wt)
	fy = fy(wt)
	ww = ww(wt)
	hh = hh(wt)
	aa = aa(wt)
	bb = bb(wt)
	areai = areai(wt)	; Image area.
	arear = aa*bb		; Region areas.
 
	;--------  Select case that best fills region  -------
	rat = float(areai)/arear
	wt = where(rat eq max(rat))
	fx = fx(wt(0))
	fy = fy(wt(0))
	aa = aa(wt(0))
	bb = bb(wt(0))
	ww = ww(wt(0))
	hh = hh(wt(0))
	rat = rat(wt(0))
 
	return
	end
	;=============================================================
 
 
	;===========  Main routine  =======================
 
	pro pack, help=hlp, code=code, top=top
 
	common pack_com, w0, h0, nx0, ny0, mn0
 
	if keyword_set(hlp) then begin
	  print,' Find best packing of images (rectangles) on a page.'
	  print,' pack'
	  print,'   No args, prompts.'
	  print,' Keywords:'
	  print,'   /TOP   means display information to position images at'
	  print,'     the top of each region, else center each image.'
	  print,'   /CODE  display IDL code to position images.'
	  print,'     Given code is only an example.  It assumes all the'
	  print,'     images have been resized and placed in a 3-d array.'
	  print,'     The JHU/APL library routine tvpos computes the'
	  print,'     position to give tv for the given image and position.'
	  print,' Notes: a new image size is computed to fit the given number'
	  print,'   of images on the page or screen.  Look for the flags'
	  print,'   *** Largest image ***, or *** Best fit ***,'
	  print,'   whichever is more important (if both the same, no flag'
	  print,'   is displayed).'
	  return
	endif
 
	;-------  Define defaults  -----------
	if n_elements(w0) eq 0 then begin
	  w0 = 640
	  h0 = 480
	  nx0 = 2000
	  ny0 = 1500
	  mn0 = 12
	endif
 
	;-----------  Get parameters  ------------------
	print,' '
	print,' Find best packing of images on a page.'
	print,' '
	print,' Enter dimensions of image (in any units).'
	w = ''
	read,' Enter image width (def='+strtrim(w0,2)+', q=quit): ',w
	if strlowcase(w) eq 'q' then return
	if w eq '' then w = w0
	w0 = w
	h = ''
	read,' Enter image height (def='+strtrim(h0,2)+', q=quit): ',h
	if strlowcase(h) eq 'q' then return
	if h eq '' then h = h0
	h0 = h
	w = w + 0.
	h = h + 0.
	r = h/w		; Target shape.
	print,' '
	print,' Enter dimensions of page (in same units).'
	nx = ''
	read,' Enter long dimension of page (def='+strtrim(nx0,2)+$
	  ', q=quit): ',nx
	if strlowcase(nx) eq 'q' then return
	if nx eq '' then nx = nx0
	nx0 = nx
	ny = ''
	read,' Enter short dimension of page (def='+strtrim(ny0,2)+$
          ', q=quit): ',ny
	if strlowcase(ny) eq 'q' then return
	if ny eq '' then ny = ny0
	ny0 = ny
	nx = nx + 0.
	ny = ny + 0.
	print,' '
	mn = ''
	read,' Enter minimum number of images to be packed (def='+$
	  strtrim(mn0,2)+',q=quit): ',mn
	if strlowcase(mn) eq 'q' then return
	if mn eq '' then mn = mn0
	mn0 = mn
	mn = mn + 0
 
	pack_best, w, h, nx, ny, mn, fx1, fy1, aa1, bb1, ww1, hh1, rat1
	pack_best, w, h, ny, nx, mn, fx2, fy2, aa2, bb2, ww2, hh2, rat2
	xoff1 = (aa1-ww1)/2
	yoff1 = (bb1-hh1)/2
	xoff2 = (aa2-ww2)/2
	yoff2 = (bb2-hh2)/2
	txt1 = ''
	txt2 = ''
	if rat1 gt rat2 then begin
	  txt1 = '*** Best fit ***'
	  txt2 = ''
	endif else if rat1 ne rat2 then begin
	  txt1 = ''
	  txt2 = '*** Best fit ***'
	endif
	tx1 = ''
	tx2 = ''
	if ww1*hh1 gt ww2*hh2 then begin
	  tx1 = '  *** Largest image ***'
	  tx2 = ''
	endif else if ww1*hh1 ne ww2*hh2 then begin
	  tx1 = ''
	  tx2 = '  *** Largest image ***'
	endif
 
	cmt = 'To center each image'
	yoff = strtrim(yoff1,2)
	if keyword_set(top) then begin
	  cmt = 'To top justify each image'
	  yoff = strtrim(bb1-hh1,2)
	endif
	print,' '
	print,' For LANDSCAPE mode: '+tx1+txt1
	print,'   Page is '+strtrim(long(nx),2)+' by '+strtrim(long(ny),2)+'.'+$
	  '   Original image is '+strtrim(long(w),2)+' by '+$
	  strtrim(long(h),2)+'.'
	print,'   Make '+strtrim(fx1*fy1,2)+' page regions ('+$
	  strtrim(fx1,2)+' by '+strtrim(fy1,2)+') of size '+$
	  strtrim(aa1,2)+' by '+strtrim(bb1,2)+'.'
	print,'   Make image size be '+strtrim(ww1,2)+' by '+strtrim(hh1,2)+$
	  '  (magnification is about '+string(ww1/w,form='(f6.3)')+').'
	print,'   '+cmt+': offset from region lower left corner'
	print,'     in x and y by '+strtrim(xoff1,2)+' and '+$
	  yoff+'.'+'   Fill fraction is '+strtrim(rat1,2)+'.'
	if keyword_set(code) then begin
	  print,' '
	  print,'       for i=0,'+strtrim(mn-1,2)+' do begin'+'   ; '+cmt+'.'
	  print,'         tvpos,['+strtrim(aa1,2)+','+strtrim(bb1,2)+'],i,x,y'
	  print,'         tv,img(*,*,i),x+'+strtrim(xoff1,2)+',y+'+yoff
	  print,'       endfor'
	endif
 
	cmt = 'To center each image'
	yoff = strtrim(yoff2,2)
	if keyword_set(top) then begin
	  cmt = 'To top justify each image'
	  yoff = strtrim(bb2-hh2,2)
	endif
	print,' '
	print,' For PORTRAIT mode: '+tx2+txt2
	print,'   Page is '+strtrim(long(ny),2)+' by '+strtrim(long(nx),2)+'.'+$
	  '   Original image is '+strtrim(long(w),2)+' by '+$
	  strtrim(long(h),2)+'.'
	print,'   Make '+strtrim(fx2*fy2,2)+' page regions ('+$
	  strtrim(fx2,2)+' by '+strtrim(fy2,2)+') of size '+$
	  strtrim(aa2,2)+' by '+strtrim(bb2,2)+'.'
	print,'   Make image size be '+strtrim(ww2,2)+' by '+strtrim(hh2,2)+$
	  '  (magnification is about '+string(ww2/w,form='(f6.3)')+').'
	print,'   '+cmt+': offset from region lower left corner'
	print,'     in x and y by '+strtrim(xoff2,2)+' and '+$
	  yoff+'.'+'   Fill fraction is '+strtrim(rat2,2)+'.'
	if keyword_set(code) then begin
	  print,' '
	  print,'       for i=0,'+strtrim(mn-1,2)+' do begin'+'   ; '+cmt+'.'
	  print,'         tvpos,['+strtrim(aa2,2)+','+strtrim(bb2,2)+'],i,x,y'
	  print,'         tv,img(*,*,i),x+'+strtrim(xoff2,2)+',y+'+yoff
	  print,'       endfor'
	endif
 
	return
	end
