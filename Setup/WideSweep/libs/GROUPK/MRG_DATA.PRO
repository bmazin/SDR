;+
; NAME:
;        MRG_DATA
;
; PURPOSE:
;        Merges two or more DATA structures stored in IDL SAVE session files.
;        These files must have been created by FIDCUTS1 version 6.0 or later.
;
; CATEGORY:
;        HEAO A-1.
;
; CALLING SEQUENCE:
;
;        MRG_DATA
; OUTPUTS:
;        The merged DATA structure is saved to a file specified interactively
;        by the USER.
;
; PROCEDURE:
;        This procedure is useful if you have had to break up your IDL data file
;        (.idl) on a particular source into multiple files, creating an IDL
;        SAVE session file (.sav) for each separate file and would like to
;        combine all these .sav files into one file. (e.g. LMC X-1)
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, February 1995.
;        06-AUG-1996    Check if !SAVE_PATH system variable is defined.
;-

function CK_MERGE, data, fn_orig, fn_merge

;   Check the integrity of the merged DATA structure

         Err_title = 'Mrg_DATA ERROR'

         nmerge = N_ELEMENTS( fn_orig )
         npass  = 0
         nfail  = 0
         nscan  = 0
         nbin   = 0L

         for i=0,nmerge-1 do begin

              data0 = Get_DATA(fn_orig(i))

              ; First check variables that should be invariant over all
              ; the DATA structures mereged

              err = data.MODE - data0.MODE
              err = err + (data.MODULE      ne data0.MODULE)
              err = err + (data.name(0)     ne data0.name(0))
              err = err + (data.degree      ne data0.degree)
              err = err + (data.format      ne data0.format)
              err = err + (data.deadtime    ne data0.deadtime)
              err = err + (data.notrns      ne data0.notrns)

              npass0    = data0.npass
              nbin0     = data0.nbin

              i0  = npass
              j0  = nbin

              ; Now, check the variables that should be different over each
              ; DATA structure merged

              err = err + TOTAL( data0.nsig - data.nsig(i0:i0+(npass0-1)) )
              err = err + TOTAL( data0.mjfs - data.mjfs(i0:i0+(npass0-1)) )
              err = err + TOTAL( data0.nmjfs- data.nmjfs(i0:i0+(npass0-1)))
              err = err + TOTAL( data0.sig  - data.sig(j0:j0+(nbin0-1)))
              err = err + TOTAL( data0.cts  - data.cts(j0:j0+(nbin0-1)))
              err = err + TOTAL( data0.bkd  - data.bkd(j0:j0+(nbin0-1)))
              err = err + TOTAL( data0.trns(*,0) - $
                                 data.trns(j0:j0+(nbin0-1),0))
              err = err + TOTAL( data0.intensity(*,0) - $
                                 data.intensity(i0:i0+(npass0-1),0))
              err = err + TOTAL( data0.sigma(*,0) - $
                                 data.sigma(i0:i0+(npass0-1),0))
              err = err + TOTAL( data0.pk_bins(*,0) - $
                                 data.pk_bins(i0:i0+(npass0-1),0))
              err = err + TOTAL( data0.t77i(*,0) - $
                                 data.t77i(i0:i0+(npass0-1),0))
              err = err + TOTAL( data0.t77f(*,0) - $
                                 data.t77f(i0:i0+(npass0-1),0))
              err = err + TOTAL( data0.tcorr(0,*,0) - $
                                 data.tcorr(0,i0:i0+(npass0-1),0))
              err = err + TOTAL( data0.tcorr(1,*,0) - $
                                 data.tcorr(1,i0:i0+(npass0-1),0))

              npass = npass + data0.npass
              nfail = nfail + data0.nfail
              nscan = nscan + data0.nscan
              nbin  = nbin  + data0.nbin
              data0 = 0
         endfor

         ; Finally, check the cumulative variables

         err  = err + (data.npass ne npass)
         err  = err + (data.nfail ne nfail)
         err  = err + (data.nscan ne nscan)
         err  = err + (data.nbin  ne nbin)

         if err ne 0 then $
              xmsg,['BAD merged DATA structure!',$
                    'Discrepancy found in variables between',$
                    'merged DATA structure and one of the original',$
                    'DATA structures stored in the following IDL SAVE',$
                    'session file:',$
                    fn_orig(i)],$
                   TITLE=Err_title
         if err ne 0 then return, 0 else return, 1

end


function CK_TAGS, tags, Flag, NO_MSG=No_MSG

;   Check the existence of Flag in the tags array

         Err_title = 'Mrg_DATA ERROR'

         here = where( tags eq Flag, n )

         if (n eq 0) and (NOT keyword_set(No_MSG)) then $
              xmsg,['File UNRECOGNIZED as a IDL SAVE',$
                    'session file created by FIDCUTS1.',$
                    '',$
                    'Could not find the tag: '+Flag,$
                    'in the DATA structure'],$
                    TITLE=Err_title
         return, n
end


pro MRG_DATA

         Err_title = 'Mrg_DATA ERROR'
         Gen_title = 'Mrg_DATA'

         rp   = OKCANCEL(['This routine will merge two or more',$
                          'DATA structures from IDL SAVE session',$
                          'files created by FIDCUTS1'],$
                          TITLE=Gen_title )

         if rp eq -1 then return


         FLAGS = ['MODE',$
                  'MODULE',$
                  'NPASS',$
                  'NFAIL',$
                  'NSCAN',$
                  'NBIN',$
                  'NSIG',$
                  'NSIG_SRC',$
                  'NSRC',$
                  'NAME',$
                  'DEGREE',$
                  'MJFS',$
                  'NMJFS',$
                  'SIG',$
                  'CTS',$
                  'BKD',$
                  'BKD_COEFF',$
                  'TRNS',$
                  'PK_BINS',$
                  'PK_TRNS',$
                  'OVERLAP',$
                  'T77I',$
                  'T77F',$
                  'FIDCUTS1',$
                  'MJF_RNG',$
                  'BAD_MJFS',$
                  'FORMAT',$
                  'DEADTIME',$
                  'VERSION', $
                  'INTENSITY',$
                  'SIGMA',$
                  'TCORR',$
                  'ASPECTS' ]
         nFLAGS = N_ELEMENTS(FLAGS)


         nmerge = 0
         defsysv,'!SAVE_PATH',EXISTS=defined
         if (NOT defined) then defsysv,'!SAVE_PATH',''

NOFILES: file1= PICKFILE( PATH=!SAVE_PATH, FILTER='*.sav',$
                          TITLE='Select File to Merge' )
         if file1 eq '' then return
         delim = RSTRPOS(file1,'\')
         if (delim eq -1) then delim = RSTRPOS(file1,'/')
         if (delim ne -1) then defsysv,'!SAVE_PATH',STRMID(file1,0,delim+1)

;   Restore SAV file

         data1 = Get_DATA( file1 )
         tags1 = TAG_NAMES( data1 )

;   Check integrity of the SAV file

         xmsg,'Checking integrity of the SAV file...',$
              TITLE=Gen_title,/NOBUTTON,MSG_ID=Msg_ID

         for i=0,nFLAGS-1 do begin

             if NOT CK_TAGS( tags1, FLAGS(i) ) then begin
                   WIDGET_CONTROL, Msg_ID, /DESTROY
                   xmsg,'BAD SAV file',TITLE=Err_title
                   goto, NOFILES
             endif
         endfor
         WAIT,0.5
         WIDGET_CONTROL, Msg_ID, /DESTROY

         qs     = ['Keep Additional Source Information',$
                   'Discard Additional Source Information']
         rp_mrg = XBUTTON(qs,/COLUMN,/CENTER,$
                        TITLE='Additional Source Info in Merged DATA?')
         if rp_mrg(0) eq 0 then nsrc_keep = data1.nsrc $
         else nsrc_keep = 1


ADDFILE: file2= PICKFILE( PATH=!SAVE_PATH, FILTER='*.sav',$
                          TITLE='Select File to Merge' )
         if file2 eq '' then goto, QUIT

;   Restore SAV file

         data2 = Get_DATA( file2 )
         tags2 = TAG_NAMES( data2 )

;   Check integrity of the SAV file

         xmsg,'Checking integrity of the SAV file...',$
              TITLE=Gen_title,/NOBUTTON,MSG_ID=Msg_ID

         for i=0,nFLAGS-1 do begin
             if NOT CK_TAGS( tags2, FLAGS(i) ) then begin
                   WIDGET_CONTROL, Msg_ID, /DESTROY
                   xmsg,'BAD SAV file',TITLE=Err_title
                   goto, ADDFILE
             endif
         endfor
         WAIT,0.5
         WIDGET_CONTROL, Msg_ID, /DESTROY

;   Get MERGED OUTPUT filename

         if nmerge eq 0 then begin
              ofile= PICKFILE( PATH=!SAVE_PATH, FILTER='*.sav', $
                               FILE=!SAVE_PATH+'merge.sav', $
                               TITLE='Select Name of Merged OUTPUT File' )
              if ofile eq '' then return
         endif

;   Get Final USER Approval

         rp   = OKCANCEL( ['Merging the following files:',$
                           '',$
                            file1,$
                            file2,$
                           '',$
                           'into',$
                           '',$
                           ofile],$
                           TITLE=Gen_title )

;   Make sure the DATA structures are compatible

         CASE rp OF
              0    :  if nmerge eq 0 then goto, NOFILES else goto, ADDFILE
              1    :
             -1    :  goto, QUIT
         ENDCASE

         xmsg,'Checking compatibility of the two SAV files...',$
              TITLE=Gen_title,/NOBUTTON,MSG_ID=Msg_ID

         MERGE_CK= ['MODE',$
                  'MODULE',$
                  'DEGREE',$
                  'FORMAT',$
                  'NOTRNS',$
                  'DEADTIME',$
                  'NAME(0)']

         nMERGE_CK = N_ELEMENTS( MERGE_CK )
         mck       = strarr( nMERGE_CK, 2 )

         mck(0,0)  = strtrim(data1.MODE,2)
         mck(0,1)  = strtrim(data2.MODE,2)

         mck(1,0)  = strtrim(data1.MODULE,2)
         mck(1,1)  = strtrim(data2.MODULE,2)

         mck(2,0)  = strtrim(data1.DEGREE,2)
         mck(2,1)  = strtrim(data2.DEGREE,2)

         mck(3,0)  = strtrim(data1.FORMAT,2)
         mck(3,1)  = strtrim(data2.FORMAT,2)

         mck(4,0)  = strtrim(data1.NOTRNS,2)
         mck(4,1)  = strtrim(data2.NOTRNS,2)

         mck(5,0)  = strtrim(data1.DEADTIME,2)
         mck(5,1)  = strtrim(data2.DEADTIME,2)

         mck(6,0)  = strtrim(data1.NAME(0),2)
         mck(6,1)  = strtrim(data2.NAME(0),2)

         for i=0,nMERGE_CK-1 do begin
              if (mck(i,0) ne mck(i,1)) then begin
                 WIDGET_CONTROL, MSG_ID, /DESTROY
                 xmsg,['The data structures must have idential '+$
                                                      MERGE_CK(i)+'s',$
                       '',$
                       file1+' -> '+MERGE_CK(i)+':'+mck(i,0),$
                       file2+' -> '+MERGE_CK(i)+':'+mck(i,1)],$
                       TITLE=Err_title
                 if nmerge eq 0 then goto, NOFILES else goto, ADDFILE
              endif
         endfor
         mck       = 0


;   Check additional source information

         if nsrc_keep gt 1 then begin
              nsrc1     = data1.nsrc
              nsrc2     = data2.nsrc

              name1     = data1.name
              name2     = data2.name

              src_conflict = 0
              if nsrc1 eq nsrc2 then begin
                   for i=0,nsrc1-1 do $
                        if name1(i) ne name2(i) then src_conflict = 1
              endif else src_conflict = 1

              if src_conflict then begin
                   rp_src    = OKCANCEL( ['Names of the additional sources',$
                                          'do NOT agree between the two DATA',$
                                          'structures.',$
                                          '',$
                                          'All additional source information',$
                                          'will be discarded'],$
                                          TITLE='Mrg_DATA WARNING' )
                   nsrc_keep = 1
              endif
         endif


;   Same VERSION?

         ver1 = data1.VERSION
         ver2 = data2.VERSION
         if ver1 ne ver2 then begin
              rp_ver = YNCANCEL(['The data structures from the two ',$
                                 'IDL SAVE session files were created with',$
                                 'different versions of FIDCUTS1:',$
                                 '',$
                                 file1+' -> Version:'+arr2str(ver1,2),$
                                 file2+' -> Version:'+arr2str(ver2,2),$
                                 '',$
                                 'Proceed with merge?'],$
                                 TITLE='Mrg_DATA WARNING')
              if rp_ver ne 1 then begin
                   WIDGET_CONTROL, MSG_ID, /DESTROY
                   if nmerge eq 0 then goto, NOFILES else goto, ADDFILE
              endif
              xmsg,'The merged file will contain the LATER version number',$
                    TITLE=Gen_title
         endif
         VERSION   = ver1 > ver2
         WAIT,0.5
         WIDGET_CONTROL, MSG_ID, /DESTROY


;   Okay, everything's clear to start merging the data structures:

         xmsg,'Merging DATA structures...',TITLE=Gen_title,$
              /NOBUTTON,MSG_ID=MSG_ID

         NPASS= data1.npass+data2.npass
         NBIN = data1.nbin +data2.nbin
         NSRC = nsrc_keep

         MODE      = data1.mode
         MODULE    = data1.module
         NFAIL     = data1.nfail+data2.nfail
         NSCAN     = data1.nscan+data2.nscan
         NSIG      = [data1.nsig,data2.nsig]
         NAME      = [data1.name(0:nsrc_keep-1)]
         DEGREE    = data1.degree
         MJFS      = [data1.mjfs,data2.mjfs]
         NMJFS     = [data1.nmjfs,data2.nmjfs]
         TRNS      = fltarr(NBIN,NSRC_KEEP,/NOZERO)
         FIDCUTS1  = data1.fidcuts1
         FORMAT    = data1.format
         NOTRNS    = data1.notrns
         DEADTIME  = data1.deadtime

         BKD_COEFF = fltarr(NPASS,data1.DEGREE+1,/NOZERO)
         for i=0,data1.DEGREE do begin
              BKD_COEFF(*,i) = [REFORM(data1.bkd_coeff(*,i)),$
                                REFORM(data2.bkd_coeff(*,i))]
         endfor

         MJF_RNG   = data1.mjf_rng
         if N_ELEMENTS(MJF_RNG) eq 1 then MJF_RNG=data2.mjf_rng $
         else begin
              if N_ELEMENTS(data2.mjf_rng) gt 1 then begin
                   MJF_RNG=[MJF_RNG(0)<data2.mjf_rng(0), $
                            MJF_RNG(1)>data2.mjf_rng(1)]
              endif
         endelse

         BAD_MJFS = [data1.bad_mjfs,data2.bad_mjfs]
         hbad     = WHERE( BAD_MJFS gt 0, nbad )
         if nbad eq 0 then BAD_MJFS = 0 $
         else begin
              BAD_MJFS  = BAD_MJFS(hbad)
              BAD_MJFS  = BAD_MJFS(SORT(BAD_MJFS))
         endelse

         ASPECTS   = { y:dblarr(2,NPASS,/NOZERO), z:dblarr(2,NPASS,/NOZERO) }
         for i=0,1 do begin
              ASPECTS.y(i,*) = [REFORM(data1.aspects.y(i,*)),$
                                REFORM(data2.aspects.y(i,*))]
              ASPECTS.z(i,*) = [REFORM(data1.aspects.z(i,*)),$
                                REFORM(data2.aspects.z(i,*))]
         endfor

         NSIG_SRC  = intarr(NPASS,NSRC_KEEP,/NOZERO)
         INTENSITY = fltarr(NPASS,NSRC_KEEP,/NOZERO)
         SIGMA     = fltarr(NPASS,NSRC_KEEP,/NOZERO)
         PK_BINS   = fltarr(NPASS,NSRC_KEEP,/NOZERO)
         PK_TRNS   = fltarr(NPASS,NSRC_KEEP,/NOZERO)
         OVERLAP   = fltarr(NPASS,NSRC_KEEP,/NOZERO)
         T77I      = lonarr(NPASS,NSRC_KEEP,/NOZERO)
         T77F      = dblarr(NPASS,NSRC_KEEP,/NOZERO)
         TCORR     = dblarr(2,NPASS,NSRC_KEEP,/NOZERO)
         for k=0,NSRC_KEEP-1 do begin
              NSIG_SRC(*,k)  = [data1.nsig_src(*,k),data2.nsig_src(*,k)]
              INTENSITY(*,k) = [data1.intensity(*,k),data2.intensity(*,k)]
              SIGMA(*,k)     = [data1.sigma(*,k),data2.sigma(*,k)]
              PK_BINS(*,k)   = [data1.pk_bins(*,k),data2.pk_bins(*,k)]
              PK_TRNS(*,k)   = [data1.pk_trns(*,k),data2.pk_trns(*,k)]
              OVERLAP(*,k)   = [data1.overlap(*,k),data2.overlap(*,k)]
              T77I(*,k)      = [data1.t77i(*,k),data2.t77i(*,k)]
              T77F(*,k)      = [data1.t77f(*,k),data2.t77f(*,k)]
              for l=0,1 do $
                   TCORR(l,*,k)   = [REFORM(data1.tcorr(l,*,k)),$
                                     REFORM(data2.tcorr(l,*,k))]
         endfor

;   These take MEGA-amounts of memory, so let's release some memory taken
;   by the data1 and data2 structures

         SIG       = [data1.sig,data2.sig]
         CTS       = [data1.cts,data2.cts]
         BKD       = [data1.bkd,data2.bkd]
         for k=0,NSRC_KEEP-1 do begin
              TRNS(*,k)      = [data1.trns(*,k),data2.trns(*,k)]
         endfor
         data1     = 0
         data2     = 0

         data = { $
                   MODE           :temporary(MODE)          ,$
                   MODULE         :temporary(MODULE)        ,$
                   NPASS          :temporary(NPASS)         ,$
                   NFAIL          :temporary(NFAIL)         ,$
                   NSCAN          :temporary(NSCAN)         ,$
                   NBIN           :temporary(NBIN)          ,$
                   NSIG           :temporary(NSIG)          ,$
                   NSIG_SRC       :temporary(NSIG_SRC)      ,$
                   NSRC           :temporary(NSRC)          ,$
                   NAME           :temporary(NAME)          ,$
                   DEGREE         :temporary(DEGREE)        ,$
                   MJFS           :temporary(MJFS)          ,$
                   NMJFS          :temporary(NMJFS)         ,$
                   SIG            :temporary(SIG)           ,$
                   CTS            :temporary(CTS)           ,$
                   BKD            :temporary(BKD)           ,$
                   BKD_COEFF      :temporary(BKD_COEFF)     ,$
                   TRNS           :temporary(TRNS)          ,$
                   PK_BINS        :temporary(PK_BINS)       ,$
                   PK_TRNS        :temporary(PK_TRNS)       ,$
                   OVERLAP        :temporary(OVERLAP)       ,$
                   T77I           :temporary(T77I)          ,$
                   T77F           :temporary(T77F)          ,$
                   FIDCUTS1       :temporary(FIDCUTS1)      ,$
                   MJF_RNG        :temporary(MJF_RNG)       ,$
                   BAD_MJFS       :temporary(BAD_MJFS)      ,$
                   FORMAT         :temporary(FORMAT)        ,$
                   NOTRNS         :temporary(NOTRNS)        ,$
                   DEADTIME       :temporary(DEADTIME)      ,$
                   VERSION        :temporary(VERSION)       ,$
                   INTENSITY      :temporary(INTENSITY)     ,$
                   SIGMA          :temporary(SIGMA)         ,$
                   TCORR          :temporary(TCORR)         ,$
                   ASPECTS        :temporary(ASPECTS)        $
                }

         if nmerge eq 0 then begin
              nmerge = 2
              fn_orig= [file1,file2]
         endif else begin
              nmerge = nmerge + 1
              fn_orig= [fn_orig,file2]
         endelse

         WAIT,0.5
         WIDGET_CONTROL,MSG_ID,/DESTROY

         rp_add = YNCANCEL(['DATA structures merge successful.',$
                            '',$
                            'Merge an additional DATA structure?'],$
                            TITLE=Gen_title)
         if rp_add eq 1 then begin
              data1 = TEMPORARY(data)
              data  = 0
              file1 = ofile
              goto, ADDFILE
         endif
QUIT:

;   Save the merged DATA structure to file

         xmsg,'Saving merged DATA structure to file...',TITLE=Gen_title,$
              /NOBUTTON,MSG_ID=Msg_ID

         SAVE,data,FILENAME=ofile

         xmsg,'Saving merged DATA structure to file... completed.',$
              TITLE=Gen_title, /NOBUTTON, MSG_ID=Msg_ID_END
         WIDGET_CONTROL,Msg_ID,/DESTROY
         WAIT,0.5
         WIDGET_CONTROL,Msg_ID_END,/DESTROY

         xmsg,['Number of DATA structures merged:'+strtrim(nmerge,2),$
               'Merged DATA structure save to file:',$
                ofile], TITLE=Gen_title

;   Check integrity of the merged DATA structure

         xmsg,'Checking integrity of merged DATA structure...',$
              TITLE=Gen_title, /NOBUTTON, MSG_ID=Msg_ID
         wait,1

         status = CK_MERGE( data, fn_orig, ofile )
         if status ne 1 then return

         xmsg,'Checking integrity of merged DATA structure...OK.',$
              TITLE=Gen_title, /NOBUTTON, MSG_ID=Msg_ID_END
         WIDGET_CONTROL,Msg_ID,/DESTROY
         WAIT,1
         WIDGET_CONTROL,Msg_ID_END,/DESTROY

         data=0
         data1=0
end
