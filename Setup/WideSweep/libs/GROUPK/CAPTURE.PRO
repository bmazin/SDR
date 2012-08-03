;+
; NAME:
;        CAPTURE
;
; PURPOSE:
;        Captures the current graphics screen and saves it to an image file.
;
; CATEGORY:
;        I/O.
;
; CALLING SEQUENCE:
;
;        CAPTURE
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        BMP:      Set this keyword to send a BMP image to the printer, (1=Default).
;
;        GIF:      Set this keyword to send a GIF image to the printer, (0=Default).
;
;        JPEG:     Set this keyword to send a JPEG image to the printer, (0=Default).
;
;        FILENAME: Filename of the image file (picnnn.bmp,gif,jpg=Default).
;
; PROCEDURE:
;        The current graphics screen is saved to an image file.
;
; EXAMPLE:
;        plot,indgen(100),xtitle='This is the x-axis',ytitle='Y-Axis'
;        xyouts, 0.3, 0.94, 'Title.. So What.. Big Deal', CHARSIZE=1.4, /NORMAL
;        CAPTURE
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, July 1995.
;-
pro CAPTURE, BMP=BMP, GIF=GIF, JPEG=JPEG, FILENAME=filen

         ext   = 'bmp'
         if keyword_set(GIF)  then ext='gif'
         if keyword_set(JPEG) then ext='jpg'
         if (N_ELEMENTS(filen) eq 0) then filen = tmpfile('pic',ext)

;   Save screen image to file

         image     = (!D.n_colors-1) - TVRD()
         case ext of
              'bmp' : WRITE_BMP, filen, image
              'gif' : WRITE_GIF, filen, image
              'jpg' : WRITE_GIF, filen, image
         endcase
         message,'Captured graphics screen to image file: '+filen,/INF
end
