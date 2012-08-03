;+
; NAME:
;        STRPAD
;
; PURPOSE:
;        This function returns the source string padded with leading
;        and/or trailing white-space characters.
;
; CATEGORY:
;        STRLIB.
;
; CALLING SEQUENCE:
;
;        Result = STRPAD( Source, Length [, Pos] )
;
; INPUTS:
;        Source:   A string or number you want padded with white-space
;                  characters.
;
;        Length:   The total length of the returned padded string.
;
; OPTIONAL INPUTS:
;
;        Pos:      Position of the Source string within the returned
;                  padded string. [0=Default]
;
; OUTPUTS:
;        The source parameter is returned as a string with leading
;        and/or trailing white-space characters.
;
; RESTRICTIONS:
;        The Length and Pos parameters must be in the range [0-255].
;
; EXAMPLE:
;        Let's say you want 'bob' to have a length of 10 characters
;        with spaces padded after 'bob':
;
;        bob10 = STRPAD( 'bob', 10 )
;
;        Or if you want 'bob' to be at the end:
;
;        bobend= STRPAD( 'bob', 10, 7 )
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;-
function STRPAD, Source, Length, Pos

         NP = N_PARAMS()
         if (NP lt 2) or (NP gt 3) $
         then message,'Must be called with 2-3 parameters: '+$
                                   'Source, Length [, Pos]'

         if Length gt 255 $
         then message,'Length must be 0-255.'

         sz   = size(Source)
         if sz(0) ne 0 then message,'Source parameter must be a scalar.'

         if (sz(1) eq 7) then $
              ssrc = string( Source ) $
         else $
              ssrc = strtrim( Source,2 )    ;remove leading/trailing blanks
                                            ;from the number
         slen = strlen( ssrc )
         sdiff= Length - slen

         blank= ' '
         case NP of
              2    : BEGIN
                   if sdiff gt 0 then begin
                        fmt='(A'+strtrim(sdiff,2)+')'
                        return, ssrc + string(blank,format=fmt)
                   endif else begin
                        fmt='(A'+strtrim(Length,2)+')'
                        return, string(ssrc,format=fmt)
                   endelse
                   END
              3    : BEGIN
                   ldiff = Pos
                   rdiff = Length - (ldiff + slen )
                   strtmp= ssrc
                   if ldiff gt 0 then begin
                        fmt    = '(A'+strtrim(ldiff,2)+')'
                        strtmp = string(blank,format=fmt)+strtmp
                   endif
                   if rdiff gt 0 then begin
                        fmt    = '(A'+strtrim(rdiff,2)+')'
                        strtmp = strtmp+string(blank,format=fmt)
                   endif
                   fmt  = '(A'+strtrim(Length,2)+')'
                   return, string(strtmp, format=fmt)
                   END
         endcase
end
