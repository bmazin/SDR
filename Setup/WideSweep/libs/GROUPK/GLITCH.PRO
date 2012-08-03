;+
; NAME:
;        GLITCH
;
; PURPOSE:
;        Looks for "glitches" in the data by calculating the changes
;        in count rate across a major frame. When it finds a major
;        frame with a "glitch", its bin number is added to a list.
;
; CATEGORY:
;        Data Analysis.
;
; CALLING SEQUENCE:
;
;        BIN_LIST = GLITCH( Cts, [, Nglitch, CUT=Cut, /ZERO_ONLY, /NOWARN] )
;
; INPUTS:
;          Cts:    Array containing the data, [float( nbin )].
;
; OPTIONAL INPUTS:
;
;      Nglitch:    Number of bins with glitches, [integer].
;
; OPTIONAL KEYWORD INPUTS:
;
;          CUT:    The cutoff fractional derivative used to determine if the
;             counts in a bin is a glitch, [float].
;
;    ZERO_ONLY:    Only look for zero bins in the Cts array.
;
;       NOWARN:    Suppress printing of warning messages.
;
;          LOG:    Write warning messages to log file.
;
; OUTPUTS:
;        This function returns a list of bins where glitches have been found.
;
; EXAMPLE:
;        Let's say you have an array of counts and want to find which
;        bins have glitches:
;
;        Cts = randomu( seed, 128 ) + 100
;        Cts(20) = 5000
;        Cts(90) = 0
;
;        list = GLITCH( Cts )
;        print, list
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May, 1994.
;        20-JUL-1994    Bugfix: moved the min. 3 data pts cutoff to after
;                       the check for 0 bins.
;        10-JAN-1995    Bugfix: (nNOzero eq 0) -> (nNOzero le 1) because
;                       we need at least 2 points to determine the
;                       count derivative
;-
function GLITCH, Cts, Nglitch, CUT=cut, ZERO_ONLY=zero_only, NOWARN=nowarn, LOG=log

         ON_ERROR,2

         NP = N_PARAMS()
         if (NP lt 1) or (NP gt 2) then $
            message, 'Must be called with 1-2 parameters: Cts [, Nglitch]'

         nover = 0 & nzero = 0

         if not keyword_set( CUT ) then cut = 2.0
         if cut lt 0 then message,'Keyword CUT must be > 0

         nbin = N_ELEMENTS( Cts )

;  First check for 0 bins; these are definitely glitches

         i_zero   = WHERE( cts  eq 0, nzero )
         i_NOzero = WHERE( cts  gt 0, nNOzero )
         if (keyword_set( ZERO_ONLY )) or (nNOzero le 1) then goto, COLLECT

;  Abort if there are too few data points to search for derivative glitches

         if nbin le 3 then begin
              printdev,'Not enough data points to determine glitches.',$
                        NODISPLAY=nowarn, LOG=log
              goto, QUIT
         endif

;  Calculate the derivatives at each bin and find the bin(s) with glitches

         Cts0     = Cts( i_NOzero )
         cts_prev = shift( cts0, 1 )
         diff     = cts0 - cts_prev
         fder     = diff/cts_prev
         fder(0)  = -diff(1)/cts0(1)   ; reverse defn for first point

         i_over   = WHERE( abs( fder ) gt cut, nover )

;  Create the list of bad bins and return them

COLLECT: nglitch = nzero + nover
         if nglitch gt 0 then begin
            badbins = intarr( nglitch )
            if nzero gt 0 then $
               badbins(0    :nzero-1)       = i_zero
            if nover gt 0 then $
               badbins(nzero:nzero+nover-1) = i_NOzero( i_over )
            if (nzero gt 0) and (nover gt 0) then $
               badbins                      = badbins( SORT( badbins ) )
         endif else badbins = -1

         return, badbins

QUIT:    nglitch = 0
         return, -1
end
