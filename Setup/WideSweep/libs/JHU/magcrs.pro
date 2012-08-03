;-------------------------------------------------------------
;+
; NAME:
;       MAGCRS
; PURPOSE:
;       Show a magnified window around given point and wait for a cursor change.
; CATEGORY:
; CALLING SEQUENCE:
;       magcrs, x, y
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /INITIALIZE  Must be done before using or after a
;           color table change.  Must be done for each different
;           window that uses magcrs.
;         STATE=state  Structure with state information.
;           Returned for /INIT.  Must give for each call.
;           Allows multiple mag cursors for multiple windows.
;         MAG=m    Mag factor (def=10).  On /INIT only.
;         SIZE=s   Mag window size (def=200).  On /INIT only.
;         XPOS=xpos, YPOS=ypos Set mag window position.  On /INIT only.
;         WINDOW=win Specified mag window, else make one.
;           Specified window must be expected size.  On /INIT only.
;         /NOCURSOR means given x,y are dev coord, do not call
;           cursor.  Returned x,y are /DATA by default.
;         /DATA    Work in data coordinates (default).
;         /DEVICE  Work in device coordinates.
;         /NORMAL  Work in normalized coordinates.
;         /VER=ver draw vertical line through cursor.
;           return data under it in ver. Must use in /INIT also.
;         /HOR=hor draw horizontal line through cursor.
;           return data under it in hor. Must use in /INIT also.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Operates like CURSOR,X,Y,/CHANGE, that is
;         after each move or a button up or down.  Check !mouse
;         to find which button was last clicked.
;         When finished with mag window remove it:
;           wdelete,st.win
;         Sets starting point and cursor to given x,y.
;         WINDOW keyword allows use in a draw widget. Use /NOCURSOR.
;         Examples: magcrs,/init,state=st
;                   for i=0,300 do magcrs,state=st,x,y
;                   magcrs,/init,state=st,/ver,/hor
;                   for i=0,300 do magcrs,state=st,/ver,/hor,x,y
;         Use /INIT only for new image or new window.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Feb 26
;       R. Sterner, 1998 Apr 10 --- Added WINDOW keyword, allows use in widget.
;       Also added NOCURSOR keyword.
;       R. Sterner, 2002 Sep 05 --- Added /VER and /HOR.
;       R. Sterner, 2002 Sep 09 --- Made /VER and /HOR use XOR mode.
;       R. Sterner, 2002 Sep 22 --- Added XPOS and YPOS.
;       R. Sterner, 2003 May 13 --- Upgraded for true color.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro magcrs_up, x, y, st, hor=hor, ver=ver
 
	;----  Deal with H/V lines: Erase any lines, read data ---
	if st.herase then hline,/erase,/xmode
	if st.verase then vline,/erase,/xmode
 
	;---------  Read cursor  ----------
	t = tvrd2(x-st.rdsz2,y-st.rdsz2,st.rdsz,st.rdsz,true=st.vflag)
 
	;----  Deal with H/V lines: Redraw lines  ----------
	if st.harg then begin
	  hline,y,/dev,/xmode,/noerase	; Draw new line (last erased above).
	  st.herase = 1				; Erase next time around.
	endif
	if st.varg then begin
	  vline,x,/dev,/xmode,/noerase
	  st.verase = 1
	endif
 
	;---------  Prepare magnified view  ----------
;	t = rebin(t,st.wsz,st.wsz,/samp)	; Magnify.
	t = img_resize(t,imgmax=st.wsz,/samp)	; Magnify.
	if st.vflag eq 0 then begin
	  it = t(st.xmid+1,st.ymid+1)             ; Mid pixel.
          if st.lum(it) lt 128 then cc=st.br $
             else cc=st.dr                        ; Outline color.
          t(st.xmid:st.xmid+st.mag,st.ymid)=cc    ; Draw mid pixel outline.
          t(st.xmid:st.xmid+st.mag,st.ymid+st.mag)=cc
          t(st.xmid,st.ymid:st.ymid+st.mag)=cc
          t(st.xmid+st.mag,st.ymid:st.ymid+st.mag)=cc
	endif else begin
	  it = t(*,st.xmid+1,st.ymid+1)
	  lum = .3 * it(0) + .59 * it(1) + .11 * it(2)
          if lum lt 128 then cc=st.br $
             else cc=st.dr                        ; Outline color.
          t(*,st.xmid:st.xmid+st.mag,st.ymid)=cc    ; Draw mid pixel outline.
          t(*,st.xmid:st.xmid+st.mag,st.ymid+st.mag)=cc
          t(*,st.xmid,st.ymid:st.ymid+st.mag)=cc
          t(*,st.xmid+st.mag,st.ymid:st.ymid+st.mag)=cc
	endelse
	;------  Display magnified view  ------
	wset,st.win
	device,get_graphics=gmode	; Need Graphics mode 3.  Get current.
	device,set_graphics=3		; Set mode 3.
	tv,t,tr=st.vflag
	device,set_graphics=gmode	; Restore old mode.
	wset,st.win0
 
	return
	end
 
;====================================================
;	magcrs.pro = Mag window cursor
;	R. Sterner, 1996 Feb 23
;====================================================
 
	pro magcrs, x0, y0, initialize=init, state=st, mag=mag0, $
	  size=msize0, data=dat0, device=dev0, normal=nrm0, $
	  window=wins, nocursor=nocursor, help=hlp, hor=hor, ver=ver, $
	  xpos=xpos, ypos=ypos
 
	if keyword_set(hlp) then begin
	  print,' Show a magnified window around given point and wait for a cursor change.'
	  print,' magcrs, x, y'
	  print,'   x,y = cursor position.    in,out'
	  print,' Keywords:'
	  print,'   /INITIALIZE  Must be done before using or after a'
	  print,'     color table change.  Must be done for each different'
	  print,'     window that uses magcrs.'
	  print,'   STATE=state  Structure with state information.'
	  print,'     Returned for /INIT.  Must give for each call.'
	  print,'     Allows multiple mag cursors for multiple windows.'
	  print,'   MAG=m    Mag factor (def=10).  On /INIT only.'
	  print,'   SIZE=s   Mag window size (def=200).  On /INIT only.'
	  print,'   XPOS=xpos, YPOS=ypos Set mag window position.  On /INIT only.'
	  print,'   WINDOW=win Specified mag window, else make one.'
	  print,'     Specified window must be expected size.  On /INIT only.'
	  print,'   /NOCURSOR means given x,y are dev coord, do not call'
	  print,'     cursor.  Returned x,y are /DATA by default.'
	  print,'   /DATA    Work in data coordinates (default).'
	  print,'   /DEVICE  Work in device coordinates.'
	  print,'   /NORMAL  Work in normalized coordinates.'
	  print,'   /VER=ver draw vertical line through cursor.'
	  print,'     return data under it in ver. Must use in /INIT also.'
	  print,'   /HOR=hor draw horizontal line through cursor.'
	  print,'     return data under it in hor. Must use in /INIT also.'
	  print,' Notes: Operates like CURSOR,X,Y,/CHANGE, that is'
	  print,'   after each move or a button up or down.  Check !mouse'
	  print,'   to find which button was last clicked.'
	  print,'   When finished with mag window remove it:'
	  print,'     wdelete,st.win'
	  print,'   Sets starting point and cursor to given x,y.'
	  print,'   WINDOW keyword allows use in a draw widget. Use /NOCURSOR.'
	  print,'   Examples: magcrs,/init,state=st'
	  print,'             for i=0,300 do magcrs,state=st,x,y'
	  print,'             magcrs,/init,state=st,/ver,/hor'
	  print,'             for i=0,300 do magcrs,state=st,/ver,/hor,x,y'
	  print,'   Use /INIT only for new image or new window.'
	  return
	endif
 
	;-------  Initialize  -------------------
	if keyword_set(init) then begin
 
          if n_elements(mag0) eq 0 then mag0=1          ; Force defined.
          if n_elements(msize0) eq 0 then msize0=200    ; Def mag win size.
          msize = round(msize0)                         ; Rounded size.
          mag = round(mag0)                             ; Rounded mag.
          if mag eq 1 then mag=10                       ; Def is 10.
          rdsz = round(float(msize)/mag)                ; Read size.
          rdsz2 = rdsz/2                                ; Offset.
          xmid = rdsz2*mag                              ; Mag win midpoint.
          ymid = rdsz2*mag
          wsz = rdsz*mag                                ; True mag win size.
 
	  if n_elements(wins) eq 0 then wins=29		; Look for given win.
	  if n_elements(xpos) eq 0 then xpos=0		; Look for position.
	  if n_elements(ypos) eq 0 then ypos=0		; Look for position.
 
	  if keyword_set(vline) then vline,/reset,/xmode
	  if keyword_set(hline) then hline,/reset,/xmode
 
	  device, get_visual_name=vis			; Get visual type.
	  vflag = vis ne 'PseudoColor'			; 0 if PseudoColor.
;	  if vflag eq 1 then tvtr=3 else tvtr=0
 
	  if vflag eq 0 then begin
	    tvlct,r,g,b,/get
	    lum = .3 * r + .59 * g + .11 * b
	    br = (where(lum eq max(lum)))(0)
	    dr = (where(lum eq min(lum)))(0)
	  endif else begin
	    lum = 0
	    br = 255
	    dr = 0
	  endelse
 
	  st = {lum:lum, br:br, dr:dr, mag:mag, rdsz:rdsz, rdsz2:rdsz2, $
	    wsz:wsz, xmid:xmid, ymid:ymid, win:wins, win0:!d.window, $
	    herase:0, verase:0, harg:keyword_set(hor), varg:keyword_set(ver), $
	    xpos:xpos, ypos:ypos, vflag:vflag}
 
	  if n_params(0) eq 0 then return		; Just init.
	endif
	;--------------------------------------
 
	;-------  Check that state structure is given  ---------
	if n_elements(st) eq 0 then begin
	  print,' Error in magcrs: Need to give state structure.  This'
	  print,'   structure is returned on /INIT and must be sent for'
	  print,'   each call to magcrs afterward: magcrs,x,y,state=st.'
	  return
	endif
 
	;--------  Take care of some entry items  ---------
	;-----  Coordinates  -------------
        dat = keyword_set(dat0)
        dev = keyword_set(dev0)
        nrm = keyword_set(nrm0)
        if dat+dev+nrm gt 1 then begin
          print,' Error in lini: set only one of /DATA, /DEVICE, or /NORMAL.'
          return
        endif
        if dat eq 0 then dat=1-(dev>nrm)        ; Def is /data.
	if dat eq 1 then begin
	  if !x.s(1) eq 0 then begin
	    print,' Error in magcrs: data coordinates not yet established.' 
            print,'  Must make a plot before calling magcrs or use /DEVICE'
            print,'   or /NORMAL keyword.' 
            stop 
	  endif
	endif
	;-----  Cursor position (from entry coordinates to device) ---------
	if not keyword_set(nocursor) then begin
          if dat then begin
            tmp = round(convert_coord(x0,y0,/data,/to_dev))
            x=tmp(0,0) & y=tmp(1,0)
          endif
          if dev then begin
            x=round(x0) & y=round(y0)
          endif
          if nrm then begin
            tmp = round(convert_coord(x0,y0,/norm,/to_dev))
            x=tmp(0,0) & y=tmp(1,0)
          endif
	endif else begin	; On /NOCURSOR assume iput is /dev.
            x=round(x0) & y=round(y0)
	endelse
	;----  Mag window  --------
	device,window_state=wstate			; Any mag window?
	if wstate(st.win) eq 1 then begin		; Yes.
	  mwin=st.win					; Get its number.
	  st.win = mwin					; Update state.
	endif else begin 				; No.
	  window, /free, xs=st.wsz, ys=st.wsz, $	; Make one.
	    title='Mag: '+strtrim(st.mag,2), $
	    xpos=st.xpos, ypos=st.ypos
	  mwin = !d.window				; Get its number.
	  st.win = mwin					; Update state.
	  wset, st.win0
	  magcrs_up, x, y, st, hor=hor, ver=ver
	endelse
 
	;---------  Read cursor and display magnified view  ----------
	wset, st.win0
	if keyword_set(init) then begin
	  tvcrs,x,y		; Put cursor to first point.
	  magcrs_up, x, y, st, hor=hor, ver=ver	; First mag window.
	endif
	if not keyword_set(nocursor) then cursor,x,y,2,/device
	magcrs_up, x, y, st, hor=hor, ver=ver
 
	;-------  Return last coordinates in entry coord system  ----------
        if dat then begin
          tmp = convert_coord(x,y,/dev,/to_data)
          x0=tmp(0,0) & y0=tmp(1,0)
        endif
        if dev then begin
          x0=x & y0=y
        endif
        if nrm then begin
          tmp = convert_coord(x,y,/dev,/to_norm)
          x0=tmp(0,0) & y0=tmp(1,0)
        endif
 
	return
	end
