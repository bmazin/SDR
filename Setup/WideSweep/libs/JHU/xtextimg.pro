;-------------------------------------------------------------
;+
; NAME:
;       XTEXTIMG
; PURPOSE:
;       Create an image with text.  Widget based.
; CATEGORY:
; CALLING SEQUENCE:
;       xtextimg, file
; INPUTS:
;       file = name of text file to write to image.  in
;         If not given this is prompted for.
; KEYWORD PARAMETERS:
;       Keywords:
;         OUT=out   Name of TIFF image file where text was saved.
;           Null string means no image was saved.
;         XSIZE=xs  Initial image X size in pixels.
;         YSIZE=ys  Initial image Y size in pixels.
;         /WAIT  means wait for returned result.
; OUTPUTS:
; COMMON BLOCKS:
;       xtextimg_com
;       xtextimg_com
; NOTES:
;       Notes: image may be resized just by using the mouse.
;         Text is obtained from a text file.  Default
;         file name is *.cap.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Oct 7.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro xtextimg_up, m
 
	wset, m.win
	erase, m.back
	widget_control, m.id_siz, get_val=sz
	sz = sz/100.
	widget_control, m.id_spc, get_val=sp
	sp = sp/100.
	widget_control, m.id_x, get_val=x
	x = x/500.
	widget_control, m.id_y, get_val=y
	y = y/470.
	widget_control, m.b_txt, get_uval=txt
 
	xprint,/init,/norm,x,y,charsize=sz,charthick=m.thick, dy=sp
	xyouts,/dev,0,0,m.font
	for i = 0, n_elements(txt)-1 do xprint,txt(i),col=m.fore
 
	return
	end
 
;==============================================================
;	xtextimg_event = xtextimg event handler.
;	R. Sterner, 1994 Oct 7.
;==============================================================
 
	pro xtextimg_event, ev
 
	common xtextimg_com, wild, dir, wild2, dir2
 
	widget_control, ev.id, get_uval=uval
	widget_control, ev.top, get_uval=m
 
	if uval eq 'SLIDE' then begin
	  xtextimg_up, m
	  return
	endif
 
	if uval eq 'QUIT' then begin
	  if m.windex gt 0 then begin
	    swdelete, m.windex
	  endif else begin
	    wdelete, m.win
	  endelse
	  widget_control, ev.top, /dest
	  return
	endif
 
	if uval eq 'TCLR' then begin
	  c = m.fore
	  pickcolor, c
	  if c ge 0 then begin
	    m.fore = c
	    wset, m.fwin
	    erase, m.fore
	    widget_control, ev.top, set_uval=m
	  endif
	  xtextimg_up, m
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if uval eq 'BCLR' then begin
	  c = m.back
	  pickcolor, c
	  if c ge 0 then begin
	    m.back = c
	    wset, m.bwin
	    erase, m.back
	    widget_control, ev.top, set_uval=m
	  endif
	  xtextimg_up, m
	  widget_control, ev.id, /input_focus
	  return
	endif
 
	if uval eq 'THICK' then begin
	  widget_control, ev.id, get_val=t
	  m.thick = t+0
	  widget_control, ev.top, set_uval=m
	  widget_control, m.id_th, set_val='Thickness: '+getwrd(t)
	  xtextimg_up, m
	  return
	endif
 
	if uval eq 'FONT' then begin
	  widget_control, ev.id, get_val=t
	  m.font = getwrd(t)
	  widget_control, ev.top, set_uval=m
	  widget_control, m.id_fn, set_val='Font: '+t
	  xtextimg_up, m
	  return
	endif
 
	if uval eq 'EDIT' then begin
	  ed = getenv('EDITOR')
	  if ed eq '' then begin
	    ed = 'vi'
	    xmess,['Could not find environmental variable',$
		'EDITOR.  Using the vi editor as default.',$
		'Set EDITOR to your desired editor.']
	  endif
	  spawn,ed+' '+m.file
	  txt = getfile(m.file)
	  widget_control, m.b_txt, set_uval=txt
	  xtextimg_up, m
	endif
 
	if uval eq 'READ' then begin
	  if n_elements(dir) eq 0 then cd, curr=dir
	  if n_elements(wild) eq 0 then wild = '*.cap'
	  file = pickfile(filter=wild, path=dir, get_path=tdir)
	  if file eq '' then return
	  dir=tdir
	  txt = getfile(file, error=err)
	  if err ne 0 then begin
	    xmess,'Could not open file '+file
	    return
	  endif
	  m.file = file
	  widget_control, m.b_txt, set_uval=txt
	  widget_control, ev.top, set_uval=m
	  xtextimg_up, m
	  return
	endif
 
	if uval eq 'SAVE' then begin
	  file = pickfile(/write, filter=wild2, path=dir2, get_path=tdir)
	  if file eq '' then return
	  dir2 = tdir
	  file = dir2+file
	  xmess, 'Saving image in '+file+' . . .', wid=wid, /nowait
	  t = tvrd()
	  tvlct, r, g, b, /get
	  tiff_write, file, reverse(t,2), 1, red=r, green=g, blue=b
	  widget_control, m.res, set_uval=file
	  widget_control, wid, /dest
	  return
	endif
 
	if uval eq 'CT' then begin
	  ctool
	  return
	endif
 
	return
	end
 
;==============================================================
;	xtextimg.pro = Widget based text image creation
;	R. Sterner, 1994 Oct 7.
;==============================================================
 
	pro xtextimg, file, xsize=xs, ysize=ys, out=out, $
	  wait=wait, help=hlp
 
	common xtextimg_com, wild, dir, wild2, dir2
 
	if keyword_set(hlp) then begin
	  print,' Create an image with text.  Widget based.'
	  print,' xtextimg, file'
	  print,'   file = name of text file to write to image.  in'
	  print,'     If not given this is prompted for.'
	  print,' Keywords:'
	  print,'   OUT=out   Name of TIFF image file where text was saved.'
	  print,'     Null string means no image was saved.'
	  print,'   XSIZE=xs  Initial image X size in pixels.'
	  print,'   YSIZE=ys  Initial image Y size in pixels.'
	  print,'   /WAIT  means wait for returned result.'
	  print,' Notes: image may be resized just by using the mouse.'
	  print,'   Text is obtained from a text file.  Default'
	  print,'   file name is *.cap.'
	  return
	endif
 
	;-------  Set defaults  ----------
	if n_elements(dir2) eq 0 then cd, curr=dir2
	if n_elements(wild2) eq 0 then wild2 = '*.tif'
	out = ''
 
	;-------  Read in text file  -------------
	if n_elements(file) eq 0 then begin
	  ed = getenv('EDITOR')
	  if ed eq '' then begin
	    ed = 'vi'
	    xmess,['Could not find environmental variable',$
  	      'EDITOR.  Using the vi editor as default.',$
	      'Set EDITOR to your desired editor.']
	  endif
	  if n_elements(dir) eq 0 then cd, curr=dir
	  if n_elements(wild) eq 0 then wild = '*.cap'
	  file = pickfile(filter=wild, path=dir, get_path=tdir)
	  wait,0	; Without this it won't work???
	  if file eq '' then begin
	    xtxtin,title='To create a file enter a file name',file, /wait
	    if file eq '' then return
	    filebreak, file, dir=tdir
	    spawn,ed+' '+file
	  endif
	  dir=tdir
	endif
	txt = getfile(file, error=err)
	if err ne 0 then begin
	  xmess,['Could not open file '+file,'Create one now']
	  spawn,ed+' '+file
	  txt = getfile(file, error=err)
	  if err ne 0 then return
	endif
 
	;-------  Create text window  -------------
	if n_elements(xs) eq 0 then xs=400
	if n_elements(ys) eq 0 then ys=300
	if xs>ys gt 900 then begin
	  swindow, xs=xs, ys=ys, x_scr=xs<900, y_scr=ys<900,index=indx
	  windex = indx(2)
	endif else begin
	  window, xs=xs, ys=ys, /free
	  windex = 0L
	endelse
	win = !d.window
	erase, !d.table_size-1
 
	;-------  Defaults  ---------
	fore = 0
	back = !d.table_size-1
	font = '!3'
	thick = 1
 
	;-------  Widget layout  -------------------
	top = widget_base(/column, title='Create a text image')
	;-------  Command buttons --------
	b_txt = widget_base(top, /row)
	id = widget_button(b_txt, val='Quit',uval='QUIT')
	id = widget_button(b_txt, val='Edit file', uval='EDIT')
	id = widget_button(b_txt, val='Read a file', uval='READ')
	id = widget_button(b_txt, val='Save image',uval='SAVE')
	id = widget_button(b_txt, val='Modify color table',uval='CT')
	b = widget_base(top, /row)
	id_th = widget_button(b, val='Thickness: 1', menu=2)
	  id2 = widget_button(id_th, val='    1', uval='THICK')
	  id2 = widget_button(id_th, val='    2', uval='THICK')
	  id2 = widget_button(id_th, val='    3', uval='THICK')
	  id2 = widget_button(id_th, val='    4', uval='THICK')
	  id2 = widget_button(id_th, val='    5', uval='THICK')
	  id2 = widget_button(id_th, val='    6', uval='THICK')
	  id2 = widget_button(id_th, val='    7', uval='THICK')
	  id2 = widget_button(id_th, val='    8', uval='THICK')
	id_fn = widget_button(b, val='Font: !3 Simplex Roman    ', menu=2)
	  id2 = widget_button(id_fn, val='!3 Simplex Roman', uval='FONT')
	  id2 = widget_button(id_fn, val='!4 Simplex Greek', uval='FONT')
	  id2 = widget_button(id_fn, val='!5 Duplex Roman', uval='FONT')
	  id2 = widget_button(id_fn, val='!6 Complex Roman', uval='FONT')
	  id2 = widget_button(id_fn, val='!7 Complex Greek', uval='FONT')
	  id2 = widget_button(id_fn, val='!8 Complex Italic', uval='FONT')
	  id2 = widget_button(id_fn, val='!11 Gothic English', uval='FONT')
	  id2 = widget_button(id_fn, val='!12 Simplex Script', uval='FONT')
	  id2 = widget_button(id_fn, val='!13 Complex Script', uval='FONT')
	  id2 = widget_button(id_fn, val='!17 Triplex Roman', uval='FONT')
	  id2 = widget_button(id_fn, val='!18 Triplex Italic', uval='FONT')
	;-------  Colors  -------------
	b = widget_base(top, /row)
	id = widget_button(b, val='Text Color', uval='TCLR')
	id_cf = widget_draw(b,xsize=64, ysize=32, retain=2)
	id = widget_button(b, val='Background Color', uval='BCLR')
	id_cb = widget_draw(b,xsize=64, ysize=32, retain=2)
	;####  Add shadow colors
	;-------  Sliders  ------------
	id_siz = widget_slider(top, xsize=500, min=0,max=500,/drag, $
	  uval='SLIDE', title='Text Size', val=100)
	id_spc = widget_slider(top, xsize=500, min=0,max=500,/drag, $
	  uval='SLIDE', title='Line Spacing', val=100)
	id_x = widget_slider(top, xsize=500, min=0,max=500,/drag, $
	  uval='SLIDE', title='X Position', val=15)
	id_y = widget_slider(top, xsize=500, min=0,max=500,/drag, $
	  uval='SLIDE', title='Y Position', val=500)
 
	;---------  Realize  ------------
	widget_control, top, /real
	widget_control, id_cf, get_val=fwin	; Get window numbers after
	widget_control, id_cb, get_val=bwin	;   widget realized.
	wset, fwin
	erase, fore
	wset, bwin
	erase, back
	res = widget_base(uval='')
	map = {win:win, fwin:fwin, bwin:bwin, fore:fore, back:back, $
	  thick:thick, font:font, id_th:id_th, id_fn:id_fn, b_txt:b_txt, $
	  file:file, id_siz:id_siz, id_spc:id_spc, id_x:id_x, id_y:id_y, $
	  windex:windex, res:res}
	widget_control, top, set_uval=map
	widget_control, b_txt, set_uval=txt	; Store text array here.
 
	;---------  Set colors  ----------
	xtextimg_up, map
 
	;-------- Register  ------------
	if n_elements(wait) eq 0 then wait = 0
	xmanager, 'xtextimg', top, modal=wait
 
	;--------  Get saved file name  ----------
	widget_control, res, get_uval=out
 
	return
	end
