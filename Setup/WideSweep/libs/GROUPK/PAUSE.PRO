;+
; NAME:
;        PAUSE
;
; PURPOSE:
;        Pauses until the USER presses the ENTER or 'Q' key.
;
; CATEGORY:
;        STRLIB.
;
; CALLING SEQUENCE:
;
;        PAUSE
;
; OUTPUTS:
;        Changes the prompt to 'Press ENTER to continue...' and waits
;        for the USER to press the ENTER key.  Once the USER completes
;        this request, the prompt is restored to its default appearance.
;
;        If however, the USER presses the 'Q' key, then this routine
;        aborts with a USER-BREAK error message.
;
; PROCEDURE:
;        This is good for debugging.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, October 1994.
;        01-JUN-1995    Eliminated call to PROMPT routine.
;        31-OCT-1995    Added ON_ERROR,2.
;-
pro PAUSE
    ON_ERROR, 2

    prompt_save = !prompt
    rp = ''
    read,rp,prompt='Press ENTER to continue...'
    rp = strupcase(rp)
    !prompt=prompt_save
    if rp eq 'Q' then begin
         close,/all
         message,'USER-BREAK'
    endif
end
