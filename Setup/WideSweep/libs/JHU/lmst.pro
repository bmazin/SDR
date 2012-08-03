;-------------------------------------------------------------
;+
; NAME:
;       LMST
; PURPOSE:
;       Give local mean sidereal time.
; CATEGORY:
; CALLING SEQUENCE:
;       st = lmst( jd, ut, long)
; INPUTS:
;       jd = Julian Day (starting at noon).         in
;       ut = Universal time as fraction of day.     in
;       long = observer longitude (deg, East is +). in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       st = sidereal time as fraction of day.      out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  16 Sep, 1986.
;       R. Sterner, 15 Jan, 1991 --- converted to V2.
;       R. Sterner, 2000 Jul 28 --- Fixed date error in comment.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION LMST, JD, UT, LNG, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Give local mean sidereal time.'
	  print,' st = lmst( jd, ut, long)'
	  print,'   jd = Julian Day (starting at noon).         in'
	  print,'   ut = Universal time as fraction of day.     in'
	  print,'   long = observer longitude (deg, East is +). in'
	  print,'   st = sidereal time as fraction of day.      out'
	  return, -1
	endif
 
	SOL2SID = 1.0027379093D0	; solar to sidereal rate.
	T0 = 6D0/24. + 38D0/1440. + 45.836D0/86400.	; 0 pt sidereal time.
 
	DLONG = -LNG/360.D0	; time diff from Greenwich.
	TDAYS = JD - 2415020.5	; days since 1899 Dec 31 12:00.
	T = T0 + (SOL2SID - 1.0)*TDAYS + SOL2SID*UT - DLONG
	RETURN, T - FLOOR(T)	; only want fraction.
	END
