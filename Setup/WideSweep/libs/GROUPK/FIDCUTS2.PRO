;+
; NAME:
;        FIDCUTS2
;
; PURPOSE:
;        Apply second round of fiducial cuts to the HEAO A-1 Scanning data.
;
; CATEGORY:
;        HEAO A-1 Scanning.
;
; CALLING SEQUENCE:
;
;        FIDCUTS2 [,Cuts]
;
; OPTIONAL INPUTS:
;
;        Cuts:     A 4-element array of cuts to be applied to the data, with
;                  the following definitions:
;
;                  Cuts(0) =    Cut on the |background slope|
;                  Cuts(1) =    Cut on the number of signal bins
;                  Cuts(2) =    Cut on the overlap fraction
;                  Cuts(3) =    Cut on the transmission peak minimum
;
; OUTPUTS:
;        This procedure writes out a new IDL SAVE session file containing the
;        scans which have passed the second round of fiducial cuts. The USER
;        is prompted for the filename of this IDL SAVE session file.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, February 1995.
;        06-AUG-1996    Check if !SAVE_PATH system variable is defined.
;-
pro FIDCUTS2, Cuts

         NP        = N_PARAMS()
         NCUTS     = 4

         if NP eq 1 then begin
              if N_ELEMENTS(Cuts) ne NCUTS then $
                   message,'Input array must have '+strtrim(NCUTS,2)+$
                           ' elements'
         endif

         P_MULTI   = !P.Multi
         !P.Multi  = 0

         title     = 'FidCuts2'
         title_err = title+' ERROR'

NEWFILE: data0= GET_DATA(ofile=file)

         tags = TAG_NAMES(data0)
         h    = WHERE( tags eq 'FIDCUTS2', n)
         if n gt 0 then begin
              xmsg,['Sorry, this IDL SAVE session file',$
                    'has already had FIDCUTS2 applied to it.'],$
                    TITLE=title_err
              return
         endif

         vers = 0
         h    = WHERE( tags eq 'VERSION', n)
         if n ne 0 then vers = data0.version
         if (n eq 0) or (vers lt 6.0) then begin
              xmsg,['Sorry, this IDL SAVE session file',$
                    'was not created by FITCUTS1, version 6.0 or later.'],$
                    TITLE=title_err
              return
         endif

         nsrc = data0.nsrc
         npass= data0.npass
         name = [data0.name,'New SAVE File','Quit']

NEWSRC:  isrc = XBUTTON(name,TITLE='Select',/COLUMN,/CENTER)
         CASE name(isrc) OF
              'New SAVE File': goto, NEWFILE
              'Quit'         : goto, QUIT
              else           :
         ENDCASE

;   Extract relevant variables and arrays

         t77i = data0.t77i(*,isrc)
         t77f = data0.t77f(*,isrc)
         tcorr= 0.5*REFORM(data0.tcorr(0,*,isrc)+data0.tcorr(1,*,isrc))
         time = t77i+t77f+tcorr
         tday = time/86400.

         slopes    = REFORM(data0.bkd_coeff(*,1))
         nsig_src  = data0.nsig_src(*,isrc)
         overl     = data0.overlap(*,isrc)
         pk_trns   = data0.pk_trns(*,isrc)
         flux      = data0.intensity(*,isrc)
         sigf      = data0.sigma(*,isrc)

         if (NP eq 1) and (N_ELEMENTS( here1 ) ne 0) then begin
              sl_cut    = Cuts(0)
              nsig_cut  = Cuts(1)
              over_cut  = Cuts(2)
              trn_cut   = Cuts(3)
              goto, APPLY
         endif

         if N_ELEMENTS( here1 ) ne 0 then begin
              CASE YNCANCEL('Use existing CUTS?',TITLE=Title) OF
                   1 : goto, APPLY
                   0 :
                  -1 : goto, NEWSRC
              ENDCASE
         endif


;   CUT#1:    Background slope

         sl_cut_def= 0.04
         if NOT YNCANCEL('Accept background slope cut: '+$
                          arr2str(sl_cut_def,2)+'?', TITLE=title ) then begin

              plot,tday,abs(slopes),psym=10,/ynozero,/xstyle,$
                   XTITLE='Time [Days]',$
                   YTITLE='|Fitted Backgroud Slopes|',$
                   TITLE ='CUT#1: Background slope', $
                   SUBTITLE='File: '+file
              h = hist1d( abs(slopes),BINSIZE=0.01,OBIN=sl_bin)
              xplot,sl_bin,h,psym=10,/xstyle,$
                   XTITLE='Abs(Fitted Background Slope)',$
                   YTITLE='Frequency',$
                   TITLE ='CUT#1: Background slope', $
                   SUBTITLE='File: '+file,$
                   WINDOW=1,$
                   /NO_MENU


              sl_cut    = MRK_LINE(/STATUS,/HELP,/VERTICAL,/ERASE)
              sl_cut    = float(arr2str(sl_cut,1))

              sl_rp     = XQUERY( 'CUT#1: Background slope:', DEFAULT=sl_cut,$
                                  TITLE=Title )
              sl_cut    = sl_rp(0)
              xoplot,[sl_cut,sl_cut],[0,2.*MAX(h)]
              wset,0
         endif else sl_cut = sl_cut_def


;   CUT#2:    Nsignal bins

         nsig_cut_def = 36
         if NOT YNCANCEL('Accept # signal bins cut: '+$
                          strtrim(nsig_cut_def,2), TITLE=title ) then begin

              plot,tday,nsig_src,psym=10,/ynozero,/xstyle,$
                   XTITLE='Time [Days]',$
                   YTITLE='# signal bins for this source',$
                   TITLE ='Nsignal bins for source: '+data0.name(isrc),$
                   SUBTITLE='File: '+file
              h = hist1d( nsig_src,OBIN=nsig_bin )
              xplot,nsig_bin,h,psym=10,/xstyle,$
                   XTITLE='Number of Signal bins',$
                   YTITLE='Frequency',$
                   TITLE ='CUT#2: Nsignal bins for '+data0.name(isrc), $
                   SUBTITLE='File: '+file,$
                   WINDOW=1,$
                   /NO_MENU
              nsig_cut    = ROUND(MRK_LINE(/STATUS,/HELP,/VERTICAL,/ERASE))
              nsig_qry    = XQUERY( 'CUT#2: Nsignal bins for '+data0.name(isrc), $
                                    DEFAULT=nsig_cut, TITLE=Title )
              nsig_cut    = nsig_qry(0)
              xoplot,[nsig_cut,nsig_cut],[0,2.*MAX(h)]
              wset,0
         endif else nsig_cut = nsig_cut_def


;   CUT#3:    Overlap region

         over_cut_def = 0.80
         if NOT YNCANCEL('Accept Overlap cut: '+$
                          strtrim(over_cut_def,2), TITLE=title ) then begin
              plot,tday,overl,psym=10,/ynozero,/xstyle,$
                   XTITLE='Time [Days]',$
                   YTITLE='Overlap fraction for this source',$
                   TITLE ='Overlap fraction for source: '+data0.name(isrc),$
                   SUBTITLE='File: '+file
              h = hist1d( overl,BINSIZE=0.02,OBIN=over_bin, MIN=0 )
              xplot,over_bin,h,psym=10,/xstyle,$
                   XTITLE='Overlap fraction',$
                   YTITLE='Frequency',$
                   TITLE ='CUT#3: Overlap fraction for '+data0.name(isrc), $
                   subtitle='File: '+file,$
                   WINDOW=1,$
                   /NO_MENU
              over_cut    = MRK_LINE(/STATUS,/HELP,/VERTICAL,/ERASE)
              over_cut    = float(arr2str(over_cut,1))

              over_qry    = XQUERY( 'CUT#3: Overlap fraction for '+$
                                    data0.name(isrc), $
                                    DEFAULT=over_cut, TITLE=Title )
              over_cut    = over_qry(0)
              xoplot,[over_cut,over_cut],[0,2.*MAX(h)]
              wset,0
         endif else over_cut = over_cut_def

;   CUT#4:    Transmission Peak cutoff

         trn_cut_def    = 0.10
         if NOT YNCANCEL('Accept Trns Peak cut: '+$
                          strtrim(trn_cut_def,2), TITLE=title ) then begin

              plot,tday,pk_trns,psym=10,/ynozero,/xstyle,$
                   xtitle='Time [Days]',$
                   ytitle='Peak Transmission/scan',$
                   title ='Peak Transmission/scan for '+data0.name(isrc),$
                   subtitle='File: '+file
              h = hist1d( pk_trns,BINSIZE=0.025,OBIN=trn_bin, MIN=0 )
              xplot,trn_bin,h,psym=10,/xstyle,$
                   XTITLE='Peak Transmission/scan',$
                   YTITLE='Frequency',$
                   TITLE ='CUT#4: Transmission Peak cutoff for '+$
                             data0.name(isrc), $
                   SUBTITLE='File: '+file,$
                   WINDOW=1,$
                   /NO_MENU
              trn_cut   = MRK_LINE(/STATUS,/HELP,/VERTICAL,/ERASE)
              trn_cut   = float(arr2str(trn_cut,1))

              trn_qry   = XQUERY( 'CUT#4: Transmission Peak cutoff for '+$
                                       data0.name(isrc), $
                                       DEFAULT=trn_cut, TITLE=Title )
              trn_cut    = trn_qry(0)
              xoplot,[trn_cut,trn_cut],[0,2.*MAX(h)]
              wset,0
         endif else trn_cut = trn_cut_def

APPLY:   here1     = where( abs(slopes) gt sl_cut, n1 )
         here2     = where( nsig_src lt nsig_cut, n2)
         here3     = where( overl gt over_cut, n3)
         here4     = where( pk_trns lt trn_cut, n4 )

         hbad      = -1
         if here1(0) ne -1 then hbad = here1
         if hbad(0) ne -1  then hbad = [hbad,here2]
         if hbad(0) ne -1  then hbad = [hbad,here3]
         if hbad(0) ne -1  then hbad = [hbad,here4]

         htmp      = hbad(SORT(hbad))
         ntmp      = N_ELEMENTS(htmp)
         j         = 1
         hbad(0)   = htmp(0)
         for i=1,ntmp-1 do begin
              if htmp(i) ne htmp(i-1) then begin
                   hbad(j) = htmp(i)
                   j    = j+1
              endif
         endfor
         htmp      = 0

         nbad      = j
         hbad      = hbad(0:nbad-1)

         hgood     = indgen(npass)
         j         = 0
         for i=0,npass-1 do begin
              h    = where( i eq hbad, nm )
              if (nm eq 0) then begin
                   hgood(j)=i
                   j=j+1
              endif
         endfor
         ngood     = j
         hgood     = hgood(0:ngood-1)

         xmsg,['Summary of Results:',$
               '',$
               'Number of scans REJECTED: '+strtrim(nbad,2),$
               'Number of scans ACCEPTED: '+strtrim(ngood,2) ],$
               TITLE=Title

         !P.multi=[0,1,2]
         t0= tday(hgood(0)) < tday(hbad(0))
         tf= tday(hgood(ngood-1)) > tday(hbad(nbad-1))
         xplot,tday(hgood),flux(hgood),sigf(hgood),psym=1,$
              XRANGE=[t0,tf],$
              XTITLE='Time [Days]',$
              YTITLE='Counts/320ms',$
              TITLE ='Accepted Data for '+data0.name(isrc),$
              SUBTITLE='File: '+file,$
              /PORTRAIT, WINDOW=0, $
              /XSTYLE
         xplot,tday(hbad),flux(hbad),sigf(hbad),psym=1,$
              XRANGE=[t0,tf],$
              XTITLE='Time [Days]',$
              YTITLE='Counts/320ms',$
              TITLE ='Rejected Data for '+data0.name(isrc),$
              SUBTITLE='File: '+file,$
              /PORTRAIT,$
              /XSTYLE


         if ngood eq 0 then goto, SKIP

         Bad_MJFS = data0.Bad_MJFS
         if nbad gt 0 then begin
              if Bad_MJFS(0) eq -1 then Bad_MJFS = data0.mjfs(hbad) $
              else begin
                   Bad_MJFS = [Bad_MJFS,data0.mjfs(hbad)]
                   hMJFS    = SORT( Bad_MJFS )
                   Bad_MJFS = Bad_MJFS(hMJFS)
              endelse
         endif

         nbin = 0
         sig  = -1
         cts  = -1
         bkd  = -1
         trns = -1

         if ngood gt 0 then begin
              j    = hgood(0)
              nsig = data0.nsig(j)
              nbin = long(nsig)
              if (j eq 0) then i0=0 else i0 = TOTAL( data0.nsig(0:j-1) )
              sig  = data0.sig(i0:i0+nsig-1)
              cts  = data0.cts(i0:i0+nsig-1)
              bkd  = data0.bkd(i0:i0+nsig-1)
              trns = data0.trns(i0:i0+nsig-1)
         endif
         for i=1,ngood-1 do begin
              j    = hgood(i)
              nsig = data0.nsig(j)
              nbin = nbin+nsig
              i0   = TOTAL( data0.nsig(0:j-1) )
              sig  = [sig,data0.sig(i0:i0+nsig-1)]
              cts  = [cts,data0.cts(i0:i0+nsig-1)]
              bkd  = [bkd,data0.bkd(i0:i0+nsig-1)]
              trns = [trns,data0.trns(i0:i0+nsig-1)]
         endfor
         fidcuts2  = {  bkd_slope:sl_cut,   $
                        nsig_src :nsig_cut, $
                        overlap  :over_cut, $
                        pk_trn   :trn_cut   }

         Data =   {      mode  : data0.mode,                    $
                       module  : data0.module,                  $
                        npass  : data0.npass-nbad,              $
                        nfail  : data0.nfail+nbad,              $
                        nscan  : data0.nscan,                   $
                         nbin  : nbin,                          $
                         nsig  : [data0.nsig(hgood)],           $
                     nsig_src  : [data0.nsig_src(hgood,isrc)],  $
                         nsrc  : 1,                             $
                         name  : [data0.name(isrc)],            $
                       degree  : data0.degree,                  $
                         mjfs  : [data0.mjfs(hgood)],           $
                        nmjfs  : [data0.nmjfs(hgood)],          $
                          sig  : temporary(sig),                $
                          cts  : temporary(cts),                $
                          bkd  : temporary(bkd),                $
                    bkd_coeff  : [data0.bkd_coeff(hgood,*)],    $
                         trns  : temporary(trns),               $
                      pk_bins  : [data0.pk_bins(hgood,isrc)],   $
                      pk_trns  : [data0.pk_trns(hgood,isrc)],   $
                      overlap  : [data0.overlap(hgood,isrc)],   $
                         t77i  : [data0.t77i(hgood,isrc)],      $
                         t77f  : [data0.t77f(hgood,isrc)],      $
                     fidcuts1  : data0.fidcuts1,                $
                      MJF_RNG  : data0.MJF_rng,                 $
                     Bad_MJFS  : Bad_MJFS,                      $
                       FORMAT  : data0.Format,                  $
                       NOTRNS  : data0.Notrns,                  $
                     DEADTIME  : data0.deadtime,                $
                      VERSION  : data0.version,                 $
                    intensity  : [data0.intensity(hgood,isrc)], $
                        sigma  : [data0.sigma(hgood,isrc)],     $
                        tcorr  : [data0.tcorr(*,hgood,isrc)],   $
                      aspects  : { y:data0.aspects.y(*,hgood),  $
                                   z:data0.aspects.z(*,hgood) },$
                     fidcuts2  : fidcuts2                       $
                  }

;   Superficially compare the new Data structure with the old

         ntags = N_ELEMENTS(Tags)
         tags_new = TAG_NAMES(Data)
         if ntags ne (N_ELEMENTS(tags_new)-1) then $
              message,'Error in creating new DATA structure.'
         for i=0,ntags-1 do begin
              if tags(i) ne tags_new(i) then $
                   message,'Conflict between NEW and OLD DATA structures.'
         endfor

         defsysv,'!SAVE_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!SAVE_PATH',''
         file=pickfile(PATH=!SAVE_PATH,FILTER='*.sav',$
                        TITLE='Select OUTPUT IDL SAVE session filename')

         if (File ne '') then begin
              delim = RSTRPOS(File,'\')
              if (delim eq -1) then delim = RSTRPOS(File,'/')
              if (delim ne -1) $
              then defsysv,'!SAVE_PATH',STRMID(File,0,delim+1)
         endif
         save, data, FILENAME=file
         data = 0

SKIP:    goto, NEWSRC

QUIT:    !P.Multi  = P_MULTI

;   Now, free up some memory

         data      = 0
         t77i      = 0
         t77f      = 0
         tcorr     = 0
         time      = 0
         tday      = 0
         slopes    = 0
         nsig_src  = 0
         overl     = 0
         pk_trns   = 0
         flux      = 0
         sigf      = 0

         nbin      = 0
         sig       = 0
         cts       = 0
         bkd       = 0
         trns      = 0
         hgood     = 0
         hbad      = 0
         here1     = 0
         here2     = 0
         here3     = 0
         here4     = 0
         h         = 0
         sl_bin    = 0
         nsig_bin  = 0
         over_bin  = 0
         trn_bin   = 0
end




