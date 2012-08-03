;-------------------------------------------------------------
;+
; NAME:
;       XGETVALS
; PURPOSE:
;       General widget to get values.
; CATEGORY:
; CALLING SEQUENCE:
;       xgetvals
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         TITLE=txt Title string or string array (Def="Enter values:").
;         LABELS=lab Array of labels for each value to enter.
;           Each label is an element of a string array and has the text
;           for an item to enter.  A field size may also be given after
;           a separator (def="/", change with SEP=sep).  Example:
;           LABEL=['X min:/5','X max:/5','Y min:','Y max:']
;         TAGS=tags Arrays of tags to use if values are returned in a
;           structure (Default will be V0, V1, ...).
;         SEP=sep  character used to separate label and field size (def=/).
;         DEF=def  Array of default values for each item.
;           If given must have a value for each item (def=blank).
;         ROWS=rows  Array of row numbers for each item.  Example:
;           ROWS=[1,1,2,2]  Just flags when to start next row.
;         LIST=lst  String array defining drop-down lists for specified items.
;           Each element gives a list in the following format:
;           'row, item /menu_1/menu_2/.../menu_n' where row, item gives the
;           row and item # for a text entry area (1 is first).  The drop-down
;           menu will contain the listed menu entries which can be clicked
;           to fill in the text area.
;         BUTTONS=btn String array with optional buttons to fill in values.
;           Each item contains the row number and procedure name separated by
;           the delimeter (see above).  The button will execute the specified
;           procedure which takes one arg, an array of widget IDs for that row
;           Any other values needed by the routine internally should be passed
;           in another call before xgetvals calls it.  For example, the top level
;           base ID might be needed if xtxtin is used in the routine.
;           The routine must fill in the values of all fields in that row. Example:
;           btn=['1/procedure_1','2 / procedure_2']
;         ACT_PRO=actpro Array of user procedure names. Will be executed by an action
;           button. This procedure must take 2 arguments, the structure returned by
;           the STRUCT keyword (STRUCT is not needed for this to work), and a list
;           of widget IDs for all the text entry areas. Ex: userpro, s, idlist.
;           Neither arg need be used in the procedure. Can use the IDLUSR function
;           tag_test to find the index into idlist of a known tag in s.  Note, a set
;           of tag names must be given using the TAGS keyword.
;         ACT_LAB=actlab Labels for the action buttons.
;         ACT_COL=n Action buttons base will have n columns (def=5).
;         INIT_PRO=ipro Name of an initialization procedure.  It must follow the
;           same rules as an action procedure and take the same args.
;         HEAD=hd Row heading text.  String array with optional row headings.
;           Each item contains the row number and heading text separated by
;           the delimeter (see above).  Example:
;           hd=['1/Heading text for row 1','3 / Heading text for row 3']
;         VALS=vals Returned array of values in a string array.
;         STRUCT=svals Values returned in a structure.
;         EXIT=ex  Returned exit code: 0=ok, -1=canceled.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Sep 19
;       R. Sterner, 2003 Jul 10 --- Fixed defaults for byte values.
;       R. Sterner, 2003 Jul 10 --- Allowed non-numericdefault values.
;       R. Sterner, 2003 Jul 10 --- Set input focus to OK button.
;       R. Sterner, 2006 Mar 01 --- Added optional Get Values buttons.
;       R. Sterner, 2006 Mar 02 --- Added optional row headings.
;       R. Sterner, 2006 Mar 03 --- Passed top into button procedures.
;       R. Sterner, 2006 Mar 14 --- Fixed error on a RETURN after text entry.
;       R. Sterner, 2006 Mar 14 --- Added drop-down lists.
;       R. Sterner, 2006 Apr 13 --- Button procedures now only need accept the
;       array of row widget IDs.
;       R. Sterner, 2006 Apr 20 --- Fixed row headings to allow slashes.
;       R. Sterner, 2006 Sep 01 --- Added TAGS=tags, STRUCT=sval.
;       R. Sterner, 2006 Sep 01 --- Added action buttons.  Now this routine
;       can be used as a simple widget program by calling user routines.
;       R. Sterner, 2006 Sep 05 --- Added INIT_PRO.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro xgetvals_event, ev
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=s
 
	if uval eq 'OK' then begin
	  n = n_elements(s.id_list)
	  vals = strarr(n)
	  for i=0,n-1 do begin
	    widget_control, s.id_list(i), get_val=t
	    vals(i) = t(0)
	  endfor
	  out = {vals:vals, ex:0}
	  widget_control, s.res, set_uval=out
	  widget_control, ev.top, /dest
	  return
	endif
 
	if uval eq 'CAN' then begin
	  out = {vals:'', ex:-1}
	  widget_control, s.res, set_uval=out
	  widget_control, ev.top, /dest
	  return
	endif
 
	if getwrd(uval) eq 'ACT' then begin
	  in = getwrd(uval,1)+0			; Index into actpro array.
	  n = n_elements(s.id_list)
	  val = strarr(n)
	  for i=0,n-1 do begin
	    widget_control, s.id_list(i), get_val=t
	    val(i) = t(0)
	  endfor
	  tags = s.tags
	  sval = create_struct(tags(0),val(0))
	  for i=1,n_elements(val)-1 do sval=create_struct(sval,tags(i),val(i))
	  call_procedure,s.actpro(in),sval, s.id_list
	  return
	endif
 
	uval1 = getwrd(uval)
 
	if uval1 eq 'BUT' then begin
	  proc = getwrd(uval,1)
	  txt = getwrd(uval,2,99)
	  wordarray,txt,list
	  widlist = list+0L
	  catch, err
	  if err ne 0 then begin
	    xmess,'Error calling procedure '+proc,/wait
	    catch,/cancel
	    message, /reissue_last
	    return
	  endif
	  call_procedure, proc, widlist	
	  catch,/cancel
	  return
	endif
 
	if uval1 eq 'LIST' then begin
	  wid = getwrd(uval,1)+0L
	  txt = getwrd(uval,2,99)
	  widget_control, wid, set_val=txt
	  return
	endif
 
	end
 
 
	;------------------------------------------------------
	;  xgetvals = main routine
	;------------------------------------------------------
	pro xgetvals, title=tt, vals=val, labels=lab, tags=tags, rows=row, $
	  def=def, sep=sep, exit=ex, help=hlp, buttons=but, head=hd, $
	  list=list, struct=sval, act_lab=actlab, act_pro=actpro, act_col=actcol, $
	  init_pro=initpro
 
	if keyword_set(hlp) then begin
	  print,' General widget to get values.'
	  print,' xgetvals'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   TITLE=txt Title string or string array (Def="Enter values:").'
	  print,'   LABELS=lab Array of labels for each value to enter.'
	  print,'     Each label is an element of a string array and has the text'
	  print,'     for an item to enter.  A field size may also be given after'
	  print,'     a separator (def="/", change with SEP=sep).  Example:'
	  print,"     LABEL=['X min:/5','X max:/5','Y min:','Y max:']"
	  print,'   TAGS=tags Arrays of tags to use if values are returned in a'
	  print,'     structure (Default will be V0, V1, ...).'
	  print,'   SEP=sep  character used to separate label and field size (def=/).'
	  print,'   DEF=def  Array of default values for each item.'
	  print,'     If given must have a value for each item (def=blank).'
	  print,'   ROWS=rows  Array of row numbers for each item.  Example:'
	  print,'     ROWS=[1,1,2,2]  Just flags when to start next row.'
	  print,'   LIST=lst  String array defining drop-down lists for specified items.'
	  print,'     Each element gives a list in the following format:'
	  print,"     'row, item /menu_1/menu_2/.../menu_n' where row, item gives the"
	  print,'     row and item # for a text entry area (1 is first).  The drop-down'
	  print,'     menu will contain the listed menu entries which can be clicked'
	  print,'     to fill in the text area.'
	  print,'   BUTTONS=btn String array with optional buttons to fill in values.'
	  print,'     Each item contains the row number and procedure name separated by'
	  print,'     the delimeter (see above).  The button will execute the specified'
	  print,'     procedure which takes one arg, an array of widget IDs for that row'
	  print,'     Any other values needed by the routine internally should be passed'
	  print,'     in another call before xgetvals calls it.  For example, the top level'
	  print,'     base ID might be needed if xtxtin is used in the routine.'
	  print,'     The routine must fill in the values of all fields in that row. Example:'
	  print,"     btn=['1/procedure_1','2 / procedure_2']"
	  print,'   ACT_PRO=actpro Array of user procedure names. Will be executed by an action'
	  print,'     button. This procedure must take 2 arguments, the structure returned by'
	  print,'     the STRUCT keyword (STRUCT is not needed for this to work), and a list'
	  print,'     of widget IDs for all the text entry areas. Ex: userpro, s, idlist.'
	  print,'     Neither arg need be used in the procedure. Can use the IDLUSR function'
	  print,'     tag_test to find the index into idlist of a known tag in s.  Note, a set'
	  print,'     of tag names must be given using the TAGS keyword.'
	  print,'   ACT_LAB=actlab Labels for the action buttons.'
	  print,'   ACT_COL=n Action buttons base will have n columns (def=5).'
	  print,'   INIT_PRO=ipro Name of an initialization procedure.  It must follow the'
	  print,'     same rules as an action procedure and take the same args.'
	  print,'   HEAD=hd Row heading text.  String array with optional row headings.'
	  print,'     Each item contains the row number and heading text separated by'
	  print,'     the delimeter (see above).  Example:'
	  print,"     hd=['1/Heading text for row 1','3 / Heading text for row 3']"
	  print,'   VALS=vals Returned array of values in a string array.'
	  print,'   STRUCT=svals Values returned in a structure.'
	  print,'   EXIT=ex  Returned exit code: 0=ok, -1=canceled.'
	  return
	endif
 
	;--------  Set defaults  --------------------
	if n_elements(lab) eq 0 then begin
	  print,' Error in xgetvals: must give item labels.'
	  return
	endif
	if n_elements(tags) eq 0 then begin
	  ntags = n_elements(lab)
	  dig = 1 + floor(alog10(ntags-1))
	  tags = 'V'+makes(0,ntags-1,1,dig=dig)
	endif else begin
	  if n_elements(tags) ne n_elements(lab) then begin
	    print,' Error in xgetvals: Number of tags must match number of labels.'
	    return
	  endif
	endelse
	if n_elements(actpro) eq 0 then actpro=''
	if n_elements(actlab) eq 0 then actlab='Action '+makes(1,n_elements(actpro),1)
	if n_elements(actcol) eq 0 then actcol=5
	if n_elements(tt) eq 0 then tt='Enter values:'
	if n_elements(row) eq 0 then row=1+indgen(n_elements(lab))
	if n_elements(def) eq 0 then begin
	  df = strarr(n_elements(lab))
	endif else begin
	  if datatype(def) eq 'BYT' then begin
	    df = strtrim(def+0,2)
	  endif else begin
	    df = strtrim(def,2)
	  endelse
	endelse
	if n_elements(lab) ne n_elements(row) then begin
	  print,' Error in xgetvals: must give a row number for each label.'
	  return
	endif
	if n_elements(lab) ne n_elements(df) then begin
	  print,' Error in xgetvals: must give a default value for each item.'
	  return
	endif
	if n_elements(sep) eq 0 then sep='/'
	bflag = intarr(max(row)+1)		; No buttons by def.
	bproc = strarr(max(row)+1)		; No button procedures by def.
	if n_elements(but) gt 0 then begin	; Have some specified buttons.
	  for i=0,n_elements(but)-1 do begin	; Loop through them.
	    t = but(i)				; Grab i'th button.
	    j = getwrd(t,0,del=sep)+0		; Row number.
	    p = getwrd(t,1,del=sep)		; Procedure name.
	    bflag(j) = 1			; Button for row j.
	    bproc(j) = p			; Procedure name.
	  endfor
	endif
	hflag = intarr(max(row)+1)		; No row headings by def.
	htext = strarr(max(row)+1)		; No heading text by def.
	if n_elements(hd) gt 0 then begin	; Have some row headings.
	  for i=0,n_elements(hd)-1 do begin	; Loop through them.
	    t = hd(i)				; Grab i'th heading.
	    j = getwrd(t,0,del=sep)+0		; Row number.
	    txt = getwrd(t,1,99,del=sep)	; Get heading.
	    hflag(j) = 1			; Heading for row j.
	    htext(j) = txt			; Heading text.
	  endfor
	endif
	list_nx = max(histogram(row)) + 1	; # columns.
	list_ny = max(row) + 1			; # rows
	list_array = strarr(list_nx,list_ny)	; List array, null means no drop-down list.
	if n_elements(list) ne 0 then begin	; Process given drop-down lists.
	  for i=0,n_elements(list)-1 do begin
	    t = list(i)
	    tmp = getwrd(t,0,del=sep)		; Get row and item.
	    iy = getwrd(tmp,0,del=',') + 0	; Row #.
	    ix = (getwrd(tmp,1,del=',') + 0)>1	; Item # (def=1).
	    list_array(ix,iy) = getwrd(t,1,99,del=sep) ; Drop-down menu items.
	  endfor
	endif
 
	;--------  Build widget  --------------
	top = widget_base(/col)
	;-----  Title text  -----------
	for i=0,n_elements(tt)-1 do id=widget_label(top,val=tt(i),/align_left)
	;-----  Entry fields  ---------
	id_list = lonarr(n_elements(lab))	; Field widget IDs.
	last_lab = n_elements(lab)-1		; Last label index.
	rlst = -1				; Last row number.
 
	;------  Loop through labels  ---------
	for i=0, last_lab do begin		; Loop through items.
	  r = row(i)				; Row number.
	  ;-----  Start a new row?  ---------
	  if r ne rlst then begin		; New row?
	    if hflag(r) then begin		; Row heading?
	      id = widget_label(top,val=htext(r),/align_left) ; Display it.
	    endif
	    b = widget_base(top,/row)		; Start new row.
	    widlist = [0L]			; Start list of widget IDs.
	    item0 = i				; First item # i nthis row.
	  endif
	  item = 1 + i - item0			; Item # in row (first is 1).
	  ;------  Decode label text  -------
	  tmp = lab(i)				; Grab label text.
	  n = nwrds(tmp,del=sep)
	  if n eq 1 then begin			; Only 1 item in label, no field size.
	    txt = tmp
	    sz = 10
	  endif else begin			; Might have field size (if a number).
	    sz = getwrd(tmp,del=sep,/last)	; See if field size at end.
	    if isnumber(sz) then begin		; If a number pick off rest as label.
	      txt = getwrd(tmp,del=sep,-99,-1,/last)
	    endif else begin			; Not a number, assume all label.
	      txt = tmp
	      sz = 10
	    endelse
	  endelse
	  ;------  Add labeled text area  ------
	  id = widget_label(b,val=txt)		; Add field label.
	  id_text = widget_text(b,xsize=sz,$	; Add field entry area.
	    /edit,val=df(i),uval='X')
	  id_list(i) = id_text
	  widlist = [widlist,id_text]		; Add text field to widlist.
	  ;------  Optional drop-down list  ---
	  ; At this point: row # is r, item # in row is item.
	  ; If drop-down list for this address then build here.
	  ; set uval to 'LIST WID list_text'
	  ;   WID is wid for text area to set to list_text.
	  tmp = list_array(item,r)
	  if tmp ne '' then begin
	    wordarray,tmp,out,del=sep
	    id_menu = widget_button(b,val='List',/menu)
	    for j=0,n_elements(out)-1 do begin
	      uval = 'LIST '+strtrim(id_text,2)+' '+out(j)
	      id = widget_button(id_menu,val=out(j),uval=uval)
	    endfor
	  endif
	  ;------  At end of row?  ------------
	  row_end_flag = 0			; Assume no.
	  if i eq last_lab then row_end_flag=1	; Last label, so end of row.
	  if row_end_flag eq 0 then begin
	    if row(i+1) ne r then row_end_flag=1  ; Next label is in new row, so end of row.
	  endif
	  if row_end_flag then begin
	    if bflag(r) eq 1 then begin	; Add a button.
	      widlist = widlist(1:*)		; Drop seed value.
	      uval = 'BUT '+bproc(r)+' '+commalist(widlist)	; <===<<< fix widlist.
	      get_txt = 'Get value'+plural(n_elements(widlist))
	      id = widget_label(b,val='  ')
	      id = widget_button(b,val=get_txt,uval=uval)
	    endif
	  endif
	  ;------  Set new last row  ----------
	  rlst = r				; Remember row number.
	endfor
	;------  Action buttons  -----
	if actpro(0) ne '' then begin
	  b = widget_base(top,col=actcol,/frame)
	  for i=0,n_elements(actpro)-1 do begin
	    id = widget_button(b,val=actlab(i), uval='ACT '+strtrim(i,2))
	  endfor
	endif
	;------  Exit buttons  ----------
	b = widget_base(top,/row)
	id_ok = widget_button(b,val='OK', uval='OK')
	id = widget_button(b,val='Cancel', uval='CAN')
 
	;------  Save info  --------------
	res = widget_base()
	s = {id_list:id_list, res:res, actpro:actpro, tags:tags}
	widget_control, top, set_uval=s
 
	;------  Deal with any init pro  ----
	if n_elements(initpro) ge 0 then begin
	  sv = create_struct(tags(0),df(0))
	  for i=1,n_elements(df)-1 do sv=create_struct(sv,tags(i),df(i))
	  call_procedure,initpro,sv,id_list
	endif
 
	;------  Activate widget  --------
	widget_control, top, /realize
	widget_control, id_ok, /input_focus
	xmanager, 'xgetvals', top, /modal
 
	;------  Get returned values  -----
	widget_control, res, get_uval=tmp
	val = tmp.vals
	ex = tmp.ex
	widget_control, res, /dest
	if arg_present(sval) then begin
	  sval = create_struct(tags(0),val(0))
	  for i=1,n_elements(val)-1 do sval=create_struct(sval,tags(i),val(i))
	endif
 
	end
