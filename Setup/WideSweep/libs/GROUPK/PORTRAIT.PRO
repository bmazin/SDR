;+
; NAME:
;        PORTRAIT
;
; PURPOSE:
;        Graphics Device Manager for Portrait mode.
;        (see DEVICE_MGR routine)
;
; CATEGORY:
;        Graphics.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, November 1994.
;-
pro PORTRAIT, dev, _EXTRA=Other_keywords

         DEVICE_MGR, dev, ORIENTATION='PORTRAIT', _EXTRA=Other_keywords

end
