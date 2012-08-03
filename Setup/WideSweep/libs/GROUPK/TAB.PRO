;+
; NAME:
;        TAB
;
; PURPOSE:
;        Returns the ASCII tab character.
;
; CATEGORY:
;        Put a category (or categories) here.  For example:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        Result = TAB()
;
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June, 1994.
;-
function tab
   return, string(9b)
end
