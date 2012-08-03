;-------------------------------------------------------------
;+
; NAME:
;       CW_BITLIGHTS
; PURPOSE:
;       Indicate bits on or off.
; CATEGORY:
; CALLING SEQUENCE:
;       id = cw_bitlights( parent)
; INPUTS:
;       parent = Widget ID of parent base.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         VALUE=val Initial value. This may be a scalar or an
;           array of 0s and 1s (give array with smallest bit first).
;         LABEL=label  Labels for each bit.
;           A null string gives a blank space.
;           The number of labels sets the number of lights.
;           May have fewer lights than needed to display the full
;           value given, only the needed bits will be used.
;         /REVERSE means displayed order of bits.
;         /STRIP make a horizontal strip of lights.
;           For this case if all labels are single spaces then
;           no extra room will be allowed for them.  As before use
;           inserted null strings to give a blank between lights.
;         /SHOW means display value.  Only works with /STRIP.
;         FORMAT=fmt Format to use for /SHOW (def='(I0)').
;         HUE=hue  Single hue or array for each bit.
;         SAT=sat  Single saturation or array for each bit.
;           Default color is green.  If arrays are used for hue and
;           sat then they must have entries for each light.
;         UVALUE=uval User value (def=none).
;         /FRAME frame around widget (def=one).
;         TITLE=ttl Image title (def=none).
;         /NOGLARE means do not display glare around lights.
;         /PACK pack lights closer together (use with /noglare).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note:  Lights are ordered from the top down, unless
;         /REVERSE is used.
;       
;         Change status by setting a new value:
;           widget_control, id, set_val=bits
;         bits may be a single value or an array of 0s and 1s.
;         If an array is used give smallest bit first.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Nov 12
;       R. Sterner, 2003 Mar 05 --- Add dark halo for noglare.
;       R. Sterner, 2003 Mar 26 --- Added /STRIP for horizontal lights.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro cw_bitlights_update, s
 
	num = s.num
	val = s.val
 
	for i=0, num-1 do begin
	  wset, s.bit_win(i)
	  if s.hue(i) lt 0 then begin	; Blank space.
	    erase,tarclr(192,192,192)
	  endif else begin		; Light.
	    if val(i) eq 1 then begin	; ON.
	      on_h = s.on_h + s.hue(i)
	      on_s = s.on_s*s.sat(i)
	      on_v = s.on_v
	      img = img_merge(/hsv,on_h,on_s,on_v)
	    endif else begin		; OFF.
	      off_h = s.off_h + s.hue(i)
	      off_s = s.off_s*s.sat(i)
	      off_v = s.off_v
	      img = img_merge(/hsv,off_h,off_s,off_v)
	    endelse
	    tv,tr=3,img			; Display light.
	  endelse
	endfor
 
	if s.idshow ne 0 then begin
	  widget_control, s.idshow, set_val=string(s.val0,form=s.fmt)
	endif
 
	end
 
 
;----------------------------------------------------------------------
;	cw_bitlights_get_value = get cw_bitlights value.
;----------------------------------------------------------------------
 
	function cw_bitlights_get_value, id
 
	;-------  Get state structure  ------------
	ch_id = widget_info(id,/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	val = s.val				; Current value.
	if s.rev then val=reverse(val)		; Return LSB first.
	return, val
 
	end
 
 
;----------------------------------------------------------------------
;	cw_bitlights_set_value = set cw_bitlights value.
;----------------------------------------------------------------------
 
	pro cw_bitlights_set_value, id, val00
 
	;-------  Get state structure  ------------
	ch_id = widget_info(long(id),/child)
	widget_control,ch_id,get_uval=s		; Get state.
 
	;-------  Deal with incoming value  ---------
	val0 = val00
	num = s.num
	last = (num-1)<(n_elements(val0)-1)
	if n_elements(val0) eq 1 then begin		; Convert a bit field
	  tmp = basecon(long64(val0),to=2,digits=num,gr=1);   to an array.
	  wordarray,tmp,val1
	  val1 = reverse(val1)
	  val1 = val1(0:num-1)+0			; Pick off num bits.
	endif else begin				; Given an array.
	  tmp = intarr(num)				; Zero pad.
	  tmp(0) = val0(0:last)
	  val1 = tmp
	endelse
	val = val1					; val1 = non reversed.
	if s.rev eq 1 then val=reverse(val)		; Reverse display order.
 
	;-------  Save new values  ----------------
	s.val = val
	s.val0 = val00(0)
	widget_control,ch_id,set_uval=s		; Save state.
 
	;---------  Update display  ------------------
	cw_bitlights_update, s
 
	end
 
 
;----------------------------------------------------------------------
;	cw_bitlights_realize: set up bitlights when widget realized
;----------------------------------------------------------------------
 
	pro cw_bitlights_realize, root
 
	wsave = !d.window			; Save current window.
	ch_id = widget_info(root,/child)	; Widget ID of child.
	widget_control, ch_id, get_uval=s	; Grab state info.
 
	;-----  Get draw window indices  --------------
	for i=0,s.num0-1 do begin			; Loop through lights.
	  widget_control, s.bit_id(i), get_value=win	; Now can get window.
	  s.bit_win(i) = win				; Save draw window.
	  if s.flag(i) eq 0 then begin			; Blank out unused.
	    wset, win
	    erase,tarclr(192,192,192)  			; Blank.
	  endif
	endfor
 
	w = where(s.flag eq 1)			; Find good lights.
	s.bit_win = s.bit_win(w)		; Keep only real lights.
 
	widget_control, ch_id, set_uval=s	; Save updated widget state.
 
	cw_bitlights_update, s			; Update lights.
 
	wset, wsave				; Restore original window.
 
	end
 
 
;----------------------------------------------------------------------
;	Main routine
;----------------------------------------------------------------------
 
	function cw_bitlights, parent, uvalue=uval, help=hlp, $
	  frame=frame, title=title, label=label0, $
	  hue=hue0, sat=sat0, value=val0, reverse=reverse, $
	  noglare=noglare,pack=pack, strip=strip, show=show, format=fmt
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Indicate bits on or off.'
	  print,' id = cw_bitlights( parent)'
	  print,'   parent = Widget ID of parent base.   in'
	  print,' Keywords:'
	  print,'   VALUE=val Initial value. This may be a scalar or an'
	  print,'     array of 0s and 1s (give array with smallest bit first).'
	  print,'   LABEL=label  Labels for each bit.'
	  print,'     A null string gives a blank space.'
	  print,'     The number of labels sets the number of lights.'
	  print,'     May have fewer lights than needed to display the full'
	  print,'     value given, only the needed bits will be used.'
	  print,'   /REVERSE means displayed order of bits.'
	  print,'   /STRIP make a horizontal strip of lights.'
	  print,'     For this case if all labels are single spaces then'
	  print,'     no extra room will be allowed for them.  As before use'
	  print,'     inserted null strings to give a blank between lights.'
	  print,'   /SHOW means display value.  Only works with /STRIP.'
	  print,"   FORMAT=fmt Format to use for /SHOW (def='(I0)')."
	  print,'   HUE=hue  Single hue or array for each bit.'
	  print,'   SAT=sat  Single saturation or array for each bit.'
	  print,'     Default color is green.  If arrays are used for hue and'
	  print,'     sat then they must have entries for each light.'
	  print,'   UVALUE=uval User value (def=none).'
	  print,'   /FRAME frame around widget (def=one).'
	  print,"   TITLE=ttl Image title (def=none)."
	  print,'   /NOGLARE means do not display glare around lights.'
	  print,'   /PACK pack lights closer together (use with /noglare).'
	  print,' Note:  Lights are ordered from the top down, unless'
	  print,'   /REVERSE is used.'
	  print,' '
	  print,'   Change status by setting a new value:'
	  print,'     widget_control, id, set_val=bits'
	  print,'   bits may be a single value or an array of 0s and 1s.'
	  print,'   If an array is used give smallest bit first.'
	endif
 
	on_error, 2
 
	;---------------------------------------------
	;  Set defaults and constants
	;---------------------------------------------
	if keyword_set(reverse) then rev=1 else rev=0	; Display order.
	if n_elements(label0) eq 0 then begin
	  print,' Error in cw_bitlights: Must give label array.'
	  stop
	endif
	label = label0					; Copy label.
	if rev eq 1 then begin				; Reverse display order.
	  label = reverse(label)
	endif
	num0 = n_elements(label)			; Total labels given.
	w = where(label ne '', num)			; # of active labels.
	flag = label ne ''				; Flag actual lights.
	if n_elements(title) eq 0 then title='' 	; Title.
	if n_elements(uval) eq 0 then uval=''		; UVAL.
	if n_elements(val0) eq 0 then val0=0		; Initial values.
	if n_elements(hue0) eq 0 then hue0=fltarr(num)+120  ; Hue.
	if n_elements(sat0) eq 0 then sat0=fltarr(num)+1    ; Saturation.
	if n_elements(hue0) eq 1 then hue0=fltarr(num)+hue0(0)
	if n_elements(sat0) eq 1 then sat0=fltarr(num)+sat0(0)
	hue = hue0					; Copy values that may
	sat = sat0					;   be changed.
	if n_elements(val0) eq 1 then begin		; Convert a bit field
	  tmp = basecon(val0,to=2,digits=num,gr=1)	;   to an array.
	  wordarray,tmp,val1
	  val1 = reverse(val1)				; Put LSB first.
	  val1 = val1(0:(num>1)-1)+0			; Pick off num bits.
	endif else begin				; Given an array.
	  tmp = intarr(num>1)				; Zero pad.
	  tmp(0) = val0
	  val1 = tmp
	endelse
	val = val1					; val1 = non reversed.
	if rev eq 1 then begin				; Reverse display order.
	  val = reverse(val)
	  hue = reverse(hue)
	  sat = reverse(sat)
	endif
	wid = 30
	if keyword_set(pack) then wid=15
	if n_elements(fmt) eq 0 then fmt='(I0)'
	idshow = 0
 
	;---------------------------------------------
	;  Set up light
	;---------------------------------------------
	;-----  Light on  ---------
	d=shift(dist(150),75,75)
	d2=d/max(d)
	t=d lt 15
	window,xs=150,ys=150,/pixmap
	tv,(smooth2(t*255,15*3)*4+t*255)>0<255,chan=2
	img1=tvrd(tr=1)
	tv,(smooth2(192.-t*755,3*13)-t*255.)>0
	img2=tvrd(tr=1)
	img3 = img_add(img1,img2)
	img_split,img3,/hsv,hh,ss,vv
	ss = ss-smooth2(t+0.,15)^3
	if keyword_set(noglare) then begin	; Drop glare outside light.
	  hi = 8.  ; Halo intensity.
	  vv = (.75-vnorm(exp((1-d)/hi),.75)+t)<1. ; Make a dark halo.
	  ss=ss*t
	endif
	img3 = img_merge(/hsv,hh,ss,vv,tr=1)
	img3 = img3(*,30:119,30:119)
	on = img_resize(img3,imgmax=30,/rebin)
	;-----  Light off  ---------
	d=shift(dist(150),75,75)
	t=d lt 6*3
	erase
	tv,smooth2(t*120,3*5)*t,chan=2	; t*bright (like t*180).
	img1=tvrd(tr=1,30,30,90,90)
	tv,(1.-t)*192
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
;		event_func='cw_bitlights_event',         $
		pro_set_value='cw_bitlights_set_value',  $
		func_get_value='cw_bitlights_get_value', $
		notify_realize='cw_bitlights_realize')
 
	;--------  Child base for saving widget state  ----------
	base = widget_base(root,/col,space=0)
 
	;--------  Title  ----------
	if title ne '' then id = widget_label(base,val=title)
 
	;--------  Bits  ------------
	bit_id = lonarr(num0)		; Set up space for all given labels.
	bit_win = lonarr(num0)
 
	;------  Vertical strip of LEDs  -----------
	if not keyword_set(strip) then begin
	  for i=0,num0-1 do begin
	    b = widget_base(base,/row)
	    bit_id(i) = widget_draw(b,xsize=wid,ysize=wid)
	    id = widget_label(b,val=label(i))
	  endfor
	;------  Horizontal strip of LEDs  -----------
	endif else begin
	  labflag = max(byte(label)) gt 32	; Any labels? 1=yes.
	  b = widget_base(base,/row)
	  for i=0,num0-1 do begin
	    if labflag then begin		; If label add below LED.
	      bb = widget_base(b,/col)
	      bit_id(i) = widget_draw(bb,xsize=wid,ysize=wid)
	      id = widget_label(bb,val=label(i))
	    endif else begin
	      bit_id(i) = widget_draw(b,xsize=wid,ysize=wid)
	    endelse
	  endfor
	  if keyword_set(show) then begin
	    if labflag then begin
	      bb = widget_base(b,/col)
	      idshow = widget_label(bb,val=string(val0,form=fmt),/dynamic)
	      id = widget_label(bb,val=' ')
	    endif else begin
	      idshow = widget_label(b,val=string(val0,form=fmt),/dynamic)
	    endelse
	  endif
	endelse
 
	;--------  Collect state info and save  ------------------
	;----------------------------------------------------------
	s = {root:root, val:val, hue:hue, sat:sat, num0:num0, num:num, $
		bit_id:bit_id, bit_win:bit_win, rev:rev, flag:flag, $
		on_h:on_h, on_s:on_s, on_v:on_v, $
		off_h:off_h, off_s:off_s, off_v:off_v, $
		idshow:idshow, fmt:fmt, val0:val0}
	 
	widget_control, base, set_uval=s  ; Save widget state in first child.
 
	;--------  See if realized (adding to existing widget)  ------
	if widget_info(root,/real) then cw_bitlights_realize, root
 
	;--------  Return Widget ID for this compound widget  ---------
	return, root
 
	end
