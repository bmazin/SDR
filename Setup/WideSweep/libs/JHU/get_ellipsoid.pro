;-------------------------------------------------------------
;+
; NAME:
;       GET_ELLIPSOID
; PURPOSE:
;       Return an ellipsoid structure.
; CATEGORY:
; CALLING SEQUENCE:
;       get_ellipsoid, name, ell
; INPUTS:
;       name = Name of ellipsoid.            in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST  lists available ellipsoids.
;         ERROR=err  Error flag: 0=ok, 1=not found.
; OUTPUTS:
;       ell = Returned ellipsoid structure.  out
;         Contains a, 1/f, and name.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Apr 18
;       R. Sterner, 2002 Apr 26 --- Fixed output structure tag typo.
;       R. Sterner, 2002 May 01 --- Fixed error flag.
;       R. Sterner, 2004 Jul 28 --- Handled ambiguous matches better.
;       R. Sterner, 2004 Nov 12 --- Embedded ellipsoid definition text.
;       R. Sterner, 2006 Jan 23 --- Added Unit Sphere.
;       R. Sterner, 2006 Jan 23 --- Added 1000 km Sphere.
;       R. Sterner, 2007 Mar 26 --- Added Jupiter.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro get_ellipsoid, name, ell, list=list, error=err, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return an ellipsoid structure.'
	  print,' get_ellipsoid, name, ell'
	  print,'   name = Name of ellipsoid.            in'
	  print,'   ell = Returned ellipsoid structure.  out'
	  print,'     Contains a, 1/f, and name.'
	  print,' Keywords:'
	  print,'   /LIST  lists available ellipsoids.'
	  print,'   ERROR=err  Error flag: 0=ok, 1=not found.'
	  return
	endif
 
	err = 1
 
;	;-------  Read definitions file  --------------
;	whoami, dir
;	file = filename(dir,'ellipsoid_definitions.txt',/nosym)
;	txt0 = getfile(file,err=err1)
;	if err1 ne 0 then begin
;	  print,' Error in get_ellipsoid: could not find '+file
;	  return
;	endif
	;-------  Set up ellipsoid definitions text array  -----
	txt0 = ['*-----------------------------------------------------',$
	        '*  Definitions of common ellipsoid',$
		'*  (To be extended as needed)',$
		'*  Ray Sterner, 2002 Apr 18',$
		'*  See http://164.214.2.59/GandG/wgs84dt/ellips.txt',$
		'*-----------------------------------------------------',$
		'*  a = semimajor axis in meters',$
		'*  f = flattening factor',$
		'*  name = name of ellipsoid',$
		'*-----------------------------------------------------',$
		' ',$
		'*      a           1/f          Name',$
		'  6377563.396   299.3249646     Airy',$
		'  6377340.189   299.3249646     Airy (Modified)',$
		'  6378160.      298.25          Australian National',$
		'  6377397.155   299.1528128     Bessel 1841',$
		'  6377483.865   299.1528128     Bessel 1841 (Namibia)',$
		'  6378206.400   294.9786982     Clarke 1866',$
		'  6378249.145   293.465000      Clarke 1880',$
		'  6377298.556   300.8017        Everest (Brunei, E. Malaysia (Sabah & Sarawak))',$
		'  6377276.345   300.8017        Everest 1830',$
		'  6377301.243   300.8017        Everest 1956 (India and Nepal)',$
		'  6377309.613   300.8017        Everest (Pakistan)',$
		'  6377304.063   300.8017        Everest 1948 (W. Malaysia and Singapore)',$
		'  6377295.664   300.8017        Everest 1969 (W. Malaysia)',$
		'  6378137.      298.257222101   Geodetic Reference System 1980 (GRS 80)',$
		'  6378200.      298.3           Helmert 1906',$
		'  6378270.      297.            Hough 1960',$
		'  6378160.      298.247         Indonesian 1974',$
		'  6378388.000   297.000000      International',$
		'  6378245.      298.3           Krassovsky 1940',$
		'  6378155.      298.3           Modified Fischer 1960',$
		'  6378160.000   298.250000      South American 1969',$
		'  6378135.      298.26          WGS 1972',$
		'  6378137.000   298.257223563   WGS 84',$
		'  3396190.      169.8           Mars MOLA', $
		'        1.      1D500           Unit Sphere', $
		'  1000000.      1D500           1000 km Sphere', $
	        '  71492000.     15.414403       Jupiter IAU']
	txt = drop_comments(txt0)
 
	;-------  List  -----------------------------
	if keyword_set(list) then begin
	  for i=0,n_elements(txt0)-1 do print,txt0(i)
	endif
 
	if n_elements(name) eq 0 then return
 
	;--------  Extract parts  --------------------
	n = n_elements(txt)
	a = dblarr(n)
	f = dblarr(n)
	indx = indgen(n)		; Index into arrays.
	enam = strarr(n)
	for i=0,n-1 do begin
	  t = txt(i)
	  a(i) = getwrd(t,0)+0D0	; Pick off a.
	  f(i) = getwrd(t,1)+0D0	; Pick off f.
	  enam(i) = getwrd(t,2,99)	; Ellipsoid name is all the rest.
	endfor
 
	;-------  Search --------------------------
	enam2 = str_drop_punc(enam,/lower)	; Ell names lower case.
	wordarray, strlowcase(name), wds	; Request lower case.
 
	for i=0,n_elements(wds)-1 do begin	; Loop through words in name.
	  w = where(strpos(enam2,wds(i)) ge 0, c)  ; Look for word i.
	  if c eq 0 then begin
	    print,' get_ellipsoid: request not found: '+name
	    return
	  endif
	  if c eq 1 then begin
	    in = indx(w(0))
	    ell = {a:a(in), f1:f(in), name:enam(in)}
	    err = 0
	    return
	  endif
	  enam2 = enam2(w)		; Found multiple, keep searching.
	  indx = indx(w)
	endfor
 
	;------  Multiple matches, compare number of words  -----
	nwds = indx*0		; Count # words in matches.
	for i=0,n_elements(enam2)-1 do nwds(i)=nwrds(enam2(i))
	w = where(nwrds(name) eq nwds, c)	; # must match request.
	if c eq 1 then begin			; One did, return it.
	  in = indx(w(0))
	  ell = {a:a(in), f1:f(in), name:enam(in)}
	  err = 0
	  return
	endif
 
	;------  Ambiguous  -------------------
	print,' get_ellipsoid - ambiguous request:'
	more,'                 '+enam(indx)
 
	return
 
	end
