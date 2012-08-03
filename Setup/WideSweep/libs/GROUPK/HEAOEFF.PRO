;+
; NAME:
;        HEAOEFF
;
; PURPOSE:
;        This function returns the HEAO A-1 detector efficiences for the
;        specified energies.
;
; CATEGORY:
;        HEAO A-1.
;
; CALLING SEQUENCE:
;
;        Result = HEAOEFF( HVmode, keV )
;
; INPUTS:
;
;        HVmode:   String specifying one of two high-voltage modes,
;                  'AGCL' for High Gain mode, or 'AGCP' for the Low Gain mode.
;
;        keV:      A scalar or array of energies in KEV.
;
; OUTPUTS:
;        The HEAO A-1 detector efficiencies at each of the energies specified
;        by the USER.
;
; COMMON BLOCKS:
;        HEAOEFF:  Holds the detector efficiency data. (For internal use only).
;
; PROCEDURE:
;        The detector efficiency data is a digitization of a scan of the HEAO
;        A-1 catalog fig. 7.  In order to optimize for speed, no interpolation
;        is performed.  Instead, we rely on a set of detector efficiency data
;        finely binned in logarithmic energy.
;
; EXAMPLE:
;
;        energy         = 100.*(findgen(1000)/1000.)
;        efficiencies   = HEAOEFF( 'AGCL', energy )
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May 1995.
;        06-AUG-1996    Simplified directory structure.
;-
function HEAOEFF, HVmode1, keV

         common HEAOEFF, AGCL_, AGCP_

         NP   = N_PARAMS()
         if (NP ne 2) then message,'Must be called with 2 parameters: HVmode, keV'

         HVmode    = STRUPCASE(HVmode1)

;   Read in HEAO detector efficiency tables from file

         if (n_elements(AGCL_) eq 0) then begin

              ;    k=0 -> AGCL Mode (High Gain)
              ;     =1 -> AGCP Mode (Low Gain)

              for k=0,1 do begin
                   if (k eq 0) then filen='agcl.dat' $
                   else filen= 'agcp.dat'
                   filen     = GRPKPATH()+filen

                   ;    Open data file (Digitization of the HEAO Catalog
                   ;    fig. 7)

                   openr,in,filen,/GET_LUN
                   en=0.0
                   de=0.0
                   i =0L
                   energy = -1.0
                   eff    = -1.0

                   ;    Loop over all the data

                   repeat begin
                       readf,in,en,de
                       energy = [energy,en]
                       eff    = [eff,de]
                   endrep until EOF(in)

                   close,in
                   free_lun,in

                   npts      = N_ELEMENTS(eff)
                   energy    = energy(1:npts-1)
                   eff       = eff(1:npts-1)
                   npts      = npts - 1

                   ;    Store data in AGCL_ and AGCP_ structures

                   if (k eq 0) then begin
                   AGCL_ = { $
                             npts:npts,  $
                             keV:energy, $
                             eff:eff,    $
                             ch16:  [  0.15, 0.23, 0.31, 0.46, $     ;These are the
                                       0.61, 0.92, 1.22, 1.84, $     ;16 Channel sorter
                                       2.45, 3.67, 4.90, 7.35, $     ;lower level
                                       9.80,14.69,19.52]}            ;break points [keV]
                   endif else $
                   AGCP_ = { $
                             npts:npts,  $
                             keV:energy, $
                             eff:eff,    $
                             ch16:  [  0.79, 1.18, 1.57, 2.36, $
                                       3.14, 4.71, 6.29, 9.43, $
                                      12.57,18.86,25.14,37.72, $
                                      50.29,75.43,100.18]}
              endfor

         endif

;   Put detector efficiencies into common "work" arrays

         if (HVmode eq 'AGCL') then begin
              n    = AGCL_.npts
              en   = AGCL_.keV
              eff  = AGCL_.eff
         endif else begin
              n    = AGCP_.npts
              en   = AGCP_.keV
              eff  = AGCP_.eff
         endelse

;   Find the nearest energy data point and assign the
;   corresponding detector efficiencies

         nu   = N_ELEMENTS(keV)
         effu = FLTARR(nu)

         here = WHERE( (keV gt MIN(en)) and (keV lt MAX(en)), nok )
         if (nok gt 0) then begin

            ; Since the where function is more efficient than for loops
            ; choose the path that minimizes the number of loops

            if (nok lt n) then begin
              for i=0,nok-1 do begin
                   j = HERE(i)
                   h = WHERE( en lt keV(j), nlt )
                   effu(j) = eff(h(nlt-1)+1)
              endfor
            endif else begin
              for i=0,n-2 do begin
                   h = WHERE( en(i) lt keV(here), nlt)
                   if (nlt gt 0) then effu(here(h))  = eff(i+1)
              endfor
            endelse
         endif

         if (nu eq 0) then effu   = effu(0)

         return, effu
end
