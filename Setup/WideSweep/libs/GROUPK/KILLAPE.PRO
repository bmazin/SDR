;+
; NAME:
;        KILLAPE
;
; PURPOSE:
;        This routine removes Adjacent Photon Events (APEs) from a MJF block
;        of HBR PTI data.  An APE is defined as two photons occurring in adjacent
;        8 usec bins ACROSS sequential HBR data words.  Namely, the first photon
;        occurs in time bin 9 and the second photon occurs in time bin 0 of the
;        next word.  These events occur in the HBR PTI data for roughly 3-4% of
;        all photons lying in time bin 0 or 9.  They are considered  UNPHYSICAL
;        due to the deadtime of the detector (>16 usec) and the consistent
;        occurrance of these events ONLY across sequential HBR data words.
;
; CATEGORY:
;        HEAO HBR.
;
; CALLING SEQUENCE:
;
;        KILLAPE, PTIblock, Fixes
;
; INPUTS:
;        PTIblock: Structure variable holding the next MJF block of PTI data.
;                  It is one of the outputs of the READPTI routine.
;
; OUTPUTS:
;        Fixes:    This structure variable holds the corrected time intervals.
;                  Its tags are defined as follows:
;
;                  nAPE:     The number of APEs found in this MJF block.
;                  hAPE:     Array of indices pointing to elements in the orginal
;                            Photon Time Interval array, PTIblock.PTI where APEs
;                            were found. (= -1 if nAPE=0).
;                  pti:      The corrected PTIs with APEs removed and neighboring
;                            PTIs corrected. (= -1 if no photons in MJF block).
;
; PROCEDURE:
;        This routine first finds any APEs by determining which PTIs = 1
;        occur across adjacent HBR data words.  The PTIs corresponding to any
;        APEs found are marked and later removed.  The neighboring PTIs before
;        and after the APEs are subsequently corrected by adding a 1 to the
;        smaller of the two PTIs.  If the two PTIs are equal, then the 1 goes to
;        the PTI before the APE.  This algorithm leads to a roughly equal
;        distribution of corrections before and after the APEs.
;
; EXAMPLE:
;
;        OPENPTI, lu, !DATA_PATH+'086_7_7.xdr'   ; Open a HBR PTI data file
;        READPTI, lu, block                      ; Read in a MJF block
;        KILLAPE, block, fixes                   ; Remove APEs
;
;        h    = hist1d( fixes.pti, MIN=0, MAX=100 )
;        plot,h,psym=10,xrange=[0,100]
;
; COMMON BLOCKS:
;        DEF_HBRH: Holds all the MJF and MNF PTI pointers, (see def_hbrh.pro).
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, September 1995.
;        09-OCT-1995    Return short integer for fixes.nAPE instead of long integer
;-
pro KILLAPE, PTIblock, Fixes

         common def_hbrh

;   Define default values for the Fixes structure

         hAPE = -1
         nAPE = 0
         pti  = -1

;   Extract the time interval from the start of a NON-zero MNF
;   to the first photon

         nMNF = N_ELEMENTS(PTIblock.mnfh)/16
         i=-1
         repeat begin
              i = i+1
              n = PTIblock.mnfh(mnfptr_.mnfndt,i)
         endrep until (n gt 0) or (i eq (nMNF-1))
         if (n eq 0) then goto, DEFAULT
         pti0 = PTIblock.mnfh(mnfptr_.delbeg,i)
         if (pti0 lt 0) then pti0 = 65536L + pti0     ; Check for overflows

;   Find all adjacent photons

         pti  = PTIblock.PTI
         here = where(pti eq 1,nadj)
         if (nadj eq 0) then goto, DEFAULT

;   Adjacent Photon Events (APEs) ONLY occur across HBR data words,
;   i.e. bins 9 and 0.

         ts   = lonarr(nadj)
         for k=0L,nadj-1L do $
              ts(k)     = pti0 + TOTAL(pti(0:here(k)))
         bins = ts MOD 10

         h0   = where( bins eq 0, nAPE)
         if (nAPE eq 0) then goto, DEFAULT

;   First mark the APEs for later removal

         here0     = here(h0)
         pti(here0) = -9999

;   Then correct the neighboring PTIs by adding 1 to the smaller/equal
;   of the two intervals.  This will result in a more/less equal distribution
;   of corrections before and after these APEs.

         left = pti(here0-1)                ; PTIs neighboring to the LEFT  of APEs
         right= pti(here0+1)                ;  "      "         "  "  RIGHT  "  "

         hR   = where(right lt left,nR)     ; See where RIGHT PTIs are < LEFT PTIs
         if (nR gt 0) then $
              pti(here0(hR)+1) = pti(here0(hR)+1) + 1

         hL   = where(right ge left,nL)     ; See where LEFT PTIs are <= RIGHT PTIs
         if (nL gt 0) then $
              pti(here0(hL)-1) = pti(here0(hL)-1) + 1

         if (nR+nL) ne nAPE then $
              message,'nR+nL <> nAPE:'+strtrim(nR+nL,2)+','+strtrim(nAPE,2)

         hAPE = here0
         nAPE = nAPE

         here = where( pti ne -9999,nne)
         pti  = pti(here)

;   Pack up the fixes and send them back to the USER

DEFAULT:
         fixes = { $
              nAPE : fix(nAPE), $
              hAPE : hAPE, $
              pti  : pti   }
end

