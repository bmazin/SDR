;-------------------------------------------------------------
;+
; NAME:
;       PAN
; PURPOSE:
;       Pan around a screen image.  Set pixels to a specified value.
; CATEGORY:
; CALLING SEQUENCE:
;       pan, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         INWINDOW=w1  input window (window to zoom, def=0).
;         OUTWINDOW=w2 output window (magnified image, def=1).
;         COLOR=clr    If this keyword is given then when the
;           middle mouse button is clicked the pixel under the
;           crosshairs is set to clr.  Next click unsets pixel
;           if cursor position has not changed.
; OUTPUTS:
;       out = returned color index.    out.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 17 Mar, 1993
;       R. Sterner,  1 Jun, 1993 --- Added COLOR keyword and pixel set.
;       R. Sterner, 15 Oct, 1993 --- Added output value.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro pan, out, help=hlp, inwindow=inwin, outwindow=outwin, color=clr
 
        if keyword_set(hlp) then begin
          print,' Pan around a screen image.  Set pixels to a specified value.'
          print,' pan, out'
          print,'   out = returned color index.    out.'
	  print,' Keywords:'
	  print,'   INWINDOW=w1  input window (window to zoom, def=0).'
	  print,'   OUTWINDOW=w2 output window (magnified image, def=1).'
	  print,'   COLOR=clr    If this keyword is given then when the'
	  print,'     middle mouse button is clicked the pixel under the'
 	  print,'     crosshairs is set to clr.  Next click unsets pixel'
	  print,'     if cursor position has not changed.'
          return
        endif
 
	;------  Initialize  ------
	if n_elements(inwin) eq 0 then inwin = 0
	if n_elements(outwin) eq 0 then outwin = 1
	flag = 1		; Turn on white cross-hairs.
	if inwin lt 32 then wset,inwin	 ; Make sure window is defined.
	if inwin lt 32 then wshow,inwin	 ; Put image window up front.
;	wset, inwin		; Work in image window.
	zsize = 5		; Zoom factor.
	wsize = 50*zsize	; Zoom window size.
	w2 = wsize/2		; Half zoom window size.
	wa = w2-5		; For zoom window cross hair cursor.
	wb = w2+5
	wd = zsize/2		; Offset to center cross-hair.
	pnum = 0		; Position list count.
 
	;-----  Set up screen  --------------
	printat,1,1,/clear
	printat, 5, 3, 'Screen image pan'
	printat, 5, 5, 'Use mouse to position cursor on image.'
	printat, 5, 6, 'A 50 x 50 window around cursor is displayed'
	printat, 5, 7, 'magnified 5 times in the zoom window.'
	printat, 5, 9, 'Commands:'
	printat, 5, 11, 'Left Button:    Toggle cross-hairs'
	printat, 5, 12, 'Middle Button:  List position'
	printat, 5, 13, 'Right Button:   Quit'
	printat, 5, 15, 'Position number:  0'
	printat, 5, 17, 'Screen pixel x,y:  None'
	printat, 5, 19, 'Pixel value:  None'
	if n_elements(clr) ne 0 then begin
	  printat,5,21,'Middle button sets selected pixel to '+strtrim(clr,2)
	endif
 
	window, outwin, xs=wsize, ys=wsize	; Make zoom window.
 
	ix2 = -1			; Last position.
	iy2 = -1
	ccnt = 0			; Click count.
 
	repeat begin
	  !err = 0
	  wset, inwin			; Work in image window next.
	  cursor, /dev, ix, iy, 0	; Read cursor position.
	  ;--------  Left mouse button  ----------
	  if !err eq 1 then begin	; Toggle cross-hairs.
	    flag = (flag + 1) mod 3
	    wshow, outwin		; Make sure window 1 in front.
	    wait, .05			; Computer too fast, must wait.
	  endif
	  ;---------  Middle mouse button  ---------
	  if !err eq 2 then begin
	    pnum = pnum + 1
	    iz = strtrim(tvrd(ix,iy,1,1)+0,2)
	    printat, 23, 15, strtrim(pnum,2)+'   '
	    printat, 24, 17, strtrim(ix,2)+'  '+strtrim(iy,2)+'     '
	    printat, 19, 19, iz+'     '
	    wait, .05
	    if (ix eq ix2) and (iy eq iy2) and $
	      (n_elements(clr) ne 0) then begin
	      ccnt = (ccnt + 1) mod 2
	      if ccnt eq 1 then begin		; Set pixel to COLOR.
	        oldpix = tvrd(ix,iy,1,1)	; Read current value.
		wait, .1
		tv,[clr],ix,iy			; Set to COLOR.
	      endif else begin			; Undo pixel set.
		tv,[oldpix],ix,iy
	      endelse
	    endif
	    ix2 = ix				; Save current position.
	    iy2 = iy
	  endif  ; !err eq 2
	  t0 = tvrd2(ix-25,iy-25,50,50)	; Grab small part of image.
	  wset,outwin			        ; Work in zoom window next.
	  t = rebin(t0,wsize,wsize,/samp) 	; Zoom small part.
	  case flag of
1:	  begin					; White cross hairs.
	    t(0:wa+wd,w2+wd) = 255
	    t((wd+wb):*,w2+wd) = 255
	    t(w2+wd,0:wa+wd) = 255
	    t(w2+wd,(wb+wd):*) = 255
	    t(w2+wd,w2+wd) = 255
	  end
2:	  begin					; Black cross hairs.
	    t(0:wa+wd,w2+wd) = 0
	    t((wb+wd):*,w2+wd) = 0
	    t(w2+wd,0:wa+wd) = 0
	    t(w2+wd,(wb+wd):*) = 0
	    t(w2+wd,w2+wd) = 0
	  end
else:
	  endcase
	  tv, t				; Display zoomed image.
	endrep until !err eq 4		; Right button pressed?
 
	wset, inwin			; Set back to input window.
	out = tvrd(ix,iy,1,1)		; Read current value.
	out = out(0)
 
	printat,1,24,''
 
	return
 
	end
