;+
; NAME:
;        DEF_HBRH
;
; PURPOSE:
;        This routine defines all the pointers and bits to the Major Frame
;        and Minor Frame headers for the Photon Time Interval (PTI) format.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        DEF_HBRH
;
; OUTPUTS:
;        A common block gets filled with pointer and bit values.  See below
;        for definition of the common block.
;
; COMMON BLOCKS:
;        DEF_HBRH: This common block holds all the pointers and bits to the
;                  MJF and MNF headers.
;
;                  NWMJFH:   Length of a MJF header in WORDS
;                  MJFptr_:  A structure containing the index values and their
;                            associated names of all the pointers to the MJF
;                            header.
;                  MJFbit_:  A structure containing the bit values and their
;                            associated names of the MJF Flags variable.
;                  MJFmark:  Value of the MJF marker.
;
;                  NWMNFH:   Length of a MNF header in WORDS
;                  MNFptr_:  A structure containing the index values and their
;                            associated names of all the pointers to the MNF
;                            header.
;                  MNFbit_:  A structure containing the bit values and their
;                            associated names of the MNF Flags variable.
;                  MNFmark:  Value of the MNF marker.
;
;        (*Note: For a description of each pointer or bit, see DEF_HBRH.pro)
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, July 1995.
;-
pro DEF_HBRH

         common DEF_HBRH, NWMJFH, MJFptr_, MJFbit_, MJFmark, $
                          NWMNFH, MNFptr_, MNFbit_, MNFmark, $
                          NWNRZB, NWPTIR


         NWPTIR  =512        ; Number of words/record for PTI format.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;                              MJF Header
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
         NWMJFH  =NWPTIR     ; Words/MJF Header

         MJFptr_ = { $
              MJF    :   0,$  ; MJF number calculated (32-bit integer)
              MJFNRZ :   2,$  ; MJF number read (32-bit integer)
              MJFLAGS:   4,$  ; MJF flags (16 bits) (see below for definition)
              SYNLOSS:   5,$  ; Total number of HBR sync loss errors (32-bit)
              CLKERRS:   7,$  ; Total number of Clock TicToc errors (32-bit)
              MJFCNTS:   9,$  ; Total counts (32-bit)
              MNFMISS:  11,$  ; Number of Missing MNF's
              MNFLAGS:  12,$  ; MNF flags (duplicated)
              MNFNDTS: 140,$  ; Number of Deltat's (counts-1)/MNF
              DATRECS: 268,$  ; Total number of data records written
              DATRECN: 269,$  ; Data record number for each MNF
              PARERRS: 397,$  ; Total number of parity errors
              SYNMNFS: 398,$  ; # MNF's with HBR sync loss errors
              NOSYNCH: 399,$  ; # buffers with no DCS synch bit transition error(s)
              BADSYNC: 400,$  ; # buffers with bad or missing synch pattern error(s)
              TIKTOK : 401,$  ; # buffers with Clock TicToc errors
              BUMSIZ : 402,$  ; # buffers with MNF is not 4096 words long error(s)
              BITSBAD: 403,$  ; # buffers with DCS bit lock lost somewhere in MNF error(s)
              OBOUNDS: 404,$  ; # buffers with MNF extends beyond buffer size error(s)
              MJFMARK: 448 }  ; MJF marker (64 words)

;
;   MJF FLAG BITS (F77 Convention: 0=LSB)
;
         MJFbit_ = { $
              MJF_GDVS   : 0 ,$   ; Global data validity (0=ok)
              MNF_MISS   : 1 ,$   ; MNF(s) missing
              NO_DATAS   : 2 ,$   ; No events (data) detected
              SYN_ERRS   : 3 ,$   ; HBR sync loss error(s)
              PAR_ERRS   : 4 ,$   ; Tape parity error(s)
              HBR_FMTS   : 5 ,$   ; HBR format (0=bit,1=word)
              NOSYN_ERRS : 6 ,$   ; No DCS synch bit transition error(s)
              BADSYN_ERRS: 7 ,$   ; Bad or missing synch pattern error(s)
              CLK_ERRS   : 8 ,$   ; Clock tictoc error(s)
              BUMSIZ_ERRS: 9 ,$   ; MNF is not 4096 words long error(s)
              BITBAD_ERRS: 10,$   ; DCS bit lock lost somewhere in MNF error(s)
              OBOUND_ERRS: 11 }   ; MNF extends beyond buffer size error(s)

;
;   MJF Marker (Use to recover from any read errors)
;
         MJFmark    =reform(byte(['B','O','K','S','T','E','V','E']))
         MJFmark    =MJFmark#replicate(1,8)
         MJFmark    =fix(REFORM(MJFmark,64))
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;                              MNF Header
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;   Added DPM's HBRSYNC flags (07/08/95, H.C. Wen)
;
         NWMNFH    =16                 ; Words/MNF Header

         MNFptr_ = { $
              MNF   :  0,$   ; MNF number calculated/first missing
              MNFNRZ:  1,$   ; MNF number read/ last missing
              MNFLAG:  2,$   ; MNF flags (16 bits) (see definitions below)
              MNFCNT:  3,$   ; Counts this MNF
              NRZOFF:  4,$   ; NRZ data offset in buffers
              SYNLOS:  5,$   ; Number of HBR sync loss errors
              CLKERR:  6,$   ; Number of Clock TicToc errors
              DATREC:  7,$   ; Data record number
              MNFNDT:  8,$   ; Number of Dt's this MNF, this record
              MNFLDT:  9,$   ; Number of Dt's this MNF, last record
              DELBEG: 10,$   ; Time from beginning of MNF to first event
              DELEND: 11,$   ; Time from last event to end MNF
              SYNFLG: 12,$   ; HBRsync flags (16 bits)
              ERROFF: 13,$   ; Error offset in buffers (see HBRsync.pro, flags(1),
              MNFMARK:14 }   ; MNF marker (32-bits)
;
;   MNF flag bits (F77 convention: 0=LSB) (MNFLAG)
;
         MNFbit_ = { $
              MNF_GDV: 0 ,$  ; Global data validity (0=OK)
              MNF_MIS: 1 ,$  ; MNF missing
              NO_DATA: 2 ,$  ; No events (data) detected
              SYN_ERR: 3 ,$  ; HBR sync loss error(s)
              CLK_ERR: 4 ,$  ; Clock tictoc error(s)
              PAR_ER1: 5 ,$  ; Tape parity error buffer 1
              PAR_ER2: 6 ,$  ; Tape parity error buffer 2
              SUSPECT: 7  }  ; Current or previous buffer(s) have one or
                             ;    more fatal HBRSYNC errors.
;                    : 8 ,$  ; Unassigned
;                    : 9 ,$  ; Unassigned
;                    : 10,$  ; Unassigned
;                    : 11,$  ; Unassigned
;                    : 12,$  ; Unassigned
;                    : 13,$  ; Unassigned
;                    : 14,$  ; Unassigned
;                    : 15 }  ; Unassigned

;
;   MNF Marker (Use to recover from any read errors)
;
         MNFmark   =142857143L

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;                              NRZ Block
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

         NWNRZB  =128*128     ; Words/NRZ block (128 words/MNF)
end
