;+
; NAME:
;        XHELPMSG
;
; PURPOSE:
;        This routine displays help messages in a widget format
;        similar to the IDL Help facility.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;
;        XHELPMSG, Topics, Descriptions, Nlines
;
; INPUTS:
;        Topics:   An array of strings describing the topics of the help
;                  message, strarr( ntopics ).
;
;        Descriptions:  An array of strings describing each of the topics.
;
;        Nlines:   The number of "lines" or string array elements of
;                  description for each topic, fltarr( ntopics ).
;
; OPTIONAL INPUT KEYWORDS:
;
;        TITLE:    Title of this XHELPMSG widget, ('XHelp Message'=Default)
;
;        YSIZE:    The height of the help widget in number of lines,
;                  (20=Default).
;
;        GROUP:    The widget ID of an existing widget that serves as
;                  "group leader" for this message widget.
;
; OUTPUTS:
;        Displays a help widget similar to the one provided by the IDL help
;        facility appears; i.e. two columns: help topics and a description of
;        currently highlighted topic.
;
; COMMON BLOCKS:
;        XHELPMSG_COM:  This is for internal use only.
;
; EXAMPLE:
;        ;Here's a simple example:
;
;        Topics=['Joe','Widgeting']
;        Descriptions=['Makes a sloppy burger',$
;                      'Always inviting others to his restaurant.',$
;                      'Can be a real pain in the butt..',$
;                      'unless you have cool canned X routines..',$
;                      'such as this one!']
;
;        Nlines=[2,3]
;        XHELPMSG, Topics, Descriptions, Nlines
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, December 1994.
;-

PRO MAIN_HELP_Event, Event

         common XHELPMSG_COM, xhdata

         WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

         CASE Ev OF


         'TOPIC_COL': BEGIN                 ;User has selected a Topic.
              ID = xhdata.ID.topic
              index = WIDGET_INFO( ID, /LIST_SELECT )   ;Get index of topic.
              WIDGET_CONTROL, ID, SET_LIST_SELECT=index ;Highlight topic.
              nl        = xhdata.nlines
              descr     = xhdata.descr
              ioff      = 0
              if index gt 0 then ioff = TOTAL( nl(0:index-1) )
              Descr_list= descr(ioff:ioff+nl(index)-1)  ;Description list.

              WIDGET_CONTROL, xhdata.ID.descr, $        ;Display description
                             SET_VALUE=Descr_list       ;of the selected topic.
              END
         'DESCR_COL':
         'MAIN_HELP': WIDGET_CONTROL, xhdata.ID.main,  /REALIZE
         'BUTTON_ID': dummy=EXECUTE('WIDGET_CONTROL,Event.Top,/DESTROY')
         ENDCASE
END


PRO XHELPMSG, Topics, Descriptions1, Nlines, GROUP=Group, $
              TITLE=Title, YSIZE=Ysize, CENTER=center

         common XHELPMSG_COM, xhdata

         NP = N_PARAMS()
         IF NP ne 3 then message,'Must be called with 3 parameters: '+$
                                 'Topics, Descriptions, Nlines'

         Descriptions   = Descriptions1
         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0
         IF N_ELEMENTS(Title) EQ 0 THEN TITLE='XHelp Message'
         IF N_ELEMENTS(Ysize) EQ 0 THEN YSIZE=20

         IF ((N_ELEMENTS(Descriptions) NE TOTAL(Nlines)) OR $
             (N_ELEMENTS(Topics) NE N_ELEMENTS(Nlines)))    $
         THEN message,'Incompatible arrays.'

         max_len        = MAX( strlen( Descriptions ) )
         for i=0,TOTAL(Nlines)-1 do $
              Descriptions(i) = strpad( Descriptions(i), max_len )

         MAIN_HELP = WIDGET_BASE(GROUP_LEADER=Group, $
             /COLUMN, $
             /TLB_SIZE_EVENTS, $
             MAP=0, $
             TITLE=Title, $
             UVALUE='MAIN_HELP')

         BUTTON_ROW = WIDGET_BASE(MAIN_HELP, $
             /COLUMN, $
             /MAP, $
             UVALUE='BUTTON_ROW')

         BUTTON_ID = WIDGET_BUTTON( BUTTON_ROW, $
             UVALUE='BUTTON_ID', $
             VALUE='Quit')


         BODY_HELP = WIDGET_BASE(MAIN_HELP, $    ;This widget holds the
             /ROW, $                             ;body of the help display
             /MAP, $
             UVALUE='BODY_HELP')

         Ntopic    = N_ELEMENTS(Topics)
         ysize_help= Ysize < (Ntopic > MAX( Nlines ) )
         TOPIC_COL = WIDGET_LIST(BODY_HELP, $    ;Topic column lists all
             VALUE=Topics,$                      ;available topics
             /FRAME,$
             YSIZE=ysize_help, $
             UVALUE='TOPIC_COL')

         DESCR_COL = WIDGET_LIST(BODY_HELP, $
             VALUE = Descriptions(0:Nlines(0)-1), $  ;Description column
             /FRAME,$                                ;describes the currently
             YSIZE=ysize_help,$                      ;selected topic
             UVALUE='DESCR_COL')

         xhdata = { $
                   ID     : {main:main_help, $
                             topic:topic_col,$
                             descr:descr_col}, $
                   nlines : nlines, $
                   descr  : descriptions $
                  }

         if keyword_set(CENTER) then widget_position, main_help, /center $
         else widget_position, main_help, /right, /top

         WIDGET_POSITION, MAIN_HELP, /RIGHT, /TOP
         WIDGET_CONTROL, TOPIC_COL, /SET_LIST_TOP, SET_LIST_SELECT=0

         XMANAGER, 'MAIN_HELP', MAIN_HELP

END
