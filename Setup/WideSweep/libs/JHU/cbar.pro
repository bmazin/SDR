;-------------------------------------------------------------
;+
; NAME:
;       CBAR
; PURPOSE:
;       Make a color bar.
; CATEGORY:
; CALLING SEQUENCE:
;       cbar
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         VMIN=vmn  Minimum value of color bar parameter (def=0).
;         VMAX=vmx  Maximum value of color bar parameter (def=top).
;         CMIN=cmn  Color that represents vmn (def=0).
;         CMAX=cmx  Color that represents vmx (def=top).
;           where top = !d.table_size-1.
;         CCLIP=cc  Actual max color index allowed (def=!d.table_size-1)
;         /HORIZONTAL Colors vary horizontally (def).
;         /VERTICAL   Colors vary vertical.
;         /BOTTOM   Horizontal axis on bottom (def).
;         /TOP      Horizontal axis on top.
;         /RIGHT    Vertical axis on right (def).
;         /LEFT     Vertical axis on left.
;         /KEEP_SCALING Keep color bar axes scaling on exit.
;         XSAVE=xs, YSAVE=ys, PSAVE=ps returned original scaling.
;           Use /KEEP to plot in cbar coordinates (x=[0,1],y=[vmn,vmx]).
;           May then restore original scale: !x=xs & !y=ys & !p=ps
;         Plus all keywords accepted by PLOT.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Bar is positioned using the POSITION keyword.
;         To display a title use TITLE and so on.
; MODIFICATION HISTORY:
;       R. Sterner, 13 Dec, 1993
;       R. Sterner, 1994 Jul 5 --- Added axis positioning.
;       R. Sterner, 1995 Dec 10 --- Allow position to be in device coords.
;       R. Sterner, 1995 Dec 18 --- Fixed to not clobber current xy scaling.
;       R. Sterner, 1996 Dec  9 --- Added CCLIP keyword.
;       R. Sterner, 1998 Jan 23 --- Added charthick keyword.
;       R. Sterner, 2003 Jan 21 --- Added keyword /KEEP_SCALING, and [X|Y|P]SAVE.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro cbar, vmin=vmn, vmax=vmx, cmin=cmn, cmax=cmx, horizontal=hor, $
	  vertical=ver, top=top, bottom=bottom, left=left, right=right, $
	  position=pos, color=col, title=ttl, _extra=extra, keep_scaling=keep, $
	  charsize=csz, device=device, cclip=cclip, charthick=cthk, $
	  xsave=xsave, ysave=ysave, psave=psave, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Make a color bar.'
	  print,' cbar'
	  print,'   All arguments are keywords.'
	  print,' Keywords:'
	  print,'   VMIN=vmn  Minimum value of color bar parameter (def=0).'
	  print,'   VMAX=vmx  Maximum value of color bar parameter (def=top).'
	  print,'   CMIN=cmn  Color that represents vmn (def=0).'
	  print,'   CMAX=cmx  Color that represents vmx (def=top).'
	  print,'     where top = !d.table_size-1.'
	  print,'   CCLIP=cc  Actual max color index allowed (def=!d.table_size-1)'
	  print,'   /HORIZONTAL Colors vary horizontally (def).'
	  print,'   /VERTICAL   Colors vary vertical.'
	  print,'   /BOTTOM   Horizontal axis on bottom (def).'
	  print,'   /TOP      Horizontal axis on top.'
	  print,'   /RIGHT    Vertical axis on right (def).'
	  print,'   /LEFT     Vertical axis on left.'
	  print,'   /KEEP_SCALING Keep color bar axes scaling on exit.'
	  print,'   XSAVE=xs, YSAVE=ys, PSAVE=ps returned original scaling.'
	  print,'     Use /KEEP to plot in cbar coordinates (x=[0,1],y=[vmn,vmx]).'
	  print,'     May then restore original scale: !x=xs & !y=ys & !p=ps'
	  print,'   Plus all keywords accepted by PLOT.'
	  print,' Notes: Bar is positioned using the POSITION keyword.'
 	  print,'   To display a title use TITLE and so on.'
	  return
	endif
 
	;-------  Set defaults  ---------------
	if n_elements(vmn) eq 0 then vmn = 0.
	if n_elements(vmx) eq 0 then vmx = !d.table_size-1
	if n_elements(cmn) eq 0 then cmn = 0
	if n_elements(cmx) eq 0 then cmx = !d.table_size-1
	if n_elements(cclip) eq 0 then cclip = !d.table_size-1
	if n_elements(col) eq 0 then col = !p.color
	if n_elements(ttl) eq 0 then ttl = ''
	if n_elements(csz) eq 0 then csz = !p.charsize
	if n_elements(cthk) eq 0 then cthk = !p.charthick
	if n_elements(device) eq 0 then device = 0
 
	;----  Set orientation dependent parameters  ----------
	if keyword_set(ver) then begin		; Vertical.
	  dim = [1,256]
	  x = [0,1]
	  y = [vmn,vmx]
	  ax = 2				; Right.
	  if keyword_set(left) then ax = 4	; Left.
	  if n_elements(pos) eq 0 then pos = [.4,.2,.6,.8]
	endif else begin			; Horizontal.
	  dim = [256,1]
	  x = [vmn,vmx]
	  y = [0,1]
	  ax = 1				; Bottom.
	  if keyword_set(top) then ax = 3	; Top.
	  if n_elements(pos) eq 0 then pos = [.2,.4,.8,.6]
	endelse
 
	;-----  Make bar  --------------
	z = reform(scalearray(maken(vmn,vmx,256),vmn,vmx,cmn,cmx),dim)<cclip
 
	;------  Plot bar  -------------
	xsave = !x	; Save incoming X/Y scaling.
	ysave = !y
	psave = !p
	tn = [' ',' ']
	plot, x,y,/xstyl,/ystyl,/nodata,/noerase,xticks=1,xtickn=tn,$
	  yticks=1,ytickn=tn,xminor=1,yminor=1,pos=pos, col=col, titl=ttl, $
	  chars=csz, xran=x, yran=y, device=device, charthick=cthk
	imgunder, z
	plot, x,y,/xstyl,/ystyl,/nodata,/noerase,xticks=1,xtickn=tn,$
	  yticks=1,ytickn=tn,xminor=1,yminor=1,pos=pos, col=col, titl=ttl, $
	  chars=csz, xran=x, yran=y, device=device, charthick=cthk
 
	;--------  Axis  ------------
	case ax of
1:	axis,xaxis=0,/xstyl,chars=csz,col=col, charthick=cthk,_extra=extra
2:	axis,yaxis=1,/ystyl,chars=csz,col=col, charthick=cthk,_extra=extra
3:	axis,xaxis=1,/xstyl,chars=csz,col=col, charthick=cthk,_extra=extra
4:	axis,yaxis=0,/ystyl,chars=csz,col=col, charthick=cthk,_extra=extra
	endcase
 
	if keyword_set(keep) then return
	!x = xsave	; Restore incoming X/Y scaling.
	!y = ysave
	!p = psave
 
	return
 
	end
