;-------------------------------------------------------------
;+
; NAME:
;       OBJ_DRAW
; PURPOSE:
;       Display graphical object in a resizable window.
; CATEGORY:
; CALLING SEQUENCE:
;       obj_draw, obj
; INPUTS:
;       obj = Object to display.    in
;         Must have a DRAW method.
;         Should also have a method called XSET which is
;         a widget interface to all plot control parameters.
;         XSET method should accept group_leader and current
;         plot window.
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=ttl Window title (def=none).
;         /NOTITLE  Suppress title bar.  To move window drag
;           while holding down the ALT key.
;         XSIZE=xs, YSIZE=ys  Given initial display window size.
;         WIN=win  returned window ID.
;         WID=wid  returned widget ID for this widget.
;         GROUP_LEADER=group  Set group leader.  When it is
;           iconized or destroyed this widget will be too.
;         ANNOTATE=ann  Name of a procedure called after the
;           objects DRAW method to add annotation.  Optional.
;         /USER_OPTIONS lists notes on adding custom options.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: window may be resized with the pointing device.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Nov 21
;       R. Sterner, 1999 Jun 10 --- returned to this routine.
;       R. Sterner, 1999 Nov 16 --- Added GROUP_LEADER for XSET call.
;       R. Sterner, 1999 Dec 14 --- Improved debug mode.
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro obj_draw_opt, ev
 
	widget_control, ev.top, get_uval=info, /no_copy
	widget_control, ev.id, get_uval=uval
 
	wset, info.win		; Set obj_draw window to be current.
 
 
	case uval of
 
	;--------  Exit  ---------------------------
'EXIT':	begin
	  widget_control, ev.top, /dest
          return
        end
 
	;---------  MODIFY something  ---------------
'MOD':	begin
	  if info.debug eq 0 then begin  ; If debug off set up err handler.
	    catch,err
	    if err ne 0 then begin
	      print,' Error in OBJ_DRAW:'
	      print,'   The given object of class '+obj_class(info.obj)
	      print,'   maybe does not have a method named XSET.'
	      print,'   Such a method should give a widget interface to all'
	      print,'   available plot control parameters.  It must also'
	      print,'   accept a group leader.'
	      print,'   Use Options menu to toggle Debug mode on and try again.'
	      widget_control, ev.top, set_uval=info, /no_copy
	      return
	    endif
	  endif
          info.obj->xset, window=info.win, group_leader=ev.top
        end
 
	;--------  Load a color table  -------------
'CLT':	begin
	  xloadct
	end
 
	;--------  Toggle debug mode  -------------
'DEBUG': begin
	  info.debug = 1 - info.debug
	  if info.debug eq 0 then print,' Debug mode OFF' $
	    else print,' Debug ON'
	end
 
	;-------  Assume a user option  ------------
else:	begin
	  print,' User option: '+uval
	  call_procedure, uval, info.obj, info.ann
	end
	endcase
 
	widget_control, ev.top, set_uval=info, /no_copy	; Put info back in top.
 
	end
 
 
;==================================================
;	Resize
;==================================================
	pro obj_draw_event, ev
 
	widget_control, ev.top, get_uval=info, /no_copy
 
	widget_control, info.drawid, draw_xs=ev.x, draw_ys=ev.y
	wset, info.win
	info.obj->draw
	if info.ann ne '' then call_procedure, info.ann
	widget_control, ev.top, set_uval=info, /no_copy
	return
 
	end
 
;==================================================
;	Main program
;==================================================
 
	pro obj_draw, obj, xsize=xsize, ysize=ysize, win=win, $
	  title=title, annotate=ann, user_options=usr_opt, help=hlp, $
	  notitle=notitle, wid=tlb, group_leader=group
 
	if keyword_set(hlp) then begin
	  print,' Display graphical object in a resizable window.'
	  print,' obj_draw, obj'
	  print,'   obj = Object to display.    in'
	  print,'     Must have a DRAW method.'
	  print,'     Should also have a method called XSET which is'
	  print,'     a widget interface to all plot control parameters.'
	  print,'     XSET method should accept group_leader and current'
	  print,'     plot window.'
	  print,' Keywords:'
	  print,'   TITLE=ttl Window title (def=none).'
          print,'   /NOTITLE  Suppress title bar.  To move window drag'
          print,'     while holding down the ALT key.'
	  print,'   XSIZE=xs, YSIZE=ys  Given initial display window size.'
	  print,'   WIN=win  returned window ID.'
	  print,'   WID=wid  returned widget ID for this widget.'
	  print,'   GROUP_LEADER=group  Set group leader.  When it is'
	  print,'     iconized or destroyed this widget will be too.'
	  print,'   ANNOTATE=ann  Name of a procedure called after the'
	  print,'     objects DRAW method to add annotation.  Optional.'
	  print,'   /USER_OPTIONS lists notes on adding custom options.'
	  print,' Notes: window may be resized with the pointing device.'
	  return
	endif
 
        ;------  Check if notes on user options requested  -------
	if keyword_set(usr_opt) then begin
	text_block
;  If obj_draw.txt exists in local or home directory then read it.
;  It defines commands using the following format:
;      menu = menu text
;      command_1  label text for command_1
;      command_2  label text for command_2
;      . . .
;  The menu line is optional, it gives the label to appear on
;  the menu bar of obj_draw (def=User_Options).
;  The commands are names of procedures to call when that
;  option is selected.  These procedures must accept 2 arguments
;  (even if they don't use them): the object, and the annotate
;  routine.  Also when the user procedure is called it can assume
;  the obj_draw window is the current window.
	  return
	endif
 
	if n_elements(obj) eq 0 then return
 
	;-----  Defaults  -----------
	if n_elements(title) eq 0 then title=' '
	if keyword_set(notitle) then f_att=4 else f_att=2
	if n_elements(xsize) eq 0 then xsize=400
	if n_elements(ysize) eq 0 then ysize=400
	if n_elements(ann) eq 0 then ann=''
	if n_elements(group) eq 0 then group=0
 
	;------  Set up a resizeable window  -------
	print,' Initial window size: ',xsize,ysize
	tlb = widget_base(titl=title,/tlb_size_events,mbar=bar, $
	  tlb_frame_attr=f_att, group_leader=group)
	drawid = widget_draw(tlb,xs=xsize,ys=ysize)
 
	;------  Fill in menu bar pull down menus  --------
	id_cmd = widget_button(bar,val='Options',/menu, $
	    event_pro='obj_draw_opt')
	  id = widget_button(id_cmd,val='Exit',uval='EXIT')
	  id = widget_button(id_cmd,val='Modify plot',uval='MOD')
	  id = widget_button(id_cmd,val='Debug mode',uval='DEBUG',/sep)
	  id = widget_button(id_cmd,val='Load Color Table',uval='CLT')
 
	;------  Add user options if any found  --------
	;------  Read obj_draw.txt = user options  -----------
	optfile = 'obj_draw.txt'		; Try for a local cile.
	ff = findfile(optfile, count=cnt)
	if cnt eq 0 then begin			; None, try in HOME.
	  optfile = filename(getenv('HOME'),optfile,/nosym)
	  ff = findfile(optfile, count=cnt)
	endif
	;-----  Extract user options and add to a top base menu  -------
	if cnt gt 0 then begin			; Found obj_draw options file.
	  a = getfile(ff(0),err=err,/q)		; Read it.
	  if err eq 0 then begin
	    a = drop_comments(a)
	    menu_txt = 'User_Options'		; Look for menu text.
	    sp = strpos(a,'=')
	    w = where(sp ge 0, c)
	    if c gt 0 then menu_txt=getwrd(a(w(0)),del='=',1,99)  ; Menu text.
	    w = where(sp lt 0)			; Non-menu text lines.
	    a = a(w)				; Drop menu text line.
	    id_usr = widget_button(bar,val=menu_txt,/menu, $
	        event_pro='obj_draw_opt')
	    for i=0,n_elements(a)-1 do begin	; Loop through options.
	      cmd = getwrd(a(i))		; Procedure name.
	      txt = getwrd(a(i),1,99)		; Menu text.
	      id = widget_button(id_usr,val=txt,uval=cmd)
	    endfor
	  endif  ; err
	endif  ; cnt
 
	;------  Activate window and plot initial display  -----
	widget_control, tlb, /real
	widget_control, drawid, get_val=win
	wset, win
	obj->draw
	if ann ne '' then call_procedure, ann
 
	;-------  Store the needed info  ----------
help,win
	info = {obj:obj, win:win, drawid:drawid, ann:ann, debug:0}
	widget_control, tlb, set_uval=info, /no_copy
 
	;-----  Send to xmanager  -------------
	xmanager, 'obj_draw', tlb, /no_block, event_handler='obj_draw_event'
 
	end
