;-------------------------------------------------------------
;+
; NAME:
;       WAVELENGTH_TO_HUE
; PURPOSE:
;       Convert an array of wavelengths to hues.
; CATEGORY:
; CALLING SEQUENCE:
;       wavelength_to_hue, wav, hue, sat
; INPUTS:
;       wav = wavelength in Angstroms.      in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       hue = returned hue (0 to 360 deg).  out
;       sat = returned saturation (0-1).    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jan 20
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro wavelength_to_hue, wav0, hue, sat, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert an array of wavelengths to hues.'
	  print,' wavelength_to_hue, wav, hue, sat'
	  print,'  wav = wavelength in Angstroms.      in'
	  print,'  hue = returned hue (0 to 360 deg).  out'
	  print,'  sat = returned saturation (0-1).    out'
	  return
	endif
 
	;--------  Hue  --------------
	wav_min = 4100.			; Min hue wavelength.
	wav_max = 6700.			; Max hue wavelength.
	wav = wav0>wav_min<wav_max	; Keep within hue range.
	w1 = where(wav lt 4900., c1)	; Blue end.
	w2 = where(wav ge 4900., c2)	; Red end.
	hue = wav*0.			; Output array.
	if c1 gt 0 then begin		; Do blue end if any points.
	  wv = wav(w1)
	  hue(w1) = -2221. + 1.225*wv - 1.5E-4*wv^2
	endif
	if c2 gt 0 then begin		; Do red end if any points.
	  wv = wav(w2)
	  hue(w2) = 2466. - 0.7366*wv + 5.5029E-5*wv^2
	endif
 
	;--------  Sat  --------------
	uv_cutoff = 4000.		; Vis limit for UV.
	ir_cutoff = 7100.		; Vis limit for IR.
	uv_trans = 100			; Transition size.
	uvhi = uv_cutoff
	uvlo = uv_cutoff - uv_trans
	ir_trans = 400			; Transition size.
	irhi = ir_cutoff + ir_trans
	irlo = ir_cutoff
	n = n_elements(wav)
	sat = wav*0.+1.
	;-------  Deal with UV  -----------------
	w = where(wav0 lt uvhi, c)	; Transition sat from 0.3 to 1
	if c gt 0 then begin		; Have some UV.
	  sat(w) = (0.3+0.7*(wav0(w)-uvlo)/(uvhi-uvlo))>0.3
	endif
	;-------  Deal with IR  -----------------
	w = where(wav0 gt irlo, c)	; Transition sat from 1 to 0.3
	if c gt 0 then begin		; Have some IR.
	  sat(w) = (1.0-0.7*(wav0(w)-irlo)/(irhi-irlo))>0.3
	endif
 
	end
