function DEADCORR, Mode, Cts, OTAU=Otau, ONC=ONc, EXTENDED=Extended
;+
; NAME:
;        DEADCORR
;
; PURPOSE:
;        This function corrects for dead time in the HEAO A-1 detector.
;        The dead time and collimator response function were fitted for
;        using the data on the Crab from module 3 ONLY.
;
; CATEGORY:
;        HEAO A-1 Scanning.
;
; CALLING SEQUENCE:
;
;        Result = DEADCORR( Mode, Cts )
;
; INPUTS:
;        Mode:     Scanning timing mode in MILLISECONDS (320 ms or 5 ms).
;
;        Cts:      Array of HEAO A-1 counts, UNCORRECTED for dead time.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        EXTENDED: Set this keyword to specify extended or paralyzable
;                  dead time corrections.  Otherwise, NON-extended or
;                  NON-paralyzable dead time corrections will be made, namely,
;                  (0=Default).
;
; OUTPUTS:
;        An array of counts, CORRECTED for dead time is returned.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        OTAU:     Dead time used to correct the data in MICROSECONDS.
;
;        ONC:      Charged particle rate assumed in COUNTS/mode.
;
; COMMON BLOCKS:
;        DEADCORR:   Dead times and charged particle rates used by this
;             routine. See DEADINIT.
;
; RESTRICTIONS:
;        The dead time used in this routine (14.4 microsec, NON-extended)
;        has been determined by studying ONLY collimator module 3 data on
;        the Crab.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, 10-3-94.
;-
         common DEADCORR, ne_dt, e_dt

         if n_elements( ne_dt ) eq 0 then DEADINIT

         No        = Cts

         if NOT keyword_set( EXTENDED ) then begin    ;Non-extended dead time

                   Otau      = ne_dt.tau              ;dead time [microsec]
                   ONc       = ne_dt.nc               ;charged particle rate
                   tau_norm  = (Otau/Mode)*1.E-3

                   N         = No/( 1.-No*tau_norm )
                   N         = N*( 1.+ONc*tau_norm )  ;correction for effective
                                                      ;dead time due to charged
                                                      ;particles
                   return,N

         endif else begin                             ;Extended dead time

                   Otau      = e_dt.tau               ;dead time [microsec]
                   ONc       = e_dt.nc                ;charged particle rate
                   tau_norm  = (Otau/Mode)*1.E-3

                   coeff     = e_dt.coeff
                   lny_cut   = e_dt.lny_cut

                   y         = No * tau_norm * exp( ONc*tau_norm )
                   here_ne0  = where( y ne 0, ne0 )
                   nbin      = n_elements( y )
                   x         = fltarr( nbin )

                   x_ne0     = fltarr( ne0 )
                   y_ne0     = y( here_ne0 )
                   lny_ne0   = alog(y_ne0)

                   here_lt   = WHERE( lny_ne0 lt lny_cut, nlt )
                   if nlt gt 0 then begin
                        lny1 = lny_ne0( here_lt )
                        lnx1 = POLY( lny1, coeff(*,0) )
                        x_ne0( here_lt ) = exp( lnx1 )
                   endif

                   here_ge   = WHERE( lny_ne0 ge lny_cut, nge )
                   if nge gt 0 then begin
                        lny2 = lny_ne0( here_ge )
                        lnx2 = POLY( lny2, coeff(*,1) )
                        x_ne0( here_ge ) = exp( lnx2 )
                   endif

                   x( here_ne0 )  = x_ne0
                   N              = x/tau_norm

                   return,N
         endelse

end
