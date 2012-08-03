;-------------------------------------------------------------
;+
; NAME:
;       PCKEY
; PURPOSE:
;       Read PC keyboard. Interpret special keys.
; CATEGORY:
; CALLING SEQUENCE:
;       pckey, out
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         ASCII=a returns the ascii code of the key.
;         FLAG=f  returns a flag indicating a leading
;           255: 0=no, 1=yes.
; OUTPUTS:
;       out = output string.   out
;         Will be a letter or:
;         F1, ... F12, UP, DOWN, LEFT, RIGHT.
;         ALT-UP, CTR-UP, ...
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 5 Oct, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
        pro pckey, out, ascii=code, flag=flag, help=hlp
 
        if keyword_set(hlp) then begin
          print,' Read PC keyboard. Interpret special keys.'
          print,' pckey, out'
          print,'   out = output string.   out'
          print,'     Will be a letter or:'
          print,'     F1, ... F12, UP, DOWN, LEFT, RIGHT.'
          print,'     ALT-UP, CTR-UP, ...'
          print,' Keywords:'
          print,'   ASCII=a returns the ascii code of the key.'
          print,'   FLAG=f  returns a flag indicating a leading'
          print,'     255: 0=no, 1=yes.'
          return
        end
 
        out = get_kbrd(1)		; Wait for a key.
        code = (byte(out))(0)		; Get its ascii code.
        flag = code eq 255		; Was it 255?
        if flag then begin		; If it was 255 then
          out = get_kbrd(1)		;   get another key.
          code = (byte(out))(0)		; Get its ascii code.
          case code of			; Interpret sequence.
72:         out = 'UP'
75:         out = 'LEFT'
77:         out = 'RIGHT'
80:         out = 'DOWN'
141:        out = 'CTR-UP'
115:        out = 'CTR-LEFT'
116:        out = 'CTR-RIGHT'
145:        out = 'CTR-DOWN'
152:        out = 'ALT-UP'
155:        out = 'ALT-LEFT'
157:        out = 'ALT-RIGHT'
160:        out = 'ALT-DOWN'
82:         out = 'INSERT'
71:         out = 'HOME'
73:         out = 'PAGE-UP'
83:         out = 'DELETE'
79:         out = 'END'
81:         out = 'PAGE-DOWN'
else:       begin
	      ;------  Function keys  -----------
              if (code ge 59) and (code le 68) then begin
                out = 'F'+strtrim(code-58,2)
              endif
              if (code ge 133) and (code le 134) then begin
                out = 'F'+strtrim(code-122,2)
              endif
            end
          endcase
        endif
 
        return
        end
