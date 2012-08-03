;-------------------------------------------------------------
;+
; NAME:
;       ELL_LATCON
; PURPOSE:
;       Convert between latitude types.
; CATEGORY:
; CALLING SEQUENCE:
;       ell_latcon, lat1, lat2
; INPUTS:
;       lat1 = Input latitude.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /G2P = PlanetoGraphic to Parametric     latitude.
;         /G2C = PlanetoGraphic to PlanetoCentric latitude.
;         /P2G = Parametric     to PlanetoGraphic latitude.
;         /P2C = Parametric     to PlanetoCentric latitude.
;         /C2G = PlanetoCentric to PlanetoGraphic latitude.
;         /C2P = PlanetoCentric to Parametric     latitude.
;         SET=ell_name  Set working ellipsoid by giving name.
; OUTPUTS:
;       lat2 = Output latitude. out
; COMMON BLOCKS:
; NOTES:
;       Notes: lat1 may be a scalar or array.
;         Set current working ellipsesoid using
;         ellipsoid,SET=name (to find name do ellipsoid,/all).
; MODIFICATION HISTORY:
;       R. Sterner, 2007 Mar 27
;       R. Sterner, 2007 Aug 05 --- Added missing set keyword.
;
; Copyright (C) 2007, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro ell_latcon, lat1, lat2, help=hlp, set=set, $
	  g2p=g2p, g2c=g2c, p2g=p2g, p2c=p2c, c2g=c2g, c2p=c2p
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert between latitude types.'
	  print,' ell_latcon, lat1, lat2'
	  print,'   lat1 = Input latitude.  in'
	  print,'   lat2 = Output latitude. out'
	  print,' Keywords:'
	  print,'   /G2P = PlanetoGraphic to Parametric     latitude.'
	  print,'   /G2C = PlanetoGraphic to PlanetoCentric latitude.'
	  print,'   /P2G = Parametric     to PlanetoGraphic latitude.'
	  print,'   /P2C = Parametric     to PlanetoCentric latitude.'
	  print,'   /C2G = PlanetoCentric to PlanetoGraphic latitude.'
	  print,'   /C2P = PlanetoCentric to Parametric     latitude.'
	  print,'   SET=ell_name  Set working ellipsoid by giving name.'
	  print,' Notes: lat1 may be a scalar or array.'
	  print,'   Set current working ellipsesoid using'
	  print,'   ellipsoid,SET=name (to find name do ellipsoid,/all).'
	  return
	endif
 
	;--------------------------------------------------------
	;  Get ellipsoid (set first if requested)
	;--------------------------------------------------------
	ellipsoid, set=set, get=ell	; Get ellipsoid structure (set first).
	a = ell.a			; Semimajor axis (m).
	f = 1.D0/ell.f1			; Flattening factor.
	b = a*(1-f)			; Semiminor axis (m).
 
 
	;--------------------------------------------------------
	;  /C2P = PlanetoCentric to Parametric     latitude.
	;  latC -> latP:  factor a/b
	;--------------------------------------------------------
	if keyword_set(c2p) then begin
	  lat2 = atan((a/b)*tan(lat1/!radeg))*!radeg
	endif
 
	;--------------------------------------------------------
	;  /P2G = Parametric     to PlanetoGraphic latitude.
	;  latP -> latG:  factor a/b
	;--------------------------------------------------------
	if keyword_set(p2g) then begin
	  lat2 = atan((a/b)*tan(lat1/!radeg))*!radeg
	endif
 
	;--------------------------------------------------------
	;  /C2G = PlanetoCentric to PlanetoGraphic latitude.
	;  latC -> latG:  factor (a/b)^2
	;--------------------------------------------------------
	if keyword_set(c2g) then begin
	  lat2 = atan((a/b)^2*tan(lat1/!radeg))*!radeg
	endif
 
 
	;--------------------------------------------------------
	;  /G2P = PlanetoGraphic to Parametric     latitude.
	;  latG -> latP:  factor b/a
	;--------------------------------------------------------
	if keyword_set(g2p) then begin
	  lat2 = atan((b/a)*tan(lat1/!radeg))*!radeg
	endif
 
	;--------------------------------------------------------
	;  /P2C = Parametric     to PlanetoCentric latitude.
	;  latP -> latC:  factor b/a
	;--------------------------------------------------------
	if keyword_set(p2c) then begin
	  lat2 = atan((b/a)*tan(lat1/!radeg))*!radeg
	endif
 
	;--------------------------------------------------------
	;  /G2C = PlanetoGraphic to PlanetoCentric latitude.
	;  latG -> latC:  factor (b/a)^2
	;--------------------------------------------------------
	if keyword_set(g2c) then begin
	  lat2 = atan((b/a)^2*tan(lat1/!radeg))*!radeg
	endif
 
 
	end
