;-------------------------------------------------------------
;+
; NAME:
;       RESHDR_TO_FILE
; PURPOSE:
;       Write a RES file header to a text file.
; CATEGORY:
; CALLING SEQUENCE:
;       reshdr_to_file, resfile, txtfile
; INPUTS:
;       resfile = name of RES file.  in
;       txtfile = name of text file. in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err error flag: 0=ok.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Header from specified RES file is written to the
;       specified file.
;       See also reshdr_from_file for inverse operation.
; MODIFICATION HISTORY:
;       R.Sterner, 2003 Aug 20
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro reshdr_to_file, resfile, txtfile, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Write a RES file header to a text file.'
	  print,' reshdr_to_file, resfile, txtfile'
	  print,'   resfile = name of RES file.  in'
	  print,'   txtfile = name of text file. in'
	  print,' Keywords:'
	  print,'   ERROR=err error flag: 0=ok.'
	  print,' Notes: Header from specified RES file is written to the'
	  print,' specified file.'
	  print,' See also reshdr_from_file for inverse operation.'
	  return
	endif
 
	resopen,resfile,err=err,header=h
	if err ne 0 then return
 
	putfile,txtfile,h,err=err
 
	end
