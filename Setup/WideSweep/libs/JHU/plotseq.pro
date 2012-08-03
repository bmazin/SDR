;-------------------------------------------------------------
;+
; NAME:
;       PLOTSEQ
; PURPOSE:
;       Plot a movielike sequence of graphs.
; CATEGORY:
; CALLING SEQUENCE:
;       plotseq, x, y, [ind]
; INPUTS:
;       x = array of x coordinates.  May be 1-d or 2-d.   in
;           When x is 1-d all plots share same x values.
;       y = array of y coordinates.  May be 1-d or 2-d.   in
;           If 2-d second index is plot number.
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=ttxt  Plot titles (def=plot number).
;           May be an array with one element for each plot.
;         XTITLE=xtxt X axis title (def=none).
;           Same for all plots.
;         YTITLE=ytxt Y axis title (def=none).
;           Same for all plots.
;         COLOR=clr   Plot color (def=!p.color).
;         SYMSIZE=sz  Symbol size (def=1).
;         XOVER=x2    Second data set x array.  Same format as x.
;         YOVER=y2    Second data set y array.  Same format as y.
;         YTICKNAMES=ytn String array of user specified Y tick
;           labels.  Must also give YTICKVALUES.
;         YTICKVALUES=ytv Array of Y positions of the tick labels
;           given in YTICKNAMES.  # elements must match.
;         XSCALE=xs   X array scaling. 2-d in general: xs(3,n).
;           If xs is given then xs(0,j) + xs(1,j)*x
;           will be plotted as X where j=plot number.
;           The number of points plotted will be xs(2,j).
;         GH=h an array of Y values of horizontal lines.
;         GV=v an array of X values of vertical lines.
;           Any horizontal or vertical lines are known together
;           as the grid.
;         GCOLOR=c      grid color (def=!p.color).
;         GLINESTYLE=s  grid line style (def=!p.linestyle).
;         XRANGE=xran   A 2-d array giving the X axis range.
;         YRANGE=yran   A 2-d array giving the Y axis range.
;         XTYPE=t       Set linear (0) or log (1) X axis.
;         YTYPE=t       Set linear (0) or log (1) Y axis.
; OUTPUTS:
;       ind = optional indices of last plotted points.    out
;           The indices of a subset of points may be
;           returned if used with the ZOOM option.
; COMMON BLOCKS:
;       plotseq_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Sep, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro plotseq, x, y, ind, title=title, xtitle=xtitle, ytitle=ytitle, $
	  color=color, symsize=symsize, xscale=xscale, xover=x2, yover=y2, $
	  yticknames=ytickn, ytickvalues=ytickv, $
	  gh=gh, gv=gv, gcolor=gcolor, glinestyle=gline, $
	  xrange=xran, yrange=yran, xtype=xtyp, ytype=ytyp,  help=hlp
 
	common plotseq_com, pdir, pin, pxran, pyran, pmode, pgrid, pgridon, $
	  pxtyp, pytyp, ppsym, pwt, pxstyl, pystyl, p2nd, p2on, pxscal
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot a movielike sequence of graphs.'
	  print,' plotseq, x, y, [ind]'
	  print,'   x = array of x coordinates.  May be 1-d or 2-d.   in'
	  print,'       When x is 1-d all plots share same x values.'
	  print,'   y = array of y coordinates.  May be 1-d or 2-d.   in'
	  print,'       If 2-d second index is plot number.'
	  print,'   ind = optional indices of last plotted points.    out'
	  print,'       The indices of a subset of points may be'
	  print,'       returned if used with the ZOOM option.'
	  print,' Keywords:'
	  print,'   TITLE=ttxt  Plot titles (def=plot number).'
	  print,'     May be an array with one element for each plot.'
	  print,'   XTITLE=xtxt X axis title (def=none).'
	  print,'     Same for all plots.'
	  print,'   YTITLE=ytxt Y axis title (def=none).'
	  print,'     Same for all plots.'
	  print,'   COLOR=clr   Plot color (def=!p.color).'
	  print,'   SYMSIZE=sz  Symbol size (def=1).'
	  print,'   XOVER=x2    Second data set x array.  Same format as x.'
	  print,'   YOVER=y2    Second data set y array.  Same format as y.'
	  print,'   YTICKNAMES=ytn String array of user specified Y tick'
	  print,'     labels.  Must also give YTICKVALUES.'
	  print,'   YTICKVALUES=ytv Array of Y positions of the tick labels'
	  print,'     given in YTICKNAMES.  # elements must match.'
	  print,'   XSCALE=xs   X array scaling. 2-d in general: xs(3,n).'
	  print,'     If xs is given then xs(0,j) + xs(1,j)*x'
	  print,'     will be plotted as X where j=plot number.'
	  print,'     The number of points plotted will be xs(2,j).'
	  print,'   GH=h an array of Y values of horizontal lines.'
	  print,'   GV=v an array of X values of vertical lines.'
	  print,'     Any horizontal or vertical lines are known together'
 	  print,'     as the grid.'
	  print,'   GCOLOR=c      grid color (def=!p.color).'
	  print,'   GLINESTYLE=s  grid line style (def=!p.linestyle).' 
	  print,'   XRANGE=xran   A 2-d array giving the X axis range.'
	  print,'   YRANGE=yran   A 2-d array giving the Y axis range.'
	  print,'   XTYPE=t       Set linear (0) or log (1) X axis.'
	  print,'   YTYPE=t       Set linear (0) or log (1) Y axis.'
	  return
	endif
 
	;--------  Check inputs  ----------
	if n_elements(x) eq 0 then begin
	  bell
	  print,' Error in plotseq: first arg is undefined.'
	  return
	endif
	if n_elements(y) eq 0 then begin
	  bell
	  print,' Error in plotseq: second arg is undefined.'
	  return
	endif
 
	;--------  Check user specified Y ticks  ------
	if n_elements(ytickn) ne 0 then begin
	  if n_elements(ytickv) eq 0 then begin
	    bell
	    print,' Error in plotseq: YTICKVALUES must be specified'
	    print,'   along with YTICKNAMES.'
	    return
	  endif
	  if n_elements(ytickn) ne n_elements(ytickv) then begin
	    bell
	    print,' Error in plotseq: YTICKVALUES must have the same'
	    print,'   number of elements as YTICKNAMES.'
	    return
	  endif
	  yticks = n_elements(ytickn) - 1
	endif else begin
	  ytickn = ''	
	  ytickv = 0
	  yticks = 0
	endelse
 
	;----------  Get array sizes  ----------
	;-----  Main curves  --------
	sz = size(x)
	nx_x = sz(1)
	ny_x = 0 & lst_x = 0
	if sz(0) gt 1 then begin ny_x = sz(2)  &  lst_x = ny_x-1 & end
	sz = size(y)
	nx_y = sz(1)
	ny_y = 0 & lst_y = 0
	if sz(0) gt 1 then begin ny_y = sz(2)  &  lst_y = ny_y-1 & end
	;------  Secondary curves  --------
	p2nd = 0				; Assume no secondary curves.
	if n_elements(x2) ne 0 then begin
	  sz = size(x2)
	  nx_x2 = sz(1)
	  ny_x2 = 0 & lst_x2 = 0
	  if sz(0) gt 1 then begin ny_x2 = sz(2)  &  lst_x2 = ny_x2-1 & end
	  if n_elements(y2) ne 0 then begin
	    sz = size(y2)
	    nx_y2 = sz(1)
	    ny_y2 = 0 & lst_y2 = 0
	    if sz(0) gt 1 then begin ny_y2 = sz(2)  &  lst_y2 = ny_y2-1 & end
	    p2nd = 1				; Secondary curves exist.
	  endif
	endif
	;------  X axis scaling  ---------------
	pxscal = 0				; Assume no special scaling.
	if n_elements(xscale) ne 0 then begin
	  sz = size(xscale)
	  if sz(1) ne 3 then begin
	    bell
	    print,' Error in plotseq: XSCALE keyword parameter must be'
	    print,'   an array 3 X n where n may be 1.'
	    return
	  endif
	  ny_xs = 0 & lst_xs = 0
	  if sz(0) gt 1 then begin ny_xs=sz(2) & lst_xs=ny_xs-1 & end
	  pxscal = 1				; Special X axis scaling.
	endif
 
	;---------- Grid  --------------------
	pgrid = 0				; Assume no grid.
	if (n_elements(gh) ne 0) or (n_elements(gv) ne 0) then pgrid=1
	if n_elements(gcolor) eq 0 then gcolor = !p.color
	if n_elements(gline) eq 0 then gline = !p.linestyle
 
	;----------  Set defaults  -----------
	if n_elements(title) eq 0 then title = strtrim(sindgen(ny_y>1),2)
	lst_t = n_elements(title)-1
	if n_elements(xtitle) eq 0 then xtitle = ''
	if n_elements(ytitle) eq 0 then ytitle = ''
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(symsize) eq 0 then symsize = 1
	if n_elements(xran) ne 0 then pxran = xran
	if n_elements(yran) ne 0 then pyran = yran
	if n_elements(xtyp) ne 0 then pxtyp = xtyp
	if n_elements(ytyp) ne 0 then pytyp = ytyp
	if n_elements(pdir) eq 0 then pdir=0	    ; Plot direction.
	if n_elements(pin) eq 0 then pin=0L	    ; Current plot index.
	if n_elements(pxran) eq 0 then pxran=[0,0]  ; X range.
	if n_elements(pyran) eq 0 then pyran=[0,0]  ; Y range.
	pxstyl = 1				    ; Exact x axis,
	if total(abs(pxran)) eq 0 then pxstyl=0     ;   unless autoscale.
	pystyl = 1				    ; Exact y axis,
	if total(abs(pyran)) eq 0 then pystyl=0     ;   unless autoscale.
	if n_elements(pmode) eq 0 then pmode=0      ; Plot mode (overplot?).
	if n_elements(pxtyp) eq 0 then pxtyp=0      ; X Plot type (Log?).
	if n_elements(pytyp) eq 0 then pytyp=0      ; Y Plot type (Log?).
	if n_elements(ppsym) eq 0 then ppsym=0      ; Plot symbol.
	if n_elements(pwt) eq 0 then pwt=0          ; Sec between plots.
	if n_elements(p2on) eq 0 then p2on = 1	    ; 2nd plot on.
	if n_elements(pgridon) eq 0 then pgridon=1  ; Grid on.
 
	;---------  Set up the screen menu  -------
mloop:	menu = ['|5|2|Plot a sequence of Graphs||',$
		'|5|4|Quit| |QUIT|',$
		'|15|4|Help| |HELP|',$
		'|45|4|Debug Stop| |DEBUG|',$
		'|5|6|Go| |GO|',$
		'|15|6|Plot Direction|'+(['Forward','Reverse'])(pdir)+$
		    '|DIR|',$
		'|45|6|Single Step| |STEP|',$
		'|45|8|Wait time (sec)|'+strtrim(pwt,2)+'|WT|',$
		'|65|6|Replot| |REP|',$
		'|5|8|Plot Index|'+strtrim(pin,2)+$
		  ' of '+strtrim(lst_y,2)+'       |PIN|',$
		'|5|10|X range|'+strtrim(pxran(0),2)+'  '+$
		    strtrim(pxran(1),2)+'|XRAN|',$
		'|5|12|Y range|'+strtrim(pyran(0),2)+'  '+$
		    strtrim(pyran(1),2)+'|YRAN|',$
		'|15|14|ZOOM| |ZOOM|',$
		'|15|16|UNZOOM| |UNZOOM|',$
		'|45|14|Plot type|'+(['Normal','Overplot'])(pmode)+$
		    '|MODE|',$
		'|45|16|X Axis|'+(['Linear','Log'])(pxtyp)+$
		    '|XAX|',$
		'|45|18|Y Axis|'+(['Linear','Log'])(pytyp)+$
		    '|YAX|',$
		'|15|18|PSYM|'+strtrim(ppsym,2)+'|PSYM|']
 
	;-----  If secondary curves exist add a menu item  -----
	if p2nd eq 1 then begin
	  menu = [menu, '|45|10|Second data set|'+$
	    (['Off','On'])(p2on)+'|SET2|']
	endif
 
	;-----  If grid exists add a menu item  -----
	if pgrid eq 1 then begin
	  menu = [menu, '|45|12|Grid|'+$
	    (['Off','On'])(pgridon)+'|GRID|']
	endif
 
	;--------  Display menu  -------------
	txtmenu, init=menu
	opt = 'GO'
 
	;--------  Menu selection  -----------
loop:	txtmenu, select=opt, uvalue=uval
 
	;--------  Process command  ----------
	case uval of
'QUIT':	begin
	  printat,1,24,''
	  if n_params(0) lt 3 then return
	  xr = pxran
	  if total(abs(xr)) eq 0 then xr = !x.crange
	  yr = pyran
	  if total(abs(yr)) eq 0 then yr = !y.crange
	  ind = where((x ge xr(0)) and (x lt xr(1)) and $
		    (y ge yr(0)) and (y lt yr(1)))
	  return
	end
'GO':	begin
	  printat,5,20,'< Press any key to stop >'
	  i = pin
	  if (pdir eq 0) and (i eq lst_y) then i = 0
	  if (pdir eq 1) and (i eq 0) then i = lst_y
	  while ((i ge 0) and (i le lst_y)) do begin
	    ;************ <PLOT> ****************
	    xx = x(*,i<lst_x)
	    yy = y(*,i<lst_y)
	    if pxscal then begin
	      xsc = xscale(*,i<lst_xs)
	      xx = xsc(0) + xsc(1)*xx(0:xsc(2))
	      yy = yy(0:(xsc(2)-1))
	    endif
	    plot,xx,yy,title=title(i<lst_t),xtitle=xtitle,$
	      ytitle=ytitle, xtype=pxtyp, ytype=pytyp, color=color, $
	      symsize=symsize,xrange=pxran, yrange=pyran,psym=ppsym, $
	      xstyle=pxstyl, ystyle=pystyl,ytickn=ytickn,ytickv=ytickv,$
	      yticks=yticks
	    if p2nd and p2on then oplot, x2(*,i<lst_x2), y2(*,i<lst_y2)
	    if pgridon then begin
	      if n_elements(gh) ne 0 then hor, gh, color=gcolor, line=gline
	      if n_elements(gv) ne 0 then ver, gv, color=gcolor, line=gline
	    endif
	    ;*************************************
	    if get_kbrd(0) ne '' then goto, skip
	    wait, pwt
	    i = i + ([1,-1])(pdir)
	  endwhile
skip:	  pin = i>0<lst_y
	  txtmenu, update = '|5|8|Plot Index|'+strtrim(pin,2)+$
            ' of '+strtrim(lst_y,2)+'       |PIN|'
	  printat,5,20,'                         '
	  goto, loop
	end
'DIR':	begin
	  pdir = 1 - pdir
	  txtmenu, update = '|15|6|Plot Direction|'+$
	    (['Forward','Reverse'])(pdir)+'|DIR|'
	  goto, loop
	end
'STEP':	begin
	  i = (pin + ([1,-1])(pdir))
	  if i gt lst_y then i = i - ny_y
	  if i lt 0 then i = i + ny_y
	  ;************ <PLOT> ****************
          xx = x(*,i<lst_x)
          yy = y(*,i<lst_y)
          if pxscal then begin
            xsc = xscale(*,i<lst_xs)
            xx = xsc(0) + xsc(1)*xx(0:xsc(2))
            yy = yy(0:(xsc(2)-1))
          endif
	  if pmode eq 1 then begin
	    oplot, xx, yy, color=color, $
	      symsize=symsize,psym=ppsym
	  endif else begin
	    plot,xx,yy,title=title(i<lst_t),xtitle=xtitle,$
	      ytitle=ytitle, xtype=pxtyp, ytype=pytyp, color=color, $
	      symsize=symsize,xrange=pxran, yrange=pyran,psym=ppsym,$
	      xstyle=pxstyl, ystyle=pystyl,ytickn=ytickn,ytickv=ytickv,$
	      yticks=yticks
	  endelse
	  if p2nd and p2on then oplot, x2(*,i<lst_x2), y2(*,i<lst_y2)
	  if pgridon then begin
	    if n_elements(gh) ne 0 then hor, gh, color=gcolor, line=gline
	    if n_elements(gv) ne 0 then ver, gv, color=gcolor, line=gline
	  endif
	  ;*************************************
	  pin = i
	  if !d.name ne 'TEK' then begin
	    txtmenu, update = '|5|8|Plot Index|'+strtrim(pin,2)+$
              ' of '+strtrim(lst_y,2)+'       |PIN|'
	  endif
	  opt = 'STEP'
	  goto, loop
	end
'PIN':	begin
	  txtin,'New plot index',in, def=pin
	  i = (in + 0L)>0<lst_y
	  ;************ <PLOT> ****************
          xx = x(*,i<lst_x)
          yy = y(*,i<lst_y)
          if pxscal then begin
            xsc = xscale(*,i<lst_xs)
            xx = xsc(0) + xsc(1)*xx(0:xsc(2))
            yy = yy(0:(xsc(2)-1))
          endif
	  plot,xx,yy,title=title(i<lst_t),xtitle=xtitle, $
	    ytitle=ytitle, xtype=pxtyp, ytype=pytyp, color=color, $
	    symsize=symsize,xrange=pxran, yrange=pyran,psym=ppsym,$
	    xstyle=pxstyl,ystyle=pystyl,ytickn=ytickn,ytickv=ytickv,$
	    yticks=yticks
	  if p2nd and p2on then oplot, x2(*,i<lst_x2), y2(*,i<lst_y2)
	  if pgridon then begin
	    if n_elements(gh) ne 0 then hor, gh, color=gcolor, line=gline
	    if n_elements(gv) ne 0 then ver, gv, color=gcolor, line=gline
	  endif
	  ;*************************************
	  pin = i
	  txtmenu, update = '|5|8|Plot Index|'+strtrim(pin,2)+$
            ' of '+strtrim(lst_y,2)+'       |PIN|'
	  goto, loop
	end
'REP':	begin
	  i = pin
	  ;************ <PLOT> ****************
          xx = x(*,i<lst_x)
          yy = y(*,i<lst_y)
          if pxscal then begin
            xsc = xscale(*,i<lst_xs)
            xx = xsc(0) + xsc(1)*xx(0:xsc(2))
            yy = yy(0:(xsc(2)-1))
          endif
	  plot,xx,yy,title=title(i<lst_t),xtitle=xtitle, $
	    ytitle=ytitle, xtype=pxtyp, ytype=pytyp, color=color, $
	    symsize=symsize,xrange=pxran, yrange=pyran,psym=ppsym,$
	    xstyle=pxstyl,ystyle=pystyl,ytickn=ytickn,ytickv=ytickv,$
	    yticks=yticks
	  if p2nd and p2on then oplot, x2(*,i<lst_x2), y2(*,i<lst_y2)
	  if pgridon then begin
	    if n_elements(gh) ne 0 then hor, gh, color=gcolor, line=gline
	    if n_elements(gv) ne 0 then ver, gv, color=gcolor, line=gline
	  endif
	  ;*************************************
	  goto, loop
	end
'XRAN': begin
	  xr = strtrim(pxran(0),2)+'  '+strtrim(pxran(1),2)
	  txtin, 'New X range',in,def=xr
	  if in ne '' then begin
	    in = repchr(in,',')
	    pxran = [getwrd(in,0)+0., getwrd(in,1)+0.]
	    txtmenu,update='|5|10|X range|'+strtrim(pxran(0),2)+'  '+$
	      strtrim(pxran(1),2)+'|XRAN|'
	  endif
	  pxstyl = 1				      ; Exact x axis,
	  if total(abs(pxran)) eq 0 then pxstyl=0     ;   unless autoscale.
	  goto, loop
	end
'YRAN': begin
	  yr = strtrim(pyran(0),2)+'  '+strtrim(pyran(1),2)
	  txtin, 'New Y range',in,def=yr
	  if in ne '' then begin
	    in = repchr(in,',')
	    pyran = [getwrd(in,0)+0., getwrd(in,1)+0.]
	    txtmenu,update='|5|12|Y range|'+strtrim(pyran(0),2)+'  '+$
	      strtrim(pyran(1),2)+'|YRAN|'
	  endif
	  pystyl = 1				      ; Exact y axis,
	  if total(abs(pyran)) eq 0 then pystyl=0     ;   unless autoscale.
	  goto, loop
	end
'ZOOM':	begin
	  pk,x(*,pin<lst_x),y(*,pin<lst_y),/nomark,xrange=pxran,yrange=pyran
	  txtmenu,update='|5|10|X range|'+strtrim(pxran(0),2)+'  '+$
	    strtrim(pxran(1),2)+'|XRAN|'
	  txtmenu,update='|5|12|Y range|'+strtrim(pyran(0),2)+'  '+$
	    strtrim(pyran(1),2)+'|YRAN|'
	  pxstyl = 1				      ; Exact x axis,
	  if total(abs(pxran)) eq 0 then pxstyl=0     ;   unless autoscale.
	  pystyl = 1				      ; Exact y axis,
	  if total(abs(pyran)) eq 0 then pystyl=0     ;   unless autoscale.
	  ;************ <PLOT> ****************
	  i = pin
          xx = x(*,i<lst_x)
          yy = y(*,i<lst_y)
          if pxscal then begin
            xsc = xscale(*,i<lst_xs)
            xx = xsc(0) + xsc(1)*xx(0:xsc(2))
            yy = yy(0:(xsc(2)-1))
          endif
	  plot,xx,yy,title=title(i<lst_t),xtitle=xtitle, $
	    ytitle=ytitle, xtype=pxtyp, ytype=pytyp, color=color, $
	    symsize=symsize,xrange=pxran, yrange=pyran,psym=ppsym,$
	    xstyle=pxstyl,ystyle=pystyl,ytickn=ytickn,ytickv=ytickv,$
	    yticks=yticks
	  if p2nd and p2on then oplot, x2(*,i<lst_x2), y2(*,i<lst_y2)
	  if pgridon then begin
	    if n_elements(gh) ne 0 then hor, gh, color=gcolor, line=gline
	    if n_elements(gv) ne 0 then ver, gv, color=gcolor, line=gline
	  endif
	  ;*************************************
	  goto, loop
	end
'UNZOOM': begin
	  pxran = [0,0]
	  if pxtyp eq 1 then begin
	    pxran = [min(x),max(x)]
	    if pxran(0) le 0 then pxran(0)=1.<abs(pxran(1))/1000.
	  endif
	  pyran = [0,0]
	  if pytyp eq 1 then begin
	    pyran = [min(y),max(y)]
	    if pyran(0) le 0 then pyran(0)=1.<abs(pyran(1))/1000.
	  endif
	  pxstyl = 0
	  pystyl = 0
	  txtmenu,update='|5|10|X range|'+strtrim(pxran(0),2)+'  '+$
	    strtrim(pxran(1),2)+'|XRAN|'
	  txtmenu,update='|5|12|Y range|'+strtrim(pyran(0),2)+'  '+$
	    strtrim(pyran(1),2)+'|YRAN|'
	  i = pin
	  ;************ <PLOT> ****************
          xx = x(*,i<lst_x)
          yy = y(*,i<lst_y)
          if pxscal then begin
            xsc = xscale(*,i<lst_xs)
            xx = xsc(0) + xsc(1)*xx(0:xsc(2))
            yy = yy(0:(xsc(2)-1))
          endif
	  plot,xx,yy,title=title(i<lst_t),xtitle=xtitle, $
	    ytitle=ytitle, xtype=pxtyp, ytype=pytyp, color=color, $
	    symsize=symsize,xrange=pxran, yrange=pyran,psym=ppsym, $
	    xstyle=pxstyl,ystyle=pystyl,ytickn=ytickn,ytickv=ytickv,$
	    yticks=yticks
	  if p2nd and p2on then oplot, x2(*,i<lst_x2), y2(*,i<lst_y2)
	  if pgridon then begin
	    if n_elements(gh) ne 0 then hor, gh, color=gcolor, line=gline
	    if n_elements(gv) ne 0 then ver, gv, color=gcolor, line=gline
	  endif
	  ;*************************************
	  goto, loop
	end
'PSYM':	begin
	  txtin,'New plot symbol',in, def=ppsym
	  ppsym = in + 0
	  txtmenu,up='|15|18|PSYM|'+strtrim(ppsym,2)+'|PSYM|'
	  goto, loop
	end
'WT':	begin
	  txtin,'Delay in seconds between plots',in, def=pwt
	  pwt = in + 0.
	  txtmenu,up='|45|8|Wait time (sec)|'+strtrim(pwt,2)+'|WT|'
	  goto, loop
	end
'MODE':	begin
	  pmode = 1 - pmode
	  txtmenu,up='|45|14|Plot type|'+(['Normal','Overplot'])(pmode)+$
		    '|MODE|'
	  if pmode eq 1 then begin
	    bell
	    txtmess,/noclear,y=21,'Over plots only work in Single Step mode'
	  endif
	  goto, loop
	end
'SET2':	begin
	  p2on = 1 - p2on
	  txtmenu,up='|45|10|Second data set|'+ (['Off','On'])(p2on)+'|SET2|'
	  goto, loop
	end
'GRID':	begin
	  pgridon = 1 - pgridon
	  txtmenu,up= '|45|12|Grid|'+(['Off','On'])(pgridon)+'|GRID|'
	  goto, loop
	end
'XAX':	begin
	  pxtyp = 1 - pxtyp
	  txtmenu, up='|45|16|X Axis|'+(['Linear','Log'])(pxtyp)+'|XAX|'
	  wflag = 0		; Set warning flag to off.
	  if (pxtyp eq 1) and (total(abs(pxran)) eq 0) then begin
	    xmx = max(max(xscale(0,*))+max(xscale(1,*))*x)
	    xmn = min(min(xscale(0,*))+min(xscale(1,*))*x)
	    pxran=[xmn,xmx]
	    wflag = 1
	  endif
	  if (pxtyp eq 1) and (min(pxran) eq 0) then begin
	    pxran(0) = 1.<(pxran/1000.)
	    wflag = 1
	  endif
	  txtmenu,update='|5|10|X range|'+strtrim(pxran(0),2)+'  '+$
	    strtrim(pxran(1),2)+'|XRAN|'
	  if wflag then begin
	    bell
	    txtmess,/noclear,y=21,'Warning: X range changed.'
	  endif
	  goto, loop
	end
'YAX':	begin
	  pytyp = 1 - pytyp
	  txtmenu, up='|45|18|Y Axis|'+(['Linear','Log'])(pytyp)+'|YAX|'
	  wflag = 0
	  if (pytyp eq 1) and (total(abs(pyran)) eq 0) then begin
	    pyran = [min(y),max(y)]
	    wflag = 1
	  endif
	  if (pytyp eq 1) and (min(pyran) eq 0) then begin
	    pyran = 1.<(pyran/1000.)
	    wflag = 1
	  endif
	  txtmenu,update='|5|12|Y range|'+strtrim(pyran(0),2)+'  '+$
	    strtrim(pyran(1),2)+'|YRAN|'
	  if wflag then begin
	    bell
	    txtmess,/noclear,y=21,'Warning: Y range changed.'
	  endif
	  goto, loop
	end
'HELP':	begin
	  printat,1,1,/clear
	  dir = getenv('IDL_IDLUSR')
	  if dir eq '' then begin
	    txtmess,['Error in plotseq: the system variable IDL_IDLUSR',$
		     'is not defined so help text cannot be located.',$
		     'Defined IDL_IDLUSR to be the IDLUSR library directory.']
	    goto, mloop
	  endif
	  helpfile,'plotseq_1.hlp',/txt,dir=dir
	  goto, mloop
	end
'DEBUG': begin
	  printat,1,24,''
	  stop,' Debug stop.  Do .con to continue.'
	  goto, mloop
	end
	endcase
 
	return
	end
