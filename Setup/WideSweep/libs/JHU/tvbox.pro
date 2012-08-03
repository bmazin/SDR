;-------------------------------------------------------------
;+
; NAME:
;       TVBOX
; PURPOSE:
;       Draw or erase a box on the image display.
; CATEGORY:
; CALLING SEQUENCE:
;       tvbox, x, y, dx, dy, clr
; INPUTS:
;       x = Device X coordinate of lower left corner of box.  in
;       y = Device Y coordinate of lower left corner of box.  in
;       dx = Box X size in device units.                      in
;       dy = Box Y size in device units.                      in
;       clr = box color.                                      in
;          -1 to just erase last box (only last box).
;          -2 for dotted outline.  Useful if box must cover an
;             unknown range of colors.
; KEYWORD PARAMETERS:
;       Keywords:
;         ECHO=win2 Echo same box in window win2.
;         /NOERASE  causes last drawn box not to be erased first.
;         /XMODE  use XOR mode for speed.  Keywords below ignored.
;         /COPY  use first time to set screen copy mode.  Good for
;           windows on slow machines.  Uses an internal copy of the
;           screen image instead of tvrd (tvrd is up to 16 times
;           slower than tv on some machines).  Avoid for large
;           windows.  Unneeded on fast machines.
;        /NOCOPY  unsets the COPY mode.
; OUTPUTS:
; COMMON BLOCKS:
;       box_com
; NOTES:
;       Notes: /COPY and /NOCOPY should be used with no
;         other parameters.
; MODIFICATION HISTORY:
;       R. Sterner, 25 July, 1989
;       R. Sterner, 1994 Jan 11 --- Added copy mode.
;       R. Sterner, 1994 Aug 31 --- Added dotted outline.
;       R. Sterner, 1994 Nov 27 --- Changed dotted colors from 0,255
;       to darkest, brightest.
;       R. Sterner, 1998 Mar 18 --- Attempt to deal with true color.
;       R. Sterner, 2002 Sep 17 --- Added /XMODE.
;       R. Sterner, 2005 Apr 19 --- Fixed to work on first call.
;       R. Sterner, 2005 Jun 24 --- Added ECHO=win2 keyword.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro tvbox, x, y, dx, dy, clr, noerase=noeras, $
	  copy=copy, nocopy=nocopy, xmode=xmode, $
	  echo=win2, help=hlp 
 
	common box_com, xc, yc, dxc, dyc, bb, bl, bt, br, cmode, img, $
	  xc2, yc2, dxc2, dyc2, img2, bb2, bl2, bt2, br2
	;  box_com: values needed to erase the old box.
	;	xc, yc, dxc, dyc = old box position and size.
	;	bb, bl, bt, br = image under box bottom, left, top, right.
	;	cmode = copy mode flag. 0: use tvrd, 1:use screen copy image.
	;	img = copy of screen image.
	;-------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Draw or erase a box on the image display.'
	  print,' tvbox, x, y, dx, dy, clr'
  	  print,'   x = Device X coordinate of lower left corner of box.  in'
  	  print,'   y = Device Y coordinate of lower left corner of box.  in'
	  print,'   dx = Box X size in device units.                      in' 
	  print,'   dy = Box Y size in device units.                      in' 
	  print,'   clr = box color.                                      in'
	  print,'      -1 to just erase last box (only last box).'
	  print,'      -2 for dotted outline.  Useful if box must cover an'
          print,'         unknown range of colors.'
	  print,' Keywords:'
	  print,'   ECHO=win2 Echo same box in window win2.'
	  print,'   /NOERASE  causes last drawn box not to be erased first.'
	  print,'   /XMODE  use XOR mode for speed.  Keywords below ignored.'
	  print,'   /COPY  use first time to set screen copy mode.  Good for'
	  print,'     windows on slow machines.  Uses an internal copy of the'
	  print,'     screen image instead of tvrd (tvrd is up to 16 times'
	  print,'     slower than tv on some machines).  Avoid for large'
	  print,'     windows.  Unneeded on fast machines.'
	  print,'  /NOCOPY  unsets the COPY mode.'
	  print,' Notes: /COPY and /NOCOPY should be used with no'
	  print,'   other parameters.'
	  return
	endif
 
	win1 = !d.window
 
	if n_elements(clr) eq 0 then clr=!p.color
 
	;----------------------------------------------------------------
	if not keyword_set(xmode) then begin
          ;---------------------------------------------------------
          ;  Deal with True Color
          ;  If not PseudoColor then assume using true color or
          ;  something close.  It turns out that using true=3 on
          ;  tv and tvrd is harmless for 8-bit displays.  The only
          ;  step needing changed is to reload the image line using
          ;  the standard BW color table, then restore original table.
          ;  The original table is read once at start.
          ;---------------------------------------------------------
	  vis = ''
	  if (!version.release+0) ge 5 then $
	    device, get_visual_name=vis		; Get visual type.
          vflag = vis ne 'PseudoColor'            ; 0 if PseudoColor.
          tvlct,/get,rr0,gg0,bb0                  ; Get color table.
          ii0 = bindgen(256)                      ; B&W table.
  
	  if keyword_set(copy) then begin		; Start copy mode.
	    img = tvrd()				; Read screen image.
	    if n_elements(win2) ne 0 then begin
	      wset,win2
	      img2 = tvrd()				; Read screen image.
	      wset,win1
	    endif
	    cmode = 1				; Copy mode flag.
	    goto,done
	  endif
 
	  if keyword_set(nocopy) then begin	; End copy mode.
	    img = 0				; Delete screen copy.
	    if n_elements(img2) ne 0 then img2=0
	    cmode = 0				; No copy mode.
	    goto,done
	  endif
 
	  if n_elements(cmode) eq 0 then cmode=0
	endif
	;-----------------------------------------------------
 
	if (not keyword_set(noeras)) and $
	  (n_elements(dxc) ne 0) then begin 	; Not NOERASE.
	  if keyword_set(xmode) then begin
	    device,get_graph=old,set_graph=6	; XOR mode.
  	    x2 = xc + dxc - 1			; 2nd corner.
	    y2 = yc + dyc - 1
	    plots,[xc,x2,x2,xc,xc],[yc,yc,y2,y2,yc],/device,color=-1
	    if n_elements(win2) ne 0 then begin
	      wset,win2
  	      x2 = xc2 + dxc2 - 1		; 2nd corner.
	      y2 = yc2 + dyc2 - 1
	      plots,[xc2,x2,x2,xc2,xc2],[yc2,yc2,y2,y2,yc2],/device,color=-1
	      wset,win1
	    endif
	    device,set_graph=old		; Entry mode.
	    if clr eq -1 then goto,done	        ; Only erase old box.
	  endif else begin
	    if n_elements(win2) ne 0 then begin
	      if n_elements(bb2) ne 0 then begin  ; Something to erase?
		wset,win2
  	        x2 = xc2 + dxc2 - 1
	        y2 = yc2 + dyc2 - 1
	        if vflag then tvlct,ii0,ii0,ii0	; Need B&W table.
	        tv, bb2, xc2, yc2, true=3	        ; Restore parts of image
	        tv, bl2, xc2, yc2, true=3	        ; beneath box.
	        tv, bt2, xc2, y2, true=3
	        tv, br2, x2, yc2, true=3
	        if vflag then tvlct,rr0,gg0,bb0	; Original table.
		wset,win1
	      endif
	    endif
	    if n_elements(bb) ne 0 then begin	; Something to erase?
  	      x2 = xc + dxc - 1
	      y2 = yc + dyc - 1
	      if vflag then tvlct,ii0,ii0,ii0	; Need B&W table.
	      tv, bb, xc, yc, true=3	        ; Restore parts of image
	      tv, bl, xc, yc, true=3	        ; beneath box.
	      tv, bt, xc, y2, true=3
	      tv, br, x2, yc, true=3
	      if vflag then tvlct,rr0,gg0,bb0	; Original table.
	      if clr eq -1 then goto,done	        ; Only erase old box.
	    endif
	  endelse
	endif  ; not noerase.
 
	x2 = x + dx - 1			        ; Box corner.
	y2 = y + dy - 1
 
	if not keyword_set(xmode) then begin
	  if cmode then begin			; Copy mode.
	    bb = img(x:x2,y)
	    bl = img(x,y:y2)
	    bt = img(x:x2,y2)
	    br = img(x2,y:y2)
	    if n_elements(win2) ne 0 then begin
	      wset,win2
	      bb2 = img(x:x2,y)
	      bl2 = img(x,y:y2)
	      bt2 = img(x:x2,y2)
	      br2 = img(x2,y:y2)
	      wset,win1
	    endif
	  endif else begin			; No copy mode.
	    bb = tvrd(x, y, dx>1, 1, true=3)	; Save image beneath box.
	    bl = tvrd(x, y, 1, dy>1, true=3)
	    bt = tvrd(x, y2,dx>1, 1, true=3)
	    br = tvrd(x2,y, 1, dy>1, true=3)
	    if n_elements(win2) ne 0 then begin
	      wset,win2
	      bb2 = tvrd(x, y, dx>1, 1, true=3)	; Save image beneath box.
	      bl2 = tvrd(x, y, 1, dy>1, true=3)
	      bt2 = tvrd(x, y2,dx>1, 1, true=3)
	      br2 = tvrd(x2,y, 1, dy>1, true=3)
	      wset,win1
	    endif
	  endelse
	endif
 
	xc = x & yc = y & dxc = dx & dyc = dy   ; Save box position and size.
	if n_elements(win2) ne 0 then begin
	  xc2=x & yc2=y & dxc2=dx & dyc2=dy 	; Save box position and size.
	endif
 
	if keyword_set(xmode) then begin
	  device,get_graph=old,set_graph=6	; XOR mode.
	  plots,[x,x2,x2,x,x],[y,y,y2,y2,y],/device,color=-1
	  if n_elements(win2) ne 0 then begin
	    wset, win2
	    plots,[x,x2,x2,x,x],[y,y,y2,y2,y],/device,color=-1
	    wset, win1
	  endif
	  device,set_graph=old			; Entry mode.
	endif else begin
	  if clr eq -2 then begin
	    c1 = tarclr(255,255,255)
	    c2 = tarclr(0,0,0)
	    xx = [maken(x,x2,dx),maken(x2,x2,dy),maken(x2,x,dx),maken(x,x,dy)]
	    yy = [maken(y,y,dx),maken(y,y2,dy),maken(y2,y2,dx),maken(y2,y,dy)]
	    cc = c1+((indgen(n_elements(xx)) mod 6) lt 3)*(c2-c1)
	    plots,xx,yy,/dev,color=cc
	    if n_elements(win2) ne 0 then begin
	      wset,win2
	      plots,xx,yy,/dev,color=cc
	      wset,win1
	    endif
	  endif else begin
	    plots,[x,x2,x2,x,x],[y,y,y2,y2,y],/device,color=clr
	    if n_elements(win2) ne 0 then begin
	      wset,win2
	      plots,[x,x2,x2,x,x],[y,y,y2,y2,y],/device,color=clr
	      wset,win1
	    endif
	  endelse
	endelse
 
done:
	return
 
	end
