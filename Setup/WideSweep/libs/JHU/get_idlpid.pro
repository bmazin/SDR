;-------------------------------------------------------------
;+
; NAME:
;       GET_IDLPID
; PURPOSE:
;       Get Process ID of IDL current IDL session (Unix only).
; CATEGORY:
; CALLING SEQUENCE:
;       pid = get_idlpid()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       pid = returned Process ID of the current IDL session.  out
; COMMON BLOCKS:
; NOTES:
;       Note: The Process ID (PID) of the calling session of IDL is
;         returned as a string.  This can be useful to create
;         unique file names for example.  Returns a null string
;         for non-unix operating systems.  As a check try
;         idl> spawn,"pidof idl" which will list the PIDs of all
;         IDL sessions currently running on the system (unix only).
; MODIFICATION HISTORY:
;       R. Sterner, 2005 Jan 05
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function get_idlpid, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Get Process ID of IDL current IDL session (Unix only).'
	  print,' pid = get_idlpid()'
	  print,'   pid = returned Process ID of the current IDL session.  out'
	  print,' Note: The Process ID (PID) of the calling session of IDL is'
	  print,'   returned as a string.  This can be useful to create'
	  print,'   unique file names for example.  Returns a null string'
	  print,'   for non-unix operating systems.  As a check try'
	  print,'   idl> spawn,"pidof idl" which will list the PIDs of all'
	  print,'   IDL sessions currently running on the system (unix only).'
	  return,''
	endif
 
	if !version.os_family ne 'unix' then return,''
	spawn,'echo $PPID',/sh,pid
	return, pid(0)
	end
