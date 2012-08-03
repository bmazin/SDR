;-------------------------------------------------------------
;+
; NAME:
;       BOX2B
; PURPOSE:
;       Simple two mouse button interactive box on image display.
; CATEGORY:
; CALLING SEQUENCE:
;       box2b, x1, x2, y1, y2
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /LOCK lock box to initial size (box must be defined).
;         /XMODE use XOR mode for box.
;         /STATUS  means display box size and position.
;           Use FACT=fct to correct for demagged image.
;         MENU=txtarr     Text array with exit menu options.
;           Def=['OK','Abort','Continue'].  Continue is added.
;         /NOMENU         Inhibits exit menu.
;         EXITCODE=code.  0=normal exit, 1=alternate exit.
;           If MENU is given then code is option index.
;         /YREVERSE makes y=0 be the top line.
;         FACT=fact  Factor to correct image coordinates.
;           If an image is dispayed half size give FACT=2 to get
;           full size image coordinates (def=1).
;         CHANGE=routine  Name of a procedure to execute when box
;           changed.  Do box2b,/ch_details for details.
;         CTEXT=txt change routine toggle text for menu.
; OUTPUTS:
;       x1, x2 = min and max device X.   in, out
;       y1, y2 = min and max device Y.   in, out
;       Set all values to -1 for new box.
; COMMON BLOCKS:
; NOTES:
;       Notes: Works in device coordinates.
;         Drag open a new box.  Corners or sides may be dragged.
;         Box may be dragged by clicking inside.
;         Click any other button to exit.
;         A returned value of -1 means box undefined.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Nov 10
;       R. Sterner, 1998 Feb  5 --- Fixed first erase box problem.
;       Better but not perfect.
;       R. Sterner, 1998 Jul 21 --- Added List Box Position.
;       R. Sterner, 1999 Mar 15 --- Added /YREVERSE keyword.
;       R. Sterner, 2002 Sep 17 --- Fixed initial box erase problem.
;       R. Sterner, 2002 Sep 17 --- Also fixed button up move error.
;       R. Sterner, 2002 Sep 17 --- Added /XMODE.
;       R. Sterner, 2002 Sep 17 --- Added CHANGE procedure option.
;       R. Sterner, 2004 Mar 23 --- Made small /locked boxes easier to move.
;       R. Sterner, 2005 Oct 13 --- Minor help text addition.
;       R. Sterner, 2006 Apr 09 --- Added help on how to get a new box.
;       R. Sterner, 2007 Feb 08 --- Fixed to allow abort on first click.
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;-------------------------------------------------------------
;  box2b_stat = Update status display.
;-------------------------------------------------------------
 
	pro box2b_stat, x1, x2, y1, y2, nid=nid, yrev=yrev, fact=fact
 
	;------  Correct indices into image  ------------
	;---  For image size  -------
	xsc = round(fact*!d.x_size)	; Corrected image size.
	ysc = round(fact*!d.y_size)
	x1c = round(fact*x1)		; Corrected image x indices.
	x2c = round(fact*x2)
	y1t = round(fact*y1)		; Temp image y indices.
	y2t = round(fact*y2)		; (Maybe correct, maybe not).
	;---  For Y reversal  -------
	if keyword_set(yrev) then begin	; Reverse y.
	  y1c = (ysc-1) - y2t		; Corrected image y indices.
	  y2c = (ysc-1) - y1t
	endif else begin
	  y1c = y1t
	  y2c = y2t
	endelse
 
	;---------  Display results  ----------
	widget_control,nid(0),set_val='X1  X2  DX  =  '+strtrim(x1c,2)+$
	  '   '+strtrim(x2c,2)+'   '+strtrim(x2c-x1c+1,2)
	widget_control,nid(1),set_val='Y1  Y2  DY  =  '+strtrim(y1c,2)+$
	  '   '+strtrim(y2c,2)+'   '+strtrim(y2c-y1c+1,2)
	widget_control,nid(2),set_val='CX  CY  =  '+strtrim((x1c+x2c)/2,2)+$
	  '   '+strtrim((y1c+y2c)/2,2)
 
	end
 
 
;-------------------------------------------------------------
;  box2b = main routine.
;-------------------------------------------------------------
	pro box2b, x10, x20, y10, y20, status=stat, help=hlp, $
	  exitcode=exit, menu=menu0, nomenu=nomenu, yrev=yrev, $
	  xmode=xmode, fact=fact, change=change, ctext=ctext, $
	  ch_details=ch_details, ch_opts=ch_opts, ch_vals=ch_vals, $
	  info=info, lock=lock, ch_flag=ch_flag
 
	if keyword_set(hlp) then begin
	  print,' Simple two mouse button interactive box on image display.'
	  print,' box2b, x1, x2, y1, y2'
	  print,'   x1, x2 = min and max device X.   in, out'
	  print,'   y1, y2 = min and max device Y.   in, out'
	  print,'   Set all values to -1 for new box.'
	  print,' Keywords:'
	  print,'   /LOCK lock box to initial size (box must be defined).'
	  print,'   /XMODE use XOR mode for box.'
	  print,'   /STATUS  means display box size and position.'
	  print,'     Use FACT=fct to correct for demagged image.'
          print,'   MENU=txtarr     Text array with exit menu options.'
          print,"     Def=['OK','Abort','Continue'].  Continue is added."
          print,'   /NOMENU         Inhibits exit menu.'
          print,'   EXITCODE=code.  0=normal exit, 1=alternate exit.' 
          print,'     If MENU is given then code is option index.'
	  print,'   /YREVERSE makes y=0 be the top line.'
	  print,'   FACT=fact  Factor to correct image coordinates.'
	  print,'     If an image is dispayed half size give FACT=2 to get'
	  print,'     full size image coordinates (def=1).' 
	  print,'   CHANGE=routine  Name of a procedure to execute when box'
	  print,'     changed.  Do box2b,/ch_details for details.'
	  print,'   CTEXT=txt change routine toggle text for menu.'
	  print,' Notes: Works in device coordinates.'
	  print,'   Drag open a new box.  Corners or sides may be dragged.'
	  print,'   Box may be dragged by clicking inside.'
	  print,'   Click any other button to exit.'
	  print,'   A returned value of -1 means box undefined.'
	  return
	endif
 
	if keyword_set(ch_details) then begin
	  print,' box2b change routine details'
	  print,' '
	  print,' box2b can execute a user routine every time the box is'
	  print,' moved or its sized changed.  This routine is intended to'
	  print,' display some value for the subarea indicated by the box.'
	  print,' This routine is passed to box2d through the keyword'
	  print,' CHANGE=routine_name.  Its calling may be toggled by a'
	  print,' new exit menu item which may be customized with CTEXT=txt.'
	  print,' That menu item allows the routine to be called only when'
	  print,' box changes and on a mouse button up, or during box moves,'
	  print,' or not at all. Set CH_FLAG to 0=none, 1=on mouse up, or 2=on move'
	  print,' to initialize this operation (can always change it by clicking'
	  print,' the middle mouse button.'
	  print,' This routine is called a change routine and must follow'
	  print,' a strict calling sequence.  It may also have optional'
	  print,' initialize and terminate modes which are called outside'
	  print,' box2b.  It must take the 4 parameters x1,x2,y1,y2 which'
	  print,' are the box x and y device coordinates in the window.'
	  print,' It also must allow the following 4 keywords:'
	  print,' FACT=fact, YREV=yrev, OPTION=opt, INFO=info although it'
	  print,' need not use them.  FACT is the image display size factor,'
	  print,' if the image is half size on the screen then FACT=2.'
	  print,' YREV indicates if Y should be reversed (0=no, 1=yes).'
	  print,' The change routine can use these keywords and the raw'
	  print,' box device coordinates to compute actual indices into'
	  print,' the full image.  box2b may be given a list of menu items'
	  print,' in ch_opts that are options to the change routine, the'
	  print,' corresponding values may be given in ch_vals.  When a menu'
	  print,' option is picked its value is sent to the change routine'
	  print,' through the OPTION keyword.  INFO may be any info to be'
	  print,' passed to the change routine from outside box2b, it could'
	  print,' be a structure, maybe with image file name for example.  The'
	  print,' change routine must know what to do with it. The example'
	  print,' routine image_stats.pro may be used with box2b.  It is'
	  print,' initialized with the raw image: image_stats, init=img0.'
	  print,' It sets up a small window to display the histogram of the'
	  print,' subarea in the box.  After box2b completes the window may'
	  print,' be removed by image_stats,/terminate.'
	  print,' The box2b keywords CH_OPTS and CH_VALS are used together to'
	  print,' give menu items and option values to pass into the change'
	  print," routine: box2b,change='image_stats',ch_opt='Snap JPEG',$"
	  print,"   ch_vals=1, info='test.png' will do the call:"
	  print,' image_stats, x1,x2,y1,y2,fact=fact,yrev=yrev,option=opt,info=info'
	  print,' when Snap JPEG is clicked on the box2b exit menu.'
	  print,' This will snap an image and box2b will then continue.'
	  print,' The contents of INFO is printed at the bottom of the'
	  print,' snapped image and could be the image file name.'
	  print,' CH_OPTS and CH_VALS may be arrays for change routines'
	  print,' that have multiple options.'
	  return
	endif
 
	tol = 5				; Closeness tolerence (5 pixels).
	xmx = !d.x_size			; Max X coord.
	ymx = !d.y_size			; Max Y coord.
 
	xcl=-1 & ycl=-1			; Define last cursor position.
	noerase = 1			; Don't erase old box first time.
	chflag = 0			; Assume no change routine.
	exit = -99			; In case aborted on first click.
 
	img = tvrd()			; Grab copy of image.
 
	if n_elements(fact) eq 0 then fact=1	; Image size factor.
	if n_elements(ctext) eq 0 then begin
	  txt = 'processing'
	  if n_elements(change) ne 0 then txt=change
	  ctext='Turn '+txt+' on/off'
	endif
	
 
	;========  Set up menu  ==========
	;----  Change processing  ------------
	if n_elements(change) ne 0 then begin
	  menu = [ctext]		; Add change routine ctr to menu.
	  mvals = [-2]			; Change processing toggle = -2.
	  chflag = 1			; Change processing on by default.
	  if n_elements(ch_flag) ne 0 then chflag=ch_flag
	  ;----  Change options  -------------
	  n = n_elements(ch_opts)
	  if n ne 0 then begin		; Add change options to menu.
	    if n_elements(ch_vals) eq 0 then ch_vals=indgen(n)
	    menu = [menu,ch_opts]
	    mvals = [mvals,-100-ch_vals]	; Change options LE -100.
	  endif
	  if n_elements(menu0) ne 0 then begin	; Add given menu items.
	    menu = [menu, menu0]
	    mvals = [mvals, indgen(n_elements(menu0))]
	  endif else begin			; or if none add EXIT.
	    menu = [menu,'Exit']
	    mvals = [mvals,0]
	  endelse
	endif
        ;----  Make sure exit menu is setup   ---------
        if n_elements(menu) eq 0 then begin	; If no menu make default.
	  if n_elements(menu0) eq 0 then menu0=['OK','Abort']
	  menu = menu0
          mvals = indgen(n_elements(menu))
	endif
 
	;-------  Set up status display?  -----------
	if keyword_set(stat) then begin
	  xbb,wid=wid,nid=nid,res=[0,1,2],lines=[$
	    'X1 X2 DX = 000  000  000',$
	    'Y1 Y2 DY = 000  000  000',$
	    'CX CY = 000  000']
	endif
 
	;-------  Use entry box if available  ------------
	if n_elements(x10) eq 0 then x10=-1	; Make sure box values
	if n_elements(x20) eq 0 then x20=-1	; are not undefined.
	if n_elements(y10) eq 0 then y10=-1
	if n_elements(y20) eq 0 then y20=-1
	if min([x10,x20,y10,y20]) ge 0 then begin
	  x1 = (x10<x20)>0<(xmx-1)	; Use given values but keep in range.
	  x2 = (x10>x20)>0<(xmx-1)
	  y1 = (y10<y20)>0<(ymx-1)
	  y2 = (y10>y20)>0<(ymx-1)
	  if keyword_set(yrev) then begin	; Reverse Y.
	    yt = !d.y_size-y1-1
	    y1 = !d.y_size-y2-1
	    y2 = yt
	  endif
	  tvbox,x1,y1,x2-x1,y2-y1,-2, $	  ; Plot entry box.
	    noerase=noerase, xmode=xmode
	  noerase = 0				; Have a box to erase now.
	  tvcrs, (x1+x2)/2, (y1+y2)/2		; Set cursor to midbox.
	  if keyword_set(stat) then begin	; Update status.
	    box2b_stat, x1, x2, y1, y2, nid=nid, yrev=yrev, fact=fact
	  endif
	  goto, loop			; Go intereactive.
	endif
 
	;-------  Init box to first point  ----------
	cursor, x1, y1, 3, /device	; Wait for a button down.
        if !mouse.button gt 1 then begin  ; Other button.
	  if n_elements(wid) ne 0 then widget_control, wid, /dest
	  return
	endif
	x2=x1 & y2=y1			; Got one, set box to single point.
 
	xcl = x1  &  ycl = y1		; Last cursor position.
 
	;================================================
	;	Main cursor loop
	;================================================
loop:
        cursor, xc, yc, 0, /device		; Look for new values.
        if ((xc eq xcl) and (yc eq ycl)) or $xi	 ; Not moved, or
           ((xc eq -1) and (yc eq -1)) then $	; moved out of window:
          cursor,xc,yc,2,/device		; wait for a change.
	xcl=xc  &  ycl=yc			; Save last position.
 
	;-------  Exit box routine  ------------
        if !mouse.button gt 1 then begin	; Other button.
help,!mouse.button
          ;----  Exit options: OK, Abort, Continue. 
          if keyword_set(nomenu) then begin
            exit = 0
          endif else begin
            exit = xoption(['Continue',menu],val=[-1,mvals],def=-1)
          endelse
	  ;----  Set change routine call option  -----------
	  if exit eq -2 then begin
	    chflag = xoption(['No '+change, $
		change+' only on mouse up', change+' during move'])
	    exit = -1				; Continue.
	  endif
	  ;---  Execute a change routine option, then continue  -----
	  if exit le -100 then begin
	    opt = -exit-100			; Recover option value.
	    if chflag ge 1 then begin
	      call_procedure,change,x1,x2,y1,y2,fact=fact,yrev=yrev, $
	       option=opt, info=info
	    endif
	    exit = -1				; Continue.
	  endif
	  ;-----  Exit and return menu item number  ----------
	  if exit ne -1 then begin
	    tvbox,x1,y1,x2-x1,y2-y1,-1,xmode=xmode  ; Erase box and exit.
	    x10=x1 & x20=x2 & y10=y1 & y20=y2	; Return box.
	    if keyword_set(yrev) then begin	; Reverse Y.
	      yt = !d.y_size-y10-1
	      y10 = !d.y_size-y20-1
	      y20 = yt
	    endif
	    if keyword_set(stat) then widget_control,wid,/dest
	    return
	  endif
	  ;------  Continue ----------------
	  tv, img
	  if keyword_set(xmode) then noerase=1	; After image reload (for xmode).
	  tvbox,x1,y1,x2-x1,y2-y1,-2,	$	; Plot box again.
	    noerase=noerase, xmode=xmode
	  noerase = 0
;	  tvcrs, xcl, ycl
	  tvcrs, (x1+x2)/2, (y1+y2)/2		; Set cursor to midbox.
	  goto, loop
	endif
 
	;-------  First point of a drag command  ----------
        if !mouse.button eq 1 then $
	  wait,.2 $				; Debounce. 
	  else goto, loop
 
	if keyword_set(lock) then goto, inside
 
	;------  Check if at a box corner  --------------
	ic = 0
	if inbox(xc,yc,x1-tol,x1+tol,y1-tol,y1+tol) then ic=1
	if inbox(xc,yc,x2-tol,x2+tol,y1-tol,y1+tol) then ic=2
	if inbox(xc,yc,x2-tol,x2+tol,y2-tol,y2+tol) then ic=3
	if inbox(xc,yc,x1-tol,x1+tol,y2-tol,y2+tol) then ic=4
 
	;------  Was at a corner, drag it  ---------------
	if ic gt 0 then begin			; Move a corner.
	  while !mouse.button eq 1 do begin	; Drag current corner.
          cursor, xc, yc, 0, /device		; Look for new values.
          if ((xc eq xcl) and (yc eq ycl)) or $xi	 ; Not moved, or
             ((xc eq -1) and (yc eq -1)) then $	; moved out of window:
	    repeat begin
              cursor,xc,yc,2,/device		; wait for a change.
	    endrep until (xc gt -1) and (yc gt -1)
	    xcl=xc  &  ycl=yc			; Save last position.
	    cursor,xxx,yyy,0,/dev		; Absorb button up.
 
	  case ic of				; Process a corner move.
1:	  begin
	    x1=xc  & y1=yc
	    if (x1 gt x2) and (y1 gt y2) then begin	; Handle any crossover.
	      swap, x1, x2 & swap, y1,y2 & ic=3		; 1 --> 3
	    endif else if x1 gt x2 then begin
	      swap, x1, x2 & ic=2			; 1 --> 2
	    endif else if y1 gt y2 then begin
	      swap, y1, y2 & ic=4			; 1 --> 4
	    endif
	  end
2:	  begin
	    x2=xc  & y1=yc
	    if (x2 lt x1) and (y1 gt y2) then begin	; Handle any crossover.
	      swap, x1, x2 & swap, y1,y2 & ic=4		; 2 --> 4
	    endif else if x2 lt x1 then begin
	      swap, x1, x2 & ic=1			; 2 --> 1
	    endif else if y1 gt y2 then begin
	      swap, y1, y2 & ic=3			; 2 --> 3
	    endif
	  end
3:	  begin
	    x2=xc  & y2=yc
	    if (x2 lt x1) and (y2 lt y1) then begin	; Handle any crossover.
	      swap, x1, x2 & swap, y1,y2 & ic=1		; 3 --> 1
	    endif else if x2 lt x1 then begin
	      swap, x1, x2 & ic=4			; 3 --> 4
	    endif else if y2 lt y1 then begin
	      swap, y1, y2 & ic=2			; 3 --> 2
	    endif
	  end
4:	  begin
	    x1=xc  & y2=yc
	    if (x1 gt x2) and (y2 lt y1) then begin	; Handle any crossover.
	      swap, x1, x2 & swap, y1,y2 & ic=2		; 4 -- 2
	    endif else if x1 gt x2 then begin
	      swap, x1, x2 & ic=3			; 4 --> 3
	    endif else if y2 lt y1 then begin
	      swap, y1, y2 & ic=1			; 4 --> 1
	    endif
	  end
	  endcase
 
	    tvbox,x1,y1,x2-x1,y2-y1,-2,	$		; Plot new box.
	      noerase=noerase, xmode=xmode
	    noerase = 0					; Erase from now on.
	    if keyword_set(stat) then begin		; Update status.
	      box2b_stat, x1, x2, y1, y2, nid=nid, yrev=yrev, fact=fact
	    endif
	    if !mouse.button eq 0 then begin
	      if chflag ge 1 then begin
		call_procedure, change, x1, x2, y1, y2, fact=fact, yrev=yrev
	      endif
	    endif
	  endwhile					; Keep dragging.
	  goto, loop			; Go look for another drag operation.
	endif
 
	;------  Check if at a box side  -----------------
	is = 0
	if inbox(xc,yc,x1-tol,x2+tol,y1-tol,y1+tol) then is=1
	if inbox(xc,yc,x2-tol,x2+tol,y1-tol,y2+tol) then is=2
	if inbox(xc,yc,x1-tol,x2+tol,y2-tol,y2+tol) then is=3
	if inbox(xc,yc,x1-tol,x1+tol,y1-tol,y2+tol) then is=4
 
	;------  Was at a side, drag it  ---------------
	if is gt 0 then begin			; Move a corner.
	  while !mouse.button eq 1 do begin	; Drag current corner.
          cursor, xc, yc, 0, /device		; Look for new values.
          if ((xc eq xcl) and (yc eq ycl)) or $xi	 ; Not moved, or
             ((xc eq -1) and (yc eq -1)) then $	; moved out of window:
	    repeat begin
              cursor,xc,yc,2,/device		; wait for a change.
	    endrep until (xc gt -1) and (yc gt -1)
	  xcl=xc  &  ycl=yc			; Save last position.
	  cursor,xxx,yyy,0,/dev			; Absorb button up.
 
	  case is of				; Process a side move.
1:	  begin
	    y1 = yc
	    if y1 gt y2 then begin		; Handle any crossover.
	      swap, y1,y2 & is=3		; 1 --> 3
	    endif
	  end
2:	  begin
	    x2 = xc
	    if x2 lt x1 then begin		; Handle any crossover.
	      swap, x1, x2 & is=4		; 2 --> 4
	    endif
	  end
3:	  begin
	    y2 = yc
	    if y2 lt y1 then begin		; Handle any crossover.
	      swap, y1,y2 & is=1		; 3 --> 1
	    endif
	  end
4:	  begin
	     x1 = xc
	    if x1 gt x2 then begin		; Handle any crossover.
	      swap, x1, x2 & is=2		; 4 -- 2
	    endif
	  end
	  endcase
 
	    tvbox,x1,y1,x2-x1,y2-y1,-2,xmode=xmode  ; Plot new box.
	    if keyword_set(stat) then begin	; Update status.
	      box2b_stat, x1, x2, y1, y2, nid=nid, yrev=yrev, fact=fact
	    endif
	    if !mouse.button eq 0 then begin
	      if chflag ge 1 then begin
		call_procedure, change, x1, x2, y1, y2, fact=fact, yrev=yrev
	      endif
	    endif
	  endwhile					; Keep dragging.
	  goto, loop			; Go look for another drag operation.
	endif
 
	;------  Inside box  -----------------------------
inside:
	if keyword_set(lock) then ex=5 else ex=0
	if outbox(xc,yc,x1,x2,y1,y2,expand=ex) then goto, loop
 
	while !mouse.button eq 1 do begin	; Drag current corner.
          cursor, xc, yc, 0, /device		; Look for new values.
          if ((xc eq xcl) and (yc eq ycl)) or $ ; Not moved, or
             ((xc eq -1) and (yc eq -1)) then $	; moved out of window:
	    repeat begin
              cursor,xc,yc,2,/device		; wait for a change.
	    endrep until (xc gt -1) and (yc gt -1)
	  dcx=xc-xcl & dcy=yc-ycl		; Move in pixels.
	  xcl=xc  &  ycl=yc			; Save last position.
	  cursor,xxx,yyy,0,/dev			; Absorb button up.
 
	  if ((x1+dcx) ge 0) and ((x2+dcx) lt xmx) then begin
	    x1 = x1+dcx  &  x2 = x2+dcx		; New box position.
	  endif
 
	  if ((y1+dcy) ge 0) and ((y2+dcy) lt ymx) then begin
	    y1 = y1+dcy  &  y2 = y2+dcy
	  endif
 
	  tvbox,x1,y1,x2-x1,y2-y1,-2, xmode=xmode  ; Plot new box.
	  if keyword_set(stat) then begin	; Update status.
	    box2b_stat, x1, x2, y1, y2, nid=nid, yrev=yrev, fact=fact
	  endif
	  if chflag eq 2 then begin
	    call_procedure, change, x1, x2, y1, y2, fact=fact, yrev=yrev
	  endif
	  if !mouse.button eq 0 then begin
	    if chflag ge 1 then begin
	      call_procedure, change, x1, x2, y1, y2, fact=fact, yrev=yrev
	    endif
	  endif
 
	endwhile
 
	goto, loop
 
	end
