;-------------------------------------------------------------
;+
; NAME:
;       READM
; PURPOSE:
;       Unformatted read from a byte array.
; CATEGORY:
; CALLING SEQUENCE:
;       readm, b, a1, ... a9
; INPUTS:
;       b = Byte array with data.              in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       a1, a2, ... = variables to read into.  out
;         Up to 9 variables.
; COMMON BLOCKS:
; NOTES:
;       Note: b need not be a byte array but must contain
;       enough data to fit into requested variables.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Jan 08
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro readm, b, a1, a2, a3, a4, a5, a6, a7, a8, a9, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Unformatted read from a byte array.'
	  print,' readm, b, a1, ... a9'
	  print,'   b = Byte array with data.              in'
	  print,'   a1, a2, ... = variables to read into.  out'
	  print,'     Up to 9 variables.'
	  print,' Note: b need not be a byte array but must contain'
	  print,' enough data to fit into requested variables.'
	  return
	endif
 
	if n_params(0) gt 10 then begin
	  print,' Error in readm: may only read up to 9 variables.'
	  return
	endif
 
	;------  Get a temp file name  ------------
	name0 = '____0.tmp'
	name = name0
	f = file_search(name,count=c)
	if c ne 0 then begin
	  for i=0,4 do begin
	    name = (['a','b','c','d','e'])(i)+name0
	    f = file_search(name,count=c)
	    if c eq 0 then break
	  endfor
	  if c ne 0 then stop,' STOP: Internal error in readm.'
	endif
 
	;------  Write data to file  ---------------
	get_lun, lun
	openw,lun,name,/delete
	writeu,lun,b
	point_lun, lun, 0
 
	;-------  Read data back into variables  -------
	case n_params(0) of
2:	readu,lun,a1
3:	readu,lun,a1,a2
4:	readu,lun,a1,a2,a3
5:	readu,lun,a1,a2,a3,a4
6:	readu,lun,a1,a2,a3,a4,a5
7:	readu,lun,a1,a2,a3,a4,a5,a6
8:	readu,lun,a1,a2,a3,a4,a5,a6,a7
9:	readu,lun,a1,a2,a3,a4,a5,a6,a7,a8
10:	readu,lun,a1,a2,a3,a4,a5,a6,a7,a8,a9
	endcase
 
	free_lun, lun
 
	end
