;-------------------------------------------------------------
;+
; NAME:
;       MOVBOX
; PURPOSE:
;       Interactive box on image diaply.
; CATEGORY:
; CALLING SEQUENCE:
;       movbox, x, y, dx, dy, code
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         XRANGE=xran Return X range of selected box.
;         YRANGE=xran Return Y range of selected box.
;           Returned ranges are [0,0] if data coordinates have not
;           been established (no plot done yet).
;         COLOR=clr,  box color.  -2 for dotted box.
;         DXMIN=dxmn  Set minimum allowed x size in pixels.
;         DYMIN=dymn  Set minimum allowed y size in pixels.
;         /NOERASE prevents last box from being erased on entry.
;         /EXITERASE erases box on alternate exit.
;         /POSITION lists box position after each change.
;           POSITION=n gives screen line for box listing (top=1).
;         /YREVERSE means y is 0 at top of screen.
;         XFACTOR=xf conversion factor from device coordinates
;           to scaled x coordinates.
;         YFACTOR=yf conversion factor from device coordinates
;           to scaled y coordinates.
;         TITLE=txt title for box position listing.
;         /EXITLIST lists box position on exit.
;         /COMMANDS lists box commands on entry.
;         /LOCKSIZE locks box size to entry size.
;         XSIZE=factor. Mouse changes Y size only.
;           Xsize = factor*Ysize.
;         YSIZE=factor. Mouse changes X size only.
;           Ysize = factor*Xsize.
;         /NOMENU just does an alternate exit for middle button.
;         /OPTIONS puts a box on the image that says options.
;           If mouse wiggled inside this box options menu pops up.
;         X_OPTION=x  device X coordinate for options box (def=0).
;         Y_OPTION=y  device Y coordinate for options box (def=0).
;         ECHO=win2  Echo box in window win2.
; OUTPUTS:
;       code = exit code. (2=alternate, 4=normal exit)      out
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Commands:
;           Left button:   Toggle bewteen move box and change size.
;           Middle button: Option menu or alternate exit.
;           Right button:  Normal exit (erases box).
;         Y reversal and coordinate scaling only apply to
;         box position and size listing.  MOVBOX is still called
;         and still exits with actual device coordinates.
; MODIFICATION HISTORY:
;       R. Sterner 25 July, 1989
;       R. Sterner, 6 Jun, 1990 --- added menu.
;       R. Sterner, 13 June, 1990 --- added /nomenu
;       R. Sterner, Oct, 1991 --- fixed for DOS.
;       R. Sterner, 16 Mar, 1992 --- upgraded coordinate listing.
;       R. Sterner, 18 Feb, 1993 --- Added b=a(x1:x2,y1:y2) listing.
;       R. Sterner,  3 Dec, 1993 --- Added XRANGE and YRANGE keywords.
;       R. Sterner,  7 Dec, 1993 --- Added DXMIN, DYMIN keywords.
;       R. Sterner, 1994 Nov 27 --- switched !err to !mouse.button.
;       R. Sterner, 2005 Jun 29 --- Added ECHO=win2.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
 
 
	PRO MOVBOX, X, Y, DX, DY, CODE, position=pos, exitlist=ex, $
	  commands=cmd, help=hlp, locksize=lock, noerase=noer, xsize=xsiz, $
	  ysize=ysiz, color=clr, nomenu=nomen, exiterase=exiterase, $
	  options=options, x_option=x_option, y_option=y_option,$
	  yreverse=yrev, xfactor=xfact, yfactor=yfact,title=title, $
	  xrange=xran, yrange=yran, dxmin=dxmin, dymin=dymin,echo=win2
 
	IF keyword_set(hlp) THEN begin
	  print,' Interactive box on image diaply.'
	  PRINT,' movbox, x, y, dx, dy, code'
	  PRINT,'   x,y = Device coordinates of box lower left corner.  in,out'
	  PRINT,'   dx,dy = box X and Y size in device units.           in,out'
	  PRINT,'   code = exit code. (2=alternate, 4=normal exit)      out'
	  print,' Keywords:'
	  print,'   XRANGE=xran Return X range of selected box.'
	  print,'   YRANGE=xran Return Y range of selected box.'
	  print,'     Returned ranges are [0,0] if data coordinates have not'
	  print,'     been established (no plot done yet).'
	  print,'   COLOR=clr,  box color.  -2 for dotted box.'
	  print,'   DXMIN=dxmn  Set minimum allowed x size in pixels.'
	  print,'   DYMIN=dymn  Set minimum allowed y size in pixels.'
	  print,'   /NOERASE prevents last box from being erased on entry.'
	  print,'   /EXITERASE erases box on alternate exit.'
	  print,'   /POSITION lists box position after each change.'
	  print,'     POSITION=n gives screen line for box listing (top=1).'
	  print,'   /YREVERSE means y is 0 at top of screen.'
	  print,'   XFACTOR=xf conversion factor from device coordinates'
	  print,'     to scaled x coordinates.'
	  print,'   YFACTOR=yf conversion factor from device coordinates'
	  print,'     to scaled y coordinates.'
	  print,'   TITLE=txt title for box position listing.'
	  print,'   /EXITLIST lists box position on exit.'
	  print,'   /COMMANDS lists box commands on entry.'
	  print,'   /LOCKSIZE locks box size to entry size.'
	  print,'   XSIZE=factor. Mouse changes Y size only.'
	  print,'     Xsize = factor*Ysize.'
	  print,'   YSIZE=factor. Mouse changes X size only.'
	  print,'     Ysize = factor*Xsize.'
	  print,'   /NOMENU just does an alternate exit for middle button.'
	  print,'   /OPTIONS puts a box on the image that says options.'
	  print,'     If mouse wiggled inside this box options menu pops up.'
	  print,'   X_OPTION=x  device X coordinate for options box (def=0).'
	  print,'   Y_OPTION=y  device Y coordinate for options box (def=0).'
	  print,'   ECHO=win2  Echo box in window win2.'
	  print,' Notes:'
	  print,'   Commands:'
	  print,'     Left button:   Toggle bewteen move box and change size.'
	  print,'     Middle button: Option menu or alternate exit.'
	  print,'     Right button:  Normal exit (erases box).'
	  print,'   Y reversal and coordinate scaling only apply to'
	  print,'   box position and size listing.  MOVBOX is still called'
	  print,'   and still exits with actual device coordinates.'
	  return
	endif
 
	;------  Set initial values  ---------
	showflag = 0
	if n_elements(xfact) eq 0 then xfact = 1.
	if n_elements(yfact) eq 0 then yfact = 1.
	xran = [0,0]
	yran = [0,0]
	if n_elements(dxmin) eq 0 then dxmin = 1
	if n_elements(dymin) eq 0 then dymin = 1
 
	;---------  Options box (click inside to pop up option menu)  -------
	if keyword_set(options) then begin
	  if n_elements(x_option) eq 0 then x_option=0	   ; Def. box pos
	  if n_elements(y_option) eq 0 then y_option=0
	  options_image = tvrd(x_option, y_option, 75,30)  ; Save img under bx.
	  tmp = bytarr(75,30)				   ; To erase opt box.
	  imgfrm, tmp, [255,0,255,0,255]		   ; Fancy border.
	  tv, tmp, x_option, y_option
	  xyouts,x_option+37.5,y_option+10,/dev,align=.5,'Options',size=1.5
	  mnox = x_option  & mxox = mnox + 74
	  mnoy = y_option  & mxoy = mnoy + 29
	  optcnt = 0	; Count # times in optns box (makes less sensitive).
	endif
 
	if keyword_set(cmd) then begin
	  print,'     Use the mouse to move a box on the screen.'
	  print,'     Left button:   Toggle bewteen move box and change size.'
	  print,'        Move mouse to change box size, '
	  print,'        then press left button to move box.'
	  if keyword_set(nomen) then begin
 	    print,'     Middle button: Alternate exit.'
	  endif else begin
	    print,'     Middle button: Options menu.'
	  endelse
	  print,'     Right button:  Normal exit (erases box).'
	  if keyword_set(options) then print,$
	    '     Wiggle mouse inside options box to pop up the options menu.'
	endif
 
	;-------  Make sure box exists and fits window  --------
	bflag = 0	; Box adjust flag.
	;------  Create box if needed  -------
	if n_elements(x) eq 0 then begin x=100 & bflag=1 & endif
	if n_elements(y) eq 0 then begin y=100 & bflag=1 & endif
	if n_elements(dx) eq 0 then begin dx=100 & bflag=1 & endif
	if n_elements(dy) eq 0 then begin dy=100 & bflag=1 & endif
	;------  Handle min box size  -------------
	dx = dx>dxmin
	dy = dy>dymin
	;------  Adjust box to fit in current window  ------
	if (x+dx) gt !d.x_size then begin x=(!d.x_size-dx)>0 & bflag=2 & endif
	if (y+dy) gt !d.y_size then begin y=(!d.y_size-dy)>0 & bflag=2 & endif
	if (x+dx) gt !d.x_size then begin dx=(!d.x_size-x) & bflag=2 & endif
	if (y+dy) gt !d.y_size then begin dy=(!d.y_size-y) & bflag=2 & endif
	;-----  Message  ------
	if bflag eq 2 then print,$
	  ' Warning: box size/position adjusted to fit window.'
 
 
	if n_elements(clr) eq 0 then clr=!p.color
 
	if not keyword_set(noer) then noer = 0
	tvcrs, x, y				  ; Put corner at given loc.
	tvbox,x,y,dx,dy,clr,noerase=noer,echo=win2  ; Draw new box.
	if keyword_set(pos) then begin
	  show_box,x,y,dx,dy,showflag,yreverse=yrev,position=pos,$
	    xfactor=xfact, yfactor=yfact,title=title
	endif
 
	if !version.os eq 'vms' then begin
	  device, cursor_standard = 35		  ; VMS position cursor.
	endif else begin
	  if !version.os ne 'DOS' then DEVICE, /CURSOR_CROSS  ; Unix cursor.
	endelse
 
LOOP:	CURSOR, X, Y, 2, /DEVICE	; Rd curs in dev units, only if moved.
 
	X = X < (!D.X_SIZE - DX) > 0		  ; Restrict box to window.
	Y = Y < (!D.Y_SIZE - DY) > 0
 	tvbox, x, y, dx, dy, clr, echo=win2	  ; Draw new box.
 
	if keyword_set(options) then begin
	  if (x ge mnox) and (x le mxox) and (y ge mnoy) and (y le mxoy) then $
	  begin
	    if optcnt ge 3 then goto, opt
	    optcnt = optcnt + 1		; Must count to 3 before doing options.
	  endif else begin
	    optcnt = 0			; Outside box, clear count.
	  endelse
	endif
 
	;------------  Right button = normal exit   ------------------------ 
	IF !mouse.button EQ 4 THEN BEGIN		  ; Check if exit.
	  CODE = !mouse.button
	  tvbox, x, y, dx, dy, -1, echo=win2		  ; Erase.
	  if keyword_set(ex) then begin
	    show_box, x, y, dx, dy, showflag, yreverse=yrev,position=pos,$
	      xfactor=xfact, yfactor=yfact,title=title
	  endif
	  if !x.s(1) ne 0 then begin
	    out = convert_coord([x,x+dx-1],[y,y+dy-1],/dev,/to_data)
	    xran = [out(0,0),out(0,1)]
	    yran = [out(1,0),out(1,1)]
	  endif
	  goto, done			  		  ; and return.
	ENDIF
 
	;----------  Middle button = menu  --------------------------------
	if !mouse.button eq 2 then begin		  ; Options menu.
	  if keyword_set(exiterase) then $
	    tvbox,x,y,dx,dy,-1,echo=win2  		  ; Erase first?
	  if keyword_set(nomen) then begin		  ; No menu, just exit.
	    goto, aex
	  endif
opt:	  menu = ['Box Options','  Cancel options','  List box position/size',$
		  '  Alternate exit','  Enter size','  Enter LL corner',$
	          '  Enter UR corner']
	  if keyword_set(options) then menu = [menu,'  Move options box']
	  optcnt = 0		; Clear options count.
	  in = 3
mloop:	  in = wmenu(menu, title=0, init=in)
	  if in lt 0 then begin
	    in = 3
	    goto, mloop
	  endif
	  if in eq 2 then begin				; List.
	    print,' Box size in X and Y:      '+strtrim(dx,2)+',  '+$
	      strtrim(dy,2)
	    print,' Lower left corner (X,Y):  '+strtrim(x,2)+',  '+strtrim(y,2)
	    print,' Upper right corner (X,Y): '+strtrim(x+dx-1,2)+',  '+$
	      strtrim(y+dy-1,2)
	    print,' b=a('+strtrim(x,2)+':'+strtrim(x+dx-1,2)+$
	      ','+strtrim(y,2)+':'+strtrim(y+dy-1,2)+')'
	    goto, mloop
	  endif
	  if in eq 3 then begin				; Abnormal exit.
aex:	if !version.os ne 'DOS' then device, /cursor_original
	    code = 2
	    goto, done
	  endif
	  if in eq 4 then begin				; Enter size.
	    txt = ''
	    read, ' Enter box size (dx, dy): ', txt
	    if txt ne '' then begin
	      txt = repchr(txt,',')
	      dx = (getwrd(txt) + 0) > 0 < (!d.x_size - x - 1)
	      dy = (getwrd(txt,1) + 0) > 0 < (!d.y_size - y - 1)
	    endif
	  endif
	  if in eq 5 then begin				; Enter LL corner.
	    txt = ''
	    read, ' Enter lower left corner (x,y): ', txt
	    if txt ne '' then begin
	      txt = repchr(txt,',')
	      x = (getwrd(txt) + 0) > 0 < (!d.x_size - dx - 1)
	      y = (getwrd(txt,1) + 0) > 0 < (!d.y_size - dy - 1)
	    endif
	  endif
	  if in eq 6 then begin				; Enter UR corner.
	    txt = ''
	    read, ' Enter upper right corner (x,y): ', txt
	    if txt ne '' then begin
	      txt = repchr(txt,',')
	      x2 = getwrd(txt) + 0
	      y2 = getwrd(txt,1) + 0
	      dx = x2 - x + 1
	      dy = y2 - y + 1
	      dx = dx > 0 < (!d.x_size - x - 1)
	      dy = dy > 0 < (!d.y_size - y - 1)
	    endif
	  endif
 
	  if in eq 7 then begin				; Move options box.
	    print,' Move options box.'
	    print,' Use mouse to position options box.'
	    print,'  New box - Right button.'
	    print,'  Cancel - Middle button.'
	    ox = mnox
	    oy = mnoy
	    dox = 75
	    doy = 30
	    movbox, ox, oy, dox, doy, c,/lock,/nomenu,/exiterase,color=clr
	    if c eq 4 then begin	; New box.
	      tv, options_image, x_option, y_option  ; clear old box.
	      x_option = ox
	      y_option = oy
	      options_image = tvrd(x_option, y_option, 75,30)	; Sv img.
	      tmp = bytarr(75,30)				; To erase box.
	      imgfrm, tmp, [255,0,255,0,255]			; Fancy border.
	      tv, tmp, x_option, y_option
	      xyouts,x_option+37.5,y_option+10,/dev,align=.5,'Options',size=1.5
	      mnox = x_option  & mxox = mnox + 74
	      mnoy = y_option  & mxoy = mnoy + 29
	      optcnt = 0	; # times in optns bx (to make less sensitive).
	    endif
	  endif
	  !mouse.button = 0
	  tvcrs, x, y		; Put cursor in right spot.
	endif
 
	;----------------  Left button = size  -----------------------------	
	IF !mouse.button EQ 1 THEN begin
	  if not keyword_set(lock) then begin
	    box_size, x, y, dx, dy, showflag, position=pos, xsize=xsiz, $
	      ysize=ysiz, yreverse=yrev, xfactor=xfact, yfactor=yfact, $
	      dxmin=dxmin, dymin=dymin, color=clr, echo=win2
	  endif
	endif
 
	;------  Display box coordinates?  -----
	if keyword_set(pos) then begin
	  show_box, x, y, dx, dy,showflag,yreverse=yrev,position=pos, $
	    xfactor=xfact, yfactor=yfact,title=title
	endif
 
	GOTO, LOOP					  ; Keep looping.
 
;----------  Clean up and exit  ------------
done:	if !version.os ne 'DOS' then device, /cursor_original  ; Restore cursr.
	if keyword_set(options) then tv, options_image, x_option, y_option  
	return
 
	END
