;+
; NAME:
;        OKCANCEL
;
; PURPOSE:
;        This function prompts USER with a widget window with OK and
;        Cancel buttons. Use this function to let the USER allow some
;        subsequent action that you are going to take (described by the
;        Msgs parameter) once this widget is destroyed.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        Result = OKCANCEL( [Msgs] )
;
; INPUTS:
;        Msgs:     A string or array of strings containing message(s)
;             to be displayed.
;
; OPTIONAL KEYWORD INPUTS:
;
;        TITLE:    A string containing the title of the widget window,
;                  ('IDL'=Default)
;
;        ALIGN:    Set this keyword to left align each message string,
;                  by default, each message string is centered (0=Default).
;
;        RIGHT:    Display widget in the right corner of the display.
;
;        LEFT:     Display widget in the left corner of the display.
;
;        BOTTOM:   Display widget in the bottom corner of the display.
;
;        TOP:      Display widget in the top corner of the display.
;
;        CENTER:   Display widget in the center of the display (DEFAULT).
;
;        GROUP:    The widget ID of an existing widget that serves as
;                  "group leader" for this message widget.
;
; OUTPUTS:
;        This function will return a 1 if the OK button is selected and a 0
;        if the Cancel button is selected.
;
; COMMON BLOCK:
;        OKCANCEL: For internal use only.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, January 1994.
;        02-AUG-1995    Added scrollbar if number of messages exceeds 15.
;        27-SEP-1995    Improved algorithm to determine width of widget in pixels.
;-
PRO MAIN_OKC_Event, Event


         common OKCANCEL, OKCANCEL_val

         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF
         'LISTN': return
         'OK': OKCANCEL_val = 1
         'CANCEL' : OKCANCEL_val = -1
         ENDCASE
         dummy = EXECUTE('WIDGET_CONTROL, Event.Top, /DESTROY')
END


function OKCANCEL, Msg1, TITLE=Title, ALIGN=Align, LEFT=Left, $
              RIGHT=Right, BOTTOM=Bottom, TOP=Top, CENTER=Center, GROUP=Group

         common OKCANCEL, OKCANCEL_val

         nrow_max = 15

         NP = N_PARAMS()
         if NP eq 0 then Msg1 = ''
         margin='     '
         Msg = margin+Msg1+margin

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0
         IF N_ELEMENTS(Title) EQ 0 THEN TITLE='IDL'
         IF N_ELEMENTS(Center)EQ 0 THEn CENTER=1
         IF (keyword_set( LEFT ) or $
             keyword_set( RIGHT) or $
             keyword_set( BOTTOM)or $
             keyword_set( TOP )) then CENTER=0

;   Create the message widget base

         MAIN_OKC = WIDGET_BASE(GROUP_LEADER=Group, $
             COLUMN=1, $
             MAP=0, $
             TITLE=title, $
             UVALUE='MAIN_OKC')

;   Create one label for each message string

         LABEL0    = WIDGET_LABEL( MAIN_OKC, UVALUE='LABEL0', VALUE=' ')

         nmsg      = N_ELEMENTS( Msg )
         if keyword_set( ALIGN ) or (nmsg gt nrow_max) then begin
              nrow = nmsg < nrow_max
              Listn= WIDGET_LIST( MAIN_OKC, $
                        YSIZE= nrow, $
                        VALUE=msg, $
                        UVALUE='LISTN' )
         endif else begin
              for i=0,nmsg-1 do begin
                  LABELn= WIDGET_LABEL( MAIN_OKC, $
                             UVALUE='LABEL'+strtrim(string(15+i),2), $
                             VALUE=msg(i))
              endfor
         endelse
         LABEL1    = WIDGET_LABEL( MAIN_OKC, UVALUE='LABEL1', VALUE=' ')

;   Determine the number of pixels needed to center the OK button

         msg_list  = [string(msg1),title+strpad(' ',5)]
         msg_byte  = byte(msg_list)
         msg_wgt   = 6*( (msg_byte ne 32) and (msg_byte ne 0) )
         msg_wgt   = msg_wgt + 4*( msg_byte eq 32 )
         msg_wgt   = REFORM(TOTAL(msg_wgt,1))
         widget_len= MAX(msg_wgt) + 2*strlen(margin)

;   Create the OK & CANCEL buttons widget base

         BASE_BUTTONS = WIDGET_BASE(MAIN_OKC, $
             ROW=1, $
             MAP=1, $
             XPAD=widget_len/2, $
             UVALUE='BASE_BUTTONS')

         OK = WIDGET_BUTTON( BASE_BUTTONS, $
             UVALUE='OK', $
             VALUE='OK')

         CANCEL = WIDGET_BUTTON( BASE_BUTTONS, $
             UVALUE='CANCEL', $
             VALUE='Cancel')

         WIDGET_POSITION, MAIN_OKC, LEFT=Left, RIGHT=Right, TOP=Top, $
                        BOTTOM=Bottom, CENTER=Center
         WIDGET_CONTROL, MAIN_OKC, /INPUT_FOCUS

         XMANAGER, 'MAIN_OKC', MAIN_OKC, /MODAL

         IF keyword_set(Group) then WIDGET_CONTROL, Group, /SHOW

         return, OKCANCEL_val
END
