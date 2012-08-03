;+
; NAME:
;        WSHOW_ACTIVE
;
; PURPOSE:
;
;        This function exposes or hides the current window if its window
;        index matches the input argument.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        Result = WSHOW_ACTIVE, Window_index [, Show]
;
; INPUTS:
;        Window_index:  The window index of the window you would
;                  like to expose or hide.
;
; OPTIONAL INPUTS:
;        Show:     Set Show to 0 to hide the window. Omit this
;                  argument or set it to 1 to expose the window.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;        ICONIC:   Set this keyword to iconify the window. Set
;                  ICONIC to 0 to de-iconify the window.
;
; OUTPUTS:
;        This function returns a 1 if the window index of the current
;        window matches the Window_index parameter and a 0 if it does
;        not.
;
; PROCEDURE:
;        This routine was created to offset an annoying side-effect of
;        creating or destroying IDL widgets.  Namely, any existing windows
;        are usually hidden behind the IDL Main window.  You can use WSHOW
;        to expose these windows, but what if they no longer exist? Namely,
;        what if the USER has already closed the window?  Applying WSHOW
;        to a non-existing window will generate an error.  This routine
;        checks the current windows existence by comparing the !D.WINDOW
;        system variable with the Window_index parameter and then does a
;        WSHOW if the two window indices agree.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, January 1995.
;-
function WSHOW_ACTIVE, Window_index, Show

         NP = N_PARAMS()
         if NP eq 1 then Show=1

         if !D.WINDOW eq Window_index then begin
              WSHOW, Window_index, Show
              return, 1
         endif else return, 0
end
