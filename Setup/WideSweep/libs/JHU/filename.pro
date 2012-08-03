;-------------------------------------------------------------
;+
; NAME:
;       FILENAME
; PURPOSE:
;       File names with system independent symbolic directories.
; CATEGORY:
; CALLING SEQUENCE:
;       f = filename(symdir, name)
; INPUTS:
;       symdir = symbolic directory name.   in
;       name = file name.                   in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NOSYM means directory given is not a symbolic name.
;         OPSYS=os specifiy operating system to over-ride
;           actual.  Use VMS, WINDOWS, or MACOS.  UNIX is default.
;         DELIM=c delimiter character between directory and
;           file name.  This is returned.
; OUTPUTS:
;       f = file name including directory.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: symdir is a logical name for VMS and
;         an environmental variable for UNIX and WINDOWS.  Ex:
;         DEFINE IDL_IDLUSR d0:[publib.idl]  for VMS
;         set IDL_IDLUSR=c:\IDL\LIB\IDLUSR   for WINDOWS.
;         setenv IDL_IDLUSR /usr/pub/idl     for UNIX.
;         Then in IDL: f=filename('IDL_IDLUSR','tmp.tmp')
;         will be the name of the file tmp.tmp in IDL_IDLUSR.
; MODIFICATION HISTORY:
;       R. Sterner,  4 Feb, 1991
;       R. Sterner, 27 Mar, 1991 --- added /NOSYM
;       R. Sterner, 21 May, 1991 --- If not a listed opsys assume unix.
;       R. Sterner,  4 Jun, 1991 --- added DOS.
;       R. Sterner,  2 Jul, 1991 --- added DELIM.
;       R. Sterner, 17 Jan, 1992 --- added OPSYS= and avoided double //
;       R. Sterner, 1994 Feb 7 --- Added MacOS.
;       R. Sterner, 1994 Feb 14 --- Changed DOS to windows.
;       R. Sterner, 1998 Jan 16 --- Changed from !version.os to os_family.
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function filename, symdir, name, help=hlp, nosym=nosym, $
	  opsys=opsys, delim=chr
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' File names with system independent symbolic directories.'
	  print,' f = filename(symdir, name)'
	  print,'   symdir = symbolic directory name.   in'
	  print,'   name = file name.                   in'
	  print,'   f = file name including directory.  out'
	  print,' Keywords:'
	  print,'   /NOSYM means directory given is not a symbolic name.'
	  print,'   OPSYS=os specifiy operating system to over-ride'
	  print,'     actual.  Use VMS, WINDOWS, or MACOS.  UNIX is default.'
	  print,'   DELIM=c delimiter character between directory and'
	  print,'     file name.  This is returned.'
	  print,' Notes: symdir is a logical name for VMS and'
	  print,'   an environmental variable for UNIX and WINDOWS.  Ex:'
	  print,'   DEFINE IDL_IDLUSR d0:[publib.idl]  for VMS'
	  print,'   set IDL_IDLUSR=c:\IDL\LIB\IDLUSR   for WINDOWS.'
	  print,'   setenv IDL_IDLUSR /usr/pub/idl     for UNIX.'
	  print,"   Then in IDL: f=filename('IDL_IDLUSR','tmp.tmp')"
	  print,'   will be the name of the file tmp.tmp in IDL_IDLUSR.'
	  return, -1
	endif
 
	if n_elements(opsys) eq 0 then opsys = !version.os_family
 
	case strupcase(opsys) of
'VMS':	   begin
	     t = name
	     chr = ']'
	     if symdir ne '' then begin
	       if not keyword_set(nosym) then begin
                 t = ':'+t
	         chr = ':'
	       endif
	       t = symdir + t
	     endif 
	     return, t
	   end
'WINDOWS': begin
	     t = name
	     if symdir ne '' then begin			; Have directory name.
	       if not keyword_set(nosym) then begin	; Is symbolic.
		 t = getenv(symdir)+'\'+t
	       endif else begin				; Is actual.
		 if strmid(symdir,strlen(symdir)-1,1) eq '\' then begin
		   t = symdir + t
		 endif else begin
	           t = symdir + '\' + t
		 endelse
	       endelse
	     endif 
	     chr = '\'
	     return, t
	   end
'MACOS':   begin
	     t = name
	     if symdir ne '' then begin			; Have directory name.
	       if not keyword_set(nosym) then begin	; Is symbolic.
		 t = getenv(symdir)+':'+t
	       endif else begin				; Is actual.
		 if strmid(symdir,strlen(symdir)-1,1) eq ':' then begin
		   t = symdir + t
		 endif else begin
	           t = symdir + ':' + t
		 endelse
	       endelse
	     endif 
	     chr = ':'
	     return, t
	   end
else:	   begin	; Assume UNIX.
	    t = name
	    if symdir ne '' then begin
	      if strmid(symdir,strlen(symdir)-1,1) eq '/' then begin
	        t = symdir + name
	      endif else begin
	        t = symdir + '/' + name
	      endelse
	      if not keyword_set(nosym) then t = '$'+t
	    endif
	    chr = '/'
	    return, t
	   end
	endcase
 
	end
