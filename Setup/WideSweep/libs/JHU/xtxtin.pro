;-------------------------------------------------------------
;+
; NAME:
;       XTXTIN
; PURPOSE:
;       Widget based text input.
; CATEGORY:
; CALLING SEQUENCE:
;       xtxtin, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=tt   Widget title text (def="Enter text").
;           May be a text array.
;         DEFAULT=def  Initial text string (def=null).
;         GROUP_LEADER=g Give group leader (needed if called
;           from another widget routine).  Can use the top level
;           base wid of the calling routine.
;         XSIZE=text entry area size in characters (minimum).
;         YSIZE=text entry area number of lines (def=1).
;           If YSIZE used then must exit with 'Accept Entry' button.
;         XOFFSET=xoff, YOFFSET=yoff Widget position.
;         OK=ok_txt Text for OK button (def="Accept entry").
;         CLEAR=clr_txt  Text for Clear button (def="Clear text").
;         CANCEL=cnc_txt Text for Cancel button (def="Cancel entry").
;         Extra buttons, 3 sets, all optional:
;         MENU=txt   Text array of labels for added menu buttons.
;           Clicking a menu button returns its label text.
;         /ROW means add menu buttons in a row (use short labels).
;         /TOP means put menu buttons on top (def=bottom).
;         MBLAB=mblab Label for menu button (def="-").
;         Presets: Dropdown menu button with preset text.
;           Clicking puts new text in text area from pvals.
;         PTITLE=pttl Title on preset text button (scalar).
;         PTAGS=ptags Text array with short tags for preset text.
;         PVALS=pvals Text array of preset text strings (def=PTAGS).
;          Must give at least PTITLE and PTAGS to use preset text.
;         Extra command buttons: may give a few extra command
;           buttons that look like the OK, CLEAR, and CANCEL
;           buttons.  Returns value when clicked.
;         XTAGS=xtags Text array with button labels.
;         XVALS=xvals Text array with text to return (def=XTAGS).
;         May also have optional flags:
;         FTAG=ftag  Flag label(s).
;         FDEF=fdef  Flag default setting(s) (0 or 1).
;         FOUT=fout  Returned flag setting(s).
; OUTPUTS:
;       out = Returned text string (null for CANCEL).    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Mar, 14
;       R. Sterner, 1995 Mar 21 --- Added optional buttons.
;       R. Sterner, 1998 Jun  3 --- Added xoff, yoff.
;       R. Sterner, 2000 Aug 22 --- Added preset text keywords.
;       R. Sterner, 2000 Aug 30 --- Ignored null strings for ptags.
;       R. Sterner, 2002 Jun 14 --- Allowed custom button labels.
;       R. Sterner, 2002 Jun 25 --- Added extra command buttons.
;       R. Sterner, 2002 Jul 17 --- Added optional flags.
;       R. Sterner, 2002 Jul 19 --- Fixed bug and cleaned up.
;       R. Sterner, 2002 Sep 06 --- Added /ROW and MBLAB= keywords.
;       R. Sterner, 2004 Apr 29 --- Upgraded to IDL5+ modal method.
;       R. Sterner, 2004 Jul 13 --- Allowed multiline input (YSIZE).
;       R. Sterner, 2006 Mar 03 --- Fixed problem when calling from a widget.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xtxtin_event, ev
 
	widget_control, ev.id, get_uval=name	; Get button uval.
	widget_control, ev.top, get_uval=m	; Get info structure.
 
	;------  OK button or return in text area  -----------
	if (name eq 'OK') or (name eq 'TEXT') then begin
done:	  widget_control, m.idtxt, get_val=val
	  if n_elements(val) eq 1 then val=val(0)
	  widget_control, m.res, set_uval={val:val,flag:m.fout}
	  widget_control, ev.top, /dest
	  return
	endif
 
	;------  Clear text area button  ------------
	if name eq 'CLEAR' then begin
	  widget_control, ev.top, get_uval=wids
	  widget_control, m.idtxt, set_val=''
	  widget_control, ev.top, tlb_set_title=''
	  return
	endif
 
	;------  Cancel button  ------------------
	if name eq 'CANCEL' then begin
	  widget_control, ev.top, get_uval=wids
	  widget_control, m.res, set_uval={val:'',flag:m.fout}
	  widget_control, ev.top, /dest
	  return
	endif
 
	;-----  Preset text dropdown menu button  ---------
	if getwrd(name) eq 'PRE' then begin
	  widget_control, m.idtxt, set_val=getwrd(name,1,99)
	  widget_control, ev.id, get_val=ttl
	  widget_control, ev.top, tlb_set_title=ttl
	  return
	endif
 
	;------  Extra command button  -------------
	if strmid(name,0,8) eq 'XCOMMAND' then begin
	  in = strmid(name,8,1)+0
	  widget_control, m.res, set_uval= $
	      {val:m.xvals(in),flag:m.fout}
	  widget_control, ev.top, /dest
	  return
	endif
 
	;------  Flags  ----------------------------
	if strmid(name,0,4) eq 'FLAG' then begin
	  i = strmid(name,4,99)+0
	  m.fout(i) = ev.select
	  widget_control, ev.top, set_uval=m
	  return
	endif
 
	;------  Multiline text area  -----------
	if name eq 'YTEXT' then return
 
	;----  Assume Menu button (uval=index into menu) ------- 
	menu = m.menu
	widget_control, m.res, set_uval={val:menu(name+0),flag:m.fout}
	widget_control, ev.top, /dest
	return
 
	end
 
;=====================================================================
;	xtxtin.pro = Widget text input.
;	R. Sterner, 1994 Mar 14.
;=====================================================================
 
	pro xtxtin, out, title=title, default=def, xsize=xsize, $
	  ysize=ysize, $
	  menu=menu, top=btop, help=hlp, xoffset=xoff, yoffset=yoff, $
	  ptitle=ptitle, ptags=ptags, pvals=pvals, ok=ok_txt, $
	  clear=clear_txt, cancel=cancel_txt, xtags=xtags, xvals=xvals, $
	  ftag=ftag, fdef=fdef, fout=fout, row=brow, mblab=mblab, $
	  group_leader=grp
 
	if keyword_set(hlp) then begin
	  print,' Widget based text input.'
	  print,' xtxtin, out'
	  print,'   out = Returned text string (null for CANCEL).    out'
	  print,' Keywords:'
	  print,'   TITLE=tt   Widget title text (def="Enter text").'
	  print,'     May be a text array.'
	  print,'   DEFAULT=def  Initial text string (def=null).'
          print,'   GROUP_LEADER=g Give group leader (needed if called'
	  print,'     from another widget routine).  Can use the top level'
	  print,'     base wid of the calling routine.'
	  print,'   XSIZE=text entry area size in characters (minimum).'
	  print,'   YSIZE=text entry area number of lines (def=1).'
	  print,"     If YSIZE used then must exit with 'Accept Entry' button."
	  print,'   XOFFSET=xoff, YOFFSET=yoff Widget position.'
	  print,'   OK=ok_txt Text for OK button (def="Accept entry").'
	  print,'   CLEAR=clr_txt  Text for Clear button (def="Clear text").'
	  print,'   CANCEL=cnc_txt Text for Cancel button (def="Cancel entry").'
	  print,'   Extra buttons, 3 sets, all optional:'
	  print,'   MENU=txt   Text array of labels for added menu buttons.'
	  print,'     Clicking a menu button returns its label text.'
	  print,'   /ROW means add menu buttons in a row (use short labels).'
	  print,'   /TOP means put menu buttons on top (def=bottom).'
	  print,'   MBLAB=mblab Label for menu button (def="-").'
	  print,'   Presets: Dropdown menu button with preset text.'
	  print,'     Clicking puts new text in text area from pvals.'
	  print,'   PTITLE=pttl Title on preset text button (scalar).'
	  print,'   PTAGS=ptags Text array with short tags for preset text.'
	  print,'   PVALS=pvals Text array of preset text strings (def=PTAGS).'
	  print,'    Must give at least PTITLE and PTAGS to use preset text.'
	  print,'   Extra command buttons: may give a few extra command'
	  print,'     buttons that look like the OK, CLEAR, and CANCEL'
	  print,'     buttons.  Returns value when clicked.'
	  print,'   XTAGS=xtags Text array with button labels.'
	  print,'   XVALS=xvals Text array with text to return (def=XTAGS).'
	  print,'   May also have optional flags:'
	  print,'   FTAG=ftag  Flag label(s).'
	  print,'   FDEF=fdef  Flag default setting(s) (0 or 1).'
	  print,'   FOUT=fout  Returned flag setting(s).'
	  return
	endif
 
	;-----  Defaults  -----------------
	if n_elements(title) eq 0 then title='Enter text'
	if n_elements(def) eq 0 then def=''
	if n_elements(ok_txt) eq 0 then ok_txt='Accept entry'
	if n_elements(clear_txt) eq 0 then clear_txt='Clear entry'
	if n_elements(cancel_txt) eq 0 then cancel_txt='Cancel entry'
	if n_elements(mblab) eq 0 then mblab='-'
 
	;------  Lay out widget  ----------
	if float(!version.release) GE 5 AND n_elements(grp) GT 0 THEN $
          wmodal = {Modal:1, Group_Leader:grp}
	top = widget_base(/col,title=' ',xoff=xoff,yoff=yoff,_extra=wmodal)
	n = n_elements(title)
	m = max(strlen(title))
	if n_elements(xsize) ne 0 then m=m>xsize
	id = widget_text(top,xsize=m,ysize=n,val=title)
	;-------  Deal with YSIZE  --------------------------
	tuval = 'TEXT'
	scroll = 0
	if n_elements(ysize) gt 0 then begin
	  if ysize gt 1 then begin
	    ysz=ysize
	    tuval='YTEXT'
	    scroll = 1
	  endif else begin
	    ysz=1
	  endelse
	endif else ysz=1
	;-------  Text entry above any buttons (def)  -------
	if not keyword_set(btop) then $
	  idtxt = widget_text(top,/edit,xsize=40,ysize=ysz,val=def, $
	    scroll=scroll, uval=tuval)
	;-------  Optional buttons  ------
	nm = n_elements(menu)
	if nm gt 0 then begin
	  base = top						; Menu in column.
	  if keyword_set(brow) then base=widget_base(top,/row)	; Menu in row.
	  for i = 0, nm-1 do begin
	    b = widget_base(base,/row)
	    id = widget_button(b,val=mblab,uval=strtrim(i,2))
	    id = widget_label(b,val=menu(i))
	  endfor
	endif
	;-------  Text entry below any buttons  -------
	if keyword_set(btop) then $
	  idtxt = widget_text(top,/edit,xsize=40,ysize=ysz,val=def, $
	    scroll=scroll, uval=tuval)
	;------------------------------------------------
	but = widget_base(top, /row)
 
	;----------  Preset text drop down menu button  --------
	if n_elements(ptitle) ne 0 then begin	; Must have a menu title.
	  if n_elements(ptags) eq 0 then begin
	    print,' Error in xtxtin: when using preset text menu must'
	    print,' give arrays of tags and values.'
	    stop
	  endif
	  if n_elements(pvals) eq 0 then pvals=ptags	; Def vals=tags.
	  if n_elements(ptags) ne n_elements(pvals) then begin
	    print,' Error in xtxtin: when using preset text menu must'
	    print,' give same number of tags and values.'
	    stop
	  endif
	  if ptags(0) ne '' then begin		; Menu dropdown menu.
	    b = widget_button(but, val=ptitle,menu=2)
	    for i=0,n_elements(ptags)-1 do begin
	      id = widget_button(b,val=ptags(i),uval='PRE '+pvals(i))
	    endfor
	  endif
	endif
 
	;---------  Standard buttons  ------------------
	bok = widget_button(but, val=ok_txt,uval='OK')
	b = widget_button(but, val=clear_txt,uval='CLEAR')
	b = widget_button(but, val=cancel_txt,uval='CANCEL')
 
	;----------  Extra command buttons  --------------
	if n_elements(xtags) ne 0 then begin
	  if n_elements(xvals) eq 0 then xvals=xtags
	  for i=0,n_elements(xtags)-1 do begin
	    b = widget_button(but, val=xtags(i),uval='XCOMMAND'+strtrim(i,2))
	  endfor
	endif else xvals=['']
 
	;---------  Optional flag(s)  ---------------------
	fid = 0				; Flag widget IDs.
	fout = 0			; Flag return settings (0 or 1).
	if n_elements(ftag) ne 0 then begin		; Any flags?
	  bf = widget_base(top,/nonexclusive,/row)	; Yes, set up a row.
	  nflags = n_elements(ftag)			; How many?
	  if n_elements(fdef) eq 0 then fdef=bytarr(nflags) ; Assure defaults.
	  fout = bytarr(nflags)				; Out settings.
	  fid = lonarr(nflags)				; Flag widget IDs.
	  for i=0,nflags-1 do begin			; Set up flags.
	    b = widget_button(bf,val=ftag(i),uval='FLAG'+strtrim(i,2))
	    fid(i) = b					; Save widget ID.
	    widget_control,b,set_button=(fdef([i]))(0)	; Default setting.
	    fout(i) = fdef([i])				; Save setting.
	  endfor
	endif
 
	;------  Package and store needed info  ------------
	res = widget_base()
	if n_elements(menu) eq 0 then begin
	  map = {idtxt:idtxt, res:res, xvals:xvals, fid:fid, fout:fout}
	endif else begin
	  map = {idtxt:idtxt,res:res,menu:menu,xvals:xvals,fid:fid,fout:fout}
	endelse
	widget_control, top, set_uval=map
 
	;------  realize widget  -----------
	widget_control, top, /real
	if def eq '' then begin
	  widget_control, idtxt, /input_focus
	endif else begin
	  widget_control, bok, /input_focus
	endelse
 
	;------  Event loop  ---------------
;	IF float(!version.release) LT 5 THEN xmodal = {Modal:1}
	IF float(!version.release) GT 5 THEN xmodal = {Modal:1}
	xmanager, 'xtxtin', top, _extra=xmodal
 
	;------  Get result  ---------------
	widget_control, res, get_uval=out0
	out = out0.val
	fout = out0.flag
 
	return
	end
