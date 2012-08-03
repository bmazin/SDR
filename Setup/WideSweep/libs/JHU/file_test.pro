;-------------------------------------------------------------
;+
; NAME:
;       FILE_TEST
; PURPOSE:
;       Test if file readable &, optionally, has specified contents.
; CATEGORY:
; CALLING SEQUENCE:
;       flag = file_test(file)
; INPUTS:
;       file = name of file to check.         in
; KEYWORD PARAMETERS:
;       Keywords:
;         CONTENTS=txt  contents of file (text file).  Must
;           match what's in file or file_test returns 0.
; OUTPUTS:
;       flag = test result, 1=true, 0=false.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: Useful for testing status type files.  Example:
;         if file_test('last.tmp',contents='number 3') then begin
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Sep 26
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function file_test, file, contents=cnt, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Test if file readable &, optionally, has specified contents.'
	  print,' flag = file_test(file)'
	  print,'   file = name of file to check.         in'
	  print,'   flag = test result, 1=true, 0=false.  out'
	  print,' Keywords:'
	  print,'   CONTENTS=txt  contents of file (text file).  Must'
	  print,"     match what's in file or file_test returns 0."
	  print,' Notes: Useful for testing status type files.  Example:'
	  print,"   if file_test('last.tmp',contents='number 3') then begin"
	  return,''
	endif
 
	txt = getfile(file,err=err,/q)	; Read file.
	if err ne 0 then return, 0	; Could not read, return false.
	n2 = n_elements(cnt)		; Lines given to check.
	if n2 eq 0 then return, 1	; File was readable, return true.
	n1 = n_elements(txt)		; Lines in file.
	if n1 ne n2 then return, 0	; Contents differ, return false.
	for i=0,n1-1 do begin		; Check line by line.
	  if txt(i) ne cnt(i) then return, 0	; Found diff, return false.
	endfor
	return, 1			; All checked, return true.
 
	end
