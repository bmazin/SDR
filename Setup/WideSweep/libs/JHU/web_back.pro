;-------------------------------------------------------------
;+
; NAME:
;       WEB_BACK
; PURPOSE:
;       Generate a random web background.
; CATEGORY:
; CALLING SEQUENCE:
;       web_back, h, s, v
; INPUTS:
;       h = [h1,h2] min and max hue.       in
;       s = [s1,s2] min and max sat.       in
;       v = [v1,v2] min and max val.       in
; KEYWORD PARAMETERS:
;       Keywords:
;         SMOOTH=sm  Smoothing window size (def=3) which
;           gives a fine grained pattern.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: makes a 100 x 100 pixel background image
;         with a random s[eckle pattern that tiles
;         seamlessly.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Oct 13
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro web_back, h, s, v, smooth=sm, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Generate a random web background.'
	  print,' web_back, h, s, v'
	  print,'   h = [h1,h2] min and max hue.       in'
	  print,'   s = [s1,s2] min and max sat.       in'
	  print,'   v = [v1,v2] min and max val.       in'
	  print,' Keywords:'
	  print,'   SMOOTH=sm  Smoothing window size (def=3) which'
	  print,'     gives a fine grained pattern.'
	  print,' Notes: makes a 100 x 100 pixel background image'
	  print,'   with a random s[eckle pattern that tiles'
	  print,'   seamlessly.'
	  return
	endif
 
	if n_elements(sm) eq 0 then sm=3
 
	;------  Do color table  -----------
	tvlct, min(h),min(s),min(v),0,/hsv
	tvlct, max(h),max(s),max(v),topc(),/hsv
	tvlct,r,g,b,/get
	ctint, r, g, b, 0, topc()
	tvlct,r,g,b
 
	;-------  Make and tile image  --------------------
loop:	z = makez(100,100,sm, /periodic)*topc()
	window,xs=400,ys=400
	for i=0,15 do tv,z,i
 
	;------  Command  ---------------
	txt = ''
	read,' OK? y/n/q: ',txt
	if strupcase(txt) eq 'Q' then return
	if strupcase(txt) ne 'Y' then goto, loop
 
	;------  Crop and display  --------------
	a = tvrd(0,0,100,100)
	window,xs=100,ys=100
	tv,a
 
	;-------  Save  -------------	
	out = 'back_'+strtrim(fix(min(h)),2)+'_'+strtrim(fix(max(h)),2)+'.gif'
	gifscreen,out
 
	return
	end
