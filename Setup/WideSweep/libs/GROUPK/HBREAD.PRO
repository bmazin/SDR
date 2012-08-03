;+
;   HBR digitized 9-track tape read routine (used by HBRFMT)
;
;   Written by Daryl J. Yentis, Naval Research Laboratory, SSD 02/08/83.
;   Adapted to IDL by H.C. Wen, 4/18/95
;-

function HBREAD, LU,OBuff, MNFword, Copy, IOS

         COMMON HBRFMT, NOVA_

;         ON_IOERROR, IO_err                           ; IDL I/O error

         IBUF=NOVA_.NOVABUF+2*NOVA_.C_BUF
         NBUF=NOVA_.NOVABUF/2
         IOS =0

         Buffer = intarr(IBUF/2)

         if EOF(LU) then goto, IO_EOF                 ; End-of-file

         READU, LU, Buffer
         BYTEORDER, Buffer, /HTONS                    ; Byte swap on PC,VMS

         MNFword   = Buffer(0)
         OBuff     = Buffer(1:NBUF-1)
         Copy      = Buffer(NBUF:NBUF+NOVA_.C_BUF-1)

         IOS       = Copy(NOVA_.C_IER)
         if (IOS ne 0) then goto, IO_AOS              ; AOS I/O error

         IOS  =  N_ELEMENTS( Buffer )
         return, 0

IO_EOF:  return, 1
IO_AOS:  return, 2
IO_ERR:  IOS  = !ERROR
         return, 3
end
