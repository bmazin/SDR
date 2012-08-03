;-------------------------------------------------------------
;+
; NAME:
;       TESTCOLOR
; PURPOSE:
;       Display colors selected by number.
; CATEGORY:
; CALLING SEQUENCE:
;       testcolor
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /ALL displays all colors with names and numbers.
;	  START=n starts displaying at color # n (def=0).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Jan, 1990
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro testcolor, help=hlp, all=all, start=start
 
	if keyword_set(hlp) then begin
	  print,' Display colors selected by number.'
	  print,' testcolor'
	  print,' Keywords:'
	  print,'   /ALL displays all colors with names and numbers.'
	  print,'   START=n starts displaying at color # n (def=0).'
	  return
	endif
 
	if keyword_set(all) then begin
	  dmx = topc()
	  color,'white',dmx,maxnum=mx
	  b = bytarr(120,30)
	  if n_elements(start) eq 0 then start = 0
	  for i = start, (start+dmx)<(mx-1) do tv, b+i-start, i-start
	  for i = start, (start+dmx)<(mx-1) do begin
	    color,'d',i-start,num=i,name=nm, text=txt
	    tvpos, b, i-start, x, y
	    xyouts,x+5,y+17,nm,color=txt,/dev
	    xyouts,x+5,y+3,strtrim(i,2),color=txt,/dev
	  endfor
	  return
	endif
 
	print,' Test color. May display colors without changing current table.'
	save = tvrd(0,0,100,100)
	tv,bytarr(100,100) + 1
	tvlct, r, g, b, /get
	svrd = r(1)  & svgr = g(1)  & svbl = b(1)
	color,'red',1,maxnum=mx
tloop0:	color, /list
tloop:	tmp = ''
	read, ' Enter color number to display (? for color list): ', tmp
	if tmp eq '?' then goto, tloop0
	if tmp eq '' then begin
	  r(1) = svrd & g(1) = svgr & b(1) = svbl
	  tv, save
	  return
	endif
	tmp = tmp + 0
	if tmp gt mx-1 then begin
	  print,' Max color number = ',mx-1
	  print,' Re-enter'
	  goto, tloop
	endif
	color,'d',0,number=tmp,/exit,red=trd,green=tgr,blue=tbl,name=tnm
	print,' Color = '+tnm
	r(1) = trd   & g(1) = tgr   & b(1) = tbl
	tvlct, r, g, b
	goto, tloop
 
	end
