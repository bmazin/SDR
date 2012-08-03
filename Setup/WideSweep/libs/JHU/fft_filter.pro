;-------------------------------------------------------------
;+
; NAME:
;       FFT_FILTER
; PURPOSE:
;       Do FFT filtering of time series data.
; CATEGORY:
; CALLING SEQUENCE:
;       FILTER_DATA = FFT_FILTER(DATA, FILTER_WEIGHTS)
; INPUTS:
;       data = input data array.              in
;       filter_weights = weighting array.     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       fitler_data = filtered output.        out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       B. L. Gotwols.  7 Apr, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1987, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function fft_filter,data,filterwts, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Do FFT filtering of time series data.
	  print,' FILTER_DATA = FFT_FILTER(DATA, FILTER_WEIGHTS)
	  print,'   data = input data array.              in'
	  print,'   filter_weights = weighting array.     in'
	  print,'   fitler_data = filtered output.        out'
	  return, -1
	endif
 
	return,fft(fft(data,-1)*filterwts,1)
	end
