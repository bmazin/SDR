;+
; NAME:
;        HBRFMT
;
; PURPOSE:
;
;        This routine processes and re-formats the raw High-Bit-Rate
;        digitized files into the Photon Time Interval (PTI) format.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        HBRFMT,   FILES=Files, RECORDS=Records
;
; INPUT KEYWORD PARAMETERS:
;
;        FILES:    A array of filenames for each raw HBR digitized file.
;
;        RECORDS:  A two dimensional array (2,nfiles) holding the first record
;                  number, (0,*) and last record number (1,*) to be processed
;                  for each each of the specified files. (Run HBRECS to determine
;                  these start/stop records.)
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        PATH:     Optional path to the specified input files, (''=Default).
;
;        PTIPATH:  Optional path to the output PTI file, (PATH=Default).
;
;        QUIET:    Suppress all print messages to the display, (0=Default).
;
; OUTPUTS:
;        Each specified raw HBR digitized file is processed into the Photon
;        Time Interval (PTI) format and written to a file in the same directory
;        where the HBR file resides.  The filename of this PTI file has the same
;        prefix as the HBR file and an extension of pti. A log file is also created
;        with the name ptiNNNNN.log.
;
;        The format of the PTI file is as follows:
;
;        Byte order record   (512 words, sequence:[0,1,2...511])
;
;        MJF Header record   (512 words)
;        NRZ Data block      (32 512-word records = 4 MNFs/record)
;        DATA records        (512-word records)
;
;            Dynamic format: a MNF header followed by time intervals between
;                            photon events, Deltat's or PTIs
;
;             MNF Header:    (16 words)
;                 Events:    Deltat's between events, 1,...,MNFNDT
;                 Header:
;                 Events:
;                    .
;                    .
;                    .
;                 Header:
;                 Events:
;
;        For a complete description of the MJF and MNF headers, see DEF_HBRH.PRO
;
; RESTRICTIONS:
;
;        The def_hbrh.pro routine must be previously compiled.
;
; COMMON BLOCKS:
;        DEF_HBRH: See DEF_HBRH.PRO for a description.
;        HBRSYNC:  See HBRSYNC.PRO for a description.
;        HBRFMT:   Holds NOVA tape pointers.
;
; PROCEDURE:
;        There is a possibility which leads to NEGATIVE photon time intervals,
;        or PTIs. Since, DATA records is a 16-bit integer array, the largest
;        possible POSITIVE number it can hold is 2^15-1 = 32767.  However, the
;        MSB bit (the sign bit) allows us to effectively extend the range of
;        numbers to [0-65535].
;
;        Each MNF is 320 msec long.  At 7.8125 usec time bins, the largest
;        possible PTI within a MNF is 40960.  Any PTIs > 32767 overflow
;        to their negative complement, namely, -2^16 + PTI.  This means that
;        PTIS = [32768,40960] are mapped to their NEGATIVE overflow values
;        = [-32768,-24576].
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, July 1995 (Adapted from HBRFMT.FOR, Yentis & Co.).
;        09-AUG-1995    Added NRL mag.tape error codes.  Eliminated hard-coded IDL
;                       error code.
;        20-AUG-1995    Added QUIET keyword.
;        28-AUG-1995    Take care of special case, 1 photon/MNF.
;                       Added the PTIPATH keyword.
;        29-AUG-1995    Bugfix: Skip next record when next MJF13 number is different
;                       from the previous by more than 1. Do not increment expected
;                       MNF number for garbage data.
;        29-SEP-1995    Added the PROCEDURE comments about possible 16-bit integer
;                       overflows of the time intervals, PTIs.
;        07-OCT-1995    Eliminated XDR and BINARY keywords. Create binary files with
;                       .pti extension.  Added byte order record to Check Endian-type.
;                       Converted existing XDR files -> .pti using XDR2PTI.PRO.
;-


function OCTAL, Input, Output

         Output    = string( INPUT, FORMAT='(O6)' )
         Bout      = BYTE( Output )
         spc       = BYTE( ' ' )
         here      = WHERE( Bout eq spc(0), nspace )
         if (nspace gt 0) then Bout(here) = BYTE('0')

         return, string( Bout )
end

;-------------------------------------------------------------------------------
;
;        MJF Header Processing
;
;-------------------------------------------------------------------------------

pro Def_MJFhdr, MJFhdr

         common DEF_HBRH     ; Defined in def_hbrh.pro

         tns  = tag_names( MJFptr_ )
         sp_tags = [ 'MJFNRZ',  'SYNLOSS', $
                     'CLKERRS', 'MJFCNTS', $
                     'MNFLAGS', 'MNFNDTS', $
                     'DATRECN', 'MJFMARK'  ]
         nsp  = N_ELEMENTS(sp_tags)
         for i=0,nsp-1 do $
              STRREPLACE, tns, sp_tags(i), ''
         here = WHERE((tns ne '') and (tns ne 'MJF'),n)
         vals = REPLICATE(0,n)
         MJFhdr = CREATE_STRUCT( tns(here(0)), 0 )
         for i=1,n-1 do $
              MJFhdr = CREATE_STRUCT( MJFhdr, tns(here(i)), 0 )
         MJFhdr   = CREATE_STRUCT( $
                        'MJF'    ,0L, $
                        'MJFNRZ' ,0L, $
                        'SYNLOSS',0L, $
                        'CLKERRS',0L, $
                        'MJFCNTS',0L, $
                        'MNFLAGS',intarr(128), $
                        'MNFNDTS',intarr(128), $
                        'DATRECN',intarr(128), $
                        MJFhdr,       $
                        NAME='MJF_header')
end

pro Clear_MJFhdr, MJFhdr

         MJFhdr = {MJF_header}
end


function Reform_MJFhdr, MJFhdr

         common DEF_HBRH     ; Defined in def_hbrh.pro

         n    = n_tags( MJFhdr)

         MJFhdr_arr    =intarr(NWMJFH)

         EQUIV, MJFhdr_arr, MJFhdr.MJF,     MJFptr_.MJF       ; Special 32-bit integers
         EQUIV, MJFhdr_arr, MJFhdr.MJFNRZ,  MJFptr_.MJFNRZ
         EQUIV, MJFhdr_arr, MJFhdr.SYNLOSS, MJFptr_.SYNLOSS
         EQUIV, MJFhdr_arr, MJFhdr.CLKERRS, MJFptr_.CLKERRS
         EQUIV, MJFhdr_arr, MJFhdr.MJFCNTS, MJFptr_.MJFCNTS
         EQUIV, MJFhdr_arr, MJFhdr.MNFLAGS, MJFptr_.MNFLAGS   ; 16-bit, 128-element arrays
         EQUIV, MJFhdr_arr, MJFhdr.MNFNDTS, MJFptr_.MNFNDTS
         EQUIV, MJFhdr_arr, MJFhdr.DATRECN, MJFptr_.DATRECN

         MJFhdr_arr( MJFptr_.MJFLAGS )  = MJFhdr.MJFLAGS      ; Regular 16-bit integers
         MJFhdr_arr( MJFptr_.MNFMISS )  = MJFhdr.MNFMISS
         MJFhdr_arr( MJFptr_.DATRECS )  = MJFhdr.DATRECS
         MJFhdr_arr( MJFptr_.PARERRS )  = MJFhdr.PARERRS
         MJFhdr_arr( MJFptr_.SYNMNFS )  = MJFhdr.SYNMNFS
         MJFhdr_arr( MJFptr_.NOSYNCH )  = MJFhdr.NOSYNCH
         MJFhdr_arr( MJFptr_.BADSYNC )  = MJFhdr.BADSYNC
         MJFhdr_arr( MJFptr_.TIKTOK )   = MJFhdr.TIKTOK
         MJFhdr_arr( MJFptr_.BUMSIZ )   = MJFhdr.BUMSIZ
         MJFhdr_arr( MJFptr_.BITSBAD )  = MJFhdr.BITSBAD
         MJFhdr_arr( MJFptr_.OBOUNDS )  = MJFhdr.OBOUNDS

         EQUIV, MJFhdr_arr, MJFmark, MJFptr_.MJFmark      ; Put in MJF marker

         return, MJFhdr_arr
end


;-------------------------------------------------------------------------------
;
;        MNF Header Processing
;
;-------------------------------------------------------------------------------

pro Def_MNFhdr, MNFhdr

         common DEF_HBRH     ; Defined in def_hbrh.pro

         tns  = tag_names( MNFptr_ )
         n    = n_elements(tns)
         MNFhdr = CREATE_STRUCT( tns(0), 0 )
         for i=1,n-2 do $
              MNFhdr = CREATE_STRUCT( MNFhdr, tns(i), 0 )
         MNFhdr   = CREATE_STRUCT( MNFhdr, NAME='MNF_header' )

end

pro Clear_MNFhdr, MNFhdr

         MNFhdr = {MNF_header}
end

function Reform_MNFhdr, MNFhdr

         common DEF_HBRH     ; Defined in def_hbrh.pro

         n    = n_tags( MNFhdr)

         MNFhdr_arr =intarr(NWMNFH)
         for i=0,n-1 do MNFhdr_arr(i) = MNFhdr.(i)

         EQUIV, MNFhdr_arr, MNFmark, MNFptr_.MNFmark   ; Put in MNF marker

         return, MNFhdr_arr
end

;-------------------------------------------------------------------------------
;
;        Data Buffer Processing
;
;-------------------------------------------------------------------------------

pro BUFPUSH, Data, Block, Recnum, RECL=Recl, NEW=New

         nblocks = N_ELEMENTS(Block)
         if (nblocks le 1) then New = 1

         Recl      = fix(Recl)
         nwrds     = N_ELEMENTS(Data)
         nmod      = nwrds MOD Recl
         nrec      = nwrds/Recl + (nmod gt 0)

         if (nmod gt 0) then begin
              data_rec = [Data,intarr(Recl - nmod)]
              data_rec = REFORM( data_rec, Recl, nrec, /OVERWRITE )
         endif else data_rec = REFORM( Data, Recl, nrec )

         if keyword_set(NEW) then begin
              Block = TEMPORARY( data_rec )
              Recnum= nrec
         endif else begin
              Block = [[Block], [TEMPORARY( data_rec )]]
              Recnum= nblocks/Recl + nrec
         endelse
end


pro HBRFMT, FILES=Files, PATH=Path, RECORDS=Records, QUIET=Quiet, $
         PTIPATH=PTIpath, DEBUG=Debug

         common DEF_HBRH     ; Defined in def_hbrh.pro
         common HBRSYNC, B_, E_, V_, C_

;   Take care of keywords

         nfile= N_ELEMENTS(Files)
         if (nfile eq 0) then return
         if N_ELEMENTS(Path) eq 0 then Path=''
         if N_ELEMENTS(PTIpath) eq 0 then PTIpath=Path
         ext  = 'pti'
         i    = 1
         byteorder, i, /NTOHS
         if (i eq 1) then fmt='Binary, (Big Endian)' $
         else fmt='Binary, (Little Endian)'

         if N_ELEMENTS(Records) gt 0 then begin
              IRECSTRT = REFORM(Records(0,*))
              IRECSTOP = REFORM(Records(1,*))
         endif else begin
              IRECSTRT = intarr(nfile)
              IRECSTOP = IRECSTART + '37777'O
         endelse


;
;   Initialize parameters, pointers, MJF and MNF headers
;
         Def_HBRH                                ; Define HBR Header pointers
         Def_MJFhdr, MJFH                        ;    "   MJF Header
         Def_MNFhdr, MNFH                        ;    "   MNF Header

         MJFH.MJF       = -1L

;
; ------------------------------------------------------------------------------
;
;   Define NRL Magnetic Tape Error flags
;
;   From: %INCLUDE ':UDD:DJY:F77LIB:MTERR.IN.F77'
;
         ER_OK='000000'O                  ; Ok (no error)
         ERFNO='000002'O                  ; Channel not open
         ERFDE='000025'O                  ; Filename does not exist
         EREOF='000030'O                  ; End of file
         ERDTO='000076'O                  ; Device timeout
         ERPUF='000121'O                  ; Physical unit failure
         ERPET='000163'O                  ; Mag tape req past LEOT
         ERTMR='000470'O                  ; Too many tape retries
         EREO1='000203'O                  ; File open
;
; ------------------------------------------------------------------------------
;
         COMMON HBRFMT, NOVA_
         NOVA_ = { $
                   NOVABUF   : 8194,$       ; HBR NOVA record size (bytes)
                   C_TAPE    : 0   ,$       ; NOVA tape sequence number
                   C_RUN     : 1   ,$       ; NOVA tape run number
                   C_FILS    : 2   ,$       ; Number of NOVA files
                   C_FILE    : 3   ,$       ; NOVA tape file number
                   C_IER     : 4   ,$       ; Copy error flag
                   C_ICNT    : 5   ,$       ; NOVA input record size
                   C_DATE    : 6   ,$       ; Date of copy
                   C_TIME    : 9   ,$       ; Time of copy
                   C_BUF     : 13   }       ; NOVABUF+C_BUF=copy buffer
;
; ------------------------------------------------------------------------------
;
;
         NOVBUF=4097                        ; Digitizer buffer length
         COPBUF=NOVBUF+NOVA_.C_BUF          ; HBRCOPY buffer length

         NRZ       = intarr(128)
         HBR       = intarr(4096)
         BUFF      = intarr(4096,2)

         BUF2      = intarr(4096)
         FLAGS     = intarr(3)


         SIGMA     = 2.0
         SIGMA     = 0.0
         TMNF      = 40960L
         SPCLK     = 0L                ; Spacecraft clock
         ISPCLK    = 0L
         TEN       = 10L

         OCT       = ''                ; Char*6

;
; Logical units
;
;        LUI=1                         ; HBR digitized  input  file
;        LUO=2                         ; HBR reformated output file
;        LOG=12                        ; Log file

         INITFL=-1
         IFILE=0
         IREC=0
         IPAR1=0
         IPAR2=0
         IB=1
         IFLUSH=0

         RECL=512                      ; Record length in WORDS
         NRNRZB= NWNRZB/RECL           ; Number of records/NRZ block
         endian_rec= indgen(RECL)      ; Endian record

;
;   Define fortran-style format statements
;
         F4000 = '('' HBR '',A6,'' file : '',$)'
         F4010 = '(A20)'
         F4030 = '(I2,''/'',I2,''/'',I2,I2,'':'',I2,'':'',I2)'
         F4080 = '(/'' SIGMA = '',F8.3/)'

         F4100 = '(''    TAPE: Sequence'',I4,2X,''Run'',I3,'+$
                        '2X,''Rec Start'',I6,2X,'' Stop'',I6)'
         F4110 = '(''  SKIP ?: File'',I3,2X,''Rec'',I6,2X,''NOVA '',I2,''/'',I2)'
         F4120 = '('' AOS ERR: File'',I3,2X,''Rec'',I6,2X,''IOS '',A6)'
         F4120 = '('' IDL ERR: File'',I3,2X,''Rec'',I6,2X,''IOS '',I6)'
         F4130 = '(''     EOF: File'',I3,2X,''Rec'',I6)'
         F4140 = '('' STARTUP: File'',I3,2X,''Rec'',I6,2X,''FLAGS'',I2,2(1X,I6))'
         F4150 = '('' HBRSYNC: File'',I3,2X,''Rec'',I6,2X,''FLAGS'',I2,2(1X,I6),'+$
                                  '2X,''(MJF/MNF (?) '',I7,''/'',I3,'')'')'
         F4160 = '('' CLOCK ?: File'',I3,2X,''Rec'',I6,'+$
                       '2X,''MJF/MNF '',I7,''/'',I3,'' ('',I7,''/'',I3,'')'')'
         F4170 = '(''   GAP ?: File'',I3,2X,''Rec'',I6,'+$
                       '2X,''MJF/MNF '',I7,''/'',I3,'' ('',I7,''/'',I3,'')'')'
         F4190 = '('' MISSING: File'',I3,2X,''Rec'',I6,2X,''MNF(S) '',I3,'' - '',I3)'
         F4200 = '(''    DATA: File'',I3,2X,''Rec'',I6,'+$
                       '2X,''MJF/MNF '',I7,''/'',I3,4X,A6,2X,I6)'
         F4220 = '(/A1/38('' *'')//'+$
                       '''  RE-VERIFY: Date '',A8,2X,''Time '',A8,2X,''File '',I2,'+$
                       '//38('' *'')/)'
         F4230 = '(''   FLUSH: '',I4)'
         F4240 = '(''  TOTALS: '',''MJF'',I8,'+$
                                 '2X,''FLG'',1X,A6,'+$
                                 '2X,''MIS'',I4,'+$
                                 '2X,''PAR'',I4,'+$
                                 '2X,''SYN'',I7,''/'',I3,'+$
                                 '2X,''CLK'',I7,''/'',I3,'+$
                                 '2X,''CNT'',I7)'
         F4250 = '(''   PHASE: '',''FLAGS = '',I2,1X,O6,1X,I6)'
         F4260 = '(''0 FINISH: File'',I3,2X,''Rec'',I6,2X,''Process Time'',F6.1,'+$
                        '1X,''min.'')'

;
;   Initialization
;
;   FORMAT: IBUF=4110, 6250 BPI HBRCOPY TAPES
;
;   Open log file
;
         if keyword_set(DEBUG) then LOG = DEBUG $
         else begin
              olog = !LOG_PATH+'pti*.log'
              existfile = FINDFILE( olog, COUNT=nexist )
              if (nexist gt 0) then begin
                   dot = rstrpos(existfile(0),'.')
                   log_list  = fix(strmid( existfile, dot-4, 4 ))
                   log_index = MAX(log_list) + 1
              endif else log_index = 0
              log_index = '00000'+strtrim(log_index,2)
              len_index = strlen(log_index)
              log_index = strmid(log_index,len_index-5,5)
              olog      = !LOG_PATH+'pti'+log_index+'.log'

              openw, LOG, olog, /GET_LUN
         endelse

         if keyword_set(QUIET) then mlun=[LOG] else mlun = [-1,LOG]

;
;   **** BEGIN: FILE LOOP ******************************************************
;
         for kk=0,nfile-1 do begin

           MJF_set      = 0
           time_start   = systime(1)

           idat = path+files(kk)
           pos  = rstrpos( files(kk), '.' )
           odat = ptipath+strmid( files(kk),0,pos ) + '.'+ext

           if (kk gt 0) then WIDGET_CONTROL, Msg_ID, /DESTROY
           xmsg,['Processing file '+strtrim(kk,2)+'/'+$
                                    strtrim(nfile-1,2)+'...',$
                 'Filename: '+odat,$
                 'Format:   '+fmt],/ALIGN,/TOP,/RIGHT,/NOBUTTON,MSG_ID=Msg_ID
;
;   Open HBR input and output data files
;
           printfs,mlun,'Output file information:'
           printfs,mlun,'  Name  : '+odat
           printfs,mlun,'  Format: '+fmt

           openr, LUI, idat, /GET_LUN
           openw, LUO, odat, /GET_LUN
           writeu,LUO, odat, endian_rec
;
;   (Re)initialize program
;
           HBRSYNC,/INIT                 ; Initialize HBRSYNC

           systim  = BIN_DATE(SYSTIME())
           IDATE   = systim(0:2)
           ITIME   = systim(3:5)

           IDATE(0)= IDATE(0) MOD 100
           WHEN    = string(IDATE(1),IDATE(2),IDATE(0),ITIME,FORMAT=F4030)
           BWHEN   = BYTE( WHEN )
           spc     = BYTE( ' ' )
           here    = where( BWHEN eq spc(0), nspace)
           if (nspace gt 0) then BWHEN(here)  = BYTE('0')
           IDATE='' & ITIME = ''
           reads, WHEN, IDATE, ITIME, FORMAT='(2A8)'
           printfs,mlun,FORMAT=F4220, '1',IDATE,ITIME,IFILE

           INITFL=-1
           IFLUSH=0
           IB=1                ; RESTART I/O, LOG FILE, ETC.
           IPHAS=0
           CNTMNF=0.0
           LASTFLG=-1          ; 177777K

           datrec   = 1 + NRNRZB
           ;
           ;   **** BEGIN: MJF loop ********************************************
           ;
           REPEAT BEGIN

             NRZdata  =-1              ; Reset NRZ data storage
             MNFSblock=-1              ;      MNFS data output block

             rec_offset = 0
             MJFLAST =MJFH.MJF
             Clear_MJFhdr, MJFH
             MJFH.MJF=MJFLAST+1        ; Expected MJF number

             MNFH.MNF=-1               ; Expected MNF number initialization (0-127)
             MNFLDT  = 0               ; Number of DeltaT's from previous MNF

             ;
             ;    **** BEGIN: MNF loop *****************************************
             ;
             REPEAT BEGIN

               MNFLAST =MNFH.MNF
               Clear_MNFhdr, MNFH
               MNFH.MNF = MNFLAST                ; MNF Number is updated later


               if (IFLUSH ne 0) then begin       ; Just flushed an MJF ?
                   IFLUSH=0                      ; Reset flag
                   GOTO, SYNC                    ; Bypass input
               endif

NEXT_RECORD:   BUFF(0:4095)= BUFF(4096:8191)     ; Stuff earlier HBR record
                                                 ; into 1st half of BUFF

               IPAR1=IPAR2                       ; Parity errors in
               IPAR2=0                           ; Buffer 1 -> IPAR1
                                                 ; Buffer 2 -> IPAR2
               ;
               ;   **** BEGIN:  Loop over beginning RECORDS ********************
               ;
               REPEAT BEGIN

                 IREC=IREC+1
                 ;
                 ;    Read NOVA4097+BUF2(4096)+COPY
                 ;
                 iss = HBREAD(LUI, BUF2, MNFword, Copy, IOS)
                 BUFF(4096:8191)  = BUF2

SET_EOF:         CASE iss OF
                   0 :                           ; No errors reading file
                   1 : begin                     ; EOF
                      IREC=IREC-1
                      IRECEND = IREC
                      IFILEND = IFILE
                      printfs, mlun, FORMAT=F4130, IFILE, IREC
                      IFILE=IFILE+1
                      IREC=0
                      if (N_ELEMENTS( MNFsblock ) eq 1) then begin
                        IFLUSH=4
                        goto, NEXT_FILE     ; Next file
                        endif else begin    ; Flush buffer, next file
                             IFLUSH = 2
                             goto, UPDATE_BUF
                             endelse
                      end
                   2 : begin                     ; Errors: input,HBRCOPY, etc
                      IPAR2=1                    ; Buffer flag
                      OCT = OCTAL(IOS)
                      printfs, mlun, FORMAT=F4120, IFILE,IREC,OCT
                      if (IOS EQ ERPET) then begin
                        iss = 1
                        goto, SET_EOF
                      endif
                      end
                   3 : begin                     ; Errors: IDL read, EOF, etc.
                      IPAR2=1                    ; Buffer flag
                      printfs, mlun, FORMAT=F4122, IFILE,IREC,IOS
                      err_str= STRMESSAGE(IOS)
                      ck     = strpos(err_str,'End of file')
                      if (ck ne -1) then begin
                        iss = 1
                        goto, SET_EOF
                      endif
                      end
                 ENDCASE

                 if (Copy(NOVA_.C_FILE) ne Copy(NOVA_.C_FILS)) then begin
                      printfs,mlun, FORMAT=F4110, IFILE,IREC, $
                             Copy(NOVA_.C_FILE), Copy(NOVA_.C_FILS)
                 endif

                 if (INITFL lt 0) then begin   ; Temporarily moved 03/07/83
                      printfs,mlun, FORMAT=F4100, Copy(NOVA_.C_TAPE), $
                             Copy(NOVA_.C_RUN), IRECSTRT(kk), IRECSTOP(kk)
                      INITFL = 0
                 endif

               ENDREP until (IREC ge IRECSTRT(kk)) and (IREC le IRECSTOP(kk))
               ;
               ;   ****** END:  Loop over beginning RECORDS ********************
               ;
               if (IB ne 2) then begin
                   IB = 2                             ; Buffer pointer
                   goto, NEXT_RECORD                  ; Need at least two
               endif                                  ; records for HBRSYNC
               ;
               ;   ------ Synchronize with MNF and extract data ----------------
               ;
SYNC:          HBRSYNC, BUFF, HBR, NRZ, IMJF, IMNF, Flags

               if (INITFL eq 0) then begin            ; Startup
                 if (Flags(0) ne 0) then begin        ; Begin only on good MNF
                        printfs,mlun, FORMAT=F4140, $
                             IFILE,IREC, Flags
                        goto, NEXT_RECORD
                 endif
                 INITFL=1
                 IMJF13= IMJF and '00000017777'OL   ; Spacecraft clock should start
                 SPCLK = ishft( IMJF13,7 ) - 1      ;      at MNF 0
                 MJF13=0                            ; Upper 13 bits of S/C clock
               endif
               ;
               ;   ------ Handle HBRSYNC Errors -------------------------------
               ;
               if (Flags(0) ne 0) then begin

                 ;   Update MNF error flags

                 MNFH.SYNFLG = MNFH.SYNFLG or 2^Flags(0)
                 MNFH.ERROFF = Flags(1)

                 ;   Update MJF error flags

                 case Flags(0) of ; Record Fatal HBRSYNC errors
                      E_.NOSYNCH  : MJFH.NOSYNCH = MJFH.NOSYNCH + 1
                      E_.BADSYNCH : MJFH.BADSYNC = MJFH.BADSYNC + 1
                      E_.TIKTOK   :
                      E_.BUMSIZ   : MJFH.BUMSIZ  = MJFH.BUMSIZ  + 1
                      E_.BITSBAD  : MJFH.BITSBAD = MJFH.BITSBAD + 1
                      E_.OBOUNDS  : MJFH.OBOUNDS = MJFH.OBOUNDS + 1
                 endcase

                 ;   Continue on only if TicToc errors

                 if (Flags(0) ne E_.TIKTOK) then begin
                      printfs,mlun, FORMAT=F4150,$
                           IFILE,IREC,Flags,IMJF,IMNF
                      MNFH.MNFLAG = MNFH.MNFLAG  or 2^MNFbit_.SUSPECT
                      goto, NEXT_RECORD
                 endif else begin                          ; If TicToc errors then
                        MNFH.CLKERR = Flags(1)             ;    update headers
                        MNFH.MNFLAG = MNFH.MNFLAG or $     ; # Clock tictoc errors
                                      2^MNFbit_.CLK_ERR
                        MJFH.TIKTOK = MJFH.TIKTOK + 1
                        MJFH.CLKERRS= MJFH.CLKERRS+MNFH.CLKERR
                 endelse
               endif

               MNFH.MNF=MNFH.MNF+1                         ; Expected MNF

               ;
               ;   ------ Check Spacecraft Clock / Missing MNF's ---------------
               ;

               ;   IMJF and IMNF were extracted from the NRZ S/C clock words
               ;   in the HBRSYNC routine.

               IMJF13   = IMJF and '00000017777'OL         ; 13 LSBs of MJF number
               ISPCLK   = ishft( IMJF13,7 ) + long(IMNF)   ; 7 bits of MNF number, since
                                                           ; MNF <= 127 = '177'O

               ;   For each sequential MNF of data, we expect the spacecraft
               ;   clock to increment by 1. ( When MNF = 127 -> 0, then
               ;   MJF -> MJF + 1, so the S/C clock still increments by 1.)

               if (ISPCLK eq (SPCLK+1)) then     $         ; Spacecraft clock ok?
                      goto, MNF_PASS

               ;   Now, if the current S/C clock has not incremented by 1, then
               ;   a)   if it's garbage (e.g. value of 0) skip this record.
               ;   b)   if it's due to one or more missing MNFs, then usually
               ;        current MNF > previous MNF +1.  If the current MNF is
               ;        less than the previous, then this must be a roll over
               ;        to the next MJF (e.g. MNF = 127 -> 0).  For this case,
               ;        the current MJF = previous MJF + 1.

               if (ISPCLK eq 0) or $                       ; Bad spacecraft clock
                 ((IMNF lt MNFH.MNF) and $                 ; Missing MNFs into next MJF?
                  (IMJF13 ne (MJF13+1))) or $              ; Test on 13 bits of MJF

                 ((MJF_set eq 1) and $                     ; Added 8/29/95, H.C. Wen:
                  (abs(IMJF13 - MJF13) gt 1)) then begin   ;    Again, garbage S/C clock

                   printfs,mlun, FORMAT=F4160, $
                          IFILE,IREC,IMJF,IMNF,MJFH.MJF,MNFH.MNF
                   MNFH.MNF=MNFH.MNF-1                     ; Added 8/29/95, H.C. Wen:
                                                           ;    Don't increment expected
                                                           ;    MNF number for garbage data
                   goto, NEXT_RECORD
               endif

               MNFH.MNFNRZ=IMNF-1                ; Last missing MNF, i.e. one less
                                                 ;    than the current one/

               if (MJF13 ne 0) and $
                  (MJF13 lt IMJF13) then begin   ; New MJF ?
                  MNFH.MNFNRZ=127                ; Current buffer only holds "previous"
                  SPCLK=ISPCLK-1                 ;    MJF.  Need to flush "previous" MJF
                  MJF13=IMJF13-1                 ;    to file before processing current
                  IFLUSH=1                       ;    one. (Don't worry, setting IFLUSH=1
               endif                             ;    will prevent reading in another MNF
                                                 ;    before processing this one.)

               MFRST=MNFH.MNF                    ; First missing MNF
               MLAST=MNFH.MNFNRZ                 ; Last  missing MNF

               ;   Update LOG file of Missing MNF(s)

               printfs, mlun, FORMAT=F4170 , $
                        IFILE,IREC,IMJF,IMNF,MJFH.MJF,MNFH.MNF
               printf,LOG, FORMAT=F4190 , IFILE,IREC,MFRST,MLAST

               ;   Update MNF header of Missing MNF(s)

               bitset_  = [MNFbit_.MNF_GDV, MNFbit_.MNF_MIS, MNFbit_.NO_DATA]
               MNFH.MNFLAG= MNFH.MNFLAG or fix(TOTAL(2^bitset_))
               MNFH.DATREC= datrec + rec_offset

               MNFheader = Reform_MNFhdr( MNFH )           ; Write out missing MNF header
               BUFPUSH, MNFheader, MNFSblock, $            ;    headers to buffer
                        rec_offset, RECL=RECL

               ;   Update MJF header of Missing MNF(s)

               MJFH.MNFMISS=MJFH.MNFMISS+(MLAST-MFRST+1)   ; MJF header update
               MJFH.MNFLAGS(MFRST:MLAST) = MNFH.MNFLAG
               MJFH.MNFNDTS(MFRST:MLAST) = 0
               MJFH.DATRECN(MFRST:MLAST) = MNFH.DATREC

               if (IFLUSH ne 0) then goto, UPDATE_BUF      ; End of MJF, flush MJF

               ;   Reset to current MNF

               MNFH.MNF=IMNF
               MNFH.MNFLAG=0
               MNFH.SYNFLG=0
               MNFH.ERROFF=0

MNF_PASS:      MNFH.MNFNRZ=IMNF
               SPCLK=ISPCLK
               MJF13=IMJF13
               if (MNFH.MNF eq 118) then begin
                   MJFH.MJFNRZ=IMJF
                   IMJFUP    = MJFH.MJF and (NOT '00000017777'OL)
                   if (IMJFUP eq 0) then begin        ; Set starting value for expected
                        MJFH.MJF = IMJF               ;  MJF number
                        MJF_set  = 1
                   endif
               endif

               MNFH.NRZOFF=Flags(2)                   ; DPM to add 02/28/83
               ;
               ;   ------ Extract 6.4 kbs NRZ Data -----------------------------
               ;
               ;          (of which 2.1 kbs belongs to HEAO A-1)
               ;
               NRZdata  = [NRZdata, NRZ]                   ; Store MNF NRZ block

               ;
               ;   ------ Extract HBR Word Errors ------------------------------
               ;
               i_err    = WHERE( HBR lt 0, nerr)      ; Bit 15 is set for words where
                                                      ;    there is either a HBR sync
                                                      ;    loss or Tick Tock error.
               if (nerr gt 0) then begin
                   clk_fill  = HBR(i_err) and C_.TTERR     ; Bit 14 is additionally set
                                                           ;    for Tick Tock errors

                   i_clk= WHERE(clk_fill eq C_.TTERR,nCLKCHK)   ; If Tick Tock error, make
                   if (nCLKCHK gt 0) then $                     ;    sure HBRSYNC properly
                        if (nCLKCHK ne MNFH.CLKERR) then $      ;    filled Flags(1)
                        message,'HBRSYNC Error filling Flags.'

                   MNFH.SYNLOS   = nerr - nCLKCHK
               endif else MNFH.SYNLOS = 0

               ;
               ;   ------ Extract Photon events --------------------------------
               ;

               i        = WHERE( HBR gt 0, nwords )   ;  Words with at least 1 photon

               if (nwords gt 0) then begin

                   tevents  = [-9999L]
                   for j=9,0,-1 do begin                   ; See if there's a photon in the
                       bits = HBR(i) and 2^j               ;  jth bit for all the HBR words, i
                       k    = WHERE(bits ne 0, nbitset)
                                                           ; Get all the photon times relative
                       if (nbitset gt 0) then begin        ;  to the start of the minor frame:
                            tbits     = TEN*i(k)+(9L-j)    ;  Namely, times are DEFINED at the
                            tevents   = [tevents,tbits]    ;  LEFT-EDGE of each bin.
                       endif
                   endfor
                   tevents  = tevents(SORT( tevents ))          ; Sort all these times
                   nmnfcnt  = N_ELEMENTS( tevents ) - 1         ; First element is -9999L

                   if (nmnfcnt gt 1) then $
                   deltas   =  tevents( 2:nmnfcnt ) $           ; And find the relative
                            -  tevents( 1:nmnfcnt-1 )           ;    time intervals

                   MNFH.MNFCNT = nmnfcnt
                   MNFH.MNFNDT = nmnfcnt - 1
                   MNFH.DELBEG = tevents(1)
                   MNFH.DELEND = TMNF-tevents(nmnfcnt)

               endif else begin
                   MNFH.MNFCNT = 0                         ; These elements are
                   MNFH.MNFNDT = 0                         ;    already set to 0, but
                   MNFH.DELBEG = 0                         ;    we reset them here
                   MNFH.DELEND = 0                         ;    anyways for illustrative
               endelse                                     ;    purposes only.

               ;
               ;   Update MNF and MJF header flags & statistics
               ;

               MNFH.MNFLDT   = MNFLDT
               MNFLDT        = MNFH.MNFNDT
               MNFH.DATREC   = datrec + rec_offset

               if (MNFH.MNFCNT gt 0) then begin                 ; Counts
                   MJFH.MJFCNTS = MJFH.MJFCNTS+MNFH.MNFCNT
                   MJFH.MNFNDTS(MNFH.MNF) = MNFH.MNFCNT - 1
               endif else $
                   MNFH.MNFLAG=MNFH.MNFLAG or 2^MNFbit_.NO_DATA

               if (IPAR1 ne 0) then $
                   MNFH.MNFLAG=MNFH.MNFLAG or 2^MNFbit_.PAR_ER1 ; Parity error buffer 1
               if (IPAR2 ne 0) then begin
                   MNFH.MNFLAG=MNFH.MNFLAG or 2^MNFbit_.PAR_ER2 ; Parity error buffer 2
                   MJFH.PARERRS=MJFH.PARERRS+IPAR2
               endif

               if (MNFH.SYNLOS ne 0) then begin                 ; HBR sync loss errors
                   MNFH.MNFLAG=MNFH.MNFLAG or 2^MNFbit_.SYN_ERR
                   MJFH.SYNMNFS=MJFH.SYNMNFS+1
                   MJFH.SYNLOSS=MJFH.SYNLOSS+MNFH.SYNLOS
               endif

               ;   Set MNF Global Validity bit if appropriate MNF flag bit(s) are set
               ;   (1 = NOT Ok)

               MNFlags_set = MNFH.MNFLAG xor (MNFH.MNFLAG and 2^MNFbit_.NO_DATA)
               if (MNFlags_set ne 0) then MNFH.MNFLAG=MNFH.MNFLAG or 2^MNFbit_.MNF_GDV

               MJFH.MNFLAGS(MNFH.MNF)  = MNFH.MNFLAG            ; Save MNF info in
               MJFH.DATRECN(MNFH.MNF)  = MNFH.DATREC            ;    MJF header
               ;
               ;   ------ Store MNF Header & Photon events ---------------------
               ;

               MNFdata   = Reform_MNFhdr( MNFH )                ; Stuff MNF header
               if (MNFH.MNFCNT gt 1) then $                     ;    and time intervals
                   MNFdata = [MNFdata, deltas]                  ;    into MNFSblock

               BUFPUSH, MNFdata, MNFSblock, rec_offset, RECL=RECL


               OCT = OCTAL(MNFH.MNFLAG)
               printf,LOG,FORMAT=F4200, IFILE,IREC,IMJF,IMNF,OCT,MNFH.MNFCNT
;
;   ______________________________________________________________________________
;
               if (Copy(NOVA_.C_FILE) eq Copy(NOVA_.C_FILS)) then begin

                   if (IPHAS eq 0) and (Flags(0) eq 0) then begin
                        printfs,mlun, FORMAT=F4250, FLAGS   ; Phase
                        IPHAS=1
                   endif
                   CASE 1 OF
                        keyword_set(QUIET)            : iprn = 0
                        (IMNF eq 118) or $
                             (IMNF eq 0)              : iprn = 1
                        (ABS(CNTMNF-MNFH.MNFCNT) gt $
                             SIGMA*SQRT(CNTMNF))      : iprn = 1
                        (MNFH.MNFLAG ne LASTFLG)      : iprn = 1
                        else                          : iprn = 0
                   ENDCASE
                   if iprn then print, FORMAT=F4200, $
                        IFILE,IREC,IMJF,IMNF,OCT,MNFH.MNFCNT
                   LASTFLG=MNFH.MNFLAG
                   CNTMNF=MNFH.MNFCNT
               endif

             ENDREP UNTIL (MNFH.MNF ge 127)
             ;
             ;    ****** END: MNF loop *****************************************
             ;

             IFLUSH=0
             ;
             ;     Set MJF flags
             ;
UPDATE_BUF:  if(MJFH.MNFMISS ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.MNF_MISS
             if(MJFH.PARERRS ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.PAR_ERRS
             if(MJFH.MJFCNTS eq 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.NO_DATAS
             if(MJFH.SYNMNFS ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.SYN_ERRS
             if(MJFH.NOSYNCH ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.NOSYN_ERRS
             if(MJFH.BADSYNC ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.BADSYN_ERRS
             if(MJFH.TIKTOK  ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.CLK_ERRS
             if(MJFH.BUMSIZ  ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.BUMSIZ_ERRS
             if(MJFH.BITSBAD ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.BITBAD_ERRS
             if(MJFH.OBOUNDS ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.OBOUND_ERRS

             ;   Set MJF Global Validity bit if appropriate MJF flag bit(s) are set
             ;   (1 = NOT Ok)

             MJFlags_set = MJFH.MJFLAGS xor (MJFH.MJFLAGS and 2^MJFbit_.NO_DATAS) $
                                        xor (MJFH.MJFLAGS and 2^MJFbit_.HBR_FMTS)
             if (MJFlags_set ne 0) then MJFH.MJFLAGS=MJFH.MJFLAGS or 2^MJFbit_.MJF_GDVS

             nDATrec = N_ELEMENTS(MNFSblock)/RECL
             MJFH.DATRECS = nDATrec

             OCT = OCTAL(MJFH.MJFLAGS)
             printfs, mlun, FORMAT=F4240, $
                      IMJF,OCT,MJFH.MNFMISS,MJFH.PARERRS, $
                      MJFH.SYNLOSS,MJFH.SYNMNFS,MJFH.CLKERRS,MJFH.TIKTOK, $
                      MJFH.MJFCNTS
;
;     IFLUSH= 0: Buffer completely filled, flush, next MJF
;             1: Buffer partially  filled, flush, next MJF
;             2: Buffer partially  filled, flush, next file
;             3:
;             4: Buffer empty, next file
;
             ;
             ;    ------ Save MJF to File --------------------------------------
             ;
             if ((IFLUSH eq 1) or (IFLUSH eq 2)) and $
                    (NOT keyword_set(QUIET)) then print, FORMAT=F4230, IFLUSH
             if (IFLUSH le 2) then begin

                   ;    Write out the MJF header

                   MJFheader = Reform_MJFhdr( MJFH )
                   writeu, LUO, MJFheader

                   ;    .. then the NRZ block

                   nNRZwrd = N_ELEMENTS(NRZdata)-1
                   nNRZmod = nNRZwrd MOD NWNRZB
                   case 1 of
                        (nNRZwrd eq 0) : NRZdata = intarr(NWNRZB)
                        (nNRZmod eq 0) : NRZdata = NRZdata(1:nNRZwrd)
                        (nNRZmod ne 0) : BEGIN
                             NRZdata = NRZdata(1:nNRZwrd)
                             nrec_0s = NWNRZB - nNRZmod
                             NRZdata = [NRZdata,intarr(nrec_0s)]
                             END
                        endcase

                   BUFPUSH, NRZdata, NRZblock, nNRZrec, RECL=RECL, /NEW
                   if (nNRZrec ne NRNRZB) then begin
                        message,'Error constructing NRZ block:',/INF
                        message,'Number of Records:'+strtrim(nNRZrec,2)
                   endif
                   writeu, LUO, NRZblock

                   ;    .. and finally the MNF block

                   writeu, LUO, MNFSblock

                   nDATrec = N_ELEMENTS(MNFSblock)/RECL
                   datrec  = datrec + 1 + NRNRZB + nDATrec

                   MNFsblock = -1
             endif

NEXT_FILE:
           ENDREP until (IFLUSH ge 2)
           ;
           ;   ****** END: MJF loop ********************************************
           ;
           free_lun, LUI, LUO

           time_stop  = systime(1)
           dt_process = (time_stop - time_start)/60.0
           printfs,mlun, FORMAT=F4260, IFILEND, IRECEND, dt_process

         endfor
;
;   ****** END: FILE LOOP ******************************************************
;
         WIDGET_CONTROL, Msg_ID, /DESTROY

         if NOT keyword_set(DEBUG) then free_lun, LOG
         return

END
