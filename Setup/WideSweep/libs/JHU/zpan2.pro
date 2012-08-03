;-------------------------------------------------------------
;+
; NAME:
;       ZPAN2
; PURPOSE:
;       Zoom and pan around an image using the mouse, mark center.
; CATEGORY:
; CALLING SEQUENCE:
;       zpan2, ix, iy
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         INWINDOW=w1  input window (window to zoom).
;         ZOOM=zm  Initial zoom factor (def=2).
;         SIZE=sz  Approximate size of zoom window (def=250).
;         XPOS=xp,YPOS=yp Mag window position.
;         /KEEP keep mag window on exit (else delete it).
;           A new window will appear each time zpan2 called,
;           /KEEP just does not delete it on exit.
;         MAGWIN=mwin Window index of mag window.  Returned on exit
;           and may be sent in but must have correct size.
;           Can use with /KEEP.
; OUTPUTS:
; COMMON BLOCKS:
;       zpan2_com
; NOTES:
;       Note: The mag window may be dragged to a new position.
;         The new position will be remembered on the next call
;         to zpan2.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 May 17
;       R. Sterner, 2004 May 31 --- Added MAGWIN keyword.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro zpan2, ix1, iy1, help=hlp, inwindow=inwin, $
	  zoom=zsize, size=sz, xpos=xpos1, ypos=ypos1, keep=keep, $
	  magwin=magwin
 
	common zpan2_com, zsize0, sz0, ix0, iy0, xpos0, ypos0, vflag, tvtr
	;-------------------------------------------------------------------
	; zsize0 = Default zoom factor.
	; sz0 = Default mag window size.
	; ix0, iy0 = Cursor position (dev).
	; xpos0, ypos0 = Mag window position (dev).
	; vflag = 24-bit color flag (1=true).
	; tvtr = Value for true on tv command.
	;-------------------------------------------------------------------
 
        if keyword_set(hlp) then begin
          print,' Zoom and pan around an image using the mouse, mark center.'
          print,' zpan2, ix, iy'
          print,'   ix,iy = Cursor position.  in,out.'
	  print,' Keywords:'
	  print,'   INWINDOW=w1  input window (window to zoom).'
	  print,'   ZOOM=zm  Initial zoom factor (def=2).'
	  print,'   SIZE=sz  Approximate size of zoom window (def=250).'
	  print,'   XPOS=xp,YPOS=yp Mag window position.'
	  print,'   /KEEP keep mag window on exit (else delete it).'
	  print,'     A new window will appear each time zpan2 called,'
	  print,'     /KEEP just does not delete it on exit.'
	  print,'   MAGWIN=mwin Window index of mag window.  Returned on exit'
	  print,'     and may be sent in but must have correct size.'
	  print,'     Can use with /KEEP.'
	  print,' Note: The mag window may be dragged to a new position.'
	  print,'   The new position will be remembered on the next call'
	  print,'   to zpan2.'
          return
        endif
 
	;------  Initialize common  --------
	if n_elements(sz0) eq 0 then sz0 = 250	; Default mag win size.
	if n_elements(zsize0) eq 0 then zsize0=2   ; Default zoom.
	if n_elements(ix1) ne 0 then ix0 = ix1	; New point (incoming).
	if n_elements(iy1) ne 0 then iy0 = iy1
	if n_elements(ix0) eq 0 then ix0 = 0	; No point given, def=0,0.
	if n_elements(iy0) eq 0 then iy0 = 0
	if n_elements(vflag) eq 0 then begin
	  device, get_visual_name=vis		; Get visual type.
	  vflag = vis ne 'PseudoColor'		; 0 if PseudoColor.
          tvtr = 0
          if vflag eq 1 then tvtr=3		; True color flag.
	endif
	if n_elements(xpos0) eq 0 then xpos0=0	; Force common pos defined.
	if n_elements(ypos0) eq 0 then ypos0=0
	if n_elements(xpos1) ne 0 then begin
	  xpos = xpos1				; Mag win position given.
	endif else begin
	  xpos = xpos0				; Use last position.
	endelse
	if n_elements(ypos1) ne 0 then begin
	  ypos = ypos1				; Mag win position given.
	endif else begin
	  ypos = ypos0				; Use last position.
	endelse
 
	;------  Initialize  ------
	windef = !d.window				; Current window.
	if n_elements(inwin) eq 0 then inwin=windef	; Def=curr win.
	if inwin lt 0 then return			; No windows.
	tvcrs, ix0, iy0				; Put cursor on image point.
	if n_elements(sz) eq 0 then sz = sz0		; Zoom window size.
	if n_elements(zsize) eq 0 then zsize = zsize0	; Zoom factor.
	sz0 = sz
	zsize0 = zsize
 
	wshow,inwin			 ; Put image window up front.
	wset, inwin			 ; Work in image window.
 
	;-------  Init mag cursor  ------
	magcrs,/init,state=magstate, mag=zsize, size=sz, $
	  xpos=xpos,ypos=ypos, window=magwin
	ix = ix0			; Current pixel.
	iy = iy0
	ix2 = -1			; Last pixel.
	iy2 = -1
	flag = 0			; Size change flag.
	wset, inwin			; Set to target window.
 
	wht = tarclr(255,255,255)	; Coordinates colors.
	blk = tarclr(0,0,0)
	bold = [5,2]
	clr = [wht,blk]
 
	repeat begin
	  !err = 0
	  magcrs, ix, iy, /dev, state=magstate	; Like cursor but with mag win.
	  err = !err
	  wset, magstate.win
	  xytxt = strtrim(ix,2)+' '+strtrim(iy,2)
	  xyoutb,5,5,/dev,xytxt,bold=bold,col=clr,chars=1.5
	  ;--------  Left mouse button: zoom out  ----------
	  if err eq 1 then begin	; Toggle cross-hairs.
	    zsize = (zsize-1)>2		; Reduce zoom factor.
	    flag = 1			; Set size change flag.
	    wait, .05			; Computer too fast, must wait.
	  endif
	  ;---------  Middle mouse button: zoom in  ---------
	  if err eq 2 then begin
	    zsize = (zsize+1)<20	; Increase zoom factor.
	    flag = 1			; Set size change flag.
	    wait, .05			; Computer too fast, must wait.
	  endif
	  ;---------  New zoom window  --------
	  if flag eq 1 then begin
	    wsize = fix(zsize*fix(sz/zsize))	; Actual zoom window size.
	    wset, magstate.win			; Set to mag window.
	    device, get_window_position=pos	; Get window position.
	    window_drift,dx,dy			; Get window drift.
	    xpos = pos(0)-dx			; Corrected window position.
	    ypos = pos(1)-dy
	    wdelete,magstate.win			; Delete old mag win.
	    wset, inwin					; Set to input win.
	    magcrs,/init,state=magstate, mag=zsize, size=wsize, $  ; New magwin.
	      xpos=xpos,ypos=ypos
	  endif
	  flag = 0			; Unset size change flag.
	endrep until err eq 4		; Right button pressed?
 
	;-------  Finish up  ------------------
	zsize0 = zsize			; Remember zoom,
	ix0 = ix			; and Cursor location.
	iy0 = iy
	ix1 = ix			; Return point.
	iy1 = iy
	wset, magstate.win		; Set to mag window.
	device, get_window_position=pos	; Mag window position.
	window_drift,dx,dy		; Get window drift.
	xpos0 = pos(0)-dx		; Remember mag win position.
	ypos0 = pos(1)-dy
	wset, inwin			; Set to input win.
 
	if not keyword_set(keep) then wdelete, magstate.win
	magwin = magstate.win
 
	return
 
	end
