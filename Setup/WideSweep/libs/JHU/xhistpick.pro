;-------------------------------------------------------------
;+
; NAME:
;       XHISTPICK
; PURPOSE:
;       Widget routine to select image scaling based on a histogram.
; CATEGORY:
; CALLING SEQUENCE:
;       xhistpick, xx, hh
; INPUTS:
;       xx = Histogram bin positions.  in
;       hh = Histogram counts.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         MIN=mn  Returned selected lower image value cutoff.
;         MAX=mx  Returned selected upper image value cutoff.
;           If defined these values will also be used as initial
;           values of the cutoffs.
;         TITLE=txt  Title text string or array.
;         ERROR=err  Error flag: 0=OK, 1=CANCEL
;         CLIP=n  Clip max histogram count to the n'th below the
;           highest count.  Good for ignoring spikes in histogram.
;           /clip may work well, or try clip=2 or 3.
;         IMAGE=img  Image to display (def=none).  If given, this
;           image will be displayed in the specified window with
;           the currently selected scaling limits.
;         WINDOW=win  Window for image display (def=0).  Only
;           needed if an image is given.
;         /ON_FREEZE redisplay image every time a limit is frozen
;           in a new position.  Else a Redisplay button appears.
;         /WAIT  means wait for returned result.
;        GROUP_LEADER=grp  specified group leader.  When the
;          group leader widget is destroyed this widget is also.
;        Any valid PLOT keywords will be passed on to PLOT.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Histogram and bin position array may be made using
;         hist.  Ex:   hh=hist(img,xx)
;                      xhistpick,xx,hh,image=img
;         Try xx(2:0),hh(2:*) to drop a large count of image zeros
;         and the bottom added bin.  See h=hist(/help)).
;         Image may be floating.
; MODIFICATION HISTORY:
;       R. Sterner, 7 Dec, 1993
;       R. Sterner, 13 Dec, 1993 --- Added clip and _extra.
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xhistpick_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=d
 
	if uval eq 'OK' then begin
	  if d.freeze lt 0 then begin
	    widget_control, d.imgb, get_uval=img
	    wset, d.win
	    tvscl,img>d.v(0)<d.v(1)
	    return
	  endif
	  widget_control, ev.top, /dest
	  widget_control, d.res, set_uval={flag:0, v:d.v}
	  return
	endif
 
	if uval eq 'CANCEL' then begin
	  widget_control, ev.top, /dest
	  widget_control, d.res, set_uval={flag:1, v:d.v}
	  return
	endif
 
	if uval eq 'DRAW' then begin
	  wset, d.draw
	  t = convert_coord(ev.x,ev.y,0,/dev,/to_data)  ; Find position. 
	  x = t(0)
	  if d.status(0) eq 1 then begin	; Minimum active.
	    d.status(1) = 0			; Make sure Max is off.
	    x = x<(d.v(1)-d.xq)>!x.crange(0)	; Force left of max-xq.
	    vline, /data, x, num=0
	    d.v(0) = x
	    widget_control, d.tmn, set_val=strtrim(x,2)
	  endif
	  if d.status(1) eq 1 then begin	; Maximum active.
	    d.status(0) = 0			; Make sure Min is off.
	    x = x>(d.v(0)+d.xq)<!x.crange(1)	; Force right of min+xq.
	    vline, /data, x, num=1
	    d.v(1) = x
	    widget_control, d.tmx, set_val=strtrim(x,2)
	  endif
	  if ev.press eq 1 then begin		; Process a button down event.
	    ds = abs(d.v-x)			; Find closest line.
	    w = where(ds eq min(ds)) & w=w(0)
	    d.status(w) = 1-d.status(w)		; Toggle status of button w.
	    ;------  Display image on freeze  --------
	    if (d.freeze eq 1) and (max(d.status) eq 0) then begin
	      widget_control, d.imgb, get_uval=img
	      wset, d.win
	      tvscl,img>d.v(0)<d.v(1)
	    endif
	  endif
	  widget_control, ev.top, set_uval=d
	  return
	endif
 
	return
	end
 
;=======================================================================
;	xhistpick.pro = Widget Histogram based scaling selctor
;	R. Sterner, 7 Dec, 1993
;=======================================================================
 
	pro xhistpick, xx, hh, min=xmin, max=xmax, title=title, $
	  error=err, image=img, window=win, on_freeze=frz, $
	  group_leader=grp, wait=wait, clip=clip, _extra=extra, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Widget routine to select image scaling based on a histogram.'
	  print,' xhistpick, xx, hh'
	  print,'   xx = Histogram bin positions.  in'
	  print,'   hh = Histogram counts.         in'
	  print,' Keywords:'
	  print,'   MIN=mn  Returned selected lower image value cutoff.'
	  print,'   MAX=mx  Returned selected upper image value cutoff.'
	  print,'     If defined these values will also be used as initial'
	  print,'     values of the cutoffs.'
	  print,'   TITLE=txt  Title text string or array.'
	  print,'   ERROR=err  Error flag: 0=OK, 1=CANCEL'
	  print,"   CLIP=n  Clip max histogram count to the n'th below the"
	  print,'     highest count.  Good for ignoring spikes in histogram.'
	  print,'     /clip may work well, or try clip=2 or 3.'
	  print,'   IMAGE=img  Image to display (def=none).  If given, this'
	  print,'     image will be displayed in the specified window with'
	  print,'     the currently selected scaling limits.'
	  print,'   WINDOW=win  Window for image display (def=0).  Only'
	  print,'     needed if an image is given.'
	  print,'   /ON_FREEZE redisplay image every time a limit is frozen'
	  print,'     in a new position.  Else a Redisplay button appears.'
          print,'   /WAIT  means wait for returned result.'
          print,'  GROUP_LEADER=grp  specified group leader.  When the'
          print,'    group leader widget is destroyed this widget is also.'
	  print,'  Any valid PLOT keywords will be passed on to PLOT.'
	  print,' Notes: Histogram and bin position array may be made using'
	  print,'   hist.  Ex:   hh=hist(img,xx)'
	  print,'                xhistpick,xx,hh,image=img'
	  print,'   Try xx(2:0),hh(2:*) to drop a large count of image zeros'
	  print,'   and the bottom added bin.  See h=hist(/help)).'
	  print,'   Image may be floating.'
	  return
	endif
 
	;--------  Set defaults  ------------
	if n_elements(xmin) eq 0 then xmin = min(xx)
	if n_elements(xmax) eq 0 then xmax = max(xx)
	if n_elements(title) eq 0 then begin
	  title = ['Use histogram to select image scaling.',$
		'To move lower or upper scaling, use mouse',$
		'to move the corresponding vertical line.',$
		'To activate a line click a mouse button near it.',$
		'To freeze it click same button again.']
	endif
	if n_elements(win) eq 0 then win = 0
	if n_elements(img) eq 0 then img = 0
	if n_elements(img) gt 1 then freeze = -1
	if keyword_set(frz) then freeze = 1
	if n_elements(img) eq 1 then freeze = 0
 
	;---------  Layout widget  -------------
	top = widget_base(/column,title=' ')
        if n_elements(grp) then widget_control, top, group=grp
	drw = widget_draw(top,xsize=100,ysize=200,/butt,/motion,uval='DRAW')
	ny = n_elements(title)
	nx = max(strlen(title))
	id = widget_text(top,xsize=nx,ysize=ny,val=title)
	imgb = widget_base(top,/row)
	id = widget_label(imgb,val='Min')
	tmn = widget_text(imgb,val=strtrim(xmin,2),uval='TMIN')
	id = widget_label(imgb,val='Max')
	tmx = widget_text(imgb,val=strtrim(xmax,2),uval='TMAX')
	b = widget_base(top,/row)
	case freeze of
0:	begin	;--- No image display.
	  id = widget_button(b,val='OK',uval='OK')
	  id = widget_button(b,val='CANCEL',uval='CANCEL')
	end
1:	begin	;--- Display image on limit freeze.
	  id = widget_button(b,val='EXIT',uval='CANCEL')
	end
-1:	begin	;--- Display image on Redisplay button.
	  id = widget_button(b,val='Redisplay',uval='OK')
	  id = widget_button(b,val='EXIT',uval='CANCEL')
	end
	endcase
 
	;-------  Activate and initialize  --------
	if freeze ne 0 then begin
	  wset, win
	  tvscl, img>xmin<xmax
	endif
	widget_control, top, /real
	widget_control, drw, get_val=drw_win
	wset, drw_win
	hclip = max(hh)
	if n_elements(clip) ne 0 then begin
	  s = reverse(sort(hh))
	  hclip = hh(s(clip))
	endif
	plot,xx,hh<hclip,psym=10,_extra=extra
	r = convert_coord([0,1],[0,1],[0,0],/dev,/to_data)
	xq = r(0,1)-r(0,0)
	vline, xmin, num=0, /data
	vline, xmax, num=1, /data
 
	;------  Pack require info  ---------
	res = widget_base()		; Unused top level base for results.
	data = {status:[0,0], v:[xmin,xmax], tmn:tmn, tmx:tmx, xq:xq, $
	  draw:drw_win, win:win, freeze:freeze, imgb:imgb, res:res}
	widget_control, top, set_uval=data
	widget_control, imgb, set_uval=img	; Store image.
 
	;-------  Register  ------------------------
        if n_elements(wait) eq 0 then wait = 0
	xmanager, 'xhistpick', top, modal=wait
 
	;-------  Get returned values  -------------
	widget_control, res, get_uval=r
	err = r.flag
	xmin = r.v(0)
	xmax = r.v(1)
 
	return
	end
