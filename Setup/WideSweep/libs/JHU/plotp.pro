;-------------------------------------------------------------
;+
; NAME:
;       PLOTP
; PURPOSE:
;       Pencode plot routine.  Allows disconnected lines.
; CATEGORY:
; CALLING SEQUENCE:
;       plotp, x, y, [p]
; INPUTS:
;       x,y = arrays of x and y coordinates to plot.       in
;       p = optional pen code array.                       in
;           0: move to point, 1: draw to point.
; KEYWORD PARAMETERS:
;       Keywords:
;         /DATA plots in data coordinates (default).
;         /DEVICE plots in device coordinates.
;         /NORMAL plots in normalized coordinates.
;         COLOR=clr.  Set plot color (def=!p.color).
;         THICK=thk.  Plot thickness (def=!p.thick).
;         LINESTYLE=ls.  Set linestyle (def=!p.linestyle).
;         PSYM=psym  Plot symbol (def=none).
;         SYMSIZE=symsz Symbol size (def=1.).
;         /CLIP means clip to plot window (def=no clipping).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Oct, 1989
;       R. Sterner, 10 Dec, 1990 --- added LINESTYLE.
;       R. Sterner, 19 Dec, 1991 --- made loop index long.
;       R. Sterner, 1999 Dec 03 --- Added THICK.
;       R. Sterner, 2002 Jul 16 --- Now clips for any coordinate system.
;       R. Sterner, 2002 Jul 16 --- Fix z-buffer problem.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro plotp, x0, y0, p0, help=hlp, data=dt, device=dv, $
	  normalized=nm, color=clr, linestyle=linestyle, thick=thk, $
	  clip=clip, psym=psym, symsize=symsz
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Pencode plot routine.  Allows disconnected lines.'
	  print,' plotp, x, y, [p]'
	  print,'   x,y = arrays of x and y coordinates to plot.       in'
	  print,'   p = optional pen code array.                       in'
	  print,'       0: move to point, 1: draw to point.'
	  print,' Keywords:'
	  print,'   /DATA plots in data coordinates (default).'
	  print,'   /DEVICE plots in device coordinates.'
	  print,'   /NORMAL plots in normalized coordinates.'
	  print,'   COLOR=clr.  Set plot color (def=!p.color).'
	  print,'   THICK=thk.  Plot thickness (def=!p.thick).'
	  print,'   LINESTYLE=ls.  Set linestyle (def=!p.linestyle).'
	  print,'   PSYM=psym  Plot symbol (def=none).'
	  print,'   SYMSIZE=symsz Symbol size (def=1.).'
	  print,'   /CLIP means clip to plot window (def=no clipping).'
	  return
	endif
 
	;----  Force arrays to be 1-d  ------
	x = reform(x0)
	y = reform(y0)
	if n_elements(p0) eq 0 then p=x*0+1 else p=reform(p0)
 
	;----  set plot coordinate system  ------
	flg = 1				 		; Default = data.
	if keyword_set(dt) then flg = 1    		; data
	if keyword_set(dv) then flg = 2   		; device
	if keyword_set(nm) then flg = 3    		; normalized
	if n_elements(clr) eq 0 then clr = !p.color	; color
	if n_elements(linestyle) eq 0 then linestyle=!p.linestyle  ; lnstyl.
	if n_elements(thk) eq 0 then thk=!p.thick	; Thick.
	if n_elements(psym) eq 0 then psym=0		; Plot symbol.
	if n_elements(symsz) eq 0 then symsz=1		; Symbol size.
 
	;-----  Deal with clipping  ----------
	noclip = 1		; Default is not to clip.
	if keyword_set(clip) then noclip=0
	;-----  Z-buffer needs explicit clipping window  ----
	case flg of	; clipping window must match coordinate system used.
1:	c_win = [!x.crange(0),!y.crange(0),!x.crange(1),!y.crange(1)]
2:	begin
	  t1 = round(!x.window*!d.x_size)
	  t2 = round(!y.window*!d.y_size)
	  c_win = [t1(0),t2(0),t1(1),t2(1)]
	end
3:	c_win = [!x.window(0),!y.window(0),!x.window(1),!y.window(1)]
	endcase
 
	;-----  Find breaks in curve  -------
	p2 = p			; Copy pencode array.
	p2(0) = 0		; Force first value to 0.
	w0 = where([p2,0] eq 0)	; Find all 0s, add 0 to end of p.
	nw0 = n_elements(w0)
 
	;-----  plot curve  ---------
	for i = 0L, nw0-2 do begin
	  xx = x(w0(i):(w0(i+1)-1))	; Extract first connected set.
	  yy = y(w0(i):(w0(i+1)-1))
	  case flg of			; Use correct coordinate system.
1:	  plots, xx, yy, /data,   color=clr, linestyle=linestyle, $
	    psym=psym, symsize=symsz, thick=thk,noclip=noclip,clip=c_win
2:	  plots, xx, yy, /device, color=clr, linestyle=linestyle, $
	    psym=psym, symsize=symsz, thick=thk,noclip=noclip,clip=c_win
3:	  plots, xx, yy, /normal, color=clr, linestyle=linestyle, $
	    psym=psym, symsize=symsz, thick=thk,noclip=noclip,clip=c_win
	  endcase
	endfor
 
	return
	end
