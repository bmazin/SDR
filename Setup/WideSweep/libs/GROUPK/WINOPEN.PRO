;+
; NAME:
;        WINOPEN
;
; PURPOSE:
;        This function returns the additional keywords needed to calls to
;        the OPEN procedure in IDL for Windows, version 4.0.1 and later.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        Result = WINOPEN(TEXT=Text, BINARY=Binary)
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        TEXT:     Set this keyword to specify that the file should be opened
;                  as a text file, (0=Default).
;
;        BINARY:   Set this keyword to specify that the file should be opened
;                  as a binary file, (0=Default).
;
; OUTPUTS:
;        If you are running IDL for Windows, version 4.0.1 and later,
;        this function returns an anonymous structure that may be used in
;        conjunction with the _EXTRA keyword in the OPEN procedure to properly
;        open files.  If you are running IDL with an earlier version or a
;        different platform, or if neither keywords are set, then an undefined
;        variable is returned.
;
; RESTRICTIONS:
;        This routine ONLY needs to be used with calling the OPEN procedure
;        with IDL for Windows, version 4.0.1 and later.
;
; EXAMPLE:
;        To open a binary file, do:
;
;        OPENR, lu1, 'bob', /GET_LUN, _EXTRA=WINOPEN(/BINARY)
;        OPENW, lu2, 'joe', /GET_LUN, _EXTRA=WINOPEN(/BINARY)
;
;        or to open a text file, do:
;
;        OPENR, lu1, 'bob', /GET_LUN, _EXTRA=WINOPEN(/TEXT)
;        OPENW, lu2, 'joe', /GET_LUN, _EXTRA=WINOPEN(/TEXT)
;
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, October 1995.
;-
function WINOPEN, BINARY=Binary, TEXT=Text

         OS   = strupcase(!VERSION.OS)
         OS   = strmid(OS,0,3)
         if (OS ne 'WIN') then binset = 0 $
         else begin

              vers = strtrim(!version.release,2)
              per  = strpos(vers,'.')
              vern = float(strmid(vers,0,per+2))
              case 1 of
                   (vern lt 4.0) : binset = 0
                   (vern eq 4.0) : begin
                        per2 = rstrpos(vers,'.')
                        if (per2 ne per) then binset=1 $  ; version > 4.0
                        else binset = 0
                        end
                   (vern gt 4.0) : binset = 1
              endcase
         endelse
         if (binset) then begin
              case 1 of
              keyword_set( Binary ) : return, { binary:1, noautomode:1 }
              keyword_set( Text )   : return, { binary:0, noautomode:1 }
              else                  : return, undefined
              endcase
         endif else return, undefined

end
