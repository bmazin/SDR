;+
; NAME:
;        LANDSCAPE
;
; PURPOSE:
;        Graphics Device Manager for Landscape mode.
;        (see DEVICE_MGR routine)
;
; CATEGORY:
;        Graphics.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, November 1994.
;-
pro LANDSCAPE, dev, _EXTRA=Other_keywords

         DEVICE_MGR, dev, ORIENTATION='LANDSCAPE', _EXTRA=Other_keywords

end
