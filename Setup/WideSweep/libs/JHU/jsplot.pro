;-------------------------------------------------------------
;+
; NAME:
;       JSPLOT
; PURPOSE:
;       Make a time series plot with time in Julian Seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       jsplot, js, y
; INPUTS:
;       js = Time array in Julian Seconds.   in
;       y  = Data to be plotted.             in
; KEYWORD PARAMETERS:
;       Keywords:
;         GAP=gs  Gap in seconds.  This or greater time difference
;           will cause a break in the curve.  If a plot symbol
;           is desired use a negative psym number to connect pts.
;         CCOLOR=cc     Curve and symbol color (def=same as axes).
;         XTITLE=txt    Time axis title text.
;         XTICKLEN=xtl  Time axis tick length (fraction of plot).
;         XTICKS=n      Suggested number of time axis ticks.
;           The actual number of tick marks may be quite different.
;         FORMAT=fmt    Set date/time format (see timeaxis,/help).
;         LABELOFF=off  Adjust label position (see timeaxis,/help).
;         MAJOR=mjr     Major grid linestyle.
;         MINOR=mnr     Minor grid linestyle.
;         JSMAJOR=jsmajor Returned major time tick positions (JS).
;         JSMINOR=jsminor Returned minor time tick positions (JS).
;         TRANGE=[js1,js2] Specified time range in JS.
;           May also give date/time strings as entries.
;         OFF=off       Returned JS of plot min time. Use to plot
;           times in JS: VER, js(0)-off.
;         /OVER         Make overplot.  oplot,js-off,y also works
;           but will not handle any gaps.
;         Any plot keywords will be passed on to the plot call.
;         Following related to background sun colors:
;         /SUN display day/night/twilight as background colors.
;         COLOR=clr     Plot color (set to black by /SUN).
;         LONG=lng, LAT=lat = observer location for sun colors.
;         ZONE=hrs  Hours ahead of GMT (def=0). Ex: zone=-4 for EDT.
; OUTPUTS:
; COMMON BLOCKS:
;       js_com
; NOTES:
;       Notes:  Julian seconds are seconds after 0:00 1 Jan 2000.
;         See also dt_tm_tojs(), dt_tm_fromjs(), ymds2js(), js2ymds.
; MODIFICATION HISTORY:
;       R. Sterner 1994 Mar 30
;       R. Sterner, 1994 May 17 --- Added common js_com.
;       R. Sterner, 1996 Sep 16 --- Added sun colors.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;       R. Sterner, 1998 Feb  5 --- Added XTHICK, YTHICK, CHARTHICK.
;       R. Sterner, 1998 Aug 25 --- Fixed bug with the MAX_VALUE keyword.
;       R. Sterner, 1999 Sep 23 --- Returned JS for major and minor time ticks.
;       R. Sterner, 2000 Jun 23 --- Added LSHIFT to shift time axis labels.
;       R. Sterner, 2005 Apr 18 --- Allowed date/time strings in TRANGE.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro jsplot, t, y0, help=hlp, charsize=csz, color=clr, $
	  format=frm, xtitle=xtitl, xticklen = xtl, xticks=ntics, $
	  labeloff=lbloff, _extra=extra, major=mjr, minor=mnr, $
	  trange=tran0, gap=gap, max_value=maxv, linestyle=lstyl, $
	  thick=thk, ccolor=cclr, off=off, psym=psym, symsize=symsize, $
	  nodata=nodata, over=over, xtick_get=xtkget, ytick_get=ytkget, $
	  sun=sun, long=lng, lat=lat, zone=zone, xthick=xthick, ythick=ythick,$
	  charthick=charthick, jsmajor=jsmajor, jsminor=jsminor, lshift=lshift
 
	common js_com, jsoff
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make a time series plot with time in Julian Seconds.'
	  print,' jsplot, js, y'
	  print,'   js = Time array in Julian Seconds.   in'
	  print,'   y  = Data to be plotted.             in'
	  print,' Keywords:'
	  print,'   GAP=gs  Gap in seconds.  This or greater time difference'
	  print,'     will cause a break in the curve.  If a plot symbol'
	  print,'     is desired use a negative psym number to connect pts.'
	  print,'   CCOLOR=cc     Curve and symbol color (def=same as axes).'
	  print,'   XTITLE=txt    Time axis title text.'
	  print,'   XTICKLEN=xtl  Time axis tick length (fraction of plot).'
	  print,'   XTICKS=n      Suggested number of time axis ticks.'
	  print,'     The actual number of tick marks may be quite different.'
	  print,'   FORMAT=fmt    Set date/time format (see timeaxis,/help).'
	  print,'   LABELOFF=off  Adjust label position (see timeaxis,/help).'
	  print,'   MAJOR=mjr     Major grid linestyle.'
	  print,'   MINOR=mnr     Minor grid linestyle.'
	  print,'   JSMAJOR=jsmajor Returned major time tick positions (JS).'
	  print,'   JSMINOR=jsminor Returned minor time tick positions (JS).'
	  print,'   TRANGE=[js1,js2] Specified time range in JS.'
	  print,'     May also give date/time strings as entries.'
	  print,'   OFF=off       Returned JS of plot min time. Use to plot'
	  print,'     times in JS: VER, js(0)-off.'
	  print,'   /OVER         Make overplot.  oplot,js-off,y also works'
	  print,'     but will not handle any gaps.'
	  print,'   Any plot keywords will be passed on to the plot call.'
	  print,'   Following related to background sun colors:'
	  print,'   /SUN display day/night/twilight as background colors.'
	  print,'   COLOR=clr     Plot color (set to black by /SUN).'
	  print,'   LONG=lng, LAT=lat = observer location for sun colors.'
	  print,'   ZONE=hrs  Hours ahead of GMT (def=0). Ex: zone=-4 for EDT.'
	  print,' Notes:  Julian seconds are seconds after 0:00 1 Jan 2000.'
	  print,'   See also dt_tm_tojs(), dt_tm_fromjs(), ymds2js(), js2ymds.'
	  return
	endif
 
	;-------  Float y to allow for an IDL bug in max_val  ----------
	y = float(y0)
 
	;-------  Define defaults  ----------
	if n_elements(csz) eq 0 then csz=!p.charsize
	if csz eq 0 then csz = 1
;	if n_elements(cclr) eq 0 then cclr=clr
	if n_elements(xtitl) eq 0 then xtitl=!x.title
	if n_elements(xtl) eq 0 then xtl=.02
	if n_elements(ntics) eq 0 then ntics=!x.ticks
	if n_elements(lbloff) eq 0 then lbloff=0
	if n_elements(frm) eq 0 then frm=''
	if n_elements(tran0) eq 0 then tran0=[t(0),t(n_elements(t)-1)]
	if n_elements(maxv) eq 0 then maxv=max(y)+1.
	if n_elements(lstyl) eq 0 then lstyl=!p.linestyle
	if n_elements(thk) eq 0 then thk=!p.thick
	if n_elements(psym) eq 0 then psym=!p.psym
	if n_elements(symsize) eq 0 then symsize=!p.symsize
	symsz = symsize
	if symsz eq 0 then symsz = 1.
	if !p.multi(1) gt 1 then symsz = symsz/2.
	if n_elements(xthick) eq 0 then xthick=!x.thick
	if n_elements(ythick) eq 0 then ythick=!y.thick
	if n_elements(charthick) eq 0 then charthick=!p.charthick
 
	;-------  Make sure time range, tran, values are JS ------
	js1 = tran0(0)		; Start time.
	js2 = tran0(1)		; End time.
	if datatype(js1) eq 'STR' then js1=dt_tm_tojs(js1) ; Convert to JS.
	if datatype(js2 )eq 'STR' then js2=dt_tm_tojs(js2)
	tran = [js1, js2]	; Pack into array.
 
	;-------  Find JD and offset  ---------
	if not keyword_set(over) then begin
	  time2jdoff, t(0), jd=jd, off=off
	  jsoff = off
	endif else off = jsoff
 
	;-------  Handle GAP keyword  ----------
	w = lindgen(n_elements(t))
	nr = 1
	if n_elements(gap) ne 0 then begin
	  w = where((t(1:*)-t) lt gap, cnt)
	  if cnt eq 0 then begin
	    bell
	    print,' Error in jsplot: given gap size of '+strtrim(gap,2)+$
	    ' seconds is too small, no points selected.'
	    return
	  endif
	  nr = nruns(w)
	endif
 
	;--------  Get set up for sun colors  ---------------
	if keyword_set(sun) then begin
	  if !d.window eq -1 then begin
	    if !d.name eq 'X' then begin
	      window,/free,xs=50,ys=50,/pixmap
	      wdelete,!d.window
	    endif
	  endif
	  if !d.table_size lt 181 then begin
            print,' Error in jsplot: Only have '+strtrim(!d.table_size,2)
	    print,'   colors available.  Need at least 181 to use /SUN option.'
            return
	  endif
	  if (n_elements(lng) eq 0) or (n_elements(lat) eq 0) then begin
	    print,' Error in jsplot: when using /SUN must also give both'
	    print,'   long and lat.'
	    return
	  endif
	  zd = sun_zd(lng,lat,tran(0),tran(1),zone=zone)
	  sun_colors
	endif
	if n_elements(clr) eq 0 then clr=!p.color
	if n_elements(cclr) eq 0 then cclr=clr
 
	;------  Plot  -------------------------
	if not keyword_set(over) then $
	  plot, t-off, y, charsize=csz, color=clr, xstyle=5, $
	    xthick=xthick, ythick=ythick, charthick=charthick, $
	    xrange=tran-off, /nodata, max_value=maxv, linestyle=lstyl, $
	    thick=thk, _extra=extra, xtick_get=xtkget, ytick_get=ytkget
	if keyword_set(sun) then begin
	  imgunder,zd,/int
	  plot, t-off, y, charsize=csz, color=clr, xstyle=5, $
	    xthick=xthick, ythick=ythick, charthick=charthick, $
            xrange=tran-off, /nodata, max_value=maxv, linestyle=lstyl, $
            thick=thk,_extra=extra,xtick_get=xtkget,ytick_get=ytkget,/noerase
	endif
	if psym ne 0 then oplot, t-off,y,psym=abs(psym),color=cclr, $
	  symsize=symsz, linestyle=lstyl,thick=thk
	if not keyword_set(nodata) and (psym le 0) then begin
	  for i=0, nr-1 do begin
	    ww = getrun(w,i)
	    ww = [ww,max(ww)+1]
	    oplot, t(ww)-off, y(ww), max_value=maxv, symsize=symsz, $
	      color=cclr, linestyle=lstyl, thick=thk, psym=psym
	  endfor
	endif
	lastplot
	if not keyword_set(over) then $
	  plot, t-off, y, charsize=csz, color=clr, xstyle=5, $
	    xthick=xthick, ythick=ythick, charthick=charthick, $
	    xrange=tran-off, /nodata, max_value=maxv, linestyle=lstyl, $
	    thick=thk,/noerase,_extra=extra,xtick_get=xtkget,ytick_get=ytkget
	nextplot
 
	if not keyword_set(over) then $
	  timeaxis, jd=jd, form=frm, nticks=ntics, title=xtitl, $
	    ticklen=xtl*100, labeloffset=lbloff, charsize=csz, $
	    color=clr, major=mjr, minor=mnr, thick=xthick, $
	    charthick=charthick, tmaj=tmaj, tmin=tmin, lshift=lshift
 
	;------  return JS for major and minor time ticks  --------
	if n_elements(tmaj) ne 0 then begin
	  jsmajor = off + tmaj
	  jsminor = off + tmin
	endif
 
	return
	end
