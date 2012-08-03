;-------------------------------------------------------------
;+
; NAME:
;       EPSINIT
; PURPOSE:
;       Redirect plots and images to Encapsulated Postscript File.
; CATEGORY:
; CALLING SEQUENCE:
;       epsinit, outfile
; INPUTS:
;       outfile = EPS file name (def=idl.eps).          in
; KEYWORD PARAMETERS:
;       Keywords:
;         XSIZE=xsz  Plot size in X (def=8).
;         YSIZE=xsz  Plot size in Y (def=5.5).
;         /CM    Means size units are cm (else inches).
;         /COLOR means do color PostScript (def is B&W).
;           For true color images do loadct,0 after calling epsinit.
;         /VECTOR to use vector fonts instead of postscript fonts.
;         /QUIET turns off epsinit messages.
; OUTPUTS:
; COMMON BLOCKS:
;       eps_com,xsv,ysv,psv,dsv,ou
; NOTES:
;       Notes: 8 bit gray scale or color is set.  Times Roman
;         font is used.  To over-ride just use a call to device
;         after epsinit to set desired values.
;         Also sets default axes and plot thicknesses and charsize,
;         and loads a color table with a wide range of colors.
;         Plot colors may be selected using the tarclr function.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Aug 2
;       R. Sterner, 2004 May 27 --- Set some useful values. Default size 8"x6".
;       R. Sterner, 2004 May 28 --- load_colors only for /color.
;       R. Sterner, 2004 Jun 01 --- Minor default size change.
;       R. Sterner, 2004 Jun 02 --- Added loadct, 0 to help text.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro epsinit, outfile, help=hlp, $
	            vector=vect, centimeters=cm, $
		    quiet=qt, color=color, xsize=xsize, ysize=ysize
 
	common eps_com,xsv,ysv,psv,dsv,out
 
	if keyword_set(hlp) then begin
	  print,' Redirect plots and images to Encapsulated Postscript File.'
	  print,' epsinit, outfile' 
	  print,'   outfile = EPS file name (def=idl.eps).          in'
	  print,' Keywords:'
	  print,'   XSIZE=xsz  Plot size in X (def=8).'
	  print,'   YSIZE=xsz  Plot size in Y (def=5.5).'
	  print,'   /CM    Means size units are cm (else inches).'
	  print,'   /COLOR means do color PostScript (def is B&W).'
	  print,'     For true color images do loadct,0 after calling epsinit.'
 	  print,'   /VECTOR to use vector fonts instead of postscript fonts.'
 	  print,'   /QUIET turns off epsinit messages.'
	  print,' Notes: 8 bit gray scale or color is set.  Times Roman'
	  print,'   font is used.  To over-ride just use a call to device'
	  print,'   after epsinit to set desired values.'
	  print,'   Also sets default axes and plot thicknesses and charsize,'
	  print,'   and loads a color table with a wide range of colors.'
	  print,'   Plot colors may be selected using the tarclr function.'
	  return
	endif	
 
	;------  Set defaults  ------------
	qflg = not keyword_set(qt)
 	if n_elements(outfile) eq 0 then outfile='idl.eps'
	out = outfile
	if n_elements(xsize) eq 0 then xsize=8
	if n_elements(ysize) eq 0 then ysize=5.5
	if n_elements(cm) eq 0 then cm=0
	inches=1-cm
	
	;--------  Save entry state  ----------
	xsv=!x & ysv=!y & psv=!p & dsv=!d
 
	;--------------  Enter PS mode  -------------------
	set_plot, 'ps'
	device,file=outfile
	;-------  Set plot size  -------------
	device, xsize=xsize, ysize=ysize, inches=inches 
 
	if qflg then print,' All plots are now redirected to the '+$
	  'EPS file ' + outfile
	if qflg then print,' To terminate EPS and reset to screen do epsterm.'
 
 
	device, bits_per_pixel = 8	; Def 256 gray levels.
	!p.font = 0
	device, /times			; Default font is times.
 
	if keyword_set(vect) then begin
	  !p.font = -1
	  if qflg then print,' Using vector font.'
	endif
 
	if keyword_set(color) then begin
	  device, /color
	  if qflg then print,' Color PostScript mode.'
	  load_colors			; Load a color table with colors.
	endif
 
	;-------  Set some useful defaults  ----------
	!x.thick = 2
	!y.thick = 2
	!p.charsize = 1.5
	!p.thick = 3
 
	return
	end
