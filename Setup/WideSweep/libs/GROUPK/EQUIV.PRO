;+
; NAME:
;        EQUIV
;
; PURPOSE:
;        This procedure equates arrays of different integer types, similar to
;        Fortran's Equivalence function.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        EQUIV, Target, Source [, iTar, iSrc]
;
; INPUTS:
;        Target:   Target array.
;
;        Source:   Source array.
;
; OPTIONAL INPUTS:
;
;        iTar:     Starting index of the target array.  If this parameter is
;                  not provided, 0 is the default.
;
;        iSrc:     Starting index of the source array.  If this parameter is
;                  not provided, 0 is the default.
;
; OUTPUTS:
;        Starting from index, iTar, the Target array gets filled with "equivalent"
;        elements from the Source array starting from the Source index, iSrc up
;        until the end of the Source or Target array depending upon which one ends
;        first.
;
; PROCEDURE:
;        Assuming iTar and iSrc = 0, if the Target is an integer array and the Source
;        is a longword integer array, then the least significant 16-bits of Source are
;        put into the "even" elements of Target, while the most signficant 16 bits of
;        Source are put into the "odd" elements of Target.  If the situation is reversed,
;        then the "even" elements of Source are put into the least significant 16-bits
;        of Target, while the "odd" elements are put into the most significant 16-bits
;        of Target.
;
; EXAMPLE:
;        a = 1234567890L
;        b = intarr(2)
;
;        EQUIV,b,a
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, July 1995.
;-
pro EQUIV, Target, Source, iTar, iSrc

         NP   = N_PARAMS()
         case NP of
              4 :
              3 : iSrc = 0
              2 : BEGIN
                   iTar = 0
                   iSrc = 0
                  END
            else: message,'Must be called with 2-4 parameters: '+$
                          'Source, Target [, iSrc, iTar]'
         endcase

         szS  = SIZE(Source) & nszS = n_elements(szS)
         szT  = SIZE(Target) & nszT = n_elements(szT)

         nS   = szS(nszS-1)
         typeS= szS(nszS-2)

         nT   = szT(nszT-1)
         typeT= szT(nszT-2)

         if ((typeS ne 2) and (typeS ne 3)) or $
            ((typeT ne 2) and (typeT ne 3)) then $
            message,'Input parameters must be of type: Integer or Longword integer.'

;    Both Integers or Both Longword integers

         if (typeS eq typeT) then begin
              nTmax     = nT - iTar
              nSmax     = nS - iSrc
              neq       = nTmax < nSmax
              Target(iTar:iTar+neq-1)  = Source(iSrc:iSrc+neq-1)
              return
         endif

;   Longword integer Source & Integer Target

         if (typeS eq 3) then begin
              nTmax     = nT - iTar
              nSmax     = 2*(nS - iSrc)
              neq       = nTmax < nSmax
              neq2      = CEIL(neq/2.)
              Sorg      = Source(iSrc:iSrc+neq2-1)
              ieven     = 2*indgen(neq2)
              S         = intarr(2*neq2)
              S(ieven)  = Sorg and 'FFFF'X            ; Lower 16-bits
              S(ieven+1)= ISHFT(Sorg,-16)             ; Upper 16-bits
              Target(iTar:iTar+neq-1)  = S(0:neq-1)
              return
         endif

;   Integer Source & Longword integer Target

         if (typeT eq 3) then begin
              nTmax     = nT - iTar
              nSmax     = CEIL((nS - iSrc)/2.)
              neq       = nTmax < nSmax
              neq2      = 2*neq
              Sorg      = intarr(neq2)
              norg      = neq2<(ns-iSrc)
              Sorg(0:norg-1) = Source(iSrc:iSrc+norg-1)
              ieven     = 2*indgen(neq)
              Seven     = long(Sorg(ieven))
              here      = where(Seven lt 0,nlt)
              if (nlt gt 0) then Seven(here) = 2L^16 + Seven(here)
              Target(iTar:iTar+neq-1)  = Seven + $         ; Lower 16-bits -> LONG integer
                        ISHFT(long(Sorg(ieven+1)),16)      ; Upper 16-bits
              return
         endif

end
