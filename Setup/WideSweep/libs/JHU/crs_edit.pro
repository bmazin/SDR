;-------------------------------------------------------------
;+
; NAME:
;       CRS_EDIT
; PURPOSE:
;       Edit a bitmap to use for a cursor image.
; CATEGORY:
; CALLING SEQUENCE:
;       crs_edit, img, msk
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         HOT=[ix,iy] x and y offsets to cursor hot spot (def=[8,8]).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Displays current array values as a large version
;         of the cursor.  Click on pixels to change state among
;         black, white, and gray.  Transparent part of cursor is
;         gray.  Left and middle mouse buttons change state,
;         right button exits.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Nov 24
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro crs_edit, img, msk, hot=hot, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Edit a bitmap to use for a cursor image.'
	  print,' crs_edit, img, msk'
	  print,'   img = 16 element integer array with image bitmap.  in,out'
	  print,'   msk = 16 element integer array with mask bitmap.   in,out'
	  print,' Keywords:'
	  print,'   HOT=[ix,iy] x and y offsets to cursor hot spot (def=[8,8]).'
	  print,' Notes: Displays current array values as a large version'
	  print,'   of the cursor.  Click on pixels to change state among'
	  print,'   black, white, and gray.  Transparent part of cursor is'
	  print,'   gray.  Left and middle mouse buttons change state,'
	  print,'   right button exits.'
	  return
	endif
 
	;-----  Init arrays if new  ----------------
	if n_elements(img) eq 0 then img = uintarr(16)
	if n_elements(msk) eq 0 then msk = uintarr(16)
	img0 = img
	msk0 = msk
	if n_elements(hot) eq 0 then hot=[8,8]
	hx=hot(0) & hy=hot(1)
 
	;-----  Convert incoming to an image  ------
	aa = bytarr(16,16)+2
	for iy=0,15 do begin
	  t = basecon(msk(iy),to=2,dig=16)
	  for ix=0,15 do if strmid(t,ix,1) eq 1 then aa(ix,iy)=1
	  t = basecon(img(iy),to=2,dig=16)
	  for ix=0,15 do if strmid(t,ix,1) eq 1 then aa(ix,iy)=0
	endfor
 
;	a = reverse(shift(aa,-8,0),1)
	a = reverse(aa,1)
 
	;-----  Display  -------------
	window,xs=160,ys=160
	t = tarclr(0,0,0,/hsv,set=0)
	t = tarclr(0,0,1,/hsv,set=1)
	t = tarclr(0,0,.5,/hsv,set=2)
	t = tarclr(0,0,.3,/hsv,set=3)
	t = tarclr(0,1,1,/hsv,set=4)
	tv,rebin(a,160,160,/samp),/order
	ver,makex(0,160,10),col=3,/dev
	hor,makex(0,160,10),col=3,/dev
	plots,/dev,10*[hx,hx+1,hx+1,hx,hx],10*(16-[hy,hy,hy+1,hy+1,hy]),col=4
 
	;------  Edit image  ----------
	print,' Click on block to change state.  Right button exits.'
loop:	cursor,ix0,iy0,/dev,/down
	b = !mouse.button
	if b eq 4 then goto, menu
	ix = ix0/10
	iy = 15 - iy0/10
	print,ix,iy
	a(ix,iy) = (a(ix,iy)+b) mod 3	
	tv,rebin(a,160,160,/samp),/order
	ver,makex(0,160,10),col=3,/dev
	hor,makex(0,160,10),col=3,/dev
	plots,/dev,10*[hx,hx+1,hx+1,hx,hx],10*(16-[hy,hy,hy+1,hy+1,hy]),col=4
	goto, loop
 
	;-----  Options menu  ------------
menu:
;	aa = reverse(shift(a,8,0),1)
	aa = reverse(a,1)
 
	for iy=0,15 do begin
	  t = aa(*,iy) eq 0
	  txt = basecon(strcompress(commalist(t,/nocom),/rem),from=2)
	  img(iy) = txt
	  t = aa(*,iy) le 1
	  txt = basecon(strcompress(commalist(t,/nocom),/rem),from=2)
	  msk(iy) = txt
	endfor
 
	opt = xoption(['Return new cursor','Cancel changes',$
	  'List image and mask','Set cursor to new shape', $
	  'Set cursor to standard', 'Continue','Help'])
 
	if opt eq 0 then return
 
	if opt eq 1 then begin
	  img = img0
	  msk = msk0
	  return
	endif
 
	if opt eq 2 then begin
	  array_list, front='        c_img = ',typ='uint',img
	  array_list, front='        c_msk = ',typ='uint',msk
	  goto, menu
	endif
 
	if opt eq 3 then begin
	  device,cursor_image=img,cursor_mask=msk,cursor_xy=hot
	  tvcrs,ix0,iy0
	  goto, loop
	endif
 
	if opt eq 4 then begin
	  device,/cursor_standard
	  tvcrs,ix0,iy0
	  goto, loop
	endif
 
	if opt eq 5 then begin
	  tvcrs,ix0,iy0
	  goto, loop
	endif
 
	if opt eq 6 then begin
	  xhelp,['Cursor image and mask editor',$
	    ' ','Click on pixel to change with left or middle mouse button',$
	    ' ','Click right mouse button for options menu'],/wait
	  tvcrs,ix0,iy0
	  goto, loop
	endif
 
	end
