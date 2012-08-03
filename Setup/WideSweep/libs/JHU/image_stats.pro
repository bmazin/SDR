;-------------------------------------------------------------
;+
; NAME:
;       IMAGE_STATS
; PURPOSE:
;       Display image stats in a widget.
; CATEGORY:
; CALLING SEQUENCE:
;       image_stats, x1, x2, y1, y2
; INPUTS:
;       x1,x2,y1,y2 = Indices into image for area of interest.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         INIT=img0  Must give original image to initialize.
;         /TERMINATE Destroy plot window and terminate.
;         FACT=fact Times smaller displayed image is than original.
;         /YREV Y is reversed.
;         XPOS=xpos, YPOS=ypos x,y position of histogram window. On INIT.
;         BINWIDTH=binwid  Initial histogram bin width.  On INIT.
;         OPTION=opt  Plot option:
;           1 = JPEG snapshot.
;           2 = Set plot paramaters.
;         INFO=name of image file.
; OUTPUTS:
; COMMON BLOCKS:
;       image_stats_com
; NOTES:
;       Notes: intended to work with box2d as the CHANGE routine.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Sep 17
;       R. Sterner, 2002 Sep 22 --- Added XPOS,YPOS.
;       R. Sterner, 2003 Jan 14 --- Fixed SDEV problem for UINT.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro image_stats, x1, x2, y10, y20, fact=fact, yrev=yrev, $
	  init=img0, terminate=term, help=hlp, option=option, info=info, $
	  xpos=xpos, ypos=ypos, binwidth=binwidth
 
	common image_stats_com, img, img_dsp, ny, win, win_img, flag, $
	  csz0, pos, tt, tx, ty, c_plt, c_bak, ty0, tdy, tx1, tx2, $
	  xran, yran, binsz
	;------------------------------------------------------------
	;  Status common:
	;	img = Original full image.
	;	img_dsp = Displayed image.
	;	ny = Image y size.
	;	win = Plot window index.
	;	win_img = Image window index.
	;	flag = 1 if intialized, else 0.
	;	csz0 = Plot character size.
	;	pos = Plot position.
	;	tt, tx, ty = Plot title, xtitle, ytitle
	;	c_plt, c_bak = Plot color, background color.
	;	ty0, tdy = Text top y, delta y.
	;	tx1, tx2 = Text column 1, column 2.
	;	xran = [xmn,xmx] plot x range.
	;	yran = [ymn,ymx] plot y range.
	;	binsz = histogram bin size.
	;------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Display image stats in a widget.'
	  print,' image_stats, x1, x2, y1, y2'
	  print,'   x1,x2,y1,y2 = Indices into image for area of interest.  in'
	  print,' Keywords:'
	  print,'   INIT=img0  Must give original image to initialize.'
	  print,'   /TERMINATE Destroy plot window and terminate.'
	  print,'   FACT=fact Times smaller displayed image is than original.'
	  print,'   /YREV Y is reversed.'
	  print,'   XPOS=xpos, YPOS=ypos x,y position of histogram window. On INIT.'
	  print,'   BINWIDTH=binwid  Initial histogram bin width.  On INIT.'
	  print,'   OPTION=opt  Plot option:'
	  print,'     1 = JPEG snapshot.'
	  print,'     2 = Set plot paramaters.'
	  print,'   INFO=name of image file.'
	  print,' Notes: intended to work with box2d as the CHANGE routine.'
	  return
	endif
 
	;----------  Initialize  ------------------
	if n_elements(img0) ne 0 then begin
	  win_img = !d.window		; Save current window.
	  img_dsp = tvrd()		; Grab current screen image.
	  img = img0			; Copy image to common.
	  sz = size(img)		; Image y size.
	  ny = sz(2)			; Window Y size.
	  if n_elements(xpos) eq 0 then xpos=0
	  if n_elements(ypos) eq 0 then ypos=0
	  window,/free,xs=300,ys=300,$	; Make plot window.
	    xpos=xpos,ypos=ypos
	  win = !d.window		; Save index.
	  csz0 = 1.			; Base charsize.
	  pos = [.2,.45,.92,.9]		; Plot position.
	  tt = 'Histogram'		; Plot titles.
	  tx = 'Image value'
	  ty = 'Count'
	  c_plt = tarclr(0,0,0)		; Plot colors.
	  c_bak = tarclr(255,255,255)
	  ty0 = 0.30			; Starting Y for text.
	  tdy = 0.05
	  tx1 = 0.20			; Column 1 x.
	  tx2 = 0.60			; Column 2 x.
	  xmn = min(img,max=xmx)
	  xran = [xmn,xmx]
	  yran = [0,0]
	  binsz = 50
	  if n_elements(binwidth) ne 0 then binsz=binwidth
	  erase, c_bak			; Erase to background.
	  xyouts,.1,.5,/norm,'Drag open a box in the image window',$
	    col=c_plt,chars=1.2
	  xyouts,.1,.45,/norm,'   using left mouse button.',$
	    col=c_plt,chars=1.2
	  xyouts,.1,.4,/norm,'For options click middle mouse button.',$
	    col=c_plt,chars=1.2
	  flag = 1			; Initialized.
	  wset, win_img			; Restore image window.
	  return
	endif
 
	;------  Terminate  -----------------
	if keyword_set(term) then begin
	  wdelete, win
	  flag = 0					; Not intialized.
	  return
	endif
 
	;=======  Process a request  =======================
	if n_elements(flag) eq 0 then flag=0
	if flag eq 0 then begin
	  print,' Error in image_stats: must initialize first.'
	  return
	endif
 
	if n_elements(option) eq 0 then option=0
	if n_elements(info) eq 0 then info=''
 
	;------  Set plot parameters  --------------------
	if option eq 2 then begin
	  if flag eq 0 then return
	  txt = ['Set plot parameters:',$
	    '    x and y plot ranges (both 0 for autoscale),',$
	    '    histogram bin width']
	  lab = ['X min:','X max:','Y min:','Y max:','Hist bin width:']
	  row = [1,1,2,2,3]
	  dfx1=strtrim(xran(0),2) & dfx2=strtrim(xran(1),2) 
	  dfy1=strtrim(yran(0),2) & dfy2=strtrim(yran(1),2) 
	  dfbs = strtrim(binsz,2)
	  def = [dfx1,dfx2,dfy1,dfy2,dfbs]
	  xgetvals,title=txt,lab=lab,row=row,def=def,val=val,exit=ex
	  if ex lt 0 then return
	  xran = [val(0),val(1)]+0L
	  yran = [val(2),val(3)]+0L
	  binsz = val(4)+0
;	  return
	endif
 
	;------  Get coordinates  -------------------
	if n_elements(fact) eq 0 then fact=1
	y1t = round(fact*y10)           ; Temp image y indices.
	y2t = round(fact*y20)           ; (Maybe correct, maybe not).
	if keyword_set(yrev) then begin ; Reverse y.
	  y1 = (ny-1) - y2t           ; Corrected image y indices.
	  y2 = (ny-1) - y1t
	endif else begin
	  y1 = y1t
	  y2 = y2t
	endelse
	;------  Extract subimage  -------------------
	sub = img(x1:x2, y1:y2)			; Extract subimage.
	;------  Statistics  -------------------------
	hh = histogram(sub,binsize=binsz,omin=omin,omax=omax)	; Histogram.
	xx = makei(omin,omax,binsz)		; Make x array.
	mn = min(sub,max=mx)			; Min/Max.
	imn = 'Min = '+strtrim(mn,2)		; Strings.
	imx = 'Max = '+strtrim(mx,2)
	imean = 'Mean = '+strtrim(mean(sub),2)	; Mean.
	isdev = 'SDev = '+strtrim(sdev(sub+0.),2) ; Sdev. (added +0. RES)
	ibox = 'Subimage = ('+strtrim(x1,2)+':'+strtrim(x2,2)+$
	  ','+strtrim(y1,2)+':'+strtrim(y2,2)+')'
	ibin = 'Bin size = '+strtrim(binsz,2)
	inum = 'Samples = '+strtrim(n_elements(sub),2)
 
	;------  Do plot  ----------------------------
	win_img = !d.window			; Save current window.
	wset, win				; Set plot window.
	csz = csz0
	noaa=1
	win_redirect
 
	if option eq 1 then begin	; Snap image option.
	  window,/free,xs=450,ys=450	; Larger window.
	  csz = 1.5*csz0		; Larger char size.
	  noaa = 0			; Do antialiasing.
	endif
 
	;--------  Plot commands  ----------------
	erase, c_bak
	aaplot,xx,hh,col=c_plt, $	; Histogram.
	  xtitl=tx,title=tt, ytitl=ty, $
	  pos=pos, chars=csz, noaa=noaa, $
	  xran=xran, yran=yran, /xstyle, psym=10
	txt = [imn,imx,imean,isdev,ibox,ibin,inum]
	chrsz = [csz,csz,csz,csz,csz,csz,csz]
	x = [tx1,tx2,tx1,tx2,tx1,tx1,tx2]
	y = [ty0,ty0,ty0-tdy,ty0-tdy,ty0-tdy*2,ty0-tdy*3,ty0-tdy*3]
	if option eq 1 then begin	; Add info for snapshot.
	  filebreak, info, dir=dir, nvfile=nam
	  txt = [txt,nam,dir]
	  chrsz = [chrsz,1,1]
	  x = [x,.01,.01]
	  y = [y,.01,.04]
	endif
	aatext, /norm, x, y, col=c_plt, chars=chrsz, txt, noaa=noaa
	empty
 
	if option eq 1 then begin	; Snap image option.
	  fmt = 'hist_y$n$0d$_h$m$s$.jpg'
	  jpg = dt_tm_fromjs(dt_tm_tojs(systime()),form=fmt)
	  jpegscreen, jpg
	  wdelete
	endif
 
	win_copy
	wset, win_img
 
 
	end
