;+
; NAME:
;        READPTI
;
; PURPOSE:
;        This routine reads in the next MJF block of Photon Time Interval (PTI)
;        file and supplies it to the USER in a structure variable.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        READPTI, LU, Block
;
; INPUTS:
;
;        LU:       Logical unit associated with the current PTI file.
;
; OUTPUTS:
;
;        Block:    Structure variable holding the next MJF block of PTI data.
;                  The tags are defined as follows:
;
;                  MJFH:     An array holding the MJF header, intarr(512).
;                  MNFH:     An array holding the MNF header for each MNF
;                            present in this MJF block, intarr(16,nMNFH*).
;                  NRZ:      An array holding the NRZ data**, intarr(128,nMNF*).
;                  PTI:      An array holding all the photon time intervals** in
;                            7.8125 usec bins in this MJF block, lonarr(ndt).
;                            (E.g. A value of 1 means that two photons occurred
;                            within adjacent 7.8125 usec bins.)
;
;        * (see PROCEDURE below for definitions).
;        **(see PROCEDURE below for caveats).
;
; OUTPUT KEYWORD PARAMETERS:
;
;        ERROR:    Error status code:
;                       0,   Success.
;                       1,   End of File.
;                       2,   Could not find MJF marker.
;                       3,   Cound not find MNF marker.
;                  !error,   I/O error.
;
; COMMON BLOCKS:
;        DEF_HBRH: Holds all the MJF and MNF PTI pointers, (see def_hbrh.pro).
;
; PROCEDURE:
;        * There are several HBR data files where there are one or more missing
;        MNFs.  For each contiguous section of missing MNFs (e.g. missing
;        MNFs = [23,24,25]) one MNFH header is written out.  No PTI or NRZ data
;        is associated with this header.  Therefore,
;
;        nMISS                         , Number of missing MNFs in this MJF.
;        nsect                         , Number of contiguous section(s) of
;                                        missing MNFs, (e.g. missing MNFs =
;                                        [23,24,25, 100] => nMISS_sec = 2)
;        nMNFH = 128 - nMISS + nsect   , Number of actual MNF headers written out
;        nMNF  = 128 - nMISS           , Number of MNFs present (i.e. NOT missing)
;                                        in the MJF of data.
;
;        ** If there are NO photons in a MJF then NRZ = PTI = -1.  This can
;        happen if an entire MJF is missing or if NO counts are actually detected
;        in a MJF.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1995.
;        31-AUG-1995    Let PTI=-nMNFw if no photons in entire MJF.
;        28-SEP-1995    Added negative numbers due to overflow comments; check
;                       for PTIs > 32767 across adjacent MNFs.
;        29-SEP-1995    Eliminated any negative PTIs due to overflows or
;                       missing MNFs by converting the PTI array output to a
;                       long integer array.
;        30-SEP-1995    Eliminated non-existent NRZ data from Block.NRZ due
;                       to one or more missing MNFs.
;-
pro READPTI, LU, Block, ERROR=Error

         common DEF_HBRH     ; Defined in def_hbrh.pro
         common PTI_ENDIAN,  endian_swap_


         overflow  = 65536L

         Error = -1 & ON_IOERROR, ERROR_

         NP   = N_PARAMS()
         if (NP lt 1) or (NP gt 2) then $
              message,'Must be called with 1-2 parameters: LU [, Block]'

;   Check for End-of-File

         Error = 1 & if EOF(LU) then goto, ERROR_

         PTIrec    = intarr(NWPTIR)              ; Define PTI record

;   Read/Check/Search for Major Frame Header

         repeat begin
              readu, LU, PTIrec
              if (endian_swap_) then byteorder, PTIrec, /SSWAP
              i      = MJFptr_.MJFMARK
              marker = PTIrec( i:i+63 )          ; Check for MJF marker
              diff   = TOTAL(abs(marker - MJFmark))
         endrep until (diff eq 0) or EOF(LU)

         Error = 2 & if EOF(LU) then goto, ERROR_

         MJFH      = PTIrec

;   Read in NRZ (6.4 kps) Data block

         NRZ       = intarr(NWNRZB)              ; NRZ block
         nMNF      = 128                         ; Number of Minor frames/MJF
         NWNRZ     = NWNRZB/nMNF                 ; = 128 words of NRZ data/MNF

         readu, LU, NRZ
         if (endian_swap_) then byteorder, NRZ, /SSWAP
         NRZ  = REFORM(NRZ,NWNRZ,nMNF, $         ; NRZ record/MNF
                        /OVERWRITE)

;   Read in all Minor Frame data records

         nrecMNFs  = MJFH( MJFptr_.DATRECS )
         DATArecs  = intarr(long(nrecMNFs)*NWPTIR)

         readu, LU, DATArecs                     ; Read in all data records
         if (endian_swap_) then byteorder, DATArecs, /SSWAP
         DATArecs   = REFORM( DATArecs, $        ; DATA record/MNF
                        NWPTIR, nrecMNFs, $
                        /OVERWRITE )


;   Determine MNF record numbers

         mrkstr    = 'MNF'
         i         = MJFptr_.DATRECN
         MNFrecn   = MJFH( i:i+nMNF-1 )          ; Eliminate any missing MNFs
         here      = WHERE( MNFrecn ne 0, nne0 ) ;    not reported by HBRFMT
         Error = 3 & if (nne0 eq 0) then goto, ERROR_
         MNFrecn   = MNFrecn(here)

         here      = UNIQ( MNFrecn )             ; Removing redundant missing
         MNFrecn   = MNFrecn(here)               ;    MNFs record numbers
         nMNFw     = N_ELEMENTS( MNFrecn )       ; Number of MNFs written to PTI file

;   Extract MNF headers

         rec_offset= MNFrecn - MNFrecn(0)
         MNFH      = DATArecs( 0:NWMNFH-1, rec_offset )

;   Check MNF marker

         i         = MNFptr_.MNFMARK
         markint   = MNFH( i:i+1,* )
         markers   = lonarr( nMNFw )
         EQUIV, markers, markint

         here      = WHERE( markers ne MNFMARK, nne0 )
         Error = 3 & if (nne0 gt 0) then goto, ERROR_

;   Extract number of DATA record numbers written for each MNF

         if (nMNFw eq 1) then nrecDATA = nrecMNFs - rec_offset(0) $
         else begin
              nrecDATA  = [rec_offset(1:nMNFw-1), nrecMNFs]
              nrecDATA  = nrecDATA - rec_offset(0:nMNFw-1)
         endelse

;   and the Photon Time Intervals

         ntot = MJFH(MJFptr_.MJFCNTS)            ; Total number of photons in this MJF
         k    = 0                                ; Number of MNFs with photons present
         npho = REFORM(MNFH(MNFptr_.MNFCNT,*))   ; Number of photons in the MNF
         ndt  = npho - 1                         ; Number of PTIs in the MNF
         for i=0,nMNFw-1 do begin

              ;    See if this is a MISSING MNF block
              MNFmiss_bit    = MNFH(MNFptr_.MNFLAG,i) and 2^MNFbit_.MNF_MIS
              if (MNFmiss_bit ne 0) then goto, SKIP_MISS

              case 1 of

              ;    Two or more photons in MNF
              (npho(i) gt 1) : begin
                   k    = k+1
                   nrec = nrecDATA(i)
                   j    = rec_offset(i)
                   data = DATArecs( *, j:j+nrec-1 )
                   data = REFORM( data, nrec*NWPTIR, /OVERWRITE )
                   data = long(data( NWMNFH: NWMNFH + ndt(i)-1 ))

                   ;    Check for 16-bit overflows

                   hovr = where( data lt 0, novr )
                   if (novr gt 0) then $
                        data(hovr)     = data(hovr) + overflow

                   if (k eq 1) then PTI = data $
                   else begin

                   ;    Extract time interval from beginning of MNF
                   ;    to 1st photon.  With dt_EOMNF, construct the
                   ;    time interval between last and first photons
                   ;    of "adjacent" MNFs.

                        dt_SOMNF  = long(MNFH( MNFptr_.DELBEG,i ))
                        if (dt_SOMNF lt 0) then dt_SOMNF = dt_SOMNF + overflow

                        dt_pho1   = dt_EOMNF + dt_SOMNF

                   ;    If there are missing MNFs between current and
                   ;    previous MNFs, then we must add that time interval
                   ;    to dt_pho1

                        mnf_skip  = MNFH(MNFptr_.MNFNRZ,i) - $
                                    MNFH(MNFptr_.MNFNRZ,i_last) - 1
                        if (mnf_skip gt 0) then $
                             dt_pho1   = dt_pho1 + mnf_skip*40960L

                   ;    Finally add this 1st and remaining time intervals for
                   ;    this MNF to the PTI array.

                        PTI = [PTI, dt_pho1, data]
                   endelse

                   ;    Extract time interval from last photon
                   ;    to end of MNF

                   dt_EOMNF  = long(MNFH( MNFptr_.DELEND,i ))
                   if (dt_EOMNF lt 0) then dt_EOMNF = dt_EOMNF + overflow

                   i_last    = i
                   end

              ;    One photon in MNF
              (npho(i) eq 1) : begin
                   k    = k+1
                   if (k gt 1) then begin
                        dt_SOMNF  = long(MNFH( MNFptr_.DELBEG,i ))
                        if (dt_SOMNF lt 0) then dt_SOMNF = dt_SOMNF + overflow
                        dt_pho1   = dt_EOMNF + dt_SOMNF
                        PTI       = [PTI,dt_pho1]
                   endif
                   dt_EOMNF  = long(MNFH( MNFptr_.DELEND,i ))
                   if (dt_EOMNF lt 0) then dt_EOMNF = dt_EOMNF + overflow
                   end

              ;    NO photons in MNF
              (npho(i) eq 0) : if (k gt 1) then dt_EOMNF  = dt_EOMNF + 40960L

              endcase
SKIP_MISS:
         endfor

         if (N_ELEMENTS(PTI) eq 0) then PTI=-1

;   MNF headers describing missing MNFs have NO associated NRZ data.
;   The actual amount of NRZ data contained in a (128,128) NRZ block is
;   (128,nMNF-nskip), where nskip is the number of MNF headers with
;   missing MNFs.

         b_MNFmiss = MNFH(mnfptr_.MNFLAG,*) and 2^MNFbit_.MNF_MIS
         hdata     = where(b_MNFmiss eq 0,ndata)    ;i.e. ndata = nMNF-nskip
         if (ndata gt 0) then NRZ = NRZ(*,0:ndata-1) $
         else NRZ = -1

         block = { MJFH : MJFH, $
                   NRZ  : NRZ,  $
                   MNFH : MNFH, $
                   PTI  : PTI   }

         Error = 0 & return

ERROR_:  fptr      = FSTAT(LU)
         nbytes    = fptr.CUR_PTR
         nrec      = nbytes/(2*NWPTIR)

         case Error of
              1    :                   ; End of File
              2    : BEGIN             ; MJF marker error
                   message,'Could NOT find MJF marker!',/INF
                   message,'Number of records searched: '+strtrim(nrec,2),/INF
                   END
              3    : BEGIN             ; MNF marker error
                   message,'Could NOT find MNF marker!',/INF
                   message,'Number of records searched: '+strtrim(nrec,2),/INF
                   END
              else : BEGIN
                   message,'Error reading PTI data file at RECORD:'+strtrim(nrec,2),/INF
                   print, strmessage(!error)
                   Error = !error
                   END
         endcase
end
