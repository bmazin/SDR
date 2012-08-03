;---------------------------------------------------------------------------
;	plexview.pro = View complex values in a small window on an image
;	R. Sterner, 2004 Feb 27
;
;	To init:
;	  plexview, INIT=z, NX=nx, ny=ny, /KEEP
;	    z = Input complex image array.
;	    nx, ny = Subarea size in pixels.
;	    /KEEP means keep vector view on exit.
;
;	Call (from box2b as change routine (CHANGE='plexview')):
;	  plexview, x1,x2,y1,y2,fact=fact,yrev=yrev,option=opt,info=info
;	    Do box2b,/ch_details for details.
;
;	Terminate:
;	  plexview,/terminate
;	    Cleans up internal array copy, may delete window.
;---------------------------------------------------------------------------
 
	pro plexview, init=z0, nx=nx, ny=ny, keep=keep, terminate=term, $
	  x1,x2,y1,y2,fact=fact,yrev=yrev,option=opt,info=info
 
	common plexview_com, z, win1, kflag
 
	;------  Initialize  ---------
	if n_elements(z0) gt 0 then begin
	  win0 = !d.window		; Incoming window.
	  if keyword_set(keep) then kflag=1 else kflag=0
	  z = z0
	  sz=size(z) & tt='Full array size: '+strtrim(sz(1),2)+ $
	    ' x '+strtrim(sz(2),2)
	  ;----  Estimate window size needed.  ----
	  sx = nx*14
	  sy = ny*14
	  window,/pixmap, xs=sx, ys=sy	; Output window.
	  plot,[0,nx-1],[0,ny-1],chars=1.2,/iso,/xstyl,/ystyl
	  xpos = !x.window*!d.x_size
	  ypos = !y.window*!d.y_size
	  wdelete
	  ;-----  Adjust window size and make plot window  ----
	  sx = sx + xpos(0) + (sx-xpos(1))
	  sy = sy + ypos(0) + (sy-ypos(1))
	  window,/free, xs=sx, ys=sy, titl=tt	; Output window.
	  win1 = !d.window
	  wset, win0			; Set back to incoming window.
	  return
	endif
 
	;-----  Terminate  ------------
	if keyword_set(term) then begin
	  if kflag eq 0 then wdelete, win1  ; Delete display window.
	  z = 0				; Kill off array.
	  return
	endif
 
	;-----  Call from box2b  --------
	win0 = !d.window		; Incoming window.
	s = z(x1:x2,y1:y2)		; Extract sub area.
	wset, win1
	win_redirect
	vecfld,s,/iso,/mag,/mark,symsize=.3,symcol=-1,vscale=2,x0=x1,y0=y1
	win_copy
	wset, win0			; Set back to incoming window.
 
	return
 
	end
