;-------------------------------------------------------------
;+
; NAME:
;       NUMPLOT
; PURPOSE:
;       Interactive array of image numbers in a box.
; CATEGORY:
; CALLING SEQUENCE:
;       numplot
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ARRAY=array Data array to display from.
;           If array was displayed as an image using:
;           tvscl,array,/order then use /YREVERSE on histplot call.
;         /YREVERSED means Image Y=0 for top row, else bottom.
;           Image must be displayed correctly before calling numplot.
;           If image was displayed as tvscl,img,/order then call
;           numplot with /YREVERSED.
;         PXOFF=pxoff, PYOFF=pyoff  Display widget x,y offset.
;         MXPOS=mxpos, MYPOS=mypos  Mag window x,y position.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
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
	pro numplot, array=arr, yreversed=yrev, info=info, help=hlp, $
	  pxoff=pxoff, pyoff=pyoff, mxpos=mxpos, mypos=mypos, flag=flag
 
	if keyword_set(hlp) then begin
	  print,' Interactive array of image numbers in a box.'
	  print,' numplot'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   ARRAY=array Data array to display from.'
	  print,'     If array was displayed as an image using:'
	  print,'     tvscl,array,/order then use /YREVERSE on histplot call.'
	  print,'   /YREVERSED means Image Y=0 for top row, else bottom.'
	  print,'     Image must be displayed correctly before calling numplot.'
	  print,'     If image was displayed as tvscl,img,/order then call'
	  print,'     numplot with /YREVERSED.'
	  print,'   PXOFF=pxoff, PYOFF=pyoff  Display widget x,y offset.'
	  print,'   MXPOS=mxpos, MYPOS=mypos  Mag window x,y position.'
	  return
	endif
 
	if n_elements(arr) eq 0 then begin
	  print,' Error in numplot: Must give data array to use.'
	  return
	endif
	if n_elements(pxoff) eq 0 then pxoff=0
	if n_elements(pyoff) eq 0 then pyoff=0
	if n_elements(mxpos) eq 0 then mxpos=0
	if n_elements(mypos) eq 0 then mypos=0
 
	image_numbers, init=arr, pxoff=pxoff, pyoff=pyoff, mxpos=mxpos, mypos=mypos
	img = tvrd()
 
	x1 = 100	; Can do better than this.
	x2 = 109
	y1 = 100
	y2 = 109
 
	;------  Instructions  ----------------
        xmess,['Position display window as desired.',$
          'Then click CONTINUE and place cursor in image window.', $
          'Left button = drag to move box.',$
          'Other buttons = options (can scroll window also)'], $
          oktext='CONTINUE', /wait
 
	wshow
	tv, img
	box2b, x1,x2,y1,y2, change='image_numbers',yrev=yrev,/lock,/xmode, ch_flag=flag
 
	image_numbers,/terminate
 
	end
