;-------------------------------------------------------------
;+
; NAME:
;       XCYPH
; PURPOSE:
;       Widget based cycle/phase images.
; CATEGORY:
; CALLING SEQUENCE:
;       xcyph, data, time
; INPUTS:
;       data = Time series data.                    in
;       time = time tag for each point in data.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         RANGE=[min,max]  Set slice length range limits.
;         CPOUT=out  Returned output image.
;         TOUT=t     Returned times of bottom edge of out.
;         SLICE=s    Returned slice length.
;         OFFSET=fr  Returned offset into data as fraction of slice.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Time series is divided into slices which are arranged
;         into an image in a graphics window.  Time slice length
;         is adjusted using the slider.
;         See also cyph.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Jan 25
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro xcyph_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=m
 
	if uval eq 'QUIT' then begin
	  widget_control, m.ids, get_val=val	; Read slice slider.
	  v = (val/500.)*(m.smx-m.smn)+m.smn	; Compute slice size.
	  widget_control, ev.top, /dest		; Destroy widget.
	  widget_control, m.res, set_uval={slice:v, offset:m.phase}
	  return	
	endif
 
	if uval eq '-' then begin
	  widget_control, m.ids, get_val=val
	  val = (val-1)>0
	  widget_control, m.ids, set_val=val
	  v = (val/500.)*(m.smx-m.smn)+m.smn
	  widget_control, m.ids_lb, set_val=string(v,form='(g13.6)')
	  cyph, m.data0, m.time0, slice=v, cpout=c, off=m.phase
	  tvscl,c
	  return	
	endif
 
	if uval eq '+' then begin
	  widget_control, m.ids, get_val=val
	  val = (val+1)<500
	  widget_control, m.ids, set_val=val
	  v = (val/500.)*(m.smx-m.smn)+m.smn
	  widget_control, m.ids_lb, set_val=string(v,form='(g13.6)')
	  cyph, m.data0, m.time0, slice=v, cpout=c, off=m.phase
	  tvscl,c
	  return	
	endif
 
	if uval eq 'MIN' then begin
	  widget_control, m.ids, get_val=val
	  v = (val/500.)*(m.smx-m.smn)+m.smn
	  widget_control, m.mnlb, set_val=string(v,form='(g13.6)')
	  m.smn = v
	  m.ind = (m.ind+1)<99
	  m.mna(m.ind) = m.smn
	  m.mxa(m.ind) = m.smx
	  widget_control, m.ids, set_val=0
	  widget_control, ev.top, set_uval=m
	  return	
	endif
 
	if uval eq 'MAX' then begin
	  widget_control, m.ids, get_val=val
	  v = (val/500.)*(m.smx-m.smn)+m.smn
	  widget_control, m.mxlb, set_val=string(v,form='(g13.6)')
	  m.smx = v
	  m.ind = (m.ind+1)<99
	  m.mna(m.ind) = m.smn
	  m.mxa(m.ind) = m.smx
	  widget_control, m.ids, set_val=500
	  widget_control, ev.top, set_uval=m
	  return	
	endif
 
	if uval eq 'SLIDE' then begin
	  widget_control, ev.id, get_val=val
	  v = (val/500.)*(m.smx-m.smn)+m.smn
	  widget_control, m.ids_lb, set_val=string(v,form='(g13.6)')
	  cyph, m.data0, m.time0, slice=v, cpout=c, off=m.phase
	  tvscl,c
	  return
	endif
 
	if uval eq 'BACK' then begin
	  m.ind = (m.ind-1)>0
	  m.smn = m.mna(m.ind)
	  m.smx = m.mxa(m.ind)
	  widget_control, m.mnlb, set_val=string(m.smn,form='(g13.6)')
	  widget_control, m.mxlb, set_val=string(m.smx,form='(g13.6)')
	  widget_control, m.ids, set_val=250
	  v = .5*(m.smn+m.smx)
	  widget_control, m.ids_lb, set_val=string(v,form='(g13.6)')
	  cyph, m.data0, m.time0, slice=v, cpout=c, off=m.phase
	  tvscl,c
	  widget_control, ev.top, set_uval=m
	  return
	endif
 
	if uval eq 'PHASE' then begin
	  widget_control, ev.id, get_val=phase
	  m.phase = phase
	  widget_control, m.ids, get_val=val
	  v = (val/500.)*(m.smx-m.smn)+m.smn
	  cyph, m.data0, m.time0, slice=v, cpout=c, off=m.phase
	  tvscl,c
	  widget_control, ev.top, set_uval=m
	  return
	endif
 
	if uval eq 'HELP' then begin
	  xhelp,title='Help for XCYPH',['Overview',$
		'xcyph takes time series data and arranges it into an image.',$
		'This is done by dividing the data into uniform slices and',$
		'arranging the slices as columns of an image.  The length',$
		'of each slice is set by the top slider bar and may be varied',$
		'between the limits shown on the left and right sides of the',$
		'bar.  These limits are set by the keyword RANGE=[min,max]',$
		'used when calling xcyph.',' ',$
		'Periodic components of the data with a period equal to the',$
		'length of the slice, or multiples or submultiples, will',$
		'appear in the resulting image as horizontal features.',' ',$
		'Commands',$
		'Quit:    Quit xcyph.',$
		'-:       Step slice size down by one step.',$
		'+:       Step slice size up by one step.',$
		'Set Min: Set minimum of slider bar to current value.',$
		'Set Max: Set maximum of slider bar to current value.',$
		'Back:    Go back to slider bar limits before last Set',$
		'         Min or Set Max command.',$
		'Help:    Display this text.',$
		'Top slider bar: Set length of slice.',$
		'Bottom slider bar: Set phase as fraction of slice.']
	  return
	endif
 
	return
	end
 
 
;==============================================
;	xcyph.pro = Widget cycle phase tool
;	R. Sterner, 1995 Jan 25
;
;	Notes:
;	*1. Add Help button.
;	*2. move common to uval.
;	3. Add Plot button to make a cycle/phase plot:
;	   Will need to pass in _extra plot keywords, also /JS.
;	4. Display cycle length in window next to phase:
;	   Display as time if /js.
;	5. Add CPOUT=z, TOUT=t (like cyph).
;	   Also will need SLICE=s, OFFSET=f.  All return values.
;	6. Add Set Limits button.
;==============================================
 
	pro xcyph, data, time, range=ran, cpout=cpout, tout=tout, $
	  slice=slice, offset=offset, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Widget based cycle/phase images.'
	  print,' xcyph, data, time'
	  print,'   data = Time series data.                    in'
	  print,'   time = time tag for each point in data.     in'
	  print,' Keywords:'
	  print,'   RANGE=[min,max]  Set slice length range limits.'
	  print,'   CPOUT=out  Returned output image.'
	  print,'   TOUT=t     Returned times of bottom edge of out.'
	  print,'   SLICE=s    Returned slice length.'
	  print,'   OFFSET=fr  Returned offset into data as fraction of slice.'
	  print,' Notes: Time series is divided into slices which are arranged'
	  print,'   into an image in a graphics window.  Time slice length'
	  print,'   is adjusted using the slider.'
	  print,'   See also cyph.'
	  return
	endif
 
	data0 = data
	time0 = time
	if n_elements(ran) eq 0 then ran=[100,300]
	smn = ran(0)		; Current slider min.
	smx = ran(1)		; Current slider max.
	mna = fltarr(100)	; Memory for mins.
	mxa = fltarr(100)	; Memory for maxs.
	ind = 0			; Current index.
	mna(0) = ran(0)		; Load up first.
	mxa(0) = ran(1)
	phase = 0.
	cyph, data0, time0, slice=ran(0), cpout=c, off=phase
	tvscl, c
 
	;------  Layout widget  ------------
	top = widget_base(/column, titl='Interactive Cycle/Phase Image')
	b = widget_base(top,/row)
	id = widget_button(b,val='Quit',uval='QUIT')
	id = widget_button(b,val='-',uval='-')
	id = widget_button(b,val='+',uval='+')
	id = widget_button(b,val='Set Min',uval='MIN')
	id = widget_button(b,val='Set Max',uval='MAX')
	id = widget_button(b,val='Back',uval='BACK')
	id = widget_button(b,val='Help',uval='HELP')
 
	b = widget_base(top,/row)
	mnlb = widget_label(b,value=string(ran(0),form='(g13.6)'))
	bb = widget_base(b,/column)
	ids_lb = widget_label(bb,val=string(smn,form='(g13.6)'))
	ids = widget_slider(bb,uval='SLIDE',xsize=400, $
	  min=0, max=500, /drag, /suppress_val)
	mxlb = widget_label(b,value=string(ran(1),form='(g13.6)'))
 
	b = widget_base(top,/row)
	id = widget_label(b,value='Phase')
	id = cw_fslider(b,value=0,uval='PHASE', min=0,max=1,xsize=400,/drag)
 
	;---------  Pack needed info into structure  ---------
	res = widget_base()
	map = {data0:data0, time0:time0, ids:ids, ids_lb:ids_lb, smn:smn, $
	  smx:smx, mnlb:mnlb, mxlb:mxlb, mna:mna, mxa:mxa, ind:ind, $
	  phase:phase, res:res}
	widget_control, top, set_uval=map
 
	;------  Realize  --------------
	widget_control, top, /real
	xmanager, 'xcyph', top
 
	;------  Prepare returned values  ------------
	widget_control, res, get_uval=uval
	slice = uval.slice
	offset = uval.offset
	cyph, data0, time0, slice=slice, offset=offset, cpout=cpout, tout=tout
 
	return
	end
