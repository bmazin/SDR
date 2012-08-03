;-------------------------------------------------------------
;+
; NAME:
;       CHINIT
; PURPOSE:
;       Initializes chart setup.  Good for viewgraphs.
; CATEGORY:
; CALLING SEQUENCE:
;       chinit
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /HARD means plot on postscript printer (else screen).
;         /LAND means use landscape mode (else portrait mode).
;         UNITS=u  Set plot units to 'inches' (def) or 'cm'.
;         BPOSITION=p scalar or array giving list of outline
;           offsets in UNITS from edge of page. Def=no outline.
;         BTHICKNESS=t scalar or array giving outline thicknesses
;           for each outline given in BPOS.  Def=1.
;         XOFFSET=xoff  Set chart X offset in UNITS (def=0).
;         YOFFSET=yoff  Set chart Y offset in UNITS (def=0).
;         /MOVE means just move origin.  The only other keywords
;           recognized with /MOVE are XOFFSET and YOFFSET.
;           /MOVE should be used on the second and later calls to
;           CHINIT to reposition the position of graphics.
;         WINSIZE=sz Multiply default screen window size by this factor.
;        Output keywords:
;         LAST=lst Highest available plot color, returned.
;         FONT=f "!17" for screen, null string for /HARD.
;           Put in front of first string printed to make
;           device independent.
;         FACTOR=f text size factor. 1 for /HARD, 0.68 for screen.
;           Multiply text size by this for device independence.
;         Any extra PSINIT keywords may be passed in.
; OUTPUTS:
; COMMON BLOCKS:
;       chinit_com
; NOTES:
;       Notes: Also erases to white and sets default plot
;         color to black.  All plot commands may then be
;         given in units of inches or cm, whichever were set.
;         Plot size:
;           Portrait:  7.5 by 10 inches (360 by 480 on screen)
;           Landscape: 9.5 by  7 inches (640 by 472 on screen)
;         The screen view is not always close to the hard copy.
;         Spaces are handled differently, and strings that fit
;         for the hardcopy are sometimes too long on the screen.
; MODIFICATION HISTORY:
;       R. Sterner, 17 Aug, 1991
;       R. Sterner,  9 Jan, 1992 --- added /MOVE, also common.
;       R. Sterner,  1 Sep, 1992 --- added WINSIZE
;       R. Sterner, 2005 Feb 16 --- Added _EXTRA=extra to pass color to psinit.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
        pro chinit, units=units, xoffset=xoff, yoffset=yoff, help=hlp, $
          hard=hard, last=lst, bposition=bpos, bthickness=bth, $
	  landscape=land, font=font, factor=factor, move=move, $
	  winsize=winsize, _extra=extra
 
	common chinit_com, xmn0, xmx0, ymn0, ymx0, lst0
 
        if keyword_set(hlp) then begin
          print,' Initializes chart setup.  Good for viewgraphs.'
          print,' chinit'
          print,'   All args are keywords.'
          print,' Keywords:'
          print,'   /HARD means plot on postscript printer (else screen).'
	  print,'   /LAND means use landscape mode (else portrait mode).'
          print,"   UNITS=u  Set plot units to 'inches' (def) or 'cm'."
	  print,'   BPOSITION=p scalar or array giving list of outline'
	  print,'     offsets in UNITS from edge of page. Def=no outline.'
	  print,'   BTHICKNESS=t scalar or array giving outline thicknesses'
	  print,'     for each outline given in BPOS.  Def=1.'
          print,'   XOFFSET=xoff  Set chart X offset in UNITS (def=0).'
          print,'   YOFFSET=yoff  Set chart Y offset in UNITS (def=0).'
	  print,'   /MOVE means just move origin.  The only other keywords'
	  print,'     recognized with /MOVE are XOFFSET and YOFFSET.'
	  print,'     /MOVE should be used on the second and later calls to'
	  print,'     CHINIT to reposition the position of graphics.'
	  print,'   WINSIZE=sz Multiply default screen window size by this factor.'
	  print,'  Output keywords:'
          print,'   LAST=lst Highest available plot color, returned.'
	  print,'   FONT=f "!17" for screen, null string for /HARD.'
	  print,'     Put in front of first string printed to make'
	  print,'     device independent.'
	  print,'   FACTOR=f text size factor. 1 for /HARD, 0.68 for screen.'
	  print,'     Multiply text size by this for device independence.'
	  print,'   Any extra PSINIT keywords may be passed in.'
          print,' Notes: Also erases to white and sets default plot'
          print,'   color to black.  All plot commands may then be'
          print,'   given in units of inches or cm, whichever were set.'
	  print,'   Plot size:'
	  print,'     Portrait:  7.5 by 10 inches (360 by 480 on screen)'
	  print,'     Landscape: 9.5 by  7 inches (640 by 472 on screen)'
	  print,'   The screen view is not always close to the hard copy.'
	  print,'   Spaces are handled differently, and strings that fit'
	  print,'   for the hardcopy are sometimes too long on the screen.'
          return
        endif
 
        if n_elements(xoff) eq 0 then xoff = 0.
        if n_elements(yoff) eq 0 then yoff = 0.
	if keyword_set(move) then goto, skip
        if n_elements(units) eq 0 then units = 'inches'
	if n_elements(land) eq 0 then land = 0
        if n_elements(hard) eq 0 then hard=0
	if n_elements(winsize) eq 0 then winsize = 1.0
 
        ;-----------  Hardcopy?  ----------
	font = '!17'
	factor = 0.68*winsize
	; factor = 0.55
	if keyword_set(hard) then begin
	  font = ''
	  factor = 1.
          if land eq 1 then psinit, /land, vector=vector, _extra=extra
          if land eq 0 then psinit, /full, vector=vector, _extra=extra
	endif
 
        ;-----------  set scaling  --------
        xmn0 = 0.				; First assume PS.
        ymn0 = 0.
        xmx0 = !d.x_vsize/!d.x_px_cm
        ymx0 = !d.y_vsize/!d.y_px_cm
	if not keyword_set(hard) then begin	; Was really screen.
	  if keyword_set(land) then begin
	    xmx0 = 9.5*2.54
	    ymx0 = 7.*2.54
	    xs = 640*winsize
	    ys = 472*winsize
	    if (xs gt 1150) or (ys gt 900) then $
	      swindow,xsize=xs, ysize=ys,x_scr=1150<xs,y_scr=900<ys else $
	      window, 1, xsize=xs, ysize=ys
	  endif else begin
	    xmx0 = 7.5*2.54
	    ymx0 = 10.*2.54
	    xs = 360*winsize
	    ys = 480*winsize
	    if (xs gt 1150) or (ys gt 900) then $
              swindow,xsize=xs, ysize=ys,x_scr=1150<xs,y_scr=900<ys else $
	      window, 1, xsize=xs, ysize=ys
	  endelse
	endif
        if strupcase(units) eq 'INCHES' then begin
          xmx0 = xmx0/2.54
          ymx0 = ymx0/2.54
        endif
 
        ;--------  Set color  --------
        loadct, 0
        lst = !d.table_size-1
	lst0 = lst
;        erase, lst
        erase, tarclr(255,255,255)
        !p.color = 0
        !p.background = 255
 
	;------  Do offset from origin  ----------
skip:   xmn = xmn0 - xoff
        xmx = xmx0 - xoff
        ymn = ymn0 - yoff
        ymx = ymx0 - yoff
        plot, [0],[0],xrange=[xmn,xmx],yrange=[ymn,ymx],xstyle=5,ystyle=5,$
          /nodata, position=[0,0,1,1], /noerase, color=lst0
	if keyword_set(move) then return
 
	;--------  Handle border outline(s)  --------
	nb = n_elements(bpos)		; Want border outline?
	if nb eq 0 then return
	if not keyword_set(land) then begin  ; Portrait mode.
	  outx = [0,7.5,7.5,0,0]
	  outy = [0,0,10,10,0]
	endif else begin		     ; Landscape mode.
	  outx = [0,9.5,9.5,0,0]
	  outy = [0,0,7.,7.,0]
	endelse
	if strupcase(units) ne 'INCHES' then begin	; Want cm.
	  outx = outx*2.54
	  outy = outy*2.54
	endif
	if n_elements(bth) eq 0 then bth = [1]	; Make sure thickness exists.
	lstt = n_elements(bth)-1
	for i = 0, nb-1 do begin
	  bp = bpos(i)
	  bt = bth(i<lstt)
	  if not keyword_set(hard) then bt = (bt/3.)>1.
	  plots,outx+[1,-1,-1,1,1]*bp,outy+[1,1,-1,-1,1]*bp,thick=bt
	endfor
 
        return
        end
