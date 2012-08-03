;-------------------------------------------------------------
;+
; NAME:
;       RCPLOT
; PURPOSE:
;       Make Row or Column plots for current window.
; CATEGORY:
; CALLING SEQUENCE:
;       rcplot
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ARRAY=array Optional data array to plot from.
;           Default is to plot from the displayed image.
;           If array was displayed as an image using:
;           tvscl,array,/order  then use /YREVERSE on rcplot call.
;           (do not reverse array before sending to rcplot).
;         MAG=mag Mag factor for zoom window (def=10).
;         SIZE=sz Size of zoom window (def=200 pixels square).
;         MXPOS=mxpos, MYPOS=mypos Mag window x,y position (def=0,0).
;         PXPOS=pxpos, PYPOS=pypos Plot window x,y position (def=0,0).
;         PXSIZE=pxsize, PYSIZE=pysize Plot window x,y size (def=640,200).
;         YRANGE=yran  Plot Y range [ymin,ymax].
;           Use [0,0] for autoscale (default=[0,max(image)].
;         /YREVERSED means Image Y=0 for top row, else bottom.
;           Image must be displayed correctly before calling rcplot.
;           If image was displayed as tvscl,img,/order then call
;           rcplot with /YREVERSED.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: Mag factor and zoom window size may be changed with the
;         options given when the middle mouse button is clicked.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Sep 05
;       R. Sterner, 2003 Jan 16 --- Added x range.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro rcplot, array=arr, mag=mag, size=sz, help=hlp, $
	  yrange=yran, yreversed=yrev, mxpos=mxpos, mypos=mypos, $
	  pxpos=pxpos, pypos=pypos, pxsize=pxsize, pysize=pysize
 
	if keyword_set(hlp) then begin
	  print,' Make Row or Column plots for current window.'
	  print,' rcplot'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   ARRAY=array Optional data array to plot from.'
	  print,'     Default is to plot from the displayed image.'
	  print,'     If array was displayed as an image using:'
	  print,'     tvscl,array,/order  then use /YREVERSE on rcplot call.'
	  print,'     (do not reverse array before sending to rcplot).'
	  print,'   MAG=mag Mag factor for zoom window (def=10).'
	  print,'   SIZE=sz Size of zoom window (def=200 pixels square).'
	  print,'   MXPOS=mxpos, MYPOS=mypos Mag window x,y position (def=0,0).'
	  print,'   PXPOS=pxpos, PYPOS=pypos Plot window x,y position (def=0,0).'
	  print,'   PXSIZE=pxsize, PYSIZE=pysize Plot window x,y size (def=640,200).'
	  print,'   YRANGE=yran  Plot Y range [ymin,ymax].'
	  print,'     Use [0,0] for autoscale (default=[0,max(image)].'
	  print,'   /YREVERSED means Image Y=0 for top row, else bottom.'
	  print,'     Image must be displayed correctly before calling rcplot.'
	  print,'     If image was displayed as tvscl,img,/order then call'
	  print,'     rcplot with /YREVERSED.'
	  print,' Note: Mag factor and zoom window size may be changed with the'
	  print,'   options given when the middle mouse button is clicked.'
	  return
	endif
 
	;--------  Initialize  ----------------
	;---  Define some colors  ---------------
	c_bak = tarclr(255,255,255)
	c_plt = tarclr(0,0,0)
	c_mrk = tarclr(255,255,0)
	;------  Data array  ---------------
	arrflag = 0			; No array given.
	if n_elements(arr) ne 0 then begin
          asz = size(arr)
          if asz(0) ne 2 then begin
            print,' Error in rcplot: ARRAY=arr was used. Array must be 2-D.'
            return
          endif
          if (asz(1) ne !d.x_size) or (asz(2) ne !d.y_size) then begin
            print,' Error in rcplot: ARRAY=arr was used. Array size must'
            print,'   match current screen window: '+strtrim(!d.x_size,2)+$
              ' X '+strtrim(!d.y_size,2)
            return
          endif
	  img0 = arr			; Make copy to allow Y reverse.
	  arrflag = 1			; Array was given.
	endif
	;------  Option defaults  ----------
	if n_elements(mag) eq 0 then mag=10
	if n_elements(sz) eq 0 then sz=200
	if n_elements(mxpos) eq 0 then mxpos=0
	if n_elements(mypos) eq 0 then mypos=0
	if n_elements(pxpos) eq 0 then pxpos=0
	if n_elements(pypos) eq 0 then pypos=0
	if n_elements(pxsize) eq 0 then pxsize=640
	if n_elements(pysize) eq 0 then pysize=200
	if pysize ge 170 then off='!A' else off=''
	;------  Initial mode and position  -------------
	rc = 1					; 0=hor, 1=ver plots.
	x=0 & y=0
	;------  Current window = target window  ----------
	win0 = !d.window			; Current window = target.
	if win0 lt 0 then begin
	  print,' No current window.'
	  return
	endif
	img00 = tvrd()				; Save initial window (8-bit).
	if arrflag eq 0 then begin
	  img0 = img00 + 0			; Convert from Byte type.
	endif
	;------  Plot scaling  ---------------
	if n_elements(yran) eq 0 then yran=[0,max(img0)]
	asz=size(img0) & ixmx=asz(1)-1 & iymx=asz(2)-1
	yarr = indgen(asz(2))
	xwid=asz(1) & ywid=asz(2) & xwid2=xwid/2 & ywid2=ywid/2
	x1lab = 'LEFT'
	x2lab = 'RIGHT'
	y1lab = 'BOTTOM'
	y2lab = 'TOP'
	;------  Y reversal  -----------------
	if keyword_set(yrev) then begin
	  yarr = reverse(yarr)			; Reverse Y coordinate array.
	  swap, y1lab,y2lab
	endif
	;------  Plot window  ----------------
	window,/free,xs=pxsize,ys=pysize,xpos=pxpos,ypos=pypos	; Plot window.
	winplt = !d.window			; Window ID.
	erase, c_bak
	textplot,.5,.5,/norm,align=[.5,.5],chars=5,bold=3,col=c_plt,$
	  'Plot Window'
	pos = [0.078,.2,.94,.85]		; Position for plot.
	wset, win0
	;------  Instructions  ----------------
	xmess,['Position and resize Plot Window as desired.',$
	  'Then click CONTINUE and place cursor in image window.', $
	  'Left button = toggle row/column plots',$
	  'Middle button = options (can scroll window also)', $
	  'Right button = exit.'] ,$
	  oktext='CONTINUE', /wait
	;-------  Bring target window to front  ---------
	wshow, win0
 
loop:	if rc eq 0 then begin			; Init mag cursor.
	  hline,/reset
	  magcrs,/init,state=st,/hor,mag=mag,size=sz,xpos=mxpos,ypos=mypos
	endif else begin
	  vline,/reset
	  magcrs,/init,state=st,/ver,mag=mag,size=sz,xpos=mxpos,ypos=mypos
	endelse
 
	!mouse.button = 0			; Clear mouse button.
	tvcrs, x, y				; Position cursor.
 
	while !mouse.button lt 2 do begin	; Plot loop.
	  wset, win0				; Set to target window.
	  ;------  Plot Row (Hor)  --------------
	  if rc eq 0 then begin
	    magcrs,x,y,/dev,state=st,/hor	; Get new x,y.  Show mag win.
	    y2 = yarr(0>y<iymx)			; Remap y (maybe reversed).
	    if !mouse.button eq 1 then begin	; Deal with rc switched.
	       t = img0(0>x<ixmx,*)		; Have to read column.
	       if keyword_set(yrev) then t=reverse(t,2)
	       goto, col			; Jump to column plot.
	    endif
	    t = img0(*,y2)
row:	    tt1 = 'Image row '+strtrim(y2,2)
	    tt2 = ' (min/max = '+strtrim(min(t),2)+'/'+strtrim(max(t),2)+')'
	    tt3 = '.  Cursor at column '+strtrim(x,2)
	    tt4 = '.  Pixel value='+strtrim(img0(0>x<ixmx,y2),2)
	    px1 = (x-xwid2)>0			; Compute x range.
	    px2 = px1+xwid
	    if px2 gt ixmx then begin
	      px2 = ixmx
	      px1 = (px2-xwid)>0
	    endif
	    xr = [px1,px2]
	    wset, winplt
	    ;#####################################################
	    plot,t,title=off+tt1+tt2+tt3+tt4, col=c_plt, back=c_bak, $
	      ytitle='Image Value',xtitle='Image Column', $
	      /xstyle,yrange=yran,/ystyle,pos=pos,xran=xr
	    ver, x, col=c_mrk
	    oplot, t, col=c_plt
	    xyouts,/dev,!x.window(0)*!d.x_size,5,x1lab,col=c_plt,align=0
	    xyouts,/dev,!x.window(1)*!d.x_size,5,x2lab,col=c_plt,align=1
	    ;#####################################################
	  ;------  Plot Column (Ver)  -----------
	  endif else begin
	    magcrs,x,y,/dev,state=st,/ver
	    y2 = yarr(0>y<iymx)			; Remap y (maybe reversed).
	    if !mouse.button eq 1 then begin	; Deal with rc switched.
	       t = img0(*,y2)			; Have to read row.
	       goto, row			; Jump to column plot.
	    endif
	    t = img0(0>x<ixmx,*)
	    if keyword_set(yrev) then t=reverse(t,2)
col:	    tt1 = 'Image column '+strtrim(x,2)
	    tt2 = ' (min/max = '+strtrim(min(t),2)+'/'+strtrim(max(t),2)+')'
	    tt3 = '.  Cursor at row '+strtrim(y2,2)
	    tt4 = '.  Pixel value='+strtrim(img0(0>x<ixmx,y2),2)
	    py1 = (y2-ywid2)>0			; Compute x range.
	    py2 = py1+ywid
	    if py2 gt iymx then begin
	      py2 = iymx
	      py1 = (py2-ywid)>0
	    endif
	    xr = [py1,py2]
	    wset, winplt
	    wset, winplt
	    ;#####################################################
	    plot,yarr,t,title=off+tt1+tt2+tt3+tt4, col=c_plt, back=c_bak, $
	      ytitle='Image Value',xtitle='Image Row', $
	      /xstyle,yrange=yran,/ystyle,pos=pos, xran=xr
	    ver, y2, col=c_mrk
	    oplot, yarr, t, col=c_plt
	    xyouts,/dev,!x.window(0)*!d.x_size,5,y1lab,col=c_plt,align=0
	    xyouts,/dev,!x.window(1)*!d.x_size,5,y2lab,col=c_plt,align=1
	    ;#####################################################
	  endelse
	  if !mouse.button eq 1 then begin
	    !mouse.button = 0
	    wset, win0
	    if rc eq 0 then hline,/erase,/xmode else vline,/erase,/xmode
	    wdelete, st.win
	    rc = 1-rc
	    wait,0.1
	    goto, loop
	  endif
	endwhile
 
	;------  Clean up -------------
	wset, win0
	if rc eq 0 then hline,/erase,/xmode else vline,/erase,/xmode
	tv,img00
	wdelete,st.win
 
	;-------  Options  -------------
	if !mouse.button eq 2 then begin
	  menu = ['Continue','New Mag factor','New mag window size',$
	    'Set plot Y scale','Set plot X range','Exit','Debug']
	  val = ['C','MAG','SZ','YSC','XRN','EX','BUG']
	  opt = xoption(title='Options:',menu,val=val,def='C')
	  if opt eq 'BUG' then begin
	    stop,' To continue: type .con and press ENTER'
	  endif
	  if opt eq 'C' then begin
	    wshow, win0
	    goto, loop
	  endif
	  if opt eq 'EX' then goto, done
	  if opt eq 'MAG' then begin
	    def = strtrim(mag,2)
	    xtxtin,out,menu=['2','3','5','10','15','20'],/row, $
	      title='Enter mag or click a button',ok='OK', $
	      clear='Clear',cancel='Cancel',mblab='*',def=def,/wait
	    if out ne '' then mag=out+0
	  endif
	  if opt eq 'SZ' then begin
	    def = strtrim(sz,2)
	    xtxtin,out,menu=['100','200','300','400','500'],/row, $
	      title='Enter size or click a button',ok='OK', $
	      clear='Clear',cancel='Cancel',mblab='*',def=def,/wait
	    if out ne '' then sz=out+0
	  endif
	  if opt eq 'YSC' then begin
	    def = strtrim(yran(0),2)+' '+strtrim(yran(1),2)
	    xtxtin,out, $
	      title='Enter new plot range',ok='OK', $
	      clear='Clear',cancel='Cancel',def=def,/wait
	    if out ne '' then begin
	      yran(0) = getwrd(out,0)+0.
	      yran(1) = getwrd(out,1)+0.
	    endif
	  endif
	  if opt eq 'XRN' then begin
	    if rc eq 0 then def=strtrim(xwid,2) else def=strtrim(ywid,2)
	    xtxtin,out, $
	      title='Enter new plot X range',ok='OK', $
	      clear='Clear',cancel='Cancel',def=def,/wait
	    if out ne '' then begin
	      xwid = out+0
	      ywid = xwid
	      xwid2 = xwid/2
	      ywid2 = ywid/2
	    endif
	  endif
	  wshow, win0
	  goto, loop
	endif
 
done:
	wdelete,winplt
 
	end
