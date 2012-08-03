;+
; NAME:
;        ACNVRT
;
; PURPOSE:
;        This function converts the HEAO A-1 quasi-logarithmic numbers
;        to HEAO A-1 Science Data and vice versa.
;
;        HEAO A-1 quasi-logarithmic number format:
;        (8 BITS) - CCCMMMMM (C=CHARACTERISTIC, M=MANTISSA)
;
;        These quasi-logarithmic numbers are the result of the onboard
;        HEAO A-1 quasi-logarithmic scalars and are present in the raw
;        2.1 kbps A-1 portion of the NRZ data.
;
; CATEGORY:
;        HEAO.
;
; CALLING SEQUENCE:
;
;        Result = ACNVRT( Data )
;
; INPUTS:
;        Data:     Array of any dimensions containing either the HEAO A-1
;                  quasi-logarithmic numbers OR the HEAO A-1 Science
;                  Data.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        INVERSE:  Set this keyword to convert A-1 Science Data to
;                  HEAO A-1 quasi-logarithmic numbers, (0=Default).
;
; OUTPUTS:
;        This function returns A-1 Science Data converted from the input
;        Data array or A-1 quasi-logarithmic numbers, if the INVERSE keyword
;        is set.
;
; MODIFICATION HISTORY:
;        Written by:    Daryl J. Yentis, Naval Research laboratory, SSD 1980.
;        13-JUN-1994    H.C. Wen - Adapted to IDL; added INVERSE keyword.
;-
function ACNVRT, Data, INVERSE=Inverse

         IEXP2=[1,2,4,8,16,32]

         ND   = N_ELEMENTS(Data)

         if keyword_set(INVERSE) then begin
              ID   = FIX(Data)
              h64  = where(Data gt 64, n64)
              if (n64 gt 0) then begin
                   D64  = FIX(Data(h64))
                   char = REPLICATE(2,n64)
                   h127 = where(D64 gt 127, n127)
                   while (n127 gt 0) do begin
                        D64(h127) = ISHFT(D64(h127),-1)
                        char(h127)= char(h127)+1
                        h127      = where(D64 gt 127, n127)
                  endwhile
                  mant  = ISHFT(D64-64,-1)
                  ID(h64)= ISHFT(char,5) + mant
              endif
              return, ID

         endif

         ID   = FIX(Data)              ; convert to 16-bit words

         ;  FINISHED IF D=0 OR C=0 OR 1
         here = WHERE( ID ge '100'O, nconvert )

         if (nconvert gt 0) then begin

         ;  CHARACTERISTIC (3-BITS)
         ;    IC=ISHIFT(ID,-5).AND.7K
              ICs=ID(here)/'40'O

         ;  MANTISSA (5-BITS)
              IMs=ID(here) and '37'O

         ;  D = (2*(M+32)+1)*(2**(C-2))
         ;    DATA(I)=ISHIFT(2*IM+65,IC-2)
              ID(here)=(2*IMs+65)*IEXP2(ICs-2)

         endif

         return, ID

end
