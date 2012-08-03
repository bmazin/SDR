;+
; NAME:
;        CTIFMT
;
; PURPOSE:
;
;        This routine concatenates and corrects all the data contained
;        in a PTI file (created by HBRFMT).  All Adjacent Photon Events (APE)
;        and any photons in BAD minor frames are removed.  A BAD minor frame
;        occurs when there are one or more HBRSYNC errors (e.g. missing MNFs,
;        Clock TicTok errors, sync loss, etc).  This concatenated and corrected
;        data is then written to a binary file in the Concatenated Time
;        Interval (CTI) format.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        CTIFMT, FILES=Files, PTIPATH=PTIPath, CTIPATH=CTIpath
;
; INPUT KEYWORD PARAMETERS:
;
;        FILES:    A array of filenames for each raw HBR digitized file.
;
;        PTIPATH:  Path to the specified input PTI files, (''=Default).
;
;        CTIPATH:  Path to the output CTI files, (''=Default).
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        QUIET:    Suppress all print messages to the display, (0=Default).
;
; OUTPUTS:
;        The Concatenated Time Interval (CTI) format consists of 19 variable
;        length records.  The first record contains a sequence of numbers:
;        [0,1,2...511] that may be used to determine the byte order of the
;        binary file relative to your current platform. Each subsequent
;        record contains a 4-byte record header followed by data.  The record
;        header should be read into a long integer and it contains the length
;        of the data in BYTES. The 19 records are defined as follows:
;
;        Record  Variable/         Description
;        Number  Array
;        ______  ______________  ______________________________________________
;
;          0     intarr(512)     Numbered sequence: [0,1,2...511].  This record
;                                may be used to determine the byte order of the
;                                CTI binary file.  Namely, if it is Big Endian
;                                or Little Endian.
;          1     bytarr(nb)*     Name associated with this HBR data file,
;                                SSS_TT_FF.  SSS=NRL sequence number,
;                                TT=NRL tape number, FF=NRL file number on the
;                                tape.
;          2     bytarr(nb)      Name of the celestial target that the HBR
;                                data is taken from.
;          3     bytarr(nb)      Name of IDL procedure that created the CTI
;                                file, 'CTIFMT.PRO'.
;          4     bytarr(nb)      Date/time of CTI creation, SYSTIME().
;          5     bytarr(nb)      Filename of the PTI file, including path.
;          6     bytarr(nb)      IDL platform used to create CTI file, !VERSION.
;          7     bytarr(nb)      Date/time of the HBR data acquisition.
;          8     integer         Revolution number of the HEAO satellite during
;                                HBR data acquisition.
;          9     intarr(3)       Various HEAO A-1 electronics modes:
;                                intarr(0):  Which modules selected for the
;                                            random encoder -> HBR data:
;                                            3  - modules 1-4
;                                            7  - module 7
;                                intarr(1):  Mode of the NRZ data:
;                                            5  - 5 msec
;                                            320- 320 msec
;                                intarr(2):  Mode of the HEAO satellite:
;                                            0  - scanning/spinning
;                                            1  - pointing
;         10     lonarr(nb/4)    Major frame numbers.
;         11     intarr(512,nm)  Major frame headers** created by HBRFMT,
;                                nm = nb/(512*2).
;         12     intarr(16,nn)   Minor frame headers** created by HBRFMT,
;                                nn = nb/(16*2).
;         13     integer         Overall Global Data Validity flag (0=Ok, NO
;                                HBRSYNC errors detected in entire data file).
;         14     intarr(128,nr)  Normal 6.4 kbps telemetry data (NRZ),
;                                nr = nb/(128*2).
;         15     lonarr(nb/4)    Corrected photon time intervals.
;         16     lonarr(nb/4)    Corresponding photon times relative to the
;                                beginning of the minor frame containing the
;                                first photon.
;         17     lonarr(2,na)    The beginning and end of time regions where
;                                one or more HBRSYNC error were detected.
;                                The times are relative to the beginning of the
;                                MNF containing the 1st photon, na = nb/(2*4).
;         18     intarr(nb/2)    Number of Adjacent Photon Events (APE) found
;                                in each MJF.
;
;
;        *nb = the length of the data in BYTES, i.e. 4-byte record header.
;        *All of the byte arrays are strings converted to their ASCII numbers
;         equivalent.  To extract the string corresponding to a byte array,
;         apply the string function, (e.g. str = string(b) where b=bytarr(nb))
;
;        **For a complete description of the headers, see DEF_HBRH.PRO.
;
; RESTRICTIONS:
;
;        The def_hbrh.pro routine must be previously compiled.
;
; COMMON BLOCKS:
;        DEF_HBRH: Holds all the MJF and MNF PTI pointers, (see def_hbrh.pro).
;
; PROCEDURE:
;        The PTI file is read in one MJF block of data at a time.  Adjacent
;        Photon Events (APE) are removed using KILLAPE.PRO and any photons
;        falling within BAD minor frame regions are also excluded.  The
;        corrected PTIs are subsequently concatenated with the overall PTI
;        array.  The MJF and MNF headers as well as the NRZ blocks are similarly
;        concatenated.  Once all the MJF blocks have been read in and processed,
;        the concatenated arrays are then written to binary file in the CTI
;        format described above.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, September 1995.
;        18-SEP-1995    Bugfix: Eliminate non-existing NRZ data associated with
;                       each MNF header containing missing MNFs.
;        26-SEP-1995    Added the DBS tag.
;        27-SEP-1995    Moved Date & File tags into Origin; expanded Origin tag;
;                       added Name and GDV tag.
;        29-SEP-1995    Take care of possible 16-bit overflows in DELBEG and DELEND.
;        30-SEP-1995    Transferred to task of removing non-existing NRZ data to
;                       READPTI; take care of missing MJF possibility; changed
;                       version tag from named (!version) to anonymous structure
;                       to avoid incompatibilities across different versions of IDL.
;        09-OCT-1995    Formerly, CATPTI.  Write out binary file in CTI format
;                       instead of saving a structure variable to an IDL save
;                       session.
;-
pro CTIFMT, FILES=Files, PTIPATH=PTIpath, CTIPATH=CTIpath

         common def_hbrh

         endian_rec   = indgen(NWPTIR)      ; Endian record

         nfile= N_ELEMENTS(Files)
         if (nfile eq 0) then return
         if N_ELEMENTS(PTIPath) eq 0 then PTIPath=''
         if N_ELEMENTS(CTIpath) eq 0 then CTIpath=''

;
;   Open log file
;
         olog = !LOG_PATH+'cti0*.log'
         existfile = FINDFILE( olog, COUNT=nexist )
         if (nexist gt 0) then begin
              dot = rstrpos(existfile(0),'.')
              log_list  = fix(strmid( existfile, dot-4, 4 ))
              log_index = MAX(log_list) + 1
         endif else log_index = 0
         log_index = '00000'+strtrim(log_index,2)
         len_index = strlen(log_index)
         log_index = strmid(log_index,len_index-5,5)
         olog      = !LOG_PATH+'cti'+log_index+'.log'

         openw, LOG, olog, /GET_LUN

         if keyword_set(QUIET) then mlun=[LOG] else mlun = [-1,LOG]

;
;   **** BEGIN: FILE LOOP ******************************************************
;
         for kk=0,nfile-1 do begin

           ipti = PTIpath+files(kk)
           pos  = rstrpos( files(kk), '.' )
           name = strmid( files(kk),0,pos)
           octi = CTIpath+name + '.cti'
           dbs  = HBRINFO( FILE=name )

           msgs = ['ConCATenating file '+strtrim(kk,2)+'/'+$
                    strtrim(nfile-1,2)+' into CTI File: '+octi]

           printfs,mlun,msgs(0)

           openpti,lu,ipti

           tend_prev = 0
           first_MJF = 1
           nAPE      = 0
           nbad      = 0
           tbad      = [-1L,-1L]
           repeat begin

              readpti,lu,block
              MJF = 0L & EQUIV, MJF, block.MJFH(mjfptr_.MJF:mjfptr_.MJF+1)
              sMJF= strtrim(MJF,2)
              printfs,mlun,systime(),'// ConCATenating PTI info in MJF: ',sMJF & wait,1

;   Extract the time interval from the start of a NON-zero MNF
;   to the first photon

              b_nodata  = block.MNFH(mnfptr_.MNFLAG,*) and 2^MNFbit_.NO_DATA
              hdata     = where( b_nodata eq 0, ndata )

;   Take care of missing MJF possibility

              if (ndata eq 0) then begin
                   if (first_MJF eq 0) then begin
                        tend_prev = tend_prev + 40960L*128

                        MJFH = [MJFH,  block.MJFH]
                        MNFH = [MNFH,  REFORM(block.MNFH,16)]

                        MJFs = [MJFs,MJF]
                   endif
                   goto, BADBLK
              endif

;   Define indices to the first and last NON-zero MNFs in this MJF

              i         = hdata(0)
              iend      = hdata(ndata-1)

;   Eliminate Adjacent Photon Events

              killape,block,fixes

              MNFHcur   = REFORM(block.MNFH,N_ELEMENTS(block.MNFH))
              NRZcur    = REFORM(block.NRZ ,N_ELEMENTS(block.NRZ))

              if (first_MJF) then begin

                   tbeg_1st  = block.MNFh(mnfptr_.delbeg,i)
                   if (tbeg_1st lt 0) then tbeg_1st = 65536L + tbeg_1st

                   MJF0 = MJF
                   toffset   = 40960L*block.MNFh(mnfptr_.MNF,i)

                   MJFH = block.MJFh
                   NRZ  = NRZcur
                   MNFH = MNFHcur
                   PTI  = fixes.PTI
                   nAPE = fixes.nAPE

                   MJFs = MJF
                   first_MJF = 0
              endif else begin

              ; Account for any missing MNFs between sequential MJFs

                   if (i gt 0) then tmiss = i*40960L else tmiss = 0L

              ; Find PTI between last photon of the previous MJF and first photon
              ; of the current MJF

                   tbeg      = long(block.mnfh(mnfptr_.delbeg,i))
                   if (tbeg lt 0) then tbeg = 65536L + tbeg     ; overflow check

                   ptifirst   = tend_prev + tmiss + tbeg

                   PTI = [PTI, ptifirst, fixes.PTI]

                   MJFH = [MJFH,  block.MJFH]
                   NRZ  = [NRZ,   NRZcur]
                   MNFH = [MNFH,  MNFHcur]
                   nAPE = [nAPE, fixes.nAPE]

                   MJFs = [MJFs,MJF]
              endelse
              tend_prev = block.mnfh(mnfptr_.delend,iend)
              if (tend_prev lt 0) then tend_prev = 65536L + tend_prev     ; overflow check

              nMISS_end = 127 - block.mnfh(mnfptr_.MNF,iend)
              tend_prev = tend_prev + nMISS_end*40960L

;   Determine bad time interval regions

BADBLK:
              if (ndata gt 0) then begin
                   for k=0,n_elements(block.mnfh(0,*))-1 do begin
                        mnf_gdv   = (block.mnfh(mnfptr_.mnflag,k) and 2^0)
                        if (mnf_gdv ne 0) then begin
                             mnfbad1   = block.mnfh(mnfptr_.mnf,k)
                             mnfbad2   = block.mnfh(mnfptr_.mnfnrz,k)
                             tbad1     = (MJF - MJF0)*5242880L +  mnfbad1*40960L
                             tbad2     = (MJF - MJF0)*5242880L + (mnfbad2+1)*40960L - 1L
                             if (tbad2 gt toffset) then begin
                                  tbad1= tbad1 - toffset
                                  tbad2= tbad2 - toffset
                                  if (nbad eq 0) then tbad = [tbad1,tbad2] $
                                  else tbad = [temporary(tbad),tbad1,tbad2]
                                  nbad = nbad + 1
                             endif
                        endif
                   endfor
              endif else begin
                   if (first_MJF eq 0) then begin
                        tbad1     = (MJF - MJF0)*5242880L
                        tbad2     = (MJF - MJF0 + 1)*5242880L - 1L
                        tbad1     = tbad1 - toffset
                        tbad2     = tbad2 - toffset
                        if (nbad eq 0) then tbad = [tbad1,tbad2] $
                        else tbad = [temporary(tbad),tbad1,tbad2]
                        nbad = nbad + 1
                   endif
              endelse

           endrep until EOF(lu)
           free_lun,lu

           nMJF = N_ELEMENTS(MJFH)/512 & MJFH = REFORM(MJFH,512,nMJF,/OVERWRITE)
           nMNF = N_ELEMENTS(MNFH)/16  & MNFH = REFORM(MNFH,16,nMNF,/OVERWRITE)
           nNRZ = N_ELEMENTS(NRZ)/128  & NRZ  = REFORM(NRZ,128,nNRZ,/OVERWRITE)

           printfs,mlun,systime(),'// Generating absolute Photon times...' & wait,1
           ndt     = n_elements(PTI)
           ts      = lonarr(ndt+1)
           ts(0)   = tbeg_1st
           j       = 0L
           for i=1L,ndt do ts(i) = ts(i-1) + PTI(i-1)

           printfs,mlun,systime(),'// Eliminating any BAD Photon times...' & wait,1
           if (nbad gt 0) then tbad = REFORM(tbad,2,nbad,/OVERWRITE)
           for k=0,nbad-1 do begin
              here = where( (ts lt tbad(0,k)) or (ts gt tbad(1,k)),nok )
              if (nok gt 0) then ts = ts(here) else ndt = 0
           endfor

           if (ndt gt 0) then begin
              ndt  = long(n_elements(ts)) - 1
              PTI  = ts(1:ndt) - ts(0:ndt-1)
           endif else begin
              PTI  = -1L
              ts   = -1L
           endelse

           printfs,mlun,systime(),'// Determining Overall Global Data Validity...' & wait,1
           mnfmiss_ok   = MNFH(mnfptr_.mnfnrz,0) - MNFH(mnfptr_.mnf,0) + 1
           if (mnfmiss_ok eq 1) then mnfmiss_ok = 0
           mnfmiss      = MJFH(mjfptr_.mnfmiss,0)
           errmiss      = mnfmiss - mnfmiss_ok
           mjflags      = REFORM(MJFH(mjfptr_.mjflags,*))
           if (mjflags(0) eq 3) and (errmiss eq 0) then mjflags(0) = 0
           GDV          = fix(TOTAL( mjflags and 2^0 ))

           printfs,mlun,systime()+'// Saving info for '+strtrim(ndt+1,2)+$
                                  ' photons' & wait,1
           printfs,mlun,systime()+'// CTI file:'+octi & wait,1

           openw, luo, octi, /GET_LUN, _EXTRA=WINOPEN(/BINARY)
           writeu, luo, endian_rec

           n=n_tags(!version)
           vers=!version.(0)
           for i=1,n-1 do vers=vers+'/'+!version.(i)
           datei= [ dbs.chron.yy,$
                    dbs.chron.doy MOD 365,$
                    dbs.chron.hh,$
                    dbs.chron.mm,$
                    dbs.chron.ss]
           dates= date_conv(datei,'STRING')
           modes= [dbs.mode.pm,dbs.mode.nrz,dbs.mode.sat eq 'P']
           modes= fix(modes)

           for i=0,17 do begin
              case i of                          ; Type    Dimensions
              0 :  output  = byte(Name)          ; byte    strlen(Name)
              1 :  output  = byte(dbs.target)    ; byte    strlen(dbs.target)
              2 :  output  = byte('CTIFMT.PRO')  ; byte    (10)
              3 :  output  = byte(systime())     ; byte    strlen(systime())
              4 :  output  = byte(ipti)          ; byte    strlen(ipti)
              5 :  output  = byte(vers)          ; byte    !version
              6 :  output  = byte(dates)         ; byte    strlen(dates)
              7 :  output  = dbs.rev             ; integer
              8 :  output  = modes               ; integer (3)
              9 :  output  = MJFs                ; long    (nMJF)
              10:  output  = MJFH                ; integer (512,nMJF)
              11:  output  = MNFH                ; integer (16,nMNF)
              12:  output  = GDV                 ; integer
              13:  output  = temporary(NRZ)      ; integer (128,nNRZ)
              14:  output  = temporary(PTI)      ; long    (nPTI)
              15:  output  = temporary(ts)       ; long    (nPTI+1)
              16:  output  = temporary(tbad)     ; long    (2,nbad)
              17:  output  = nAPE                ; integer
              endcase
              nbyte     = long(n_elements(output))
              sz   = size(output) & nz=n_elements(sz)
              type = sz(nz-2)
              case type of
                   1    :                        ; byte
                   2    : nbyte   = 2*nbyte      ; integer
                   3    : nbyte   = 4*nbyte      ; long
                   4    : ntype   = 4*nbyte      ; float
                   5    : ntype   = 8*nbyte      ; double
                   else : message,'Invalid type:'+strtrim(type,2)
              endcase
              writeu,luo,nbyte,output
           endfor
           free_lun,luo

         endfor
         free_lun, LOG
end

