;+
; NAME:
;        READCTI
;
; PURPOSE:
;
;        This routine opens and reads in a Concatenated Time Interval
;        (CTI) file into the structure variable, cat.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        READCTI, Name, Cat
;
; INPUTS:
;        Name:     Name of the CTI file, including the path.
;
; OUTPUTS:
;        Cat:      Structure variable holding all the information read in
;                  from the CTI file.  Its tags are defined as follows:
;
;                  Name :    Name associated with this HBR data file, SSS_TT_FF.
;                            SSS=NRL sequence number, TT=NRL tape number,
;                            FF=NRL file number on the tape.
;                  Target:   Name of the celestial target that the HBR data
;                            is taken from.
;                  IDL:      Structure holding miscellaneous IDL info:
;
;                            Routine:  Name of the IDL procedure that created
;                                      the CTI file, 'CTIFMT.PRO'
;                            Date:     Date/time of CTI creation, SYSTIME().
;                            Version:  IDL version, !VERSION.
;                            File:     Filename of the PTI file, including path.
;
;                  HEAO:     Structure holding miscellaneous HEAO satellite and
;                            A-1 electronics info:
;
;                            Date:     Date/time of HBR data acquisition.
;                            Rev:      Revolution number of the HEAO satellite
;                                      during the HBR data acquisition.
;                            mode:     Various HEAO A-1 electronics modes:
;
;                                      mode(0):  Which modules selected for the
;                                                random encoder -> HBR data:
;                                                3  - modules 1-4
;                                                7  - module 7
;                                      mode(1):  Mode of the NRZ data:
;                                                5  - 5 msec
;                                                320- 320 msec
;                                      mode(2):  Mode of the HEAO satellite:
;                                                0  - scanning/spinning
;                                                1  - pointing
;
;                  MJFH:     Major frame headers* created by HBRFMT,
;                            intarr(512,nMJFH)
;                  MNFH:     Minor frame headers* created by HBRFMT,
;                            intarr(16,nMNFH)
;                  nMJFH:    Number of major frame headers in the PTI file.
;                  nMNFH:    Number of minor frame headers in the PTI file.
;                  nNRZ:     Number of NRZ block in the PTI file.
;                  nPTI:     Number of time intervals in the CTI file.
;                  nbad:     Number of time regions with BAD minor frames.
;                  nAPE:     Number of Adjacent Photon Events (APE) found
;                            in each MJF, intarr(nMJFH).
;                  MJFs:     Major frame numbers, lonarr(nMJFH).
;                  GDV:      Overall Global Data Validity flag (0=Ok, NO
;                            HBRSYNC errors found in entire data file).
;                  NRZ:      Normal 6.4 kbps telemetry data (NRZ),
;                            intarr(128, nNRZ).
;                  PTI:      Corrected photon time intervals, lonarr(nPTI).
;                  ts:       Corresponding photon time relative to the
;                            beginning of the minor frame containing the
;                            first photon, lonarr(nPTI+1).
;                  tbad:     The beginning and end of time regions where
;                            one or more HBRSYNC error were detected,
;                            lonarr(2,nbad). The times are relative to the
;                            beginning of the MNF containing the 1st photon.
;
;        *For a complete description of the headers, see DEF_HBRH.PRO.
;
; RESTRICTIONS:
;
;        The def_hbrh.pro routine must be previously compiled.
;
; COMMON BLOCKS:
;        DEF_HBRH: Holds all the MJF and MNF PTI pointers, (see def_hbrh.pro).
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, October 1995.
;-
pro READNSWAP, LU, A, SWAP=Swap

         readu, LU, A
         if keyword_set(Swap) then A = SWAP_ENDIAN(A)
end

pro READCTI, Name, Cat

         common def_hbrh

         NP   = N_PARAMS()
         if (NP ne 2) then message,'Must be called with 2 parameters: '+$
                                   'Name, Cat'

         openr, lu, Name, /GET_LUN, _EXTRA=WINOPEN(/BINARY)

;   Determine the byte order

         endian_rec= intarr(NWPTIR)
         endian_ck = indgen(NWPTIR)
         readu, LU, endian_rec

         diff = TOTAL( abs(endian_rec - endian_ck) )
         if (diff eq 0) then swap = 0 $
         else begin
              endian_rec= SWAP_ENDIAN(endian_rec)
              diff      = TOTAL( abs(endian_rec - endian_ck) )
              if (diff eq 0) then swap = 1 $
              else message,'Unrecognized PTI format.'
         endelse

;   Read in the string headers

         nbyte     = 0L
         strhdr    = strarr(7)
         for i=0,6 do begin
              readnswap, lu, nbyte, SWAP=swap & input= bytarr(nbyte)
              readnswap, lu, input, SWAP=swap
              strhdr(i) = string(input)
         endfor

         name      = strhdr(0)
         target    = strhdr(1)
         routine   = strhdr(2)
         ctitime   = strhdr(3)
         file      = strhdr(4)
         vers      = strhdr(5)
         sattime   = strhdr(6)

;   Read in miscellaneous HEAO info

         readnswap, lu, nbyte, SWAP=swap & rev  = 0
         readnswap, lu, rev,   SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & mode = intarr(nbyte/2)
         readnswap, lu, mode,  SWAP=swap

;   Extract the MJF and MNF headers

         readnswap, lu, nbyte, SWAP=swap & nMJF = nbyte/4  & MJFs = lonarr(nMJF)
         readnswap, lu, MJFs,  SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & MJFH = intarr(512,nMJF)
         readnswap, lu, MJFH,  SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & nMNF = nbyte/32 & MNFH = intarr(16,nMNF)
         readnswap, lu, MNFH,  SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & GDV  = 0
         readnswap, lu, GDV,   SWAP=swap

;   Get the 6.4 kbps data and the photon info

         readnswap, lu, nbyte, SWAP=swap & nNRZ = nbyte/256 & NRZ = intarr(128,nNRZ)
         readnswap, lu, NRZ,   SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & nPTI = nbyte/4   & PTI = lonarr(nPTI)
         readnswap, lu, PTI,   SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & nts  = nbyte/4   &  ts = lonarr(nts)
         readnswap, lu, ts,    SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & nbad = nbyte/8   &  tbad = lonarr(2,nbad)
         readnswap, lu, tbad,  SWAP=swap
         readnswap, lu, nbyte, SWAP=swap & nAPE = intarr(nbyte/2)
         readnswap, lu, nAPE,  SWAP=swap

         if (nPTI eq 1) and (PTI(0) eq -1) then nPTI=0L
         if (nbad eq 1) and (tbad(0)eq -1) then nbad=0L

         free_lun,lu

;   Pack the IDL structure variables

         IDL       = { routine : routine, $
                       date    : ctitime, $
                       version : vers,    $
                       file    : file }
         heao      = { rev     : rev,     $
                       mode    : mode,    $
                       date    : sattime  }
         cat  = {  name      : name,             $
                   target    : target,           $
                   idl       : idl,              $
                   heao      : heao,             $
                   MJFH      : MJFH,             $
                   MNFH      : MNFH,             $
                   nMJFH     : fix(nMJF),        $
                   nMNFH     : fix(nMNF),        $
                   nNRZ      : fix(nNRZ),        $
                   nPTI      : nPTI,             $
                   nbad      : nbad,             $
                   nAPE      : nAPE,             $
                   MJFs      : MJFs,             $
                   GDV       : GDV,              $
                   NRZ       : temporary(NRZ),   $
                   PTI       : temporary(PTI),   $
                   ts        : temporary(ts),    $
                   tbad      : temporary(tbad)   }
end
