;+
; NAME:
;        XBUTTON
;
; PURPOSE:
;        Query the USER via a column or row of widget button(s).
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        Result = XBUTTON( Button [, Value] )
;
; INPUTS:
;        Button:   An array of strings containing the text of each button.
;
; OPTIONAL INPUTS:
;        Value:    The result returned for each button; this can be an array
;                  of integers, floats, strings, etc. If this parameter
;                  is not specified then an integer index is returned when
;                  the USER clicks a button starting from 0 for the leftmost
;                  or topmost button, incrementing by one for each button to
;                  the right or lower.
;
; KEYWORD PARAMETERS:
;
;        TITLE:    A string containing the title of the widget window,
;                  (''=Default)
;
;        ROW:      Set this keyword to form a "row" of buttons (Default).
;
;        COLUMN:   Set this keyword to form a "column" of buttons.
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
;        GROUP:    The widget ID of an existing widget that serves as
;                  "group leader" for this message widget.
;
; OUTPUTS:
;        This function returns a value specified by the Value input array
;        or an integer index.
;
; COMMON BLOCKS:
;        XB_COM:   For intenal use only.
;
; EXAMPLE:
;
;        ;Try this one:
;        buttons = ['Hey','This','Is','Really','Cool!']
;        values  = ['H','T','I','R','C' ]
;
;        ;The following should generate a COLUMN of 5 buttons
;        rp   = xbutton( buttons, /COLUMN )
;
;        ;If you click on the 'Cool' button, then the value of rp = 4
;
;        ;The following should generate a ROW of 5 buttons
;        rp   = xbuttons( buttons, values, /ROW )
;
;        ;If you click on the 'Cool' button again, the value of rp='C'
;        ;as defined by the values array.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;        22-JAN-1995    Added /INPUT_FOCUS keyword so that the button
;                       widget window is highlighted.
;        28-JAN-1995    Added the GROUP keyword.
;-
pro MAIN_XB_Event, Event

         common XB_COM, xb122

         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         xb122 = fix( Ev )

         dummy = EXECUTE( 'WIDGET_CONTROL, Event.Top, /DESTROY' )
end


function XBUTTON, Button, Value, ROW=Row, COLUMN=Column, TITLE=Title, $
             LEFT=Left, RIGHT=Right, TOP=Top, BOTTOM=Bottom, CENTER=Center, $
             GROUP=Group

         common XB_COM, xb122

         junk   = { CW_PDMENU_S, flags:0, name:'' }

         nbutton   = N_ELEMENTS( Button )
         if N_ELEMENTS( Title ) eq 0 then Title = ''
         if N_ELEMENTS( Row   ) eq 0 then Row   = 1
         if N_ELEMENTS( Column) eq 0 then Column= 0
         if N_ELEMENTS( Value ) eq 0 then Value = indgen(nbutton)
         if N_ELEMENTS( Group ) eq 0 then Group = 0
         if keyword_set( COLUMN ) then Row = 0

         MAIN_XB = WIDGET_BASE(GROUP_LEADER=Group,  $
             ROW=Row, $
             COLUMN=Column, $
             MAP=0, $
             TITLE=Title, $
             UVALUE='MAIN_XB')

         for i=0,nbutton-1 do begin
              BUTTONn = WIDGET_BUTTON( MAIN_XB, $
                   UVALUE=strtrim(i,2), $
                   VALUE=string(button(i)))
         endfor

         WIDGET_POSITION, MAIN_XB, LEFT=Left, RIGHT=Right, TOP=Top, $
                          BOTTOM=Bottom, CENTER=Center
         WIDGET_CONTROL, MAIN_XB, /INPUT_FOCUS

         XMANAGER, 'MAIN_XB', MAIN_XB, /MODAL

         return, value( xb122 )
end
