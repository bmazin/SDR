;-------------------------------------------------------------
;+
; NAME:
;       MAPCIRCI
; PURPOSE:
;       Interactive circle on a map.  Select and list points.
; CATEGORY:
; CALLING SEQUENCE:
;       mapcirci, x, y, r
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         UNITS=units  Units of radius (def=km).
;           'km'      Default.
;           'miles'   Statute miles.
;           'nmiles'  Nautical miles.
;           'feet'    Feet.
;           'yards'   Yards.
;           'degrees' Degrees (great circle).
;           'radians' Radians (great circle).
;         PLNG, PLAT = optional arrays of point positions.
;         PTXT = text array for points.
;         SORT=sval Optional array to sort on (def=dist from center).
;         LINES=n  Number of lines to display at one time (def=10).
;         MAXLINES=m  Total number of lines with scrolling (def=all).
;         COLOR=clr  Plot color (def=255, not very useful for XOR).
; OUTPUTS:
;       x,y = circle center long, lat.       in, out
;       r = circle radius.                   in, out
; COMMON BLOCKS:
; NOTES:
;       Notes: if PLNG, PLAT, PTXT given then text from PTXT is
;         displayed in a text widget for points inside circle
;          when left mouse button clicked.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Mar 22
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro mapcirci_units, units, cf, utxt=utxt
 
        ;---------  Deal with units  ---------------
        if n_elements(units) eq 0 then units='kms'
        un = strlowcase(strmid(units,0,2))
        case un of      ; Convert distance on earth's surface to radians.
'km':   begin
          cf = 1.56956e-04      ; Km/radian.
          utxt = 'km'
        end
'mi':   begin
          cf = 2.52595e-04      ; Miles/radian.
          utxt = 'miles'
        end
'nm':   begin
          cf = 2.90682e-04      ; Nautical mile/radian.
          utxt = 'nautical miles'
        end
'fe':   begin
          cf = 4.78401e-08      ; Feet/radian.
          utxt = 'feet'
        end
'ya':   begin
          cf = 1.43520e-07      ; Yards/radian.
          utxt = 'yards'
        end
'de':   begin
          cf = 0.0174532925     ; Degrees/radian.
          utxt = 'degrees'
        end
'ra':   begin
          cf = 1.0              ; Radians/radian.
          utxt = 'radians'
        end
else:   begin
          print,' Error in mapcirci: Unknown units: '+units
          print,'   Aborting.'
	  cf = 0.
          return
        end
        endcase
 
	return
	end
 
 
;=============================================================
;	mapcirci.pro = Interactive circle on a map.
;	R. Sterner, 1996 Mar 22.
;=============================================================
 
	pro mapcirci, x, y, r, units=units, plng=plng, plat=plat, $
	  ptxt=ptxt, color=clr, lines=lines, maxlines=maxlines, $
	  sort=sval, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Interactive circle on a map.  Select and list points.'
	  print,' mapcirci, x, y, r'
	  print,'   x,y = circle center long, lat.       in, out'
	  print,'   r = circle radius.                   in, out'
	  print,' Keywords:'
	  print,'   UNITS=units  Units of radius (def=km).'
          print,"     'km'      Default."
          print,"     'miles'   Statute miles."
          print,"     'nmiles'  Nautical miles."
          print,"     'feet'    Feet."
          print,"     'yards'   Yards."
          print,"     'degrees' Degrees (great circle)."
          print,"     'radians' Radians (great circle)."
	  print,'   PLNG, PLAT = optional arrays of point positions.'
	  print,'   PTXT = text array for points.'
	  print,'   SORT=sval Optional array to sort on (def=dist from center).'
	  print,'   LINES=n  Number of lines to display at one time (def=10).'
	  print,'   MAXLINES=m  Total number of lines with scrolling (def=all).'
	  print,'   COLOR=clr  Plot color (def=255, not very useful for XOR).'
	  print,' Notes: if PLNG, PLAT, PTXT given then text from PTXT is'
	  print,'   displayed in a text widget for points inside circle'
 	  print,'    when left mouse button clicked.'
	  return
	endif
 
	;------  Deal with incoming units  -----------
	mapcirci_units, units, cf, utxt=utxt
	if cf eq 0 then return
	rr = r*cf			; Radius in radians.
 
	;---------  Set graphics mode  ------------------
        device, get_graphics=gmode0     ; Entry mode.
        device, set_graphics=6          ; XOR mode.
        todev,x,y,ix,iy
        tvcrs,ix,iy
 
	;---------  Setup text widget  -------------------
	tflag = 1				; Assume text widget.
	n1 = n_elements(plng)
	n2 = n_elements(plat)
	n3 = n_elements(ptxt)
	if max(abs([n1,n2]-n3)) ne 0 then begin
	  print,' Error in mapcirc: PLNG, PLAT, and PTXT must all be'
	  print,' the same size.  Aborting.'
	  bell
	  return
	endif
	if n1 eq 0 then tflag=0		; Don't need text widget.
	if n2 eq 0 then tflag=0
	if n3 eq 0 then tflag=0
	if tflag then begin
	  if n_elements(lines) eq 0 then lines=10	; Lines in display.
	  if n_elements(maxlines) eq 0 then maxlines=n3	; Max Lines.
	  maxlines = maxlines<n3
	  top = widget_base(/column,title='Data for points inside circle')
	  idc = widget_label(top,/dynamic, val='Radius = '+$
	    strtrim(r,2)+' '+utxt)
	  idn = widget_label(top,/dynamic, val='Points inside circle: ')
	  nx = max(strlen(ptxt))
	  ny = n_elements(ptxt)
	  if ny gt lines then begin
	    ny = lines
	    scroll = 1
	  endif else scroll=0
	  id = widget_text(top,xsize=nx,ysize=ny,scroll=scroll)
	  widget_control, top, /real
	endif
 
	;---------  Initialize  -------------------------
	if n_elements(clr) eq 0 then clr=255
	rb2ll,x,y,rr,maken(0,360,181),xx,yy	; Initial circle.
	w = where(xx gt 180, c)			; Put long in range +/-180.
	if c gt 0 then xx(w)=xx(w)-360
	exflag = 0				; Exit flag.
	!mouse.button = 0
 
        ;==========  Main loop  ==========================
	while exflag eq 0 do begin
	  plots, xx, yy, col=clr		; Plot circle.
          repeat begin
             cursor, x, y, 2, /dat     		; Read cursor position.
          endrep until y le 90
	  plots, xx, yy, col=clr		; Erase circle.
	  rb2ll,x,y,rr,maken(0,360,181),xx,yy	; Initial circle.
	  w = where(xx gt 180, c)		; Put long in range +/-180.
	  if c gt 0 then xx(w)=xx(w)-360
	  ;--------  Display points text  -----------------
	  if (!mouse.button eq 1) and tflag then begin
	    ll2rb,x,y,plng,plat,rp,ap		; Distance to each point.
	    w = where(rp le rr, cnt)		; Points in circle.
	    if cnt ne 0 then begin
	      txt=ptxt(w)			; Text for pts in circle.
	      if n_elements(sval) ne 0 then begin
		s = sval(w)			; Sort by sort value.
	      endif else begin
	        s = rp(w)			; Sort by dist from center.
	      endelse
	      is=sort(s) & txt=txt(is)  ; Sort.
	      ntxt = n_elements(txt)
	      txt = txt(0:(maxlines-1)<(ntxt-1))	; Trim to fit display.
	      widget_control, id, set_val=txt	; Display text.
	      widget_control, idn, set_val='Points inside circle: '+$
	 	strtrim(ntxt,2)
	    endif else begin
	      widget_control, id, set_val=strarr(n_elements(lines))
	      widget_control, idn, set_val='Points inside circle: 0'
	    endelse
	  endif
	  ;--------  Handle new radius  ----------------------
	  if !mouse.button eq 2 then begin
	    xtxtin,txt,title='Enter new radius with units (or help):'
	    if strupcase(txt) eq 'HELP' then begin
	      xhelp,exit='OK',['Enter radius with units.  Example: 100 miles',$
		'  The following units may be used:',$
		'    km       Default.',$
		'    miles    Statute miles.',$
                '    nmiles   Nautical miles.',$
                '    feet     Feet.',$
                '    yards    Yards.',$
                '    degrees  Degrees (great circle).',$
                '    radians  Radians (great circle).']
	      xtxtin,txt,title='Enter new radius with units (or help):'
	    endif
	    if txt ne '' then begin
	      units2 = getwrd(txt,1)
	      if units2 eq '' then begin
	        units2 = 'km'
	       xmess,' Units assumed to be km'
	      endif
	      mapcirci_units, units2, cf2, utxt=utxt2
	      if cf2 eq 0 then begin
	        xmess,'Unkown units.  Ignored.'
	      endif else begin
	        r = getwrd(txt)+0.
		if r eq long(r) then r=long(r)	; Try to make int.
		cf = cf2
		utxt = utxt2
	        rr = r*cf			; Radius in radians.
	        rb2ll,x,y,rr,maken(0,360,181),xx,yy	; Initial circle.
	        w = where(xx gt 180, c)		; Put long in range +/-180.
	        if c gt 0 then xx(w)=xx(w)-360
		widget_control,idc,set_val='Radius = '+$
                  strtrim(r,2)+' '+utxt
        	todev,x,y,ix,iy
        	tvcrs,ix,iy
	      endelse
	    endif
	  endif
	  ;--------  Exit button  ----------------
          if !mouse.button gt 2 then exflag=1
	endwhile
 
	;------- terminate  ------------------------------
	device, set_graphics=gmode0           ; Restore mode.
	if n_elements(top) ne 0 then widget_control, top, /dest
 
	return
	end
