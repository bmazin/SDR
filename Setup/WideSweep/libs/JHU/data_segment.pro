;-------------------------------------------------------------
;+
; NAME:
;       DATA_SEGMENT
; PURPOSE:
;       Compute indices of data segments in an array.
; CATEGORY:
; CALLING SEQUENCE:
;       data_segment, tlen, slen, [off]
; INPUTS:
;       tlen = total number of elements in array.         in
;       slen = number of elements in a full segment.      in
;       off = optional offset into array for 1st segment. in
;         (default = 0).
; KEYWORD PARAMETERS:
;       Keywords:
;         OUT=s Returned structure with follow items:
;           n = number of full segments.
;           ind = array of n indices of full segments.
;           irem = index of remaining segment.
;           lrem = # elements in remaining segment (0 if none).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: This routine gives info useful for accessing an
;       array in segments.  Starting at index off (def=0) read
;       in slen elements and repeat n times.  A remaining smaller
;       segment of lrem elements starting at irem may remain.
;       May also use the indices of each segment from ind to go
;       directly to that segment and read in slen elements.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Jul 28
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro data_segment, tlen, slen, off, out=s, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Compute indices of data segments in an array.'
	  print,' data_segment, tlen, slen, [off]'
	  print,'   tlen = total number of elements in array.         in'
	  print,'   slen = number of elements in a full segment.      in'
	  print,'   off = optional offset into array for 1st segment. in'
	  print,'     (default = 0).'
	  print,' Keywords:'
	  print,'   OUT=s Returned structure with follow items:'
	  print,'     n = number of full segments.'
	  print,'     ind = array of n indices of full segments.'
	  print,'     irem = index of remaining segment.'
	  print,'     lrem = # elements in remaining segment (0 if none).'
	  print,' Notes: This routine gives info useful for accessing an'
	  print,' array in segments.  Starting at index off (def=0) read'
	  print,' in slen elements and repeat n times.  A remaining smaller'
	  print,' segment of lrem elements starting at irem may remain.'
	  print,' May also use the indices of each segment from ind to go'
	  print,' directly to that segment and read in slen elements.'
	  return
	endif
 
	if n_elements(off) eq 0 then off=0LL	; Default offset (start index).
 
	n = long64((long64(tlen) - off)/slen)	; Number of full segments.
	irem = n*slen+off			; Start index of remainder.
	lrem = tlen - irem			; # of elements in remainder.
	ind = indgen(n,/l64)*slen+off		; Full segment indices.
 
	s = {tlen:tlen, slen:slen, off:off, n:n, ind:ind, irem:irem, lrem:lrem}
 
	end
