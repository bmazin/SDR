;+
; NAME:
;        FINDSRC
;
; PURPOSE:
;        Interactively finds all x-ray sources around a primary source
;        within the field of view of a HEAO A-1 scan. Uses the XXX database.
;
; CATEGORY:
;        Database.
;
; CALLING SEQUENCE:
;
;        Result = FINDSRC( Module, Cts, Src, Sat )
;
; INPUTS:
;        Module:   Collimator module number.
;
;        Cts:      Counts of the scan, fltarr(nbin).
;
;        Src:      Structure containing information about the primary source.
;                  Its must have the following tags defined:
;
;                  RA:  The RA of the primary source in DEGREES.
;                  DEC: The DEC of the primary source in DEGREES.
;                  trn: The collimator transmissions of the primary source
;                       across the scan, fltarr(nbin).
;
;        Sat:      Structure containing information about the satellite's
;                  position. It must have the following tags defined:
;
;                  RAY,DEY:  The RA,DEC of the Y-axis of the satellite
;                            in RADIANS at either the beginning of each
;                            major frame, fltarr( nmjfs ) or at each
;                            bin, fltarr( nbin ).
;                  RAZ,DEZ:  The RA,DEC of the Z-axis of the satellite
;                            in RADIANS at either the beginning of each
;                            major frame, fltarr( nmjfs ) or at each
;                            bin, fltarr( nbin ).
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        DEGREES:  Set this keyword to interactively input the RA and
;                  DEC of any additional USER-defined sources not
;                  found in the database in DEGREES. ((hh mm ss) and
;                  (dd mm ss)] = Default).
;
;        FLUX_CUTOFF:   Minimum flux requirement in MICROJY for any
;                  source found in the database, (i.e. you want to find
;                  all sources with its max. flux > FLUX_CUTOFF). (0=Default)
;
;        MJFS:     List of major frame numbers for this scan, lonarr( nmjf ).
;
;        USERSRC:  ARRAY of structures holding information about each
;                  USER-defined source to be plotted and returned
;                  in addition to those found by the database. It must
;                  have the following tags defined for each structure.
;
;                  Name:     The name of the source, string.
;                  RA:       The RA of the source in DEGREES.
;                  DEC:      The DEC of the source in DEGREES.
;
;                  (See example below for implementation).
;
; OUTPUTS:
;        This function first finds all the sources around a primary source
;        and within the field of view of a scan by searching a database.
;        Only those sources the USER interactively specifies will be
;        returned in an ARRAY of structures with tags defined as:
;
;        Name:     The name of the source, string.
;        RA:       The RA of the source in DEGREES.
;        DEC:      The DEC of the source in DEGREES.
;
;        If no sources are accepted by the USER then -1 is returned.
;
; RESTRICTIONS:
;        There are TWO PRECONDITIONS that must be satisfied before calling
;        this routine, 1) That the XXX database is currently opened using
;        the Astronomy Library routine DBOPEN; and 2) The light curve
;        color table has already been loaded by calling the LCLOADCT routine.
;        (See example below).
;
; PROCEDURE:
;        When you call this routine, a database is first searched for all
;        sources within a cone about the primary source, defined by the
;        Src structure. The (1/2) separation or polar angle defining this
;        cone is the larger of the two angles between the source position
;        on the scan and the bin edges of the scan added in quadrature with
;        8 degrees to account for the collimator's acceptance.
;
;        For each source found, its corresponding transmissions are
;        calculated across the scan. The transmissions for this source
;        as well as for the primary source are then plotted over the
;        light curve for this scan.  The USER is then prompted about
;        whether to add this source to the list that will eventually be
;        returned.
;
; EXAMPLE:
;        Let's say we want to find all the sources around 1H1741-32
;        that will actually show up in the scan because they're within
;        the acceptance of the collimator module.
;
;        name = '1H1741-32'
;        src  = { RA:265.4, DEC:-32.2, Trn:trn }
;        sat  = { RAY:RAY, DEY:DEY, RAZ:RAZ, DEZ:DEZ }
;
;        Let's additionally say we already know two sources, 1H1715-321
;        and 1H1728-334.A that will show up; so we want them plotted
;        immediately:
;
;        othersrc = { name:'', RA:0.0, DEC:0.0 }
;        othersrc = REPLICATE( othersrc, 2)
;        othersrc( 0).name =
;        othersrc( 0).RA   =  258.885
;        othersrc( 0).DEC  =  -32.1261
;        othersrc( 1).name = '
;        othersrc( 1).RA   =  262.165
;        othersrc( 1).DEC  =  -33.7969
;
;        We must first open the XXX database, and load the light curve
;        color table:
;
;        DBOPEN,'xxx'
;        LCLOADCT
;
;        Now, we can go ahead and interactively get the list:
;
;        list = FINDSRC( Module, Cts, Src, Sat, USERSRC=othersrc )
;
;        You will find, in addition to those you accept:
;
;        list(0).name   = 1H1715-321
;        list(1).name   = 1H1728-334.A
;
;        ..etc
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, November, 1994.
;        30-DEC-1994    Widgetized this routine FINDSRC->FINDSRC.
;        10-JAN-1995    Fixed small typo bug.
;        22-JAN-1995    Moved FINDSRC -> OBSOLETE directory. Renamed
;                       XFINDSRC->FINDSRC
;-
function FINDSRC, Module, Cts, Src, Sat, DEGREES=Degrees, $
                  FLUX_CUTOFF=Flux_cutoff, USERSRC=USERsrc, MJFS=Mjfs


         common lc_colors, ncolors, linecolors, black, cyan, white

         Msg_ID=0

         WIDGET_CONTROL,/HOURGLASS

         lcloadct

         title=''
         if keyword_set(MJFS) then title = 'MJF:'+arr2str(mjfs)
         xfmsg     = 'Findsrc Message'
         xfw       = 'Findsrc WARNING'

;   Define XQUERY buttons

         buttons = [ $
                   '?', $
                   'Add current source to list',$
                   'Redo source selection for this scan',$
                   'Quit source hunting for this scan' $
                   ]
         values  = [ 'N', 'A', 'R', 'Q' ]


;   Unpack data from Src and Sat structures

         trn_src   = Src.trn
         srcRA     = Src.RA
         srcDEC    = Src.DEC

         RAY       = Sat.RAY
         DEY       = Sat.DEY
         RAZ       = Sat.RAZ
         DEZ       = Sat.DEZ

;   Extract number of elements info

         nbin      = N_ELEMENTS( Cts )
         nasp      = N_ELEMENTS( RAY )

         nsrcmax   = 200
         asrc      = { findsrc, name: '',  RA: 0.0, DEC: 0.0 }
         othersrc  = REPLICATE( asrc, nsrcmax )
         othertrns = fltarr( nbin, nsrcmax )
         srccolor  = intarr( nsrcmax )
         nother    = 0

;   Scale transmissions to the middle 1/2 of the screen

         ct_min    = MIN( cts, MAX=ct_max )
         ct_rng    = ct_max - ct_min
         avg_bkd   = 0.25 * ct_rng + ct_min
         Iavg      = 0.50 * ct_rng

;   Find existing sources in the XXX database

         trnmax    = MAX( trn_src, binmax )
         sang      = abs( nbin-1 - binmax ) > binmax
         sang      = 0.05 * sang             ;degrees, 38.4 min spin period
         sang      = sqrt( sang^2. + 8.^2. ) ;collimator 1x4 window
         cone= ['Considering a cone of polar angle:',$
                 strtrim(sang,2)+' [deg]']
         xmsg, cone, TITLE=xfmsg, /LEFT, /TOP, /NOBUTTON, MSG_ID=cone_id

         if n_elements( FLUX_CUTOFF ) eq 0 then Flux_cutoff = 0.0

         list      = dbcircle( srcRA/15., srcDEC, 60.*sang, dist )
         if list(0) ne -1 then begin
              dbext,list,'name,ra_deg,dec,flux_min,flux_max',$
                        fovName,fovRA,fovDEC,fluxmin,fluxmax

              here_avg  = where( fluxmax eq 0, nmin ) ;Average flux sources
              here_rng  = where( fluxmax gt 0, nmax ) ;Range of fluxes sources

;   If there are average flux sources see if any of them are
;   greater than the cutoff flux

              if nmin gt 0 then begin
                   hhere_min =  $
                        where( fluxmin( here_avg ) gt Flux_cutoff, nmin )
              endif

;   If there are range of fluxes sources see if any of them have their
;   maximum flux greater than the cutoff flux

              if nmax gt 0 then begin
                   hhere_max =  $
                        where( fluxmax( here_rng ) gt Flux_cutoff, nmax )
              endif

              nfov      = nmin + nmax
              CASE nfov OF
                      0 :    here = -1
                   nmin :    here =  here_avg( hhere_min )
                   nmax :    here =  here_rng( hhere_max )
                   else :    here = [here_avg( hhere_min ), $
                                     here_rng( hhere_max )]
              ENDCASE

              if nfov gt 0 then begin
                   list      = list( here )
                   dist      = dist( here )
                   fovName   = fovName( here )
                   fovRA     = fovRA( here )
                   fovDEC    = fovDEC( here )
                   fluxmin   = fluxmin( here )
                   fluxmax   = fluxmax( here )
                   xmsg, [strtrim(nfov,2)+' sources found within '+$
                          'Field of View of scan ',$
                          'with Flux >'+strtrim(Flux_cutoff,2)], $
                          TITLE=xfmsg
                   newline
                   dbprint,list
              endif else $
                   xmsg,'No sources within Field of View',TITLE=xfmsg
         endif else nfov = 0

         WIDGET_CONTROL, cone_id, /DESTROY

;   Start adding new sources in

         landscape,title='Source Hunting...'
REDO:    isrc      = 0
         name      = ''
         eol       = 0
         j         = 0
         DEG_SET   = keyword_set( DEGREES )
         if Msg_ID ne 0 then begin
              WIDGET_CONTROL, Msg_ID, /DESTROY
              Msg_ID=0
         endif
         if keyword_set( USERSRC ) then begin
              nuser     = N_ELEMENTS( USERSRC )
              nother    = nuser
              srccolor(0:nuser-1)     = linecolors( 1+indgen( nuser ) )
              othersrc(0:nuser-1).name= USERsrc.name
              othersrc(0:nuser-1).RA  = USERsrc.RA
              othersrc(0:nuser-1).DEC = USERsrc.DEC

              RAs       = [ USERsrc.RA ]*!dtor
              DECs      = [ USERsrc.DEC]*!dtor

              for i=0,nuser-1 do begin
                   if nasp eq nbin then $

                        trns = COLLF( module, RAs(i), DECs(i), $
                                      RAY, DEY, RAZ, DEZ ) $

                   else begin

                        if nasp gt 1 then begin
                             trns = GET_TRNS( module, nbin, RAs(i), $
                                              DECs(i), RAY, DEY, RAZ, DEZ )
                        endif else begin
                             xmsg,['WARNING: Only ONE MJF in this scan',$
                                   '-> Cannot determine transmissions', $
                                   'for extra sources.'], TITLE=xfw

                             trns = REPLICATE(0.,nbin)
                        endelse
                   endelse
                   othertrns(*,i)      = trns
              endfor

         endif else begin
              nuser     = 0
              nother    = 0
              srccolor(*)       = 0
              othersrc(*).name  = ''
              othersrc(*).RA    = 0.0
              othersrc(*).DEC   = 0.0
              othertrns         = fltarr(nbin,nsrcmax)
         endelse


NEWSRC:  if j lt nfov then begin
              Action    = 'Display next source'
              name      = fovName(j)
              RA        = fovRA(j)
              DEC       = fovDEC(j)
              flux      = [fluxmin(j),fluxmax(j)]
              srcsep    = dist(j)/60.
              j         = j+1
         endif else begin
           if (j eq nfov) and (eol eq 0) then begin
                Action  = 'Add USER-defined source'
                endlist   = ['Reached end of list',$
                        'of sources in FOV.']
                xmsg, endlist, TITLE=xfmsg
                eol  = 1
                goto, QUERY
           endif else begin
                 Action  = 'Add USER-defined source'
                 udsrc= 'USER-defined source'
                 name = XQUERY( 'Name of source: ', TITLE=udsrc )
                 name = name(0)

                 flux = [0.,0.]
                 if DEG_SET then begin
                      qs   = ['RA  [Degrees]: ','DEC [Degrees]: ']
                      dirs = XQUERY( qs, TITLE=udsrc )
                      RA   = float( qs(0) )
                      DEC  = float( qs(1) )
                 endif else begin
                      qs   = ['RA    [hours]: ', $
                              'RA  [minutes]: ', $
                              'RA  [seconds]: ', $
                              'DEC [degrees]: ', $
                              'DEC [minutes]: ', $
                              'DEC [seconds]: '  ]
                      dirs = XQUERY( qs, TITLE=udsrc )
                      RAhr = float( dirs(0) )
                      RAmin= float( dirs(1) )
                      RAsec= float( dirs(2) )
                      DEChr= float( dirs(3) )
                      DECmin=float( dirs(4) )
                      DECsec=float( dirs(5) )

                      signRA    = sign( RAhr )
                      signDEC   = sign( DEChr )
                      RA   = signRA  * 15.*(abs(RAhr) + RAmin/60. + RAsec/3600.)
                      DEC  = signDEC * (abs(DEChr) + DECmin/60. + DECsec/3600.)
                      xmsg, [ 'RA  [Degrees]:'+strtrim(RA,2), $
                              'DEC [Degrees]:'+strtrim(DEC,2) ], TITLE=udsrc
                 endelse
                 srcRA_rad = srcRA*!dtor
                 srcDEC_rad= srcDEC*!dtor
                 RA_rad    = RA*!dtor
                 DEC_rad   = DEC*!dtor
                 srcsep    = SEPANGLE( srcRA_rad, srcDEC_rad, RA_rad, DEC_rad )
                 srcsep    = srcsep * !radeg
           endelse
         endelse


;   See if next source is the primary

         if srcsep lt 0.001 then begin
              print,'Source ',name,' is the Primary source.'
              if j ne nfov then goto, NEWSRC
         endif

;   Determine the transmissions for the next source on the list

         RAs  = RA*!dtor
         DECs = DEC*!dtor

         if nasp eq nbin then $

              trns = COLLF( module, RAs, DECs, $
                            RAY, DEY, RAZ, DEZ ) $

         else begin

              if nasp gt 1 then begin
                   trns = GET_TRNS( module, nbin, RAs, $
                                    DECs, RAY, DEY, RAZ, DEZ )
              endif else begin
                   xmsg,['WARNING: Only ONE MJF in this scan',$
                         '-> Cannot determine transmissions', $
                         'for extra sources.'], TITLE=xfw

                   trns = REPLICATE(0.,nbin)
              endelse
         endelse

         trnsum    = total( trns )
         if trnsum eq 0 then begin
              print,'Source ',name,' outside scan field of view.'
              if j ne nfov then goto, NEWSRC
         endif

;   First plot the data with the primary source transmission

         plot,cts,psym=10,/xstyle, color=white, $     ;data
              xtitle='Bin',$
              ytitle='Counts/mode', $
              title =title, $
              subtitle='Source:'+name
         src  = avg_bkd + Iavg * trn_src
         oplot,src,color=linecolors(0)                ;primary source

;   Then plot any additional sources added to our list

         for i=0,nother-1 do begin
              src  = avg_bkd + Iavg * othertrns(*,i)
              oplot,src,color=srccolor(i)
         endfor

;   And overplot the next source transmissions

;   Check to see if it has already been added to the list

         here = where( name eq othersrc.name, nfind )
         if name eq '' then nfind = 0
         if nfind eq 0 then begin

              src       = avg_bkd + Iavg * trns
              icolor    = (isrc + 1) MOD ncolors
              oplot,src,color=linecolors(icolor)
              legendstr = LCLEGEND( name, max(flux) )
              legend, legendstr, /right, colors=linecolors(icolor), $
                      textcolors=[white,white], psym=8, /fill
              if !D.NAME eq 'WIN' then wshow

              isrc = isrc + 1

         endif else begin
              print,'Plotting existing sources.'
              goto, NEWSRC
         endelse

         udtxt = [ 'Name of additional source:'+name, $
                   'Distance to primary source [deg]:'+$
                    arr2str(srcsep,3),$
                   'Flux min:'+arr2str(flux(0),4)+' [microJy]',$
                   'Flux max:'+arr2str(flux(1),5)+' [microJy]' ]
         xmsg, udtxt, TITLE=xfmsg, /ALIGN, /LEFT, /BOTTOM, /NOBUTTON, $
               MSG_ID=Msg_ID


;   Query USER whether or not to add this next source to our list

QUERY:   buttons(0) = Action
         rp = XBUTTON( buttons, values, /COLUMN, TITLE='Source Hunting Menu' )
         if Msg_ID ne 0 then begin
              WIDGET_CONTROL, Msg_ID, /DESTROY
              Msg_ID=0
         endif
         case rp of
              'N'  : goto, NEWSRC
              'A'  : begin
                        ; Check to see if it has already been added
                        here = where( name eq othersrc.name, nfind )
                        if nfind ge 1 then $
                             xmsg,'Source already added to list.',TITLE=xfmsg $
                        else begin
                             srccolor(nother)       = linecolors(icolor)
                             othersrc(nother).name  = name
                             othersrc(nother).RA    = RA
                             othersrc(nother).DEC   = DEC
                             othertrns(*,nother)    = trns
                             nother  = nother + 1
                             xmsg,'Added source to list.',TITLE=xfmsg,$
                                  /NOBUTTON, MSG_ID=Msg_ID
                        endelse
                        goto, QUERY
                     end
              'Q'  : begin
                        data = -1
                        if nother gt 0 then data = othersrc(0:nother-1)
                        return, data
                     end
              'R'  : begin
                        xmsg,'Redoing source selection for this scan.',$
                             TITLE=xfmsg, /NOBUTTON, MSG_ID=Msg_ID
                        goto, REDO
                     end
         endcase
end
