;+
; NAME:
;        OPENPTI
;
; PURPOSE:
;        This routine opens a Photon Time Interval (PTI) file.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        OPENPTI, LU, File
;
; INPUTS:
;
;        LU:       The logical unit to be associated with the opened PTI file.
;                  If LU is undefined then the GET_LUN procedure is automatically
;                  used to set its value.
;
; OPTIONAL INPUTS:
;
;        File:     A string containing the name of the PTI file to be opened.
;                  If this parameter is not provided, then the PICKFILE routine
;                  is used to allow the USER to interactively select the name
;                  of the PTI file.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        GET_LUN:  Force the GET_LUN procedure to be called to defined LU if
;                  LU is undefined or redefine LU if it is.
;
; OPTIONAL OUTPUT KEYWORD PARAMETERS:
;
;        NRECORDS: The total number of 512 byte records in the opened PTI file.
;
; COMMON BLOCKS:
;        DEF_HBRH:      Holds all the MJF and MNF PTI pointers, (see def_hbrh.pro).
;        PTI_ENDIAN:    Holds variable that determines whether or not to swap bytes.
;
; PROCEDURE:
;        Opens a PTI file and reads in the first record to determine the byte order.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1995.
;        29-SEP-1995    Added GET_LUN keyword.
;        08-OCT-1995    Eliminated XDR and BINARY keywords; check for byte order;
;                       made compatible with vers 4.0.1.
;        09-OCT-1995    Moved Win 4.0.1 specific keywords to WINOPEN function.
;-
pro OPENPTI, LU, File, NRECORDS=NRECORDS, GET_LUN=Get_LUN_set

         common DEF_HBRH     ; Defined in def_hbrh.pro
         common PTI_ENDIAN,  endian_swap_

         NP = N_PARAMS()
         if (NP eq 0) or (NP gt 2) then $
             message,'Must be called with 1-2 parameters: LU [, File]'

         if (N_ELEMENTS(LU) eq 0) or keyword_set(Get_LUN_set) then GET_LUN, LU

         if (NP eq 1) then File = pickfile()

         def_hbrh

         openr, LU, File, _EXTRA=WINOPEN( /BINARY )

         iss       = fstat(LU)
         NRECORDS  = iss.SIZE/(NWPTIR*2)

;   Determine the byte order

         endian_rec= intarr(NWPTIR)
         endian_ck = indgen(NWPTIR)
         readu, LU, endian_rec

         diff = TOTAL( abs(endian_rec - endian_ck) )
         if (diff eq 0) then endian_swap_ = 0 $
         else begin
              endian_rec= SWAP_ENDIAN(endian_rec)
              diff      = TOTAL( abs(endian_rec - endian_ck) )
              if (diff eq 0) then endian_swap_ = 1 $
              else message,'Unrecognized PTI format.'
         endelse
end
