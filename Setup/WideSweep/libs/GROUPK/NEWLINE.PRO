;+
; NAME:
;        NEWLINE
;
; PURPOSE:
;        Print a blank line or line of a particular ASCII character
;        to screen or other output device.
;
; CATEGORY:
;        STRLIB.
;
; CALLING SEQUENCE:
;
;        NEWLINE, [Luns]
;
;
; OPTIONAL INPUTS:
;        Luns:     Array of logical units corresponding to the device(s) this
;                  procedure outputs to, (Default=-1=Screen).
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        CHAR:     Charactor for which a line will be drawn, (Default=space).
;                  If the output device is not the screen (i.e. a file) then
;                  a semicolon, ; is at the beginning of the line.
;
; OUTPUTS:
;        Prints a line to the screen (default) or the devices specified by
;        the Luns parameter.  If the CHAR keyword is not specified, then
;        a blank line is outputted, otherwise a line of CHAR characters is
;        outputted.
;
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, November 1994.
;-
pro NEWLINE, luns, CHAR=Char


         if N_ELEMENTS( luns ) eq 0 then luns = -1

         nunit     = N_ELEMENTS( luns )
         for i=0,nunit-1 do begin
              if luns(i) eq -1 then $
                   str  = '' $
              else $
                   str  = ';'

              if keyword_set( CHAR ) then $
                   for j=0,69 do str=str+Char

              printf,luns(i),str
         endfor
end
