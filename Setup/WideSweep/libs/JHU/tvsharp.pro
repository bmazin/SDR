;-------------------------------------------------------------
;+
; NAME:
;       TVSHARP
; PURPOSE:
;       Redisplay a sharpened version of the current screen image.
; CATEGORY:
; CALLING SEQUENCE:
;       tvsharp
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SMOOTH=sm  Smoothing window size (def=3).
;         WEIGHT=wt  Weight for smoothed image (def=0.75).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: BW images only.  Use odd values for SMOOTH: 3,5,7,...
;         WEIGHT should be >0 and < 1.
; MODIFICATION HISTORY:
;       R. Sterner, 1997 Feb 17
;       R. Sterner, 1999 Sep 15 --- Added optional smoothing and weight.
;
; Copyright (C) 1997, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro tvsharp, smooth=sm, weight=wt, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Redisplay a sharpened version of the current screen image.'
	  print,' tvsharp'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   SMOOTH=sm  Smoothing window size (def=3).'
	  print,'   WEIGHT=wt  Weight for smoothed image (def=0.75).'
	  print,' Notes: BW images only.  Use odd values for SMOOTH: 3,5,7,...'
	  print,'   WEIGHT should be >0 and < 1.'
	  return
	endif
 
	;------  Defaults  -------------
	if n_elements(sm) eq 0 then sm=3
	if n_elements(wt) eq 0 then wt=0.75
 
	tvlct,r,g,b,/get
	color_convert,r,g,b,h,s,v,/rgb_hsv
	if max(s) gt 0 then begin
	  print,' Only works for BW images.'
	  return
	endif
 
	a = float(tvrd())
	s = a-wt*smooth(a,sm)
	s = s*sdev(a)/sdev(s)
	s = s+mean(a)-mean(s)
	tv,byte(s>0<255)
 
	return
	end
