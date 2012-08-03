;-------------------------------------------------------------
;+
; NAME:
;       IMAGE_NUMBERS
; PURPOSE:
;       Display image numbers in a widget.
; CATEGORY:
; CALLING SEQUENCE:
;       image_numbers, x1, x2, y1, y2
; INPUTS:
;       x1,x2,y1,y2 = Indices into image for area of interest.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         INIT=img0  Must give original image to initialize.
;         /TERMINATE Destroy widget and terminate.
;         FACT=fact Times smaller displayed image is than original.
;         /YREV Y is reversed.
;         MXPOS=xpos, MYPOS=ypos x,y position of mag window. On INIT.
;         PXOFF=xoff, PYOFF=yoff x,y offset of numbers window. On INIT.
;         OPTION=opt  option:
; OUTPUTS:
; COMMON BLOCKS:
;       image_numbers_com
; NOTES:
;       Notes: intended to work with box2d as the CHANGE routine.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Sep 22
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro image_numbers, x1, x2, y10, y20, fact=fact, yrev=yrev, $
	  init=img0, terminate=term, help=hlp, option=option, $
	  mxpos=mxpos, mypos=mypos, pxoff=pxoff, pyoff=pyoff
 
	common image_numbers_com, img, img_dsp, ny, nid, wid, flag, $
	  win_img, win_mag
	;------------------------------------------------------------
	;  Status common:
	;	img = Original full image.
	;	img_dsp = Displayed image.
	;	ny = Image y size.
	;	nid = widget indices of lines to update.
	;	wid = widget index.
	;	flag = 1 if intialized, else 0.
	;	win_img = image window index.
	;	win_mag = mag window index.
	;------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Display image numbers in a widget.'
	  print,' image_numbers, x1, x2, y1, y2'
	  print,'   x1,x2,y1,y2 = Indices into image for area of interest.  in'
	  print,' Keywords:'
	  print,'   INIT=img0  Must give original image to initialize.'
	  print,'   /TERMINATE Destroy widget and terminate.'
	  print,'   FACT=fact Times smaller displayed image is than original.'
	  print,'   /YREV Y is reversed.'
	  print,'   MXPOS=xpos, MYPOS=ypos x,y position of mag window. On INIT.'
	  print,'   PXOFF=xoff, PYOFF=yoff x,y offset of numbers window. On INIT.'
;	  print,'   OPTION=opt  option:'
	  print,' Notes: intended to work with box2d as the CHANGE routine.'
	  return
	endif
 
	;----------  Initialize  ------------------
	if n_elements(img0) ne 0 then begin
	  ;-----  Deal with image  -------------------
	  win_img = !d.window		; Save current window.
	  img_dsp = tvrd()		; Grab current screen image.
	  img = img0			; Copy image to common.
	  sz = size(img)		; Image y size.
	  ny = sz(2)			; Window Y size.
	  ;------  Set up mag window  ----------------
	  if n_elements(mxpos) eq 0 then mxpos=0
	  if n_elements(mypos) eq 0 then mypos=0
	  window,/free,xsize=200,ysize=200,xpos=mxpos,ypos=mypos
	  win_mag = !d.window
	  ;------  Set up display widget  ------------
	  if n_elements(pxoff) eq 0 then pxoff=0
	  if n_elements(pyoff) eq 0 then pyoff=0
	  txt = [strarr(10)+spc(5*10,char='*'),'','']
	  txt(4) = ' '
	  txt(5) = '     Click left mouse button and drag box'
	  txt(6) = ' '
	  xbb,lines=txt,res=[indgen(10),11], $
	    nid=nid,wid=wid,xoff=pxoff,yoff=pyoff
	  ;------  Finish init  ----------------------
	  flag = 1			; Initialized.
	  wset, win_img			; Set back to image window.
	  return
	endif
 
	;------  Terminate  -----------------
	if keyword_set(term) then begin
	  widget_control, wid, /dest
	  if win_open(win_mag) then wdelete,win_mag
	  flag = 0					; Not intialized.
	  return
	endif
 
	;=======  Process a request  =======================
	if n_elements(flag) eq 0 then flag=0
	if flag eq 0 then begin
	  print,' Error in image_stats: must initialize first.'
	  return
	endif
 
	if n_elements(option) eq 0 then option=0
 
	;------  Get coordinates  -------------------
	if n_elements(fact) eq 0 then fact=1
	y1t = round(fact*y10)           ; Temp image y indices.
	y2t = round(fact*y20)           ; (Maybe correct, maybe not).
	if keyword_set(yrev) then begin ; Reverse y.
	  y1 = (ny-1) - y2t           ; Corrected image y indices.
	  y2 = (ny-1) - y1t
	endif else begin
	  y1 = y1t
	  y2 = y2t
	endelse
	;------  Extract subimage  -------------------
	sub = img(x1:x2, y1:y2)		; Extract subimage.
	ibox = 'Subimage = ('+strtrim(x1,2)+':'+strtrim(x2,2)+$
          ','+strtrim(y1,2)+':'+strtrim(y2,2)+')'
	for i=0,9 do widget_control, nid(i),set_val=string(sub(*,i),form='(10I5)')
	widget_control, nid(10),set_val=ibox
	;------  Display mag window  -----------------
	wset, win_mag
	tv,rebin(img_dsp(x1:x2, y10:y20), 200,200,/samp)
	wset, win_img			; Set back to image window.
 
	end
