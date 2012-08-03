;-------------------------------------------------------------
;+
; NAME:
;       WEBSHADOW
; PURPOSE:
;       Add a shadow to a web page image.
; CATEGORY:
; CALLING SEQUENCE:
;       webshadow, image, back
; INPUTS:
;       image = name of image to shadow (GIF or JPEG).  in
;       back = name of background image (GIF).          in
;         Alternately background color may be given here instead:
;         Give as '#rrggbb' like '#ffffff' for white, '#000000' for
;         black, '#ff0000' for red, ...  Must use # at front and
;         R,G,B values as 2 digit hex.
;         Standard Netscape gray is '#c0c0c0'.
; KEYWORD PARAMETERS:
;       Keywords:
;         /IJPEG  means image is a JPEG file, else GIF.
;         /COLOR  means make shadows in color, else BW.
;           Gives a translucent effect.
;         WIDTH=wid  Shadow size (def=5).
;         BLUR=bl    Shadow blurring (def=5).
;         SHADOW=sh  Shadow darkness (def=0.5).
;         /JPEG   means use JPEG method to combine RGB components.
;           Else use color_quan.  Sometimes JPEG is a bit better.
;         /DITHER means use dithering in color combine algorithm.
;       Result is displayed on the screen.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1995 Nov 21
;	R. Sterner, 1996 Sep 20 --- Added TRANS=trans.
;       R. Sterner, 1998 Jan 15 --- Dropped use of !d.n_colors.
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro webshadow, image, back, color=color, width=wid, $
	  blur=blur, shadow=sh, jpeg=jpeg, dither=dith, help=hlp, $
	  ijpeg=ijpeg, trans=trans
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Add a shadow to a web page image.'
	  print,' webshadow, image, back'
	  print,'   image = name of image to shadow (GIF or JPEG).  in'
	  print,'   back = name of background image (GIF).          in'
	  print,'     Alternately background color may be given here instead:'
	  print,"     Give as '#rrggbb' like '#ffffff' for white, '#000000' for"
	  print,"     black, '#ff0000' for red, ...  Must use # at front and"
	  print,'     R,G,B values as 2 digit hex.'
	  print,"     Standard Netscape gray is '#c0c0c0'."
	  print,' Keywords:'
	  print,'   TRANS=t Index of transparent background (def=solid).'
	  print,'   /IJPEG  means image is a JPEG file, else GIF.'
	  print,'   /COLOR  means make shadows in color, else BW.'
	  print,'     Gives a translucent effect.'
	  print,'   WIDTH=wid  Shadow size (def=5).'
	  print,'   BLUR=bl    Shadow blurring (def=5).'
	  print,'   SHADOW=sh  Shadow darkness (def=0.5).'
	  print,'   /JPEG   means use JPEG method to combine RGB components.'
	  print,'     Else use color_quan.  Sometimes JPEG is a bit better.'
	  print,'   /DITHER means use dithering in color combine algorithm.'
	  print,' Result is displayed on the screen.'
	  return
	endif
 
	;-------  Defaults  -------------
	if n_elements(wid) eq 0 then wid=10	; Shadow width.
	if n_elements(blur) eq 0 then blur=5	; Blurring.
	if n_elements(sh) eq 0 then sh=.5	; Darkness.
	if n_elements(dith) eq 0 then dith=0    ; Dither.
	if n_elements(trans) eq 0 then trans=-1 ; Index of transparent bckgrnd.
 
	;-------  Read image  ----------
	if keyword_set(ijpeg) then begin	; Input image is JPEG.
	  read_jpeg, image, img, c, colors=256,/dither,/two_pass
	  ri=c(*,0) & gi=c(*,1) & bi=c(*,2)
	endif else begin
	  read_gif,image,img,ri,gi,bi		; Input image is GIF.
	endelse
	sz=size(img) & nix=sz(1) & niy=sz(2)		; Size.
	rimg=ri(img) & gimg=gi(img) & bimg=bi(img)	; Split into RGB.

	;------  Handle transparent background  ------------
	w = where(img ne trans, cnt)			; Find 1-d image pts.
	if cnt eq 0 then begin
	  print,' Error in webshadow: all of image is transparent.'
	  print,'   Aborting.'
 	  return
	endif
	one2two, w, img, iix, iiy			; Find 2-d image pts.

	;------  Background  ------------------	
	if strmid(back,0,1) eq '#' then begin		; Background as Color.
	  rb=0 & gb=0 & bb=0				; Want integers.
	  reads,back,rb,gb,bb,form='(x,3z2)'		; Interpret hex number.
	  rbck=bytarr(nix,niy)+rb			; Set up background
	  gbck=bytarr(nix,niy)+gb			; image color component
	  bbck=bytarr(nix,niy)+bb			; arrays.
	  nbx=nix & nby=niy				; Backgr image size.
	endif else begin
	  read_gif,back,bck,rb,gb,bb			; Background as Image.
	  sz=size(bck) & nbx=sz(1) & nby=sz(2)		; Size.
	  rbck=rb(bck) & gbck=gb(bck) & bbck=bb(bck)	; Split into RGB.
	endelse
 
	;-------  Resulting image size  --------
	rx = nix+wid+blur/2+2
	ry = niy+wid+blur/2+2
 
	;-------  Unshadowed image  -------------
	nx = ceil(rx/float(nbx))	; # background tiles in x.
	ny = ceil(ry/float(nby))	; # background tiles in y.
	sx=nx*nbx & sy=ny*nby		; Size in pixels.
	red = bytarr(sx,sy)		; New image components.
	grn = bytarr(sx,sy)
	blu = bytarr(sx,sy)
	for i=0,nx*ny-1 do begin	; Tile with background.
	  tvpos,rbck,i,res=[sx,sy],ix,iy	; Find insertion point.
	  red(ix,iy) = rbck		; Insert background image.
	  grn(ix,iy) = gbck
	  blu(ix,iy) = bbck
	endfor

	red(iix,iiy+sy-niy) = rimg(w)		; Insert image.
	grn(iix,iiy+sy-niy) = gimg(w)
	blu(iix,iiy+sy-niy) = bimg(w)

	;========  Make shadow  =============
	;---------  BW shadow  --------------
	zr = fltarr(nix,niy)			; Zero array.
	if not keyword_set(color) then begin
	  s = fltarr(sx,sy)+1.			; Pure white screen.
	  s(iix+wid,iiy+sy-niy-wid)=(zr+sh)(w)	; Shifted shadow.
	  s = smooth2(s,blur)			; Smooth shadow.
	  s(iix,iiy+sy-niy) = (zr+1.)(w)	; Mask out image position.
	  sred = s				; Shadow components.
	  sgrn = s				; All same for BW.
	  sblu = s
	endif else begin
	;--------  Color shadows  ---------------
	  sred = fltarr(sx,sy)+1.		; Pure red screen.
	  sred(iix+wid,iiy+sy-niy-wid) = (sh*rimg/255.)(w)	; Red shadow.
	  sred = smooth2(sred,blur)		; Smooth shadow.
	  sred(iix,iiy+sy-niy) = (zr+1.)(w)	; Mask out image position.
	  sgrn = fltarr(sx,sy)+1.		; Pure green screen.
	  sgrn(iix+wid,iiy+sy-niy-wid) = (sh*gimg/255.)(w)	; Green shadow.
	  sgrn = smooth2(sgrn,blur)		; Smooth shadow.
	  sgrn(iix,iiy+sy-niy) = (zr+1.)(w)	; Mask out image position.
	  sblu = fltarr(sx,sy)+1.		; Pure blue screen.
	  sblu(iix+wid,iiy+sy-niy-wid) = (sh*bimg/255.)(w)	; Blue shadow.
	  sblu = smooth2(sblu,blur)		; Smooth shadow.
	  sblu(iix,iiy+sy-niy) = (zr+1.)(w)	; Mask out image position.
	endelse
 
	;---------  Shadow image  ----------------
	red = byte(red*sred)
	grn = byte(grn*sgrn)
	blu = byte(blu*sblu)
 
	;----------  Combine R,G,B  ---------------
	if keyword_set(jpeg) then begin
          tmp = bytarr(sx,sy,3)                ; Set up image array.
          tmp(0,0,0) = red
          tmp(0,0,1) = grn
          tmp(0,0,2) = blu
          write_jpeg,'temp.jpg',tmp,true=3,quality=100    ; Save in jpeg file.
          read_jpeg, 'temp.jpg',c,cc,colors=!d.table_size,dither=dith,/two_pass
	  r = cc(*,0)
	  g = cc(*,1)
	  b = cc(*,2)
	endif else begin
	  c = color_quan(red,grn,blu,r,g,b,dither=dith)
	endelse
 
	;----------  Crop  ------------------------
	c = c(0:rx-1,sy-ry:sy-1)
	window,xs=rx,ys=ry,/free,title=strtrim(fix(rx),2)+' X '+$
	  strtrim(fix(ry),2)
	tv,c
	tvlct,r,g,b
 
	return
	end
