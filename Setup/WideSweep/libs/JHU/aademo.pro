;-------------------------------------------------------------
;+
; NAME:
;       AADEMO
; PURPOSE:
;       Demo plot using the aa routines.
; CATEGORY:
; CALLING SEQUENCE:
;       aademo
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /anti make same plot using antialiasing.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: useful to show how to do antialiased plotting.
;       Do .run -t aademo to see code.
;       IDL routine    Antialiased equivalent
;          plot           aaplot, ...         (x/y plots)
;          oplot          aaplotp, /clip, ... (over plot)
;          xyouts         aatext, ...         (text)
;            ---          aapoint, ...        (plot points)
;       All the aa routines are procedures, just type the
;       name and RETURN for help.
;       Antialiasing is slower, it is useful to make it optional.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Jul 23
;       R. Sterner, 2003 May 23 --- added to library.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro aademo, antialias=anti, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Demo plot using the aa routines.'
	  print,' aademo'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   /anti make same plot using antialiasing.'
	  print,' Note: useful to show how to do antialiased plotting.'
	  print,' Do .run -t aademo to see code.'
	  print,' IDL routine    Antialiased equivalent'
	  print,'    plot           aaplot, ...         (x/y plots)'
	  print,'    oplot          aaplotp, /clip, ... (over plot)'
	  print,'    xyouts         aatext, ...         (text)'
	  print,'      ---          aapoint, ...        (plot points)'
	  print,' All the aa routines are procedures, just type the'
	  print,' name and RETURN for help.'
	  print,' Antialiasing is slower, it is useful to make it optional.'
	  return
	endif
 
	;----------------------------------------
	;  Use the aa* routines to do graphics.
	;  Add a flag for antialiasing, test
	;  with no antialiasing, make final
 	;  plot with antialiasing.
	;----------------------------------------
 
	;---  Init graphics in case of first plot  ------
	window,xs=50,ys=50,/pix
	erase
	wdelete
 
	;------  Antialias switch  -------------
	if n_elements(anti) eq 0 then anti=0
	noaa = 1-anti
	print,' '
	if keyword_set(anti) then begin
	  print,' Plot with Antialiasing'
	endif else begin
	  print,' Plot with no Antialiasing'
	endelse
 
	;------  Plot parameters  ----------
	c_wht = tarclr(255,255,255)
	c_blk = tarclr(0,0,0)
	c_red = tarclr(255,0,0)
	c_pnk = tarclr(255,200,200)
	c_brn = tarclr(/hsv,30,.6,.6)
	c_yel = tarclr(255,255,150)
	c_grn = tarclr(0,150,0)
	c_blu = tarclr(0,0,255)
	pos = [.15,.15,.95,.85]
	tt = 'Demo plot: '+ $
	  (['with no antialiasing','with antialiasing'])(anti)
	tx = 'Sample Number'
	ty = 'Value'
	txt = 'Demo text'
	txt2 = 'Small text'
	csz = 2
 
	;------  Make data  -------------------
	x = maken(0,100,101)
	y = makey(101,7,seed=1,/per)
	k = 5
	r = randomu(k,101)*2-1
	in = makei(5,95,5)
 
	;------  Make plot  -------------------
	erase, c_wht
	aaplot,x,y,pos=pos,col=c_blk,title=tt,xtitle=tx,ytitle=ty, $
	  charsize=csz, noaa=noaa
 
	;-------  Envelope  -------------------
	aaplotp,x,1.05*y,col=c_red, /clip, noaa=noaa
	aaplotp,x,0.95*y,col=c_blu, /clip, noaa=noaa
 
	;--------  Points  --------------------
	aapoint,x(in),y(in)+r(in)*.15,col=c_yel,ocol=c_grn, $
	  thick=1, size=2,/clip,sides=37,noaa=noaa
	aapoint,x(in+1),y(in+1)+r(in+1)*.15,col=c_pnk,ocol=c_blu, $
	  thick=1, size=2,/clip,sides=4, noaa=noaa
 
	;-------  Text  -------------------------
	aatext, 20, .2, txt, align=.5, chars=3, col=c_brn, $
	  charthick=3, noaa=noaa
	aatext, 20, .1, txt2, align=.5, chars=.75, col=c_blk, $
	  noaa=noaa
 
	print,' Do aademo,/help for details.'
	end
