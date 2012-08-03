;-------------------------------------------------------------
;+
; NAME:
;       TEXTI
; PURPOSE:
;       Interactive Text.
; CATEGORY:
; CALLING SEQUENCE:
;       texti, text
; INPUTS:
;       text = Text to write (def=Text).   in
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       texti_com
; NOTES:
;       Notes: XOR plot mode is used to display text
;         before it is burned into image.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 27
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro texti, text, help=hlp
 
	common texti_com, text0, a0, b0, thk0, clr0, fnt0, $
	  patch0, px0, py0, pdx0, pdy0
 
	if keyword_set(hlp) then begin
	  print,' Interactive Text.'
	  print,' texti, text
	  print,'   text = Text to write (def=Text).   in'
	  print,' Notes: XOR plot mode is used to display text'
	  print,'   before it is burned into image.'
	  return
	endif
 
	;--------  Defaults  ----------------------------------
	;----  Common:
	if n_elements(text0) eq 0 then text0 = 'Text'
	if n_elements(thk0) eq 0 then thk0 = [3,1]
	if n_elements(fnt0) eq 0 then fnt0 = '!3'
	if n_elements(a0) eq 0 then begin
	  a0 = [round(.3*!d.x_size),round(.6*!d.y_size)]
	endif
	if n_elements(b0) eq 0 then begin
	  b0 = [round(.6*!d.x_size),round(.6*!d.y_size)]
	endif
	if n_elements(clr0) eq 0 then begin
	  tvlct,r,g,b,/get
	  lum = round(.3 * r + .59 * g + .11 * b) < 255
	  wdrk = where(lum eq min(lum))
	  wbrt = where(lum eq max(lum))
	  clr0 = [wdrk(0),wbrt(0)]
	endif
 
	;------  Pull values from common  --------
	if n_elements(text) eq 0 then text = text0
	a = a0
	b = b0
	if text eq '' then text = 'Default text string'
	fnt = fnt0
	thk = thk0
	clr = clr0
 
	;-------  Set other needed values  -------------
	ltyp = 'Device coordinates'
	flag = 1		; Active point is A (point 1).
	cflag = 1		; Set change flag.
	usersym,[1,1,-1,-1],[-1,1,1,-1],/fill
	ssz = 2			; Symbol size.
	angtxt = 'Angle'
	if keyword_set(azi) then angtxt = 'Azimuth'
	magmode = 0		; Mag window mode: start off.
	magcrs,/init,state=magstate
 
	ax=a(0) & ay=a(1)
	bx=b(0) & by=b(1)
	;---------  Convert to device coordinates  ------------
	ixa=round(ax) & iya=round(ay)
	ixb=round(bx) & iyb=round(by)
 
	;---------  Save initial coordinates  ---------------
	ixa0=ixa & iya0=iya	; Only needed for /*FIX keywords.
	ixb0=ixb & iyb0=iyb
 
	;---------  Set up display board  ---------------
	atxt = strtrim(ax,2)+', '+strtrim(ay,2)
	btxt = strtrim(bx,2)+', '+strtrim(by,2)
	txt = '___________________________________'
	lines = [ltyp,txt,'1','2','3','4']
	res = [2,3,4,5]
	xbb, lines=lines, res=res, nid=nid, wid=wid, title='Line parameters'
 
	;---------  Help widget  ------------------------
	if not keyword_set(nohelp) then begin
	  xhelp,title='Instructions',$
		['Interactive Text',$
		' ','The text is positioned by',$
		"moving it's baseline.",' ',$
		'Move the cursor to one end of the',$
		'   baseline or the middle.',$
	        ' ',$
		'Left button: drag endpoint or',$
		'   middle to a new position.',$
	        ' ',$
		'Middle button: toggle mag window.', $
	        ' ',$
		'Right button: options menu.']
	endif
 
	;---------  Set graphics mode  ------------------
	device, get_graphics=gmode0	; Entry mode.
	device, set_graphics=6		; XOR mode.
	tvcrs,ixa,iya
 
	;==========  Main loop  ==========================
	;-------  Plot line and active endpoint  -------------
loop:	plots, [ixa,ixb],[iya,iyb],/dev
        case flag of                                    ; Plot active point.
1:        begin
	    plots,ixa,iya,/dev,psym=8,symsize=ssz
	    ast = '*'
	    bst = ' '
	  end
2:        begin
	    plots,ixb,iyb,/dev,psym=8,symsize=ssz
	    ast = ' '
	    bst = '*'
	  end
3:        begin
	    plots,.5*(ixa+ixb),.5*(iya+iyb),/dev,psym=8,symsize=ssz
	    ast = ' '
	    bst = ' '
	  end
	endcase
	;--------  Plot text  ----------------
	textpos, text, [ixa,iya],[ixb,iyb],tix,tiy,tsz,tang,/dev
	xyouts,/dev,tix,tiy,text,chars=tsz,orient=tang
	empty
 
	;------  Update board with any changes  --------------
	if cflag then begin
	  atxt = strtrim(ax,2)+', '+strtrim(ay,2)
	  btxt = strtrim(bx,2)+', '+strtrim(by,2)
	  dx=bx-ax & dy=by-ay
	  if keyword_set(azi) then $
	    recpol,dy,dx,rr,aa,/deg $
	    else recpol,dx,dy,rr,aa,/deg
	  widget_control, nid(0), set_val=ast+' Ax, Ay = '+atxt
	  widget_control, nid(1), set_val=bst+' Bx, By = '+btxt
	  widget_control, nid(2), set_val='Length = '+strtrim(rr,2)
	  widget_control, nid(3), set_val=angtxt+' (B from A) = '+strtrim(aa,2)
	  cflag = 0
	endif
 
        ;----------------  Cursor  -------------------------
	if magmode eq 0 then begin
          cursor, ix, iy, 2, /dev                      ; Read cursor position.
	endif else begin
          magcrs, ix, iy, /dev, state=magstate         ; Use mag window.
	endelse
 
        ;---------------  Exit  --------------
        if !mouse.button gt 2 then goto, done           ; Done.
 
	;-------  Toggle mag mode  -------------
	if !mouse.button eq 2 then begin
	  if magmode eq 1 then wdelete,magstate.win
	  magmode = 1-magmode
	endif
 
	;-------  Erase line and active endpoint  -------------
	plots, [ixa,ixb],[iya,iyb],/dev
        case flag of                                    ; Erase active point.
1:        plots,ixa,iya,/dev,psym=8,symsize=ssz
2:        plots,ixb,iyb,/dev,psym=8,symsize=ssz
3:        plots,.5*(ixa+ixb),.5*(iya+iyb),/dev,psym=8,symsize=ssz
	endcase
	;-------  Erase text  ---------------
	xyouts,/dev,tix,tiy,text,chars=tsz,orient=tang
	empty
 
	if !mouse.button eq 0 then begin
	  ;--------  Closest point  ------------
	  d2=long(ix-[ixa,ixb,(ixa+ixb)/2.])^2+long(iy-[iya,iyb,(iya+iyb)/2.])^2
	  w = where(d2 eq min(d2))
 
	  ;--------  Activate a point  ---------
          if d2(w(0)) le 400 then begin                   ; Activate point.
            flag2 = w(0)+1                                ; Set active flag.
            if flag2 ne flag then begin                   ; Did flag change?
              flag = flag2
              cflag = 1
            endif
          endif
	endif	; !mouse
 
	;--------  Move point  --------------
        if !mouse.button eq 1 then begin                ; Move point.
          case flag of
1:          begin
              ixa = ix
              iya = iy
            end
2:          begin
              ixb = ix
              iyb = iy
            end
3:	    begin
	      dx = round(ix-(ixa+ixb)/2.)
	      dy = round(iy-(iya+iyb)/2.)
	      ixa = ixa+dx
	      iya = iya+dy
	      ixb = ixb+dx
	      iyb = iyb+dy
	    end
          endcase
          cflag = 1                                     ; Set change flag.
        endif ; !mouse
 
	;-------  Handle fixed coordinates  ------------
	if keyword_set(axfix) then ixa=ixa0
	if keyword_set(ayfix) then iya=iya0
	if keyword_set(bxfix) then ixb=ixb0
	if keyword_set(byfix) then iyb=iyb0
 
	;--------  Convert back to requested coordinate system  ------
	ax=ixa & ay=iya
	bx=ixb & by=iyb
 
	goto, loop
	;====================================================
 
	;------------  Right button   ---------------
done:	plots, [ixa,ixb],[iya,iyb],/dev			; Erase line.
        case flag of                                    ; Erase active point.
1:        plots,ixa,iya,/dev,psym=8,symsize=ssz
2:        plots,ixb,iyb,/dev,psym=8,symsize=ssz
3:        plots,.5*(ixa+ixb),.5*(iya+iyb),/dev,psym=8,symsize=ssz
	endcase
	;-------  Erase text  ---------------
	xyouts,/dev,tix,tiy,text,chars=tsz,orient=tang
 
 
	;=================  Menu options  ========================
	;-------  Options menu  ------------
	men =  ['New Text','Position Text','Burn text into image',$
		'Undo last burn in',$
		'Change thickness','Change color','Change font',$
		'Quit']
	val = ['txt','pos','burn','undo','thk','clr','fnt','quit']
mloop:	opt = xoption(men,val=val,def='pos')
 
	if opt eq 'quit' then begin
quit:	  device, set_graphics=gmode0				; Restore mode.
	  a = [ax,ay]
	  b = [bx,by]
	  widget_control,/dest,wid
	  if magmode eq 1 then wdelete,magstate.win
	  ;--------  Update common  ---------------
	  text0 = text
	  a0 = a
	  b0 = b
	  fnt0 = fnt
	  thk0 = thk
	  clr0 = clr
	  return
	endif
 
	if opt eq 'pos' then begin
	  flag = 3		; Active point is midpoint.
	  tvcrs,.5*(ixa+ixb),.5*(iya+iyb)
	  goto, loop
	endif
 
	if opt eq 'burn' then begin
	  ;-----  Find patch to restore for undo  --------
	  a = [ax,ay]
	  b = [bx,by]
	  u = [b(0)-a(0),b(1)-a(1)]	; Vector a to b.
	  bb = a+u*1.1			; Pt. bb. (add some margin).
	  aa = a-u*.1			; Pt. aa.
	  u = unit(u)			; Unit vector a to b.
	  u = [-u(1),u(0)]		; Normal vector.
	  vln = !d.y_ch_size*tsz
	  cc = aa+vln*u*1.1	; Guess at a bounding box for text.
	  dd = bb+vln*u*1.1
	  aa = aa-vln*u*.3
	  bb = bb-vln*u*.3
	  xx = [aa(0),bb(0),dd(0),cc(0),aa(0)]>0<!d.x_size
	  yy = [aa(1),bb(1),dd(1),cc(1),aa(1)]>0<!d.y_size
	  pxmn=min(xx) & pxmx=max(xx) & pymn=min(yy) & pymx=max(yy)
	  px0=pxmn & py0=pymn & pdx0=pxmx-pxmn+1 & pdy0=pymx-pymn+1
	  ;--------  Read undo patch  ----------
	  device, set_graphics=gmode0				; Restore mode.
	  patch0 = tvrd(px0,py0,pdx0,pdy0)
; plots,xx,yy,/dev
; plots,[pxmn,pxmx,pxmx,pxmn,pxmn],[pymn,pymn,pymx,pymx,pymn],/dev
	  ;---------  Write text  -------------
	  xyoutb,/dev,tix,tiy,fnt+text,chars=tsz,orient=tang,bold=thk,col=clr
	  device, set_graphics=6		; XOR mode.
	  goto, mloop
	endif
 
	if opt eq 'undo' then begin
	  ;--------  Read undo patch  ----------
          device, set_graphics=gmode0		; Restore mode.
	  tv, patch0, px0, py0
	  device, set_graphics=6                ; XOR mode.
          goto, mloop
	endif
 
;	if opt eq 'bug' then begin
;         device, set_graphics=gmode0		; Restore mode.
;	  stop
;	  device, set_graphics=6                ; XOR mode.
;         goto, mloop
;	endif
 
	if opt eq 'txt' then begin
	  old_text = text
new_text: xtxtin,def=text,title='Enter new text string',text
	  if text eq '' then begin
	    if xyesno('No text to write, quit?') eq 'Y' then goto, quit
	    text = old_text
	    goto, new_text
	  endif
          goto, mloop
        endif
 
	if opt eq 'thk' then begin
	  thktxt = commalist(thk)
	  xtxtin,def=thktxt,title='Enter new text thicknesses',txt
          if txt eq '' then txt=thktxt
	  wordarray, txt, thk
	  thk = thk+0
          goto, mloop
	endif
 
	if opt eq 'fnt' then begin
	  xtxtin,def=fnt,title='Enter new text font',txt
          if txt ne '' then fnt=txt
          goto, mloop
	endif
 
	if opt eq 'clr' then begin
	  device, set_graphics=gmode0		; Restore mode.
clr_loop: menc = ['Quit color select','Change foreground color',$
	  'Change background color', 'Enter color values']
 	  valc = ['q','f','b','e']
	  optc = xoption(menc,val=valc)
	  if optc eq 'q' then begin
	    device, set_graphics=6		; XOR mode.
	    goto, mloop
	  endif
 	  if optc eq 'e' then begin
	    clrtxt = commalist(clr)
	    xtxtin,def=clrtxt,title='Enter new text colors',txt
	    if txt eq '' then txt=clrtxt
	    wordarray, txt, clr
	    clr = clr+0
	    xyoutb,/dev,tix,tiy,fnt+text,chars=tsz,orient=tang,bold=thk,col=clr
	    goto, clr_loop
	  endif
	  if optc eq 'f' then begin
floop:	    crossi,x,y,z,/pixel,/dev,/mag,but=but
	    if but ne 1 then goto, clr_loop
	    clr(1) = z
	    xyoutb,/dev,tix,tiy,fnt+text,chars=tsz,orient=tang,bold=thk,col=clr
	    goto, floop
	  endif
	  if optc eq 'b' then begin
bloop:	    crossi,x,y,z,/pixel,/dev,/mag,but=but
	    if but ne 1 then goto, clr_loop
	    clr(0) = z
	    xyoutb,/dev,tix,tiy,fnt+text,chars=tsz,orient=tang,bold=thk,col=clr
	    goto, bloop
	  endif
	endif
 
	goto, mloop
 
	return
	end
