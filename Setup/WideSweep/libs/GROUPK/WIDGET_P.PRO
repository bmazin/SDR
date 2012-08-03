;+
; NAME:
;        WIDGET_POSITION
;
; PURPOSE:
;        Realizes a widget hierachy and displays the top-level base
;        widget at the center or corner of the display.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        WIDGET_POSITION, Widget_ID
;
; INPUTS:
;        Widget_ID:     The widget ID of the widget to be manipulated.
;
; OPTIONAL INPUT KEYWORDS:
;
;        RIGHT:    Display widget in the right corner of the display.
;
;        LEFT:     Display widget in the left corner of the display (DEFAULT).
;
;        BOTTOM:   Display widget in the bottom corner of the display.
;
;        TOP:      Display widget in the top corner of the display (DEFAULT).
;
;        CENTER:   Display widget in the center of the display.
;
;        RANDOM:   Display widget randomly in the display.
;
;        MAP:      Set this keyword to 1 to display positioned widget (DEFAULT),
;                  set to 0 to HIDE the positioned widget.
;
; OUTPUTS:
;        Displays the widget centered in or at the corner of
;        the display device.
;
; COMMON BLOCKS:
;        WIDGET_POSITION:    For internal use only.  Holds seed for randomizer.
;
; PROCEDURE:
;        Replaces WIDGET_CONTROL, Widget_ID, /REALIZE
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;        3-MAY-1995     Added the RANDOM keyword
;-
pro WIDGET_POSITION, Widget_ID, LEFT=Left, RIGHT=Right, TOP=Top,$
                     BOTTOM=Bottom, CENTER=Center, MAP=Map, RANDOM=Random

         common WIDGET_POSITION, WP_seed

         if N_ELEMENTS( MAP ) eq 0 then Map=1

         DEVICE,GET_SCREEN_SIZE=win_sz

         WIDGET_CONTROL, Widget_ID, /REALIZE
         WIDGET_CONTROL, Widget_ID, TLB_GET_SIZE=Widget_SZ, $
                                    TLB_GET_OFFSET=xy_offset

         if !VERSION.OS eq 'AIX' then begin
              xoffset   = 4 ; Upper left corner = DEFAULT
              yoffset   = 24
         endif else begin
              xoffset   = xy_offset(0)
              yoffset   = xy_offset(1)
         endelse
         if keyword_set( RIGHT ) then xoffset = win_sz(0)-Widget_SZ(0)
         if keyword_set( BOTTOM) then yoffset = win_sz(1)-Widget_SZ(1)
         if keyword_set( CENTER) then BEGIN
              xoffset = (win_sz(0)-Widget_SZ(0))/2
              yoffset = (win_sz(1)-Widget_SZ(1))/2
         endif
         if keyword_set( RANDOM ) then begin
              nx      = win_sz(0)/float(Widget_SZ(0))
              ny      = win_sz(1)/float(Widget_SZ(1))

              xoffset = fix(randomu(WP_seed)*nx)*Widget_SZ(0)
              yoffset = fix(randomu(WP_seed)*ny)*Widget_SZ(1)
         endif

         WIDGET_CONTROL, Widget_ID, TLB_SET_XOFFSET=xoffset, $
                                    TLB_SET_YOFFSET=yoffset
         WIDGET_CONTROL, Widget_ID, MAP=Map, /SHOW

end
