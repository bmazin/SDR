;-------------------------------------------------------------
;+
; NAME:
;       IMGMASK
; PURPOSE:
;       Create a mask from an image.
; CATEGORY:
; CALLING SEQUENCE:
;       imgmask
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: a color is specified and the mask is created
;       using a threshhold based on that color.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Nov 29
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro imgmask_th, m
 
	handle_value, m.hflg, flg		; Get modified flag.
	if flg eq '' then return		; No condition.
	widget_control, m.idc,get_val=th & th=th(0)	; Get color.
	txt = 'Image values '+flg+' '+th	; New label.
	widget_control, m.idcur,set_val=txt	; Display new label.
	th = th+0				; Color as a number.
	i = bindgen(256)			; New color table.
	case flg of				; Threshhold.
'LT':	  j = (i lt th)*255
'LE':	  j = (i le th)*255
'EQ':	  j = (i eq th)*255
'GE':	  j = (i ge th)*255
'GT':	  j = (i gt th)*255
	endcase
	tvlct,j,j,j				; Display result.
	return
	end
 
;=================================================================
;       imgmask_update = Update button labels for new color.
;       R. Sterner, 1995 Nov 10
;=================================================================
 
	pro imgmask_update, m
 
	widget_control, m.idc, get_val=clr
	clr = strtrim(clr(0),2)
	widget_control, m.idlt, set_val='Image value LT '+clr
	widget_control, m.idle, set_val='Image value LE '+clr
	widget_control, m.ideq, set_val='Image value EQ '+clr
	widget_control, m.idge, set_val='Image value GE '+clr
	widget_control, m.idgt, set_val='Image value GT '+clr
 
	return
	end
 
 
;=================================================================
;       imgmask_event = Event handler.
;       R. Sterner, 1995 Nov 10
;=================================================================
 
        pro imgmask_event, ev
 
        widget_control, ev.id, get_uval=uval
        widget_control, ev.top, get_uval=m
 
        if uval eq 'DONE' then begin
	  handle_value, m.hflg, flg
	  if flg ne '' then begin
	    handle_value, m.himg0, img
	    tvlct,r,g,b,/get
	    tv,r(img) gt 0
	    tvlct,[0,255],[0,255],[0,255]
	  endif
          widget_control, ev.top, /dest
          return
        endif
 
        if uval eq 'CANCEL' then begin
	  handle_value, m.hflg, flg
	  if flg ne '' then begin
	    handle_value, m.himg0, img
	    handle_value, m.hr0, r
	    handle_value, m.hg0, g
	    handle_value, m.hb0, b
	    tvlct,r,g,b
	    tv,img
	  endif
          widget_control, ev.top, /dest
          return
        endif
 
        if uval eq 'COLOR' then begin
	  imgmask_update, m			; Update button labels.
	  imgmask_th, m				; Do threshhold.
          return
        endif
 
        if uval eq 'SEL' then begin
	  wshow
	  handle_value, m.hix, ix
	  handle_value, m.hiy, iy
	  crossi,ix,iy,/dev,/pixel,/mag,col=-2
	  handle_value, m.hix, ix, /set
	  handle_value, m.hiy, iy, /set
	  handle_value, m.himg0, img
	  widget_control, m.idc,set_val=strtrim(fix(img(ix,iy)),2)
	  imgmask_update, m			; Update button labels.
	  imgmask_th, m				; Do threshhold.
	  widget_control, ev.id, /input_focus
          return
        endif
 
	if getwrd(uval) eq 'TH' then begin
	  typ = getwrd('',1)			; Pick off LT,LE,EQ,GE,GT.
	  handle_value, m.hflg, typ, /set	; Set modified flag.
	  imgmask_th, m				; Do threshhold.
	  return
	endif
 
	if getwrd(uval) eq 'RES' then begin
	  widget_control,m.idcur,set_val='No condition has been selected yet'
	  handle_value, m.hr0, r
	  handle_value, m.hg0, g
	  handle_value, m.hb0, b
	  tvlct,r,g,b
	  handle_value, m.hflg, '', /set	; Clear modified flag.
	  return
	endif
 
	if getwrd(uval) eq 'HELP' then begin
	  xhelp,['This routine is used to convert a grayscale',$
	 	 'image to a binary image using threshhold like',$
		 'operations.',$
		 ' ',$
		 'Select a color value either by entering it',$
		 'directly or by selecting it from the image.',$
		 ' ',$
		 'Once the color has been selected use one of the',$
		 'buttons to display the indicated condition.',$
		 'Other condition buttons may be tried.',$
		 'Use the Reset button to return the image to its',$
		 'original state if desired.',$
		 ' ',$
		 'The Cancel button returns the image to its',$
		 'original state and then exits the routine.',$
		 ' ',$
		 'The Done button will modify the image and the',$
		 'color table to give a binary result, display it',$
		 'with white where the selected condition is true,',$
		 'and then exit.']
	  return
	endif
 
        print,uval
 
	return
	end
 
 
;=================================================================
;       imgmask = Create a mask from an image.
;       R. Sterner, 1995 Nov 10
;=================================================================
 
        pro imgmask, help=hlp
 
        if keyword_set(hlp) then begin
          print,' Create a mask from an image.'
	  print,' imgmask'
	  print,'   No arguments, widget based.'
	  print,' Notes: a color is specified and the mask is created'
	  print,' using a threshhold based on that color.'
	  return
        endif
 
        ;-------  Widget layout  -------------
        top = widget_base(/column,title=' ')
        ;---------------------------------------
	id = widget_label(top,value='Create an image mask')
	b = widget_base(top,/row)
	id = widget_label(b,val='Color = ')
	idc = widget_text(b,value='100',/edit, uval='COLOR',xsize=5)
	id = widget_button(b,val='Select color from image',uval='SEL') 
	;---------------------------------------
	bm = widget_base(top,/column,/frame)
	id = widget_label(bm,val='Select one of the following conditions: ')
	b = widget_base(bm,/row)
	idlt = widget_button(b,val='Image value LT 100',uval='TH LT')
	b = widget_base(bm,/row)
	idle = widget_button(b,val='Image value LE 100',uval='TH LE')
	b = widget_base(bm,/row)
	ideq = widget_button(b,val='Image value EQ 100',uval='TH EQ')
	b = widget_base(bm,/row)
	idge = widget_button(b,val='Image value GE 100',uval='TH GE')
	b = widget_base(bm,/row)
	idgt = widget_button(b,val='Image value GT 100',uval='TH GT')
	b = widget_base(bm,/row)
	id = widget_button(b,val='Reset image',uval='RES')
	idcur = widget_label(b,/dynamic,/align_center,$
	  val='No condition has been selected yet')
	;---------------------------------------
	b = widget_base(top,/row)
	id = widget_button(b,val='Done',uval='DONE')
	id = widget_button(b,val='Cancel',uval='CANCEL')
	id = widget_button(b,val='Help',uval='HELP')
 
        ;--------  Activate  -----------------
        widget_control, top, /real
 
	;--------  Get variables  ------------
	tvlct,r,g,b,/get
	img = tvrd()
	ix = !d.x_size/2
	iy = !d.y_size/2
	;-------- Create needed handles  ----------
	hr0   = handle_create()   ; Original CT red component.
	hg0   = handle_create()   ; Original CT grn component.
	hb0   = handle_create()   ; Original CT blu component.
	himg0 = handle_create()   ; Original image.
	hix   = handle_create()   ; Cursor X.
	hiy   = handle_create()   ; Cursor Y.
	hflg  = handle_create()   ; Modified flag.
	;-----  Set known handle values  ---------
	handle_value, hr0,     r, /set
	handle_value, hg0,     g, /set
	handle_value, hb0,     b, /set
	handle_value, himg0, img, /set
	handle_value, hix,    ix, /set
	handle_value, hiy,    iy, /set
	handle_value, hflg,   '', /set
	;--------  Map  ----------------------
	map = {idc:idc, idlt:idlt, idle:idle,            $	; Constants.
	       ideq:ideq, idge:idge, idgt:idgt, idcur:idcur, $
	       hr0:hr0, hg0:hg0, hb0:hb0, himg0:himg0,   $	; Variables.
	       hix:hix, hiy:hiy, hflg:hflg}
	widget_control, top, set_uval=map
 
	xmanager, 'imgmask', top
 
	return
	end
