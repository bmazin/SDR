;-------------------------------------------------------------
;+
; NAME:
;       GETSYSNAMS
; PURPOSE:
;       Get a list from a file specified by an environmental var.
; CATEGORY:
; CALLING SEQUENCE:
;       getsysnams, evar, n, lst1, [lst2, lst3]
; INPUTS:
;       evar = environ var (symbol in VMS) with file name.   in
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err  0=ok, 1=no such environmental variable,
;       2=file not found.
; OUTPUTS:
;       n = number of elements in each list.                 out
;       lst1, lst2, lst3 = output lists.                     out
; COMMON BLOCKS:
; NOTES:
;       Notes: the lines in the file are returned divided into as
;         many output lists as are requested, with the first line
;         in the first list, second in second, ....  File lines
;         starting with * are considered comments and are ignored.
;         This routine is useful for system dependent lists, such
;         as postscript printers or tape drives.
;         As an example for printers let the file contain:
;         *----  Example printers file  --------
;         print/queue=cps_ps
;         Postscript printer # 1 in room A.
;         print/queue=cps_ps2
;         Postscript printer # 2 in room B.
;       
;         To use:
;         (1) Set up a systen environmental variable, like 
;             IDL_PSPRINTERS, with the name of the above file.
;         (2) getsysnams,'idl_psprinters', n, cmds, nams
;             will give: n = 2, cmds = string array of print
;             commands, nams = string array of descriptive names
;             (good for menus).
; MODIFICATION HISTORY:
;       R. Sterner, 22 May, 1990
;       R. Sterner, 26 Feb, 1991 --- Renamed from get_sysnames.pro
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro getsysnams, evar, n, lst1, lst2, lst3,  error=err, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Get a list from a file specified by an environmental var.'
	  print,' getsysnams, evar, n, lst1, [lst2, lst3]'
	  print,'   evar = environ var (symbol in VMS) with file name.   in'
	  print,'   n = number of elements in each list.                 out'
	  print,'   lst1, lst2, lst3 = output lists.                     out'
	  print,' Keywords:'
	  print,'   ERROR=err  0=ok, 1=no such environmental variable,'
	  print,'	2=file not found.'
	  print,' Notes: the lines in the file are returned divided into as'
	  print,'   many output lists as are requested, with the first line'
	  print,'   in the first list, second in second, ....  File lines'
	  print,'   starting with * are considered comments and are ignored.'
	  print,'   This routine is useful for system dependent lists, such'
	  print,'   as postscript printers or tape drives.'
	  print,'   As an example for printers let the file contain:'
	  print,'   *----  Example printers file  --------'
	  print,'   print/queue=cps_ps'
	  print,'   Postscript printer # 1 in room A.'
	  print,'   print/queue=cps_ps2'
	  print,'   Postscript printer # 2 in room B.'
	  print,' '
	  print,'   To use:'
	  print,'   (1) Set up a systen environmental variable, like 
	  print,'       IDL_PSPRINTERS, with the name of the above file.'
	  print,"   (2) getsysnams,'idl_psprinters', n, cmds, nams"
	  print,'       will give: n = 2, cmds = string array of print'
	  print,'       commands, nams = string array of descriptive names'
	  print,'       (good for menus).'
	  return
	endif
 
	f = getenv(evar)
	if f eq '' then begin
	  print,' Error in getsysnams: no such environmental variable - '+$
	    evar
	  err = 1
	  return
	endif
 
	on_ioerror, ioerr
	openr, lun, f, /get_lun
	np = n_params(0)
	nx = np - 2
	txt0 = strarr(nx)
	n = 0
loop:	txt = strarr(nx)
	for i = 0, nx-1 do begin
	  t = nextitem(lun, in)
	  txt(i) = in
	endfor
	if in ne '' then begin
	  n = n + 1
	  txt0 = [[txt0],[txt]]
	  goto, loop
	endif
	txt0 = txt0(*,1:*)
	lst1 = (txt0(0,*))(0:*)
	if nx gt 1 then lst2 = (txt0(1,*))(0:*)
	if nx gt 2 then lst3 = (txt0(2,*))(0:*)
	err = 0
	free_lun, lun
	return
 
ioerr:	on_ioerror, null
	print,' Error in getsysnams: file not opened - '+f
	err = 2
	return
 
	end
