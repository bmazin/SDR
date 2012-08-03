;-------------------------------------------------------------
;+
; NAME:
;       CW_MCLED
; PURPOSE:
;       Multicolored LED widget.
; CATEGORY:
; CALLING SEQUENCE:
;       id = cw_mcled( parent)
; INPUTS:
;       parent = Widget ID of parent base.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         VALUE=val Initial value. Must be from 0 to N-1
;           where N is the number of allowed states.
;         LABEL=label  Array of N labels, one for each state.
;           A null string gives a blank label.  First element
;           is for the off state, other elements are for on states.
;         DONE_LABEL=dlab Optional label for an extra state,
;           normally done (LED off).  Set value--2 for this state.
;         MSG_ID=msg_id  WID of LED label is any (-1=none).
;           Can be used to display text in an unused label area.
;         HUE=hue  Array of hues, one for each state.
;         SAT=sat  Array of saturations, one for each state (def=1s).
;         UVALUE=uval User value (def=none).
;         /FRAME frame around widget (def=one).
;         TITLE=ttl LED title (def=none).
;         /NOGLARE means do not display glare around LED.
;         /PACK Make a smaller LED (use with /noglare).
;       
;         Change status by setting a new value:
;           widget_control, id, set_val=state
;           Set state to 0 for off.  Set to any value from 0
;           to 1 less than number of states (labels and hues).
;           Setting to -1 erases LED and label.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Mar 18
;       R. Sterner, 2003 Mar 24 --- Squeezed out some excess space.
;       R. Sterner, 2006 Feb 19 --- Added return in help.
;       R. Sterner, 2006 Feb 19 --- Fixed floating under flow (>1e-10).
;       R. Sterner, 2006 Feb 19 --- OS dependent values. Dark halo darker.
;       R. Sterner, 2006 Feb 28 --- Changed background brightness.
;       R. Sterner, 2007 Jul 27 --- Added DONE_LABEL.
;       R. Sterner, 2007 Jul 30 --- Fixed to not change current window.
;       R. Sterner, 2007 Aug 27 --- Added MSG_ID.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro cw_mcled_update, s
 
	num = s.num
	val = s.val
	c1 = fix(s.c1)	; Widget background value.
 
	if val ge num then begin
	  print,' Error in cw_mcled: given value out of range.'
	  print,'   Max value = '+strtrim(num-1,2)
	  return
	endif 
 
	wsave = !d.window			; Save current window.
	wset, s.led_win
 
 
	if val eq -2 then begin		; Set off state with done text.
	    off_h = s.off_h + s.hue(0)
	    off_s = s.off_s*s.sat(0)
	    off_v = s.off_v
	    img = img_merge(/hsv,off_h,off_s,off_v)
	    tv,tr=3,img			; Display light.
	    if s.lab_id ge 0 then widget_control,s.lab_id,set_val=s.done
	    wset, wsave
	  return
	endif
 
	if val eq -1 then begin		; Blank space.
	  erase,tarclr(c1,c1,c1)
	  if s.lab_id ge 0 then widget_control,s.lab_id,set_val=''
	endif else begin		; Light.
	  if val ge 1 then begin	; ON.
	    on_h = s.on_h + s.hue(val)
	    on_s = s.on_s*s.sat(val)
	    on_v = s.on_v
	    img = img_merge(/hsv,on_h,on_s,on_v)
	  endif else begin		; OFF.
	    off_h = s.off_h + s.hue(0)
	    off_s = s.off_s*s.sat(0)
	    off_v = s.off_v
	    img = img_merge(/hsv,off_h,off_s,off_v)
	  endelse
	  tv,tr=3,img			; Display light.
	  if s.lab_id ge 0 then widget_control,s.lab_id,set_val=s.label(val)
	  wset, wsave
	endelse
 
	end
 
 
;----------------------------------------------------------------------
;	cw_mcled_get_value = get cw_mcled value.
;----------------------------------------------------------------------
 
	function cw_mcled_get_value, id
 
	;-------  Get state structure  ------------
	ch_id = widget_info(id,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	val = s.val				; Current value.
	return, val
 
	end
 
 
;----------------------------------------------------------------------
;	cw_mcled_set_value = set cw_mcled value.
;----------------------------------------------------------------------
 
	pro cw_mcled_set_value, id, val
 
	;-------  Get state structure  ------------
	ch_id = widget_info(long(id),/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	;-------  Save new values  ----------------
	s.val = val
	widget_control,ch_id,set_uval=s		; Save state.
 
	;---------  Update display  ------------------
	cw_mcled_update, s
 
	end
 
 
;----------------------------------------------------------------------
;	cw_mcled_realize: set up mcled when widget realized
;----------------------------------------------------------------------
 
	pro cw_mcled_realize, root
 
	wsave = !d.window			; Save current window.
	ch_id = widget_info(root,/child)	; Widget ID of child.
	widget_control, ch_id, get_uval=s	; Grab state info.
 
	;-----  Get draw window indices  --------------
	widget_control, s.led_id, get_value=win	; Now can get window.
	s.led_win = win				; Save draw window.
 
	widget_control, ch_id, set_uval=s	; Save updated widget state.
 
	cw_mcled_update, s			; Update LED.
 
	wset, wsave				; Restore original window.
 
	end
 
 
;----------------------------------------------------------------------
;	Main routine
;----------------------------------------------------------------------
 
	function cw_mcled, parent, uvalue=uval, help=hlp, $
	  frame=frame, title=title, label=label0, $
	  hue=hue0, sat=sat0, value=val0, $
	  noglare=noglare,pack=pack, done_label=done, $
	  msg_id=msg_id
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Multicolored LED widget.'
	  print,' id = cw_mcled( parent)'
	  print,'   parent = Widget ID of parent base.   in'
	  print,' Keywords:'
	  print,'   VALUE=val Initial value. Must be from 0 to N-1'
	  print,'     where N is the number of allowed states.'
	  print,'   LABEL=label  Array of N labels, one for each state.'
	  print,'     A null string gives a blank label.  First element'
	  print,'     is for the off state, other elements are for on states.'
	  print,'   DONE_LABEL=dlab Optional label for an extra state,'
	  print,'     normally done (LED off).  Set value--2 for this state.'
	  print,'   MSG_ID=msg_id  WID of LED label is any (-1=none).'
	  print,'     Can be used to display text in an unused label area.'
	  print,'   HUE=hue  Array of hues, one for each state.'
	  print,'   SAT=sat  Array of saturations, one for each state (def=1s).'
	  print,'   UVALUE=uval User value (def=none).'
	  print,'   /FRAME frame around widget (def=one).'
	  print,"   TITLE=ttl LED title (def=none)."
	  print,'   /NOGLARE means do not display glare around LED.'
	  print,'   /PACK Make a smaller LED (use with /noglare).'
	  print,' '
	  print,'   Change status by setting a new value:'
	  print,'     widget_control, id, set_val=state'
	  print,'     Set state to 0 for off.  Set to any value from 0'
	  print,'     to 1 less than number of states (labels and hues).'
	  print,'     Setting to -1 erases LED and label.'
	  return,''
	endif
 
	on_error, 2
 
	;---------------------------------------------
	;  Set defaults and constants
	;---------------------------------------------
	num_1 = n_elements(label0)
	num_2 = n_elements(hue0)
	num = num_1 > num_2			; Number of allowed states.
	if num eq 0 then begin
	  print,' Error in cw_mcled: Must give array of labels or hues.'
	  stop
	endif
	if n_elements(label0) eq 0 then label0=strarr(num)
	if n_elements(done) eq 0 then done=''		; Label for Done state.
	if n_elements(title) eq 0 then title='' 	; Title.
	if n_elements(uval) eq 0 then uval=''		; UVAL.
	if n_elements(val0) eq 0 then val0=0		; Initial values.
	if n_elements(hue0) eq 0 then hue0=fltarr(num)+120  ; Hue.
	if n_elements(sat0) eq 0 then sat0=fltarr(num)+1    ; Saturation.
	if n_elements(hue0) eq 1 then hue0=fltarr(num)+hue0(0)
	if n_elements(sat0) eq 1 then sat0=fltarr(num)+sat0(0)
	hue = hue0					; Copy values that may
	sat = sat0					;   be changed.
	wid = 30
	if keyword_set(pack) then wid=15
 
	;---------------------------------------------
	;  Set up light
	;
	;  Set c3 to brightness fraction:
	;    erase,tarclr(255.*c3) and match background.
	;  Set c1 = 255.*c3
	;  Set c2 = 1007.*c3
	;---------------------------------------------
	if !version.os_family eq 'unix' then begin	; OS constants.
	  c1 = 192.
	  c2 = 755
	  c3 = 0.75
	endif
	if !version.os_family eq 'Windows' then begin
;	  c1 = 232.	; Was.
;	  c2 = 916
;	  c3 = 0.91
	  c1 = 209.	; RES 2006 Feb 28.
	  c2 = 825
	  c3 = 0.82
	endif
	;-----  Light on  ---------
	d=shift(dist(150),75,75)
	d2=d/max(d)
	t=d lt 15
	window,xs=150,ys=150,/pixmap
	tv,(smooth2(t*255,15*3)*4+t*255)>0<255,chan=2
	img1=tvrd(tr=1)
;	tv,(smooth2(192.-t*755,3*13)-t*255.)>0
	tv,(smooth2(c1-t*c2,3*13)-t*255.)>0
	img2=tvrd(tr=1)
	img3 = img_add(img1,img2)
	img_split,img3,/hsv,hh,ss,vv
	ss = ss-(smooth2(t+0.,15)>1E-10)^3	; Fixed floating underflow.
	if keyword_set(noglare) then begin	; Drop glare outside light.
;	  hi = 8.  ; Halo intensity.
	  hi = 12.  ; Halo intensity.
;	  vv = (.75-vnorm(exp((1-d)/hi),.75)+t)<1. ; Make a dark halo.
	  vv = (c3-vnorm(exp((1-d)/hi),c3)+t)<1. ; Make a dark halo.
	  ss=ss*t
	endif
	img3 = img_merge(/hsv,hh,ss,vv,tr=1)
	img3 = img3(*,30:119,30:119)
	on = img_resize(img3,imgmax=30,/rebin)
	;-----  Light off  ---------
	d=shift(dist(150),75,75)
	t=d lt (6*3)
	erase
	tv,smooth2(t*120,3*5)*t,chan=2	; t*bright (like t*180).
	img1=tvrd(tr=1,30,30,90,90)
;	tv,(1.-t)*192
	tv,(1.-t)*c1
	img2=tvrd(tr=1,30,30,90,90)
	off = img_resize(img_add(img1,img2),imgmax=30,/rebin)
	wdelete
	;-----  Closer packing  ----------
	if keyword_set(pack) then begin
	  on = img_subimg(on,7,7,15,15)
	  off = img_subimg(off,7,7,15,15)
	endif
	;----  Split into components  -------
	img_split, on, /hsv, on_h, on_s, on_v
	img_split, off, /hsv, off_h, off_s, off_v
	on_h = on_h*0
	off_h = off_h*0
 
	;---------------------------------------------
	;  Set up widget
	;	notify_realize needed to get draw
	;	widget window IDs after widget realized.
	;---------------------------------------------
	;--------  CW widget root base  ------------------------
	root = widget_base( parent, uvalue=uval,frame=frame, $
;		event_func='cw_mcled_event',         $
		pro_set_value='cw_mcled_set_value',  $
		func_get_value='cw_mcled_get_value', $
		notify_realize='cw_mcled_realize')
 
	;--------  Child base for saving widget state  ----------
	base = widget_base(root,/col,space=0,xpad=0,ypad=0)
 
	;--------  Title  ----------
	if title ne '' then id = widget_label(base,val=title)
 
	;--------  LED  ------------
	b = widget_base(base,/row,ypad=0,/align_center)
	led_id = widget_draw(b,xsize=wid,ysize=wid)
	len = strlen(label0)
	w = where(len eq max(len))
	if max(len) gt 0 then begin
	  lab_id = widget_label(b,val=label0(w(0)),/dynamic)
	endif else lab_id = -1
	msg_id = lab_id
 
	;--------  Collect state info and save  ------------------
	;----------------------------------------------------------
	s = {root:root, val:val0, hue:hue, sat:sat, num:num, $
		  led_id:led_id, led_win:0L, $
		  label:label0, lab_id:lab_id, done:done, $
		  on_h:on_h,   on_s:on_s,   on_v:on_v, $
		off_h:off_h, off_s:off_s, off_v:off_v, c1:c1 }
	 
	widget_control, base, set_uval=s  ; Save widget state in first child.
 
	;--------  See if realized (adding to existing widget)  ------
	if widget_info(root,/real) then cw_mcled_realize, root
 
	;--------  Return Widget ID for this compound widget  ---------
	return, root
 
	end
