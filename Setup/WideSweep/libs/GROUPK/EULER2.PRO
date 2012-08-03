;+
; NAME:
;        EULER2
; PURPOSE:
;        Transform between galactic, celestial, and ecliptic coordinates.
;        Use the procedure ASTRO to use this routine interactively
;
; CALLING SEQUENCE:
;        EULER, AI, BI, AO, BO, [ SELECT ]
;
; INPUTS:
;        AI - Input Longitude in RADIANS, scalar or vector.  If only two
;         parameters are supplied, then  AI and BI will be modified to
;         contain the output longitude and latitude.
;        BI - Input Latitude in RADIANS
;
; OPTIONAL INPUT:
;        SELECT - Integer (1-6) specifying type of coordinate transformation.
;
;        SELECT     From          To     |   SELECT      From            To
;        1     RA-DEC(1950)   GAL.(ii)   |     5       ECLIPTIC       GAL.(ii)
;        2     GAL.(ii)       RA-DEC     |     6       GAL.(ii)       ECLIPTIC
;        3     RA-DEC         ECLIPTIC   |     7       System A       System B
;        4     ECLIPTIC       RA-DEC     |     8       System B       System A
;
;        If omitted, program will prompt for the value of SELECT
;
; OUTPUTS:
;        AO - Output Longitude in RADIANS
;        BO - Output Latitude in RADIANS
;
; REVISION HISTORY:
;        Written W. Landsman,  February 1987
;        Adapted from Fortran by Daryl Yentis NRL
;        22-JUN-1994:   H.C. Wen, change angle units from degrees to radians.
;                       Added SETSYB keyword, and 2 more conversion options:
;
;                       System A to System B
;                       ========    ========
;                           System B:  z-axis = alongz,alatz
;                               x-axis = alongx,alatx = zero azimuth (longitude)
;
;                           PSI,THETA,PHI = F(alongz,alatz,alongx,alatx)
;                                    initialized at ENTRY SETSYB.
;                                             ----- ------
;                           SYASYB, alongz,alatz,alongx,alatx
;                           EULER2, along,alat,blong,blat, 7
;
;                       System B to System A
;                       ========    ========
;                           PSI,THETA,PHI = F(alongz,alatz,alongx,alatx)
;                                    initialized at ENTRY SETSYB.
;                                             ----- ------
;                           EULER2, blong,blat,along,alat, 8
;
;        15-AUG-1995    Comment bugfix: removed extraneous ;+ and ;-.
;-
PRO EULER2,AI,BI,AO,BO,SELECT,SETSYB=Setsyb_flag

         common SYAB_DATA, SY_psi, SY_phi, SY_stheta, SY_ctheta

         On_error,2

         npar = N_params()
         if npar LT 4 then begin
              print,'Syntax - EULER, AI, BI, A0, B0, [ SELECT ]
              print,'    AI,BI - Input longitude,latitude in radians'
              print,'    AO,BO - Output longitude, latitude in radians'
              print,'    SELECT - Scalar (1-6) specifying transformation type'
              return
         endif

         twopi   =   2.*!DPI
         fourpi  =   4.*!DPI

         if keyword_set( setsyb_flag ) then begin
                SETSYB, AI,BI,AO,BO
                return
         endif

         if npar LT 5 then begin
                print,' '
                print,' 1 RA-DEC(1950) TO GAL.(ii)
                print,' 2 GAL.(ii)     TO RA-DEC
                print,' 3 RA-DEC       TO ECLIPTIC
                print,' 4 ECLIPTIC     TO RA-DEC
                print,' 5 ECLIPTIC     TO GAL.(ii)
                print,' 6 GAL.(ii)     TO ECLIPTIC
                print,' 7 System A     TO System B
                print,' 8 System B     TO System A
                read,'Enter selection: ',select
         endif

         if SELECT lt 7 then begin
              psi   = [ 0.57595865315D, 4.9261918136D,  $
                        0.00000000000D, 0.0000000000D,  $
                        0.11129056012D, 4.7005372834D]
              stheta =[ 0.88781538514D,-0.88781538514D, $
                        0.39788119938D,-0.39788119938D, $
                        0.86766174755D,-0.86766174755D]
              ctheta =[ 0.46019978478D, 0.46019978478D, $
                        0.91743694670D, 0.91743694670D, $
                        0.49715499774D, 0.49715499774D]
              phi  = [ 4.9261918136D,  0.57595865315D, $
                        0.0000000000D, 0.00000000000D, $
                        4.7005372834d, 0.11129056012d]
              I  = select - 1                         ; IDL offset
              a  = ai - phi(i,*)
              b  = bi
         endif else begin
              psi       = SY_psi
              phi       = SY_phi
              stheta    = SY_stheta
              ctheta    = SY_ctheta
              I = 0
              k = N_ELEMENTS( psi )/2  ;number of transformations
;
;             a = REPLICATE(1.,k)#ai - phi(i,*)
;             b = REPLICATE(1.,k)#bi
; Bugfix: 08-SEP-1994, H.C. Wen
;
              a = REPLICATE(1.,k)*ai - phi(i,*)
              b = REPLICATE(1.,k)*bi
         endelse

         sb = sin(b) & cb = cos(b)
         cbsa = cb * sin(a)
         b  = -stheta(i,*) * cbsa + ctheta(i,*) * sb
         bo    = REFORM(asin(b<1.0d))  ;trim (1,n) array into a (n) array

         a =  atan( ctheta(i,*) * cbsa + stheta(i,*) * sb, cb * cos(a) )
        ;
        ; factor of 1./(cos(bo)) removed from both sin(a) and cos(a)
        ;
         ao = REFORM( (a+psi(i,*)+fourpi) mod twopi)


         if ( npar EQ 2 ) then begin
                 ai = ao & bi=bo
         endif

         return
end



