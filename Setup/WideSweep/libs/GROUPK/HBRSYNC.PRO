;+
; NAME:
;        HBRSYNC
;
; PURPOSE:
;        This routine processes the HBRB data (High-Bit-Rate in Bit telemetry
;        mode) and extracts the 128 kbps and 6.4 kbps datastream for a
;        minor frame.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        HBRSYNC, Buf [, HBR, NRZ, MJF, MNF, Flags]
;
; INPUTS:
;        Buf  :    A concatenation of two HBR records, the earlier one
;                  first.  Namely, a 2*4096 element 2-byte array, intarr(8192).
;
; INPUT KEYWORD PARAMETERS:
;
;        INIT :    Set this keyword to initialize various parameters used in
;                  subsequent calls to this routine.
;
; OPTIONAL OUTPUTS:
;
;        HBR  :    The 128 kbps datastream packed into 4096 words, intarr(4096)
;                  containing a minor frame (320ms) of data.
;
;        NRZ  :    The 6.4 kbps datastream packed into 128 words, intarr(128)
;                  containing a minor frame (320ms) of data.
;
;        MJF  :    The major frame number, long.
;
;        MNF  :    The minor frame number, integer [0-127].
;
;        Flags:    A 3-element integer array containing possible error flags:
;
;                  Flags(0)  : Error code
;                                 0,        Success.
;                                 2,        Failure to find 6.4 kb DCS lock.
;                                 3,        Bad or missing synch pattern.
;                                 4,        Alternate failure(s) in NRZ clock.
;                                 5,        Minor frame is not 4096 words long.
;                                 6,        DCS bit lock lost somewhere in frame
;                                 7,        Minor frame is out of Buf array boundary.
;
;                  Flags(1)  : if Flags(0) =
;                                 3,        Word offset to the start of the minor
;                                             frame with a bad or missing synch
;                                             pattern.  This offset is relative to
;                                             the next DCS synch bit transition to 0.
;                                 4,        Number of tick tock errors.
;                                 5,        Word offset to the next DCS synch bit
;                                             transition to 0.
;                                 6,        Word offset to the lost DCS bit lock.
;                                 7,        Word offset to the end of the minor frame.
;
;                              ** Unless stated otherwise, all word offsets are
;                                 relative to the start of the buffer.
;
;                  Flags(2)  : Word offset in Buf array to the "real" start of
;                              the minor frame for the NRZ data.
;
; COMMON BLOCKS:
;
;        HBRSYNC:  This common blocks holds various parameters and static
;             variables used in repeated calls to this routine.
;
; PROCEDURE:
;        You must call first this routine with the INIT keyword set to define
;        various parameters.
;
;
; MODIFICATION HISTORY:
;
; MODIFIED 3 31 83 TO CORRECT FOR OBSERVED TICKTOCK ERRORS ON SOME TAPES
; INIT ENTRY ADDED.
;  MODULE TO CONTAIN BIT SHOVING STUFF FOR HEAO HIGH BIT RATE DATA
;  D P MCNUTT  1 26 83    -    NO RIGHTS RESERVED
;
; THE FOLLOWING ASSEMBLY PARAMETER AFFECTS THE TIMING OF THE MINOR FRAME
; DATA RETURNED.  FAZEF=0 WILL USE THE EARLIER OF THE TWO AVAILABLE COPIES OF
; A MINOR FRAME, FAZEF=1 WILL USE THE LATER.
;
;   **** I will use the convention that BIT 0 is the LEAST significant bit.
;   **** All numbers will be in base 10, unless stated otherwise.
;
;   We will assume that the data is in BIG Endian convention since this
;   routine was written for the Data Generals which used this convention.
;
;   "Ported" to IDL from Data
;   General Eclipse assembly      : Han Wen, April 1995.
;        23-APR-1995              Bugfix: NRZ was returning as a long integer (4-byte)
;                                 instead of a (2-byte) integer.
;        08-JUL-1995              Changed word offset (Flags(1)) for BITSBAD error
;                                 relative to start of buffer instead of start of minor
;                                 frame.
;-
pro HBRSYNC, Buf, HBR, NRZ, MJF, MNF, Flags, INIT=Init

         common HBRSYNC, B_, E_, V_, C_
;
         if keyword_set(INIT) then begin

         ;  Define various bit parameters

              B_ = { $
                   LOSS:15,$  ; Analog lost data bit
                   HLOK:14,$  ; High bit rate lock
                   TIKT:13,$  ; Tick tock FAZEF bit for copies of NRZ data
                   LNRZ:12,$  ; 6.4kb NRZ data
                   FSYN:7 ,$  ; Frame synch flag from the DCS ground station
                   LLOK:6 ,$  ; 6.4kb bit synch lock flag
                   HBR1:11,$
                   HBR2:8 ,$  ; Bit locations in source words of HBR data bytes
                   HBR3:5 ,$
                   HBR4:0  }

         ;  Define error codes for the Flags array

              E_ = { $
                   NOSYNCH :2,$   ; Failure to find 6.4 kb DCS lock
                   BADSYNCH:3,$   ; Bad or missing synch pattern
                                  ;   second word is SLIP value
                   TIKTOK  :4,$   ; Alternate failure(s) in NRZ clock
                                  ;   second word is count thereof
                   BUMSIZ  :5,$   ; Minor frame is not 4096 words long
                                  ;   second word is ordinal of next synch
                                  ;   bit transition if it occurred early.
                   BITSBAD :6,$   ; DCS bit lock lost somewhere in the frame
                   OBOUNDS :7 }   ; Minor frame is out of Buf bounds
                                  ;   second word is end of minor frame offset

         ;  Define other miscellaneous constants

              SLIPR     = 100
              LBUF      =8192          ; Length of double buffer in 16 bit words
              LIMBF     =-LBUF/2-SLIPR

              C_ = { $
                   SLIPR: SLIPR,$      ; +/- range allowed for slip checking
                   LIMBF: LIMBF,$      ; = -4196, limiting address in search for
                                       ;    DCS synch
                   LIMB2: -4095+16,$   ; = -4079, Length of scan to find second
                                       ;    sync flag.
                   LOKC9: -4096,$
                   TTMSK: 8192,$       ; Mask for tick tock bit (6.4kb clock)
                                       ; 0010 0000 0000 0000

                   TTERR: -16384, $    ; Fill word in case of ticktock failure
                                       ; 1100 0000 0000 0000

                   ; BARKER CODE 24: 111 110 101 111 001 100 100 000
                   PTRNH:  -1293,$     ; 1 111 101 011 110 011
                   PTRNL:  8192  }     ; 0 010 000 000 000 000

         ;  Define various STATIC variables

              V_ = { $
                   SLIP :-64,$    ; Offset required to give earlier minor frame
                                  ; this value requires that TTSAV be initialized
                                  ; to 0
                   TTSAV:0,$      ; Storage for 'last' ticktock value
                   TTCNT:0,$      ; Counter for ticktock failures
                   INITF:0,$      ; Init/reinit flag, zero means init
                   TTTRY:0,$      ; Try counter for ticktock phasing
                   TTINI:0 }

              return
         endif

;   Leftover stuff from HBRSYNC.SR
;
;        FAZEF=0
;        BANANA=0 ; Set so that slip will not be reset on synch fail ; on 3/31


;   Initialize/define output arguments

         if N_ELEMENTS( MJF ) eq 0 then MJF = 0L

         HBR       = intarr(4096)
         NRZ       = intarr(128)
         Flags     = intarr(3)

         V_.TTTRY  = 0            ; Set try count for ticktock phasing
         SLIPS     = V_.SLIP      ; Save beginning value for loop test

;
;   Search for the first word in the buffer in which the frame synch word is
;   set.  this means that the DCS ground station is locked on and has found
;   the minor frame synch word.
;
         bitsets   = (BUF(C_.SLIPR:8191) and 2^B_.FSYN)    ; Bump C_.SLIPR words
                                                           ; ahead to avoid
                                                           ; early synch pattern

         here0     = WHERE( bitsets eq 0, nzero )     ; The first word where
                                                      ; the B_.FSYN bit is NOT
                                                      ; set points to the first
                                                      ; DCS frame synch

         if (nzero eq 0) then begin
              Flags(0) = E_.NOSYNCH         ; DCS never found frame synch
              return                        ; Exit with error flag
         endif

;   Check next synch transition to see if it is 4096 words away.
;   For each minor frame (i.e. 320ms time interval), there are 16 sequential
;   words where bit B_.FSYN is 0.  So the 17th word where bit B_.FSYN is 0
;   should contain the next synch transition.

         if (nzero gt 16) then begin        ; If nzero eq 16, then next
                                            ; synch transition is out of buffer.
                                            ; Assume it's okay.

              if ((here0(16) - here0(0)) ne 4096) then begin
                   Flags(0) = E_.BUMSIZ               ;Error code
                   Flags(1) = C_.SLIPR + here0(16)    ;Word offset of
                                                      ;offending bit
                   return
              endif
         endif

RENTR:                            ; Possible reentry if SLIP value is bad

         START     = C_.SLIPR+ here0(0)     ; Offset of the first DCS sync bit
         START     = START   + V_.SLIP      ; Position to "real" start of minor
                                            ; frame
         Flags(2)  = START        ; Send start offset to caller  *-*
                                  ; In third word of flags       *-* 3-8-83
;
;   Check to see if minor frame is within buffer
;
         if START gt 4096 then begin
              Flags(0)  = E_.OBOUNDS
              Flags(1)  = START + 4095      ; Return out of bound offset
              return
         endif

;
;   Now pack up the minor frame into caller's buffer.
;
         BNRZ = BUF(START + 2*indgen(128*16))    ; Get every other word
         BNRZ = (BNRZ and 2^B_.LNRZ) ne 0        ; Pick out 6.4kb NRZ bits
         BNRZ = REFORM( BNRZ,16,128,/OVERWRITE ) ; Each 16 element array represents
                                                 ; the bit pattern of one minor frame,
                                                 ; where the 0th element corresponds
                                                 ; to the MSB, 2^15.
         bbase= REVERSE(indgen(16))
         bbase= 2^bbase                          ; i.e. [2^15, 2^14, ... 2^0]

         NRZ  = FIX(TRANSPOSE( bbase#BNRZ ))
;
;   Now see if we got a synch pattern at the right place
;
         SYBAD = 0

         if (NRZ(0) eq C_.PTRNH) then begin      ; Synch pattern HI
              AC0  = C_.PTRNL
              AC1  = NRZ(1) and -256             ; Only keep upper 8 bits

              if AC0 ne AC1 then SYBAD = 1
         endif else SYBAD = 1                    ; No match


         SYBA1 = 0                               ; Date: 3/31
         if SYBAD then begin                     ; If at beginning allow slip to
              if V_.INITF eq 0 then begin        ; adjust, otherwise fail on no
                   AC0  = V_.SLIP - 1            ; synch
                   AC1  = AC0  + C_.SLIPR        ; Limiting value
                                                 ; See if there, and if so,
                   if AC1 eq 0 then AC0 = 0      ; replace w/ other limit.
                   V_.SLIP = AC0
                   if (SLIPS ne V_.SLIP) then $  ; See if we have gone full
                        goto, RENTR              ; circle
                   SYBA1 = 1
              endif else SYBA1 = 1
         endif

         if SYBA1 then begin
              Flags(0) = E_.BADSYNCH
              Flags(1) = V_.SLIP
              return
         endif

;
;   Check DCS bit lock bit - if zero anywhere we will fail
;

         bitsets   = (BUF(START:START+4095) and 2^B_.LLOK)      ; Pick out DCS
                                                                ; bit lock


         here_bad  = WHERE( bitsets ne 0, nbad )

         if (nbad gt 0) then begin
              Flags(0)  = E_.BITSBAD   ; Set error flags for caller
              Flags(1)  = START + here_bad(0)
              return
         endif

;
;   CELL = 1 byte = 8 bits
;
;   Pick up the subframe ID and pass to caller
;      20 bits of the spacecraft clock are contained in cells 128,129,130
;   of each minor frame, the upper 4 bits of 128 being garbage.  eight more
;   bits of clock are transmitted in cell 81 of  minor frame 118.
;

         AC1  = NRZ(65)                ; CELLS  130 AND 131
         AC0  = NRZ(64)                ; CELLS  128 AND 129
         AC0  = AC0  and 4095          ; Clear out bits 12 thru 15
         CARRY= (AC1 and -32768) ne 0  ; Shift bit 15 into the CARRY
         if CARRY then $
         AC1  = (AC1 xor -32768 )
         AC1  = ISHFT(AC1,-8)          ; Get rid of garbage CELL 131.
         AC0  = ISHFT(AC0,1)           ; Shift and put CARRY into
         AC0  = AC0 + CARRY            ; bit 0.
         MNF  = AC1
         if (MNF ne 118) then begin    ; Get callers MJF bits
              ACL = ISHFT(MJF,3)
              AC1 = ISHFT(ACL,-16)     ; Get upper 16 bits of ACL
         endif else AC1 = NRZ(40)     ; Cell 81 plus garbage in high bits

         DUM  = AC0
         AC0  = AC1
         AC1  = long( DUM )
         AC0  = long( AC0 and 255 )    ; Lower 8 bits, 255=0000 0000 1111 1111
         AC1  = ISHFT( AC1,  3 )       ; Left justify low order bits
         MJF  = ISHFT( AC0, 16 ) + AC1
         MJF  = ISHFT( MJF, -3 )       ; and merge with the hi

;
;
;   Now we need to pack the high bit rate bits into the caller's output buffer
;   we will pick up one word at a time and shift the bits around.  In the output
;   the sign bit will be set if the HBR lock bit was set or if we had a tick-tock
;   sequence error.
;
;   There are 10 bits of HBR data for each BUF word, namely there are
;   ten 7.8125 microsecond time intervals where one or more photons may have
;   been detected.  Each bit that is set represents a detection of one or
;   more photons.  (We are assuming that the data is in the HBRB or High Bit
;   Rate BIT format.)
;
         HBRwrds   = (BUF and 63)                     or $  ; Bits 0 - 5
                     (ISHFT(BUF,-2) and 960)          or $  ; Bits 8 - 11
                     (ISHFT(BUF and 2^B_.HLOK,15-B_.HLOK))

HBM_0:
         V_.TTSAV= V_.TTINI       ; Value varies with assembly parameter "FAZEF"
         INC1 = 0 - 1             ; Set auto incrementer for destination buffer
         INC0 = START - 1         ; Set auto incrementer for source buffer
         COUNT= 4096              ; Set number of words to move

;
;   The bit picked up by TTMSK should be "tick-tock"ing between values
;   0 and 1 for sequential BUF words.
;
         for i=1,COUNT do begin

              INC0 = INC0 + 1
              AC1  = BUF(INC0)         ; Load up next source word
              AC2  = AC1 and C_.TTMSK  ; Pick up NRZ clock bit only
              AC0  = V_.TTSAV
              V_.TTSAV= AC2

              HBRfill   = HBRwrds(INC0)

              if (AC2 eq AC0) then begin    ; If next "tick" is a "tock"-> error
                   V_.TTSAV= C_.TTMSK xor AC2
                   AC0  = C_.TTERR
                   INC0 = INC0 - 1                 ; Move back in the source
                   if INC0 ne 0 then HBRfill = AC0 ; and go store the fill data
              endif

              INC1      = INC1 + 1
              HBR(INC1) = HBRfill

         endfor
;
;   Now calculate the number of words actually loaded from the buffer.  should
;   be 4096 - if not we had a ticktock error.
;

         AC0  = START + 4095
         AC0  = AC0 - INC0
         if AC0 ne 0 then begin   ; Will be zero if no tick tock errors

              if (V_.TTTRY ne 0) or $       ; Have tried both phases - just fail
                 (V_.INITF ne 0) then $     ; See if we ever had a good one
                 begin                      ;    yes so fail now
                   Flags(0) = E_.TIKTOK     ; Return with error
                   Flags(1) = AC0
                   return
              endif

              V_.TTINI = C_.TTMSK xor V_.TTINI   ; Otherwise invert the
              V_.TTTRY = V_.TTTRY + 1            ; initializer and try again.
              goto, HBM_0

         endif

         Flags(0) = AC0
         Flags(1) = V_.TTINI           ; Pass the initial value to DJY if he wants it
         V_.INITF = 1                  ; Adjust the innitializer flag
                                       ;  to show a successful pass
         return                        ; Return with no errors
;
;
;  A known problem with this code can occur when and if the synch pattern
; occurs before the beginning of the buffer and the DCS frame synch bit
; comes true right at the beginning of the buffer.  If this happens a simple
; fix is to save some data in storage space before the beginning of the
; buffer.  It happened: MURPHY'S RULE IS PROVEN; it's been fixed.
;
end
