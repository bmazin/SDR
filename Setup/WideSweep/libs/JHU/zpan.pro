;-------------------------------------------------------------
;+
; NAME:
;       ZPAN
; PURPOSE:
;       Zoom and pan around an image using the mouse.
; CATEGORY:
; CALLING SEQUENCE:
;       pan
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         INWINDOW=w1  input window (window to zoom).
;         OUTWINDOW=w2 output window (magnified image).
;         ZOOM=zm  Initial zoom factor (def=2).
;         SIZE=sz  Approximate size of zoom window (def=250).
; OUTPUTS:
; COMMON BLOCKS:
;       zpan_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 8 Oct, 1993
;       R. Sterner, 1999 Oct 05 --- Modified for true color.
;       R. Sterner, 2001 Mar 30 --- Modified to know which windows to use.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro zpan, help=hlp, inwindow=inwin, outwindow=outwin, $
	  zoom=zsize, size=sz
 
	common zpan_com, inwin0, outwin0, zsize0, sz0, ix0, iy0, vflag, tvtr
 
        if keyword_set(hlp) then begin
          print,' Zoom and pan around an image using the mouse.'
          print,' pan'
          print,'   No args.'
	  print,' Keywords:'
	  print,'   INWINDOW=w1  input window (window to zoom).'
	  print,'   OUTWINDOW=w2 output window (magnified image).'
	  print,'   ZOOM=zm  Initial zoom factor (def=2).'
	  print,'   SIZE=sz  Approximate size of zoom window (def=250).'
          return
        endif
 
	;------  Initialize common  --------
	winlist, list,free=free,/quiet
	if list(0) lt 0 then return
	if n_elements(inwin0) eq 0 then inwin0=-1
	if n_elements(outwin0) eq 0 then outwin0=-1
	if outwin0 eq inwin0 then outwin0=-1
	w = where(inwin0 eq list,cnt)
	if cnt eq 0 then inwin0=-1
	w = where(outwin0 eq list,cnt)
        if cnt eq 0 then outwin0=-1
	if inwin0 lt 0 then inwin0 = list(0)
	if outwin0 lt 0 then outwin0 = free(0)
	if n_elements(sz0) eq 0 then sz0 = 250
	if n_elements(zsize0) eq 0 then zsize0 = 2
	if n_elements(ix0) eq 0 then ix0 = 0
	if n_elements(iy0) eq 0 then iy0 = 0
	tvcrs, ix0, iy0
	if n_elements(vflag) eq 0 then begin
	  device, get_visual_name=vis             ; Get visual type.
	  vflag = vis ne 'PseudoColor'            ; 0 if PseudoColor.
          tvtr = 0
          if vflag eq 1 then tvtr=3               ; True color flag.
	endif
 
	;------  Initialize  ------
	if n_elements(inwin) eq 0 then inwin = inwin0	  ; Input window.
	if n_elements(outwin) eq 0 then outwin = outwin0  ; Zoom window #.
	if n_elements(sz) eq 0 then sz = sz0		  ; Zoom window size.
	if n_elements(zsize) eq 0 then zsize = zsize0	  ; Zoom factor.
	inwin0 = inwin					  ; Keep common
	outwin0 = outwin				  ;   up to date.
	sz0 = sz
	zsize0 = zsize
 
;	if inwin lt 32 then wshow,inwin	 ; Put image window up front.
	wshow,inwin			 ; Put image window up front.
	wset, inwin			 ; Work in image window.
 
 
	ix2 = -1			; Last pixel.
	iy2 = -1
	flag = 1			; Size change flag.
	wset, inwin
 
	repeat begin
	  !err = 0
	  cursor, /dev, ix, iy, 0	; Read cursor position.
	  ;--------  Left mouse button: zoom out  ----------
	  if !err eq 1 then begin	; Toggle cross-hairs.
	    zsize = (zsize-1)>2		; Reduce zoom factor.
	    flag = 1			; Set size change flag.
	    wait, .05			; Computer too fast, must wait.
	  endif
	  ;---------  Middle mouse button: zoom in  ---------
	  if !err eq 2 then begin
	    zsize = (zsize+1)<20	; Increase zoom factor.
	    flag = 1			; Set size change flag.
	    wait, .05			; Computer too fast, must wait.
	  endif
	  ;---------  New zoom window  --------
	  if flag eq 1 then begin
	    wsize = fix(zsize*fix(sz/zsize))	; Actual zoom window size.
	    wid = wsize/zsize			; Width to read.
	    wlo = wid/2				; Window start.
	    window, outwin, xs=wsize, ys=wsize, $  ; Make zoom window.
	      title=strtrim(zsize,2)+' = mag'
	    wset, inwin
	  endif
	  ;-------  Read image  ----------
	  if (ix ne ix2) or (iy ne iy2) or (flag eq 1) then begin
	    t = tvrd2(ix-wlo, iy-wlo, wid, wid,true=tvtr)	; Read image.
	    ix2 = ix
	    iy2 = iy
	    wset, outwin
	    tv, rebin(t,wsize,wsize,tvtr>1,/samp),tr=tvtr ; Display zoomed img.
	    wset, inwin
	  endif
	  flag = 0				; Unset size change flag.
	endrep until !err eq 4		; Right button pressed?
 
	zsize0 = zsize			; Remember zoom.
	ix0 = ix			; And position.
	iy0 = iy
 
	return
 
	end
