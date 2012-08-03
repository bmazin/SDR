;-------------------------------------------------------------
;+
; NAME:
;       FIX_RESLIB
; PURPOSE:
;       Modify routines in specified RES IDL library.
; CATEGORY:
; CALLING SEQUENCE:
;       fix_reslib
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         DIR=dir Directory to process (def=current).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: run this routine in a temporary directory to create
;         a directory of modified routines.  This routine will modify
;         the lines of dashes in the documentation template in RES
;         IDL library routines to change from ;----... to ; ----...
; MODIFICATION HISTORY:
;       R. Sterner, 2004 Jan 08
;
; Copyright (C) 2004, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro fix_reslib, dir=dir, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Modify routines in specified RES IDL library.'
 	  print,' fix_reslib'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   DIR=dir Directory to process (def=current).'
	  print,' Note: run this routine in a temporary directory to create'
	  print,'   a directory of modified routines.  This routine will modify'
	  print,'   the lines of dashes in the documentation template in RES'
	  print,'   IDL library routines to change from ;----... to ; ----...'
	  return
	endif
 
	;-------  Defaults  ---------------------
	if n_elements(dir) eq 0 then cd,curr=dir
 
	;-------  Find all IDL routines  --------
	wild = filename(dir,'*.pro',/nosym)
	f = file_search(wild,count=fcnt)
	if fcnt eq 0 then begin
	  print,' Error in fix_reslib: No files found in '+dir
	  return
	endif
 
	;-------  Loop through all routines and extract purpose  ------
	print,' Processing '+strtrim(fcnt,2)+' files ...'
	for i=0, fcnt-1 do begin
	  filebreak,f(i),nvfile=nam			; Name of routine.
	  print,' '+nam
	  t = getfile(f(i))				; Read in routine code.
	  in = where(strmid(t,0,2) eq ';+',c)
	  if c eq 0 then begin				; Not found.
	    print,' Error in fix_reslib: could not find ;+.'
	    print,'   Ignored.'
	    continue
	  endif
	  lo = in(0)-1		; Expected index of first line of dashes.
	  if not (strmid(t(lo),0,10) eq ';---------') then begin
	    print,'  Error in fix_reslib: did not find expected line of dashes.'
	    print,'   Ignored.'
	    continue
	  endif
	  t(lo) = '; '+strmid(t(lo),2,999)
	  putfile,nam,t
	endfor
 
	end
