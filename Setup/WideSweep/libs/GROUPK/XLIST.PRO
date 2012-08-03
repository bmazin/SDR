;+
; NAME:
;        XLIST
;
; PURPOSE:
;        This function returns the value or index of an item from
;        a list that the USER interactively selects from.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        Result = XLIST( List )
;
; INPUTS:
;        List:     An array of items of ANY type to choose from.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        VALUE:    Set this keyword to return the value of the item selected,
;                  (1=Default).
;
;        INDEX:    Set this keyword to return the index of the item selected,
;                  (0=Default).
;
;        HEADER:   An array of strings containing the header that will be
;                  placed above the list of items, (''=Default).
;
;        TITLE:    A string containing the title of the widget window,
;                  ('Select Item'=Default)
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
;        GROUP:    The widget ID of an existing widget that serves as
;                  "group leader" for this message widget.
;
; OUTPUT:
;
;        By default or if the VALUE keyword is set, this function returns the
;        value of the item selected, preserving its type.  If the INDEX keyword
;        is set, then the array index of this item is returned.
;
; COMMON BLOCKS:
;
;        XLIST:    For internal use only.
;
; EXAMPLE:
;
;        list = ['Why is','IBM','so incompetent','in','marketing','OS/2','?']
;        str  = XLIST(list)
;        ; select 'OS/2'
;        print, str
;        ; the value should be 'OS/2'
;
;        index= XLIST(list)
;        ; select 'OS/2' again
;        print,index
;        ; the index should be 5
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, August 1995.
;        27-SEP-1995    Improved algorithm to determine width of widget in pixels.
;-
PRO MAIN_LIST29_Event, Event

         COMMON XLIST, xl_index

         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF
         'LISTN': xl_index = Event.index
         'BUTTON_CANCEL': xl_index = -1
         ENDCASE

         dummy = EXECUTE('WIDGET_CONTROL, Event.Top, /DESTROY')
END


function XLIST, List1, TITLE=Title, LEFT=Left, RIGHT=Right, $
         BOTTOM=Bottom, TOP=Top, CENTER=Center, RANDOM=Random, GROUP=Group, $
         INDEX=Index, VALUE=Value, HEADER=Header

         COMMON XLIST, xl_index

         nrow_max = 15

         NP = N_PARAMS()
         if NP eq 0 then List1 = ''
         margin='     '
         List = margin+string(List1)+margin

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0
         IF N_ELEMENTS(Title) EQ 0 THEN TITLE='Select Item'
         IF N_ELEMENTS(Center)EQ 0 THEN CENTER=1
         IF (keyword_set( LEFT ) or $
             keyword_set( RIGHT) or $
             keyword_set( BOTTOM)or $
             keyword_set( TOP )) then CENTER=0

;   Create the list widget base

         MAIN_LIST29 = WIDGET_BASE(GROUP_LEADER=Group, $
             COLUMN=1, $
             MAP=0, $
             TITLE=title, $
             UVALUE='MAIN_LIST29')
         LIST_ID   = MAIN_LIST29

         nlist      = N_ELEMENTS( List )
         LABEL0    = WIDGET_LABEL( MAIN_LIST29, UVALUE='LABEL0', VALUE=' ')

         if keyword_set(Header) then begin
              nH   = N_ELEMENTS(Header)
              for i=0,nH-1 do $
                   LABELh    = WIDGET_LABEL( MAIN_LIST29, VALUE=Header(i))
         endif

         nrow = nlist < nrow_max
         Listn= WIDGET_LIST( MAIN_LIST29, $
                   YSIZE= nrow, $
                   VALUE=list, $
                   UVALUE='LISTN' )

         LABEL1    = WIDGET_LABEL( MAIN_LIST29, UVALUE='LABEL1', VALUE=' ')

;   Determine the number of pixels needed to center the Cancel button

         msg_list  = [string(list1),title+strpad(' ',5)]
         msg_byte  = byte(msg_list)
         msg_wgt   = 8*( (msg_byte ne 32) and (msg_byte ne 0) )
         msg_wgt   = msg_wgt + 4*( msg_byte eq 32 )
         msg_wgt   = REFORM(TOTAL(msg_wgt,1))
         widget_len= MAX(msg_wgt) + 2*strlen(margin)

;   Create the Cancel button widget base

         BASE_CANCEL = WIDGET_BASE(MAIN_LIST29, $
             ROW=1, $
             MAP=1, $
             XPAD=widget_len/2, $
             UVALUE='BASE_CANCEL')

         BUTTON_CANCEL = WIDGET_BUTTON( BASE_CANCEL, $
             UVALUE='BUTTON_CANCEL', $
             VALUE='Cancel')

         WIDGET_POSITION, MAIN_LIST29, LEFT=Left, RIGHT=Right, TOP=Top, $
                        BOTTOM=Bottom, CENTER=Center, RANDOM=Random

         XMANAGER, 'MAIN_LIST29', MAIN_LIST29, /MODAL, GROUP_LEADER=Group
         IF keyword_set(Group) then WIDGET_CONTROL, Group, /SHOW

         if (xl_index eq -1) then return, xl_index

         if keyword_set(INDEX) then return, xl_index $
         else return, list1(xl_index)
END
