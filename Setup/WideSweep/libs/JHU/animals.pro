;-------------------------------------------------------------
;+
; NAME:
;       ANIMALS
; PURPOSE:
;       Return a string array of animals.
; CATEGORY:
; CALLING SEQUENCE:
;       a = animals()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       a = string array of animals.   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 24 Jul, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function animals, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Return a string array of animals.'
	  print,' a = animals()'
	  print,'   a = string array of animals.   out'
	  return, ''
	endif
 
	a = ['Cat','Dog','Cow','Bat','Bug','Fox','Rat','Bee',$
	     'Fish','Bird','Goat',$
	     'Sheep','Horse','Worm','Wolf','Skunk','Squirrel',$
	     'Rabbit','Mouse','Whale']
 
	return, a
	end
