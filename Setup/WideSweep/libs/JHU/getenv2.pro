;-------------------------------------------------------------
;+
; NAME:
;       GETENV2
; PURPOSE:
;       Version of getenv portable across operating systems.
; CATEGORY:
; CALLING SEQUENCE:
;       val = getenv(var)
; INPUTS:
;       var = Name of environmental variable.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         LIST=v  1 means list source, else 0 (default).
;           Remembers last setting during session.
; OUTPUTS:
;       val = Returned value of requested variable.  out
;             Null string if variable not found.
; COMMON BLOCKS:
;       getenv2_com
; NOTES:
;       Notes: The requested variable may either be an actual
;       environmental variable, or the contents of a file with
;       that name located in !base_dir.  The second case is portable
;       across operating systems.  Just define !base_dir in your
;       IDL startup file to point to some directory.  Example:
;         defsysv, '!base_dir', '/homes/sterner/idl/base_dir', 1
;       The value from !base_dir takes precedence.
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Mar 18
;       R. Sterner, 1998 May 18 --- fixed to work if !base_dir not defined.
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function getenv2, var, list=list, help=hlp
 
	common getenv2_com, flag
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Version of getenv portable across operating systems.'
	  print,' val = getenv(var)'
	  print,'   var = Name of environmental variable.        in'
	  print,'   val = Returned value of requested variable.  out'
	  print,'         Null string if variable not found.'
	  print,' Keywords:'
	  print,'   LIST=v  1 means list source, else 0 (default).'
	  print,'     Remembers last setting during session.'
	  print,' Notes: The requested variable may either be an actual'
	  print,' environmental variable, or the contents of a file with'
	  print,' that name located in !base_dir.  The second case is portable'
	  print,' across operating systems.  Just define !base_dir in your'
	  print,' IDL startup file to point to some directory.  Example:'
	  print,"   defsysv, '!base_dir', '/homes/sterner/idl/base_dir', 1"
	  print,' The value from !base_dir takes precedence.'
	  return,''
	endif
 
	if n_elements(flag) eq 0 then flag=0	; Don't list source.
	if n_elements(list) ne 0 then flag=list	; Set or clear list flag.
 
	;-------  Try to read value from !base_dir file  --------------
	defsysv, '!base_dir', exists=ex		; Base directory defined?
	if ex eq 1 then begin
	  ;-----  Get name of file that has requested value  --------
	  ;-----  Must use execute so getenv2 will compile   --------
	  tmp = execute('name=filename(!base_dir,var,/nosym)')
	  a = getfile(name,err=err,/quiet)	; Try to read file.
	  if err eq 0 then begin		; Got it.
	    if flag eq 1 then print,var+' from file '+name
	    return, a(0)
	  endif
	endif	
 
	;------  No value yet, try environmental variable  ---------
	val = getenv(var)
	if flag eq 1 then begin
	  if val ne '' then print,var+' from environmental variable'
	  if val eq '' then print,' No value found for '+var
	endif
	return,val
 
	end
