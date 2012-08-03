;-------------------------------------------------------------
;+
; NAME:
;       ELLIPSOID
; PURPOSE:
;       Set or get earth ellipsoid structure.
; CATEGORY:
; CALLING SEQUENCE:
;       ellipsoid
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         SET=ell_name  Name of ellipsoid to set as working.
;           Default = WGS 84.
;         GET=ell_str   Return ellipsoid structure.
;         /ALL      List all available ellipsoids.
;         /CURRENT  List currently set ellipsoid.
;         IDL=idl_ell Set an IDL ellipsoid as the working one.
;           idl_ell = [a, e2, k0] where a=semi-major axis in m,
;             e2 = ecc^2, k0=scale on central meridian.
; OUTPUTS:
; COMMON BLOCKS:
;       ellipsoid_com
; NOTES:
;       Note: the ellipsoid structure contains the semimajor
;         axis in meters, the reciprocal of the flattening
;         factor, and the ellipsoid name.
;         This routine is used internally by the ellipsoid
;         ell_* routines.  The working ellipsoid may be set
;         before calling those routines.
; MODIFICATION HISTORY:
;       R. Sterner, 2002 May 01
;       R. Sterner, 2003 Oct 17 --- New keyword IDL=ell to set map_set ellipsd.
;       R. Sterner, 2004 Jan 13 --- Added semiminor axis, b, to /CURR listing.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ellipsoid,set=set,get=get,error=err,all=all,current=curr, $
	  idl=idl, help=hlp
 
	;-----  Common containing ellipsoid structure  -----------
	common ellipsoid_com, ell_str
 
	if keyword_set(hlp) then begin
	  print,' Set or get earth ellipsoid structure.'
	  print,' ellipsoid'
	  print,'   All args are keywords.'
	  print,' Keywords:'
	  print,'   SET=ell_name  Name of ellipsoid to set as working.'
	  print,'     Default = WGS 84.'
	  print,'   GET=ell_str   Return ellipsoid structure.'
	  print,'   /ALL      List all available ellipsoids.'
	  print,'   /CURRENT  List currently set ellipsoid.'
	  print,'   IDL=idl_ell Set an IDL ellipsoid as the working one.'
	  print,'     idl_ell = [a, e2, k0] where a=semi-major axis in m,'
	  print,'       e2 = ecc^2, k0=scale on central meridian.'
	  print,' Note: the ellipsoid structure contains the semimajor'
	  print,'   axis in meters, the reciprocal of the flattening'
	  print,'   factor, and the ellipsoid name.'
	  print,'   This routine is used internally by the ellipsoid'
	  print,'   ell_* routines.  The working ellipsoid may be set'
	  print,'   before calling those routines.'
	  return
	endif
 
	;---  Working ellipsoid defaults to WGS 84  --------------
	if n_elements(ell_str) eq 0 then begin
	  get_ellipsoid, 'WGS 84', ell, err=err
	  if err ne 0 then stop
	  ell_str = ell
	endif
 
	;---  Set requested ellipsoid to be working ellipsoid  ---
	if n_elements(set) ne 0 then begin
	  get_ellipsoid, set, ell, err=err  ; Try to get requested ellipsoid.
	  if err ne 0 then return	    ; If error return.
	  ell_str = ell			    ; Copy to working ellipsoid.
	endif
 
	;---  Set given IDL ellipsoid as working ellipsoid  -----
	if n_elements(idl) gt 0 then begin
	  ee = idl(1)
	  ff = 2/(2-sqrt(4-4*ee))
	  ell_str = {A:idl(0),F1:ff,NAME:'IDL map_set'}
	endif
 
	;---  Return working ellipsoid  ------------
	get = ell_str
 
	;---  List all available ellipsoids  ---------------------
	if keyword_set(all) then get_ellipsoid, /list
 
	;---  List current ellipsoid  ---------------
	if keyword_set(curr) then begin
	  f = 1.D0/ell_str.f1
	  b = ell_str.a*(1-f)
	  print,'  Currently set ellipsoid:'
	  print,'       a            b           1/f          Name'
	  print,ell_str.a,b,ell_str.f1,ell_str.name, $
	    form='(F13.3,F13.3,F16.9,3X,A)'
	endif
 
	end
