;-------  sector_demo.pro - Demonstrate sector routine.  ----
;	R. Sterner, 2005 Feb 15
 
	pro sector_demo, explode=explode
 
	a = maken(0.,360.,8)		; 7 sectors.
	da = randomu(k,6)*30-15		; Randomize size a bit.
	a(1) = a(1:6) + da
 
	window,xs=600,ys=600				; New window.
	plot,[-1.3,1.3],[-1.3,1.3],/iso,pos=[0,0,1,1]	; Set up coordinates.
	erase,-1					; White background.
 
	for i=0,6 do begin			; Loop through sectors.
	  a1 = a(i)				; Sector angles.
	  a2 = a(i+1)
	  clrf = tarclr(/hsv,i*50.,.3,1)	; Sector color.
	  clro = 0				; Black outline.
	  thk = 2				; Outline thickness.
	  fr = 0.
	  if keyword_set(explode) then begin
	    if randomu(k) lt 0.333 then fr=0.25
	  endif
	  sector,a1,a2,/fill,col=clrf,ocol=clro,thick=thk, $
	    tx=tx,ty=ty, frac=fr
	  lab = string(byte(i+65))		; Make label.
	  textplot,tx,ty,lab,align=[.5,.5],col=0, chars=2, bold=2
	endfor
 
	end
