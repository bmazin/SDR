;-------------------------------------------------------------
;+
; NAME:
;       IMG_INSIMG
; PURPOSE:
;       Insert a subimage into an 24-bit color image.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_insimg(base,sub)
; INPUTS:
;       base = Original image.      in
;       sub = Sub image to insert.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         XSTART=ix, YSTART=iy lower left corner
;           of inserted image (def=0).
;         CHANNELS=chan  Color channels to insert (def='RGB').
;           Insert channels from sub into base.
;           May insert one or more color channels, like R,G,B for
;           the Red, Green, and Blue color components.  Or
;           H,S,V for Hue, Saturation, and Value.  May not mix
;           RGB and HSV.  For example, to colorize img0 based on
;           imgc: out=img_insimg(img0,imgc,chan='HS')
;         LOX=lox, HIX=hix Min and Max x pixels to use from sub.
;         LOY=loy, HIY=hiy Min and Max y pixels to use from sub.
;           Default is to use all of sub image.
;         The substituted channels may be weighted:
;         RWT=rwt, GWT=gwt, BWT=bwt RGB weights (0-1, def=1).
;         HOFF=hoff, SWT=swt, VWT=vwt  H offset (def, def=0),
;           S weight (0-1, def=1), V weight (0-1, def=1).
;         VMULT=vmult  Multiply base image brightness by sub
;           image brightness, vmult is a weighting factor:
;           0=no change, 1=max change.
;         VMIX=vmix mix base image and subimage values (brightness).
;           vmix=0 means all base img (def), 1 means all sub image.
;           Only one of VWT or VMIX may be used.  Must also include
;           V in the CHANNELS keyword for VMIX or VWT to work.
; OUTPUTS:
;       out = Resulting image.      out
; COMMON BLOCKS:
; NOTES:
;       Notes: if sub image is too big to fit inside base image
;         it is clipped to fit. Works for single channel (B&W)
;         images but none of the channel keywords apply.
; MODIFICATION HISTORY:
;       R. Sterner, 2001 Jun 25
;       R. Sterner, 2002 May 17 --- Fixed a V bug.
;       R. Sterner, 2002 May 20 --- Rewrite to simplify.
;       R. Sterner, 2006 Jul 17 --- Now works for B&W images (single channel).
;
; Copyright (C) 2001, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_insimg, base, sub, xstart=ix, ystart=iy, $
	  channels=chan, lox=lox, hix=hix, loy=loy, hiy=hiy, $
	  rwt=rwt, gwt=gwt, bwt=bwt, hoff=hoff, swt=swt, vwt=vwt, $
	  vmix=vmix, vmult=vmult, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Insert a subimage into an 24-bit color image.'
	  print,' out = img_insimg(base,sub)'
	  print,'   base = Original image.      in'
	  print,'   sub = Sub image to insert.  in'
	  print,'   out = Resulting image.      out'
	  print,' Keywords:'
	  print,'   XSTART=ix, YSTART=iy lower left corner'
	  print,'     of inserted image (def=0).'
	  print,"   CHANNELS=chan  Color channels to insert (def='RGB')."
	  print,'     Insert channels from sub into base.'
	  print,'     May insert one or more color channels, like R,G,B for'
	  print,'     the Red, Green, and Blue color components.  Or'
	  print,'     H,S,V for Hue, Saturation, and Value.  May not mix'
	  print,'     RGB and HSV.  For example, to colorize img0 based on'
	  print,"     imgc: out=img_insimg(img0,imgc,chan='HS')"
	  print,'   LOX=lox, HIX=hix Min and Max x pixels to use from sub.'
	  print,'   LOY=loy, HIY=hiy Min and Max y pixels to use from sub.'
	  print,'     Default is to use all of sub image.'
	  print,'   The substituted channels may be weighted:'
	  print,'   RWT=rwt, GWT=gwt, BWT=bwt RGB weights (0-1, def=1).'
	  print,'   HOFF=hoff, SWT=swt, VWT=vwt  H offset (def, def=0),'
	  print,'     S weight (0-1, def=1), V weight (0-1, def=1).'
	  print,'   VMULT=vmult  Multiply base image brightness by sub'
	  print,'     image brightness, vmult is a weighting factor:'
	  print,'     0=no change, 1=max change.'
	  print,'   VMIX=vmix mix base image and subimage values (brightness).'
	  print,'     vmix=0 means all base img (def), 1 means all sub image.'
	  print,'     Only one of VWT or VMIX may be used.  Must also include'
	  print,'     V in the CHANNELS keyword for VMIX or VWT to work.'
	  print,' Notes: if sub image is too big to fit inside base image'
	  print,'   it is clipped to fit. Works for single channel (B&W)'
	  print,'   images but none of the channel keywords apply.'
	  return,''
	endif
 
	;-------  Find shapes of images  ------------
	img_shape, base, true=tr1, nx=nx1, ny=ny1
	img_shape, sub,  true=tr2, nx=nx2, ny=ny2
 
	;-------  Determine channels to use  -------
	if n_elements(chan) eq 0 then chan='RGB'
	ch = strupcase(chan)
	rflag = strpos(ch,'R') ge 0
	gflag = strpos(ch,'G') ge 0
	bflag = strpos(ch,'B') ge 0
	hflag = strpos(ch,'H') ge 0
	sflag = strpos(ch,'S') ge 0
	vflag = strpos(ch,'V') ge 0
	rgb = rflag + gflag + bflag
	hsv = hflag + sflag + vflag
	if (rgb gt 0) and (hsv gt 0) then begin
	  print,' Error in img_insimg: Can not mix RGB and HSV channels.'
	  print," Request one of more of RGB or HSV, but not mixed."
	  print," Example: chan='HS'"
	  return,''
	endif
 
	;------  Set defaults  -------------
	if n_elements(ix) eq 0 then ix=0	; Default insertion point.
	if n_elements(iy) eq 0 then iy=0
	if n_elements(lox) eq 0 then lox=0	; Clip sub image to
	if n_elements(hix) eq 0 then hix=nx2-1	; lox:hix, loy:hiy
	if n_elements(loy) eq 0 then loy=0	; before using.
	if n_elements(hiy) eq 0 then hiy=ny2-1
	lox = lox > 0
	loy = loy > 0
	hix = hix < (nx2-1)
	hiy = hiy < (ny2-1)
 
	dx0 = hix-lox+1			; Size of unclipped part of subimage.
	dy0 = hiy-loy+1
	ix2 = (ix+dx0-1) < (nx1-1)	; Ending indices in base.
	iy2 = (iy+dy0-1) < (ny1-1)
	dx = ix2-ix+1			; Size of clipped part of subimage.
	dy = iy2-iy+1
 
	if n_elements(rwt) eq 0 then rwt=1.  ; Substituted Red weighting.
	if n_elements(gwt) eq 0 then gwt=1.  ; Substituted Green weighting.
	if n_elements(bwt) eq 0 then bwt=1.  ; Substituted Blue weighting.
	if n_elements(hoff) eq 0 then hoff=0. ; Substituted Hue offset.
	if n_elements(swt) eq 0 then swt=1.  ; Substituted Saturation weighting.
	if n_elements(vwt) eq 0 then vwt=1.  ; Substituted Value weighting.
	if n_elements(vmix) eq 0 then vmix=-1 ; Value mixing strength (none).
 
	;-----  Extracting working subimages  -------------
	img1 = img_subimg(base,ix,iy,dx,dy)	  ; Modified subset of base.
	img2 = img_subimg(sub,lox,loy,dx,dy)	  ; Subset of subimage.
 
	;------  Deal with single channel image (BW)  --------
	if tr1 eq 0 then begin
	  out = base
	  out(ix,iy) = img2
	  return, out
	endif
 
	;------  Split images into color components  ---------
	if hsv gt 0 then begin
	  img_split, base, h10, s10, v10, /hsv
	  img_split, img1, h1, s1, v1, /hsv
	  img_split, img2, h2, s2, v2, /hsv
	endif else begin
	  img_split, base, r10, g10, b10
	  img_split, img1, r1, g1, b1
	  img_split, img2, r2, g2, b2
	endelse
 
	;-----  Clip and insert subimage  ------------
	;------------  HSV  --------------------------
	if hsv gt 0 then begin
	  if hflag then begin
	    h10(ix,iy) = pmod(h2+hoff,360)
	  endif
	  if sflag then begin
	    s10(ix,iy) = (s2*swt)>0<1
	  endif
	  if vflag then begin
	    if vmix ge 0 then begin
	      ;---------------------------------------------
	      ; vmix=0 uses only base image brightness
	      ; vmix=1 uses only subimage brightness,
	      ; vmix=0.5 uses equal mix.
	      ;---------------------------------------------
	      if vmix lt 0.5 then begin
		v2 = (v1*(1-2*vmix*(1-v2))*(1+vmix))<1>0
	      endif else begin
		v2 = (v2*(1-2*(1.0-vmix)*(1-v1))*(2-vmix))<1>0
	      endelse
	    endif else begin ; No vmix.
	      if n_elements(vmult) eq 0 then begin  ; Just weighted v2.
	        v2 = (v2*vwt)>0<1
	      endif else begin			; Multiple image values.
		tmp = ((1-v2)*vmult)>0.<1.
		v2 = v1*(1-tmp)			; New brightness. 
	      endelse
	    endelse
	    v10(ix,iy) = v2
	  endif ; vflag
	  out = img_merge(h10,s10,v10,/hsv,true=tr1)
	;------------  RGB  --------------------------
	endif else begin
	  if rflag then r10(ix,iy) = (r2*rwt)>0<255
	  if gflag then g10(ix,iy) = (g2*gwt)>0<255
	  if bflag then b10(ix,iy) = (b2*bwt)>0<255
	  out = img_merge(r10,g10,b10,true=tr1)
	endelse
 
	return, out
 
	end
