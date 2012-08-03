;+
; NAME:
;        XQUERY
;
; PURPOSE:
;        Reply to a list of questions via a widget window.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        Result = XQUERY( Question )
;
; INPUTS:
;        Question: A string or array of strings describing the question(s)
;                  to be asked to the USER.
;
; OPTIONAL INPUTS:
;
;        Default:  An array of numbers or strings containing the default
;                  answers for each of the corresponding questions.  If this
;                  parameter is not provided each answer is defaulted to a
;                  NULL string.
;
; OPTIONAL INPUT KEYWORDS:
;
;        TITLE:    Title of this XQUERY widget, ('XQUERY'=Default)
;
;        GROUP:    The widget ID of an existing widget that serves as
;                  "group leader" for this message widget.
;
;        OK:       Set this keyword to set the button text to 'OK' for
;                  the button which destroys this widget. ('Done'=Default)
;
;        XSIZE:    An array of numbers giving the width of each "answer"
;                  widget in characters, fltarr( N_ELEMENTS( Question ) )
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
; OUTPUTS:
;        This function returns an array or scalar containing the answers to each
;        corresponding questions.  If the Default input parameter is provided
;        then its TYPE is preserved in the returned array/scalar.  Otherwise,
;        the returned array/scalar will be of STRING type.
;
; RESTRICTIONS:
;
;        Complex numbers or arrays are treated as strings.
;
; COMMON BLOCKS:
;        XQUERY_COM:  This is for internal use only.
;
; EXAMPLE:
;
;        ; Try this one
;
;        result = XQUERY(['Is this Cool? ','Or What? '], $
;                        DEFAULT=['Yes..','Indeed.'])
;
;        ; If you only press DONE then result will have the following values:
;        ; result(0) = 'Yes..'
;        ; result(1) = 'Indeed.'
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;        09-JAN-1995    Small bugfix: returned null strarr when pressing
;                       Cancel -> return DEFAULT strarr if keyword is defined.
;        29-JAN-1995    Added the RIGHT,LEFT,TOP,BOTTOM,CENTER keywords.
;        19-JUL-1995    If Question is a scalar, return a scalar instead of a
;                       1-element array.
;        24-JUL-1995    Changed the functionality of the Cancel button to be
;                       consistent with other widget routines; namely, returning
;                       a -1.  Added a new Undo button to replace the former
;                       functionality of Cancel, except that the widget is now
;                       reset to its defaults instead of being destroyed.  Also
;                       moved the DEFAULTS keyword to the second input parameter
;                       to be consistent with XBUTTON. (However, DEFAULTS keyword
;                       will still be available to maintain backward compatibility.)
;        17-AUG-1995    Preserve type defined by the Default input parameter.
;        18-AUG-1995    Bugfix: Removed wset, windex; unnecessary.
;-

PRO MAIN_XQ_Event, Event

         common XQUERY_COM, input, reply, ID

         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

;   If USER hits ENTER in an text editable widget, set the cursor
;   to the next entry if it's NOT the last text widget.

         pos  = strpos( Ev, 'TEXT_' )
         if pos ne -1 then begin
              text_ID = fix(strmid( Ev, 5,2 ))
              if (text_ID lt (input.nq-1)) then begin
                   WIDGET_CONTROL, ID(text_ID), SET_TEXT_SELECT=[0,0]
                   WIDGET_CONTROL, ID(text_ID+1), /INPUT_FOCUS, $
                                   GET_VALUE=TextVal
                   WIDGET_CONTROL, ID(text_ID+1), SET_TEXT_SELECT= $
                                  [0,strlen( TextVal )]
                   RETURN
              endif
         endif

;   If it IS the last text widget then process the
;   text and destroy the XQUERY widget

         TEXT_LAST = 'TEXT_'+strtrim(input.nq-1,2)

         update = 1
         destroy= 1
         CASE Ev OF

         TEXT_LAST:
         'BUTTON_DONE':
         'BUTTON_UNDO': BEGIN
              reply     = input.default
              for i=0,input.nq-1 do $
                   WIDGET_CONTROL, ID(i),SET_VALUE=reply(i)
              update    = 0
              destroy   = 0
              END
         'BUTTON_CANCEL': BEGIN
              reply     = -1
              update    = 0
              END
         ENDCASE

         if (update) then begin
              reply=strarr( input.nq )
              for i=0,input.nq-1 do begin
                   WIDGET_CONTROL, ID(i),GET_VALUE=result
                   reply(i) = result
                   endfor
              endif
         if (destroy) then dummy = EXECUTE( 'WIDGET_CONTROL, Event.Top, /DESTROY' )
END


pro XQUERY_widget, LEFT=Left, RIGHT=Right, TOP=Top, $
                   BOTTOM=Bottom, CENTER=Center, GROUP=Group

         common XQUERY_COM, input, reply, ID

         MAIN_XQ = WIDGET_BASE(GROUP_LEADER=Group, $
             COLUMN=1, $
             MAP=0, $
             TITLE=input.Title, $
             UVALUE='MAIN_XQ')

;   Create the widget layout

         LABELSPC  = WIDGET_LABEL( MAIN_XQ, VALUE=' ')


         Text_ID   = intarr( input.nq )
         TextVal   = strarr( input.nq )
         for i=0,input.nq-1 do begin

              ROWn = WIDGET_BASE(MAIN_XQ, $
                                   ROW=1, $
                                   MAP=1 )

              Query = WIDGET_LABEL( ROWn, VALUE= input.Question(i) )


              TextVal(i) = ''
              if input.Ndef gt 0 then $
              TextVal(i) = strtrim(input.Default(i),2)

              Text_ID(i) = WIDGET_TEXT( ROWn,VALUE=TextVal(i), $
                                        EDITABLE=1, $
                                        /FRAME, $
                                        XSIZE=input.xsize(i), $
                                        UVALUE='TEXT_'+strtrim(i,2) )
         endfor
         ID = Text_ID

         LABELSPC  = WIDGET_LABEL( MAIN_XQ, VALUE=' ')

;   Determine the number of pixels needed to center the Done button

         txt_list  = [input.Question+input.Default, input.Title+strpad(' ',5)]
         char_len  = MAX( strlen(txt_list), imax )
         widget_len= 8*char_len   ; approx. 8 pixels wide/character


         BASE_BUTTON = WIDGET_BASE(MAIN_XQ, $
                         XPAD=widget_len/2, $
                         /ROW, $
                         /MAP )
         BUTTON_DONE = WIDGET_BUTTON( BASE_BUTTON, $
                                      UVALUE='BUTTON_DONE', $
                                      VALUE=input.button)

         BUTTON_UNDO = WIDGET_BUTTON( BASE_BUTTON, $
                                      UVALUE='BUTTON_UNDO', $
                                      VALUE='Undo')

         BUTTON_CANCEL = WIDGET_BUTTON( BASE_BUTTON, $
                                      UVALUE='BUTTON_CANCEL', $
                                      VALUE='Cancel')

;   Take care of an annoying AIX widget bug: /INPUT_FOCUS will
;   generate an error if the widget has not been drawn to the display yet!
;
         if !VERSION.OS eq 'AIX' then Focus = 0 $
         else Focus = 1

         WIDGET_POSITION, MAIN_XQ, LEFT=Left, RIGHT=Right, TOP=Top,$
                          BOTTOM=Bottom, CENTER=Center
         WIDGET_CONTROL, ID(0), INPUT_FOCUS=Focus, $ ;Highlight and put cursor
            SET_TEXT_SELECT=[0,strlen( TextVal(0) )] ;at 1st text window

;   Removed, 8/18/95.
;
;        WSET, input.windex  ;prevent /MODAL from pushing XQUERY window
;                            ;behind the main IDL window

         XMANAGER, 'MAIN_XQ', MAIN_XQ, /MODAL, $
                   GROUP_LEADER=Group

         IF (Group ne 0) then WIDGET_CONTROL, Group, /SHOW
END


function XQUERY, Question1, Defaults, DEFAULT=Default1, GROUP=Group, TITLE=Title, $
                 OK=Ok, XSIZE=Xsize1, LEFT=Left, RIGHT=Right, $
                 TOP=Top, BOTTOM=Bottom, CENTER=Center

         common XQUERY_COM, input, reply, ID

;   Check dimensions

         NP = N_PARAMS()
         IF NP eq 0 then $
              message,'Must be called with 1-2 parameters: '+$
                        'Questions [,Defaults]'
         nq = N_ELEMENTS( Question1 )
         Question       = strarr(nq)
         Question(*)    = Question1

         if (NP eq 2) then Default1=Defaults
         Ndef = N_ELEMENTS(Default1)
         IF ((ndef gt 0) and (ndef ne nq)) then message,'Incompatible arrays.'

;   Define default keywords

         IF keyword_set( OK ) then button_text='OK' else button_text='Done'
         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0
         IF N_ELEMENTS(Title) EQ 0 THEN TITLE='XQuery'
         IF Ndef eq 0 then Default=replicate('',nq) $
         else begin
              Default   = strarr(Ndef)      ;take care of scalars
              Default(*)= string(Default1)
         endelse
         IF N_ELEMENTS(Xsize1) EQ 0 THEN Xsize=REPLICATE(22,nq) $
         else begin
              Xsize     = fltarr(nq)
              Xsize(*)  = Xsize1
         endelse

         IF N_ELEMENTS(Center)EQ 0 THEN CENTER=1
         IF (keyword_set( LEFT ) or $
             keyword_set( RIGHT) or $
             keyword_set( BOTTOM)or $
             keyword_set( TOP )) then CENTER=0

         reply = replicate('',nq)

         input = { $
                   Question : Question, $
                   Title : Title, $
                   Default : Default, $
                   Nq    : Nq, $
                   Ndef  : Ndef, $
                   windex: !D.WINDOW, $
                   button: button_text, $
                   xsize : xsize $
                 }

         XQUERY_WIDGET, LEFT=Left, RIGHT=Right, TOP=Top, $
                        BOTTOM=Bottom, CENTER=Center, GROUP=Group

         if (nq eq 1) then reply = reply(0)

;   Determine output type

         sz   = SIZE(Default1)
         type = sz(n_elements(sz)-2)
         case type of
              0    : ; Unknown -> default to string
              1    : reply = BYTE(reply)
              2    : reply = FIX(reply)
              3    : reply = LONG(reply)
              4    : reply = FLOAT(reply)
              5    : reply = DOUBLE(reply)
              6    : ; Complex floating -> cannot handle
              7    : ; String
              else :
         endcase
         return, reply
end

