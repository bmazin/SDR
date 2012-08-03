;-------------------------------------------------------------
;+
; NAME:
;       IMG_SCALE
; PURPOSE:
;       Scale given image for display.
; CATEGORY:
; CALLING SEQUENCE:
;       out = img_scale(in,sc,par)
; INPUTS:
;       in = Input image (2-d or 3-d).   in
;       sc = scaling option (0 to n).    in
;         0: No scaling.
;         1: Scale to image min/max:  bytscl(img).
;         2: Scale to specified min/max:  scalearray(v,mn,mx)
;         3: Percentile scaling:  ls(img,lo,hi)
;         4: Variance scaling:  bytscl(varf(img,wid)<thresh)
;         5: Unsharp masking:  ls(img-wt*smooth(img,wid),lo,hi)
;         6: Interactive scaling. BYT, INT, UNIT images only.
;         7: Apply scaling from last interactive.
;       par = Parameter structure.       in
;         Depends on scaling option (values shown are defaults):
;         0: Not used.
;         1: Not used.
;         2: {min:min, max:max}
;         3: {lo:min, hi:max, nbins:2000, quiet:0}
;         4: {width:3, thresh:100}
;         5: {wt:0.5, width:5, lo:1, hi:1, nbins:2000, quiet:0}
;         6: Returned with scaling info.
;         7: Send returned structure from option 6.
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err Error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: make sure the correct tag names are used in the
;         par structure, no checking is done. Any or all missing
;         parameter values are defaulted.
;       
;         Also note that color images are split into Hue, Saturation,
;         and Value.  Scaling is applied to Value which ranges from
;         0 to 1.  So use values appropriate for that range.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jul 08
;       R. Sterner, 2003 Sep 23 --- Added error flag.  Also fixed opt 7.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function img_scale, img0, sc, par, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Scale given image for display.'
	  print,' out = img_scale(in,sc,par)'
	  print,'   in = Input image (2-d or 3-d).   in'
	  print,'   sc = scaling option (0 to n).    in'
	  print,'     0: No scaling.'
	  print,'     1: Scale to image min/max:  bytscl(img).'
	  print,'     2: Scale to specified min/max:  scalearray(v,mn,mx)'
	  print,'     3: Percentile scaling:  ls(img,lo,hi)'
	  print,'     4: Variance scaling:  bytscl(varf(img,wid)<thresh)'
	  print,'     5: Unsharp masking:  ls(img-wt*smooth(img,wid),lo,hi)'
	  print,'     6: Interactive scaling. BYT, INT, UNIT images only.'
	  print,'     7: Apply scaling from last interactive.'
	  print,'   par = Parameter structure.       in'
	  print,'     Depends on scaling option (values shown are defaults):'
	  print,'     0: Not used.'
	  print,'     1: Not used.'
	  print,'     2: {min:min, max:max}'
	  print,'     3: {lo:min, hi:max, nbins:2000, quiet:0}'
	  print,'     4: {width:3, thresh:100}'
	  print,'     5: {wt:0.5, width:5, lo:1, hi:1, nbins:2000, quiet:0}'
	  print,'     6: Returned with scaling info.'
	  print,'     7: Send returned structure from option 6.'
	  print,' Keywords:'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,' Note: make sure the correct tag names are used in the'
	  print,'   par structure, no checking is done. Any or all missing'
	  print,'   parameter values are defaulted.'
	  print,' '
	  print,'   Also note that color images are split into Hue, Saturation,'
	  print,'   and Value.  Scaling is applied to Value which ranges from'
	  print,'   0 to 1.  So use values appropriate for that range.'
	  return,''
	endif
 
	err = 0
 
	;--------  Default parameters  --------
	if n_elements(par) eq 0 then par={null:0}
 
	;--------  No scaling  ----------------
	if sc eq 0 then return, img0
 
	;--------  Image type  -----------
	img_shape, img0, true=tr
 
	;--------  Deal with Color or B&W image  --------
	if tr ne 0 then begin		; Color image.
	  img_split, img0, h,s,v,/hsv
	  if (sc eq 6) or (sc eq 7) then v=uint(v*60000L)
	endif else begin		; B&W image.
	  v = img0
	endelse
 
	;-------  Do Scaling  -----------------
	case sc of
1:	begin		; Scale to image min/max.
	  v = bytscl(v)
	end
2:	begin		; Scale to specified min/max.
	  if tag_test(par,'min') then mn=par.min else mn=min(v,max=mx)
	  if tag_test(par,'max') then mx=par.max
	  v = scalearray(v,mn,mx)>0<255
	end
3:	begin		; Percentile scaling.
	  if tag_test(par,'lo') then lo=par.lo else lo=1
	  if tag_test(par,'hi') then hi=par.hi else hi=1
	  if tag_test(par,'quiet') then q=par.quiet else q=0
	  if tag_test(par,'nbins') then n=par.nbins else n=2000
	  v = ls(v,lo,hi,quiet=q,nbins=n)
	end
4:	begin		; Variance scaling.
	  if tag_test(par,'width') then wid=par.width else wid=3
	  if tag_test(par,'thresh') then th=par.thresh else th=100.
	  v = bytscl(varf(v+0.,wid)<th)
	end
5:	begin		; Unsharp masking.
	  if tag_test(par,'lo') then lo=par.lo else lo=1
	  if tag_test(par,'hi') then hi=par.hi else hi=1
	  if tag_test(par,'quiet') then q=par.quiet else q=0
	  if tag_test(par,'nbins') then n=par.nbins else n=2000
	  if tag_test(par,'wt') then wt=par.wt else wt=0.5
	  if tag_test(par,'width') then wid=par.width else wid=5
	  v = ls(v-wt*smooth(v,wid),lo,hi,quiet=q,nbins=n)
	end
6:	begin		; Interactive scaling.
	  img_ice, v, scale=par, error=err
	  if par.rx eq -999 then return,img0
	  if err ne 0 then return,img0
	  img_ce, v, par, out=v2
	  v = v2
	end
7:	begin		; Apply scaling from last interactive.
	  if not tag_test(par,'rx') then return,img0
	  img_ce, v, par, out=v2
	  v = v2
	end
else:	begin
	  print,' Error in img_scale: unknown scaling option: ',sc
	  err = 1
	  return,img0
	end
	endcase
 
	;--------  Deal with Color or B&W image  --------
	if tr eq 0 then begin
	  return, v
	endif else begin
	  out = img_merge(/hsv, h, s, vnorm(v), true=tr)
	  return, out
	endelse
 
	end
