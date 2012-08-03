;-------------------------------------------------------------
;+
; NAME:
;       EQVC
; PURPOSE:
;       Interactive equation viewer and curve fitter.
; CATEGORY:
; CALLING SEQUENCE:
;       eqvc
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         FILE=filename  Name of equation file to view.
;         LIST=list  List of equation file names.  If LIST is
;           given then FILE is ignored.
;         XS=x, YS=y  Optional arrays of scatterplot points.
;           Useful for interactive curve fitting.
;         PSYM=p  Scatter plot symbol (def=2 (*)).
;         SNAPSHOT=file  name of snapshot file (def=snapshot.eqv).
;         TITLE=tt  plot title (over-rides value from eqv file).
;         XTITLE=tx  X axis title (over-rides value from eqv file).
;         YTITLE=ty  Y axis title (over-rides value from eqv file).
;         WINDOW=[nx,ny] array with window x & y size (def=[450,450])
;         ROOT=dir Root directory for finding files (equation files,
;           discussion files, snapshot files).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 06 from eqv.pro
;       R. Sterner, 2002 Oct 07 Added window redirect, also WINDOW keyword.
;       R. Sterner, 2002 Oct 13 from eqvd.pro, made compact version.
;       R. Sterner, 2002 Oct 17 Added overlay plot commands.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
;  Index to internal routines:
;
;	eqv_plot = Update plot
;	eqv_stat = Update status display.
;	sp2v = Convert slider position to value.
;	sv2p = Convert slider value to position.
;	eqv_compile = Equation file compiler.
;	eqvlist_event = Equation file list selection event handler.
;	eqvlist = Equation file list selection.
;	eqv_event = eqv event handler.
;	eqvd.pro = Equation viewer
;-------------------------------------------------------------
 
 
;-------------------------------------------------------------
;	eqv_plot = Update plot
;-------------------------------------------------------------
 
	pro eqv_plot, _d, hard=_hard
 
	;-------  Predefine a number of variables  ---------
	;  These variables may be used as parameters in the equation
	;  with no cost in code space.
	a=(b=(c=(d=(e=(f=(g=(h=(i=(j=(k=(l=(m=0B))))))))))))
	n=(o=(p=(q=(r=(s=(t=(u=(v=(w=(x=(y=(z=0B))))))))))))
	ax=(bx=(cx=(dx=(ex=(fx=(gx=(hx=(ix=(jx=(kx=(lx=(mx=0B))))))))))))
	nx=(ox=(px=(qx=(rx=(sx=(tx=(ux=(vx=(wx=(xx=(yx=(zx=0B))))))))))))
	ay=(by=(cy=(dy=(ey=(fy=(gy=(hy=(iy=(jy=(ky=(ly=(my=0B))))))))))))
	ny=(oy=(py=(qy=(ry=(sy=(ty=(uy=(vy=(wy=(yy=(yy=(zy=0B))))))))))))
 
	;-------  Get X and Y ranges  ----------
	widget_control, _d.x1, get_val=_x1  &  _x1 = _x1(0)
	_err = execute('_x1='+_x1)
	widget_control, _d.x2, get_val=_x2  &  _x2 = _x2(0)
	_err = execute('_x2='+_x2)
	widget_control, _d.y1, get_val=_y1  &  _y1 = _y1(0)
	_err = execute('_y1='+_y1)
	widget_control, _d.y2, get_val=_y2  &  _y2 = _y2(0)
	_err = execute('_y2='+_y2)
 
	;-------  Get parameter, T, range  ----------
	widget_control, _d.t1, get_val=_t1 & _t1 = _t1(0)
	if _t1 eq '' then begin
	  _t1 = '-10'
	  widget_control, _d.t1, set_val=_t1
	endif
	widget_control, _d.t2, get_val=_t2 & _t2 = _t2(0)
	if _t2 eq '' then begin
	  _t2 = '10'
	  widget_control, _d.t2, set_val=_t2
	endif
 
	;-------  Get number of points  ------
	widget_control, _d.n, get_val=_n & _n = _n(0)
	if _n eq '' then begin
	  _n = '100'
	  widget_control, _d.n, set_val=_n
	endif
 
	;------  Get axis types and styles -------------
	_xtype = _d.xtype
	_ytype = _d.ytype
	_xstyle = _d.xstyle
	_ystyle = _d.ystyle
 
	;------  Get plot type  --------------
	_ptype = _d.ptype
 
	;-------  Read equation  -------------
	widget_control, _d.equat, get_val=_equat
	_equat = _equat(0)
 
	;-----  Set parameters to their values ------
	for _i = 0, n_elements(_d.pname)-1 do begin
	  _t = _d.pname(_i)+'='+string(_d.pval(_i))
	  _err = execute(_t)
	endfor
 
	;------  Generate independent array  ----------------
	widget_control, _d.iv, get_val=_t  & _t = _t(0)
	;--------  Compute both y(x) and y(xs)  ---------
	if (_d.fitflag eq 0) or (_d.psym eq -99) then begin
	  _tmp = _t+'=maken('+_t1+','+_t2+','+_n+')'
	  _err = execute(_tmp)
	  if _err ne 1 then begin
	    xhelp,exit='OK',['Error generating independent variable:',$
	      _tmp,!err_string,$
	      ' ','Do the following to recover:',$
	      '1. Correct any errors in the name of the',$
	      '   independent variable, its limits, or number of points.',$
	      '2. Do retall.','3. Do xmanager.','4. Press the OK button below.']
	    return
	  endif
	;------  Compute just y(xs): Y at scatter X.  ---------
	endif else begin
	  _tmp = _t+'=_d.x'		; _t is Ind. Var.  Set to scatt X.
	  _err = execute(_tmp)
	  if _err ne 1 then stop,' Error in setting Ind. Var = scatter X.'
	endelse
 
	;------  Define some special case values  --------
	;------  May use in equation  ----------
	_t1 = _t1 + 0.		; Min Ind. Var.
	_t2 = _t2 + 0.		; Max Ind. Var.
	_dt = _t2 - _t1		; Range of Ind. Var.
 
	;------  Compute Y(X): actually Y(Ind Var)  --------------------
	_err = execute(_equat)
	if _err ne 1 then begin
	  xhelp,exit='OK',['Error executing:',_equat,!err_string,$
	    ' ','Do the following to recover:',$
	    '1. Correct any errors in the equation text',$
	    '   the name of the independent variable.',$
	    '2. Do retall.','3. Do xmanager.','4. Press the OK button below.']
	  return
	endif
	y0 = y		; Save for overplot.
 
	;-----------------------------------------------------------
	;  At this point the equation has been executed.  So variables
	;  X and Y are now both defined.  Y is either the equation
	;  value at the independent variable values, or the equation
	;  value at the scatter plot values.  Either way Y is fitted.
	;  _d.x and _d.y are the scatter plot points, if any.
	;  The plot limits are _x1 to _x2, and _y1 to _y2.
	;------------------------------------------------------------
 
	;------  Plot  ----------------------------
	wset, _d.win
	_pos = [.15,.1,.95,.9]
	scat_color = _d.c_sct
 
	if keyword_set(_hard) then begin
	  device0 = !d.name
	  if device0 eq 'WIN' then begin
	    set_plot,'printer'
	  endif else begin
	    psinit, comment='  Program: eqv.pro.  '+$
	      'Equation file: '+_d.file
	    scat_color = _d.c_plt
	  endelse
	endif else win_redirect
 
	if _ptype eq 1 then begin
	  subnormal, [.1,.1,0,.9], _pos
	  _dx = (1-(_pos(2)-_pos(1)))/2.
	  _pos = _pos + (_dx-_pos(0))*[1,0,1,0]
	endif
 
	;---------  Plot Axes  -------------
	if not keyword_set(_hard) then begin
	  erase, _d.c_bak
	  clr = _d.c_axes
	endif else begin
	  clr = 0
    	endelse
	if _ptype eq 0 then begin
	  plot, x, y, xran=[_x1,_x2], yran=[_y1,_y2], xtype=_xtype, $
	    ytype=_ytype, xtitle=_d.xtitle, ytitle=_d.ytitle, $
	    title=_d.title, pos=_pos, xstyle=_xstyle, ystyle=_ystyle, $
	    iso=_d.iso, /noerase, color=clr, /nodata
	endif else begin
	  plot, y, x, xran=[_x1,_x2], yran=[_y1,_y2], xtype=_xtype, $
	    ytype=_ytype, /polar, xtitle=_d.xtitle, ytitle=_d.ytitle, $
	    title=_d.title, pos=_pos, xstyle=_xstyle, ystyle=_ystyle, $
	    iso=_d.iso, /noerase, color=clr, /nodata
	endelse
 
	;---------  Execute overlay commands  --------------
	widget_control, _d.id_ovr, get_val=ovr
	n_eq = 0	; Index of overlay equations.
	n_cmd = -1	; Index of overlay command.
	for i=0,n_elements(ovr)-1 do begin
	  t = ovr(i)
	  tmp = strupcase(strcompress(t,/rem))
	  t0 = strmid(tmp,0,2)
	  t1 = strmid(tmp,1,2)
	  if (t0 eq 'Y=') or (t1 eq 'Y=') then n_eq=n_eq+1 ; Count equation.
	  ;-------  Extra equation  -----------------
	  if (t0 eq 'Y=') then begin
            _err = execute(t)
	    if _err ne 1 then begin
	      xhelp,exit='OK',['Error executing:',_equat,!err_string,$
	        ' ','Do the following to recover:',$
	        '1. Correct any errors in the equation text',$
	        '   the name of the independent variable.',$
	        '2. Do retall.','3. Do xmanager.',$
	        '4. Press the OK button below.']
	      return
	    endif
            if not keyword_set(_hard) then begin
	      clr = _d.c_plt([n_eq])	; Plot color for eq # n_eq.
	    endif else begin
	      clr = 0
            endelse
	    if _ptype eq 0 then begin
	      oplot, x, y, color=clr
	    endif else begin
	      oplot, y, x, /polar, color=clr
	    endelse
	  ;--------  Overlay command  ----------
	  endif else begin
	    if (ovr(i) ne '') then n_cmd = n_cmd+1	; Count command.
	    if (ovr(i) ne '') and (strmid(ovr(i),0,1) ne ';') then begin
	      !p.color = _d.c_ovr([n_cmd])
	      err=execute(ovr(i))
	    endif
	  endelse
	endfor
 
	;--------  Plot main equation now  -------------
        if not keyword_set(_hard) then begin
	  pclr = _d.c_plt(0)	; Plot color main equation.
	endif else begin
	  pclr = 0
        endelse
	if _ptype eq 0 then begin
	  oplot, x, y0, color=pclr
	endif else begin
	  oplot, y0, x, /polar, color=pclr
	endelse
 
	;-------  Plot axes?  ---------------------
	if _d.pltax then begin
	  plots,[_x1,_x2],[0,0],linestyle=1,col=clr	; X axis.
	  plots,[0,0],[_y1,_y2],linestyle=1,col=clr	; Y axis.
	endif
 
	;-------  Scatter plot  -------------------
	if _d.psym ne -99 then begin
	  if _d.ptype eq 0 then begin
	    oplot, _d.x, _d.y, psym=_d.psym, color=scat_color
	    oplot, x, y, color=pclr
	  endif else begin
	    oplot, _d.y, _d.x, psym=_d.psym, /polar, color=scat_color
	    oplot, y, x, /polar, color=pclr
	  endelse
	endif
 
	;--------  Compute and display fit  ------------
	if _d.fittype gt 0 then begin
	  if _d.fitflag eq 0 then begin
	    _tmp = _t+'=_d.x'		; Command to set ind. var. to xs.
	    _err = execute(_tmp)	; Actually set independent var.
	    _err = execute(_equat)	; Compute y(xs).
	    if _err ne 1 then stop
	  endif
	  case _d.fittype of
1:	  begin
	    w = where((_d.x ge _x1) and (_d.x le _x2), cnt)
	    if cnt gt 0 then begin
	      fit = strtrim(total((_d.y(w) - y(w))^2/y(w)))
	      fit_txt = 'Chi Sq: Total(((y-yfit)^2/yfit) over plot range only'
	    endif
	  end
else:
	  endcase
	  widget_control, _d.fitgood, set_val=fit
	endif
 
	if keyword_set(_hard) then begin
	  csz = 1.5
	  if device0 eq 'WIN' then csz=1.0
	  eqv_stat, _d, text=txt
	  xprint,/init,/norm,.1,-.1,chars=csz, dy=1.5
	  xprint,txt
	  xprint,' '
	  xprint,_equat
	  xprint,' '
	  xprint,'where '+_t+' has '+strtrim(_n,2)+' points from '+$
	    strtrim(_t1,2)+' to '+strtrim(_t2,2)+' and'
	  for i=0, n_elements(_d.pname)-1 do begin
	    xprint,_d.pname(i)+' = '+strtrim(_d.pval(i),2)
	  endfor
	  if _d.fittype gt 0 then begin
	    xprint,' '
	    xprint,'Fit: '+fit_txt+' = '+fit
	  endif
	  if device0 eq 'WIN' then begin
	    device,/close_document
	    set_plot,'WIN'
	  endif else begin
	    psterm
	  endelse
	endif else win_copy
 
	return
	end
 
 
;===============================================================
;	eqv_stat = Update status display.
;	R. Sterner, 28 Oct, 1993
;===============================================================
 
	pro eqv_stat, d, text=txt
 
	if d.ptype eq 0 then txt = 'XY Plot.  ' else $
	  txt = 'Polar Plot.  Angle=x  Radius=y.  '
	if d.xtype eq 0 then txt = txt + 'Linear X  ' else $
	  txt = txt + 'Log X  '
	if d.ytype eq 0 then txt = txt + 'Linear Y' else $
	  txt = txt + 'Log Y'
 
	widget_control, d.stat, set_val=txt
	return
	end
 
;===============================================================
;	sp2v = Convert slider position to value.
;	R. Sterner, 26 Oct, 1993
;===============================================================
 
	function sp2v, p, smax, pmin, pmax
	return, (p/float(smax))*(pmax-pmin) + pmin
	end
 
;===============================================================
;	sv2p = Convert slider value to position.
;	R. Sterner, 26 Oct, 1993
;===============================================================
 
	function sv2p, v, smax, pmin, pmax
	p = fix(.5+float(smax)*(v-pmin)/(pmax-pmin))
	return, p>0<smax
	end
 
 
;===============================================================
;	eqv_compile = Equation file compiler.
;	R. Sterner, 25 Oct, 1993
;===============================================================
 
	pro eqv_compile, file, title=title, xrange=xran, yrange=yran, $
	  par=par, number=num, equation=equat, xtype=xtype, ytype=ytype, $
	  ptype=ptype, psym=psym, xs=xs, ys=ys, trange=tran, $
	  out=out, xtitle=xtitle, ytitle=ytitle, indv=indv, $
	  discuss=discuss, up=up, overlay=ovr, c_plt=c_plt, $
	  c_ovr=c_ovr, c_axes=c_axes, c_bak=c_bak, c_sct=c_sct, $
	  init=init, error=err
 
	;-------  Add default extension  -------
	filebreak, file, dir=dir, name=name, ext=ext
	if ext eq '' then ext='eqv'
	f = dir+name+'.'+ext
 
	;-------  Get equation title  ----------
	txt = getfile(f)
	if (size(txt))(0) eq 0 then begin
	  xmess,['Equation file not opened:',f]
	  err = 1
	  return
	endif
	title = txtgetkey(init=txt, 'title', del=':',/start)
	;-------  X axis title  ---------------
	xtitle = txtgetkey('xtitle', /start)
	;-------  Y axis title  ---------------
	ytitle = txtgetkey('ytitle', /start)
	;-------  Snapshot file name  ---------
	out = txtgetkey('snapshot', /start)
	if out eq '' then out = 'snapshot.eqv'
	;-------  Discussion file name  ---------
	discuss = txtgetkey('discussion', /start)
	up= getwrd(discuss+' ',1)
	discuss = getwrd(discuss+' ')
	;-------  Get X Range  ----------
	tmp = txtgetkey('xrange', /start)
	if tmp eq '' then begin
	  xmess,['Error in equation file:',file,' No X Range found.']
	  err = 1
	  return
	endif
	tmp = repchr(tmp,',')
	xran = [getwrd(tmp,0),getwrd(tmp,1)]
	;-------  Get Y Range  ----------
	tmp = txtgetkey('yrange', /start)
	if tmp eq '' then begin
	  xmess,['Error in equation file:',file,' No Y Range found.']
	  err = 1
	  return
	endif
	tmp = repchr(tmp,',')
	yran = [getwrd(tmp,0),getwrd(tmp,1)]
	;-------  Get T Range  ----------
	tmp = txtgetkey('trange', /start)
	if tmp eq '' then begin
	  tran = xran		; Default to xrange.
	endif else begin
	  tmp = repchr(tmp,',')
	  tran = [getwrd(tmp,0),getwrd(tmp,1)]
	endelse
	;---------  Get number of points  -------
	tmp = txtgetkey('n_points', /start)
	if tmp eq '' then tmp = '100'
	num = tmp + 0
	;---------  Get X axis type ---------
	tmp = txtgetkey('xtype', /start)
	if tmp eq '' then tmp = '0'
	xtype = tmp + 0
	;---------  Get Y axis type ---------
	tmp = txtgetkey('ytype', /start)
	if tmp eq '' then tmp = '0'
	ytype = tmp + 0
	;---------  Get Plot type ---------
	tmp = txtgetkey('ptype', /start)
	if tmp eq '' then tmp = '0'
	ptype = tmp + 0
	;---------  Get independent variable  ---------
	tmp = txtgetkey('independent', /start)
	if tmp eq '' then tmp = 'x'
	indv = tmp
	;---------  Handle scatter plot points  ------------
	psym = -99
	xs = [0]
	ys = [0]
	tmp = txtgetkey('psym', /start)
	if tmp eq '' then tmp = '-99'
	psym0 = tmp + 0
	tmp = txtgetkey('scatter', /start)
	err = 0
	if tmp ne '' then begin
	  err = 1
	  on_ioerror, scerr
	  openr, lun, tmp, /get_lun	; Get scatter plot data from text file.
	  ns = 0			; Number of x,y pairs.
	  readf, lun, ns
	  data = fltarr(2,ns)		; Array to read xy pairs into.
	  readf,lun,data
	  close, lun
	  free_lun, lun
	  err = 0
	  xs = data(0,*)
	  ys = data(1,*)
	  psym = psym0
	  if psym eq -99 then psym = 2
	endif
scerr:	if err eq 1 then begin
	  xmess,['Error reading scatter plot data from equation file',$
	    file,' ',' Scatter plot ignored.']
	endif
	;---------  Get equation  ---------------
	w = where(strupcase(strmid(txt,0,3)) eq 'EQ:', cnt)
	if cnt eq 0 then begin
	  xmess,['Error in equation file:',file,' No equation found.']
	  err = 1
	  return
	endif
	equat = ''
	i = w(0)
	tmp = txt(i)			; First line of equation.
	p = strpos(tmp,':')		; Skip over eq:.
	tmp = strmid(tmp,p+1,999)
loop:	p = strpos(tmp,'$')		; $? = continued?
	if p gt 0 then begin		; Yes:
	  tmp = strmid(tmp,0,p)		;   1. Drop $.
	  equat = equat + tmp		;   2. Concat line.
	  i = i + 1			;   3. Read next.
	  tmp = txt(i)
	  goto, loop			;   4. Process.
	endif else begin		; No.
	  equat = equat + tmp		; Last line, concat.
	endelse
	;--------  Get any overlay plot commands  ---------
	w = where(strupcase(strmid(txt,0,4)) eq 'OVER', cnt); Any overlay lines?
	if cnt eq 0 then begin		; No.
	  ovr = ''
	endif else begin
	  ovr = txt(w)			; Extract overlay lines.
	  for i=0,cnt-1 do ovr(i)=getwrd(ovr(i),1,99)	; Drop overlay:
	endelse
	;--------  Get any init text  ------------------
	w = where(strupcase(strmid(txt,0,4)) eq 'INIT', cnt); Any init lines?
	if cnt eq 0 then begin		; No.
	  init = ''
	endif else begin
	  init = txt(w)			; Extract overlay lines.
	  for i=0,cnt-1 do init(i)=getwrd(init(i),1,99)	; Drop init:
	  for i=0,cnt-1 do begin
	    print,' init: '+init(i)
	    err = execute(init(i))
	  endfor
	endelse
	;--------  Colors  -----------------------------
	;---------  Axes color  -----------
	tmp = txtgetkey('c_axes', /start)
	if tmp eq '' then tmp = 0L
	c_axes = tmp + 0L
	;---------  Background color  -----------
	tmp = txtgetkey('c_back', /start)
	if tmp eq '' then tmp = tarclr(255,255,255)
	c_bak = tmp + 0L
	;---------  Scatter plot color  -----------
	tmp = txtgetkey('c_scat', /start)
	if tmp eq '' then tmp = 0L
	c_sct = tmp + 0L
	;----  Equation colors  ------------
	w = where(strupcase(strmid(txt,0,6)) eq 'C_PLOT', cnt); Any plot colors?
	if cnt eq 0 then begin		; No.
	  c_plt = 0L
	endif else begin
	  c_plt = txt(w)			; Extract c_plot lines.
	  for i=0,cnt-1 do c_plt(i)=getwrd(c_plt(i),1,99) ; Drop c_plot:
	  c_plt = c_plt + 0L
	endelse
	;-----  Overlay command colors  --------
	w = where(strupcase(strmid(txt,0,6)) eq 'C_OVER', cnt); Any over colors?
	if cnt eq 0 then begin		; No.
	  c_ovr = 0L
	endif else begin
	  c_ovr = txt(w)			; Extract c_plot lines.
	  for i=0,cnt-1 do c_ovr(i)=getwrd(c_ovr(i),1,99) ; Drop c_plot:
	  c_ovr = c_ovr + 0L
	endelse
	;--------  Get adjustable parameters  ----------
	w = where(strupcase(strmid(txt,0,4)) eq 'PAR:', cnt)	; Any par lines?
	if cnt eq 0 then begin		; No.
	  par = {n:0}			; Set par count to 0 and return.
	  err = 0
	  return
	endif
	txt = txt(w)			; Extract parameter lines.
	pname = strarr(cnt)	; Parameter name.
	pmin = fltarr(cnt)	; Initial range min.
	pmax = fltarr(cnt)	; Initial range max.
	pdef = fltarr(cnt)	; Initial starting value.
	pclr = lonarr(cnt)	; Slider color (24-bit).
	for i = 0, cnt-1 do begin
	  tmp = getwrd(txt(i),delim=':',/last)	; i'th parameter line.
	  tmp = repchr(tmp,',')		; Drop any commas.
	  pname(i)= getwrd(tmp,0)	; Get name.
	  pmin(i) = getwrd(tmp,1) + 0.	; Get parameter range min.
	  pmax(i) = getwrd(tmp,2) + 0.	; Get parameter range max.
	  pdef(i) = getwrd(tmp,3) + 0.	; Get parameter range def.
	  tmp = getwrd(tmp,4)		; Get parameter slider color.
	  if tmp eq '' then tmp=12632256  ; Gray.
	  pclr(i) = tmp + 0L
	endfor
	par = {n:cnt, name:pname, min:pmin, max:pmax, def:pdef, clr:pclr}
 
	err = 0
 
	return
	end
 
 
;===============================================================
;	eqvlist_event = Equation file list selection event handler.
;	R. Sterner, 25 Oct, 1993
;===============================================================
 
	pro eqvlist_event, ev
 
	widget_control, ev.id, get_uval=name	; Get name of action.
	widget_control, ev.top, get_uval=base	; Get address of base.
 
        if name eq 'QUIT' then begin
          widget_control, /dest, ev.top
          return
        endif
 
        if name eq 'HELP' then begin
          print,'HELP'
          return
        endif
 
	widget_control, base, get_uval=uval	; Get uval stored in base.
	list = uval.list			; Extract list and status.
	status = uval.status
 
	if status(ev.index) ne 0 then begin	; Check status.
	  xmess,['File could not be opened','or file format error in',$
	    list(ev.index)]
	  return
	endif
 
	eqvc, file=list(ev.index)		; Execute equation file.
 
	return
	end
 
;===============================================================
;	eqvlist = Equation file list selection.
;	R. Sterner, 25 Oct, 1993
;===============================================================
 
	pro eqvlist, list
 
	;---------  Set up equation list text  ---------
	n = n_elements(list)			; Number of files in list.
	titles = strarr(n)			; Space for list entries.
	status = intarr(n)			; File status flags: 0=ok.
 
	for i = 0, n-1 do begin			; Loop through given files.
	  file = list(i)			; i'th file name.
	  filebreak,file,dir=dir,name=name,ext=ext  ; Pick apart name.
	  if ext eq '' then ext='eqv'		; Handle default extension.
	  file = dir+name+'.'+ext		; Reassemble.
	  txt = getfile(file,err=err,/quiet)	; Read file.
	  if err ne 0 then begin		; Could not read.
	    tt = 'File not opened: '+name	; List text message.
	    status(i) = 1			; Set status.
	  endif else begin			; Could read file.
	    tt = txtgetkey(init=txt,'title',del=':',/start) ; Get title text.
	    if tt eq '' then tt = 'Title text not found in '+name	; Error.
	  endelse
	  titles(i) = tt
	endfor
 
	;---------  Set up equation selection widget  -----------
	top = widget_base(title='Select Equation to view',/column)
	base = widget_base(top, /row)
	id = widget_button(base,val='QUIT',uval='QUIT')
	id = widget_button(base,val='HELP',uval='HELP')
	id_list = widget_list(top, val=titles, uval='LIST',ysize=10<n)
	widget_control, base, set_uval={list:list, status:status}
	widget_control, top, set_uval=base	; Store base wid in top uval.
	widget_control, top, /real
 
	xmanager, 'eqvlist', top
 
	return
	end
 
 
;===============================================================
;	eqv_event = eqv event handler.
;	R. Sterner, 25 Oct, 1993
;===============================================================
 
	pro eqv_event, ev
 
	widget_control, ev.id, get_uval=name0	; Get name of action.
	widget_control, ev.top, get_uval=d	; Get data structure.
	name = strmid(name0,0,3)		; First 3 chars.
 
        if name eq 'QUI' then begin
          widget_control, /dest, ev.top
          return
        endif
 
	;-------  Handle plot related items  ---------------
	if name eq 'PLT' then begin
	  eqv_plot, d
	  return
	endif
 
	;-------  Handle axis type  -------------
	if name eq 'AXS' then begin
	  act = strmid(name0,3,1)
	  i = strmid(name0,4,1) + 0
	  if i lt 2 then begin
	    case act of
'X':	      d.xtype = i
'Y':	      d.ytype = i
	    endcase
	  endif else begin
	    s = 3-i
	    case act of
'X':	      d.xstyle = s
'Y':	      d.ystyle = s
	    endcase
	  endelse
	  widget_control, ev.top, set_uval=d
	  eqv_stat, d
	  eqv_plot, d
	  return
	endif
 
	;-------  Handle axes plot  ---------------
	if name eq 'AXP' then begin
	  d.pltax = 1-d.pltax		; Toggle state.
          widget_control, ev.top, set_uval=d
	  eqv_plot, d
	  return
	endif
 
	;-------  Handle Iso plot  ---------------
	if name eq 'ISO' then begin
	  d.iso = 1-d.iso		; Toggle state.
          widget_control, ev.top, set_uval=d
	  eqv_plot, d
	  return
	endif
 
	;-------  Handle plot type  --------------
	if name eq 'TYP' then begin
	  act = strmid(name0,3,1) + 0
	  d.ptype = act
          widget_control, ev.top, set_uval=d
	  eqv_stat, d
          eqv_plot, d
	  return
        endif
 
	;-------  Handle plot symbol  --------------
	if name eq 'PSY' then begin
	  act = strmid(name0,3,2) + 0
	  if act gt 10 then act = -act
	  if n_elements(d.x) le 1 then act = -99  ; No scatterplot.
	  d.psym = act
          widget_control, ev.top, set_uval=d
          eqv_plot, d
	  return
        endif
 
	;-------  Handle parameter realted items  ----------
	if name eq 'PAR' then begin
	  act = strmid(name0,3,3)	; Parameter action code.
	  i = strmid(name0,6,2) + 0	; Parameter index.
	  ;-------  Process action code  --------
	  case act of
'SLD':	  begin		;*** Moved slider. ***
	    widget_control, d.id_slid(i), get_val=p		; New pos.
	  end
'MIN':	  begin		;*** Entered new range min. ***
	    widget_control, d.id_pmin(i), get_val=t		; Get ran min.
	    d.pmin(i) = t+0.					; Store.
	    p = sv2p(d.pval(i), d.smax, d.pmin(i), d.pmax(i))	; New pos.
	    widget_control, d.id_slid(i), set_val=p		; Update slider.
	  end
'MAX':	  begin		;*** Entered new range max. ***
	    widget_control, d.id_pmax(i), get_val=t		; Get ran min.
	    d.pmax(i) = t+0.					; Store.
	    p = sv2p(d.pval(i), d.smax, d.pmin(i), d.pmax(i))	; New pos.
	    widget_control, d.id_slid(i), set_val=p		; Update slider.
	  end
'STN':	  begin		;*** Set current value as new range min. ***
	    d.pmin(i) = d.pval(i)	; Update and display new range min.
	    widget_control, d.id_pmin(i), set_val=strtrim(d.pmin(i),2)
	    p = 0
	    widget_control, d.id_slid(i), set_val=p		; Update slider.
	  end
'STX':	  begin		;*** Set current value as new range max. ***
	    d.pmax(i) = d.pval(i)	; Update and display new range max.
	    widget_control, d.id_pmax(i), set_val=strtrim(d.pmax(i),2)
	    p = d.smax
	    widget_control, d.id_slid(i), set_val=p		; Update slider.
	  end
'VAL':	  begin
	    widget_control, d.id_pval(i), get_val=t		; Get ran min.
	    d.pval(i) = t+0.					; Store.
	    p = sv2p(d.pval(i), d.smax, d.pmin(i), d.pmax(i))	; New pos.
	    widget_control, d.id_slid(i), set_val=p		; Update slider.
	    widget_control, ev.top, set_uval=d	  ; Update parameter values.
	    eqv_plot, d				  ; Update plot.
	    return
	  end
'NAM':	  begin
	    widget_control, d.id_pnam(i), get_val=t		; Get par name.
	    d.pname(i) = t					; Replace old.
	    widget_control, ev.top, set_uval=d	  ; Update parameter values.
	    eqv_plot, d				  ; Update plot.
	    return
	  end
	  endcase
	  ;-------  Always: compute new val, display it, store it.
	  v = sp2v(p, d.smax, d.pmin(i), d.pmax(i))		; New val.
	  widget_control,d.id_pval(i),set_val=strtrim(v,2)	; Display..
	  d.pval(i) = v						; Store.
	  widget_control, ev.top, set_uval=d	  ; Update parameter values.
	  eqv_plot, d				  ; Update plot.
	  return
	endif
 
	;------------  Handle snapshot  ------------
	if name eq 'SNA' then begin
	  ;----------  Write eqv file  --------------------
	  openw, lun, d.out, /get_lun
	  user=getenv('USER')
	  user = strupcase(strmid(user,0,1))+strmid(user,1,99)
	  printf, lun, $
	    '*-----  '+d.out+' = snapshot of current status  -------'
	  printf, lun, '*	'+user+', '+systime()
	  printf, lun, ' '
	  printf, lun, 'title: '+d.title
	  printf, lun, ' '
	  widget_control, d.equat, get_val=txt
	  printf, lun, 'eq: '+txt
	  printf, lun, ' '
	  widget_control, d.x1, get_val=txt1
	  widget_control, d.x2, get_val=txt2
	  printf, lun, 'xrange: '+txt1+'  '+txt2
	  widget_control, d.y1, get_val=txt1
	  widget_control, d.y2, get_val=txt2
	  printf, lun, 'yrange: '+txt1+'  '+txt2
	  widget_control, d.t1, get_val=txt1
	  widget_control, d.t2, get_val=txt2
	  printf, lun, 'trange: '+txt1+'  '+txt2
	  widget_control, d.iv, get_val=txt
	  printf, lun, 'independent: '+txt
	  widget_control, d.n, get_val=txt
	  printf, lun, 'n_points: '+txt
	  if d.discuss ne '' then begin
	    txt = 'discussion: '+d.discuss
	    if d.up ne '' then txt = txt+' '+d.up
	    printf, lun, ' '
	    printf, lun, txt
	  endif
	  printf, lun, ' '
	  printf, lun, 'xtype: ',d.xtype
	  printf, lun, 'ytype: ',d.ytype
	  printf, lun, 'ptype: ',d.ptype
	  printf, lun, ' '
	  if d.psym ne -99 then begin		; Scatter plot info.
	    filebreak, d.out, dir=dir, name=fname, ext=ext
	    out2 = dir+fname+'.eqdat'
	    printf, lun, 'psym: ',d.psym
	    printf, lun, 'scatter: '+out2
	  endif
	  widget_control, d.id_ovr, get_val=ovr	; Overlay plot commands.
	  if d.init(0) ne '' then begin
	    for i=0,n_elements(d.init)-1 do begin
	      if d.init(i) ne '' then printf, lun, 'init: '+d.init(i)
	    endfor
	    printf, lun, ' '
	  endif
	  if ovr(0) ne '' then begin
	    for i=0,n_elements(ovr)-1 do begin
	      if ovr(i) ne '' then printf, lun, 'overlay: '+ovr(i)
	    endfor
	    printf, lun, ' '
	  endif
	  printf, lun, 'c_axes:', d.c_axes
	  printf, lun, 'c_back:', d.c_bak
	  for i=0,n_elements(d.c_plt)-1 do begin
	    printf, lun, 'c_plot:', d.c_plt(i)
	  endfor
	  for i=0,n_elements(d.c_ovr)-1 do begin
	    printf, lun, 'c_over:', d.c_ovr(i)
	  endfor
	  printf, lun, 'c_scat:', d.c_sct
	  printf, lun, ' '
	  for i = 0, n_elements(d.pname)-1 do begin
	    printf,lun,'par: ',d.pname(i),' ',d.pmin(i),d.pmax(i),d.pval(i), $
	      string(d.pclr(i),form='(I12)')
	  endfor
	  close, lun
	  free_lun, lun
	  txt = 'Snapshot saved in '+d.out
	  ;-----------   Write scatter plot data   ----------------
	  if d.psym ne -99 then begin		; Save Scatter plot data.
	    openw, lun, out2, /get_lun
	    printf, lun, n_elements(d.x)
	    data = [d.x,d.y]
	    printf, lun, data
	    close, lun
	    free_lun, lun
	    txt = [txt,'and scatter plot data in '+out2]
	  endif
	  xmess,txt
	  return
	endif
 
	;--------  Zoom  ---------------
	if name eq 'ZOO' then begin
	  txt = ['Select plot region to zoom using box.',$
	    ' ','Mouse buttons:','Left: toggles between move and resize mode',$
	    'Middle: Cancel zoom (use alternate exit)',$
	    'Right: exit and zoom selected area.',' ',$
	    'This help text will not be displayed again.']
	  if d.zhelp eq 1 then xhelp,txt, wid=id	; Show help only once.
	  pk, xran=xr, yran=yr, /nomark, code=code
	  if d.zhelp eq 1 then widget_control, /dest, id  ; Kill help.
	  d.zhelp = 0					; No more help.
	  widget_control, ev.top, set_uval=d		; Store no help status.
	  if code eq 2 then return	; Zoom canceled.
	  widget_control, d.x1, set_val=strtrim(xr(0),2)
	  widget_control, d.x2, set_val=strtrim(xr(1),2)
	  widget_control, d.y1, set_val=strtrim(yr(0),2)
	  widget_control, d.y2, set_val=strtrim(yr(1),2)
	  eqv_plot, d
	  return
	endif
 
	;--------  Cursor  ---------------
	if name eq 'CUR' then begin
	  xcursor
	  return
	endif
 
	;--------  Hardcopy  ---------------
	if name eq 'HAR' then begin
	  eqv_plot, d, /hard
	  return
	endif
 
	;-------  Discussion file  -----------
	if name eq 'DIS' then begin
	  f = d.discuss
	  filebreak, f, dir=dir		; If no dir then add root.
	  if dir eq '' then f=filename(d.root,d.discuss,/nosym)
	  txt = getfile(f, err=err, /quiet)
	  if err ne 0 then begin
	    xmess,['Could not open discussion file:',f]
	  endif else begin
	    xhelp, txt,group=ev.top,exit='Quit discussion'
	  endelse
	  return
	endif
 
	;-------- color edit  -------------
	if name eq 'AXH' then begin
	  color_pick,new,d.c_axes,title='Modify axes color',group=ev.top
	  if new ge 0 then d.c_axes=new
          widget_control, ev.top, set_uval=d
          eqv_plot, d
	  return
	endif
	if name eq 'BKH' then begin
	  color_pick,new,d.c_bak,title='Modify background color',group=ev.top
	  if new ge 0 then d.c_bak=new
          widget_control, ev.top, set_uval=d
          eqv_plot, d
	  return
	endif
	if name eq 'PCH' then begin
	  n = n_elements(d.c_plt)
	  if n eq 1 then i=0 else begin
	    men = [strtrim(indgen(n),2),'Cancel']
	    i = xoption(men,col=[d.c_plt,-1],title='Pick plot color to edit:')
	    if i eq n then return
	  endelse
	  color_pick,new,d.c_plt(i),title='Modify plot color',group=ev.top
	  if new ge 0 then d.c_plt(i)=new
          widget_control, ev.top, set_uval=d
          eqv_plot, d
	  return
	endif
	if name eq 'SCH' then begin
	  color_pick,new,d.c_sct,title='Modify scatter plot color',group=ev.top
	  if new ge 0 then d.c_sct=new
          widget_control, ev.top, set_uval=d
          eqv_plot, d
	  return
	endif
	if name eq 'OCH' then begin
	  n = n_elements(d.c_ovr)
	  if n eq 1 then i=0 else begin
	    men = [strtrim(indgen(n),2),'Cancel']
	    i = xoption(men,col=[d.c_ovr,-1],title='Pick overlay color to edit:')
	    if i eq n then return
	  endelse
	  color_pick,new,d.c_ovr(i),title='Modify Overlay color', $
	    group=ev.top
	  if new ge 0 then d.c_ovr(i)=new
          widget_control, ev.top, set_uval=d
          eqv_plot, d
	  return
	endif
 
	;---------  Handle fit related items  -----------
	if name eq 'FIT' then begin
	  act = strmid(name0,3,1)+0
	  case act of
0:	  begin			; No fit.
	    d.fittype = 0
	    if d.fitwid gt 0 then begin		; Kill any fit status display.
	      widget_control, d.fitwid, /dest
	      d.fitwid = -1
	    endif
	  end
1:	  begin			; Chi Sq.
	    if n_elements(d.x) le 1 then return	  ; Must have scatterplot data.
	    d.fittype = 1
	    xbb, lines=['--- Chi Sq ---',' '],res=1,nid=nid,wid=wid,gr=ev.top
	    d.fitwid=wid
	    d.fitgood=nid(0)
	  end
2:	  begin			; Compute both y(x) and y(xs).
	    d.fitflag = 0
	  end
3:	  begin			; Compute just y(xs).
	    d.fitflag = 1
	  end
	  endcase
	  widget_control, ev.top, set_uval=d
	  eqv_plot, d
	  return
	endif
 
 
	;---------  Help  -----------------
        if name eq 'HEL' then begin
	  act = strmid(name0,4,1)	; Help code.
          case act of
'0':	    xhelp,group=ev.top,['Overview and Index',' ',$
		'The Equation Viewing tool, EQV, makes it easy to study',$
		'an equation and see what each parameter in it does.',$
		'Equation parameters may be varied by moving a slider',$
		'bar allowing the effects of hundreds of values to be',$
		'examined in seconds.  The equation itself may be modified',$
		'with the result being instantly displayed.  Plots may be',$
		'displayed with linear or log axes and in polar',$
		'coordinates.  The default equation is a gaussian but',$
		'another equation may be entered as a replacement and',$
		'equations may be read in from equation files.  Changes',$
		'may be saved in a new equation file and the current plot',$
		'may be sent to the printer.  A set of data points may',$
		'optionally be given.  They will be displayed as a',$
		'scatterplot.  They equation and parameter values may',$
		'be adjusted to do a curve fit to these points.',' ',$
		'The Equation Viewing tool has 4 main sections: the',$
		'display panel, the plot control panel, the equation',$
		'display and entry area, and the adjustable parameter',$
		'panel.  More help is available for each of these sections',$
		'and also for the equation file format.',$
		'In the HELP menu see the following:',' ',$
		'   Plot display panel','   Plot control panel',$
		'   Equation display and entry area',$
		'   Adjustable parameters', '   Equation file format',' ',$
		'Calling syntax:',' ',$
		'eqv',$
		'  All arguments are keywords.',$
		'Keywords:',$
		'  FILE=filename  Name of equation file to view.',$
		'  LIST=list  List of equation file names.  If LIST is',$
		'    given then FILE is ignored.',$
		'  X=x, Y=y  Optional arrays of scatterplot points.',$
		'    Useful for interactive curve fitting.',$
		'  PSYM=p  Scatter plot symbol (def=2 (*)).',$
		'  SNAPSHOT=file  name of snapshot file (def=snapshot.eqv).']
'1':        xhelp,group=ev.top,['Plot display panel',' ',$
		'This is the area of EQV that displays the equation',$
		'being examined.  Several items are of interest.',' ',$
		'The plot and axis titles are optional entries in the',$
		'equation file (see Equation file format in the HELP menu).',$
		' ','The character size used for the plot is controlled',$
		'by setting !p.charsize to a new value.  1.5 works well.',' ',$
		'The default plot colors are Mint and Chocolate.',$
		'The plot colors may be adjusted using the Colors button.']
'2':	    xhelp,group=ev.top,['Plot control panel',' ',$
		'This panel consists of buttons and text entry fields',$
		'at the upper right region of the equation viewer widget.',$
		'These items are related to the overall plot.  This panel',$
		'has 5 main areas, from the top down they are:',$
		'  Action buttons',$
		'  Plot and axis type status line',$
		'  Pull-down menus',$
		'  Plot limits',$
		'  Independent variable setup',' ',$
		'  Action buttons',$
		'    Quit: exit EQV.',$
		'    Zoom: gives an interactive box which is used to select',$
		'      an area of the plot to zoom.',$
		'    Cursor: displays position of a cursor in the plot area.',$
		'    Snapshot: save the current eqv status in an equation',$
		'      file.  The name of this file may be set when starting',$
		'      eqv using the keyword snapshot=filename.  The default',$
		'      is snapshot.eqv and snapshot.edat for any scatter',$
		'      plot data.',$
		'    Hardcopy: send the current plot to a PostScript printer',$
		'      and list the equation and parameter values.',$
		'    Discussion: appears only if the discussion entry is',$
		'      specified in the equation file (see Equation file',$
		'      format).  When pressed this button displays the',$
		'      contents of the discussion text file specified.',' ',$
		'  Pull-down menus',$
		'    Help: allows selection from a number of help topics.',$
		'    X Axis: select Linear or Log X axis, exact or extended.',$
		'    Y Axis: select Linear or Log Y axis, exact or extended.',$
		'    Plot Type: select XY or Polar plot type.',$
		'    Colors: allows plot, background, and scatter plot colors',$
		'      to be modified using the HSV or RGB color systems.',$
		'    Plot Symbol: allows plot symbol change.',$
		'    Fit: if scatter plot data has been specified this button',$
		'      activates the display of goodness of fit values.',$
		'      May compute both Y(X), the full curve, or just Y(XS),',$
		'      Y of the scatter plot X values (faster).  If you pick',$
		'      the latter option the scatter plot data should have',$
		'      been sorted in X.',$
		'      Currently the fit only works for Y=f(X), not',$
		'      parametric equations.',' ',$
		'  Plot and axis type status line',$
		'    This line gives the plot type (XY or Polar) and',$
		'    axis types (Linear or Log).',' ',$
		'  Plot limits',$
		'    May enter values for the four plot limits: min x, max x,',$
		'      min y, max y.  Press RETURN (ENTER) for the new value',$
		'      to take effect.  May use expressions.',' ',$
		'  Independent variable setup',$
		'    There are four values related to the independent',$
		'    variable: Variable name, Min value, Max value, and',$
		'    Number of points spaced between the min and max values.',$
		'    All these values may be changed by entering new values',$
		'    and pressing RETURN (ENTER).  May use expressions.']
'3':	    xhelp,group=ev.top,['Equation display and entry area',' ',$
		'The current equation is shown below the plot display and',$
		'plot control panels.  The equation may be modified just by',$
		'deleting or typing text in this area.  Press RETURN (ENTER)',$
		'to see the results of the change.  Several items to note:',$
		' ','The independent variable in the equation must be the',$
		'same as named in the plot control panel or an error will',$
		'occur.  The default independent variable is x.',' ',$
		'For polar plots, x is the angle in radians, and y is the',$
		'radius.  This is stated in the plot status line.',' ',$
		'Parametric equations may be plotted as follows:',$
		'Define the independent variable in the plot control',$
		'panel to be something like t.  Then in the equation area',$
		'enter the two parametric equations for x and y separated',$
		'by &.  For example: x=a*sin(b*t) & y=c*cos(d*t)',$
		'The range and resolution of parameter t is set in the',$
		'independent variable area of the plot control panel.',' ',$
		'The variable names used in the equation may be changed.',$
		'To do so, change one parameter in the equation, but DO',$
		'NOT press RETURN after.  Then make the same name change',$
		'in the parameter control panel and press RETURN.  Repeat',$
		'for each parameter.',' ',$
		'Note: there are 3 special values made available:',$
		'  _t1 = minimum of independent variable.',$
		'  _t2 = maximum of independent variable.',$
		'  _dt = range of independent variable.',$
		'These may be used in the equation if desired.']
'4':	    xhelp,group=ev.top,['Adjustable parameters',' ',$
		'Below the equation display area is the adjustable',$
		'parameter control panel.  Each adjustable parameter in',$
		'the equation has a set of labeled text entry fields,',$
		'two buttons, and a slider bar.  These are discussed below.',$
		' ','Parameter name: The left-most text entry field for each',$
		'    parameter.  See note on name changing unde the equation',$
		'    display help.',$
		' ','Parameter value field: The text entry field to the right',$
		'    of the parameter name.  It displays the current value of',$
		'    the parameter.  It will be updated as the slider bar',$
		'    is moved.  If a new value is entered, press RETURN.',' ',$
		'Parameter range fields: these give the min and max values',$
		'    for the slider bar.  These values may be changed by',$
		'    typing new values and pressing RETURN (ENTER).',' ',$
		'Range Min and Max buttons: these set the range min or',$
		'   max to the current parameter value.  They make it easy',$
		'   decrease the range for finer control.  To increase the',$
		'   range new values must be typed in the fields.',' ',$
		'Slider bar: the mouse is used to move the slider bar',$
		'    pointer to change the value of the corresponding',$
		'    adjustable parameter.',' ',$
		'Note: there may be extra parameters unused in the equation.',$
		'These may be used to add new adjustable parameters.']
'5':	    xhelp,group=ev.top,['Equation file format',' ',$
		'The equation viewer, eqv, may be given an initialization',$
		'file called an equation file.  The calling syntax is:',$
		'  eqv, file=name','where the default extension is .eqv,',$
		'like gaussian.eqv.  So eqv,file="gaussian" is ok.',' ',$
		'Equation files set up an equation, parameter values,',$
		'plot limits, and so on.',' ',$
		'Equation files contain 3 types of lines: command lines,',$
		'null lines, and keyword/value lines.  Comment lines have',$
		'* in line 1.  Null lines have no text.  Keyword/value',$
		'lines have a keyword starting in column 1.  The keyword',$
		'is followed by a colon (:).  The value is on the rest of',$
		'line.  Only equation lines may be continued.',' ',$
		'Example equation file:',' ',$
		'*---------  gaussian.equ = Gaussian curve  -----------',$
		'*	R. Sterner, 25 Oct, 1993',$
		' ',$
		'title: Gaussian Curve',$
		'eq: y = amp*exp(-(x-mu)^2/sigma)',$
		'xrange: -10, 10',$
		'yrange: 0, 10',$
		'n_points: 100',$
		'par: amp -10 10 8',$
		'par: mu -10 10 0',$
		'par: sigma 0 100 6',' ',$
		'All the recognized keywords are listed below in example',$
		'lines with a discussion on the next line(s).',' ',$
		'title: Polar Curve # 2.',$
		'    The plot title.  It is also used for the list text',$
		'    if eqv is called with the LIST keyword.',$
		'eq:   y = a*sin(x/b)',$
		'    The initial equation.  It may be continued by',$
		'    ending lines with a $.',$
		'xtitle: Position (km)',$
		'    X axis title.  Optional.',$
		'ytitle: Temperature (deg C)',$
		'    Y axis title.  Optional.',$
		'xrange: 0  0',$
		'    The plot X range min and max.  If both 0, as here, then',$
		'    autoscaling is done.  Keyword required.',$
		'yrange: 0  0',$
		'    The plot Y range min and max.  If both 0, as here, then',$
		'    autoscaling is done.  Keyword required.',$
		'trange: 0  150',$
		'    The independent variable range.  Defaults to xrange.',$
		'n_points: 1000',$
		'    Number of points in the independent variable range.',$
		'    Defaults to 100.',$
		'xtype: 0',$
		'    X axis type: 0=linear (default), 1=log.',$
		'ytype: 1',$
		'    Y axis type: 0=linear (default), 1=log.',$
		'ptype: 1',$
		'    Plot type: 0=XY (default), 1=Polar.',$
		'independent: t',$
		'    Name of independent variable.  Defaults to x.',$
		'par: ax       1.00000      10.0000      3.12625',$
		'par: ay       1.00000      10.0000      3.68875',$
		'    Adjustable parameter definition line.  Must have 4',$
		'    items: parameter name, slider bar min, slider bar max,',$
		'    starting value.  There is one par line for each',$
		'    adjustable parameter in the equation.  Extra par',$
		'    lines may be used to define potiential new parameters.',$
		'scatter: g_scatter.txt',$
		'    Name of file containing scatter plot data.  This must',$
		'    be a text with number of points in line 1 and XY pairs',$
		'    on following lines.  Example (first 3 lines):',$
		'      20',$
		'      7.53239     0.807365',$
		'     -3.05645   0.00850357',$
		'psym: 4',$
		'    Plot symbol for scatter plot.  Default is 2.',$
		'discussion: lissajous.dsc',$
		'    Name of a text file to display that discusses the',$
		'    current equation.  It is displayed in a scrolling',$
		'    window and could be used to suggest experiments with',$
		'    the equation.',$
		'snapshot: tmp.tmp',$
		'    Name of an equation file to create when the snapshot',$
		'    button is pressed.  The default is snapshot.eqv.  Any',$
		'    scatterplot data is saved in a file with the same name',$
		'    but extension .eqdat.']
	  endcase
          return
        endif
 
	end
 
;===============================================================
;	eqvc.pro = Equation viewer
;	R. Sterner, 25 Oct, 1993
;	R. Sterner, 2002 Oct 06 --- Converted to cw_dslider
;	R. Sterner, 2002 Oct 13 --- Made compact version.
;===============================================================
 
	pro eqvc, file=file, list=list, xs=xs, ys=ys, psym=psym, $
	  snapshot=out, help=hlp, title=title0, xtitle=xtitle0, $
	  ytitle=ytitle0, window=win, root=root
 
	if keyword_set(hlp) then begin
	  print,' Interactive equation viewer and curve fitter.'
	  print,' eqvc'
	  print,'   All arguments are keywords.'
	  print,' Keywords:'
	  print,'   FILE=filename  Name of equation file to view.'
	  print,'   LIST=list  List of equation file names.  If LIST is'
	  print,'     given then FILE is ignored.'
	  print,'   XS=x, YS=y  Optional arrays of scatterplot points.'
	  print,'     Useful for interactive curve fitting.'
	  print,'   PSYM=p  Scatter plot symbol (def=2 (*)).'
	  print,'   SNAPSHOT=file  name of snapshot file (def=snapshot.eqv).'
	  print,'   TITLE=tt  plot title (over-rides value from eqv file).'
	  print,'   XTITLE=tx  X axis title (over-rides value from eqv file).'
	  print,'   YTITLE=ty  Y axis title (over-rides value from eqv file).'
	  print,'   WINDOW=[nx,ny] array with window x & y size (def=[450,450])'
	  print,'   ROOT=dir Root directory for finding files (equation files,'
	  print,'     discussion files, snapshot files).'
	  return
	endif
 
	;-------  Init graphics  -------------------------
	if !d.n_colors eq 256 then begin
	  window,/free,/pixmap,xs=50,ys=50
	  erase
	  wdelete
	endif
 
	;-------  Handle equation file list  -------------
	if n_elements(list) ne 0 then begin
	  eqvlist, list
	  return
	endif
 
	;--------  Handle equation file or set defaults  -------
	if n_elements(out) eq 0 then out = 'snapshot.eqv'
	xstyle = 1	; Start with exact axes.
	ystyle = 1
	fittype = 0	; No goodness of fit display.
	fitflag = 0	; Do both y(x) and y(xs) for fit.
	;-------  No equation file  ------------
	if n_elements(file) eq 0 then begin
	  file = 'Default equation'
	  title = 'Gaussian Curve'
	  xran = [-10,10]
	  yran = [0,10]
	  tran = xran
	  num = 100
	  xtype = 0
	  ytype = 0
	  ptype = 0
	  xtitle = ''
	  ytitle = ''
	  indv = 'x'
	  discuss = ''
	  up = ''
	  init = ''
	  ovr = ''
	  eqt = 'y = amp*exp(-((x-mu)/sigma)^2)'
	  par = {n:7, name:['amp','mu','sigma','a','b','c','d'], $
	    min:[0.,-10,0,-10,-10,-10,-10], $
	    max:[10.,10,10,10,10,10,10], $
	    def:[8.,0,6,0,0,0,0], $
	    clr:[[0L,0L,0L]+12648375L,[0L,0L,0L,0L]+12632256L]}
	  if n_elements(root) eq 0 then root=''
	  c_axes = 0L
	  c_bak = tarclr(255,255,255)
	  c_sct = 0L
	  c_plt = [16711936L,255L,52480L,16744062L,7303167L]
	  c_ovr = [6931711L,63743L,14287103L,11272061L]
	;-------  Equation file given  -----------
	endif else begin
	  if n_elements(root) eq 0 then begin
	    filebreak, file, dir=root
	  endif
	  eqv_compile, file, title=title, xrange=xran, yrange=yran, $
	    par=par, equat=eqt, number=num, xtype=xtype, ytype=ytype, $
	    ptype=ptype, xs=xsf, ys=ysf, psym=psymf, trange=tran, $
	    out=outf, xtitle=xtitle, ytitle=ytitle, indv=indv, $
	    discuss=discuss, up=up, overlay=ovr, c_plt=c_plt, c_sct=c_sct, $
	    c_ovr=c_ovr, c_axes=c_axes, c_bak=c_bak, $
	    init=init, err=err
	  if err ne 0 then return
	  if n_elements(out) eq 0 then out=outf
	  if n_elements(xs) eq 0 then xs=xsf
	  if n_elements(ys) eq 0 then ys=ysf
	  if n_elements(psym) eq 0 then psym=psymf
	endelse
	if n_elements(title0) ne 0 then title=title0	; Use given titles.
	if n_elements(xtitle0) ne 0 then xtitle=xtitle0
	if n_elements(ytitle0) ne 0 then ytitle=ytitle0
 
	;-------  Handle scatter plot parameters  ----------
	if n_elements(xs) le 1 then begin	; No scatter plot.
	  xs = [0]
	  ys = [0]
	  psym = -99
	endif else begin			; Have scatter plot.
	  if n_elements(psym) eq 0 then psym = -99
	  if psym eq -99 then psym = 2
	endelse
 
	;--------  Set up equation viewer widget  ----------
	if n_elements(win) ne 2 then win=[450,450]
;	smax = 800
	smax = 300
	top = widget_base(/column, title=title)
	  base = widget_base(top,/row)
	    id_draw = widget_draw(base, xsize=win(0), ysize=win(1))
	    right = widget_base(base,/column)
	      ;--------  Buttons and menu buttons  -------------
	      but = widget_base(right, /row)
	        b = widget_button(but, val='Quit',uval='QUIT')
	        b = widget_button(but, val='Zoom',uval='ZOOM')
	        b = widget_button(but, val='Cursor',uval='CURS')
	        b = widget_button(but, val='Snapshot',uval='SNAP')
	        b = widget_button(but, val='Hardcopy',uval='HARD')
	        if discuss ne '' then $
		  b = widget_button(but, val='Discussion',uval='DISC')
	        b = widget_button(but, val='Help',menu=2)
	          b2 = widget_button(b,val='Overview and Index',uval='HELP0')
	          b2 = widget_button(b,val='Plot display panel',uval='HELP1')
	          b2 = widget_button(b,val='Plot control panel',uval='HELP2')
	          b2 = widget_button(b,val='Equation display and entry area',$
		    uval='HELP3')
	      but = widget_base(right, /row)
	          b2 = widget_button(b,val='Adjustable parameters',uval='HELP4')
	          b2 = widget_button(b,val='Equation file format',uval='HELP5')
	        b = widget_button(but, val='X Axis',menu=2)
		  b2 = widget_button(b, val='Linear',uval='AXSX0')
		  b2 = widget_button(b, val='Log',uval='AXSX1')
		  b2 = widget_button(b, val='Exact',uval='AXSX2')
		  b2 = widget_button(b, val='Extend',uval='AXSX3')
	        b = widget_button(but, val='Y Axis',menu=2)
		  b2 = widget_button(b, val='Linear',uval='AXSY0')
		  b2 = widget_button(b, val='Log',uval='AXSY1')
		  b2 = widget_button(b, val='Exact',uval='AXSY2')
		  b2 = widget_button(b, val='Extend',uval='AXSY3')
	        b = widget_button(but, val='Plot Type',menu=2)
		  b2 = widget_button(b, val='XY',uval='TYP0')
		  b2 = widget_button(b, val='Polar',uval='TYP1')
	        b = widget_button(but, val='Colors',menu=2)
		  b2 = widget_button(b, Val='Modify axes color',uval='AXH')
		  b2 = widget_button(b,Val='Modify background color',uval='BKH')
		  b2 = widget_button(b, Val='Modify plot color', uval='PCH')
		  b2 = widget_button(b,Val='Modify scatter plot color',$
		    uval='SCH')
		  b2 = widget_button(b,Val='Modify overlay plot color',$
		    uval='OCH')
	        b = widget_button(but, val='Plot Symbol',menu=2)
		  b2 = widget_button(b, Val='  No scatter plot', uval='PSY99')
		  b2 = widget_button(b, Val='0 Connect points', uval='PSY0')
		  b2 = widget_button(b, Val='1 Plus sign (+)', uval='PSY1')
		  b2 = widget_button(b, Val='2 Asterisk (*)', uval='PSY2')
		  b2 = widget_button(b, Val='3 Period (.)', uval='PSY3')
		  b2 = widget_button(b, Val='4 Diamond', uval='PSY4')
		  b2 = widget_button(b, Val='5 Triangle', uval='PSY5')
		  b2 = widget_button(b, Val='6 Square', uval='PSY6')
		  b2 = widget_button(b, Val='7 X', uval='PSY7')
		  b2 = widget_button(b, Val='8 User-defined', uval='PSY8')
	        b = widget_button(but, val='Fit',menu=2)
		  b2 = widget_button(b,val='No Fit',uval='FIT0')
		  b2 = widget_button(b,val='Chi Sq',uval='FIT1')
		  b2 = widget_button(b,val='Compute both Y(X) and Y(XS)',$
		    uval='FIT2')
		  b2 = widget_button(b,val='Compute just Y(XS)',uval='FIT3')
	      id_stat = widget_label(right,value=' ',/dynamic)
	      ;--------  Plot limits area  ------------------
	      rn = widget_base(right, /col)
		b = widget_base(rn,/row)
		id = widget_label(b,val='Plot X Min: ')
		id_x1 = widget_text(b,val=strtrim(xran(0),2),/edit,$
		  xsize=10, uval='PLT')
		id = widget_label(b,val=' X Max: ')
		id_x2 = widget_text(b,val=strtrim(xran(1),2),/edit,$
		  xsize=10, uval='PLT')
	      rn = widget_base(right, /col)
		b = widget_base(rn,/row)
		id = widget_label(b,val='Plot Y Min: ')
		id_y1 = widget_text(b,val=strtrim(yran(0),2),/edit,$
		  xsize=10, uval='PLT')
		id = widget_label(b,val=' Y Max: ')
		id_y2 = widget_text(b,val=strtrim(yran(1),2),/edit,$
		  xsize=10, uval='PLT')
	      rn = widget_base(right, /col)
		b = widget_base(rn,/row)
		id = widget_label(b,val='Independent Variable: ')
		id_iv = widget_text(b,val=indv, /edit,xsize=10,uval='PLT')
		id = widget_label(b,val='Min: ')
		id_t1 = widget_text(b,val=strtrim(tran(0),2),/edit,$
		  xsize=10, uval='PLT')
		id = widget_label(b,val='Max: ')
		id_t2 = widget_text(b,val=strtrim(tran(1),2),/edit,$
		  xsize=10, uval='PLT')
	      rn = widget_base(right, /row)
		id = widget_label(rn,val='Number of points: ')
		id_n = widget_text(rn,val=strtrim(num,2),/edit,$
		  xsize=10, uval='PLT')
		b = widget_base(rn,/nonexclusive,/row)
		  id = widget_button(b, val='Plot axes?',uval='AXP')
		  id = widget_button(b, val='Iso?',uval='ISO')
	      rn = widget_base(right, /col)
	      id = widget_label(rn,val='Overlay Plot Commands')
	      id_ovr = widget_text(rn, val=ovr, xsize=60,ysize=8, $
		/scroll,/edit,uval='PLT')
	    ;--------  Equation area  --------------------------------
	    id_eq = widget_text(top,val=eqt,xsize=60,ysize=1,/edit,uval='PLT')
	    ;--------  Set up parameter related items  ---------------
	    id_slid   = lonarr(par.n)	; Parameter slider related wids.
	    id_parnam = strarr(par.n)
	    id_parval = lonarr(par.n)
	    id_parmin = lonarr(par.n)
	    id_parmax = lonarr(par.n)
	    ;--------  Set up all parameters  ------------------------
	    bot = widget_base(top,/column,y_scroll=200)
	    for i = 0, par.n-1 do begin		; Loop through parameters.
	      b = widget_base(bot,/row)
	      id = widget_text(b,val=par.name(i),xsize=8, /edit, $
		   uval='PARNAM'+strtrim(i,2))
	        id_parnam(i) = id
	      s = cw_dslider(b,uval='PARSLD'+strtrim(i,2),size=smax+1,$
		   max=smax,color=par.clr(i))
	        id_slid(i) = s
	      id = widget_text(b,val=strtrim(par.def(i),2),xsize=10,/edit,$
		   uval='PARVAL'+strtrim(i,2))
	        id_parval(i) = id
	      id = widget_label(b,val='Range:')
	      id = widget_text(b,val=strtrim(par.min(i),2),/edit,$
		   uval='PARMIN'+strtrim(i,2),xsize=10)
	        id_parmin(i) = id
	      id = widget_label(b,val='to')
	      id = widget_text(b,val=strtrim(par.max(i),2),/edit,$
		   uval='PARMAX'+strtrim(i,2),xsize=10)
	        id_parmax(i) = id
	      id = widget_button(b,val='Min',uval='PARSTN'+strtrim(i,2))
	      id = widget_button(b,val='Max',uval='PARSTX'+strtrim(i,2))
	    endfor
 
	;-------  Display widget and update plot  -------
	for i=0, par.n-1 do begin	; Set parameter slider starting points.
	  widget_control, id_slid(i),set_val=$
	    sv2p(par.def(i),smax,par.min(i),par.max(i))
	endfor
 
	widget_control, top, /real
 
	widget_control, id_draw, get_val=draw_win
	wset, draw_win
 
	;-----  Package and store needed global values  --------
	data = {x1:id_x1, x2:id_x2, y1:id_y1, y2:id_y2, n:id_n, $
	  equat:id_eq, win:draw_win, id_slid:[id_slid], id_pval:[id_parval], $
	  id_pmin:[id_parmin], id_pmax:[id_parmax], x:xs, y:ys, psym:psym, $
	  id_pnam:[id_parnam], pclr:[par.clr], $
	  pname:[par.name], pval:[par.def], pmin:[par.min], pmax:[par.max], $
	  smax:smax, xtype:xtype, ytype:ytype, ptype:ptype, title:title, $
	  xstyle:xstyle, ystyle:ystyle, pltax:0, iso:0, $
	  t1:id_t1, t2:id_t2, out:out, xtitle:xtitle, ytitle:ytitle, $
	  fittype:fittype, fitflag:fitflag, fitwid:-1, fitgood:-1, $
	  stat:id_stat, iv:id_iv, zhelp:1, file:file, discuss:discuss, $
	  up:up, c_bak:c_bak, c_plt:c_plt, c_ovr:c_ovr, c_sct:c_sct, $
	  c_axes:c_axes, id_ovr:id_ovr, root:root, init:init }
	widget_control, top, set_uval=data
	eqv_stat, data
 
	;------  Start plot  ----------
	tmp = check_math(1,1)
	eqv_plot, data
 
	;-------  Discussion file?  ---------
	if (up ne '') and (discuss ne '') then begin
	  f = discuss
	  filebreak, f, dir=dir		; If no dir then add root.
	  if dir eq '' then f=filename(root,discuss,/nosym)
	  txt = getfile(f, err=err, /quiet)
	  if err ne 0 then begin
	    xmess,['Could not open discussion file:',f]
	  endif else begin
	    xhelp, txt,group=top,exit='Quit discussion'
	  endelse
	endif
 
	;-------  xmanager  -------
	xmanager, 'eqv', top
 
	tmp = check_math(0,0)
 
	return
 
	end
