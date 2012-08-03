pro DEADINIT
;+
; NAME:
;        DEADINIT
;
; PURPOSE:
;        This procedures defines the dead times and charged particle rates
;        used to correct HEAO A-1 scanning counts for dead time.
;
; CATEGORY:
;        HEAO A-1 Scanning.
;
; CALLING SEQUENCE:
;
;        DEADINIT
;
; COMMON BLOCKS:
;        DEADCORR:   Dead times and charged particle rates defined here.
;
; RESTRICTIONS:
;        The dead time used in this routine (14.4 microsec, NON-extended)
;        has been determined by studying ONLY collimator module 3 data on
;        the Crab.
;
; PROCEDURE:
;        This routine is automatically called by DEADCORR.  The USER does
;        not have to call this routine.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, 10-3-94.
;-

         common DEADCORR, ne_dt, e_dt

;   Nonextended Dead Time parameters

         ne_dt     = {$
                        tau  : 14.4,  $     ;dead time, [microseconds]
                        nc   : 0.0    $     ;charge particle rate, [cts/mode]
                     }

;   Extended Dead Time parameters

         ncoeff    = 6
         e_dt      = {$
                        tau       : 13.7,   $
                        nc        : 0.0,    $
                        ncoeff    : ncoeff, $
                        coeff     : fltarr(ncoeff,2),$
                        lny_cut   : -1.8    $
                     }

         e_dt.coeff(*,0) = [ $
                                   1.4343165, $
                                   2.3887712, $
                                 0.567399399, $
                                 0.118858299, $
                                0.0125219624, $
                              0.000524497699  $
                            ]

         e_dt.coeff(*,1) = [ $
                                   390.55156, $
                                   1428.8798, $
                                   2079.4404, $
                                   1504.3581, $
                                   540.19533, $
                                   77.002005  $
                            ]

end
