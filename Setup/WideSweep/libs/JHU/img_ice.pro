;-------------------------------------------------------------
;+
; NAME:
;       IMG_ICE
; PURPOSE:
;       Color image interactive contrast enhancement.
; CATEGORY:
; CALLING SEQUENCE:
;       img_ice, img
; INPUTS:
;       img = Image to scale.  Need not be 8 bit.  in
;          Allowed data types: Byte, Int, Uint.
;          8-bit images are 2-D, full color images are
;          3-D, interleaved in dimension 1, 2, or 3 as
;          usual even if they are INT or UINT data type.
; KEYWORD PARAMETERS:
;       Keywords:
;         SCALE=sc  Returned image scaling structure.
;           Structure: {rx:rx,ry:ry,gx:gx,gy:gy,bx:bx,by:by}
;           These values are from -1 to 1.
;           x is related to brightness, y to contrast.
;           For CANCEL sc.rx is returned as -999, so check
;           after calling img_ice before using sc.
;           Scale image using img_ce,img,sc,out=img2
;         /LOCK Start with all channels locked together for scaling.
;         /RESTORE  Add Save/Restore state buttons useful
;           for saving/restoring intermediate results.
;         /LAST save last scaling on exit.  Will be available
;           under Restore button on future calls to img_ice.
;           Creates img_ice_last_scaling.txt in local directory:
;         LABELS=lab Optional text array of short channel labels.
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Image is not actually scaled, the scaling is
;         determined but not applied.  Use img_ce to apply
;         scaling: img_ce,img,sc,out=img2
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jun 06
;       R. Sterner, 2002 Jun 18 --- Added default save name, marker x,y list.
;       R. Sterner, 2002 Jun 18 --- Fixed problem with not deleting window.
;       R. Sterner, 2002 Jun 24 --- Added Save/Restore options.
;       R. Sterner, 2003 Sep 23 --- Added error flag.
;       R. Sterner, 2007 Apr 27 --- Added channel lock to scale together.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;-------------------------------------------------------------------
;	img_ice_1ch = Display single channel
;-------------------------------------------------------------------
	pro img_ice_1ch, s
 
	;-------  Display one channel as grayscale (current)  -------
	case s.ch>0 of
1:	img_ice_disp, s.r, 1, s, s.scl.rx, s.scl.ry
2:	img_ice_disp, s.g, 2, s, s.scl.gx, s.scl.gy
3:	img_ice_disp, s.b, 3, s, s.scl.bx, s.scl.by
	endcase
 
	end
 
 
;-------------------------------------------------------------------
;	img_ice_clr = Display full color image
;-------------------------------------------------------------------
 
	pro img_ice_clr, s
 
	;---------  Display all channels (full color)  -----
	img_ice_disp, s.r, 1, s, s.scl.rx, s.scl.ry
	img_ice_disp, s.g, 2, s, s.scl.gx, s.scl.gy
	img_ice_disp, s.b, 3, s, s.scl.bx, s.scl.by
 
	end
 
 
;-------------------------------------------------------------------
;	img_ice_disp = Scale and display image channel
;	cimg = channel image array (R,G,B or 8-bit grayscale).
;	ch = channel number: r=1,g=2,b=3, grayscale=0.
;	s = info structure.
;	xnew, ynew = floating scaling coordinates.
;	Outputs: slp=slp, off=off
;-------------------------------------------------------------------
 
	pro img_ice_disp, cimg, ch, s, xnew, ynew, slp=slp, off=off
 
	;------  Compute new scaling function  ---------
	yy = (90*ynew)<90>(-90)		; Angle.
	slp = tan(yy/!radeg)		; Slope
	if slp eq 0 then slpr=1000. else slpr=1/abs(slp)
	off = xnew*(1+slpr)		; Offset.
 
	;------  Scale color component  ------------------
	v = slp*(s.x_in-off)>(-1)<1
	y_out = 127.5*(v+1)
	ch_out = y_out(cimg-s.x_mn)	; Scale color component.
	wset,s.win_img			; Set to image window.
	dch = ch
	if s.dmode eq 0 then dch=0	; B&W or CLR display?
	tv,ch_out,chan=dch		; Display scaled color.
 
	end
 
 
;-------------------------------------------------------------------
;	img_ice_mvpt = Move marker point
;	  s = info structure
;	  ixnew, iynew = Device coord (where clicked).
;	  /DATA means ixnew, iynew are really data coord.
;-------------------------------------------------------------------
 
	pro img_ice_mvpt, s, ixnew, iynew, data=data
 
	;-------  Find data coordinates from device  -------
	wset, s.win
	if not keyword_set(data) then begin
	  tmp = convert_coord(ixnew,iynew,/device,/to_data)
	  xnew = tmp(0)
	  ynew = tmp(1)>(-0.999)
	endif else begin
	  xnew = ixnew
	  ynew = iynew
	endelse
 
	;---  Grab last data coordinates and scaling function  -----
	case s.ch of
1:	begin	; RED
	  vy0 = s.vyr		; Last scaling function.
	  cimg = s.r		; Channel image.
	  x = s.scl.rx		; Last position.
	  y = s.scl.ry
	  s.scl.rx = xnew	; New position.
	  s.scl.ry = ynew
	  wmsk = 16711680L
	end
2:	begin	; GREEN
	  vy0 = s.vyg
	  cimg = s.g
	  x = s.scl.gx
	  y = s.scl.gy
	  s.scl.gx = xnew
	  s.scl.gy = ynew
	  wmsk = 65280L
	end	; BLUE
3:	begin
	  vy0 = s.vyb
	  cimg = s.b
	  x = s.scl.bx
	  y = s.scl.by
	  s.scl.bx = xnew
	  s.scl.by = ynew
	  wmsk = 255L
	end
	endcase
 
	;------  8-bit gray scale image  ---------------
	ch = s.ch
	if s.true eq 0 then begin
	  wmsk = -1
	  ch = 0
	endif
 
	;-------  Scale and display image component  ------
	img_ice_disp, cimg, ch, s, xnew, ynew, slp=slp,off=off
 
	;------  Compute new scaling function  ---------
	vy = slp*(s.vx-off)>(-1)<1	; New output function.
 
	;-------  Save new scaling function  ---------
	case s.ch of
1:	s.vyr = vy	; RED
2:	s.vyg = vy	; GREEN
3:	s.vyb = vy	; BLUE
	endcase
 
	wset,s.win	; Set to widget window.
	;-------  XOR mode with channel write mask  --------
	device, set_graph=6, set_write_mask=wmsk  ; XOR
	;------  Erase last marker  -----------
	plots,x,y,psym=8		; Erase old marker.
	;------  Erase old scaling function  ----------
	plots, s.vx, vy0
	empty				; Make sure it's done.
	;------  Plot new marker  -------------
	plots,xnew,ynew,psym=8	; Plot new marker.
	;-------  Plot new scaling function  --------
	plots, s.vx, vy
	empty				; Make sure it's done.
	;--------  COPY mode with full write mask  --------
	device, set_graph=3, set_write_mask=-1    ; COPY
 
 
	end
 
 
;-------------------------------------------------------------------
;	img_ice_event = Event handler
;-------------------------------------------------------------------
 
	pro img_ice_event, ev
 
	widget_control, ev.id, get_uval=cmd
	widget_control, ev.top, get_uval=s
 
	;----  Clicked or dragged in draw widget  --------
	if cmd eq 'DRAW' then begin
	  if ev.type eq 0 then s.drag_mode=1
	  if ev.type eq 1 then s.drag_mode=0
	  if s.drag_mode eq 1 then begin
	    ixnew = ev.x>0<255
	    iynew = ev.y>0<255
	    widget_control, s.id_xy, set_val=string(ixnew,iynew, $
	      form='(I3.3,x,I3.3)')
	    if s.lock eq 1 then begin
	      ch = s.ch
	      s.ch=1 & img_ice_mvpt, s,ixnew,iynew
	      s.ch=2 & img_ice_mvpt, s,ixnew,iynew
	      s.ch=3 & img_ice_mvpt, s,ixnew,iynew
	      s.ch = ch
	    endif else begin
	      img_ice_mvpt, s,ixnew,iynew 
	    endelse
	  endif
	  widget_control, s.top, set_uval=s
	  return
	endif
 
	;------  All done, return  ------------
	if cmd eq 'OK' then begin
	  if s.last then begin
	    scl = s.scl
	    x = [scl.rx,scl.gx,scl.bx]
	    y = [scl.ry,scl.gy,scl.by]
	    ix = fix((x+1)*128)
	    iy = fix((y+1)*128)
	    openw,lun,'img_ice_last_scaling.txt',/get_lun
	    printf,lun,ix
	    printf,lun,iy
	    free_lun,lun
	  endif
	  swdelete, s.win_img
	  widget_control, s.res, set_uval=s.scl
	  widget_control, ev.top, /destroy
	  return
	endif
 
	;-------  Canceled, return  -------------
	if cmd eq 'CANCEL' then begin
	  swdelete, s.win_img
	  scl = s.scl
	  scl.rx = -999		; Set flag value.
	  widget_control, s.res, set_uval=scl
	  widget_control, ev.top, /destroy
	  return
	endif
 
	;-------  Switched to Red channel  ----------
	if cmd eq 'CH_RED' then begin
	  s.ch = 1			; Set current channel to red.
	  widget_control, s.top, set_uval=s,tlb_set_title='Red '+s.lab(0)
	  if s.dmode eq 0 then img_ice_1ch, s	; Display current channel.
	  wset, s.win
	  tmp = fix(convert_coord(s.scl.rx,s.scl.ry,/data,/to_dev))
	  widget_control, s.id_xy, set_val=string(tmp(0),tmp(1), $
	    form='(I3.3,x,I3.3)')
	  return
	endif
	;-------  Switched to Green channel  ----------
	if cmd eq 'CH_GRN' then begin
	  s.ch = 2			; Set current channel to green.
	  widget_control, s.top, set_uval=s,tlb_set_title='Green '+s.lab(1)
	  if s.dmode eq 0 then img_ice_1ch, s	; Display current channel.
	  wset, s.win
	  tmp = fix(convert_coord(s.scl.gx,s.scl.gy,/data,/to_dev))
	  widget_control, s.id_xy, set_val=string(tmp(0),tmp(1), $
	    form='(I3.3,x,I3.3)')
	  return
	endif
	;-------  Switched to Blue channel  ----------
	if cmd eq 'CH_BLU' then begin
	  s.ch = 3			; Set current channel to blue.
	  widget_control, s.top, set_uval=s,tlb_set_title='Blue '+s.lab(2)
	  if s.dmode eq 0 then img_ice_1ch, s	; Display current channel.
	  wset, s.win
	  tmp = fix(convert_coord(s.scl.bx,s.scl.by,/data,/to_dev))
	  widget_control, s.id_xy, set_val=string(tmp(0),tmp(1), $
	    form='(I3.3,x,I3.3)')
	  return
	endif
 
	;--------  Display all channels together (full color)  -----
	if cmd eq 'CH_ALL' then begin
	  s.dmode = ev.select
	  if s.dmode eq 0 then begin		; Single channel.
	    img_ice_1ch, s
	  endif else begin			; Full color.
	    img_ice_clr, s
	  endelse
	  widget_control, s.top, set_uval=s
	  return
	endif
 
	;--------  Lock all channels together for scaling  -----
	if cmd eq 'CH_LCK' then begin
	  s.lock = ev.select			; Vary all channels together.
	  if s.lock eq 1 then begin
	    ch = s.ch
	    case ch of				; Use current ch as reference.
1:	    begin
	      ixnew = s.scl.rx
	      iynew = s.scl.ry
	    end
2:	    begin
	      ixnew = s.scl.gx
	      iynew = s.scl.gy
	    end
3:	    begin
	      ixnew = s.scl.bx
	      iynew = s.scl.by
	    end
	    endcase
	    s.ch=1 & img_ice_mvpt, s,ixnew,iynew, /data	; Update marker.
	    s.scl.rx = ixnew			; Update scaling.
	    s.scl.ry = iynew
	    s.ch=2 & img_ice_mvpt, s,ixnew,iynew, /data
	    s.scl.gx = ixnew
	    s.scl.gy = iynew
	    s.ch=3 & img_ice_mvpt, s,ixnew,iynew, /data
	    s.scl.bx = ixnew
	    s.scl.by = iynew
	    s.ch = ch
	    if s.dmode eq 0 then begin		; Single channel.
	      img_ice_1ch, s
	    endif else begin			; Full color.
	      img_ice_clr, s
	    endelse
	  endif
	  widget_control, s.top, set_uval=s
	  return
	endif
 
	;-------  Display help text  -------------
	if cmd eq 'HELP' then begin
	  txt = ['Interactive Contrast Enhancement',' ']
	  if s.true ne 0 then begin
	    txt = [txt,'Unless the lock button is pressed',$
		'a single channel at a time is adjusted.',$
		'Select which channel to adjust using the channel',$
		'buttons.  The "All" button is selected to display',$
		'all channels as a color image, unselect "All" to',$
		'see just a single channel as a grayscale image.',' ']
	  endif
	  txt = [txt,'The image is adjusted using the graphical area',$
		'at the top of this widget.  Each x,y represents a',$
		'brightness and contrast setting.  The graphical area',$
		'ranges from -1 to +1 in both x and y.  The image',$
		'settings start at x=0.0, y=0.5, the middle of the top',$
		'region.  A marker point shows the current setting.',$
		'x,y values in the top area, the black region, represent',$
		'a positive image.  x,y values in the bottom area',$
		'represent a negative image.  The marker point may be',$
		'dragged using the mouse, the image will update to',$
		'show the current result.  A line corresponds with each',$
		'marker point position and shows the relation between',$
		'the input image value and the scaled output value.']
	  if s.true ne 0 then begin
	    txt = [txt,'For color images the markers and lines are shown in',$
		'the color of the selected channel (negative in lower area).']
	  endif
	  if s.id_rest ne 0 then begin
	    txt = [txt,' ', $
	        'The Save and Restore buttons are useful for keeping track',$
		'of intermediate results.  The Save button saves the current',$
		'scaling and lists a save number.  The Restore button allows',$
		'restoring any saved scaling, the initial scaling is 0.']
	  endif
	  txt = [txt,' ','When finished click on "OK" to accept the',$
		'scaling, or "Cancel" to abort it.']
	  xhelp,txt
	  return
	endif
 
	;-------  Save current scaling state (for later recall)  ------
	if cmd eq 'SAVE' then begin
	  arr_scl = [*s.p_arr_scl,s.scl]	; Grab old array, add current.
	  ptr_free, s.p_arr_scl			; Free pointer.
	  s.p_arr_scl = ptr_new(arr_scl)	; Save new state list.
	  n = n_elements(arr_scl)		; How many.
	  lab = strtrim(n-1,2)			; New state index.
	  id = widget_button(s.id_rest,val=lab,uval='REST') ; Add new button.
	  widget_control, s.id_state,set_val='Save '+lab
	  widget_control, s.top, set_uval=s
	  return
	endif
 
	;--------  Restore a previous scaling state  ------------
	if cmd eq 'REST' then begin
	  arr_scl = *s.p_arr_scl		; Grab array of saved states.
	  widget_control, ev.id, get_val=in	; Grab index into state array.
	  widget_control, s.id_state,set_val='Restore '+in	; List restore.
	  if in eq 'Last' then begin
	    ixnew = bytarr(3)			; Saved as 0-255.
	    iynew = bytarr(3)
	    openr,lun,'img_ice_last_scaling.txt',/get_lun
	    readf,lun,ixnew,iynew
	    free_lun,lun
	    tmp = convert_coord(ixnew,iynew,/device,/to_data)	; -> -1 to 1.
	    scl = arr_scl(0)
	    scl.rx=tmp(0,0) & scl.gx=tmp(0,1) & scl.bx=tmp(0,2)
	    scl.ry=tmp(1,0) & scl.gy=tmp(1,1) & scl.by=tmp(1,2)
	  endif else begin
	    scl = arr_scl(in)			; Requested scaling state.
	  endelse
	  xnew = [scl.rx,scl.gx,scl.bx]		; Scaling values.
	  ynew = [scl.ry,scl.gy,scl.by]
	  chnow = s.ch				; Current channel.
	  if s.true eq 0 then begin		; Single 8-bit image.
	    img_ice_mvpt, s, xnew(0),ynew(0),/data
	  endif else begin			; Full color image.
	    chlist = [2,1,3]			; List of channels to update.
	    chlist = shift(chlist,chnow)	; Reorder to make chnow last.
	    for i=0,2 do begin			; Loop through all channels.
	      ch = chlist(i)
	      s.ch = ch						; Set channel.
	      img_ice_mvpt, s, xnew(ch-1),ynew(ch-1),/data	; Update chan.
	    endfor
	  endelse
	  s.ch = chnow				; Restore channel.
	  s.scl = scl				; Update scaling.
	  widget_control, s.top, set_uval=s	; Save info structure.
	  return
	endif
 
	help,cmd
	help,/st,ev
 
	end
 
 
;-------------------------------------------------------------------
;	img_ice = Main routine
;-------------------------------------------------------------------
 
	pro img_ice, img, scale=sc, restore=rest, labels=lab, $
	  last=last, lock=lock, help=hlp, error=err
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Color image interactive contrast enhancement.'
	  print,' img_ice, img'
	  print,'   img = Image to scale.  Need not be 8 bit.  in'
	  print,'      Allowed data types: Byte, Int, Uint.'
	  print,'      8-bit images are 2-D, full color images are'
	  print,'      3-D, interleaved in dimension 1, 2, or 3 as'
	  print,'      usual even if they are INT or UINT data type.'
	  print,' Keywords:'
	  print,'   SCALE=sc  Returned image scaling structure.'
	  print,'     Structure: {rx:rx,ry:ry,gx:gx,gy:gy,bx:bx,by:by}'
	  print,'     These values are from -1 to 1.'
	  print,'     x is related to brightness, y to contrast.'
	  print,'     For CANCEL sc.rx is returned as -999, so check'
	  print,'     after calling img_ice before using sc.'
	  print,'     Scale image using img_ce,img,sc,out=img2'
	  print,'   /LOCK Start with all channels locked together for scaling.'
	  print,'   /RESTORE  Add Save/Restore state buttons useful'
	  print,'     for saving/restoring intermediate results.'
	  print,'   /LAST save last scaling on exit.  Will be available'
	  print,'     under Restore button on future calls to img_ice.'
	  print,'     Creates img_ice_last_scaling.txt in local directory:'
	  print,'   LABELS=lab Optional text array of short channel labels.'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Note: Image is not actually scaled, the scaling is'
	  print,'   determined but not applied.  Use img_ce to apply'
	  print,'   scaling: img_ce,img,sc,out=img2'
	  return
	endif
 
	if n_elements(lab) eq 0 then lab=['','','']
	if n_elements(last) eq 0 then last=0	; Save last scaling flag.
	if n_elements(lock) eq 0 then lock=0
 
	;--------  Check image type and get type values  ---------
	typ = datatype(img)
	ityp = ''
	case typ of
'BYT':	begin
	  ityp = typ
	  x_mn = 0
	  x_n = 256
	end
'INT':	begin
	  ityp = typ
	  x_mn = -32768
	  x_n = 65536
	end
'UIN':	begin
	  ityp = typ
	  x_mn = 0
	  x_n = 65536
	end
else:
	endcase
	if ityp eq '' then begin
	  print,' Error in img_ice: Allowed image types are'
	  print,'   BYT, INT, UINT.'
	  err = 1
	  return
	endif
	err = 0
	x_in = maken(-1.,1.,x_n)	; Image input.
 
	;--------  Display image  -------------------
	img_disp, img
	win_img = !d.window
 
	;--------  Image components  ----------------
	img_split, img, rr, gg, bb, true=tr	; tr=0 if 8-bit.
 
	;-------  Set up widget  -----------------
	if tr ne 0 then tlb_ttl='Red '+lab(0) else tlb_ttl='Grayscale '+lab(0)
	top = widget_base(title=tlb_ttl,/col)
	id_drw = widget_draw(top,xsize=256,ysize=256,/button_events, $
	  /motion_events, uval='DRAW')
 
	b = widget_base(top,/col,/align_center)	      ; Button area.
 
	if tr ne 0 then begin
	  b1 = widget_base(b,/col,/align_center,/frame) ; Channel buttons.
	  id = widget_label(b1,val='Channels',/align_center)
	  b11 = widget_base(b1,/row)
	  b111 = widget_base(b11,/row,/nonexclusive)
	  id = widget_button(b111,val='All',uval='CH_ALL') ; Start set.
	  widget_control, id, /set_button  ; Start with full color.
	  id = widget_button(b111,val='Lock',uval='CH_LCK') ; Lock all chan.
	  if lock eq 1 then widget_control, id, /set_button
	  b112 = widget_base(b11,/row,/exclusive)
	  idr = widget_button(b112,val='Red',/no_rel,uval='CH_RED')
	  widget_control, idr, /set_button  ; Start with red active.
	  idg = widget_button(b112,val='Green',/no_rel,uval='CH_GRN')
	  idb = widget_button(b112,val='Blue',/no_rel,uval='CH_BLU')
	endif
 
	b2 = widget_base(b,/row,/frame,/align_center) ; Action buttons.
	id = widget_label(b2,val='Actions',/align_center)
	id = widget_button(b2,val='OK',uval='OK')
	id = widget_button(b2,val='Cancel',uval='CANCEL')
	id = widget_button(b2,val='Help',uval='HELP')
	id_xy = widget_text(b2,val='128 192',xsize=7)
 
	if keyword_set(rest) then begin
	  b2 = widget_base(b,/row,/frame,/align_center)  ; Save/Restore state.
	  id = widget_button(b2,val='Save',uval='SAVE')
	  id_rest = widget_button(b2,val='Restore',uval='REST',menu=2)
	    f = findfile('img_ice_last_scaling.txt',count=cnt)
	    if cnt gt 0 then begin
	      id = widget_button(id_rest,val='Last',uval='REST')
	    endif
	    id = widget_button(id_rest,val='0',uval='REST')
	  id_state = widget_text(b2, val=' ',xsize=10)
	endif else begin
	  id_rest = 0L
	  id_state = 0L
	endelse
 
	;-------  Activate widget  ---------------
	widget_control, top, /real
 
	;--------  Set up control window  ------------
	usersym,2*[-1,0,1,0],2*[0,-1,0,1],/fill,col=-1
	widget_control, id_drw, get_val=win
	wset, win
	nx=256. & ny=256. & nx2=nx/2 & ny2=ny/2
	wht = tarclr(255,255,255)
	blk = tarclr(0,0,0)
	polyfill,/dev,[0,nx-1,nx-1,0],[0,0,ny2,ny2],col=wht
;	pos = [.01,.01,.99,.99]
	pos = [0.,0.,1.,1.]
	plot,[-1,1],[-1,1],/nodata,xstyl=5,ystyl=5, $
	  pos=pos, /noerase
	xyouts,-0.05,0.02,'+CONTRAST -->',chars=1.,orient=90
	xyouts,0.05,-0.02,'-CONTRAST -->',chars=1.,orient=-90.,col=blk
	xyouts,-0.8,0.4,'<-- BRIGHTER',chars=1.
	xyouts,0.8,0.4,'DARKER -->',chars=1.,align=1
	xyouts,-0.8,-0.44,'<-- DARKER',chars=1.,col=blk
	xyouts,0.8,-0.44,'BRIGHTER -->',chars=1.,align=1,col=blk
	xyouts,/dev,93,10,'INPUT   VALUES',chars=1.,col=blk
	xyouts,/dev,18,84,'OUTPUT',chars=1.,orient=90.,col=blk
	xyouts,/dev,18,120,'   VALUES',chars=1.,orient=90.,col=wht
        xyouts,-0.05,0.87,'BUTTONS',align=1
        xyouts,0.05,0.87,'LEFT: CHANGE (DRAG)'
	device,set_graph=6	; XOR mode.
        plot,[-1,1],[-1,1],/nodata,xstyl=1,ystyl=1, $
	  pos=pos, /noerase
        hor,[-.5,0,.5]
        ver,0
        vx = maken(-1,1,256)	; Scaling function.
        vy = vx
        oplot,vx,vy
        x = 0			; Initial start point (OUT=IN).
        y = .5
        x2 = x                  ; Remember last used coordinates.
        y2 = y
	tmp = convert_coord(x,y,/data,/to_dev)
	ix=tmp(0) & iy=tmp(1)
        tvcrs,ix,iy		; device xy=nx2,ny*3/4 = data xy=0,.5.
	plots,x,y,psym=8	; Plot initial marker.
	device,set_graph=3	; Normal graph. mode (COPY).
 
	;--------  Scaling structure  --------------
	rx=0.0 & ry=0.5 & gx=0.0 & gy=0.5 & bx=0.0 & by=0.5
	scl = {rx:rx, ry:ry, gx:gx, gy:gy, bx:bx, by:by}
	arr_scl = make_array(1,val=scl)	; Scaling restore array.
 
	;--------  Pack up info  --------------------------
	;  top = Widget ID of top level base.
	;  win =Widget scaling window index.
	;  win_img = Image window number.
	;  scl = R,G,B scaling info.
	;  drag_mode = flag for if dragging.
	;  ch = Channel: r=1,g=2,b=3.
	;  all = flag: 0=display 1 channel, 1=display all (color).
	;  id_xy = Widget ID of x,y display area.
	;  lab = array of channel labels.
	;  r,g,b = Image color components.
	;  true = Pixel interleave index.  true=0 for 8-bit.
	;  x_mn = Image min value. 0 for byt, 0 for uint, -32768 for int).
	;  x_in = Normalized image input array (-1 to 1). For scaling image.
	;  res = unused base widget ID for return value.
	;  vx = small x array for plotting (-1,1).
	;  vyr, vyg, vyb = small y arrays for plotting (R,G,B).
	;  dmode = Display mode: 1=color, 0=single channel.
	;  id_rest = widget ID of Restore button.  For adding new buttons.
	;  id_state = widget ID of save/restore text area.
	;  p_arr_scl = Pointer to a structure array of save scalings.
	;  last = flag: save last scaling on exit: 0=no, 1=yes.
	;--------------------------------------------------
	res = widget_base()  ; Return value unused base.
	s = {top:top, win:win, win_img:win_img, scl:scl, $
	  drag_mode:0, ch:1, all:0, lock:lock, id_xy:id_xy, lab:lab, $
	  r:rr, g:gg, b:bb, true:tr, x_mn:x_mn, x_in:x_in, res:res, $
	  vx:vx, vyr:vy, vyg:vy, vyb:vy, dmode:1, id_rest:id_rest, $
	  id_state:id_state, p_arr_scl:ptr_new(arr_scl), $
	  last:last}
	widget_control, top, set_uval=s
 
	;------  Event loop  ---------------
	xmanager, 'img_ice', top
 
	;------  Get result  ----------------
	widget_control, res, get_uval=sc
 
	end
