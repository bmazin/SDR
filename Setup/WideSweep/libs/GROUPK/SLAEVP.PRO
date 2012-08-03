;+
;     - - - - - - -
;      s l a E V P
;     - - - - - - -
;
;  Barycentric and heliocentric velocity and position of the Earth
;
;  All arguments are double precision
;
;  Given:
;
;     DATE          TDB (loosely ET) as a Modified Julian Date
;                                         (JD-2400000.5)
;
;     DEQX          Julian Epoch (e.g. 2000.0D0) of mean equator and
;                   equinox of the vectors returned.  If DEQX .LE. 0D0,
;                   all vectors are referred to the mean equator and
;                   equinox (FK5) of date DATE.
;
;  Returned (all 3D Cartesian vectors):
;
;     DVB,DPB       barycentric velocity, position
;
;     DVH,DPH       heliocentric velocity, position
;
;  (Units are au/s for velocity and au for position)
;
;  Called:  slaEPJ, slaPREC
;
;  Accuracy:
;
;     The maximum deviations from the JPL DE96 ephemeris are as
;     follows:
;
;     barycentric velocity                  42  cm/s
;     barycentric position           0.000 046  au
;
;     heliocentric velocity                 42  cm/s
;     heliocentric position          0.000 011  au
;
;  This routine is adapted from the BARVEL and BARCOR
;  subroutines of P.Stumpff, which are described in
;  Astron. Astrophys. Suppl. Ser. 41, 1-8 (1980).  Most of the
;  changes are merely cosmetic and do not affect the results at
;  all.  However, some adjustments have been made so as to give
;  results that refer to the new (IAU 1976 'FK5') equinox
;  and precession, although the differences these changes make
;  relative to the results from Stumpff's original 'FK4' version
;  are smaller than the inherent accuracy of the algorithm.  One
;  minor shortcoming in the original routines that has NOT been
;  corrected is that better numerical accuracy could be achieved
;  if the various polynomial evaluations were nested.  Note also
;  that one of Stumpff's precession constants differs by 0.001 arcsec
;  from the value given in the Explanatory Supplement to the A.E.
;
;  P.T.Wallace   Starlink   27 November 1991
;  H.Wen         SLAC       15 November 1994 - IDL vectorized
;-
pro slaEVP, Date, Deqx, Dvb, Dpb, Dvh, Dph

         COMMON EVPCOM, CC2PI,CCSEC3,CCSGD,CCKM,CCMLD,CCFDI,CCIM,$
                        DC2PI,DS2R,DCSLD,DC1MME,  $
                        CCSEL,CCAMPS,CCSEC,CCAMPM,$
                        CCPAMV,CCPAM,$
                        DCFEL,DCEPS,DCARGS,DCARGM

         sinlp     = dblarr(4)
         coslp     = dblarr(4)
         dprema    = dblarr(3,3)
         forbel    = fltarr(7)


         if N_ELEMENTS( CC2PI ) eq 0 then begin

         DC2PI=    6.2831853071796D0
         CC2PI=    6.283185
         DS2R=     0.7272205216643D-04

;
;   Constants DCFEL(I,K) of fast changing elements
;                     I=1                I=2              I=3
         DCFEL=    [$
                     [1.7400353D+00, 6.2833195099091D+02, 5.2796D-06],$
                     [6.2565836D+00, 6.2830194572674D+02,-2.6180D-06],$
                     [4.7199666D+00, 8.3997091449254D+03,-1.9780D-05],$
                     [1.9636505D-01, 8.4334662911720D+03,-5.6044D-05],$
                     [4.1547339D+00, 5.2993466764997D+01, 5.8845D-06],$
                     [4.6524223D+00, 2.1354275911213D+01, 5.6797D-06],$
                     [4.2620486D+00, 7.5025342197656D+00, 5.5317D-06],$
                     [1.4740694D+00, 3.8377331909193D+00, 5.6093D-06] $
                   ]

;
;   Constants DCEPS and CCSEL(I,K) of slowly changing elements
;                      I=1           I=2           I=3
         DCEPS=    [  4.093198D-01,-2.271110D-04,-2.860401D-08 ]
         CCSEL=    [$
                     [1.675104E-02,-4.179579E-05,-1.260516E-07],$
                     [2.220221E-01, 2.809917E-02, 1.852532E-05],$
                     [1.589963E+00, 3.418075E-02, 1.430200E-05],$
                     [2.994089E+00, 2.590824E-02, 4.155840E-06],$
                     [8.155457E-01, 2.486352E-02, 6.836840E-06],$
                     [1.735614E+00, 1.763719E-02, 6.370440E-06],$
                     [1.968564E+00, 1.524020E-02,-2.517152E-06],$
                     [1.282417E+00, 8.703393E-03, 2.289292E-05],$
                     [2.280820E+00, 1.918010E-02, 4.484520E-06],$
                     [4.833473E-02, 1.641773E-04,-4.654200E-07],$
                     [5.589232E-02,-3.455092E-04,-7.388560E-07],$
                     [4.634443E-02,-2.658234E-05, 7.757000E-08],$
                     [8.997041E-03, 6.329728E-06,-1.939256E-09],$
                     [2.284178E-02,-9.941590E-05, 6.787400E-08],$
                     [4.350267E-02,-6.839749E-05,-2.714956E-07],$
                     [1.348204E-02, 1.091504E-05, 6.903760E-07],$
                     [3.106570E-02,-1.665665E-04,-1.590188E-07] $
                   ]

;
;   Constants of the arguments of the short-period perturbations
;   by the planets:   DCARGS(I,K)
;                       I=1               I=2
         DCARGS=   [$
                     [5.0974222D+00,-7.8604195454652D+02],$
                     [3.9584962D+00,-5.7533848094674D+02],$
                     [1.6338070D+00,-1.1506769618935D+03],$
                     [2.5487111D+00,-3.9302097727326D+02],$
                     [4.9255514D+00,-5.8849265665348D+02],$
                     [1.3363463D+00,-5.5076098609303D+02],$
                     [1.6072053D+00,-5.2237501616674D+02],$
                     [1.3629480D+00,-1.1790629318198D+03],$
                     [5.5657014D+00,-1.0977134971135D+03],$
                     [5.0708205D+00,-1.5774000881978D+02],$
                     [3.9318944D+00, 5.2963464780000D+01],$
                     [4.8989497D+00, 3.9809289073258D+01],$
                     [1.3097446D+00, 7.7540959633708D+01],$
                     [3.5147141D+00, 7.9618578146517D+01],$
                     [3.5413158D+00,-5.4868336758022D+02] $
                   ]

;
;   Amplitudes CCAMPS(N,K) of the short-period perturbations
;           N=1          N=2          N=3          N=4          N=5
         CCAMPS=   [$
      [-2.279594E-5, 1.407414E-5, 8.273188E-6, 1.340565E-5,-2.490817E-7],$
      [-3.494537E-5, 2.860401E-7, 1.289448E-7, 1.627237E-5,-1.823138E-7],$
      [ 6.593466E-7, 1.322572E-5, 9.258695E-6,-4.674248E-7,-3.646275E-7],$
      [ 1.140767E-5,-2.049792E-5,-4.747930E-6,-2.638763E-6,-1.245408E-7],$
      [ 9.516893E-6,-2.748894E-6,-1.319381E-6,-4.549908E-6,-1.864821E-7],$
      [ 7.310990E-6,-1.924710E-6,-8.772849E-7,-3.334143E-6,-1.745256E-7],$
      [-2.603449E-6, 7.359472E-6, 3.168357E-6, 1.119056E-6,-1.655307E-7],$
      [-3.228859E-6, 1.308997E-7, 1.013137E-7, 2.403899E-6,-3.736225E-7],$
      [ 3.442177E-7, 2.671323E-6, 1.832858E-6,-2.394688E-7,-3.478444E-7],$
      [ 8.702406E-6,-8.421214E-6,-1.372341E-6,-1.455234E-6,-4.998479E-8],$
      [-1.488378E-6,-1.251789E-5, 5.226868E-7,-2.049301E-7, 0.0E0],      $
      [-8.043059E-6,-2.991300E-6, 1.473654E-7,-3.154542E-7, 0.0E0],      $
      [ 3.699128E-6,-3.316126E-6, 2.901257E-7, 3.407826E-7, 0.0E0],      $
      [ 2.550120E-6,-1.241123E-6, 9.901116E-8, 2.210482E-7, 0.0E0],      $
      [-6.351059E-7, 2.341650E-6, 1.061492E-6, 2.878231E-7, 0.0E0]       $
                   ]

;
;   Constants of the secular perturbations in longitude
;   CCSEC3 and CCSEC(N,K)
;                      N=1           N=2           N=3
         CCSEC3=   -7.757020E-08
         CCSEC=    [$
                  [1.289600E-06, 5.550147E-01, 2.076942E+00],$
                  [3.102810E-05, 4.035027E+00, 3.525565E-01],$
                  [9.124190E-06, 9.990265E-01, 2.622706E+00],$
                  [9.793240E-07, 5.508259E+00, 1.559103E+01] $
                   ]

;   Sidereal rate DCSLD in longitude, rate CCSGD in mean anomaly
         DCSLD=    1.990987D-07
         CCSGD=    1.990969E-07

;   Some constants used in the calculation of the lunar contribution
         CCKM=     3.122140E-05
         CCMLD=    2.661699E-06
         CCFDI=    2.399485E-07

;
;   Constants DCARGM(I,K) of the arguments of the perturbations
;   of the motion of the Moon
;                       I=1               I=2
         DCARGM=   [$
                   [5.1679830D+00, 8.3286911095275D+03],$
                   [5.4913150D+00,-7.2140632838100D+03],$
                   [5.9598530D+00, 1.5542754389685D+04] $
                   ]

;
;   Amplitudes CCAMPM(N,K) of the perturbations of the Moon
;            N=1          N=2           N=3           N=4
         CCAMPM=   [$
      [ 1.097594E-01, 2.896773E-07, 5.450474E-02, 1.438491E-07],$
      [-2.223581E-02, 5.083103E-08, 1.002548E-02,-2.291823E-08],$
      [ 1.148966E-02, 5.658888E-08, 8.249439E-03, 4.063015E-08] $
                   ]

;
;   CCPAMV(K)=A*M*DL/DT (planets), DC1MME=1-MASS(Earth+Moon)
         CCPAMV=   [8.326827E-11,1.843484E-11,1.988712E-12,1.881276E-12]
         DC1MME=   0.99999696D0

;   CCPAM(K)=A*M(planets), CCIM=INCLINATION(Moon)
         CCPAM=    [4.960906E-3,2.727436E-3,8.392311E-4,1.556861E-3]
         CCIM=     8.978749E-2

         endif
;
;   EXECUTION
;   ---------

;   Control parameter IDEQ, and time arguments
         ideq = 0
         if (deqx gt 0d0) then ideq=1
         dt = (date-15019.5d0)/36525d0
         t = float(dt)
         dtsq = dt*dt
         tsq = float(dtsq)

;   Values of all elements for the instant DATE

         k      = indgen(8)
         dlocal = (dcfel(0,k)+dt*dcfel(1,k)+dtsq*dcfel(2,k)) MOD dc2pi
         dml    = dlocal(0)
         k      = indgen(7)+1
         forbel(k-1) = float(dlocal(k))

         g    = forbel(0)
         deps = dceps(0)+dt*dceps(1)+dtsq*dceps(2) MOD dc2pi
         sorbel = (ccsel(0,*)+t*ccsel(1,*)+tsq*ccsel(2,*)) MOD cc2pi
         e    = sorbel(0)

;   Secular perturbations in longitude

         sn   = sin( ccsec(1,*) + t*ccsec(2,*)) mod cc2pi


;   Periodic perturbations of the EMB (Earth-Moon barycentre)
         pertl =  ccsec(0,0)          *sn(0) +ccsec(0,1)*sn(1)+$
                 (ccsec(0,2)+t*ccsec3)*sn(2) +ccsec(0,3)*sn(3)
         pertld = 0.0
         pertr = 0.0
         pertrd = 0.0

         k    = indgen(15)
         a = float((dcargs(0,k)+dt*dcargs(1,k)) mod dc2pi)
         cosa = cos(a)
         sina = sin(a)
         pertl = pertl + TOTAL(ccamps(0,k)*cosa+ccamps(1,k)*sina)
         pertr = pertr + TOTAL(ccamps(2,k)*cosa+ccamps(3,k)*sina)
         k    = indgen(10)
         pertld = pertld+$
                  TOTAL((ccamps(1,k)*cosa-ccamps(0,k)*sina)*ccamps(4,k))
         pertrd = pertrd+$
                  TOTAL((ccamps(3,k)*cosa-ccamps(2,k)*sina)*ccamps(4,k))

;   Elliptic part of the motion of the EMB
         esq = e*e
         dparam = 1d0-double(esq)
         param = float(dparam)
         twoe = e+e
         twog = g+g
         phi = twoe*((1.0-esq*0.125)*sin(g)+e*0.625*sin(twog)+$
                   esq*0.5416667*sin(g+twog) )
         f = g+phi
         sinf = sin(f)
         cosf = cos(f)
         dpsi = dparam/(1d0+double(e*cosf))
         phid = twoe*ccsgd*((1.0+esq*1.5)*cosf+e*(1.25-sinf*sinf*0.5))
         psid = ccsgd*e*sinf/sqrt(param)

;   Perturbed heliocentric motion of the EMB
         d1pdro = 1d0+double(pertr)
         drd = d1pdro*(double(psid)+dpsi*double(pertrd))
         drld = d1pdro*dpsi*(dcsld+double(phid)+double(pertld))
         dtl = (dml+double(phi)+double(pertl)) MOD dc2pi
         dsinls = sin(dtl)
         dcosls = cos(dtl)
         dxhd = drd*dcosls-drld*dsinls
         dyhd = drd*dsinls+drld*dcosls

;   Influence of eccentricity, evection and variation on the
;   geocentric motion of the Moon
         pertl = 0.0
         pertld = 0.0
         pertp = 0.0
         pertpd = 0.0

         k    = indgen(3)
         a = float((dcargm(0,k)+dt*dcargm(1,k)) mod dc2pi)
         sina = sin(a)
         cosa = cos(a)
         pertl = pertl +TOTAL(ccampm(0,k)*sina)
         pertld = pertld+TOTAL(ccampm(1,k)*cosa)
         pertp = pertp +TOTAL(ccampm(2,k)*cosa)
         pertpd = pertpd-TOTAL(ccampm(3,k)*sina)

;   Heliocentric motion of the Earth
         tl = forbel(1)+pertl
         sinlm = sin(tl)
         coslm = cos(tl)
         sigma = cckm/(1.0+pertp)
         a = sigma*(ccmld+pertld)
         b = sigma*pertpd
         dxhd = dxhd+double(a*sinlm)+double(b*coslm)
         dyhd = dyhd-double(a*coslm)+double(b*sinlm)
         dzhd =     -double(sigma*ccfdi*cos(forbel(2)))

;   Barycentric motion of the Earth
         dxbd = dxhd*dc1mme
         dybd = dyhd*dc1mme
         dzbd = dzhd*dc1mme

         k    = indgen(4)
         plon = forbel(k+3)
         pomg = sorbel(k+1)
         pecc = sorbel(k+9)
         tl = (plon+2.0*pecc*sin(plon-pomg)) mod cc2pi
         sinlp(k) = sin(tl)
         coslp(k) = cos(tl)
         dxbd = dxbd+TOTAL(double(ccpamv(k)*(sinlp(k)+pecc*sin(pomg))))
         dybd = dybd-TOTAL(double(ccpamv(k)*(coslp(k)+pecc*cos(pomg))))
         dzbd = dzbd-TOTAL(double(ccpamv(k)*sorbel(k+13)*cos(plon-sorbel(k+5))))

;   Transition to mean equator of date
          dcosep = cos(deps)
          dsinep = sin(deps)
          dyahd = dcosep*dyhd-dsinep*dzhd
          dzahd = dsinep*dyhd+dcosep*dzhd
          dyabd = dcosep*dybd-dsinep*dzbd
          dzabd = dsinep*dybd+dcosep*dzbd

;   Heliocentric coordinates of the Earth
          dr = dpsi*d1pdro
          flatm = ccim*sin(forbel(2))
          a = sigma*cos(flatm)
          dxh = dr*dcosls-double(a*coslm)
          dyh = dr*dsinls-double(a*sinlm)
          dzh =          -double(sigma*sin(flatm))

;   Barycentric coordinates of the Earth
          dxb = dxh*dc1mme
          dyb = dyh*dc1mme
          dzb = dzh*dc1mme

          k    = indgen(4)
          flat = sorbel(k+13)*sin(forbel(k+3)-sorbel(k+5))
          a = ccpam(k)*(1.0-sorbel(k+9)*cos(forbel(k+3)-sorbel(k+1)))
          b = a*cos(flat)
          dxb = dxb-TOTAL(double(b*coslp(k)))
          dyb = dyb-TOTAL(double(b*sinlp(k)))
          dzb = dzb-TOTAL(double(a*sin(flat)))

;   Transition to mean equator of date
          dyah = dcosep*dyh-dsinep*dzh
          dzah = dsinep*dyh+dcosep*dzh
          dyab = dcosep*dyb-dsinep*dzb
          dzab = dsinep*dyb+dcosep*dzb

;   Copy result components into vectors, correcting for FK4 equinox
          depj   = slaEPJ(date)
          deqcor = ds2r*(0.035+0.00085*(depj-1950d0))
          dvh    = dblarr(3)
          dvh(0) = dxhd-deqcor*dyahd
          dvh(1) = dyahd+deqcor*dxhd
          dvh(2) = dzahd
          dvb    = dblarr(3)
          dvb(0) = dxbd-deqcor*dyabd
          dvb(1) = dyabd+deqcor*dxbd
          dvb(2) = dzabd
          dph    = dblarr(3)
          dph(0) = dxh-deqcor*dyah
          dph(1) = dyah+deqcor*dxh
          dph(2) = dzah
          dpb    = dblarr(3)
          dpb(0) = dxb-deqcor*dyab
          dpb(1) = dyab+deqcor*dxb
          dpb(2) = dzab

;   Was precession to another equinox requested?
          if (ideq ne 0) then begin

;     Yes: compute precession matrix from MJD DATE to Julian epoch DEQX
              slaPREC,depj,deqx,dprema

;     Rotate DVH

              dvh  = dprema # dvh

;     Rotate DVB

              dvb  = dprema # dvb

;     Rotate DPH

              dph  = dprema # dph

;     Rotate DPB

              dpb  = dprema # dpb
         endif

end
