;+
; NAME:
;        INQUIRE
;
; PURPOSE:
;        This function asks the USER to respond to a question (usually Y/N)
;        and then return the USER's response as a boolean.
;
; CATEGORY:
;        STRLIB.
;
; CALLING SEQUENCE:
;
;        Result = INQUIRE( Question [, ansY, ansN ] )
;
; INPUTS:
;        Question: String containing the question to be asked to the USER.
;
; OPTIONAL INPUTS:
;
;        ansY, ansN:    The ASCII character of the USER's response which
;                  will return this function as TRUE, FALSE, respectively.
;
; EXAMPLE:
;        if INQUIRE( 'Are you happy? (y/n) ' ) then $
;             print,'Good for you!' $
;        else $
;             print,'That''s too bad.'
;
;        if INQUIRE( 'Which do you prefer, (E)at or (S)leep? ', 'E', 'S' ) $
;        then begin
;             print,'You need to lose some weight!'
;        endif else begin
;             print,'Wake up too early this morning?'
;        endelse
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, October, 1994.
;        01-JUN-1995    Eliminated call to PROMPT routine.
;-
function INQUIRE, question, ansY1, ansN1
         NP = N_PARAMS()
         prompt_save = !prompt

         ansY = 'Y'
         ansN = 'N'
         if NP ge 2 then ansY = ansY1
         if NP eq 3 then ansN = ansN1
         rp=''
QUERY:   read,rp,format='(A1)',prompt=question
         rp=strupcase(rp)
         CASE rp OF
              ansY : r = 1
              ansN : r = 0
              else : begin
                        print,'Invalid response.'
                        goto, QUERY
                     end
         ENDCASE
         !prompt=prompt_save

         return,r
end
