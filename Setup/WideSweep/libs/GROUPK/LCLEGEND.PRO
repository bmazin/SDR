;+
; NAME:
;        LCLEGEND
;
; PURPOSE:
;        Returns the Standard Light Curve legend.
;
; CATEGORY:
;        String manipulation.
;
; CALLING SEQUENCE:
;
;        Result = LCLEGEND( Srcnames, Cts [, Sigma ] )
;
; INPUTS:
;      Srcnames:   An array of source names, [string( nsrc )].
;
;           Cts:   The fitted intensities for each source, Counts/bin, [float( nsrc )].
;
; OPTIONAL INPUTS:
;         Sigma:   The uncertainties of these fitted intensity values, [float( nsrc )].
;
; OUTPUTS:
;        An array of strings summarizing the fitted intensities for each source.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May, 1994.
;        18-NOV-1994    Made the sigma input optional
;-
function LCLEGEND, Srcnames, Cts, Sigma

         NP   = N_PARAMS()
         ctstr = string(format='(F7.1)',Cts)
         if NP eq 3 then begin
              sigstr= strcompress( string(format='(F6.1)',Sigma) )
              legend= Srcnames+': '+ ctstr + ' '+string(177B) + sigstr
         endif else $
              legend= Srcnames+': '+ ctstr

         return, legend
end

