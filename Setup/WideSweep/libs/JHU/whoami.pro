;-------------------------------------------------------------
;+
; NAME:
;       WHOAMI
; PURPOSE:
;       Returns to the calling routine its directory and name.
; CATEGORY:
; CALLING SEQUENCE:
;       whoami, dir, file
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         LINE=n  Line number just after where whoami was called.
; OUTPUTS:
;       dir = Source directory of calling routine.   out
;       file = name of calling routine.              out
; COMMON BLOCKS:
; NOTES:
;       Notes: It can be useful for a routine to know
;         what directory it is located in.  This allows
;         it to reference auxiliary files in the same
;         directory without needed any special environmental
;         variables defined.  The file name returned here is
;         less important since it could always be hardwired
;         into the calling routine itself, but this technique
;         allows this to be avoided for more reusable code.
; MODIFICATION HISTORY:
;       R. Sterner, 1995 May 11
;
; Copyright (C) 1995, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro whoami, dir, file, line=line, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Returns to the calling routine its directory and name.'
	  print,' whoami, dir, file'
	  print,'   dir = Source directory of calling routine.   out'
	  print,'   file = name of calling routine.              out'
	  print,' Keywords:'
	  print,'   LINE=n  Line number just after where whoami was called.'
	  print,' Notes: It can be useful for a routine to know'
	  print,'   what directory it is located in.  This allows'
	  print,'   it to reference auxiliary files in the same'
	  print,'   directory without needed any special environmental'
	  print,'   variables defined.  The file name returned here is'
	  print,'   less important since it could always be hardwired'
	  print,'   into the calling routine itself, but this technique'
	  print,'   allows this to be avoided for more reusable code.'
	  return
	endif
 
	help,calls=cc		; Get list of all calls.
 
	is = cc(1)
	t = getwrd(is,delim='<',1)
	f = getwrd(t,delim='(')
	line = getwrd('',1)+0
 
	filebreak, f, dir=dir, nvfile=file
 
	return
	end
