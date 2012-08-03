;-------------------------------------------------------------
;+
; NAME:
;       PSINIT
; PURPOSE:
;       Redirect plots and images to postscript printer.
; CATEGORY:
; CALLING SEQUENCE:
;       psinit [,num]
; INPUTS:
;       num = Postscript printer number.           in
;         This may alternately be any unique string in the
;         printer description displayed using /LIST.
; KEYWORD PARAMETERS:
;       Keywords:
;         /FULL to use full page in portrait mode (def=top half).
;         /LANDSCAPE to do plot in landscape mode.
;         /COLOR means do color PostScript (def is B&W).
;         /AUTOCOLOR means automatically set color mode for a
;           color PS printer.  Must have the word color in the
;           printer description line.
;         CFLAG=flag  Returned color flag: 0=B&W, 1=Color mode.
;         FILE=f redirect plot to a specified file.  The default
;           is idl.ps in the local directory.
;         DEFAULT=dn  Set default printer number (def=0).
;           Stays in effect for IDL session.
;         MARGIN = [left, right, bottom, top] sets margins (inches).
;           May give as few values as needed.  For left margin only
;           may just use MAR=xxx, otherwise give an array.
;         WINDOW = [xmin, xmx, ymin, ymx] sets window (inches).
;           Must give all 4 values.
;         /CENTIMETERS  interpreted margin or window values in cm.
;         /DOUBLE to do plot in double thickness.
;         /VECTOR to use vector fonts instead of postscript fonts.
;         /ORIGIN plots a mark at the page origin.
;         /QUIET turns off psinit messages.
;         /LIST_PRINTERS lists available printers and their numbers.
;         COMMENT=txt  comment to print with the time stamp.
;         CHARSIZE=csz Character size for comment (def=0.4).
; OUTPUTS:
; COMMON BLOCKS:
;       ps_com,dname,xthick,ythick,pthick,pfont,defnum,num,comm
; NOTES:
;       Notes:
;         Default is portrait mode, top half of page.
;         Related routines:
;         psterm - terminate postscript output and make plots.
;         pspaper - plot norm. coord. system for curr. page setup.
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;       R. Sterner, 22 May, 1990 --- converted to VMS.
;       R. Sterner, 12 Oct, 1990 --- WINDOW keyword.
;       R. Sterner, 20 Dec, 1990 --- added COMMENT keyword.
;       R. Sterner,  6 Dec, 1991 --- added FILE= keyword.
;       R. Sterner, 1995 May 3 --- Added /COLOR.
;       R. Sterner, 1995 May 4 --- Added /AUTOCOLOR.
;       R. Sterner, 1998 Jun 4 --- Added CHARSIZE.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro psinit, pnum, landscape=v, double=dbl, full=fl, help=hlp, $
	            vector=d3, origin=ori, margin=mar, centimeters=cm, $
		    quiet=qt, list_printers=list, window=window, $
	            comment=comment, file=outfile, default=dnum, $
		    color=color, autocolor=auto, cflag=cflag,charsize=csz
 
	common ps_com,dname,xthick,ythick,pthick,pfont,defnum,num,comm, $
	  pfile, csz0
 
	if keyword_set(hlp) then begin
	  print,' Redirect plots and images to postscript printer.'
	  print,' psinit [,num]
	  print,'   num = Postscript printer number.           in'
	  print,'     This may alternately be any unique string in the'
	  print,'     printer description displayed using /LIST.'
	  print,' Keywords:'
 	  print,'   /FULL to use full page in portrait mode (def=top half).'
	  print,'   /LANDSCAPE to do plot in landscape mode.'
	  print,'   /COLOR means do color PostScript (def is B&W).'
	  print,'   /AUTOCOLOR means automatically set color mode for a'
	  print,'     color PS printer.  Must have the word color in the'
	  print,'     printer description line.'
	  print,'   CFLAG=flag  Returned color flag: 0=B&W, 1=Color mode.'
	  print,'   FILE=f redirect plot to a specified file.  The default'
	  print,'     is idl.ps in the local directory.'
	  print,'   DEFAULT=dn  Set default printer number (def=0).'
	  print,'     Stays in effect for IDL session.'
	  print,'   MARGIN = [left, right, bottom, top] sets margins (inches).'
	  print,'     May give as few values as needed.  For left margin only'
	  print,'     may just use MAR=xxx, otherwise give an array.'
	  print,'   WINDOW = [xmin, xmx, ymin, ymx] sets window (inches).'
	  print,'     Must give all 4 values.'
	  print,'   /CENTIMETERS  interpreted margin or window values in cm.'
	  print,'   /DOUBLE to do plot in double thickness.'
 	  print,'   /VECTOR to use vector fonts instead of postscript fonts.'
 	  print,'   /ORIGIN plots a mark at the page origin.'
 	  print,'   /QUIET turns off psinit messages.'
	  print,'   /LIST_PRINTERS lists available printers and their numbers.'
	  print,'   COMMENT=txt  comment to print with the time stamp.'
	  print,'   CHARSIZE=csz Character size for comment (def=0.4).'
	  print,' Notes:'
	  print,'   Default is portrait mode, top half of page.'
	  print,'   Related routines:'
	  print,'   psterm - terminate postscript output and make plots.'
	  print,'   pspaper - plot norm. coord. system for curr. page setup.'
	  return
	endif	
 
	getsysnams, 'IDL_PSPRINTERS', npr, cmds, plist	; Get printers.
 
	qflg = not keyword_set(qt)
 
	if n_elements(csz) ne 0 then csz0=csz else csz0=0.4
 
	if n_elements(dnum) ne 0 then begin
	  if (dnum lt 0) or (dnum ge n_elements(plist)) then begin
	    print,' '
	    print,'     Printer number out of range.'
	    print,' '
	    print,'     Available Postscript printers:'
	    print,' '
	    for i = 0, n_elements(plist)-1 do begin
	      txt = ''
	      if i eq 0 then txt=' <-- Default'
	      print,' '+strtrim(i,2)+'.  '+plist(i)+txt
	    endfor
	    print,' '
	    return
	  endif else begin
	    defnum = dnum
	    if qflg then begin
	      print,' Default printer is now: '
	      print,' '+plist(defnum)
	    endif
	  endelse
	  return
	endif
 
	if n_elements(defnum) eq 0 then defnum = 0
 
	if keyword_set(list) then begin
	  print,' '
	  print,'     Available Postscript printers:'
	  print,' '
	  for i = 0, n_elements(plist)-1 do begin
	    txt = ''
	    if i eq defnum then txt=' <-- Default'
	    print,' '+strtrim(i,2)+'.  '+plist(i)+txt
	  endfor
	  print,' '
	  return
	endif
 
	if n_elements(comm) eq 0 then comm = ''
	if n_elements(comment) ne 0 then comm = comment
 
	;-------  Printer number  ----------
	if n_elements(pnum) eq 0 then pnum = defnum
	;-------  Decode printer tag if a string  ---------
	sz = size(pnum)
	typ = sz(sz(0)+1)
	if typ eq 7 then begin
	  p = strpos(strupcase(plist),strupcase(pnum))
	  w = where(p ge 0, cnt)
	  if cnt eq 0 then begin
	    print,' Error in psinit: given printer tag unknown.'
	    print,'   Given tag was: '+pnum
;	    return
	    print,' Using default printer'
	    w(0) = defnum
	  endif
	  if cnt gt 1 then begin
	    print,' Warning in psinit: given printer tag not unique.'
	    print,'   Given tag was: '+pnum
	    print,'   Using first match = printer '+strtrim(w(0),2)
	  endif
	  pnum = w(0)
	endif
	;------  Check printer number range  ---------
	if (pnum lt 0) or (pnum ge npr) then begin
	  print,' Error in psinit: printer number out of range.  '+$
	    'must be 0 to '+strtrim(npr-1,2)
	  return
	endif
	num = pnum
 
	dname = !d.name		; Save current setup.
	xthick = !x.thick
	ythick = !y.thick
	pthick = !p.thick
	pfont = !p.font
 
 
	;--------------  Enter PS mode  -------------------
	set_plot, 'ps'
	if qflg then print,' All plots are now redirected to the '+$
	  'postscript printer number ' + strtrim(num,2) + '.'
	if qflg then print,'   = ' + plist(num)
	if qflg then print,' To output plots and reset to screen do PSTERM.'
 
	;--------------  Handle optional filename  --------
	if n_elements(outfile) eq 0 then outfile = ''	; Use default = idl.ps.
	if outfile ne '' then begin			; Use given file.
	  device, filename=outfile			; Direct plots to file.
	  if qflg then print,' Output file is '+outfile
	endif
	pfile = outfile					; Save file name.
 
 
	;------  Set plot area using Window mode or Margin mode (def)  ------
	;-----  MARGIN MODE  ----------
	if n_elements(window) eq 0 then begin	; No WINDOW, assume MARGIN.
	  ;-----  Get margin values ready to use  ------
	  if n_elements(mar) eq 0 then mar=[0,0,0,0]	; opt. page margins.
	  if keyword_set(cm) then mar = mar/2.54	; Want margins in cm.
	  mar = [mar,0,0,0]				; Any # of values.
	  ;--- dx1,dy1 = offsets from origin.  dx2,dy2=total margins  -------
	  dx1 = mar(0) & dx2 = dx1+mar(1) & dy1 = mar(2) & dy2 = dy1+mar(3)
	  ;----  landscape mode  --------
	  if keyword_set(v) then begin		; Handle landscape mode.
	    device, /landscape, /inches, xoffset=.75+dy1, yoffset=10.25-dx1, $
	      xsize=9.5-dx2, ysize=7.0-dy2
	    if qflg then print,' Landscape mode.'
	  ;--- portrait mode  -------
	  endif else begin			; Portrait mode.
	  ;----  Default = top half portrait mode  ------
	    device, /portrait, /inches, xoffset=0.5+dx1, yoffset=5.25+dy1, $
	      xsize=7.5-dx2, ysize=5.25-dy2
	    if keyword_set(fl) then begin		; Handle top.
	  ;----  Full page portrait mode  -------
	      device, /portrait, /inches, xoffset=0.5+dx1, yoffset=0.5+dy1, $
	        xsize=7.5-dx2, ysize=10.-dy2
	      if qflg then print,' Portrait mode, full page.'
	    endif else if qflg then print,' Portrait mode, top half page.'
	  endelse
	;-------  WINDOW MODE  ---------
	endif else begin
	  ;-----  Get window values ready to use  ------
	  if n_elements(window) lt 4 then begin
	    print,' Error in psinit: If WINDOW keyword used it must have 4 '+$
	      'values.'
	    return
	  endif
	  if qflg then print,' Setting plot window.'
	  if keyword_set(cm) then window = window/2.54	  	; in cm.
	  ;--- dx1,dy1 = offsets from origin.  dx2,dy2=total margins  -------
	  dx1 = window(0) & dx2 = window(1)-dx1
	  dy1 = window(2) & dy2 = window(3)-dy1
	  ;----  landscape mode  --------
	  if keyword_set(v) then begin		; Handle landscape mode.
	    device, /landscape, /inches, xoffset=.75+dy1, yoffset=10.25-dx1, $
	      xsize=dx2, ysize=dy2
	    if qflg then print,' Landscape mode.'
	  ;--- portrait mode  -------
	  endif else begin			; Portrait mode.
	  ;----  Default = top half portrait mode  ------
	    device, /portrait, /inches, xoffset=0.5+dx1, yoffset=5.25+dy1, $
	      xsize=dx2, ysize=dy2
	    if keyword_set(fl) then begin		; Handle top.
	  ;----  Full page portrait mode  -------
	      device, /portrait, /inches, xoffset=0.5+dx1, yoffset=0.5+dy1, $
	        xsize=dx2, ysize=dy2
	      if qflg then print,' Portrait mode, full page.'
	    endif else if qflg then print,' Portrait mode, top half page.'
	  endelse
	endelse  ; End of set plot area
	;--------------------------------------------------------------------
 
 
	device, bits_per_pixel = 5	; Def 32 gray levels (max ALW).
	!p.font = 0
	device, /times			; Default font is times.
 
	if keyword_set(dbl) then begin		; Handle double thickness.
	  !x.thick = 2
	  !y.thick = 2
	  !p.thick = 2
	  device, /bold
	  if qflg then print,' Double thickness mode.'
	endif
 
	if keyword_set(d3) then begin
	  !p.font = -1
	  if qflg then print,' Using vector font.'
	endif
 
	if keyword_set(ori) then begin
	  if qflg then print,' Marking origin.'
	  plots, [0,0], [0,0], /normal, psym=1
	endif 
 
	cflag = 0		; Assume B&W mode.
 
	if keyword_set(color) then begin
	  device, /color
	  if qflg then print,' Color PostScript mode.'
	  cflag = 1		; Color mode flag.
	endif
 
	if keyword_set(auto) then begin
	  if strpos(strupcase(plist(pnum)),'COLOR') ge 0 then begin
	    device, /color
	    if qflg then print,' Color PostScript mode.'
	    cflag = 1		; Color mode flag.
	  endif
	endif
 
	return
	end
