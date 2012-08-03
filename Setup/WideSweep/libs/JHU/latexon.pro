;-------------------------------------------------------------
;+
; NAME:
;       LATEXON
; PURPOSE:
;       Generate encapsulated postscript file to include in LaTeX documents.
; CATEGORY:
; CALLING SEQUENCE:
;       latexon, file
; INPUTS:
;       file = output postscript file (use *.ps).   in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       latex_com
; NOTES:
;       Notes: See also latexoff, which terminates the postscript
;         output and closes the file.
;         To create the postscript file:
;         (1) Do plot on screen.
;         (2) latexon,"outfile.ps"
;         (3) Repeat same plot.
;         (4) latexoff.  Note plot shape.
;         To use the resulting file in a LaTeX document:
;         (1) Include at the front of the LaTeX document the file
;             IDL_DIR:[LIB]IDLPLT_DVIPS.TEX, which defines the insertplot macro.
;         (2) In your LaTeX document use
;             \insertplot{file}{caption}{label}{width}{height}
;               file = name of file containing the PostScript.
;               caption = caption of figure
;               label = latex \label{} for figure to be used by \ref{} macro
;               width = width of figure in inches.      |  Best to use shape
;               height = height of figure, in inches.   |  given by latexoff.
;              or \insertimg (same arguments. Use output shape same as image shape).
;         (3) LATEXPS the LaTeX document.
; MODIFICATION HISTORY:
;       R. Sterner, 14 Sep 1990
;       R. Sterner, 11 Oct 1990 --- added plot shape.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro latexon, file0, help=hlp
 
	common latex_com, file, dname, x, y, p, s1
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Generate encapsulated postscript file to include'+$
	    ' in LaTeX documents.'
	  print,' latexon, file'
	  print,'   file = output postscript file (use *.ps).   in'
	  print,' Notes: See also latexoff, which terminates the postscript'
	  print,'   output and closes the file.'
	  print,'   To create the postscript file:'
	  print,'   (1) Do plot on screen.'
	  print,'   (2) latexon,"outfile.ps"'
	  print,'   (3) Repeat same plot.'
	  print,'   (4) latexoff.  Note plot shape.'
	  print,'   To use the resulting file in a LaTeX document:'
	  print,'   (1) Include at the front of the LaTeX document the file'
	  print,'       IDL_DIR:[LIB]IDLPLT_DVIPS.TEX, which defines the'+$
	    ' insertplot macro.'
	  print,'   (2) In your LaTeX document use
	  print,'       \insertplot{file}{caption}{label}{width}{height}
	  print,'         file = name of file containing the PostScript.
	  print,'         caption = caption of figure
	  print,'         label = latex \label{} for figure to be used by '+$
	    '\ref{} macro.
	  print,'         width = width of figure in inches.      '+$
	    '|  Best to use shape'
	  print,'         height = height of figure, in inches.   '+$
	    '|  given by latexoff.'
	  print,'        or \insertimg (same arguments. Use output shape '+$
	    'same as image shape).'
	  print,'   (3) LATEXPS the LaTeX document.'
	  return
	endif
 
	;------  Get current plot shape  ---------
	if (!x.window(0) eq 0.) and (!x.window(1) eq 0.) then begin
	  print,' Warning in latexon: you really should do a screen plot'
	  print,'   with the same plot command to set the plot window before'
	  print,'   calling latexon.'
	  print,'   The current plot shape will be assumed to be 1.24336.'
	  s1 = 1.24336
	endif else begin
	  dx1 = !d.x_size*(!x.window(1) - !x.window(0))/!d.x_px_cm
	  dy1 = !d.y_size*(!y.window(1) - !y.window(0))/!d.y_px_cm
	  s1 = dx1/dy1
	endelse
 
	;------  Save current graphics  ----------
	dname = !d.name
	x = !x
	y = !y
	p = !p
 
	;---  Redirect graphics to and encapsulated postscript file  ----
	file = file0
	set_plot, 'ps'
	device, /encap, file=file
	print,' '
	print,' All graphics and images redirected to the encapsulated'+$
	  ' PS file '+file
	print,' '
 
	return
	end
