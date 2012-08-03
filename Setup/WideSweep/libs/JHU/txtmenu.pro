;-------------------------------------------------------------
;+
; NAME:
;       TXTMENU
; PURPOSE:
;       Text screen menu routine.
; CATEGORY:
; CALLING SEQUENCE:
;       txtmenu
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       txtmenu_com
;       txtmenu_com
;       txtmenu_com
; NOTES:
;       Notes: This routine will display a screen menu and allow
;         menu items to be selected and updated.  The routine is
;         not hard to use but requires a more detailed description
;         then this space allows, so a routine was written that
;         gives more help for TXTMENU.
;       
;         For more help do TXTMENU,/MOREHELP
;       
;       There is a set of screen menu support routines:
;       TXTMENU --- the screen menu routine itself.
;       TXTIN --- prompts and reads user input allowing defaults.
;       TXTMESS --- displays a message on the screen.
;       TXTYESNO --- asks a yes/no questions and returns answer.
;       TXTFILE --- prompts for a single file (and directory).
;       TXTPICK --- prompts for multiple files.
;       TXTGETFILE --- Like TXTPICK but does wildcard search.
;       TXTMETER --- displays a 0 to 100% updatable meter on screen.
; MODIFICATION HISTORY:
;       R. Sterner, 31 Jan, 1992
;       R. Sterner, 11 Mar, 1992 --- made value of _ eq ''
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro txtmenu_txt, out, capture=capture
	;---  txtmenu_txt added by RES 27 Mar, 1992  ----
	;---  Use txtmenu_txt, /CAPTURE to internally store current screen.
	;---  Later use txtmenu_txt, out to get it.  -----
 
	common txtmenu_com, initflag, x, y, tag, val, uval, sep, $
	  item_len, n_items, hilight, screen
 
	if keyword_set(capture) then begin
	  ;---------  Capture screen --------------
	  screen = bytarr(80,24)+32B		; Represents screen.
	  screen = string(screen)		; Convert to actual strings.
	  for i = 0, n_items-1 do begin		; Loop thru items.
	    septxt = sep				; Sep. text.
	    if val(i) eq ''  then septxt = ''	; No sep. on titles.
	    if val(i) eq ' ' then septxt = ''	; No. sep. for space.
	    txt = tag(i)+septxt+val(i)		; Total menu item.
	    if val(i) eq '' then begin		; Title?
	      txt = '_'+txt+'_'		  	; Underline titles.
	    endif
	    t = screen(y(i)-1)			; Pull line to update.
	    strput, t, txt, x(i)-1		; Insert new text. 
	    screen(y(i)-1) = t			; Update text array.
	  endfor
	  t = screen(23)
	  strput, t, '? for help', 0
	  screen(23) = t
	endif else begin
	  ;----------  Returned a screen captured previously  -----
	  out = screen
	endelse
	return
	end
 
 
;********************************************************************
;***********  txtmenu_display = Display current txtmenu.       ******
;********************************************************************
 
	pro txtmenu_display
 
	common txtmenu_com, initflag, x, y, tag, val, uval, sep, $
	  item_len, n_items, hilight, screen
 
	;---------  Display menu  --------------
	printat,1,1,/clear			; Clear screen.
	for i = 0, n_items-1 do begin		; Loop thru items.
	  septxt = sep				; Sep. text.
	  if val(i) eq ''  then septxt = ''	; No sep. on titles.
	  if val(i) eq ' ' then septxt = ''	; No. sep. for space.
	  txt = tag(i)+septxt+val(i)		; Total menu item.
	  if val(i) eq '' then begin		; Title?
	    printat, x(i), y(i), txt,/under  	; Underline titles.
	  endif else begin
	    printat, x(i), y(i), txt		; Display item.
	  endelse
	endfor
	;-------  high-light tags  -------
	w = where(hilight eq 1, count)
	if count ge 0 then begin
	  for i = 0, count-1 do begin
	    j = w(i)
	    printat, x(j), y(j), tag(j), /neg	; High-light a tag.
	  endfor
	endif
	printat,1,24,'? for help' & printat,1,1,''
	return
	end
 
 
;********************************************************************
;*************  txtmenu = Main screen menu routine  *****************
;********************************************************************
 
	pro txtmenu, initialize=txtarr, seperator=sep0, $
	  delimiter=dd, xy=xy, tag=ttag, value=vval, uvalue=uuval, $
	  selection=select, update=update, help=hlp, multiple=mult, $
	  morehelp=morehelp
 
	common txtmenu_com, initflag, x, y, tag, val, uval, sep, $
	  item_len, n_items, hilight, screen
 
	if keyword_set(hlp) then begin
	  print,' Text screen menu routine.'
	  print,' txtmenu
	  print,' Notes: This routine will display a screen menu and allow'
	  print,'   menu items to be selected and updated.  The routine is'
	  print,'   not hard to use but requires a more detailed description'
	  print,'   then this space allows, so a routine was written that'
	  print,'   gives more help for TXTMENU.'
	  print,' '
	  print,'   For more help do TXTMENU,/MOREHELP'
	  print,' '
          print,' There is a set of screen menu support routines:'
          print,' TXTMENU --- the screen menu routine itself.'
          print,' TXTIN --- prompts and reads user input allowing defaults.'
          print,' TXTMESS --- displays a message on the screen.'
          print,' TXTYESNO --- asks a yes/no questions and returns answer.'
          print,' TXTFILE --- prompts for a single file (and directory).'
          print,' TXTPICK --- prompts for multiple files.'
          print,' TXTGETFILE --- Like TXTPICK but does wildcard search.'
          print,' TXTMETER --- displays a 0 to 100% updatable meter on screen.'
	  return
	endif
 
	if keyword_set(morehelp) then begin
	  txtmenu_help
	  return
	endif
 
	;================================================
	;-------------  Initialize Mode  ----------------
	if n_elements(txtarr) ne 0 then begin
	  ;-----  Start arrays for menu components  ------
	  x = intarr(1)		; Tag column.
	  y = intarr(1)		; Tag line.
	  tag = strarr(1)	; Tag itself.
	  val = strarr(1)	; Tag value.
	  uval = strarr(1)	; Tag user value.
	  txt = ''
	  ;-----  Loop through string array interpreting elements  ----
	  for it = 0, n_elements(txtarr)-1 do begin
	    txt = txtarr(it)				    ; Pull out text.
	    char1 = strmid(txt,0,1)			    ; First character.
	    if (char1 ne '*') and (txt ne '') then begin    ; If not a comment.
	      dd = char1				    ; Return delimiter.
	      x = [x, getwrd(txt,delim=char1,0,/notrim)+0]  ; Get column.
	      y = [y,getwrd('',1,/notrim)+0]		    ; Get line.
	      tag = [tag, getwrd('',2,/notrim)]		    ; Get tag.
	      val = [val, getwrd('',3,/notrim)]		    ; Get value.
	      uval = [uval, getwrd('',4,/notrim)]	    ; Get user value.
	    endif  ; ne '*'
	  endfor  ; it.
	  x = x(1:*)		; Drop dummy front end of arrays.
	  y = y(1:*)
	  tag = tag(1:*)
	  val = val(1:*)
	  w = where(val eq '_', count)	; Set underscores to null.
	  if count gt 0 then val(w) = ''
	  uval = uval(1:*)
	  ;------  returned keyword values  -----------
	  xy = dd+strtrim(x,2)+dd+strtrim(y,2)+dd	; Returned positions.
	  ttag = tag					; Returned tags.
	  vval = val					; Returned values.
	  uuval = uval					; Returned uvalues.
	  n_items = n_elements(x)			; Total # of menu items.
	  ;------  High light flags  ------------------
	  hilight = intarr(n_items)		; No initial hilights.
	  ;------  Set up tag/value seperator  --------
	  if n_elements(sep0) eq 0 then sep0 = ': '  	; Def seperator.
	  sep = sep0
	  ;------ Find lenght of each menu item  ---------
	  item_len = intarr(n_items)		; Setup menu item lengths.
	  for i = 0, n_items-1 do begin		; Loop thru items.
	    septxt = sep			; Sep. text.
	    if val(i) eq ''  then septxt = ''	; No sep. on titles.
	    if val(i) eq ' ' then septxt = ''	; No. sep. for space.
	    txt = tag(i)+septxt+val(i)		; Total menu item.
	    item_len(i) = strlen(txt)		; Length of menu item.
	  endfor
	  txtmenu_display			; Display menu.
	  initflag = 1				; Set initialized flag.
	  return
	endif  ; txtarr
 
 
	;================================================
	;------------  Select Mode  ---------------------
	if n_elements(select) ne 0 then begin
	  if n_elements(initflag) eq 0 then begin
	    print,' Error in txtmenu: must initialize before making selection.'
	    return
	  endif
	  sz = size(select)
	  if sz(sz(0)+1) eq 7 then begin
	    select=(where(select eq uval))(0);select=uvalue
	  endif
	  if (select lt 0) or (select gt (n_items-1)) then begin
	    txtmess,['Error in TXTMENU.',$
	      'SELECTION keyword value is out of range: '+select]
	    return
	  endif
	  ;------  Highlight current selection  ------
iloop:	  last = select
	  printat,x(last),y(last),tag(last),/neg
	  printat,x(last),y(last),''
	  rx = x(last)		; Reference point is currently selected item
	  ry = y(last)		;   position.
	  wg = where(val ne '')	; Good tags.
	  xg = x(wg)
	  yg = y(wg)
	  dx = xg - rx		; Vectors to all other items.
	  dy = yg - ry
	  ;------  Read keyboard  -------
kloop:	  if !version.os eq 'DOS' then begin
	    pckey, k, ascii=c
	    k = strupcase(k)
	  endif else begin
	    k = strupcase(getkey())
	    c = (byte(k))(0)	; Get byte value.
	  endelse
	  ;------  Quit if was RETURN (or space) -------
	  if (c eq 13) or (c eq 10) or (c eq 32) then begin
	    select=last
	    uuval = uval(select)
	    if keyword_set(mult) then begin
	      printat,x(last),y(last),tag(last),neg=1-hilight(last)
	      printat,x(last),y(last),''
	    endif else printat,x(last),y(last),tag(last) ; un-light.
	    return
	  endif
	  ;------  Process an arrow key  ------
	  case k of
'RIGHT':    w = where((dx gt 0) and (-dx le dy) and (dy le dx), cnt)
'UP':       w = where((dy lt 0) and (dy le dx) and (dx le -dy), cnt)
'LEFT':     w = where((dx lt 0) and (dx le dy) and (dy le -dx), cnt)
'DOWN':     w = where((dy gt 0) and (-dy le dx) and (dx le dy), cnt)
'R':	    begin	; Refresh screen.
	      txtmenu_display
	      printat,x(last),y(last),tag(last),/neg
	      printat,x(last),y(last),''
	      goto, kloop
	    end
'C':	    begin	; Capture screen.
	      txtmenu_txt, /capture
	      printat,40,24,'Screen captured'
	      printat,1,1,''
	      wait,1
	      printat,40,24,'               '
	      printat,1,1,''
	      goto, kloop
	    end
'?':	    begin
	      printat,1,1,/clear
	      print,' '
	      print,' Help for screen menu'
	      print,' '
	      print,' The currently selected menu item is highlighted.'
	      print,' '
	      print,' Change the selection by using arrow keys to move around.'
	      print,' '
	      print,' Choose the selection by pressing RETURN or SPACE.'
	      print,' '
	      print,' Underlined text may not be selected, it is either'
	      print,' a title or a currently unavailable option.'
	      print,' '
	      print,' R refreshes the screen.'
	      print,' C captures the current screen internally, to get a copy'
	      print,'   do TXTMENU_TXT, SCREEN in IDL after exiting program.'
	      print,' '
	      print,' < Press any key to continue >'
	      k = get_kbrd(1)
	      txtmenu_display
	      printat,x(last),y(last),tag(last),/neg
	      printat,x(last),y(last),''
	      goto, kloop
	    end
else:	    goto, kloop
	  endcase
 
	  ;-----  If any item in range find nearest  --------
	  if cnt gt 0 then begin
	    ;--- Factor of 2 in Y term is because lines are
	    ;    spaced about twice as far apart as characters.
	    d = (rx-xg(w))^2 + (2*(ry-yg(w)))^2      ; Distances^2
	    w0 = where(d eq min(d))		     ; Find closest.
	    printat,x(last),y(last),tag(last),neg=hilight(last) ; Deselect old.
	    select = (wg(w(w0)))(0)		     ; New tag index.
	    goto, iloop				     ; Goto new item.
	  endif
 
	  ;-----  No items selectable, go get another key ------
	  bell
	  goto, kloop
 
	endif  ; Select
 
 
	;================================================
	;--------------  Update Mode  -------------------
	if n_elements(update) ne 0 then begin
	  ;-----------  Interpret menu item update  ----------
	  char1 = strmid(update,0,1)			    ; First character.
	  if (char1 ne '*') and (update ne '') then begin   ; If not a comment.
	    xx = getwrd(update,delim=char1,0,/notrim)+0     ; Get column.
	    yy = getwrd('',1,/notrim)+0		    	    ; Get line.
	    ttag = getwrd('',2,/notrim)		   	    ; Get new tag.
	    vval = getwrd('',3,/notrim)		   	    ; Get new value.
	    if vval eq '_' then vval = ''		    ; Set _ to null.
	    uuval = getwrd('',4,/notrim)		    ; Get new uvalue.
	    ;-----  find which item to update  --------
	    w = where((xx eq x) and (yy eq y), cnt)	    ; Find same place.
	    if cnt ne 0 then begin			    ; Find that item.
	      in = w(0)					    ; Menu item #.
	      if (vval ne '') and (vval ne ' ') then begin
	        txt = ttag+sep+vval			    ; New menu item txt.
	      endif else begin
	        txt = ttag				    ; New menu item txt.
	      endelse
	      if vval eq '' then begin
	        printat,xx,yy,txt+spc(item_len(in),txt),/und ; Update item(und).
	      endif else begin
	        printat,xx,yy,txt+spc(item_len(in),txt)     ; Update menu item.
	      endelse
	      item_len(in) = strlen(txt)		    ; May have new len.
	      tag(in) = ttag				    ; May have new tag.
	      val(in) = vval				    ; New value.
	      if uuval ne '' then uval(in) = uuval	    ; New uvalue.
	    endif  ; cnt
	  endif  ; ne '*' = not a comment.
	  return
	endif  ; update
 
	txtmess, $
	[' Error in txtmenu.  Must call with one of the following 3 modes:', $
	 '   INITIALIZE=txtarr where txtarr must be defined.', $
	 '   SELECTION=s  where s must be defined.', $
	 '   UPDATE=txt   where txt must be a menu item update.',$
	 ' For help do TXTMENU, /HELP']
	return
 
	end
