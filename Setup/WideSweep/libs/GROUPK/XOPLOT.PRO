;+
; NAME:
;        XOPLOT
;
; PURPOSE:
;        This procedure is a "superset" of OPLOT and OPLOTERR with the
;        additional feature of allowing the USER to interactively change
;        many of its settings "on the fly" (e.g. plotting symbol and
;        linestyle) via various widget menus.  It accepts ALL of the
;        keywords used by OPLOT and OPLOTERR and some additional keywords
;        described below.  The USER may also print the plot directly
;        under the File pulldown menu, (it can handle multiple
;        plots/window).
;
; CATEGORY:
;        Plotting and Widgets.
;
; CALLING SEQUENCE:
;
;        XOPLOT, [X,] Y, [DX, [DY]]
;
; INPUTS:
;        Y:        The ordinate data to be plotted. This argument
;                  is converted to single-precision floating-point
;                  before plotting.
;
; OPTIONAL INPUTS:
;
;        X:        A vector argument. If X is not specified, Y is
;                  plotted as a function of point number (starting at
;                  zero). If both arguments are provided, Y is plotted
;                  as a function of X.
;
;                  This argument is converted to single-precision
;                  floating-point before plotting. Plots created with
;                  PLOT are limited to the range and precision of sin-
;                  gle-precision floating-point values.
;
;        DX:       A vector of error bar values along the X-axis.
;
;        DY:       A vector of error bar values along the Y-axis.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        All of the keywords accepted by OPLOT and OPLOTERR may be used as
;        well as the following additional keywords:
;
;        LANDSCAPE:     Set this keyword to specify that the window the plot
;                  is drawn in should be in landscape mode (1=Default).
;
;        PORTRAIT: Set this keyword to specify that the window the plot is
;                  drawn in should be in portrait mode (0=Default).
;
; COMMON BLOCKS:
;        XPLOT:    Keep tracks of USER keywords, PostScript file parameters,
;                  etc.  For internal use only.
;
; RESTRICTIONS:
;        If you are interested in sending the plots to the printer, do not
;        mix usage of XPLOT, PLOT, PLOTERR and XOPLOT, OPLOT, OPLOTERR.  XPLOT
;        and XOPLOT cannot keep track of plots made using the PLOT, PLOTERR,
;        OPLOT or OPLOTERR routines.
;
; PROCEDURE:
;
;        Okay, here's a typical situation when it comes to IDL plotting:
;        you run PLOT or PLOTERR with various graphic keywords, look at the
;        resulting plot and.. oops, need to change the x-axis range..
;        change the y-axis title.. etc.  So, you rerun PLOT or PLOTERR with
;        the modified keywords and repeat this cycle of plotting until
;        you've gotten your plot right.  Once you have that done you then have to
;        REPEAT all of this song and dance for EACH additional data set you want
;        to overplot using OPLOT or OPLOTERR.  Okay, so how about printing this
;        thing?  Well, then you have to change the output device using SET_PLOT,
;        then repeat typing in all the PLOT and/or PLOTERR and/or OPLOT and/or
;        OPLOTERR commands with all the hard-fought graphic keywords.
;        Sound familiar?
;
;        XOPLOT has been designed to make this process more "interactive"
;        and less tedious.  You may use XOPLOT just as you would OPLOT or
;        OPLOTERR, specifying on the command line all of the graphic
;        keywords accepted by OPLOT or OPLOTERR.  Now, however, along with
;        the usual plot comes a nice widget menu.  From this widget menu,
;        you may modify most of the available OPLOT and OPLOTERR settings,
;        right "there".  You may additionally SAVE this plot to a
;        PostScript file and send it to the printer, right "there" from the
;        widget menu.
;
;        If you want to overplot data on an existing plot, there are four
;        simple steps to follow: 1) Run XOPLOT on you data; 2) Fiddle with the
;        settings INTERACTIVELY until you've gotten it right; 3) Select
;        Save under the File pulldown menu to save the plot to a PostScript
;        file; and 4) Select either Close or Print under the File pulldown
;        menu.  Either commands will close the PostScript file.  Print will
;        additionally spawn a print command on this PostScript file.
;
;
; EXAMPLE:
;        x    = findgen(100)
;        y    = sin(x/20)
;        y2   = cos(x/15)
;
;        XPLOT,x,y,TITLE='Title',XTITLE='X-Axis',YTITLE='Y-Axis'
;        XOPLOT,x,y2
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, January 1995.
;        01-FEB-1995    Added the NO_MENU keyword. (1.01)
;        02-FEB-1995    Save printer output system variables to XPLOT
;                       common. (1.20)
;                       Small bug fix, initialize CLOSE (1.21)
;                       Small bug fix, reseting printer output system variables
;                       back to their defaults when exiting (1.22)
;        08-FEB-1995    Added the NOCLIP keyword and HISTOGRAM plotting
;                       symbol. (1.30)
;        08-FEB-1995    Verified GRIDLINE option w/ XPLOT will work with XOPLOT
;        29-APR-1995    >Cosmetic changes; Got rid of Current in Display Current Settings,
;                       etc.  Put it in originally to force window wide enough to read
;                       the window title.
;                       >Deleting Plot Window will NOT delete PS TMP file if Print Plot
;                       Window has been previously selected.
;        03-MAY-1995    Completely rewrote the GUI by utilizing WIDED.  Added more
;                       flexibility by adding the File pulldown menu. (3.0)
;        07-MAY-1995    Make sure USER supplied two or more points to plot for
;                       X,Y overplots. (3.01)
;        09-MAY-1995    Check only first 3 characters of !VERSION.OS. (3.02)
;        16-MAY-1995    Bugfix: Made sure !P.MULTI(0) stays constant. (3.03)
;        06-JUN-1995    Check to see if input arrays are defined. (3.04)
;        12-JUN-1995    Replaced XOPLOT_ERASE -> tvrd(), tv. (3.05)
;        14-JUN-1995    Plot updated after each USER modification. (3.1)
;        20-JUN-1995    Bugfix: Don't mess with !P.MULTI(0). (3.11)
;        21-JUN-1995    Bugfix: Preserve any changes to the color indices when leaving
;                       XOplot. (3.12)
;        29-SEP-1995    Set DEVICE keyword, DECOMPOSED=0 for systems with > 256
;                       colors. (3.14)
;        07-AUG-1996    Eliminate calls to VERSION(). (3.15)
;-

pro XOPLOT_, X=X, Y=Y, DX=DX, DY=DY, NEW=New, $
              ANONYMOUS_=Dummy_, _EXTRA=User_keys
;
;   Plot the graph using the graphic keywords defined by
;   the graphics system variables (!P, !X and !Y) and/or the additional
;   USER keywords defined by User_keys
;

;   n_plot = (!P.MULTI(1) > 1)*(!P.MULTI(2) > 1)      ;Bugfix, 06/20/95, Don't alter
;   !P.MULTI(0) = (!P.MULTI(0) + 1) MOD n_plot        ; !P.multi(0).

    nUSER = N_ELEMENTS(User_keys)
    if nUSER gt 1 then tags = TAG_NAMES(User_keys)

    if keyword_set( DY )  then oploterr, X, Y, DX, DY, NOCLIP=0, _EXTRA=User_keys $
    else if keyword_set( DX )  then oploterr, X, Y, DX, NOCLIP=0, _EXTRA=User_keys $
    else if keyword_set( Y )  then oplot, X, Y, NOCLIP=0, _EXTRA=User_keys $
    else if keyword_set( X )  then oplot, X, NOCLIP=0, _EXTRA=User_keys

end


;*******************************************************************************
;   BEGIN: XOplot ONLINE HELP widgets
;*******************************************************************************

pro XOPL_HELP, GROUP=Group

         ncol      = 50
         Topics = ['Overview'                 ,$
                   'Why should I use XOplot?'  ,$
                   'How do I use XOplot?'      ,$
                   'File - Close'             ,$
                   'File - Save'              ,$
                   'File - Print'             ,$
                   'File - Delete and Exit'   ,$
                   'File - Exit'              ,$
                   'Settings']
         Descr0 = [$
             ; Overview
             'INDENT_'                                                           ,$
             'This procedure is a "superset" of OPLOT and OPLOTERR with the'     ,$
             'additional feature of allowing the USER to interactively change'   ,$
             'many of its settings "on the fly" (e.g. plotting symbol and'       ,$
             'linestyle) via various widget menus.  It accepts ALL of the'       ,$
             'keywords used by OPLOT and OPLOTERR and some additional keywords'  ,$
             'described below.  The USER may also print the plot directly'       ,$
             'under the File pulldown menu, (it can handle multiple'             ,$
             'plots/window).'                                                    ,$
             'END_TOPIC'                                                         ,$
             ; Why should I use XOplot?
             'INDENT_'                                                                ,$
             'Okay, here''s a typical situation when it comes to IDL plotting:'       ,$
             'you run PLOT or PLOTERR with various graphic keywords, look at the'     ,$
             'resulting plot and.. oops, need to change the x-axis range..'           ,$
             'change the y-axis title.. etc.  So, you rerun PLOT or PLOTERR with'     ,$
             'the modified keywords and repeat this cycle of plotting until you''ve'  ,$
             'gotten your plot right.  Once you have that done you then have to'      ,$
             'REPEAT all of this song and dance for EACH additional data set you want',$
             'to overplot using OPLOT or OPLOTERR.  Okay, so how about printing this' ,$
             'thing?  Well, then you have to change the output device using SET_PLOT,',$
             'then repeat typing in all the PLOT and/or PLOTERR and/or OPLOT and/or'  ,$
             'OPLOTERR commands with all the hard-fought graphic keywords.'           ,$
             'Sound familiar?'                                                        ,$
             strpad(' ',ncol-1)                                                       ,$
             strpad(' ',ncol-8)                                                       ,$
             'INDENT_'                                                              ,$
             'XOPLOT has been designed to make this process more interactive '      ,$
             'and less tedious.  You may use XOPLOT just as you would OPLOT or'     ,$
             'OPLOTERR, specifying on the command line all of the graphic'          ,$
             'keywords accepted by OPLOT or OPLOTERR.  Now, however, along with'    ,$
             'the usual plot comes a nice widget menu.  From this widget menu,'     ,$
             'you may modify most of the available OPLOT and OPLOTERR settings,'    ,$
             'right THERE.  You may additionally SAVE this plot to a PostScript'    ,$
             'file and send it to the printer, right THERE from the widget menu.'   ,$
             'END_TOPIC'                                                            ,$
             ; How do I use XOplot?
             'INDENT_'                                                              ,$
             'If you want to overplot data on an existing plot, there are four'     ,$
             'simple steps to follow: 1) Run XOPLOT on you data; 2) Fiddle with the',$
             'settings INTERACTIVELY until you''ve gotten it right; 3) Select'      ,$
             'Save under the File pulldown menu to save the plot to a PostScript'   ,$
             'file; and 4) Select either Close or Print under the File pulldown'    ,$
             'menu.  Either commands will close the PostScript file.  Print will'   ,$
             'additionally spawn a print command on this PostScript file.'          ,$
             'END_TOPIC'                                                            ,$
             ; File - Close
             'INDENT_'                                                           ,$
             'Closes the current PostScript file.  Once the PostScript file is'  ,$
             'closed it can no longer be modified from within XOPLOT.'            ,$
             'END_TOPIC'                                                         ,$
             ; File - Save
             'INDENT_'                                                           ,$
             'Saves the current plot to a PostScript file by updating the'       ,$
             'current PostScript file with the current overplot.'                ,$
             'END_TOPIC'                                                         ,$
             ; File - Print
             'INDENT_'                                                           ,$
             'Prints the current PostScript file.  If it is still open, then'    ,$
             'the PostScript file is closed before being printed.  Note: this'   ,$
             'option is only available for Normal PostScript files.'             ,$
             'END_TOPIC'                                                         ,$
             ; File - Delete and Exit
             'Deletes the current plot window and exits XOplot.'                 ,$
             'END_TOPIC'                                                         ,$
             ; File - Exit
             'Exits XOplot.'                                                     ,$
             'END_TOPIC'                                                         ,$
             ; Settings
             'INDENT_'                                                           ,$
             'Most of the available graphic keywords for OPLOT and OPLOTERR'     ,$
             'can be set interactively here. All the settings are fairly'        ,$
             'self-explanatory.'                                                 ,$
             'END_TOPIC'                                                          ]

         nlines = n_elements(Descr0)
         ntopics= n_elements(Topics)
         Descr1 = strarr(ntopics)

         i=0
         for j=0,ntopics-1 do begin
              repeat begin
                   if (Descr0(i) eq 'INDENT_') then begin
                        Descr1(j) = Descr1(j)+'    '+Descr0(i+1)
                        i=i+2
                   endif else begin
                        Descr1(j) = Descr1(j) + ' '+ Descr0(i)
                        i = i+1
                   endelse
              endrep until Descr0(i) eq 'END_TOPIC'
              i=i+1
         endfor

         ncol      = 50.0
         ncols     = strtrim(fix(ncol),2)
         nlines    = intarr(ntopics)
         for j=0,ntopics-1 do begin
              nrow      = CEIL(strlen(Descr1(j))/ncol)
              nrows     = strtrim(nrow,2)
              nlines(j) = nrow
              lines     = strarr(nrow)
              fmt       = '('+nrows+'A'+ncols+')'
              reads,Descr1(j),lines,FORMAT=fmt
              if j eq 0 then Descr = lines $
              else Descr = [Descr,lines]
         endfor

         for i=0,TOTAL(nlines)-2 do begin
              spc1 = strmid(Descr(i)  ,strlen(Descr(i))-1,1)
              spc2 = strmid(Descr(i+1),0                 ,1)
              if (spc1 ne ' ') and (spc2 ne ' ') then begin
                   pos  = strpos(Descr(i+1),' ')
                   Descr(i)  =Descr(i)+strmid(Descr(i+1),0,pos+1)
                   Descr(i+1)=strmid(Descr(i+1),pos+1,strlen(Descr(i+1))-pos)
              endif
         endfor

         XHELPMSG,Topics,Descr,nlines,GROUP=Group,TITLE='XOplot Online Help'

end


;*******************************************************************************
;     END: XOplot ONELINE HELP widgets
;*******************************************************************************

;*******************************************************************************
;   BEGIN: XOplot ABOUT widgets
;*******************************************************************************

PRO MAINOAbout_Event, Event

  common XPL_bok, bok_cnt, bok_it, nbok

  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

  CASE Ev OF

  'BMPBTN30': BEGIN

      if N_elements(bok_cnt) eq 0 then begin
         bok_cnt = 1
         bok_it  = 10
         nbok    = 10
      endif

      if (bok_cnt lt bok_it) then bok_cnt = bok_cnt + 1 $
      else begin
         rp   = YNCANCEL('Is that you, Steve?',TITLE='WARNING: Do NOT press Yes')
         if (rp eq 1) then begin
              nbok_win = 0
              bok_title = 'BOK BOK BOK...'
              xmsg, 'BOK Steve!', TITLE='BOK BOK BOK..', /NOBUTTON, MSG_ID=mID
              bok_ID = mID
MORE_BOK:     repeat begin
                 if (nbok_win gt 70) then begin                 ;Make sure Steve doesn't
                   nb   = n_elements(bok_ID)                    ;Bok me back by running out
                   for i=nb-1,nb-1 - (nbok-1),-1 do $           ;of resources
                        WIDGET_CONTROL, bok_ID(i), /DESTROY
                   bok_ID = bok_ID(0:(nb-1)-nbok)
                   nbok_win = nbok_win - nbok
                 endif

                 for i=0,nbok-1 do begin
                      xmsg, 'BOK Steve Forever!  ', TITLE=bok_title, $
                             /NOBUTTON, MSG_ID=mID, /RANDOM
                      bok_ID = [mID,bok_ID]
                 endfor
                 nbok_win = nbok_win + nbok
                 rp   = YNCANCEL('Had enough, Steve?',TITLE='I DARE You!')
              endrep until (rp eq 1)

              rp   = YNCANCEL('Are you Sure?',TITLE='Persistent Aren''t We?')
              if (rp ne 1) then goto, MORE_BOK

              rp   = YNCANCEL('REALLY?!',TITLE='Don''t Even Try It..')
              if (rp ne 1) then goto, MORE_BOK

              rp   = YNCANCEL('Okay, if you insist...',TITLE='Coming to you Senses.')
              if (rp ne 1) then goto, MORE_BOK

              for i=0,nbok-1 do begin
                 xmsg, 'May Steve be BOKed.. Always...', TITLE=bok_title, $
                         /NOBUTTON, MSG_ID=mID, /RANDOM
                 bok_ID = [mID,bok_ID]
              endfor
              rp   = OKCANCEL('I lied.',TITLE='Hee.. hee..')

              for i=0,n_elements(bok_ID)-1 do $
                   WIDGET_CONTROL, bok_ID(i), /DESTROY
              bok_cnt = 0
         endif
      endelse
      WIDGET_CONTROL, Event.TOP, /SHOW
      END
  'BUTTON21': WIDGET_CONTROL, Event.TOP, /DESTROY
  ENDCASE
END

PRO XOPL_About, GROUP=Group


  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAINOAbout = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      TITLE='About XOplot', $
      UVALUE='MAINOAbout')


  VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
  CASE VERSION_OS of
    'win'    : font = 'TIMES NEW ROMAN*BOLD*ITALIC*35'
    'vms'    : font = ''
    'mac'    : font = ''
    ELSE     : font = '-adobe-times-bold-i-*-*-34-*-*-*-*-*-*-*'
  ENDCASE
  LABEL11 = WIDGET_LABEL( MAINOAbout, $
      FONT=font, $
      UVALUE='LABEL11', $
      VALUE='XOplot')

  BASE28 = WIDGET_BASE(MAINOAbout, $
      ROW=1, $
      XPAD=99, $
      MAP=1, $
      TITLE='BitMap Base', $
      UVALUE='BASE28')

  BMP2075 = [ $
    [ 255b, 255b, 255b, 255b ], $
    [ 254b, 255b, 255b, 127b ], $
    [ 252b, 255b, 255b, 63b ], $
    [ 248b, 255b, 255b, 31b ], $
    [ 240b, 255b, 255b, 15b ], $
    [ 224b, 255b, 255b, 7b ], $
    [ 192b, 255b, 255b, 3b ], $
    [ 128b, 255b, 255b, 1b ], $
    [ 0b, 255b, 255b, 0b ], $
    [ 0b, 254b, 127b, 0b ], $
    [ 0b, 252b, 63b, 0b ], $
    [ 0b, 248b, 31b, 0b ], $
    [ 0b, 240b, 15b, 0b ], $
    [ 0b, 224b, 7b, 0b ], $
    [ 0b, 192b, 3b, 0b ], $
    [ 0b, 128b, 1b, 0b ], $
    [ 0b, 128b, 1b, 0b ], $
    [ 0b, 192b, 3b, 0b ], $
    [ 0b, 224b, 7b, 0b ], $
    [ 0b, 240b, 15b, 0b ], $
    [ 0b, 248b, 31b, 0b ], $
    [ 0b, 252b, 63b, 0b ], $
    [ 0b, 254b, 127b, 0b ], $
    [ 0b, 255b, 255b, 0b ], $
    [ 128b, 255b, 255b, 1b ], $
    [ 192b, 255b, 255b, 3b ], $
    [ 224b, 255b, 255b, 7b ], $
    [ 240b, 255b, 255b, 15b ], $
    [ 248b, 255b, 255b, 31b ], $
    [ 252b, 255b, 255b, 63b ], $
    [ 254b, 255b, 255b, 127b ], $
    [ 255b, 255b, 255b, 255b ]  $
  ]
  BMPBTN30 = WIDGET_BUTTON( BASE28,VALUE=BMP2075, $
      FRAME=1, $
      UVALUE='BMPBTN30')


  LABEL12 = WIDGET_LABEL( MAINOAbout, $
      UVALUE='LABEL12', $
      VALUE='Version 3.15')

  LABEL13 = WIDGET_LABEL( MAINOAbout, $
      UVALUE='LABEL13', $
      VALUE='29-September-95')

  LABEL14 = WIDGET_LABEL( MAINOAbout, $
      UVALUE='LABEL14', $
      VALUE=' ')

  LABEL15 = WIDGET_LABEL( MAINOAbout, $
      UVALUE='LABEL15', $
      VALUE='H. C. Wen')

  LABEL16 = WIDGET_LABEL( MAINOAbout, $
      UVALUE='LABEL16', $
      VALUE='hanwen@slac.stanford.edu')

  LABEL17 = WIDGET_LABEL( MAINOAbout, $
      UVALUE='LABEL17', $
      VALUE=' ')

  BASE20 = WIDGET_BASE(MAINOAbout, $
      ROW=1, $
      XPAD=100, $
      MAP=1, $
      TITLE='Button Base', $
      UVALUE='BASE20')

  BUTTON21 = WIDGET_BUTTON( BASE20, $
      UVALUE='BUTTON21', $
      VALUE='Ok')


  WIDGET_POSITION, MAINOAbout, /CENTER

  XMANAGER, 'MAINOAbout', MAINOAbout
END

;*******************************************************************************
;     END: XOplot ABOUT widgets
;*******************************************************************************

;*******************************************************************************
;   BEGIN: XOplot SETTINGS widgets
;*******************************************************************************
PRO MAINoset_Event, Event

  common XPLOT

  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev,GET_VALUE=val

  BG_ck = STRMID(Ev,0,6)
  if (BG_ck eq 'BGROUP') then begin
      if (val ne Event.Value) then return
  endif

  CASE Ev OF

  'BGROUP69': !P.LINESTYLE = val                 ;Line Style
  'BGROUP66': BEGIN                              ;Select Plotting symbol
      if (val eq 8) then !P.PSYM=10 $
      else !P.PSYM = val
      END
  'BUTTON74': BEGIN                              ; Event for Ok
      XPL_.ok = 1
      WIDGET_CONTROL, Event.Top, /DESTROY
      RETURN
      END
  'BUTTON75': BEGIN                              ; Event for Cancel
      XPL_.ok = 0
      WIDGET_CONTROL, Event.Top, /DESTROY
      RETURN
      END
  ENDCASE

  tv, RESTORE_                                      ; Restore original plot
  XOPLOT_, X=DATA_.X, Y=DATA_.Y, $                  ; Update display
       DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with NEW settings
END


pro XOPL_SET, GROUP=Group

  common XPLOT

; Save !X, !Y, !P settings in case of Cancel
  Xsave  = !X
  Ysave  = !Y
  Psave  = !P


  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAINoset = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      TITLE='XOplot Settings', $
      UVALUE='MAINoset')

  BASE53 = WIDGET_BASE(MAINoset, $
      ROW=1, $
      MAP=1, $
      UVALUE='BASE53')

;  BASE70 = WIDGET_BASE(BASE53, $
;      COLUMN=1, $
;      MAP=1, $
;      TITLE='Plot', $
;      UVALUE='BASE70')

  BASE7 = WIDGET_BASE(BASE53, $
      COLUMN=1, $
      MAP=1, $
      UVALUE='BASE7')

  Btns13300 = [ $
    'Solid', $
    'Dotted', $
    'Dashed', $
    'Dash Dot', $
    'Dash Dot Dot Dot', $
    'Long Dashes' ]
  BGROUP69 = CW_BGROUP( BASE7, Btns13300, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Line Style', $
      UVALUE='BGROUP69',$
      SET_VALUE=!P.LINESTYLE)

  Btns13315 = [ $
    'None', $
    '+', $
    '*', $
    '.', $
    'Diamond', $
    'Triangle', $
    'Square', $
    'X', $
    'Histogram' ]
  BGROUP66 = CW_BGROUP( BASE53, Btns13315, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Plotting Symbol', $
      UVALUE='BGROUP66',$
      SET_VALUE=!P.PSYM<(n_elements(Btns13315)-1))

  BASE73 = WIDGET_BASE(MAINoset, $
      ROW=1, $
      XPAD=75, $
      MAP=1, $
      UVALUE='BASE73')

  BUTTON74 = WIDGET_BUTTON( BASE73, $
      UVALUE='BUTTON74', $
      VALUE='Ok')

  BUTTON75 = WIDGET_BUTTON( BASE73, $
      UVALUE='BUTTON75', $
      VALUE='Cancel')


  WIDGET_CONTROL, MAINoset, /REALIZE

  XMANAGER, 'MAINoset', MAINoset, /MODAL

; Restore !X, !Y, !P on Cancel
  if (XPL_.ok eq 0) then begin
    !X   = Xsave
    !Y   = Ysave
    !P   = Psave

    tv, RESTORE_                                      ; Restore original plot
    XOPLOT_, X=DATA_.X, Y=DATA_.Y, $                  ; Update display
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with ENTRY settings
  endif
END
;*******************************************************************************
;     END: XOplot SETTINGS widgets
;*******************************************************************************


;*******************************************************************************
;   BEGIN: XOplot MAIN MENU widgets
;*******************************************************************************
PRO PDMENUxop_Event, Event

    common XPLOT

    Xsave     = !X
    Ysave     = !Y
    Psave     = !P
    Printer   = 'PS'
    ext = ['ps','eps']
    prefix    = 'idl'
    suffix    = ext(XPL_.PS.type)

    n_plot    = (!P.MULTI(1) > 1)*(!P.MULTI(2) > 1)
    if (USER_.nkeys gt 0) then User_keys = USER_.Keys

  CASE Event.Value OF

  'File.Close': BEGIN
    CASE XPL_.PS.closed OF
         0: BEGIN
              XPL_.PS.closed      = 1
              XPL_.PS.exist       = 1
              DEVICE_MGR, Printer, CLOSE=XPL_.PS.CLOSED, /SILENT
              print,'Closed PostScript file:'+XPL_.PS.filename
            END
         1: xmsg,['Current PostScript file:',$
                     XPL_.PS.filename,$
                     'is already closed.'],TITLE='XOplot Info'
         2: xmsg,['No PostScript file currently exists.'],TITLE='XOplot Info'
    ENDCASE
    END

  'File.Save': BEGIN         ; Update PRINTER file
    if (XPL_.PS.closed eq 1) then begin
         xmsg,'No PostScript file currently opened.',TITLE='XOplot ERROR'
         return
    endif else begin
         XPL_.PS.closed      = 0
         XPL_.PS.exist       = 1
    endelse

    d_display = !D.NAME      ; Save system variables associated with display

    Psave = !P
    Xsave = !X
    Ysave = !Y

    DEVICE_MGR, Printer, APPEND=XPL_.PS.exist, ENCAPSULATED=XPL_.PS.type, $
              PREVIEW=XPL_.PS.Preview, ORIENTATION=XPL_.PS.Orientation, $
              FILENAME=XPL_.PS.filename, /SILENT

    if XPL_.PS.exist then begin
       !P = XPL_.P         ;Restore system variables associated
       !X = XPL_.X         ;with the printer output from the
       !Y = XPL_.Y         ;previous plot
    endif

    ; Update system variables associated with PRINTER file

    for i=0,XPL_.here_sys.nX-1 do begin
         j         = XPL_.here_sys.X(i)
         !X.(j)    = Xsave.(j)              ;for the display
    endfor

    for i=0,XPL_.here_sys.nY-1 do begin
         j         = XPL_.here_sys.Y(i)
         !Y.(j)    = Ysave.(j)
    endfor

    for i=0,XPL_.here_sys.nP-1 do begin
         j         = XPL_.here_sys.P(i)
         !P.(j)    = Psave.(j)
    endfor

    !P.multi       = Psave.multi
    !P.color       = 0
    !P.background  = 255

    XOPLOT_, X=DATA_.X, Y=DATA_.Y, DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys

    XPL_.P    = !P      ;Save the system variables associated
    XPL_.X    = !X      ;with the printer output for the
    XPL_.Y    = !Y      ;next plot

    SET_PLOT, d_display

    !P = Psave     ;Restore !X and !Y system variables
    !X = Xsave     ;associated with the display
    !Y = Ysave

    XPL_.PS.exist  = 1

    print,'Saved to PostScript file:'+XPL_.PS.filename
    END

  'File.Print':BEGIN
    if (XPL_.PS.type eq 1) then begin
         xmsg, 'Cannot print Encapsulated PostScript files.',TITLE='XOplot ERROR'
         return
    endif

    CASE XPL_.PS.closed OF
         0: BEGIN
              XPL_.PS.closed      = 1
              XPL_.PS.exist       = 1
              DEVICE_MGR, Printer, /CLOSE, /SILENT, /HARDCOPY
              print,'Closed PostScript file:'+XPL_.PS.filename
            END
         1: PRINT_FILE, XPL_.PS.filename
         2: xmsg,['No PostScript file currently exists.'],TITLE='XOplot Info'
    ENDCASE
    WIDGET_CONTROL,Event.TOP,/SHOW
    iss = WSHOW_ACTIVE(!D.Window)
    END

  'File.Delete and Exit': BEGIN
    XPL_.ok = 0
    WIDGET_CONTROL, Event.Top, /DESTROY
    END
  'File.Exit': BEGIN
    XPL_.ok = 1
    WIDGET_CONTROL, Event.Top, /DESTROY
    END
  'Settings': BEGIN
    XOPL_SET, GROUP=Event.TOP
    WIDGET_CONTROL, Event.ID, /SHOW
    END
  'Undo': BEGIN
    !X   = XPL_.Undo.X
    !Y   = XPL_.Undo.Y
    !P   = XPL_.Undo.P

    tv, RESTORE_                                      ; Restore original plot
    XOPLOT_, X=DATA_.X, Y=DATA_.Y, $                  ; Update display with
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    ORIGINAL settings

    END
  'Help.Online Help': BEGIN
    XOPL_HELP, GROUP=Event.TOP
    END
  'Help.About': BEGIN
    XOPL_ABOUT, GROUP=Event.TOP
    END
  ENDCASE

END


PRO MAINxop_Event, Event


  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

  CASE Ev OF

  ; Event for XOplot PDMenu
  'PDMENUxop': PDMENUxop_Event, Event
  ENDCASE
END



pro XOPLOT, X, Y, DX, DY, LANDSCAPE=Landscape, PORTRAIT=Portrait,$
         ANONYMOUS_=Dummy_, _EXTRA=USER_keys1, GROUP=Group

         common XPLOT

         NP = N_PARAMS()
         if (NP eq 0) or (NP gt 4) then begin
              XPL_HELP
              return
         endif

         Nundef    = (N_ELEMENTS(X) eq 0) + (N_ELEMENTS(Y) eq 0) $
                   + (N_ELEMENTS(DX)eq 0) + (N_ELEMENTS(DY)eq 0)
         if NP ne (4-Nundef) then message,'One or more arrays UNDEFINED.'

         if (NP le 2) and (N_ELEMENTS(X) eq 1) then $
              message,'Not enough points to overplot.'

         if (!D.N_COLORS gt 256) then DEVICE, DECOMPOSED=0

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0
         NPar   = N_PARAMS()

         junk   = { CW_PDMENU_S, flags:0, name:'' }

         Xsave  = !X
         Ysave  = !Y
         Psave  = !P

;   Check to see if XPL_ is defined

         if N_ELEMENTS( XPL_ ) eq 0 then message,'XPlot must be called first.'

;   Check our keywords for USER definitions otherwise use defaults

         d_display = !D.NAME
         if (d_display ne 'WIN') AND (d_display ne 'X') then $
              message,'Sorry, device must be set to display: WIN or X'


         key_land = keyword_set( Landscape )
         key_port = keyword_set( Portrait )
         key_comp = key_land + key_port
         CASE 1 OF
            key_comp eq 0 : Orientation = 'LANDSCAPE'
            key_comp eq 2 : BEGIN
                                message,'Conflicting orientations .. '+$
                                        'Defaulting to LANDSCAPE',/INF
                                Orientation = 'LANDSCAPE'
                            END
            (key_land)    : Orientation = 'LANDSCAPE'
            (key_port)    : Orientation = 'PORTRAIT'
         ENDCASE
         XPL_.PS.Orientation = Orientation

         if N_ELEMENTS( USER_keys1 ) gt 0 then Utags = TAG_NAMES( USER_keys1 )
         ntags     = N_ELEMENTS( Utags )

;   Inspect any EXTRA USER keywords specified on command line call to XOPLOT

         USER_ = { nkeys:0 }
         for i=0,ntags-1 do begin

              ;    Make sure USER has not defined a color index out of range

              if (Utags(i) eq 'COLOR') then $
                   User_keys1.(i) = User_keys1.(i) < (!D.N_COLORS-1)

              here = WHERE( Utags(i) eq XPL_.Tags(*).name, n )

              ;    If any EXTRA USER keywords are not among those that may
              ;    be modified interactively, then pass these keywords directly
              ;    to PLOT or PLOTERR

              if (n eq 0) then begin
                   if n_elements(USER_keys) eq 0 then $
                        USER_keys = CREATE_STRUCT( Utags(i), USER_keys1.(i) ) $
                   else USER_keys = CREATE_STRUCT( USER_keys, $
                                                      Utags(i), USER_keys1.(i))
              endif else begin

              ;    However, if an EXTRA USER keyword may be modified interactively,
              ;    then modify the appropriate system variables and remove from
              ;    _EXTRA keyword list.

                   k         = XPL_.Tags(here(0)).SysIndex
                   USERdef   = USER_keys1.(i)
                   CASE XPL_.Tags(here(0)).SysVar OF
                        '!X': !X.(k) = USERdef
                        '!Y': !Y.(k) = USERdef
                        '!P': !P.(k) = USERdef
                   ENDCASE
              endelse
         endfor
         USER_.nkeys    = N_ELEMENTS(USER_keys)
         if (USER_.nkeys gt 0) then USER_ = CREATE_STRUCT( USER_, 'KEYS', USER_keys )

;   Create a new window if there are no existing windows

         if (!D.Window eq -1) then $
              DEVICE_MGR, d_display, ORIENT=Orientation, WINDOW=Window

;   Save existing plot window

         RESTORE_ = TVRD()

;   Make our first plot

         XOPLOT_, X=X, Y=Y, DX=DX, DY=DY, /NEW, _EXTRA=USER_keys
         D_Window  = !D.Window

;   Save UNDO information

         XPL_.Undo.X = !X
         XPL_.Undo.Y = !Y
         XPL_.Undo.P = !P

;   Store data

         if (NPar lt 4) then DY = 0
         if (NPar lt 3) then DX = 0
         if (NPar lt 2) then Y  = 0
         DATA_     = { NP:NPar, X:X, Y:Y, DX:DX, DY:DY }

  MAINxop = WIDGET_BASE(GROUP_LEADER=Group, $
      ROW=1, $
      MAP=1, $
      TITLE='XOplot Main Menu', $
      UVALUE='MAINxop')

  MenuDesc13277 = [ $
      { CW_PDMENU_S,       1, 'File' }, $ ;        0
        { CW_PDMENU_S,       0, 'Close' }, $ ;        2
        { CW_PDMENU_S,       0, 'Save' }, $ ;        3
        { CW_PDMENU_S,       0, 'Print' }, $ ;        4
        { CW_PDMENU_S,       0, 'Delete and Exit' }, $ ;        5
        { CW_PDMENU_S,       2, 'Exit' }, $ ;        6
      { CW_PDMENU_S,       0, 'Settings' }, $ ;        7
      { CW_PDMENU_S,       0, 'Undo' }, $ ;        8
      { CW_PDMENU_S,       3, 'Help' }, $ ;        9
        { CW_PDMENU_S,       0, 'Online Help' }, $ ;        10
        { CW_PDMENU_S,       2, 'About' } $  ;     11

  ]


  PDMENUxop = CW_PDMENU( MAINxop, MenuDesc13277, /RETURN_FULL_NAME, $
      UVALUE='PDMENUxop')

  WIDGET_CONTROL, MAINxop, /REALIZE

  XMANAGER, 'MAINxop', MAINxop, /MODAL

         iss = WSHOW_ACTIVE(D_Window)

         if (XPL_.ok eq 0) then begin
              DEVICE_MGR, !D.NAME, WINDOW=Window, /CLOSE
              !P.MULTI(0)=0
         endif

;   Restore IDL's system variables
;   We cannot just restore the ENTIRE structure, because IDL updates some
;   of the tags everytime a plot is made.  Only save the ones we modify
;   and would like to restore when this routine terminates.

         Pcolor=!P.color
         Pbkd  =!P.background

         for i=0,XPL_.here_sys.nX-1 do begin
              j         = XPL_.here_sys.X(i)
              !X.(j)    = Xsave.(j)              ;for the display
              XPL_.X.(j)= Xsave.(j)              ;for the printer output
         endfor

         for i=0,XPL_.here_sys.nY-1 do begin
              j         = XPL_.here_sys.Y(i)
              !Y.(j)    = Ysave.(j)
              XPL_.Y.(j)= Ysave.(j)
         endfor

         for i=0,XPL_.here_sys.nP-1 do begin
              j         = XPL_.here_sys.P(i)
              !P.(j)    = Psave.(j)
         endfor

         !P.color       = Pcolor                 ;Preserve any changes to the colors to
         !P.background  = Pbkd                   ; be consistent with plot and oplot,
                                                 ; 6/21/95

         here      = WHERE( (XPL_.Tags(*).SysVar eq '!P') and $
                            (XPL_.Tags(*).Name ne 'COLOR')and $
                            (XPL_.Tags(*).Name ne 'BACKGROUND'),nPP )
         for i=0,nPP-1 do begin
              k         = XPL_.Tags(here(i)).SysIndex
              XPL_.P.(k)= Psave.(k)
         endfor

         USER_          = 0
         DATA_          = 0

END
;*******************************************************************************
;     END: XOplot MAIN MENU widgets
;*******************************************************************************
