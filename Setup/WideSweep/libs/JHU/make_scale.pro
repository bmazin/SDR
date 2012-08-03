;-------------------------------------------------------------
;+
; NAME:
;       MAKE_SCALE
; PURPOSE:
;       Plot circular scales on the laser printer.
; CATEGORY:
; CALLING SEQUENCE:
;       make_scale, file
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         PRINTER = postscript printer number (1=def or 2).
;         /LIST to list control files lines as processed.
;         XOFFSET=xn.  Scale center X shift in norm. coord.
;         YOFFSET=yn.  Scale center Y shift in norm. coord.
;           View page in portrait mode, +x to right, +y up.
;         FACTOR=fact  Scale all radii by given factor (def=1).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Control file format:
;         * in column 1 for comment lines.
;         A = a1, a2
;           Defines start and stop angles (deg) for arcs.
;           Not needed for circles.
;           a1, a2 = arc start & stop angles (deg) CCW from X axis.
;         R = r1, r2, r3, ..., rn
;           Draws arcs or circles of specified radius.
;           r1, r2, ... = list of radii (cm) to plot.
;         TICS = a1, a2, da,r1, r2
;           Draws tic marks.
;           a1, a2, da = tic angle start, stop, step (degrees).
;           r1, r2 = tic start, stop radii.
;         LABELS = L1, L2, dL, r, s, flg
;           Sets up labels to be used on next TICS command.
;           L1, L2, dL = label start, stop, step values.
;           r = label radial position (cm), s = label size.
;           flg = 0: to be read from outside the circle (def),
;                 1: to be read from inside the circle.
;         TEXT = r, a, flag, size, text
;           r = radius of text bottom in cm.
;           a = start angle of text in degrees CCW from X axis.
;           flag = 0 to read CW, 1 to read CCW.
;           size = text size.
;           text = text string to write.
; MODIFICATION HISTORY:
;       R. Sterner. 15 July, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;       R. Sterner, 17 Aug, 1993 --- Added keyword FACTOR=f.
;
; Copyright (C) 1988, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro make_scale, f, help=hlp, list=lst, printer=prntr, $
	  xoffset=xoff, yoffset=yoff, factor=fact
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot circular scales on the laser printer.'
	  print,' make_scale, file'
	  print,'   file = Control file name.'
	  print,' Keywords:'
	  print,'   PRINTER = postscript printer number (1=def or 2).'
	  print,'   /LIST to list control files lines as processed.'
	  print,'   XOFFSET=xn.  Scale center X shift in norm. coord.'
	  print,'   YOFFSET=yn.  Scale center Y shift in norm. coord.'
	  print,'     View page in portrait mode, +x to right, +y up.'
	  print,'   FACTOR=fact  Scale all radii by given factor (def=1).'
	  print,' Notes:'
	  print,'   Control file format:'
	  print,'   * in column 1 for comment lines.'
	  print,'   A = a1, a2'
	  print,'     Defines start and stop angles (deg) for arcs.'
	  print,'     Not needed for circles.'
	  print,'     a1, a2 = arc start & stop angles (deg) CCW from X axis.'
	  print,'   R = r1, r2, r3, ..., rn'
	  print,'     Draws arcs or circles of specified radius.'
	  print,'     r1, r2, ... = list of radii (cm) to plot.'
	  print,'   TICS = a1, a2, da,r1, r2'
	  print,'     Draws tic marks.'
	  print,'     a1, a2, da = tic angle start, stop, step (degrees).'
	  print,'     r1, r2 = tic start, stop radii.'
	  print,'   LABELS = L1, L2, dL, r, s, flg'
	  print,'     Sets up labels to be used on next TICS command.'
	  print,'     L1, L2, dL = label start, stop, step values.'
	  print,'     r = label radial position (cm), s = label size.'
	  print,'     flg = 0: to be read from outside the circle (def),'
	  print,'           1: to be read from inside the circle.'
	  print,'   TEXT = r, a, flag, size, text
	  print,'     r = radius of text bottom in cm.
	  print,'     a = start angle of text in degrees CCW from X axis.
	  print,'     flag = 0 to read CW, 1 to read CCW.
	  print,'     size = text size.
	  print,'     text = text string to write.
	  return
	endif
 
	on_ioerror, err
	get_lun, lun
	openr, lun, f
	on_ioerror, null
 
	num = 0
	if keyword_set(prntr) then num = prntr
	psinit, num, /full
	xsize = 19.08		; Full page x size in cm.
	ysize = 25.34		; Full page y size in cm.
	xoffset = 0.
	yoffset = 0.
	if keyword_set(xoff) then xoffset = xoff*xsize
	if keyword_set(yoff) then yoffset = yoff*ysize
	set_window, -xsize/2.-xoffset, xsize/2.-xoffset, $
	  -ysize/2.-yoffset, ysize/2.-yoffset
	if n_elements(fact) eq 0 then fact = 1.
 
	;-------  Initial values  --------
	a1 = 0.		; Arc start angle.
	a2 = 360.	; Arc stop angle.
	lflg = 0	; No labels defined.
 
	print,' Plotting scale . . .'
	plots, [0,0], [0,0], psym=1	; Mark center.
 
;=========  Loop through control file  ============
loop:	item = nextitem(lun, txt0)	; Get next command from control file.
	item = strupcase(item)
	if keyword_set(lst) then begin
	  print,' Control file line: ', txt0	; List control file lines.
	endif
	if item eq '' then goto, done0	; At end of file?
	txt = repchr(txt0,'=')		; delete =.
	case item of
'A':	begin				; Arc angle limits.
	  if nwrds(txt) lt 3 then begin
	    print,' Error in A command.  Must give 2 values.'
	    print,' A = a1, a2'
	    print,' Processing aborted.'
	    return
	  endif
	  a1 = getwrd(txt,1) + 0	; Arc start angle.
	  a2 = getwrd(txt,2) + 0	; Arc stop angle.
	  if a2 le a1 then begin
	    print,' Error in angles: a1, a2 = ', a1, a2
	    print,'   a1 must be less then a2.  Processing aborted.''
	    return
	  endif
	  print,'   Scale start and stop angles set to ',a1, a2
	end
'R':	begin
	  print,'   Drawing arcs or circles.'
	  for i = 1, nwrds(txt)-1 do begin
	    r = getwrd(txt, i)*fact
	    arcs, r, a1, a2
	  endfor
	end
'LABELS': begin
	  if nwrds(txt) lt 5 then begin
	    print,' Error in LABELS command.  Must give at least 4 values.'
	    print,' LABELS = l1, l2, dl, rl, sz'
	    print,' Processing aborted.'
	    return
	  endif
	  print,'   Setting up labels.'
	  l1 = getwrd(txt,1) + 0.	; First label value.
	  l2 = getwrd(txt,2) + 0.	; Last label value.
	  dl = getwrd(txt,3) + 0.	; Label step size.'
	  rl = getwrd(txt,4)*fact	; Label position radius.
	  sz = 1.			; Default size.
	  t = getwrd(txt,5)		; Try to get size.
	  if t ne '' then sz = t+0.	; Got size.
	  sz = sz*fact
	  lrv = 0			; Set for normal labels.
	  t = getwrd(txt,6)		; Try to get reverse flag.
	  if t ne '' then lrv = t+0	; Got reverse flag.
	  t = makei(l1, l2, dl)		; Labels must be integers.
	  nt = n_elements(t)		; Number of labels
	  lb = strarr(nt)		; Setup array for labels.
	  for i = 0, nt-1 do lb(i)=strtrim(t(i),2)	; Make labels.
	  lflg = 1			; Set label flag.
	end
'TICS':	begin
	  if nwrds(txt) lt 6 then begin
	    print,' Error in TICS command.  Must give 5 values.'
	    print,' TICS = a1, a2, da, r1, r2'
	    print,' Processing aborted.'
	    return
	  endif
	  print,'   Plotting tic marks.'
	  ta1 = getwrd(txt,1) + 0.	; Tics start angle.
	  ta2 = getwrd(txt,2) + 0.	; Tics stop angle.
	  dta = getwrd(txt,3) + 0.	; Tics angle step.
	  tr1 = getwrd(txt,4)*fact	; Tics start radius.
	  tr2 = getwrd(txt,5)*fact	; Tics stop radius.
	  if lflg eq 1 then begin
	    rtics, ta1, ta2, dta, tr1, tr2, rl, lb, sz, lrv
	    lflg = 0
	  endif else begin
	    rtics, ta1, ta2, dta, tr1, tr2
	  endelse
	end
'TEXT':	begin
	  if nwrds(txt) lt 6 then begin
	    print,'  Error in TEXT command. Must give at 5 values.'
	    print,'  TEXT = r, a, flag, size, text
	    print,'  Processing aborted.'
	    return
	  endif
	  print,'   Writing text.'
	  r = getwrd(txt,1)*fact
	  a = getwrd(txt,2) + 0.
	  flag = getwrd(txt,3) + 0
	  sz = getwrd(txt, 4)*fact
	  text = getwrd(txt0, 6, location=ll)
	  text = strmid(txt0, ll, 99)
	  raout, r, a, text, flag, size=sz, color=0
	end
ELSE:	begin
	  print,' Unknown command in control file: ' + ITEM
	end
	endcase
 
	goto, loop
 
done0:	psterm
	print,' Processing complete.'
 
done:	close, lun
	free_lun, lun
	return
 
err:	print,' Could not open file ' + F
	goto, done
 
	end
