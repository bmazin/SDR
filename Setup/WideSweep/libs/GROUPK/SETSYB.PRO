;+
; NAME:
;        SETSYB
; PURPOSE:
;        Set SYSTEM B parameters.
;
; CALLING SEQUENCE:
;        SETSYB, AI, BI, AO, BO
;
; INPUTS:
;        AI - Longitude of Z-axis in RADIANS, scalar or vector.
;        BI - Latitude of Z-axis in RADIANS
;        AO - Longitude of X-axis in RADIANS
;        BO - Latitude of X-axis in RADIANS
;
; OUTPUTS:
;        Sets the SYSTEM B data common.
;
; REVISION HISTORY:
;        Adapted from Fortran by Daryl Yentis NRL
;        22-JUN-1994:   H.C. Wen, adapted into IDL routine.
;        15-AUG-1995    Comment bugfix: removed extraneous ;+ and ;-.
;-
pro SETSYB, AI,BI,AO,BO
;
;  New coordinate systems: call as SETSYB,ALONGZ,ALATZ,ALONGX,ALATX
;
      common SYAB_DATA, SY_psi, SY_phi, SY_stheta, SY_ctheta

      n = N_ELEMENTS( AI )
      SY_psi       = fltarr(2,n)    & SY_phi       = fltarr(2,n)
      SY_stheta    = fltarr(2,n)    & SY_ctheta    = fltarr(2,n)

      A = SIN(BO)
      B = (COS(BO) * COS(BI)) * SIN(AO - AI)

      SY_psi(0,*) = - ATAN(A,B)
      SY_phi(1,*) = SY_psi(0,*)
      theta = !dpi/2.0d - BI
      SY_stheta(0,*) = sin(theta)
      SY_stheta(1,*) = - SY_stheta(0,*)
      SY_ctheta(0,*) = cos(theta)
      SY_ctheta(1,*) = SY_ctheta(0,*)
      SY_phi(0,*) = AI - 1.50d*!dpi
      SY_psi(1,*) = SY_phi(0,*)

end
