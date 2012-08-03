;-------------------------------------------------------------
;+
; NAME:
;       COMPLOT
; PURPOSE:
;       Plot complex numbers as points in the complex plane.
; CATEGORY:
; CALLING SEQUENCE:
;       complot, z
; INPUTS:
;       z = array of complex numbers to plot.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=clr Plot color (def=!p.color).
;         RANGE=rng Make plot range be [-rng,rng] for both x and y.
;         CIRCLES = r Array of radii of optional circles (def=none).
;         CCOLOR = cclr Circles color (def=!p.color).
;         PSYM = psym Plot symbol (def=!p.psym).
;         SYMSIZ = ssz Symbol size (def=!p.symsize).
;         SYMCOLOR = sclr Symbol color (def=clr).
;         /OVER means do an overplot.
;         /NOAXES means do not plot x and y axes.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Any plot keywords may be given.
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Dec 29
;       R. Sterner, 2005 Jan 13 --- Added /OVER, RANGE=r, /NOAXES.
;       R. Sterner, 2005 Jan 17 --- Force input to gives arrays.
;       R. Sterner, 2005 Sep 15 --- Added COLOR=clr.
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro complot, z, psym=psym, symsize=ssz, symcolor=sclr, $
	  circles=rd, ccolor=cclr, color=clr, _extra=extra, $
	  over=over, range=rng, noaxes=noaxes, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot complex numbers as points in the complex plane.'
	  print,' complot, z'
	  print,'   z = array of complex numbers to plot.  in'
	  print,' Keywords:'
	  print,'   COLOR=clr Plot color (def=!p.color).'
	  print,'   RANGE=rng Make plot range be [-rng,rng] for both x and y.'
	  print,'   CIRCLES = r Array of radii of optional circles (def=none).'
	  print,'   CCOLOR = cclr Circles color (def=!p.color).'
	  print,'   PSYM = psym Plot symbol (def=!p.psym).'
	  print,'   SYMSIZ = ssz Symbol size (def=!p.symsize).'
	  print,'   SYMCOLOR = sclr Symbol color (def=clr).'
	  print,'   /OVER means do an overplot.'
	  print,'   /NOAXES means do not plot x and y axes.'
	  print,' Note: Any plot keywords may be given.'
	  return
	endif
 
	;-----------------------------------------
	;  Defaults
	;-----------------------------------------
	if n_elements(psym) eq 0 then psym=!p.psym
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(sclr) eq 0 then sclr=clr
	if n_elements(ssz) eq 0 then ssz=!p.symsize
	if n_elements(cclr) eq 0 then cclr=!p.color
 
	;-----------------------------------------
	;  Start plot
	;-----------------------------------------
	x = [float(z)]
	y = [imaginary(z)]
	if not keyword_set(over) then begin
	  if n_elements(rng) gt 0 then begin
	    plot,x,y,/nodata,color=clr,xran=[-rng,rng],yran=[-rng,rng], $
	      _extra=extra
	  endif else begin
	    plot,x,y,/nodata,color=clr,_extra=extra
	  endelse
	endif
 
	;-----------------------------------------
	;  Plot data
	;-----------------------------------------
	oplot,x,y,psym=psym, symsize=ssz, color=sclr
 
	;-----------------------------------------
	;  Circles
	;-----------------------------------------
	if n_elements(rd) gt 0 then arcs,rd,col=cclr
 
	;-----------------------------------------
	;  Plot axes
	;  _extra used to get plot color.
	;-----------------------------------------
	if not keyword_set(noaxes) then begin
	  hor,0,_extra=extra
	  ver,0,_extra=extra
	endif
 
	end
