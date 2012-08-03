;-------------------------------------------------------------
;+
; NAME:
;       IMGSQZ
; PURPOSE:
;       Squeeze number of image colors used for current image.
; CATEGORY:
; CALLING SEQUENCE:
;       imgsqz
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         NUMBER=n  Number of colors to free up (def=10).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: modifies image and color table to free up
;       n new colors starting at 0.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Jan 6
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro imgsqz, help=hlp, number=num
 
	if keyword_set(hlp) then begin
	  print,' Squeeze number of image colors used for current image.'
	  print,' imgsqz'
	  print,'   No args.'
	  print,' Keywords:'
	  print,'   NUMBER=n  Number of colors to free up (def=10).'
	  print,' Notes: modifies image and color table to free up'
	  print,' n new colors starting at 0.'
	  return
	endif
 
	if n_elements(num) eq 0 then num=10
 
	;-----------------------------------------------------------
	;	Read current image and color table
	;-----------------------------------------------------------
	print,' Reading current image and color table . . .'
	a = tvrd()			; Read image.
	tvlct,r,g,b,/get		; Read color table.
	r=r+0.  & g=g+0.  & b=b+0.	; Convert from bytes to ints.
 
	;-----------------------------------------------------------
	;	Find list of color indices to take over.
	;	  Do this by finding the n least used colors.
	;-----------------------------------------------------------
	h = histogram(a)		; Make image histogram.
	in = indgen(n_elements(h))	; Corresponding indices.
	is = sort(h)
	in = in(is)			; Sort colors in order of #pix.
	list = in(0:num-1)		; List of indices to free.
	nlist = n_elements(list)	; Number of colors to free.
	worst = max(h(list))		; Find max pixels changed.
	print,' '
	print,' To get needed colors biggest change is '+$
	  strtrim(worst,2)+' pixels.'
	print,' '
 
	;-----------------------------------------------------------
	;	Merge colors to drop with best matches.
	;	  Do this by first collecting all the colors to
	;	  be dropped, then setting their color table entries
	;	  to a wild value (-1000), then finding the closest
	;	  match to each color and setting the image pixels
	;	  to that new color.
	;-----------------------------------------------------------
	rd = fix(r(list))		; Collect colors to drop.
	gd = fix(g(list))
	bd = fix(b(list))
	r(list) = -1000		; Flag dropped colors to be ignored.
	g(list) = -1000
	b(list) = -1000
	for i=0, nlist-1 do begin	; Find closest match for each.
	  w = where(a eq list(i),cnt)	; Find image pixels of dropped clr.
	  if cnt gt 0 then begin	; Any such pixels?
	    d = (rd(i)-r)^2 + (gd(i)-g)^2 + (bd(i)-b)^2	; Dist^2 for clr i.
	    im =(where(d eq min(d)))(0)	; Best match.
	    print,' Color '+string(list(i),form='(I3)')+' has '+$
	      strtrim(cnt,2)+' pixel'+plural(cnt)+', setting to '+strtrim(im,2)
	    print,'   ('+strtrim(rd(i),2)+','+strtrim(gd(i),2)+','+$
	      strtrim(bd(i),2)+') ---> ('+strtrim(fix(r(im)),2)+','+$
	      strtrim(fix(g(im)),2)+','+strtrim(fix(b(im)),2)+')'
	    a(w) = im			; Change image pixels to best match clr.
	  endif else print,' Color '+string(list(i),form='(I3)')+' has no pixels.'
	endfor
 
	;-----------------------------------------------------------
	;	Swap each freed color with one from table bottom.
	;	  Do this by moving an index near table bottom to
	;	  one of the freed color indices, then setting all
	;	  image pixels from the low color to the freed color.
	;-----------------------------------------------------------
	for i=0,nlist-1 do begin
	  j = list(i)			; Freed color.
	  r(j) = r(i)			; Move low color up to freed color.
	  g(j) = g(i)
	  b(j) = b(i)
	  r(i)=0 & g(i)=0 & b(i)=0	; Set freed color to black (for now).
	  w = where(a eq i, cnt)	; Find all low color pixels.
	  print,' Moving '+string(cnt,form='(I6)')+' image pixels from index '+$
	    string(i,form='(I3)')+' to index '+string(j,form='(I3)')
	  if cnt gt 0 then a(w)=j	; Low color is now high color.
	endfor
 
	;-----------------------------------------------------------
	;	Setting default new colors.
	;-----------------------------------------------------------
	print,' '
	print,' Setting default colors.'
	rnew = [000,255,128,255,255,255,000,000,000,255]
	gnew = [000,255,128,000,128,255,255,255,000,000]
	bnew = [000,255,128,000,000,000,000,255,255,255]
	name = ['Black','White','Gray','Red','Orange','Yellow',$
	  'Green','Cyan','Blue','Magenta','Black']
	last = (nlist-1)<9
	r(0) = rnew(0:last)
	g(0) = gnew(0:last)
	b(0) = bnew(0:last)
	print,'     New colors:'
	for i=0,nlist-1 do print,i,' - '+name([i<10])
 
	;-----------------------------------------------------------
	;	Put back modified image and color table.
	;-----------------------------------------------------------
	print,' '
	print,' Displaying modified image and color table.'
	tv,a
	tvlct,byte(r),byte(g),byte(b)
 
	end
