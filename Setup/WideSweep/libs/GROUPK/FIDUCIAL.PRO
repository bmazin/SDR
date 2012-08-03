;+
; NAME:
;        FIDUCIAL
;
; PURPOSE:
;        Applies various fiducial or "quality" cuts on an IDL HEAO A-1 data
;        file, extracts relevant scan characteristics into a data structure
;        and saves this structure to an IDL session file.  The USER is able
;        to interactively select which scans to accept or reject, respective
;        or irrespective of the fiducial cuts.
;
; CATEGORY:
;        HEAO A-1 scanning.
;
; OPTIONAL INPUTS:
;
;        Former "command line" options such as the input IDL data filename
;        are now handled interactively within FIDUCIAL.  You may select the
;        appropriate IDL data file by selecting the File pulldown submenu
;        on the Fiducial Main Menu.
;
; OPTIONAL INPUT KEYWORDS:
;
;        All of the former optional input keywords may now be configured
;        interactively in FIDUCIAL by selecting the Options pulldown submenu
;        on the Fiducial Main Menu.
;
; CALLING SEQUENCE:
;        FIDUCIAL
;
; OPTIONAL OUTPUTS:
;
;        The USER may interactively select to save the results of the
;        data analysis to an IDL session file (*.sav).  The contents of this
;        saved file is one structure variable, named "data". The tags of this
;        data structure are defined as follows: (NOTE: Only signal region
;        data is saved!)
;
;        structure: data
;        tags:
;                                                                     Data file
;   Name      Description                         Type(Size)          formats
;   --------- ------------------------------      ------------------  ----------
;   mode      Timing mode (320 ms or 5 ms).       integer             All
;   module    Module number (1-7).                integer             All
;   npass     Number of scans that passed         integer             All
;             the fiducial or quality cuts
;   nfail     Number of scans that failed         integer             All
;             the fiducial or quality cuts.
;   nscan     Total number of scans in data file  integer             All
;   nbin      Total number of data points.        integer             All
;   nsig      The number of bins in each scan     intarr(npass)       All
;             where the total transmission from
;             summing all sources is > 0.
;   nsig_src  The number of bins in each scan     intarr(npass,nsrc)  All
;             where the transmission from each
;             source is > 0.
;   nsrc      Number of sources in data.          integer             All
;             (for each scan if number of         intarr(npass)       All
;             sources vary)
;   name      Name of each source in the data.    strarr(nsrc)        All
;   degree    Degree of polynomial used to        integer             All
;             fit the background
;   mjfs      First major frame number in         lonarr(npass)       All
;             each scan.
;   nmjfs     Number of major frames in each      intarr(npass)       All
;             scan.
;   sig       The signal = cts - background       fltarr(nbin)        All
;             at each bin where the trans. > 0
;             for each scan.
;   cts       The detector counts, cts in the     fltarr(nbin)        All
;             signal region for each scan.
;   bkd       The fitted background in the        fltarr(nbin)        All
;             signal region for each scan.
;   bkd_coeff The coefficients of the fitted      fltarr(npass,       All
;             background                                degree)
;   trns      The transmissions of each source    fltarr(nbin,nsrc)   All
;             in the signal region for each scan.
;   phis      The scan longitude in the signal    dblarr(nbin)        DIRS
;             region for each scan in RADIANS.
;   thts      The scan latitude in the signal     dblarr(nbin)        DIRS
;             region for each scan in RADIANS.
;   intensity The fitted intensity, assuming      fltarr(npass,nsrc)  ASPECTS,
;             constant sources, for each source.                      STANDARD,
;                                                                     NOBARY
;   sigma     The sigma uncertainties associated  fltarr(npass,nsrc)  ASPECTS,
;             with each fitted intensity.                             STANDARD,
;                                                                     NOBARY
;   pk_bins   The bins where the transmission     intarr(npass,nsrc)  All
;             is a max. for each source and each
;             scan.
;   pk_trns   The tranmission max. for each       fltarr(npass,nsrc)  All
;             and each scan.
;   overlap   The fraction of each sourc trans.   fltarr(npass,nsrc)  All
;             overlapped by the sum of all the
;             other sources' trans.
;   t77i      The integer time in seconds since   lonarr(npass,nsrc)  All
;             1977 at the peak trans. bin for
;             for each scan and each source.
;   t77f      The fraction of a second since      dblarr(npass,nsrc)  All
;             1977 at the peak trans. bin for
;             for each scan and each source.
;   tcorr     The barycentric time correction     dblarr(2,npass,     ASPECTS,
;             at the beginning and end of the                  nsrc)  STANDARD
;             transmission function for each
;             scan and for each source.
;   aspects   A structure containing the                              ASPECTS
;             satellite's aspects at the beginning
;             of each scan.  This structure
;             contains two tags defined as:
;             y : The RA and DEC of the Y-axis    dblarr(2,npass)
;                 in DEGREES for each scan.
;             z : The RA and DEC of the Z-axis    dblarr(2,npass)
;                 in DEGREES for each scan.
;   MJF_RNG   range of major frames selected by   lonarr(2)           All
;             USER, 0 if none.
;   BAD_MJFS  list of bad major frames selected   lonarr(nbad)        All
;             by the USER, 0 if none.
;   FORMAT    format of the IDL data file         string              All
;   NOTRNS    flag to exclude transmission        integer             All
;             regions in fit of the scan, 1=yes
;   DEADTIME  type of dead time correction        integer             All
;             applied to the cts data:
;             = 0, No dead time corrections
;             = 1, NON-Extended or NON-Paralyzable
;                  dead time corrections made
;             = 2, Extended or Paralyzable
;                  dead time corrections made
;   VERSION   version number of the FIDUCIAL      float               ASPECTS
;             routine that created the save file
;
;        Another output option is for Fiducial to write out the first major
;        frame number of every scan that was EXCLUDED; FAILED the fiducial
;        cuts; or optionally, REJECTED by the USER (*.bad).  The USER
;        interactively chooses the name of this output file.
;
; COMMON BLOCKS:
;     These common block are for INTERNAL USE ONLY.
;
;     DATA_COM:    Common block holding the structure, data. This structure
;                  contains all relevant scan characteristics for those scans
;                  that pass the fiducial cuts.
;     INIT_COM:    This common block holds all the settings configurable
;                  by the USER.  The variables within this common block
;                  used to be optional keyword inputs to the Fiducial routine.
;     LC_COM:      This common block holds the scan data for the current
;                  scan for use of displaying or printing its light curve.
;     XF_CUT_COM:  Keeps track of the Widget Identifier for the Main Menu.
;
; MODIFICATION HISTORY:
;   August, 1994             H.C. Wen
;   06-SEP-1994              Changed PK_BINS to give bins relative to the
;                            SAVED signal region, NOT relative to the 128 or
;                            8192 bins!  Eliminated PK_TRNS, PK_CTS and PK_THTS.
;   09-SEP-1994              Added the DEADTIME keyword to make deadtime corrections
;                            to the data.
;   15-NOV-1994              Added the ASPECTS format.
;   20-NOV-1994              Additional sources may be added INTERACTIVELY.
;   21-NOV-1994              Mark bad MJFs for ALL failed scans, not just
;                            those rejected interactively under FINAL CUT.
;   23-DEC-1994              Converted FIDUCIAL into a widget routine
;                            => FIDUCIAL.
;   05-JAN-1995              Removed glitch cuts for 5ms data, added FILE
;                            keyword to PICKFILE calls.
;   07-JAN-1995              Read in .dbs file (if available) to determine
;                            MAX_NSCAN and MAX_NBIN.
;   11-JAN-1995              Bugfix: fixed warning messages when buffer full
;                            and at end of data file.
;   17-JAN-1995              Bugfix: t77i = fltarr() => lonarr(). Also changed
;                            t77f, tcorr = fltarr() => dblarr().
;   18-JAN-1995              Changed t77i,t77f from time at beginning of signal
;                            region to time at peak trns. of each source.
;                            Transposed all structure tags from ( nsrc,npass )
;                            -> (npass, nsrc) (i.e. pk_bins, intensity, sigma,
;                            tcorr and trns). Also added the version tag to
;                            indicate which version of FIDUCIAL created the
;                            save file. (version 3.0)
;   19-JAN-1995              Bugfix: idl.max_nbin = nscan*nbin => nmjf*nbin
;                            Added the YNCANCEL widget when quitting back to
;                            the Fiducial Main Menu. (version 3.1)
;   22-JAN-1995              Moved FIDUCIAL to the OBSOLETE directory and
;                            renamed XFIDUCIAL -> FIDUCIAL. (still version 3.1)
;   22-JAN-1995              Bugfix: made data.name = strarr(1) if nsrc=1,
;                            previously=scalar string. (version 3.2)
;   27-JAN-1995              Bugfix: small bug if data only contains one scan,
;                            cannot transpose a scalar => 1-D array = [scalar]
;   08-FEB-1995              Bugfix: data.name was incorrectly filled with
;                            extra blank array elements between the primary
;                            sources in the .idl data file and the sources
;                            from the .add file. (version 3.4)
;   11-FEB-1995              Utilized CREATE_STRUCT when saving data structure,
;                            added the PK_TRNS and ASPECTS tags, (version 4.0)
;   14-FEB-1995              Added the NSIG_SRC and OVERLAP tags, (version 5.0)
;   15-FEB-1995              Added the Passed after MJF cutoff option in the
;                            light curves option menu, (version 5.1)
;   16-FEB-1995              Added the BKD_COEFF tag, (version 6.0)
;   06-AUG-1996              Check if !SAVE_PATH, !DATA_PATH system variables
;                            are defined.
;-
;========= BEGIN XF_BUF_INIT routines ==================================
;
;   Initialize all common structure variables
;
pro XF_BUF_INIT

         common INIT_COM, idl, extra, bad, files
         common DATA_COM, bkkping, data_keep

         WIDGET_CONTROL, /HOURGLASS

;   Read the first scan into the scan buffer

         lunit = INIT_SCAN( files.IDL, FORMAT=idl.format )
         idl.io_unit = lunit

;   Extract common variables

         Format    = idl.Format
         Degree    = idl.Degree
         max_nsrc  = idl.max_nsrc
         max_nscan = idl.max_nscan
         max_nbin  = idl.max_nbin
         LT_CURV   = idl.lt_curv

         nsrc_extra= extra.nsrc
         name_extra= extra.name
         RA_extra  = extra.RA
         DEC_extra = extra.DEC

;   Define the structure which will hold our static bookkeeping keywords
;   and the scan characteristics

         if keyword_set( LT_CURV )     then LCLOADCT

         fmt       = strupcase( Format )
         bkkping = {      FORMAT  : Fmt,                   $
                          DEGREE  : Degree,                $
                            mode  : 0,                     $
                          module  : 0,                     $
                            nsrc  : fltarr( max_nscan ),   $
                            name  : strarr( max_nsrc ),    $
                           npass  : 0,                     $
                           nfail  : 0,                     $
                           nscan  : 0,                     $
                           nmark  : 0,                     $
                        mjf_mark  : lonarr( max_nscan ),   $
                        data_ptr  : 0L,                    $
                      nsrc_extra  : nsrc_extra,            $
                      name_extra  : name_extra,            $
                        RA_extra  : RA_extra,              $
                       DEC_extra  : DEC_extra              $
                   }

;   Define the structure which will hold our scan characteristics based
;   on ALL the possible FORMATs of the data file

         asp_struct= { y:fltarr(2,max_nscan), z:fltarr(2,max_nscan) }
         data_keep = {  $
                           nmjfs  : fltarr(max_nscan), $
                            mjfs  : lonarr(max_nscan), $
                            nsig  : intarr(max_nscan), $
                             sig  : fltarr(max_nbin),  $
                             cts  : fltarr(max_nbin),  $
                             bkd  : fltarr(max_nbin),  $
                            trns  : fltarr(max_nsrc,max_nbin),  $
                       intensity  : fltarr(max_nsrc,max_nscan), $
                            phis  : fltarr(max_nbin),  $
                            thts  : fltarr(max_nbin),  $
                           sigma  : fltarr(max_nsrc,max_nscan), $
                         pk_bins  : fltarr(max_nsrc,max_nscan), $
                            t77i  : lonarr(max_nsrc,max_nscan), $
                            t77f  : dblarr(max_nsrc,max_nscan), $
                           tcorr  : dblarr(2,max_nsrc,max_nscan), $
                         pk_trns  : fltarr(max_nsrc,max_nscan), $
                         aspects  : asp_struct, $
                        nsig_src  : intarr(max_nsrc,max_nscan), $
                         overlap  : fltarr(max_nsrc,max_nscan), $
                       bkd_coeff  : fltarr(degree+1,max_nscan)  }

end

;========= END XF_BUF_INIT routines ====================================

;========= BEGIN XF_NEXT_SCAN routines =================================
;
;   This routine reads in the next scan and sees if it
;   passes the various fiducial cuts.  It the option is set,
;   then the resulting light curve is plotted to the display.
;   This function then returns 1 if a light curve was plotted
;   and 0 if not.
;
function XF_NEXT_SCAN

         common INIT_COM, idl, extra, bad, files
         common DATA_COM, bkkping, data_keep
         common LC_COM, lcdata

;  Now read in a major frame buffer

         eofb = GET_SCAN( 1, DATA=Data )
         if eofb then return, -1            ;at end of file and buffer

;   Extract common variables

         MJF_rng   = idl.MJF_rng
         Bad_MJFs  = bad.MJFs
         Notrns    = idl.notrns
         Lt_curv   = idl.lt_curv
         Deadtime  = idl.deadtime

;   Extract bookkeeping keywords

         FORMAT    = bkkping.Format
         DEGREE    = bkkping.Degree

;   and some pointers...

         npass     = bkkping.npass
         nfail     = bkkping.nfail
         data_ptr  = bkkping.data_ptr
         nsrc_extra= bkkping.nsrc_extra

;   Extract relevant Data structures
;   common to all Formats...

         mode      = data(0).mode
         module    = data(0).module
         nsrc      = data(0).nsrc
         nsrc_tot  = nsrc + (nsrc_extra > 0)
         name      = data(0).srcnam
         mjfs      = data.mjf
         mjf       = mjfs(0)
         nmjfs     = n_elements( data )
         nbin_mjf  = data(0).nbin
         nbin      = nmjfs*nbin_mjf
         name_extra= bkkping.name_extra

         bkkping.mode             = mode
         bkkping.module           = module

         bkkping.nsrc( npass )    = nsrc
         bkkping.name( 0:nsrc-1 ) = name
         data_keep.mjfs( npass )  = mjf
         data_keep.nmjfs( npass ) = nmjfs

;   and those depending on a particular to a file format

         t77i      = data.t77i
         t77f      = data.t77f
         cts       = reform( data.cts, nbin )
         trns1     = reform( data.trns, nsrc, nbin )

         pass_all = 0

;   Apply EXCLUSION cuts

         cut  = 'EXCLUDED'

         if keyword_set( MJF_RNG(1) ) then $
              if (mjf lt MJF_RNG(0)) or (mjf gt MJF_RNG(1)) then begin
                 print,'MJF out of USER-selected range -> excluded.'
                 trns = 0
                 ofit = 0
                 goto, FAIL
              endif

         if keyword_set( BAD_MJFS ) then begin
              here_bad = WHERE( bad_mjfs eq mjf, nbad )
              if nbad gt 0 then begin
                   print,'BAD MJF -> excluded.'
                   trns = 0
                   ofit = 0
                   goto, FAIL
              endif
         endif

;   Determine the transmissions of any additional sources
;   provided by the ADDITIONAL_SOURCES keyword

         if FORMAT eq 'ASPECTS' then begin
              RAY  = REFORM( data.sat.aspects.y(0,*), nbin )
              DEY  = REFORM( data.sat.aspects.y(1,*), nbin )
              RAZ  = REFORM( data.sat.aspects.z(0,*), nbin )
              DEZ  = REFORM( data.sat.aspects.z(1,*), nbin )

         endif else begin
              RAY  = data.RAY*!dtor
              DEY  = data.DEY*!dtor
              RAZ  = data.RAZ*!dtor
              DEZ  = data.DEZ*!dtor
         endelse

         CASE 1 OF

           ( nsrc_extra gt 0 ) : $    ;   USER-predefined sources
           begin
              ddtor     = !dpi/180.d0
              srcRA     = bkkping.RA_extra*ddtor
              srcDEC    = bkkping.DEC_extra*ddtor
              trns      = fltarr( nsrc_tot, nbin )
              trns(0:nsrc-1,*)    = trns1

              if FORMAT eq 'ASPECTS' then begin
                   for i=0,nsrc_extra-1 do $
                        trns(nsrc+i,*) = COLLF( module, srcRA(i), $
                                         srcDEC(i), RAY, DEY, RAZ, DEZ )

              endif else begin
                   if nmjfs gt 1 then begin
                        for i=0,nsrc_extra-1 do begin
                             trns(nsrc+i,*) = $
                                  GET_TRNS( module, nbin, srcRA(i), $
                                           srcDEC(i), RAY, DEY, RAZ, DEZ )
                        endfor
                   endif else begin
                        print,'WARNING: Only ONE MJF in this scan -> '+$
                              'Cannot determine transmissions for '+$
                              'extra sources.'

                        trns(nsrc:nsrc_tot-1,*) = $
                                  REPLICATE(0.,nsrc_extra,nbin)
                   endelse
              endelse
           end

           ( nsrc_extra eq -1 ) : $   ;   USER-interactively defined sources
           begin

              trn_src   = trns1(0,*)
              srcRA     = data(0).srcRA(0)
              srcDEC    = data(0).srcDEC(0)

              src       = { $
                             trn: trn_src, $
                              RA: srcRA,   $
                             DEC: srcDEC   $
                          }
              sat       = { $
                             RAY: RAY, $
                             DEY: DEY, $
                             RAZ: RAZ, $
                             DEZ: DEZ  $
                          }

              othersrc  = FINDSRC( module, cts, src, sat, MJFS=Mjfs )
              sother    = size( othersrc )
              nother    = N_ELEMENTS( othersrc )
              if (nother eq 1) and (sother(0) eq 0) then nother = 0

              if nother gt 0 then begin
                   nsrc_tot                 = nsrc + nother
                   trns                     = fltarr( nsrc_tot, nbin )
                   trns(0:nsrc-1,*)         = trns1

                   iother                   = nsrc + indgen( nother )
                   trns(iother,*)           = transpose( othersrc.trns )
                   bkkping.name( iother )   = othersrc.name
                   srcRA                    = othersrc.RA
                   srcDEC                   = othersrc.DEC
                   name                     = [name(0), othersrc.name ]

                   nsrc                     = nsrc_tot
                   bkkping.nsrc( npass )    = nsrc
                   bkkping.name( 0:nsrc-1 ) = name
              endif else $
                   trns                     = trns1
           end

           else                 : trns = trns1
         ENDCASE


;   Make deadtime correction to the data

         if keyword_set( DEADTIME ) then $
              cts  = DEADCORR( mode,cts, EXTENDED=( Deadtime-1 ) )

;   Determine the fit parameters for this scan

         FITSCAN, Cts, Trns, Degree, NOTRNS=Notrns, OCOEFF=Ocoeff, $
                  OSIGMA=Osigma, OFIT=Ofit, ORCHISQ=Orchisq, OGLITCH = Oglitch

         if FORMAT ne 'DIRS' then begin
              data_keep.intensity(0:nsrc_tot-1,npass) = ocoeff.intensity
              data_keep.sigma(0:nsrc_tot-1,npass)     = osigma.intensity
         endif
         data_keep.bkd_coeff(*,npass)  = ocoeff.bkd

;   Apply FIDUCIAL cuts

         cut = 'FAILED'

;=====================================================================;
;                                                                     ;
;   CUT #1 : 320 ms mode: allow only a few glitches in the            ;
;                         background region                           ;
;              5 ms mode: skip cut                                    ;
;                                                                     ;
;---------------------------------------------------------------------;

         if mode eq 320 then $
         if Oglitch.nbkd gt 5 then begin
              print,'FAILED bkd glitch CUT #1:',oglitch.nbkd
              goto, FAIL
         endif

;=====================================================================;
;                                                                     ;
;   CUT #2 : 320 ms mode: NO glitches allowed in the signal region    ;
;              5 ms mode: skip cut                                    ;
;                                                                     ;
;---------------------------------------------------------------------;

         if mode eq 320 then $
         if oglitch.nsig gt 0 then begin
              print,'FAILED sig glitch CUT #2:',oglitch.nsig
              goto, FAIL
         endif


;=====================================================================;
;                                                                     ;
;   CUT #3 : Test for the goodness of fit in the background region    ;
;                                                                     ;
;---------------------------------------------------------------------;

         if orchisq.bkd gt 2. then begin
              print,'FAILED bkd chisq CUT #3:',orchisq.bkd
              goto, FAIL
         endif

;=====================================================================;
;                                                                     ;
;   CUT #4 : Test for the goodness of fit in the signal region        ;
;                                                                     ;
;---------------------------------------------------------------------;

         if orchisq.sig gt 10. then begin
              print,'FAILED sig chisq CUT #4:',orchisq.sig
              goto, FAIL
         endif

;=====================================================================;
;                                                                     ;
;   CUT #5 : The background must be fairly flat                       ;
;                                                                     ;
;---------------------------------------------------------------------;

         slope = OCOEFF.bkd(1)
         if abs(slope) gt 0.2 then begin
              print,'FAILED slope CUT #5:',abs(slope)
              goto, FAIL
         endif

;=====================================================================;
;                                                                     ;
;   CUT #6 : Background rate cannot be too HIGH                       ;
;                                                                     ;
;---------------------------------------------------------------------;

         bkd_cut   = (312.5*mode*1.E-3)     ;100 counts/bin in 320 ms mode
         bkd_avg   = TOTAL( Ofit.bkd )/N_ELEMENTS( Ofit.bkd )
         if bkd_avg gt bkd_cut then begin
              print,'FAILED bkd rate CUT #6:',bkd_avg
              goto, FAIL
         endif


;   Passed all fiducial cuts

         cut       = 'PASSED'
         pass_all  = 1

FAIL:    mjfscan = mjf + indgen( nmjfs )

         Title=cut+': MJF(s):'+arr2str( mjfscan )
         print,TITLE+' npass:'+strtrim(npass+(  pass_all),2)+$
                     ' nfail:'+strtrim(nfail+(1-pass_all),2)

;        Save data for XF_ACCEPT, XF_REJECT and XF_PRINT

         Is   = data_keep.intensity(0:nsrc_tot-1,npass)
         sigIs= data_keep.sigma(0:nsrc_tot-1,npass)
         names= name
         if nsrc_extra gt 0 then names= [name,name_extra]
         legstr  = LCLEGEND( names, Is, sigIs )

         lcdata = { Cts:Cts, $
                    Trns:Trns, $
                    ofit:Ofit, $
                    Title:Title, $
                    Legend:legstr, $
                    Data:data }
         Data = 0  ;free up some memory

         if (mjf lt idl.mjf_cutoff) and (idl.lt_curv eq 2) then goto, NO_PLOT

         LC = LT_CURV
         CASE cut OF
              'PASSED'  : if ((LC eq 2) or (LC eq 1)) then goto, PLOT_LC
              'FAILED'  : if ((LC eq 3) or (LC eq 1)) then goto, PLOT_LC
              'EXCLUDED':
         ENDCASE

NO_PLOT: if pass_all then XF_ACCEPT $
         else XF_REJECT
         return, 0                   ;No light curve plotted,
                                     ;  move onto the next scan.

PLOT_LC: LIGHT_CURVE, Cts, Trns, Ofit.data, TITLE=title, LEGEND=legstr

         return, 1                   ;Light curve plotted,
                                     ;  query USER for FINAL cut.
end

;========= END XF_NEXT_SCAN routines ===================================

;========= BEGIN XF_ACCEPT routines ====================================
;
;   This routine is called if either the scan has PASSED the Fiducial
;   cuts or the USER has selected to ACCEPT the scan. Pointers are updated,
;   barycentric time corrections are made and a reduced set of the scan (the
;   signal region) are stored in the appropriate structure buffers.
;
pro XF_ACCEPT

         common DATA_COM, bkkping, data_keep
         common LC_COM, lcdata

;   Extract common variables

         data      = lcdata.data
         Cts       = lcdata.Cts
         Trns      = lcdata.Trns
         Ofit      = lcdata.Ofit
         lcdata    = 0            ;free up some memory

;   Extract bookkeeping keywords

         FORMAT    = bkkping.Format

;   and some pointers...

         npass     = bkkping.npass
         nfail     = bkkping.nfail
         data_ptr  = bkkping.data_ptr
         nsrc_extra= bkkping.nsrc_extra

;   Extract relevant Data structures
;   common to all Formats...

         mode      = data(0).mode
         nsrc      = data(0).nsrc
         nsrc_tot  = nsrc + (nsrc_extra > 0)
         mjfs      = data.mjf
         mjf       = mjfs(0)
         nmjfs     = n_elements( data )
         nbin_mjf  = data(0).nbin
         nbin      = nmjfs*nbin_mjf
         name_extra= bkkping.name_extra

;   and those depending on a particular to a file format

         if FORMAT eq 'ASPECTS' then begin
              yasp      = [data(0).RAY,data(0).DEY]   ;get the Satellite's
              zasp      = [data(0).RAZ,data(0).DEZ]   ;aspects at the beginning
              data_keep.aspects.y(*,npass) = yasp     ;of the scan
              data_keep.aspects.z(*,npass) = zasp
         endif

         t77i      = data.t77i
         t77f      = data.t77f

         if nsrc_extra gt 0 then begin
              ddtor     = !dpi/180.d0
              srcRA     = bkkping.RA_extra*ddtor
              srcDEC    = bkkping.DEC_extra*ddtor
         endif


;   Determine the barycentric time corrections of any additional sources
;   provided by the ADDITIONAL_SOURCES keyword

         CASE 1 OF
           (FORMAT eq 'ASPECTS')  : $
              begin
                   ncorr     = nsrc_tot
                   tcorr     = data.t77c
                   tcorr     = REFORM( tcorr,2,1,nmjfs )

                   if nsrc_extra ne 0 then begin

                        JD77 = 43144.D0  ; Modified Julian date
                                         ; of 00:00 1/1/77 [days]

                        JDMJF= JD77 - 1.D0 + $
                               (double(t77i) + double(t77f))/86400.D0
                        JDMJF1=JD77 - 1.D0 + $
                               (double(t77i) + $
                                double(t77f) + 40.96D0)/86400.D0

                        tc_src              = tcorr
                        nsrc_data           = n_elements(tcorr)/nmjfs/2
                        nsrc_add            = nsrc_tot - nsrc_data
                        tcorr               = dblarr(2,nsrc_tot,nmjfs)
                        tcorr(*,0:nsrc_data-1,*) = tc_src

                        satXYZ    = data.sat.xyz   ; 3 x 2 x nmjfs
                        for j=0,nmjfs-1 do begin
                        for i=0,nsrc_add-1 do begin
                            SLACS2C, srcRA(i), srcDEC(i), srcXYZ

                            tc_beg=BARYCORR(srcXYZ,satXYZ(*,0,j),JDMJF(j) )
                            tc_end=BARYCORR(srcXYZ,satXYZ(*,1,j),JDMJF1(j))

                            tcorr(0,nsrc_data+i,j)   = tc_beg
                            tcorr(1,nsrc_data+i,j)   = tc_end
                        endfor
                        endfor
                   endif
              end
           (FORMAT eq 'STANDARD') : $
              begin
                   ncorr     = nsrc
                   tcorr     = data.t77c
                   if nsrc eq 1 then tcorr= REFORM( tcorr,2,1,nmjfs )
              end
            else                  : tcorr   = 0  ;Undefined for other formats
         ENDCASE

;   Interpolate the barycentric time corrections at the beginning
;   and end of the transmission function for each source.  If the
;   source is outside the field of view (trans=0 for all bins),
;   then its barycentric time correction = 0.

         if ncorr gt 0 then begin

              tc_fit= dblarr( 2,ncorr )
              for isrc  = 0,ncorr-1 do begin

;   First fit a line to the barycentric corrections
;   We'll choose the convention of letting the bin number be located
;   at the left bin edge.

                   i         = indgen(nmjfs)
                   bin_pts   = (i+1.) * nbin_mjf
                   bin_pts   = [0,bin_pts]
                   tc_pts    = REFORM( tcorr(1,isrc,i) )
                   tc_pts    = [tcorr(0,isrc,0),tc_pts]

                   coeffs    = POLY_FIT( bin_pts, tc_pts, 1 )
                   b         = coeffs(0)
                   mx        = coeffs(1)
                   here_sig  = WHERE( trns(isrc,*) gt 0, nsig )
                   if nsig gt 0 then begin
                        tc_fit(0,isrc)= mx * here_sig(0) + b
                        tc_fit(1,isrc)= mx * here_sig(nsig-1) + b
                   endif
              endfor

              data_keep.tcorr( *,0:ncorr-1,npass ) = tc_fit

         endif

         if (FORMAT eq 'DIRS') then begin
              phis      = reform( data.phis, nbin )
              thts      = reform( data.thts, nbin )
         endif


;   Extract only signal region

         sig  = Cts - Ofit.bkd

         trns_tot = TOTAL( Trns, 1 )
         here_sig = where( trns_tot gt 0, nsig )

         j0   = data_ptr
         j1   = j0 + long(nsig) - 1L

         data_keep.nsig( npass )                 = nsig
         data_keep.trns( 0:nsrc_tot-1, j0:j1 )   = trns( *, here_sig )
         data_keep.sig ( j0:j1 )                 = sig( here_sig )
         data_keep.cts ( j0:j1 )                 = cts( here_sig )
         data_keep.bkd ( j0:j1 )                 = ofit.bkd( here_sig )

         for i=0,nsrc_tot-1 do begin
              here_sig_src = where( Trns( i,* ) gt 0,nsig_src )
              data_keep.nsig_src( i,npass )      = nsig_src
         endfor
         data_keep.overlap( *,npass )  = OVERLAP( Trns )


         if FORMAT eq 'DIRS' then begin
              data_keep.phis( j0:j1 )       = phis( here_sig )
              data_keep.thts( j0:j1 )       = thts( here_sig )
         endif

;   Extract bins and times at the transmission peak of all the sources

         dt        = double( mode/1000.d )
         for i=0,nsrc_tot-1 do begin
              tmax      = MAX( trns(i,here_sig), pk_bin )

              tmax      = MAX( trns(i,*), ctr_bin )
              toff      = double( ctr_bin * dt )   ;offset to center
              toffi     = long( toff )             ;of transmission
              tofff     = double(toff - toffi)

              tsrci     = t77i(0) + toffi
              tsrcf     = t77f(0) + tofff

              if tsrcf gt 1 then begin
                   tint      = long( tsrcf )
                   tsrci     = tsrci + tint
                   tsrcf     = tsrcf - tint
              endif

              data_keep.pk_bins( i, npass ) = pk_bin
              data_keep.pk_trns( i, npass ) = tmax
              data_keep.t77i( i, npass )    = tsrci
              data_keep.t77f( i, npass )    = tsrcf

         endfor

         npass     = npass   + 1
         data_ptr  = data_ptr+ long( nsig )

         bkkping.npass       = npass
         bkkping.data_ptr    = data_ptr

end

;========= END XF_ACCEPT routines ======================================

;========= BEGIN XF_REJECT routines ====================================
;
;   This routine is called if either the scan has FAILED the Fiducial
;   cuts or the USER has selected to REJECT the scan. Pointers are updated.
;
pro XF_REJECT

         common DATA_COM, bkkping, data_keep
         common LC_COM, lcdata

         mjfs      = lcdata.data.mjf
         mjf       = mjfs(0)
         lcdata    = 0            ;free up some memory

         nmark                    = bkkping.nmark
         bkkping.mjf_mark( nmark )= mjf
         bkkping.nmark            = nmark + 1

         bkkping.nfail            = bkkping.nfail + 1

end

;========= END XF_REJECT routines ======================================


;========= BEGIN XF_PRINT routines ====================================
;
;   This routine "prints" the current light curve
;
pro XF_PRINT

         common LC_COM, lcdata

         Cts  = lcdata.Cts
         Trns = lcdata.Trns
         Ofit = lcdata.Ofit
         title= lcdata.title
         legend=lcdata.legend

         LANDSCAPE, 'PS'
         LIGHT_CURVE, Cts, Trns, Ofit.data, $
                      TITLE=title, LEGEND=legend, $
                      /WHITE_BKD
         LANDSCAPE, /CLOSE, /HARDCOPY

end

;========= END XF_REJECT routines ======================================


;========= BEGIN XF_QUIT routines ======================================
;
;   This routine is called when quitting the Fiducial APPLY routine
;
pro XF_QUIT, GROUP=Group

         ck   = YNCANCEL('Quit to Fiducial Main Menu?', $
                          TITLE='Fiducial WARNING', GROUP=Group )

         if ck ne 1 then return

         dummy = EXECUTE('WIDGET_CONTROL, Group, /DESTROY')

         END_SCAN
         CLEAR_SCAN

         LCLOADCT, /UNLOAD
end

;========= END XF_QUIT routines ========================================

;========= BEGIN XF_NEXT_LC routines ===================================
;
;   This routine checks to make sure the end of the IDL data file has
;   not been reached and that the number of data points has not extended
;   beyond parameter boundaries
;
pro XF_NEXT_LC, GROUP=Group, ALL=All

         common XF_CUT_COM, Main_ID

         common INIT_COM, idl, extra, bad, files
         common DATA_COM, bkkping, data_keep

         WIDGET_CONTROL, /HOURGLASS
         nscan     = 0
         max_nscan = idl.max_nscan

         marker    = 1-2*keyword_set(All)
         repeat begin
              eofb  = XF_NEXT_SCAN()
              nscan = nscan + 1
         endrep until (( eofb eq marker ) OR ( nscan gt max_nscan ))

         if ((nscan gt max_nscan) and (eofb ne -1) ) then begin
              xmsg,'Exceeded the maximum number of scans'+$
                   'that the data store buffer will hold.',$
                   TITLE='Fiducial WARNING', $
                   GROUP=Group
         endif

         if (eofb eq -1) then begin
              xmsg,'Reached end of file.',$
                   TITLE='Fiducial Message',$
                   GROUP=Group
         endif
end

;========= END XF_NEXT_LC routines =====================================


;========= BEGIN XF_SAVE_SESSION routines ==============================
;
;   This routine handles saving the results from the analysis to an
;   IDL session file.  All the various pieces of information are
;   synthesized here into one structure variable named "data"
;
pro XF_SAVE_SESSION, GROUP=Group

         common INIT_COM, idl, extra, bad, files
         common DATA_COM, bkkping, data_keep

         idl_file  = files.idl
         pos0      = strpos( strupcase(idl_file), 'DATA' ) + 5
         pos1      = strpos( idl_file, '.' )

         namelen   = pos1 - pos0
         name      = strmid( idl_file, pos0, namelen )+'.sav'

         WIDGET_CONTROL,/HOURGLASS
         ; Get IDL session filename
         defsysv,'!SAVE_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!SAVE_PATH',''
         File = pickfile( PATH=!SAVE_PATH, FILTER='*.sav', $
                FILE=!SAVE_PATH+name, $
                TITLE='Select Name of the IDL Session File', $
                GROUP=Group )

         if File eq '' then return
         delim = RSTRPOS(File,'\')
         if (delim eq -1) then delim = RSTRPOS(File,'/')
         if (delim ne -1) then defsysv,'!SAVE_PATH',STRMID(File,0,delim+1)

         WIDGET_CONTROL,/HOURGLASS

;   Extract common variables

         MJF_rng   = idl.MJF_rng
         Bad_MJFs  = bad.MJFs
         Notrns    = idl.notrns
         Lt_curv   = idl.lt_curv
         Deadtime  = idl.deadtime
         Version   = idl.version

         mode      = bkkping.mode
         module    = bkkping.module
         npass     = bkkping.npass
         nfail     = bkkping.nfail
         nscan     = npass + nfail
         nbin      = bkkping.data_ptr
         nsrc_extra= bkkping.nsrc_extra
         nsrc      = bkkping.nsrc
         if nsrc_extra ne -1 then begin       ;same # of sources for each scan
              nsrc      = nsrc(0)
              nsrc_max  = nsrc + nsrc_extra
              nsrc_scan = nsrc_max
         endif else begin                     ;diff # of sources for each scan
              nsrc_max  = MAX(nsrc)
              nsrc_scan = nsrc
              dbclose,'xxx'
         endelse
         name1     = bkkping.name(0:nsrc-1)   ;BUGFIX: 2/8/95 (nsrc_max->nsrc)
         if nsrc_extra gt 0 then $
              name = [name1,bkkping.name_extra] $
         else $
              name = [name1]
         degree    = bkkping.degree
         format    = bkkping.FORMAT

         if npass eq 0 then goto, NODATA

         mjfs      = data_keep.mjfs(  0:npass-1 )
         nmjfs     = data_keep.nmjfs( 0:npass-1 )
         nsig      = data_keep.nsig(  0:npass-1 )
         nsig_src  = data_keep.nsig_src( 0:nsrc_max-1, 0:npass-1 )
         sig       = data_keep.sig( 0:nbin-1L )
         cts       = data_keep.cts( 0:nbin-1L )
         bkd       = data_keep.bkd( 0:nbin-1L )
         bkd_coeff = data_keep.bkd_coeff( 0:degree, 0:npass-1 )
         trns      = data_keep.trns( 0:nsrc_max-1, 0:nbin-1L )
         intensity = data_keep.intensity( 0:nsrc_max-1, 0:npass-1 )
         sigma     = data_keep.sigma(     0:nsrc_max-1, 0:npass-1 )
         pk_bins   = data_keep.pk_bins( 0:nsrc_max-1, 0:npass-1 )
         pk_trns   = data_keep.pk_trns( 0:nsrc_max-1, 0:npass-1 )
         overlap   = data_keep.overlap( 0:nsrc_max-1, 0:npass-1 )
         t77i      = data_keep.t77i( 0:nsrc_max-1, 0:npass-1 )
         t77f      = data_keep.t77f( 0:nsrc_max-1, 0:npass-1 )

         mjfs      = [mjfs]                 ;Need the square brackets to
         nmjfs     = [nmjfs]                ;take care of 1-element cases
         nsig      = [nsig]
         nsig_src  = TRANSPOSE([nsig_src])
         bkd_coeff = TRANSPOSE([bkd_coeff])
         trns      = TRANSPOSE([trns])
         intensity = TRANSPOSE([intensity])
         sigma     = TRANSPOSE([sigma])
         pk_bins   = TRANSPOSE([pk_bins])
         pk_trns   = TRANSPOSE([pk_trns])
         overlap   = TRANSPOSE([overlap])
         t77i      = TRANSPOSE([t77i])
         t77f      = TRANSPOSE([t77f])

         if not keyword_set( MJF_RNG(1)) then MJF_rng = long(0)
         if not keyword_set( BAD_MJFS ) then Bad_MJFs= long(0)
         if not keyword_set( NOTRNS   ) then Notrns  = 0
         if not keyword_set( DEADTIME ) then deadtime= 0

;   Pack all this information into a data structure
;   common to all formats...

         Data =   {      mode  : mode,      $
                       module  : module,    $
                        npass  : npass,     $
                        nfail  : nfail,     $
                        nscan  : nscan,     $
                         nbin  : nbin,      $
                         nsig  : nsig,      $
                     nsig_src  : nsig_src,  $    ;Added in version 5.0
                         nsrc  : nsrc_scan, $
                         name  : name,      $
                       degree  : degree,    $
                         mjfs  : mjfs,      $
                        nmjfs  : nmjfs,     $
                          sig  : sig,       $
                          cts  : cts,       $
                          bkd  : bkd,       $
                    bkd_coeff  : bkd_coeff, $    ;Added in version 6.0
                         trns  : trns,      $
                      pk_bins  : pk_bins,   $
                      pk_trns  : pk_trns,   $    ;Added in version 4.0
                      overlap  : overlap,   $    ;Added in version 5.0
                         t77i  : t77i,      $
                         t77f  : t77f,      $
                      MJF_RNG  : MJF_rng,   $
                     Bad_MJFS  : Bad_MJFS,  $
                       FORMAT  : Format,    $
                       NOTRNS  : Notrns,    $
                     DEADTIME  : deadtime,  $
                      VERSION  : version    $
                  }


;   particular to each format...

         CASE 1 OF

            (FORMAT eq 'ASPECTS')  : begin
                  tcorr     = data_keep.tcorr(  *, 0:nsrc_max-1, 0:npass-1 )
                  tcorr0    = REFORM(tcorr(  0, 0:nsrc_max-1, 0:npass-1 ))
                  tcorr1    = REFORM(tcorr(  1, 0:nsrc_max-1, 0:npass-1 ))
                  tcorr     = dblarr( 2, npass, nsrc_max )
                  tcorr(0,*,*) = TRANSPOSE( tcorr0 )
                  tcorr(1,*,*) = TRANSPOSE( tcorr1 )
                  aspects        = {y:dblarr( 2,npass ), z:dblarr(2,npass)}
                  aspects.y(*,*) = data_keep.aspects.y(*,0:npass-1)
                  aspects.z(*,*) = data_keep.aspects.z(*,0:npass-1)
                  Data = CREATE_STRUCT( Data, $
                         'intensity',intensity,   $
                         'sigma'    ,sigma,       $
                         'tcorr'    ,tcorr,       $
                         'aspects'  ,aspects      )   ;Added in version 4.0
             end

            (FORMAT eq 'STANDARD') : begin
                  tcorr     = data_keep.tcorr(  *, 0:nsrc_max-1, 0:npass-1 )
                  tcorr0    = REFORM(tcorr(  0, 0:nsrc_max-1, 0:npass-1 ))
                  tcorr1    = REFORM(tcorr(  1, 0:nsrc_max-1, 0:npass-1 ))
                  tcorr     = dblarr( 2, npass, nsrc_max )
                  tcorr(0,*,*) = TRANSPOSE( tcorr0 )
                  tcorr(1,*,*) = TRANSPOSE( tcorr1 )
                  Data = CREATE_STRUCT( Data, $
                                       'intensity',intensity,   $
                                       'sigma'    ,sigma,       $
                                       'tcorr'    ,tcorr        )
             end

            (FORMAT eq 'NOBARY')   : begin
                  Data = CREATE_STRUCT( Data, $
                                       'intensity',intensity,   $
                                       'sigma'    ,sigma        )
             end

            (FORMAT eq 'DIRS')     : begin
                  phis   = data_keep.phis( 0:nbin-1L )
                  thts   = data_keep.thts( 0:nbin-1L )
                  Data = CREATE_STRUCT( Data, $
                                       'phis',phis,   $
                                       'thts',thts    )
             end
             ELSE    : message,'Invalid format.'
         ENDCASE

;   Finally, save the IDL session file

         SAVE, data, FILENAME=File
         data   = 0     ;free up memory

         xmsg, ['IDL session file:'+File,' ','Saved.'], $
               TITLE='Fiducial Message', $
               GROUP=Group

         return
NODATA:  message,'No scans passed fiducial cuts',/INF
         xmsg, ['No scans passed fiducial cuts.',$
                'IDL session file NOT saved.' ], $
                TITLE='Fiducial WARNING', $
                GROUP=Group

end

;========= END XF_SAVE_SESSION routines ================================

;========= BEGIN XF_SAVE_LIST routines =================================
;
;   This routine handles writing out a list of first major frame numbers of
;   scans that were EXCLUDED, FAILED the fiducial cuts, and/or REJECTED
;   by the USER
;
pro XF_SAVE_LIST, GROUP=Group

         common INIT_COM, idl, extra, bad, files
         common DATA_COM, bkkping, data_keep

         idl_file  = files.idl
         pos0      = strpos( strupcase(idl_file), 'DATA' ) + 5
         pos1      = strpos( idl_file, '.' )

         namelen   = pos1 - pos0
         name      = strmid( idl_file, pos0, namelen )+'.bad'

         WIDGET_CONTROL,/HOURGLASS
         ; Get IDL session filename
         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         File = pickfile( PATH=!DATA_PATH, FILTER='*.bad', $
                FILE =!DATA_PATH+name, $
                TITLE='Select Name of the Bad MJFs File', $
                GROUP=Group )

         if File eq '' then return
         if (!DATA_PATH eq '') then begin
              delim = RSTRPOS(File,'\')
              if (delim eq -1) then delim = RSTRPOS(File,'/')
              if (delim ne -1) $
              then defsysv,'!DATA_PATH',STRMID(File,0,delim+1)
         endif

         WIDGET_CONTROL,/HOURGLASS

;   Extract common variables

         nmark     = bkkping.nmark
         if nmark eq 0 then begin
              message,'No Bad MJFs',/INF
              xmsg,['No Bad MJFs.',$
                    'Bad MJFs file NOT saved.'],$
                    TITLE='Fiducial Message',$
                    GROUP=Group
              return
         endif

         Bad_MJFs  = bkkping.mjf_mark( 0:nmark-1 )

         nbad = N_ELEMENTS( Bad_MJFs )

         openw, lun, File, /GET_LUN
         for i=0,nbad-1 do $
              printf, lun, Bad_MJFs(i)

         close, lun
         free_lun, lun

         xmsg, ['Bad MJFs file:'+File,' ','Saved.'], $
               TITLE='Fiducial Message',$
               GROUP=Group

end

;========= END XF_SAVE_LIST routines ===================================

;========= BEGIN XF_RESULTS_STATS routines =============================
;
;   This routine displays a cursory summary of the data analysis of
;   the current IDL data file
;
pro XF_RESULTS_STATS, GROUP=Group
         common INIT_COM, idl, extra, bad, files
         common DATA_COM, bkkping, data_keep

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         lt_curv = [ $
                   'None',$
                   'All',$
                   'Passed',$
                   'Failed',$
                   'Passed after MJF cutoff' $
                   ]

         deadtime= [ $
                   'None',$
                   'Non-paralyzable',$
                   'Paralyzable'$
                   ]

         trn_reg = [ $
                   'Include',$
                   'Exclude' $
                   ]

         mode      = bkkping.mode
         module    = bkkping.module
         npass     = bkkping.npass
         nfail     = bkkping.nfail
         nscan     = npass + nfail
         nbin      = bkkping.data_ptr
         nsrc_extra= bkkping.nsrc_extra
         nsrc      = bkkping.nsrc
         if nsrc_extra ne -1 then begin       ;same # of sources for each scan
              nsrc      = nsrc(0)
              nsrc_max  = nsrc + nsrc_extra
              nsrc_scan = nsrc_max
         endif else begin                     ;diff # of sources for each scan
              nsrc_max  = MAX(nsrc)
              nsrc_scan = nsrc
              dbclose,'xxx'
         endelse

         if npass gt 0 then begin
              intensity = data_keep.intensity( 0:nsrc_max-1, 0:npass-1 )
              avgI = TOTAL( intensity(0,*) )/npass
         endif else $
              avgI = 0.0

         lc_set = idl.lt_curv
         if (lc_set eq 2) and (idl.mjf_cutoff gt 0) then lc_set=4
         list = [ $
              'IDL data file: '+files.IDL, $
              'Additional Source(s) file: '+files.add, $
              'Excluded MJFs file: '+files.bad, $
              'Light curve: '+lt_curv( lc_set ), $
              'MJF cutoff: '+strtrim( idl.mjf_cutoff,2 ), $
              'MJF range: ['+arr2str( idl.mjf_rng )+']',$
              'Deadtime: '+deadtime( idl.deadtime ), $
              'Transmission regions: '+trn_reg( idl.notrns ), $
              'Degree of background polynomial: '+strtrim( idl.degree,2 ), $
              ' ',$
              'Timing mode:'+strtrim( mode,2 ), $
              'Module:'+strtrim( mode,2 ), $
              'Number of scans PASSED:'+strtrim( npass,2 ), $
              'Number of scans FAILED:'+strtrim( nfail,2 ), $
              'Total number of scans:'+strtrim( nscan,2 ), $
              'Total number of data bins:'+strtrim( nbin,2 ), $
              'Total number of sources:'+strtrim( fix(nsrc_scan),2 ), $
              'Average intensity for primary source:'+strtrim( avgI,2 ) ]

         XMSG, list, /ALIGN, TITLE='Fiducial Results', GROUP=Group
end

;========= END XF_RESULTS_STATS routines ===============================


;========= BEGIN XF_RESULTS_HELP routines ==============================
;
;   This collection of widget routines handles all the Help options from
;   the Fiducial RESULTS Menu and all its submenus
;
pro XF_RESULTS_HELP, Ev, GROUP=Group
         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         CASE Ev OF
         'File.Help': BEGIN
              Title  = 'Fiducial Help [Topic: RESULTS MENU]'
              Topics = [$
                   'Save IDL session file',$
                   'Save Bad MJFs list',$
                   'Quit',$
                   'Help']

              Descrs = [$
                   '    Select this option to save an IDL session file.',$
                   'A structure, named "data" will be saved and it contains',$
                   'information about each scan that passes the fiducial',$
                   'cuts and the USER''s final cut on selected light curves.',$
                   '',$
                   '    To see what is contained in the "data" structure, ',$
                   'please select FIDUCIAL or FIDUCIAL using the IDL Online',$
                   'Help, under the HANWEN topic.',$

                   '    Select this option to write out a list of major frame',$
                   'numbers corresponding to the first major frame of every',$
                   'scan that were EXCLUDED or FAILED the fiducial cuts and ',$
                   'the USER''s final cut on selected light curves.',$

                   'Return to the Fiducial Main Menu.', $

                   'Sorry, no other additional Help available for this topic.']

              Nlines = [ 8, 4, 1, 1 ]
              END

         'Help': BEGIN
              Title  = 'Fiducial Help [Topic: RESULTS MENU]'
              Topics = [$
                   'File',$
                   'Stats',$
                   'Help']

              Descrs = [$
                   '    This is a pulldown menu from which you may either ',$
                   'select to save various files for the results of the ',$
                   'data analysis or Quit to the Fiducial Main Menu.',$
                   '(Select Help under this File menu for more information).',$

                   '    Select this button to display a summary of results ',$
                   'for the analysis of this IDL data file.',$

                   '    You have reached the end of the data analysis for this',$
                   'IDL data file.  You may save the work that has been done ',$
                   'or return to the Fiducial Main Menu by selecting the File',$
                   'pulldown menu or display a summary of the results by ',$
                   'selecting Stats.']

              Nlines = [ 4, 2, 5 ]
              END

         ENDCASE
         XHELPMSG, Topics, Descrs, Nlines, TITLE=Title, GROUP=Group
end

;========= END XF_RESULTS_HELP routines ================================

;========= BEGIN XF_RESULTS routines ===================================
;
;   This collection of widget routines handles the Fiducial RESULTS Menu
;   which is brought up after the fiducial cuts have been applied to the
;   entire IDL data file
;
pro PDMENU_RESULTS_Event, Event


         help_event = 0
         CASE Event.Value OF

         'File.Save IDL session file': XF_SAVE_SESSION, GROUP=Event.Top
         'File.Save Bad MJFs list': XF_SAVE_LIST, GROUP=Event.Top
         'File.Quit': dummy = EXECUTE('WIDGET_CONTROL, Event.Top, /DESTROY')
         'File.Help': help_event=1
         'Stats': XF_RESULTS_STATS, GROUP=Event.Top
         'Help': help_event=1
         ENDCASE

         if help_event then XF_RESULTS_HELP, Event.Value, GROUP=Event.Top
end


pro MAIN_RESULTS_Event, Event


         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF
         'PDMENU_RESULTS': PDMENU_RESULTS_Event, Event
         ENDCASE
end


pro XF_RESULTS, GROUP=Group


         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         junk   = { CW_PDMENU_S, flags:0, name:'' }


         MAIN_RESULTS = WIDGET_BASE(GROUP_LEADER=Group, $
             /ROW, $
             /MAP, $
             TITLE='Fiducial Results Menu', $
             UVALUE='MAIN_RESULTS')

         MenuDesc313 = [ $
             { CW_PDMENU_S,       1, 'File' }, $ ;    0
               { CW_PDMENU_S,       0, 'Save IDL session file' }, $ ; 1
               { CW_PDMENU_S,       0, 'Save Bad MJFs list' }, $ ;    2
               { CW_PDMENU_S,       0, 'Quit' }, $ ;  3
               { CW_PDMENU_S,       2, 'Help' }, $ ;  4
             { CW_PDMENU_S,       0, 'Stats' }, $ ;   5
             { CW_PDMENU_S,       2, 'Help' } $  ;    6

         ]


         PDMENU_RESULTS = CW_PDMENU( MAIN_RESULTS, MenuDesc313, $
              /RETURN_FULL_NAME, UVALUE='PDMENU_RESULTS')

         WIDGET_CONTROL, MAIN_RESULTS, /REALIZE

         XMANAGER, 'MAIN_RESULTS', MAIN_RESULTS
end

;========= END XF_RESULTS routines =====================================

;========= BEGIN XF_CUT_HELP routines ==================================
;
;   This collection of widget routines handles all the Help options from
;   the Fiducial FINAL CUT Menu and all its submenus
;
pro XF_CUT_HELP, GROUP=Group

         Title = 'Fiducial Help [Topic: FINAL CUT MENU]'

         Topics = [$
              'Accept',$
              'Reject',$
              'Print',$
              'Save and Quit',$
              'Quit',$
              'Help']

         Descrs = [$
              'Accept this scan and continue on applying fiducial cuts',$
              'to the next scan in the IDL data file.',$
              'Reject this scan and continue on applying fiducial cuts',$
              'to the next scan in the IDL data file.',$
              'Print this scan.',$
              'End analysis of this data file and bring up the RESULTS MENU',$
              'menu to select what information to save to file.',$
              'End analysis of this data file and return to the MAIN MENU.',$
              'Sorry, no other additional Help available for this topic.']

         Nlines= [ 2, 2, 1, 2, 1, 1 ]

         XHELPMSG, Topics, Descrs, Nlines, TITLE=Title, GROUP=Group
end

;========= END XF_CUT_HELP routines ====================================

;========= BEGIN XF_CUT routines =======================================
;
;   This collection of widget routines handles the Fiducial FINAL CUT Menu
;   which is brought up according to which light curves the USER has
;   selected to be displayed.
;
PRO PDMENU_CUT_Event, Event

         common XF_CUT_COM, Main_ID

         WIDGET_CONTROL, /HOURGLASS

         CASE Event.Value OF

         'Accept': BEGIN
           XF_ACCEPT
           XF_NEXT_LC, GROUP=Event.Top
           END
         'Reject': BEGIN
           XF_REJECT
           XF_NEXT_LC, GROUP=Event.Top
           END
         'Print': XF_PRINT
         'Save and Quit': BEGIN
           dummy = EXECUTE('WIDGET_CONTROL, Event.Top, /DESTROY')
           WIDGET_CONTROL, Main_ID, /SHOW
           END_SCAN
           CLEAR_SCAN
           LCLOADCT, /UNLOAD
           XF_RESULTS, GROUP=Main_ID
           END
         'Quit': BEGIN
           XF_QUIT, GROUP=Event.Top
           WIDGET_CONTROL, Main_ID, /SHOW
           END
         'Help': XF_CUT_HELP, GROUP=Event.Top
         ENDCASE

END

PRO MAIN_CUT_Event, Event

         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF

         'DRAW_XF_CUT':
         ; Event for PDMENU_CUT
         'PDMENU_CUT': PDMENU_CUT_Event, Event
         ENDCASE
END



PRO XF_CUT, GROUP=Group


         common XF_CUT_COM, Main_ID
         common INIT_COM, idl, extra, bad, files

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0
         Main_ID = Group

         junk   = { CW_PDMENU_S, flags:0, name:'' }

         MAIN_CUT = WIDGET_BASE(GROUP_LEADER=Group, $
             /COLUMN, $
             MAP=0, $
             TITLE='Fiducial Final Cut', $
             UVALUE='MAIN_CUT')

         DEVICE, GET_SCREEN_SIZE=win_sz
         DRAW_XF_CUT = WIDGET_DRAW( MAIN_CUT, $
             RETAIN=2, $
             XSIZE=win_sz(0)-100, $
             YSIZE=win_sz(1)-150, $
             UVALUE='DRAW_XF_CUT')

         BASE3 = WIDGET_BASE(MAIN_CUT, $
             /ROW, $
             /MAP, $
             UVALUE='BASE3')

         MenuDesc222 = [ $
             { CW_PDMENU_S,       0, 'Accept' }, $ ;        0
             { CW_PDMENU_S,       0, 'Reject' }, $ ;        1
             { CW_PDMENU_S,       0, 'Print' }, $ ;         2
             { CW_PDMENU_S,       0, 'Save and Quit' }, $ ; 3
             { CW_PDMENU_S,       0, 'Quit' }, $ ;          4
             { CW_PDMENU_S,       2, 'Help' } $  ;          5

         ]


         PDMENU_CUT = CW_PDMENU( BASE3, MenuDesc222, /RETURN_FULL_NAME, $
             UVALUE='PDMENU_CUT')


         WIDGET_POSITION, MAIN_CUT, /BOTTOM, /LEFT

         XMANAGER, 'MAIN_CUT', MAIN_CUT

         XF_NEXT_LC, GROUP=MAIN_CUT


END

;========= END XF_CUT routines =========================================


;========= BEGIN XF_APPLY routines =====================================
;
;   This collection of widget routines begins the data analysis of the
;   IDL data file by applying fiducial cuts to each scan
;
pro XF_APPLY, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         if (files.idl eq '') then begin
              xmsg,'No data file selected.',$
              TITLE='Fiducial Error',$
              GROUP=Group
              return
         endif

         XF_BUF_INIT

         if (idl.lt_curv gt 0) then begin

              XF_CUT, GROUP=Group  ;Analyze data interactively

         endif else begin     ;No light curve display interaction

              XF_NEXT_LC, Group=Group, /ALL

              END_SCAN
              CLEAR_SCAN
              XF_RESULTS, GROUP=Group

         endelse
end

;========= END XF_APPLY routines =======================================

;========= BEGIN DEF_INIT_COM routines =================================
;
;   This routine defines the default values for the various settings
;   the USER may configure
;
pro DEF_INIT_COM

         common INIT_COM, idl, extra, bad, files

;   Define default settings

         idl = { $
              Format:'', $
              Degree:1, $
              max_nsrc:5, $
              max_nscan:500, $
              max_nbin:100000L, $
              io_unit:0, $
              lt_curv:2, $
              deadtime:1, $
              notrns:0, $
              mjf_rng:[0L,0L], $
              mjf_cutoff:0L,  $
              version:6.0 $
              }

         extra = { $      ;=> No additional sources added
              nsrc:0, $
              name:'', $
              RA:0, $
              DEC:0 $
              }

         bad   = { $      ;=> No bad or to be excluded major frames
              mjfs:0L  $
              }

         files = { $
              IDL:'', $
              add:'', $
              bad:''  $
              }
end

;========= END DEF_INIT_COM routines ===================================

;========= BEGIN XF_FILE_IDL routines ==================================
;
;   This routine gets the filename of the IDL data file by interactively
;   allowing the USER to select the file from a directory listing.
;
pro XF_FILE_IDL, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         WIDGET_CONTROL, /HOURGLASS
         ; Get IDL data file
         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         File = pickfile( /READ, PATH=!DATA_PATH, FILTER='*.idl',$
                          TITLE='Select IDL Data File', $
                          GROUP=Group )
         if File eq '' then return
         if (!DATA_PATH eq '') then begin
              delim = RSTRPOS(File,'\')
              if (delim eq -1) then delim = RSTRPOS(File,'/')
              if (delim ne -1) $
              then defsysv,'!DATA_PATH',STRMID(File,0,delim+1)
         endif

         Fmt  = GET_FMT( File )
         if Fmt eq '' then begin
              xmsg,'Format of data file not recognized.',$
                   TITLE='Fiducial Error',$
                   GROUP=Group
              File = ''
              return
         endif

         dbsfile= strmid( File, 0, strlen( File ) - strlen('idl') ) + 'dbs'
         flist  = findfile( dbsfile, COUNT=nfile )
         if nfile eq 1 then begin
              openr, lun_dbs, dbsfile, /GET_LUN
              hdr   = ''
              readf, lun_dbs, hdr
              pos   = strpos( hdr, ' 320 ')
              if pos ne -1 then nbin = 128L else nbin = 8192L

              nscan = 1
              nmjf  = 1L
              mjf0  = long(strmid( hdr, 7, 6 ))
              repeat begin
                   readf, lun_dbs, hdr
                   nmjf = nmjf + 1L
                   mjf  = long(strmid( hdr, 7, 6 ))
                   if (mjf-mjf0) gt 1 then nscan = nscan + 1
                   mjf0 = mjf
              endrep until EOF(lun_dbs)
              close, lun_dbs
              free_lun, lun_dbs

              idl.max_nscan = nscan + 1     ;Add 1 extra scan to avoid
              idl.max_nbin  = nmjf * nbin   ;error message stating that
         endif                              ;data buffer is completely full.


         idl.max_nsrc   = GET_NSRC( File )

         files.idl = File
         idl.format= Fmt

         extra.nsrc= 0       ; Reset the number of additional sources
         files.add = ''

         bad = {mjfs:0L}     ; Reset the Excluded MJFs list
         files.bad = ''


end

;========= END XF_FILE_IDL routines ====================================


;========= BEGIN XF_FILE_ADD routines ==================================
;
;   This routine gets the filename of the Additional Source(s) File by
;   interactively allowing the USER to select the file from a directory
;   listing.
;
pro XF_FILE_ADD, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         WIDGET_CONTROL,/HOURGLASS
         ; Get Additional Sources file
         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         File = pickfile( /READ, PATH=!DATA_PATH, FILTER='*.add', $
                TITLE='Select Additional Source(s) File', $
                GROUP=Group )

         if File eq '' then return
         if (!DATA_PATH eq '') then begin
              delim = RSTRPOS(File,'\')
              if (delim eq -1) then delim = RSTRPOS(File,'/')
              if (delim ne -1) $
              then defsysv,'!DATA_PATH',STRMID(File,0,delim+1)
         endif
         files.add = File

         WIDGET_CONTROL,/HOURGLASS
         openr, in, File, /get_lun
         name = '' & RA = 0.0 & DEC = 0.0
         while NOT eof(in) do begin
              readf,in,format='(A15,2(F15.7))',$
                    name,RA,DEC

              if N_ELEMENTS( names ) eq 0 then begin
                   names     = name
                   RAs       = RA
                   DECs      = DEC
              endif else begin
                   names     = [names,name]
                   RAs       = [RAs,RA]
                   DECs      = [DECs,DEC]
              endelse
         endwhile

         close, in
         free_lun, in

         nsrc_extra     = N_ELEMENTS( names )
         if nsrc_extra gt 0 then begin
              extra = { $
                      nsrc : nsrc_extra, $
                      name : names, $
                      RA   : RAs,$
                      DEC  : DECs $
                      }
              idl.max_nsrc = idl.max_nsrc + nsrc_extra
         endif
end

;========= END XF_FILE_ADD routines ====================================

;========= BEGIN XF_FILE_BAD routines ==================================
;
;   This routine gets the filename of the Bad MJFs File by
;   interactively allowing the USER to select the file from a directory
;   listing.
;
pro XF_FILE_BAD, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         WIDGET_CONTROL,/HOURGLASS
         ; Get BAD MJFs file
         defsysv,'!DATA_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!DATA_PATH',''
         File = pickfile( /READ, PATH=!DATA_PATH, FILTER='*.bad', $
                TITLE='Select Excluded MJF(s) File', $
                GROUP=Group )

         if File eq '' then return
         if (!DATA_PATH eq '') then begin
              delim = RSTRPOS(File,'\')
              if (delim eq -1) then delim = RSTRPOS(File,'/')
              if (delim ne -1) $
              then defsysv,'!DATA_PATH',STRMID(File,0,delim+1)
         endif
         files.bad = File

         WIDGET_CONTROL,/HOURGLASS
         openr, in, File, /get_lun
         mjf  = 0L
         while NOT eof(in) do begin
              readf,in,mjf
              if N_ELEMENTS( mjfs ) eq 0 then mjfs = mjf $
              else mjfs = [mjfs,mjf]
         endwhile

         close, in
         free_lun, in

         nmjfs     = N_ELEMENTS( mjfs )
         if nmjfs gt 0 then $
         bad = { mjfs : mjfs }

end

;========= END XF_FILE_BAD routines ====================================


;========= BEGIN XF_OPTIONS_RNG routines ===============================
;
;   This routine interactively prompts the USER for a range of major
;   frames
;
pro XF_OPTIONS_RNG, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         Questions = [ $
                     '  Lower bound: ',$
                     '  Upper bound: ' $
                     ]

         if idl.mjf_rng(1) ne 0 then Default = idl.mjf_rng  $
         else Default = ['','']

         result    = XQUERY( Questions, DEFAULT=Default, $
                             TITLE='Range of major frames',$
                             GROUP=Group )

         if (result(0) ne '') then idl.mjf_rng(0) = long( result(0) )
         if (result(1) ne '') then idl.mjf_rng(1) = long( result(1) )
end

;========= END XF_OPTIONS_RNG routines =================================

;========= BEGIN XF_OPTIONS_FIT_BKD routines ===========================
;
;   This routine interactively prompts the USER for the degree of the
;   polynomial to be used to fit the background of each scan
;
pro XF_OPTIONS_FIT_BKD, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         Questions = 'Degree of polynomial <1=Default>: '
         Default   = idl.degree

         result    = XQUERY( Questions, DEFAULT=Default, $
                             TITLE='Background Fitting Parameter ',$
                             GROUP=Group )

         if result(0) ne '' then idl.degree = fix( result(0) )

end

;========= END XF_OPTIONS_FIT_BKD routines =============================

;========= BEGIN XF_OPTIONS_BUF routines ===============================
;
;   This routine interactively prompts the USER to set the various
;   buffer settings. NOTE: the number of sources is AUTOMATICALLY
;   configured, so you really do not need to mess with that parameter.
;
pro XF_OPTIONS_BUF, GROUP=Group, NSRC=Nsrc, NSCAN=Nscan, NBIN=Nbin


         common INIT_COM, idl, extra, bad, files

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         Questions  = ['   Number of sources <5=Default>: ', $
                       '   Number of scans <500=Default>: ', $
                       '   Number of bins <100000=Default>: ' $
                      ]
         Default    = [ idl.max_nsrc, $
                        idl.max_nscan, $
                        idl.max_nbin $
                      ]

         result    = XQUERY( Questions, DEFAULT=Default, $
                             TITLE='Scan Buffer Parameters ',$
                             GROUP=Group )

         if result(0) ne '' then idl.max_nsrc = fix( result(0) )
         if result(1) ne '' then idl.max_nscan= fix( result(1) )
         if result(2) ne '' then idl.max_nbin = long(result(2) )

end

;========= END XF_OPTIONS_BUF routines =================================

;========= BEGIN XF_OPTIONS_SET routines ===============================
;
;   This routine displays the current settings/parameters to be used
;   in the subsequent analysis of the IDL data file.
;
pro XF_OPTIONS_SET, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         lt_curv = [ $
                   'None',$
                   'All',$
                   'Passed',$
                   'Failed',$
                   'Passed after MJF cutoff' $
                   ]

         deadtime= [ $
                   'None',$
                   'Non-paralyzable',$
                   'Paralyzable'$
                   ]

         trn_reg = [ $
                   'Include',$
                   'Exclude' $
                   ]

         lc_set = idl.lt_curv
         if (lc_set eq 2) and (idl.mjf_cutoff gt 0) then lc_set=4
         list = [ $
              'IDL data file: '+files.IDL, $
              'Additional Source(s) file: '+files.add, $
              'Excluded MJFs file: '+files.bad, $
              'Light curve: '+lt_curv( lc_set ), $
              'MJF cutoff: '+strtrim( idl.mjf_cutoff,2 ), $
              'MJF range: ['+arr2str( idl.mjf_rng )+']',$
              'Deadtime: '+deadtime( idl.deadtime ), $
              'Transmission regions: '+trn_reg( idl.notrns ), $
              'Degree of background polynomial: '+strtrim( idl.degree,2 ), $
              'Number of sources: '+strtrim( idl.max_nsrc,2 ), $
              'Number of scans: '+strtrim( idl.max_nscan,2 ), $
              'Number of data bins: '+strtrim( idl.max_nbin,2 ) $
              ]


         XMSG, list, /ALIGN, TITLE='Fiducial Settings', GROUP=Group

end

;========= END XF_OPTIONS_SET routines =================================

;========= BEGIN XF_HELP_ABOUT routines ================================
;
;   These collection of widget routines displays the Fiducial Logo
;
pro MAIN_HELP_ABOUT_Event, Event

         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF

         'DRAW_DEMO':
         'BUTTON_OK': dummy=EXECUTE('WIDGET_CONTROL,Event.Top,/DESTROY')
         ENDCASE
end

pro XF_HELP_ABOUT, GROUP=Group

         common INIT_COM, idl, extra, bad, files

         if N_ELEMENTS(Group) eq 0 then Group=0

         MAIN_HELP_ABOUT = WIDGET_BASE(GROUP_LEADER=Group, $
             TITLE='About Fiducial', $
             COLUMN=1, $
             MAP=0, $
             UVALUE='MAIN_HELP_ABOUT')

         LABEL60 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL60', $
             VALUE=' ')

         OS  = STRUPCASE(!VERSION.OS)
         OS  = STRMID(OS,0,3)
         if OS eq 'WIN' then font = 25 $
         else font = '-adobe-courier-*-*-*-*-25-*-*-*-*-*-*-*'
         LABEL5 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             FONT=font, $
             UVALUE='LABEL5', $
             VALUE='Fiducial')

         LABEL62 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL62', $
             VALUE=' ')

         BASE54 = WIDGET_BASE(MAIN_HELP_ABOUT, $
             COLUMN=1, $
             XPAD=50, $
             MAP=1, $
             UVALUE='BASE54')

         DRAW_DEMO = WIDGET_DRAW( BASE54, $
             RETAIN=2, $
             UVALUE='DRAW_DEMO', $
             XSIZE=150, $
             YSIZE=110 )


         LABEL64 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL64', $
             VALUE=' ')

         LABEL15 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL15', $
             VALUE='Version '+string(idl.version,format='(F3.1)'))

         LABEL66 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL66', $
             VALUE=' ')

         LABEL16 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL16', $
             VALUE='Han Wen')

         LABEL68 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL68', $
             VALUE=' ')

         LABEL70 = WIDGET_LABEL( MAIN_HELP_ABOUT, $
             UVALUE='LABEL70', $
             VALUE=' ')

         BASE28 = WIDGET_BASE(MAIN_HELP_ABOUT, $
             ROW=1, $
             XPAD=110, $
             MAP=1, $
             UVALUE='BASE28')

         BUTTON_OK = WIDGET_BUTTON( BASE28, $
             UVALUE='BUTTON_OK', $
             VALUE='OK')

         WIDGET_POSITION, MAIN_HELP_ABOUT, /CENTER, MAP=0

;   Plot an example light curve

         y1=[$
             63, 55, 47, 62, 44, 50, 68, 45, 48, 51, 48, 53, 43, 59, 52, $
             50, 53, 55, 50, 42, 51, 57, 63, 56, 59, 63, 36, 52, 38, 42, $
             56, 62, 53, 47, 45, 45, 44, 50, 55, 43, 41, 56, 50, 44, 45, $
             46, 55, 44, 47, 56, 51, 55, 55, 53, 62, 72, 69, 85, 93, 112 $
            ]
         y2=[$
             145,123,136,179,141,154,167,135,123,110,106,82, 83, 86, 85, $
             69, 61, 58, 50, 47, 40, 55, 42, 49, 46, 46, 54, 53, 59, 48, $
             50, 46, 53, 53, 47, 55, 44, 40, 52, 43, 46, 51, 46, 45, 46, $
             46, 58, 48, 41, 52, 43, 50, 58, 47, 52, 40, 55, 45, 46, 55, $
             46, 53, 51, 54, 53, 54, 46, 52 $
            ]
         y=[y1,y2]
         plot,y, xmargin=[ 4,3 ], ymargin=[3,2], charsize=0.5, $
                psym=10, /xstyle

         WIDGET_CONTROL, MAIN_HELP_ABOUT, /MAP


         XMANAGER, 'MAIN_HELP_ABOUT', MAIN_HELP_ABOUT, /JUST_REG
end

;========= END XF_HELP_ABOUT routines ==================================

;========= BEGIN XF_MAIN_HELP routines ======================================
;
;   This collection of widget routines handles all the Help options from
;   the Fiducial MAIN Menu and all its submenus
;
pro XF_MAIN_HELP, Ev, GROUP=Group

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         CASE Ev OF
         'Help.Online Help': BEGIN
              Title  = 'Fiducial Help [Topic: MAIN MENU]'
              Topics = [$
                   'File',$
                   'Options',$
                   'Apply Cuts',$
                   'Help']

              Descrs = [$
                   '    This is a pulldown menu from which you may either ',$
                   'select to open various files for the data analysis or',$
                   'Quit the data analysis. (Select Help under this File ',$
                   'menu for more information).',$

                   '    This is a pulldown menu from which you may set ',$
                   'various options for the data analysis, such as ',$
                   'whether to display a light curve of each scan that ',$
                   'passes the fiducial cuts and prompt you to Accept or ',$
                   'Reject this scan. (Select Help under this Options menu',$
                   'for more information).',$

                   '    Begin analysis of the data by applying fiducial cuts',$
                   'to each scan in the data file.  Depending upon how',$
                   'you set the Light Curve setting in the Options menu',$
                   'a light curve of the scan may be plotted for Final',$
                   'Cut selection.  (Select Help under the Options menu for',$
                   'more information).',$
                   '',$
                   '    You may then chose to Accept or Reject this scan. After',$
                   'you have made your selection, the analysis continues on',$
                   'with applying the fiducial cuts to the next scan.',$
                   '',$
                   '    A data file must already be opened before making this',$
                   'selection. (Select Open IDL data file under the File',$
                   'menu to open a data file.)',$

                   '    The purpose of this Fiducial routine is to "weed out"',$
                   'unacceptable scans in an IDL data file by applying various',$
                   'fiducial cuts to each scan.  The scans which have passed',$
                   'these fiducial cuts may be saved to an IDL session file',$
                   'along with their various fitting results such as the ',$
                   'intensity for each source.',$
                   '',$
                   '    Saving to an IDL session file provides two main benefits',$
                   '1) "Instant" access to the data once the session file has',$
                   'been restored, as opposed to the time-consuming task of',$
                   'reading each line of text from the IDL data file; and',$
                   '2) Since an IDL session file is a binary file and the',$
                   'number of scans saved is somewhat fewer due to fiducial',$
                   'cuts rejection, the resulting IDL session file is much',$
                   'smaller in size than its ASCII counterpart, the IDL',$
                   'data file (*.idl).',$
                   '',$
                   '    The following is a list of fiducial cuts made on each',$
                   'scan of the IDL dat file:',$
                   '',$
                   'CUT#1:  The number of "glitches" in the background',$
                   '              region of each scan must be < 6. (320ms mode only)',$
                   'CUT#2:  No "glitches" are allowed in the signal region',$
                   '              of each scan. (320ms mode only)',$
                   'CUT#3:  The reduced chi-squared for fitting the background',$
                   '              to a polynomial must be < 2',$
                   'CUT#4:  The reduced chi-squared for fitting the transmission',$
                   '              function(s) of the source(s) to the signal',$
                   '              region must be < 10.',$
                   'CUT#5:  The abs(slope) of the fitted background polynomial,',$
                   '              assuming it''s a line, must be',$
                   '              < 0.2 counts/bin',$
                   'CUT#6:  The average background rate must be',$
                   '              < 312.5 counts/sec = 100 cts/bin in 320ms mode',$
                   '',$
                   '    To see the items and format of the data saved to the',$
                   'IDL session file, please select FIDUCIAL using the IDL',$
                   'Online Help, under the HANWEN topic.',$
                   '',$
                   'For additional help on a subtopic select Help',$
                   'from its submenu.']

              Nlines = [ 4,6,14,41 ]

              END
         'File.Help': BEGIN
              Title = 'Fiducial Help [Topic: FILE]'
              Topics = [$
                   'Open IDL data file',$
                   'Open Additional Source(s) file', $
                   'Open Excluded MJFs file', $
                   'Quit', $
                   'Help']

              Descrs = [$
                   'Open an IDL HEAO A-1 data file.  The file must be in the',$
                   'format defined by the FMD_IDL or FMT_SRCDATA routines.',$

                   'Open a text file containing information about sources not',$
                   'listed in the IDL data file which you would like to include',$
                   'in your light curves.', $
                   '', $
                   '    Each line of the file must specify a different source', $
                   'with the following format:',$
                   '',  $
                   'Name of source     RA             DEC',$
                   'Format = (A15)     ( F15.7 )      ( F15.7 )',$
                   'Units  = [ N/A ]     [Degrees]      [Degrees]',$
                   '',$
                   'For example:',$
                   '',$
                   '1H1608-522         242.217        -52.2953',$
                   '1H1624-490         246.074        -49.0794',$

                   '    Open a text file containing a list of scans you want excluded',$
                   'from the analysis. Each row of the text file is identified',$
                   'with a different scan by providing the MJF number of the first',$
                   'major frame of that scan.',$
                   '',$
                   'For example:',$
                   '',$
                   '452111',$
                   '478133',$
                   '853221',$

                   'Quit this Fiducial routine.',$

                   'Sorry, no other additional Help available for this topic.']
              Nlines= [ 2, 15, 10, 1, 1 ]
              END
         'Options.Help': BEGIN
              Title = 'Fiducial Help [Topic: OPTIONS]'
              Topics = [$
                   'Display current settings',$
                   'Light curve',$
                   'MJF range',$
                   'Fitting',$
                   'Scan buffer',$
                   'Default',$
                   'Help']

              Descrs = [$
                   'Display the current settings for all the Options.',$

                   '    This is a pulldown menu from which you may',$
                   'select which light curves to display. ',$
                   '',$
                   '    You may elect to Accept or Reject a scan respective',$
                   'or irrespective of the fiducial cuts by choosing',$
                   'which light curves will be displayed.  When a light',$
                   'curve of a scan is displayed, you must choose whether',$
                   'or not to cut this scan from the analysis by selecting',$
                   'an Accept or a Reject button.',$
                   '',$
                   '(Select Help under the Light curve submenu for more ',$
                   'information).',$


                   '    Select this option to restrict the data analysis to a',$
                   'range of scans. You wil be prompted to enter the lower and',$
                   'upper bound of this range. These bounds are the major frame',$
                   'number (MJF) of the first major frame of the scans. ',$
                   '',$
                   '    NOTE: the MJFs do not have to correspond to scans that',$
                   'exist in the data file.  For, example, if you wanted to ',$
                   'restrict your analysis to the first 6 months of the data set,',$
                   'then select:',$
                   '',$
                   '    Lower bound: 0',$
                   '    Upper bound: 600000',$

                   '    This is a pulldown menu from which you may modify various ',$
                   'fitting parameters. These fitting parameters are used to ',$
                   'correct the data and fit for the background and source ',$
                   'intensities. (Select Help under the Fitting submenu for more',$
                   'information).',$

                   '    Choose this option to modify various scan buffer ',$
                   'parameters.  The scan buffer holds both the data read from',$
                   'the IDL data file and the information to be saved to the',$
                   'IDL session file. Here is a list of parameters you may modify:',$
                   '',$
                   '    Number of sources = Maximum number of sources (INCLUDING',$
                   '    the additional sources) in the analysis.',$
                   '',$
                   '    Number of scans = Maximum number of scans in a the IDL ',$
                   '    data file.',$
                   '',$
                   '    Number of data bins = Maximum number of data bins to',$
                   '    store in the saved session file.',$
                   '',$
                   'NOTE: The Number of sources (IDL data file + Additional Source',$
                   'file) is AUTOMATICALLY determined.  If a corresponding database',$
                   'file exists (.dbs) then the number of scans and the number of',$
                   'data bins are also AUTOMATICALLY determined. In other words, ',$
                   'unless you are doing something very unusual, you DO NOT NEED',$
                   'TO MODIFY THESE PARAMETERS.',$

                   'Reset all of the options to their default values.',$

                   'For additional help on a subtopic select Help',$
                   'from its submenu.']

              Nlines= [ 1, 12, 12, 5, 20, 1, 2 ]
              END
         'Options.Light curve.Help': BEGIN
              Title = 'Fiducial Help [Topic: LIGHT CURVE]'
              Topics = [$
                   'None',$
                   'All',$
                   'Passed',$
                   'Passed after MJF cutoff',$
                   'Failed',$
                   'Help']

              Descrs = [$
                   '    No light curves will be displayed. Choose this option',$
                   'if you want to let Fiducial soley determine which scans',$
                   'should be cut or kept.',$
                   '',$
                   '    This option is recommended only for the FINAL pass of',$
                   'the data.',$

                   '    Choose this option to display the light curves of scans',$
                   'irrespective of the fiducial cuts.',$
                   '',$
                   '    This option is recommended for the FIRST pass of the',$
                   'data to check to see if additional sources are needed to',$
                   'fill regions of the scan where there are detector counts',$
                   'from a source but no corresponding NON-zero source',$
                   'transmissions.',$

                   '    Choose this option to display only the light curves',$
                   'of scans that PASS the fiducial cuts.',$
                   '',$
                   '    Use this option if you are reasonably confident that you',$
                   'have all the RELEVANT sources in the field of view of each scan',$
                   'and would like to REJECT poor scans which manage to get by the',$
                   'fiducial cuts.',$

                   '    Choose this option to display only the light curves',$
                   'of scans that both PASS the fiducial cuts and have a',$
                   'starting Major Frame number greater than a cutoff. ',$
                   'You will be prompted to enter this cutoff after selecting',$
                   'this option.',$
                   '',$
                   '    Use this option if you have aborted Fiducial before',$
                   'completing your analysis on a data set and would like to',$
                   'continue where you left off.  Make sure any additional',$
                   'major frames you have marked bad have been included in the',$
                   'Excluded MJF(s) file.',$

                   '    Choose this option to diplay only the light curves',$
                   'of scans that FAIL the fiducial cuts.',$

                   'Sorry, no other additional Help available for this topic.']

              Nlines= [ 6, 8, 7, 11, 2, 1 ]
              END
         'Options.Fitting.Deadtime corrections.Help': BEGIN
              Title = 'Fiducial Help [Topic: DEADTIME]'

              Topics = [$
                   'None',$
                   'Non-paralyzble',$
                   'Paralyzable',$
                   'Help']

              Descrs = [$
                   'Do NOT correct the count data for any deadtime.',$
                   'Correct the count data for a Non-paralyzable deadtime.',$
                   'This IS the proper setting for the HEAO A-1 data.',$
                   'Correct the count data for a Paralyzable deadtime.',$
                   'See Muller, "Dead-Time Problems", NIM 112 (1973) 47-57']

              Nlines= [ 1, 2, 1, 1 ]
              END
         'Options.Fitting.Transmission regions.Help': BEGIN
              Title = 'Fiducial Help [Topic: TRANSMISSION REGIONS]'

              Topics = [$
                   'Include',$
                   'Exclude',$
                   'Help']

              Descrs = [$
                   'Include the NON-ZERO transmission regions in analysis.',$
                   'Exclude the NON-ZERO transmission regions in analysis.',$
                   'If you choose this option then NO intensity or ',$
                   'background fitting parameters will be determined or',$
                   'saved.',$
                   'A NON-ZERO transmission region is defined as any count',$
                   'bin where the transmission values for one or more sources',$
                   'is greater than 0.']

              Nlines= [ 1, 4, 3 ]
              END
         'Options.Fitting.Help': BEGIN
              Title = 'Fiducial Help [Topic: FITTING]'

              Topics = [$
                   'Deadtime corrections',$
                   'Transmission regions',$
                   'Degree of background polynomial',$
                   'Help']

              Descrs = [$
                   'Select the type of deadtime corrections to be applied to',$
                   'the count data.',$
                   'Select whether or not the NON-ZERO transmission regions',$
                   'are included in the analysis.',$
                   'Select the degree of the polynomial used in fitting the',$
                   'background regions for each scan.',$
                   'For additional help on a subtopic select Help',$
                   'from its submenu.']

              Nlines= [ 2, 2, 2, 2 ]
              END


         ENDCASE
         XHELPMSG, Topics, Descrs, Nlines, TITLE=Title, GROUP=Group
end


;========= END XF_MAIN_HELP routines ========================================

;========= BEGIN FIDUCIAL routines ====================================
;
;   This collection of widget routines drives the Fiducial MAIN Menu
;
pro PDMENU_MAIN_Event, Event

         common INIT_COM, idl, extra, bad, files

         help_event = 0
         CASE Event.Value OF

         'File.Open IDL data file': XF_FILE_IDL, GROUP=Event.Top
         'File.Open Additional Source(s) file': XF_FILE_ADD, GROUP=Event.Top
         'File.Open Excluded MJFs file': XF_FILE_BAD, GROUP=Event.Top
         'File.Quit': BEGIN
              dummy = EXECUTE('WIDGET_CONTROL, Event.Top, /DESTROY')
              close,/all
              CLEAR_SCAN
              LCLOADCT, /UNLOAD
              END
         'File.Help': help_event = 1
         'Options.Display current settings': XF_OPTIONS_SET, GROUP=Event.top
         'Options.Light curve.None':idl.lt_curv=0
         'Options.Light curve.All':idl.lt_curv=1
         'Options.Light curve.Passed <Default>':idl.lt_curv=2
         'Options.Light curve.Passed after MJF cutoff': BEGIN
                   idl.lt_curv=2
                   mjf_cutoff=XQUERY('Enter MJF number cutoff:',$
                             DEFAULT=idl.mjf_cutoff, $
                             TITLE='Fiducial Options', GROUP=Event.top)
                   idl.mjf_cutoff = mjf_cutoff(0)
                   END
         'Options.Light curve.Failed':idl.lt_curv=3
         'Options.Light curve.Help': help_event = 1
         'Options.MJF range':XF_OPTIONS_RNG, GROUP=Event.top
         'Options.Fitting.Deadtime corrections.None':idl.deadtime=0
         'Options.Fitting.Deadtime corrections.Non-paralyzable <Default>':$
                                                     idl.deadtime=1
         'Options.Fitting.Deadtime corrections.Paralyzable':idl.deadtime=2
         'Options.Fitting.Deadtime corrections.Help': help_event=1
         'Options.Fitting.Transmission regions.Include <Default>':idl.notrns=0
         'Options.Fitting.Transmission regions.Exclude ':idl.notrns=1
         'Options.Fitting.Transmission regions.Help': help_event = 1
         'Options.Fitting.Degree of background polynomial':$
                             XF_OPTIONS_FIT_BKD, GROUP=Event.top
         'Options.Fitting.Help': help_event = 1
         'Options.Scan buffer':XF_OPTIONS_BUF, GROUP=Event.Top
         'Options.Default':DEF_INIT_COM
         'Options.Help': help_event = 1
         'Apply Cuts': XF_APPLY, GROUP=Event.Top
         'Help.Online Help': help_event = 1
         'Help.About Fiducial':XF_HELP_ABOUT, GROUP=Event.Top
         ENDCASE

         if help_event then XF_MAIN_HELP, Event.Value, GROUP=Event.Top
end


pro MAIN_MENU_Event, Event


         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF

         ; Event for PDMENU_MAIN
         'PDMENU_MAIN': PDMENU_MAIN_Event, Event
         ENDCASE
end


pro FIDUCIAL

         DEF_INIT_COM   ;Define common default settings

         junk   = { CW_PDMENU_S, flags:0, name:'' }


         Title     = 'Fiducial Main Menu'
         MAIN_MENU = WIDGET_BASE( $
             ROW=1, $
             MAP=1, $
             TITLE=Title, $
             UVALUE='MAIN_MENU')

         MenuDesc229 = [ $
             { CW_PDMENU_S,    1, 'File' }, $ ;        0
               { CW_PDMENU_S,    0, 'Open IDL data file' }, $ ; 1
               { CW_PDMENU_S,    0, 'Open Additional Source(s) file' }, $ ; 2
               { CW_PDMENU_S,    0, 'Open Excluded MJFs file' }, $ ;        3
               { CW_PDMENU_S,    0, 'Quit' }, $ ;      4
               { CW_PDMENU_S,    2, 'Help' }, $ ;      5
             { CW_PDMENU_S,    1, 'Options' }, $ ;     6
               { CW_PDMENU_S,    0, 'Display current settings' }, $ ;       7
               { CW_PDMENU_S,    1, 'Light curve' }, $;8
                 { CW_PDMENU_S,    0, 'None' }, $ ;    9
                 { CW_PDMENU_S,    0, 'All' }, $ ;     10
                 { CW_PDMENU_S,    0, 'Passed <Default>' }, $ ;  11
                 { CW_PDMENU_S,    0, 'Passed after MJF cutoff' }, $ ;     12
                 { CW_PDMENU_S,    0, 'Failed' }, $ ;  13
                 { CW_PDMENU_S,    2, 'Help' }, $ ;    14
               { CW_PDMENU_S,    0, 'MJF range' }, $ ; 15
               { CW_PDMENU_S,    1, 'Fitting' }, $ ;   16
                 { CW_PDMENU_S,    1, 'Deadtime corrections' }, $ ;        17
                   { CW_PDMENU_S,    0, 'None' }, $ ;  18
                   { CW_PDMENU_S,    0, 'Non-paralyzable <Default>' }, $ ; 19
                   { CW_PDMENU_S,    0, 'Paralyzable' }, $ ;               20
                   { CW_PDMENU_S,    2, 'Help' }, $ ;  21
                 { CW_PDMENU_S,    1, 'Transmission regions' }, $ ;        22
                   { CW_PDMENU_S,    0, 'Include <Default>' }, $ ;         23
                   { CW_PDMENU_S,    0, 'Exclude ' }, $ ;                  24
                   { CW_PDMENU_S,    2, 'Help' }, $ ;                      25
                 { CW_PDMENU_S,    0, 'Degree of background polynomial' }, $ ;26
                 { CW_PDMENU_S,    2, 'Help' }, $ ;    27
               { CW_PDMENU_S,    0, 'Scan buffer' }, $;28
               { CW_PDMENU_S,    0, 'Default' }, $ ;   29
               { CW_PDMENU_S,    2, 'Help' }, $ ;      30
             { CW_PDMENU_S,       0, 'Apply Cuts' }, $;31
             { CW_PDMENU_S,       3, 'Help' }, $ ;     32
               { CW_PDMENU_S,       0, 'Online Help' }, $ ;                33
               { CW_PDMENU_S,       2, 'About Fiducial' } $  ;             34

         ]


         PDMENU_MAIN = CW_PDMENU( MAIN_MENU, MenuDesc229, /RETURN_FULL_NAME, $
             UVALUE='PDMENU_MAIN')

         WIDGET_POSITION, MAIN_MENU

         XF_HELP_ABOUT, GROUP=MAIN_MENU

         XMANAGER, 'MAIN_MENU', MAIN_MENU
end
;========= END FIDUCIAL routines ======================================
