;-------------------------------------------------------------
;+
; NAME:
;       SCALE_RGB
; PURPOSE:
;       Interactively scale R,G,B image components.
; CATEGORY:
; CALLING SEQUENCE:
;       scale_rgb, ri,gi,bi,ro,go,bo
; INPUTS:
;       ri,gi,bi = Input Red, Green, Blue image arrays.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  Error flag: 0=ok, 1=cancel.
;         TOP=top  Max value for returned scaled images (def=255.
;         BOT=bot  Min value for returned scaled images (def=0).
;           TOP and/or BOT may be a 3 element array ([r,g,b]).
;         INSCALE=isc, OUTSCALE=osc  2x3 arrays giving the
;           input and output image ranges used to scale the R,G,B.
; OUTPUTS:
;       ro,go,bo = Ouput Red, Green, Blue image arrays.   out
; COMMON BLOCKS:
; NOTES:
;       Notes: All the image components are assumed to be the
;         same size (not checked).  Intended for scaling image
;         components to combine into a color result.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 25
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro scale_rgb, ri,gi,bi,ro,go,bo,error=err,inscale=inscale,$
	  outscale=outscale, top=top,bot=bot,help=hlp
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Interactively scale R,G,B image components.'
	  print,' scale_rgb, ri,gi,bi,ro,go,bo'
	  print,'   ri,gi,bi = Input Red, Green, Blue image arrays.   in'
	  print,'   ro,go,bo = Ouput Red, Green, Blue image arrays.   out'
	  print,' Keywords:'
	  print,'   ERROR=err  Error flag: 0=ok, 1=cancel.'
	  print,'   TOP=top  Max value for returned scaled images (def=255.'
	  print,'   BOT=bot  Min value for returned scaled images (def=0).'
	  print,'     TOP and/or BOT may be a 3 element array ([r,g,b]).'
	  print,'   INSCALE=isc, OUTSCALE=osc  2x3 arrays giving the'
	  print,'     input and output image ranges used to scale the R,G,B.'
	  print,' Notes: All the image components are assumed to be the'
	  print,'   same size (not checked).  Intended for scaling image'
	  print,'   components to combine into a color result.'
	  return
	endif
 
	if n_elements(top) eq 0 then top=[255,255,255]
	if n_elements(bot) eq 0 then bot=[0,0,0]
	if n_elements(top) eq 1 then top=top*[1,1,1]
	if n_elements(bot) eq 1 then bot=bot*[1,1,1]
 
	sz=size(ri) & nx=sz(1) & ny=sz(2)
	inscale = bytarr(2,3)		; Returned scaling info.
	outscale = bytarr(2,3)
 
	;---------  Red  -----------------
	swindow,xs=nx,ys=ny,colors=256,x_scr=1200<nx,y_scr=900<ny,title='RED'
	loadct,0 & tv,ri
	imgscale,in,ot,exit=err,/saturate
	if err ne 0 then begin
	  swdelete,!d.window
	  return
	endif
	in = fix(255*in)
	ot = fix(255*ot)
	inscale(0,0)=in & outscale(0,0)=ot
	ot = [bot(0)>ot(0),top(0)<ot(1)]
	ro = scalearray(ri,in(0),in(1),ot(0),ot(1))>bot(0)<top(0)
	loadct,0 & tv,ro
	swdelete,!d.window
 
	;---------  Green  -----------------
	swindow,xs=nx,ys=ny,colors=256,x_scr=1200<nx,y_scr=900<ny,title='GREEN'
	loadct,0 & tv,gi
	imgscale,in,ot,exit=err,/saturate
	if err ne 0 then begin
	  swdelete,!d.window
	  return
	endif
	in = fix(255*in)
	ot = fix(255*ot)
	ot = [bot(1)>ot(0),top(1)<ot(1)]
	inscale(0,1)=in & outscale(0,1)=ot
	go = scalearray(gi,in(0),in(1),ot(0),ot(1))>bot(1)<top(1)
	loadct,0 & tv,go
	swdelete,!d.window
 
	;---------  Blue  -----------------
	swindow,xs=nx,ys=ny,colors=256,x_scr=1200<nx,y_scr=900<ny,title='BLUE'
	loadct,0 & tv,bi
	imgscale,in,ot,exit=err,/saturate
	if err ne 0 then begin
	  swdelete,!d.window
	  return
	endif
	in = fix(255*in)
	ot = fix(255*ot)
	ot = [bot(2)>ot(0),top(2)<ot(1)]
	inscale(0,2)=in & outscale(0,2)=ot
	bo = scalearray(bi,in(0),in(1),ot(0),ot(1))>bot(2)<top(2)
	loadct,0 & tv,bo
	swdelete,!d.window
 
	err = 0
 
	return
	end
