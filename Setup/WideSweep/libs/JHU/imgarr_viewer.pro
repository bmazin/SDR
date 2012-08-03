;-------------------------------------------------------------
;+
; NAME:
;       IMGARR_VIEWER
; PURPOSE:
;       View an array of images.
; CATEGORY:
; CALLING SEQUENCE:
;       imgarr_viewer, imgarr
; INPUTS:
;       imgarr = an array of images.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /ORDER display order.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: imgarr is a 3-d array, like (512,512,25).
;       Images need not be byte and need not be scaled 0 to 255.
;       Scaling option may be changed.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Oct 03
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro imgarr_viewer_disp, img, s
 
	case s.sc_flag of
0:	begin	; Specified min/max.
	  if (s.amn eq 0) and (s.amx eq 0) then begin
	    amn = min(img,max=amx)
	  endif else begin
	    amn = s.amn
	    amx = s.amx
	  endelse
	  tv,scalearray(img,amn,amx)>0<255, order=s.order
	end
1:	begin	; Image min/max.
	  amn = min(img,max=amx)
	  tv,scalearray(img,amn,amx)>0<255, order=s.order
	end
2:	begin	; Percentiles.
	  tv, ls(img,s.alo,s.ahi,/quiet), order=s.order
	end
	endcase
 
	end
 
 
	;======================================================
	;  imgarr_viewer_event
	;======================================================
 
	pro  imgarr_viewer_event, ev
 
	widget_control, ev.top, get_uval=s
 
	if tag_names(ev,/struct) eq 'WIDGET_TIMER' then begin
	  if s.mvflag eq 0 then return		; Check if stopped.
	  in = (s.indx + 1) mod s.num		; Step to next image index.
	  if in eq 0 then wait,s.ps		; Pause a bit before first.
	  widget_control, s.id_slid, set_val=in	; Show image number on slider.
	  wset, s.win				; Set to display window.
	  imgarr_viewer_disp,s.stk(*,*,in), s	; Display image.
	  if s.mvflag eq 1 then $		; Set next timer event.
	    widget_control,s.twid,timer=s.wt
	  s.indx = in				; Remember new index.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	widget_control, ev.id, get_uval=uval	; Grab event name from uval.
 
	if uval eq 'STOP' then begin
	  s.mvflag = 0				; Set movie flag to off.
	  widget_control, s.id_slid, sens=1	; Ungray slider.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq 'GO' then begin
	  s.mvflag = 1				; Set movie flag to on.
	  widget_control, s.id_slid, sens=0	; Gray  slider.
	  widget_control, s.twid, timer=s.wt	; Set a new timer event.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq 'SLID' then begin
	  widget_control, s.id_slid, get_val=in	; Grab slider value
	  s.indx = in				; which is new image index.
	  wset, s.win				; Set to display window and
	  imgarr_viewer_disp,s.stk(*,*,in), s	; ; Display image.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq '<' then begin
	  in = (s.indx-1)>0			; Decrement index.
	  s.indx = in				; Save.
	  widget_control,s.id_slid,set_val=in	; Update slider.
	  imgarr_viewer_disp,s.stk(*,*,in), s	; ; Display image.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq '>' then begin
	  in = (s.indx+1)<(s.num-1)		; Increment index.
	  s.indx = in				; Save.
	  widget_control,s.id_slid,set_val=in	; Update slider.
	  imgarr_viewer_disp,s.stk(*,*,in), s	; ; Display image.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq 'WT' then begin	; Wait time between frames.
	  def = strtrim(s.wt,2)			; Use current as default.
	  xtxtin, txt, title='Enter wait time in sec (def='+def+'):'
	  if txt eq '' then return		; No change.
	  s.wt = txt+0.				; Store new value.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq 'PS' then begin	; Pause time after last frame.
	  def = strtrim(s.ps,2)			; Use current as default.
	  xtxtin, txt, title='Enter pause time in sec (def='+def+'):'
	  if txt eq '' then return		; No change.
	  s.ps = txt+0.				; Store new value.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq 'DISP' then begin
	  men = ['Scale to specified min/max',$
		'Scale to image min/max',$
		'Linear stretch based on percentiles']
	  subset = s.order
	  clr = [-1,-1,-1]
	  clr(s.sc_flag) = tarclr(/hsv,150,.5,1)
	  sc_flag = xoption(men,subopt='Display from top down', $
	    subset=subset, color=clr)
	  s.order = subset
	  s.sc_flag = sc_flag
	  case sc_flag of
0:	  begin
	    img = s.stk(*,*,s.indx)
	    amn = min(img,max=amx)
	    txt = strtrim(s.amn,2)+' '+strtrim(s.amx,2)+ $
	      '       (0 0 = autoscale)'
	    txt2 = 'Current image min, max: '+strtrim(amn+0,2)+', '+$
	      strtrim(amx+0,2)
	    xtxtin, /wait, def=txt, out, $
	      title=['Set scaling min max:',txt2]
	    if out ne '' then begin
	      s.amn = getwrd(out,0) + 0.
	      s.amx = getwrd(out,1) + 0.
	    endif
	  end
1:	  begin
	    out = 'x'	; Just want sc_flag=1.
	  end
2:	  begin
	    txt = strtrim(s.alo,2)+' '+strtrim(s.ahi,2)
	    xtxtin, /wait, def=txt, out, title='Set scaling lo hi percentile:'
	    if out ne '' then begin
	      s.alo = getwrd(out,0) + 0.
	      s.ahi = getwrd(out,1) + 0.
	    endif
	  end
	  endcase
	  imgarr_viewer_disp,s.stk(*,*,s.indx),s	; Display image.
	  widget_control, ev.top, set_uval=s	; Save updated values.
	  return
	endif
 
	if uval eq 'QUIT' then begin
	  widget_control, ev.top, /destroy	; All done, just destroy top.
	  return
	endif
 
	end
 
 
	;======================================================
	;  imgarr_viewer = Image array viewer.
	;  R. Sterner, 2001 Oct 03
	;======================================================
 
	pro imgarr_viewer, imgarr, order=order, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' View an array of images.'
	  print,' imgarr_viewer, imgarr'
	  print,'   imgarr = an array of images.  in'
	  print,' Keywords:'
	  print,'   /ORDER display order.'
	  print,' Note: imgarr is a 3-d array, like (512,512,25).'
	  print,' Images need not be byte and need not be scaled 0 to 255.'
	  print,' Scaling option may be changed.'
	  return
	endif
 
	sz  = size(imgarr)	; Find number and size of images.
	xs  = sz(1)		; X size of images.
	ys  = sz(2)		; Y size of images.
	num = sz(3)		; Number of images in imgarr.
 
	ssiz = (4*num)<250>100
	if n_elements(order) eq 0 then order=0
	device, get_screen_size=ss                      ; Get screen size.
	xmx = ss(0)*2/3                                 ; Max allowed default
	ymx = ss(1)*2/3                                 ;   window size.
	xscr = xs<xmx
	yscr = ys<ymx
 
	;------  Build widget  ------------------
	top = widget_base(/col)
	b = widget_base(top,/row)
	id = widget_button(b,val='Quit',uval='QUIT')
	id = widget_button(b,val='Stop',uval='STOP')
	id = widget_button(b,val='Go',uval='GO')
	id_slid = widget_slider(b,min=0,max=num-1,uval='SLID', $
	  /drag,xsize=ssiz)
	id = widget_button(b,val=' < ',uval='<')
	id = widget_button(b,val=' > ',uval='>')
	b2 = widget_base(b,/row)
	men = widget_button(b2,val='Set values',menu=2)
	  id = widget_button(men,val='Change image display',uval='DISP')
	  id = widget_button(men,val='Change time step',uval='WT')
	  id = widget_button(men,val='Change pause time',uval='PS')
 
	if (xscr eq xs) and (yscr eq ys) then begin
	  id_draw = widget_draw(top,xsize=xs,ysize=ys)
	endif else begin
	  id_draw = widget_draw(top,xsize=xs,ysize=ys,x_scr=xscr, y_scr=yscr)
	endelse
 
	;------  Realize widget  --------------
	widget_control, top,/real
 
	;------  Draw window ID  --------------
	widget_control, id_draw, get_val=win
	wset, win
 
	;------  Start timer  -------
	twid = b			; Use a base widget as timer.
;       widget_control, twid, timer=0.	; Set timer to trigger right away.
	mvflag = 0			; Set play movie flag to off.
	indx = 0			; Image index (# images=num).
;	widget_control, id_slid, sens=0	; Gray out slider to start.
	wt = 0.2			; Wait between display steps.
	ps = 1.0			; Pause at end of imgarr.
 
	;-------  Pack up info  ----------------
	s = {id_draw:id_draw, win:win, stk:imgarr, indx:0, num:num, $
	     twid:twid, mvflag:mvflag, wt:wt, ps:ps, id_slid:id_slid, $
	     order:order, amn:0., amx:0., alo:1., ahi:1., $
	     sc_flag:1, dum:0 }
	widget_control, top, set_uval=s
	imgarr_viewer_disp,imgarr(*,*,0), s	; Display image.
 
	;------  Activate  -----------
	xmanager, 'imgarr_viewer', top, /no_block
 
	end
