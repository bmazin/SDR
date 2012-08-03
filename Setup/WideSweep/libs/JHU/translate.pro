;-------------------------------------------------------------
;+
; NAME:
;       TRANSLATE
; PURPOSE:
;       Translate an image to regisiter with a reference image.
; CATEGORY:
; CALLING SEQUENCE:
;       translate, img1, img2, [dx2, dy2, key]
; INPUTS:
;       img1 = reference image.                  in
;       img2 = image to translate.               in
; KEYWORD PARAMETERS:
;       Keywords:
;         EXITKEY=k define exit key.  Default is A.
;         EXITTEXT=txt  to use for menu giving action of EXITKEY.
;           Should say something like Exit and do ...
;         /FIRST keeps difference image scaling same as unshifted difference.
; OUTPUTS:
;       dx2, dy2 = pixels shifted in x and y.    in, out
;       key = non keypad key returned.           out
; COMMON BLOCKS:
; NOTES:
;       Notes: the displayed image is: img1 - shift(img2,dx2,dy2)
;         Images with discontinueties may have small differences
;         when unshifted but very large differences in a few
;         places when shifted.  These large differences may
;         dominate the autoscaling.  Try using /FIRST to avoid this.
; MODIFICATION HISTORY:
;       R. Sterner, 9 Nov, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro translate, img1, img2, dx2, dy2, c, help=hlp, $
	  first=frst, exitkey=ex, exittext=exetxt
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Translate an image to regisiter with a reference image.'
	  print,' translate, img1, img2, [dx2, dy2, key]'
	  print,'   img1 = reference image.                  in'
	  print,'   img2 = image to translate.               in'
	  print,'   dx2, dy2 = pixels shifted in x and y.    in, out'
	  print,'   key = non keypad key returned.           out'
	  print,' Keywords:'
	  print,'   EXITKEY=k define exit key.  Default is A.'
	  print,'   EXITTEXT=txt  to use for menu giving action of EXITKEY.'
	  print,'     Should say something like Exit and do ...'
	  print,'   /FIRST keeps difference image scaling same as unshifted '+$
	    'difference.'
	  print,' Notes: the displayed image is: img1 - shift(img2,dx2,dy2)'
	  print,'   Images with discontinueties may have small differences'
	  print,'   when unshifted but very large differences in a few'
	  print,'   places when shifted.  These large differences may'
	  print,'   dominate the autoscaling.  Try using /FIRST to avoid this.'
	  return
	endif
 
 
	if n_elements(dx2) eq 0 then dx2 = 0
	if n_elements(dy2) eq 0 then dy2 = 0
	mn = min(img1-img2,max=mx)
	mode = 1
	sz = size(img1)
	nx = sz(1)
	ny = sz(2)
	blank = bytarr(640, 20)
	if n_elements(ex) eq 0 then ex = 'A'
	if n_elements(exetxt) eq 0 then exetxt = 'Alternate exit.'
 
	print,' '
	print,' Shift image 2 relative to image 1.'
	print,' Uses keypad keys.  Any other key is returned.'
	print,' Q --- Quit.'
	print,' P --- Toggles print shift values on or off.'
	print,' Z --- Returns to (0,0) shift.'
	print,' K --- Keyboard shift entry.'
	print,' '+strupcase(ex)+' --- '+exetxt
	print,' Arrow keys shift image.'
	print,' '
	print,' Press any key to continue'
	k = get_kbrd(1)
 
	erase
	xyouts, 640, 512, /dev, align=.5,'Displaying Difference Image . . .'
	wshow, 0
	print,' Command: '
loop:	if mode eq 1 then begin
	  tv, blank, 0, ny
	  xyouts, 10, ny+5, /dev, 'dx = '+strtrim(dx2,2)+',  dy = '+$
	    strtrim(dy2,2)
	endif
	if keyword_set(frst) then begin
	  tv, bytscl(img1-shift(img2,dx2,dy2), mn, mx)
	endif else begin
	  tvscl,img1-shift(img2,dx2,dy2)
	endelse
	wait, 0			; Need this to display image immediately.
loopc:	c = getkey()
	c = strupcase(c)
	
	;------  Toggle shift print on/off  --------
	if strupcase(c) eq 'P' then begin
	  mode = 1 - mode
	  goto, loop
	endif
 
	;-------  Quit  ----------
	if strupcase(c) eq 'Q' then goto, done
 
	;--------  Arrow keys  ---------
	if c eq 'RIGHT' then begin
	  dx2 = dx2 + 1
	  goto, loop
	endif
	if c eq 'LEFT' then begin
	  dx2 = dx2 - 1
	  goto, loop
	endif
	if c eq 'UP' then begin
	  dy2 = dy2 + 1
	  goto, loop
	endif
	if c eq 'DOWN' then begin
	  dy2 = dy2 - 1
	  goto, loop
	endif
 
	;-----  Zero shifts  ----------
	if c eq 'Z' then begin
	  dx2 = 0
	  dy2 = 0
	  goto, loop
	endif
 
	;------  Keyboard shift entry  --------
	if c eq 'K' then begin
kloop:	  txt = ''
	  read,' Enter image shift (dx,dy): ',txt
	  if txt eq '' then begin
	    print,' Command: '
	    goto, loopc
	  endif
	  txt = repchr(txt,',')
	  txt = repchr(txt,'	')
	  dx2 = getwrd(txt) + 0
	  dy2 = getwrd(txt,1) + 0
	  if mode eq 1 then begin
	    tv, blank, 0, ny
	    xyouts, 10, ny+5, /dev, 'dx = '+strtrim(dx2,2)+',  dy = '+$
	      strtrim(dy2,2)
	  endif
	  if keyword_set(frst) then begin
	    tv, bytscl(img1-shift(img2,dx2,dy2), mn, mx)
	  endif else begin
	    tvscl,img1-shift(img2,dx2,dy2)
	  endelse
	  wait, 0		; Need this to display image immediately.
	  goto, kloop
	endif
 
	;-------  Exit key  ---------
	if keyword_set(ex) then begin	; This is needed because of problems
	  if c eq strupcase(ex) then goto, done	; with getkey.  For pauses 
	  goto, loopc				; between getkey calls it
	endif					; often messes up and 
						; returns a wrong value.
 
done:	wshow, 0, 0
	return
 	
	end
