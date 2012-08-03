;---------------------------------------
;	npow_demo.pro = Demo of npow.
;	R. Sterner, 2005 Feb 10
;---------------------------------------
 
	pro npow_demo
 
	nlo = 2
	nhi = 6
	plo = 1
	phi = 4
 
	swindow,xs=720*(nhi-nlo+1),ys=720*(phi-plo+1)
	plot,[0,1],pos=[0,0,1,1]
	erase,-1
	dd = 175*4
	r = 50*4
	x0 = 100*4
	y0 = 100*4
	clr1 = tarclr(0,0,255)
	clr2 = tarclr(/hsv,0,1,1)
 
	for n=nlo,nhi do begin
	  xc = x0 + (n-nlo)*dd
	  for p=plo, phi do begin
	    yc = y0 + (p-plo)*dd
	    cen = [xc,yc]
	    npow,n,p,r=r,/nocirc,fcol=clr1,cen=cen
	    npow,n,p,r=r,/nofr,frac=.75,/fill,ccol=clr2,cen=cen	
	  endfor ; p
	endfor ; n
 
	end
