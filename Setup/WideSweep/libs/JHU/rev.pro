;-------------------------------------------------------------
;+
; NAME:
;       REV
; PURPOSE:
;       Reverse plot and background colors.
; CATEGORY:
; CALLING SEQUENCE:
;       rev
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /PROMPT sets prompt to LDI> if color<background.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: switches background and color.
; MODIFICATION HISTORY:
;       R. Sterner, 7 Oct, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
        pro rev, prompt=prompt, help=hlp
 
        if keyword_set(hlp) then begin
          print,' Reverse plot and background colors.'
          print,' rev'
          print,'  No args.'
          print,' Keywords:'
          print,'   /PROMPT sets prompt to LDI> if color<background.'
          print,' Notes: switches background and color.'
          return
        endif   
 
        ;------  switch plot colors  -------
        back = !p.background
        !p.background = !p.color
        !p.color = back
 
        ;-------  Handle prompt  -------
        if keyword_set(prompt) then begin
          if !p.color lt !p.background then begin
            !prompt = 'LDI>'
          endif else begin
            if !prompt eq 'LDI>' then !prompt='IDL>'
          endelse
        endif          
 
        return
        end
