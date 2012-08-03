;-------------------------------------------------------------
;+
; NAME:
;       IMG_RADON
; PURPOSE:
;       Compute the Radon Transform of a color or B&W image.
; CATEGORY:
; CALLING SEQUENCE:
;       img_radon, img
; INPUTS:
;       img = Input image (Color or B&W).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         START=a1  Given start angle in degrees, default=0.
;         STOP=a2  Given stop angle in degrees, default=179.
;         STEP=da  Given angle step in degrees, default=1.
;         ANGLES=ang  Returned list of angles used (deg).
;         RADIUS=rd  Returned list of radii from image center (pix).
;         EMBED=n  Given size of zero image to embed given image in.
;           Def=no embed.
;         TRANSFORM=trans Returned Radon Transform image.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Display original image:
;           img_disp,img & win1=!d.window
;         Display Radon Transform of image:
;           izoom, ang, rd, bytscl(trans),/center
;         Explore Radon Transform:
;           xypro_radon,init=win1
;           crossi,xypro='xypro_radon',/mag
;           xypro_radon,/erase
; MODIFICATION HISTORY:
;       R. Sterner, 2006 Jun 27
;
; Copyright (C) 2006, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro img_radon, img, start=a1, stop=a2, step=da, angles=ang, $
	  embed=nx0, help=hlp, radius=rd, transform=trans
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
          print,' Compute the Radon Transform of a color or B&W image.'
	  print,' img_radon, img'
	  print,'   img = Input image (Color or B&W).  in'
	  print,' Keywords:'
	  print,'   START=a1  Given start angle in degrees, default=0.'
          print,'   STOP=a2  Given stop angle in degrees, default=179.'
          print,'   STEP=da  Given angle step in degrees, default=1.'
          print,'   ANGLES=ang  Returned list of angles used (deg).'
          print,'   RADIUS=rd  Returned list of radii from image center (pix).'
	  print,'   EMBED=n  Given size of zero image to embed given image in.'
          print,'     Def=no embed.'
	  print,'   TRANSFORM=trans Returned Radon Transform image.'
	  print,' Notes:'
	  print,'   Display original image:'
	  print,'     img_disp,img & win1=!d.window'
	  print,'   Display Radon Transform of image:'
	  print,'     izoom, ang, rd, bytscl(trans),/center'
	  print,'   Explore Radon Transform:'
	  print,"     xypro_radon,init=win1"
	  print,"     crossi,xypro='xypro_radon',/mag"
	  print,"     xypro_radon,/erase"
	  return
	endif
 
	;-------  B&W or Color?  ------------
	img_shape, img, true=true, nx=nx, ny=ny
 
	;--------  Non-square?  -----------
	if nx ne ny then begin
	  nn = nx > ny
	  nn2 = nn/2
	  nx2 = nx/2
	  ny2 = ny/2
	  typ = datatype(img,2)
	  z = make_array(nn,nn,type=typ)
	endif else nn2=nx/2
 
	;--------  Color image  -----------
	if true ne 0 then begin
	  ;----  Split into RGB components if any  -------
	  img_split, img, rr, gg, bb
	  ;----  Deal with non-square image ----
	  if nx ne ny then begin
	    zrr = z
	    zgg = z
	    zbb = z
	    zrr((nn2-nx2)>0,(nn2-ny2)>0) = rr
	    zgg((nn2-nx2)>0,(nn2-ny2)>0) = gg
	    zbb((nn2-nx2)>0,(nn2-ny2)>0) = bb
	    rr = temporary(zrr)
	    gg = temporary(zgg)
	    bb = temporary(zbb)
	  endif
	  ;-----  Transform  -----------
	  tr_rr = radon2(rr,start=a1,stop=a2,step=da,angles=ang,embed=nx0)
	  tr_rr = transpose(tr_rr)
	  tr_gg = radon2(gg,start=a1,stop=a2,step=da,angles=ang,embed=nx0)
	  tr_gg = transpose(tr_gg)
	  tr_bb = radon2(bb,start=a1,stop=a2,step=da,angles=ang,embed=nx0)
	  tr_bb = transpose(tr_bb)
	  trans = img_merge(tr_rr, tr_gg, tr_bb, true=true)
	  ntr = dimsz(tr_rr,2)
	;-------  B&W image  ---------
	endif else begin
	  if nx ne ny then begin
	    z((nn2-nx2)>0,(nn2-ny2)>0) = img
	    img = temporary(z)
	  endif else z=img
	  trans = radon2(z,start=a1,stop=a2,step=da,angles=ang,embed=nx0)
	  trans = transpose(trans)
	  ntr = dimsz(trans,2)
	endelse
 
	rd = maken(-nn2,nn2,ntr)
 
	end
