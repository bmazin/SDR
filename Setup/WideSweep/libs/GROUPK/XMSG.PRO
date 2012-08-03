;+
; NAME:
;        XMSG
;
; PURPOSE:
;        Displays message(s) in a widget window with an optional OK button.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        XMSG, Msgs
;
; INPUTS:
;        Msgs:     An array of message(s) of ANY type to be displayed.
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
;        RANDOM:   Display widget randomly in the display.
;
;        NOBUTTON: Set this keyword to NOT display an OK button.  If this
;                  keyword is set, then control is returned to the USER
;                  after this message widget is displayed, (0=Default).
;
;        GROUP:    The widget ID of an existing widget that serves as
;                  "group leader" for this message widget.
;
;        MSG_ID:   The widget ID of this XMSG widget.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;        09-JAN-1995    Added the NOBUTTON and MSG_ID keywords.
;        02-AUG-1995    Added scrollbar if number of messages exceeds 15.
;        16-AUG-1995    Input array parameter can be of ANY type instead of
;                       only strings.
;        27-SEP-1995    Improved algorithm to determine width of widget in pixels.
;-
PRO MAIN_MSG_Event, Event


         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF
         'LISTN':
         'BUTTON_OK': dummy = EXECUTE('WIDGET_CONTROL, Event.Top, /DESTROY')
         ENDCASE
END


PRO XMSG, Msg1, TITLE=Title, ALIGN=Align, LEFT=Left, RIGHT=Right, $
         BOTTOM=Bottom, TOP=Top, CENTER=Center, RANDOM=Random, GROUP=Group, $
         NOBUTTON=Nobutton, MSG_ID=MSG_ID

         nrow_max = 15

         NP = N_PARAMS()
         if NP eq 0 then Msg1 = ''
         margin='     '
         Msg = margin+string(Msg1)+margin

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0
         IF N_ELEMENTS(Title) EQ 0 THEN TITLE='IDL'
         IF N_ELEMENTS(Center)EQ 0 THEN CENTER=1
         IF (keyword_set( LEFT ) or $
             keyword_set( RIGHT) or $
             keyword_set( BOTTOM)or $
             keyword_set( TOP )) then CENTER=0

;   Create the message widget base

         MAIN_MSG = WIDGET_BASE(GROUP_LEADER=Group, $
             COLUMN=1, $
             MAP=0, $
             TITLE=title, $
             UVALUE='MAIN_MSG')
         MSG_ID   = MAIN_MSG

;   Create one label for each message string if number of strings < nrow_max

         nmsg      = N_ELEMENTS( Msg )
         LABEL0    = WIDGET_LABEL( MAIN_MSG, UVALUE='LABEL0', VALUE=' ')

         if keyword_set( ALIGN ) or (nmsg gt nrow_max) then begin
              nrow = nmsg < nrow_max
              Listn= WIDGET_LIST( MAIN_MSG, $
                        YSIZE= nrow, $
                        VALUE=msg, $
                        UVALUE='LISTN' )
         endif else begin
              for i=0,nmsg-1 do begin
                  LABELn= WIDGET_LABEL( MAIN_MSG, $
                             UVALUE='LABEL'+strtrim(string(15+i),2), $
                             VALUE=msg(i))
              endfor
         endelse

         LABEL1    = WIDGET_LABEL( MAIN_MSG, UVALUE='LABEL1', VALUE=' ')

;   Determine the number of pixels needed to center the OK button

         msg_list  = [string(msg1),title+strpad(' ',5)]
         msg_byte  = byte(msg_list)
         msg_wgt   = 6*( (msg_byte ne 32) and (msg_byte ne 0) )
         msg_wgt   = msg_wgt + 4*( msg_byte eq 32 )
         msg_wgt   = REFORM(TOTAL(msg_wgt,1))
         widget_len= MAX(msg_wgt) + 2*strlen(margin)

;   Create the OK button widget base

         if NOT keyword_set( NOBUTTON ) then begin
            BASE_OK = WIDGET_BASE(MAIN_MSG, $
                ROW=1, $
                MAP=1, $
                XPAD=widget_len/2, $
                UVALUE='BASE_OK')

            BUTTON_OK = WIDGET_BUTTON( BASE_OK, $
                UVALUE='BUTTON_OK', $
                VALUE='OK')
         endif

         WIDGET_POSITION, MAIN_MSG, LEFT=Left, RIGHT=Right, TOP=Top, $
                        BOTTOM=Bottom, CENTER=Center, RANDOM=Random

         if NOT keyword_set( NOBUTTON ) then $
         XMANAGER, 'MAIN_MSG', MAIN_MSG, GROUP_LEADER=Group
END
