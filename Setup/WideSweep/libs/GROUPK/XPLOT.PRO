;+
; NAME:
;        XPLOT
;
; PURPOSE:
;        This procedure is a "superset" of PLOT and PLOTERR with the
;        additional feature of allowing the USER to interactively change
;        many of its settings "on the fly" (e.g. x-axis range, plotting
;        symbol, etc.) via various widget menus.  It accepts ALL of the
;        keywords used by PLOT and PLOTERR and some additional keywords
;        described below.  The USER may also print the plot directly
;        under the File pulldown menu, (it can handle multiple
;        plots/window).
;
; CATEGORY:
;        Plotting and Widgets.
;
; CALLING SEQUENCE:
;
;        XPLOT, [X,] Y, [DX, [DY]]
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
;        All of the keywords accepted by PLOT and PLOTERR may be used as
;        well as the following additional keywords:
;
;        LANDSCAPE:     Set this keyword to specify that the window the plot
;                  is drawn in should be in landscape mode (1=Default).
;
;        PORTRAIT: Set this keyword to specify that the window the plot is
;                  drawn in should be in portrait mode (0=Default).
;
;        WINDOW:   Window number of the window to create and draw the plot
;                  in.  If the window already exists, then any existing
;                  plots in the window will be erased (0=Default).
;
;        RESET:    Resets the XPLOT common block.
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
;        you've gotten your plot right.  Okay, so how about printing this
;        thing?  Well, then you have to change the output device using
;        SET_PLOT, then repeat typing in all the PLOT and PLOTERR commands
;        with all the hard-fought graphic keywords.  Sound familiar?
;
;        XPLOT has been designed to make this process more "interactive"
;        and less tedious.  You may use XPLOT just as you would PLOT or
;        PLOTERR, specifying on the command line all of the graphic
;        keywords accepted by PLOT or PLOTERR.  Now, however, along with
;        the usual plot comes a nice widget menu.  From this widget menu,
;        you may modify most of the available PLOT and PLOTERR settings,
;        right "there".  You may additionally SAVE this plot to a
;        PostScript file and send it to the printer, right "there" from the
;        widget menu.
;
;        Okay, so how do I do this?  For single plots/page, there are four
;        simple steps. 1) Run XPLOT on you data; 2) Fiddle with the
;        settings INTERACTIVELY until you've gotten it right; 3) Select
;        Save under the File pulldown menu to save the plot to a PostScript
;        file; and 4) Select either Close or Print under the File pulldown
;        menu.  Either commands will close the PostScript file.  Print will
;        additionally spawn a print command on this PostScript file.
;
;        For multiple plots/page, repeat steps 1) - 3) for each plot.  For
;        each plot, except the last, select Exit under the File pulldown
;        menu when you're done with the plot.  For the last plot, instead
;        of selecting Exit, select either Close or Print in order to close
;        the PostScript file.  Once the PostScript file is closed, you can
;        no longer make any modifications to it from within XPLOT.
;
;        Finally, if you want to overplot data on an existing plot, first
;        use XPLOT to create the first plot following steps 1) - 3)
;        described above and then Exit XPLOT.  Use XOPLOT for each data set
;        you want to overplot, following setps 1) - 3) again (using XOPLOT
;        instead of XPLOT, of course) and then Exit XOPLOT except for the
;        last data set.  For the last one, select Close or Print from the
;        File pulldown menu to close the PostScript File.
;
;
; EXAMPLE:
;        x    = findgen(100)
;        y    = sin(x/20)
;
;        XPLOT,x,y,TITLE='Title',XTITLE='X-Axis',YTITLE='Y-Axis'
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, January 1995.
;        01-FEB-1995    Added the NO_MENU keyword. (1.01)
;        02-FEB-1995    Save printer output system variables to XPLOT
;                       common. (1.20)
;        02-FEB-1995    Small bug fix, initialize CLOSE (1.21)
;                       Small bug fix, reseting printer output system variables
;                       back to their defaults when exiting (1.22)
;        08-FEB-1995    Added the NOCLIP keyword and HISTOGRAM plotting
;                       symbol. (1.30)
;                       Added GRIDLINES option. (1.40)
;                       Bugfix: Improperly displayed gridlines settings (1.41)
;        21-FEB-1995    Bugfix: Did not reset current window if !D.WINDOW ne
;                       -1, (1.42)
;        29-APR-1995    >Cosmetic changes; Got rid of Current in Display Current Settings,
;                       etc.  Put it in originally to force window wide enough to read
;                       the window title.
;                       >Deleting Plot Window will NOT delete PS TMP file if Print Plot
;                       Window has been previously selected.
;                       >Added Output Settings and Encapsulate PostScript options.
;        03-MAY-1995    Completely rewrote the GUI by utilizing WIDED.  Added more
;                       flexibility by adding the File pulldown menu. (3.0)
;        06-MAY-1995    Rearranged Settings widget layout.  Don't have to press Enter
;                       when modifying titles, limits or font sizes. (3.1)
;        07-MAY-1995    Make sure USER supplied two or more points to plot. (3.11)
;        09-MAY-1995    Check only first 3 characters of !VERSION.OS. (3.12)
;        15-MAY-1995    Reset IDL system variables if RESET keyword is set. (3.13)
;        17-MAY-1995    Bugfix: Make sure x,y scale is linear upon entering Xplot,
;                       unless USER specifies XTYPE,YTYPE keywords. (3.14)
;        23-MAY-1995    Remembers path of current or previously saved PS file and
;                       warn USER if overwriting existing PS file. (3.15)
;        25-MAY-1995    Bugfix: Preserve any changes to !X.type or !Y.type in case
;                       of subsequent XOplot calls. (3.16)
;        06-JUN-1995    Bugfix: Changed max slider value from 255 -> !D.N_COLORS. (3.17)
;        06-JUN-1995    Check to see if input arrays are defined. (3.18)
;        08-JUN-1995    Check to see if ANY data in USER-selected range. (3.19)
;        12-JUN-1995    Replaced XPLOT_ERASE -> tvrd(), tv. (3.20)
;        14-JUN-1995    Added Select Region button, plot updated after each
;                       USER modification. (3.3)
;        19-JUN-1995    Bugfix: Don't check for valid range if !X.range=0. (3.31)
;        20-JUN-1995    Bugfix: Save/restore existing plot settings if closing an
;                       old print file. (3.32)
;        21-JUN-1995    Bugfix: Preserve any changes to the color indices when leaving
;                       XOplot. (3.33)
;        29-SEP-1995    Set DEVICE keyword, DECOMPOSED=0 for systems with > 256
;                       colors. (3.34)
;        07-AUG-1996    Eliminate calls to VERSION(). (3.35)
;-


pro XPLOT_, X=X, Y=Y, DX=DX, DY=DY, NEW=New, $
              ANONYMOUS_=Dummy_, _EXTRA=User_keys
;
;   Plot the graph using the graphic keywords defined by
;   the graphics system variables (!P, !X and !Y) and/or the additional
;   USER keywords defined by User_keys
;

;   If the NEW keyword is NOT set then we are RE-ploting an existing
;   plot.  Set !P.MULTI(0) to the value before existing plot was plotted.

    if NOT keyword_set(NEW) then begin
         n_plot = (!P.MULTI(1) > 1)*(!P.MULTI(2) > 1)
         !P.MULTI(0) = (!P.MULTI(0) + 1) MOD n_plot
    endif

    nUSER = N_ELEMENTS(User_keys)
    if nUSER gt 1 then tags = TAG_NAMES(User_keys)

    if (!X.type eq 1) then begin
         XTYPE=1
         if nUSER gt 1 then begin
              here = where( tags eq 'XTYPE', ndefined )
              if ndefined gt 0 then User_keys.XTYPE = 1
         endif
    endif else XTYPE=0

    if (!Y.type eq 1) then begin
         YTYPE=1
         if nUSER gt 1 then begin
              here = where( tags eq 'YTYPE', ndefined )
              if ndefined gt 0 then User_keys.YTYPE = 1
         endif
    endif else YTYPE=0

    if keyword_set( DY )  then ploterr, X, Y, DX, DY,  $
                                        XTYPE=XTYPE, $
                                        YTYPE=YTYPE, $
                                        NOCLIP=0, $
                                        _EXTRA=User_keys $
    else if keyword_set( DX )  then ploterr, X, Y, DX, $
                                        XTYPE=XTYPE, $
                                        YTYPE=YTYPE, $
                                        NOCLIP=0, $
                                        _EXTRA=User_keys $
    else if keyword_set( Y )  then plot, X, Y, $
                                        XTYPE=XTYPE, $
                                        YTYPE=YTYPE, $
                                        NOCLIP=0, $
                                        _EXTRA=User_keys $
    else if keyword_set( X )  then plot, X, $
                                        XTYPE=XTYPE, $
                                        YTYPE=YTYPE, $
                                        NOCLIP=0, $
                                        _EXTRA=User_keys

end


;*******************************************************************************
;   BEGIN: XPlot ONLINE HELP widgets
;*******************************************************************************

pro XPL_HELP, GROUP=Group

         ncol      = 50
         Topics = ['Overview'                 ,$
                   'Why should I use XPlot?'  ,$
                   'How do I use XPlot?'      ,$
                   'File - New'               ,$
                   'File - Close'             ,$
                   'File - Save'              ,$
                   'File - Print'             ,$
                   'File - Delete and Exit'   ,$
                   'File - Exit'              ,$
                   'Settings']
         Descr0 = [$
             ; Overview
             'INDENT_'                                                           ,$
             'This procedure is a "superset" of PLOT and PLOTERR with the '      ,$
             'additional feature of allowing the USER to interactively change'   ,$
             'many of its settings "on the fly" (e.g. x-axis range, plotting'    ,$
             'symbol,etc.) via various widget menus.  It accepts ALL of the'     ,$
             'keywords used by PLOT and PLOTERR and some additional keywords'    ,$
             'described below. The USER may also print the plot directly'        ,$
             'under the File pulldown menu, (it can handle multiple '            ,$
             'plots/window).'                                                    ,$
             'END_TOPIC'                                                         ,$
             ; Why should I use XPlot?
             'INDENT_'                                                           ,$
             'Okay, here''s a typical situation when it comes to IDL plotting:'  ,$
             'you run PLOT or PLOTERR with various graphic keywords, look at the',$
             'resulting plot and .... oops, need to change the x-axis range..'   ,$
             'change the y-axis title.. etc.  So, you rerun PLOT or PLOTERR with',$
             'the modified keywords and repeat  this  cycle of plotting until'   ,$
             'you''ve gotten your plot right.  Okay, so how about printing this' ,$
             'thing?   Well, then you have to change the output device using'    ,$
             'SET_PLOT, then repeat typing in all the PLOT  and PLOTERR commands',$
             'with all the hard-fought graphic keywords.  Sound familiar?'       ,$
             strpad(' ',15+ncol-1)                                               ,$
             'INDENT_'                                                           ,$
             'XPLOT has been designed to make this process more interactive '    ,$
             'and less tedious.  You may use XPLOT just as you would PLOT or'    ,$
             'PLOTERR, specifying on the command line all of the graphic'        ,$
             'keywords accepted by PLOT or PLOTERR.  Now, however, along with'   ,$
             'the usual plot comes a nice widget menu.  From this widget menu,'  ,$
             'you may modify most of the available PLOT and PLOTERR settings,'   ,$
             'right THERE.  You may additionally SAVE this plot to a PostScript' ,$
             'file and send it to the printer, right THERE from the widget menu.',$
             'END_TOPIC'                                                         ,$
             ; How do I use XPlot?
             'INDENT_'                                                           ,$
             'Okay, so how do I do this?  For single plots/page, there are four' ,$
             'simple steps. 1) Run XPLOT on you data;   2) Fiddle with the'      ,$
             'settings INTERACTIVELY until you''ve gotten it right; 3) Select'   ,$
             'Save under the File pulldown menu to save the plot to a PostScript',$
             'file; and 4) Select either Close or Print under the File pulldown' ,$
             'menu.  Either commands will close the PostScript file.  Print will',$
             'additionally spawn a print command on this PostScript file.'       ,$
             strpad(' ',ncol-1)                                                  ,$
             'INDENT_'                                                           ,$
             'For multiple plots/page, repeat steps 1) - 3) for each plot.  For' ,$
             'each plot, except the last, select Exit under the File pulldown'   ,$
             'menu when you''re done with the plot.  For the last plot, instead' ,$
             'of selecting Exit, select either Close or Print in order to close' ,$
             'the PostScript file.  Once the PostScript file is closed, you can' ,$
             'no longer make any modifications to it from within XPLOT.'         ,$
             strpad(' ',15+ncol-1)                                               ,$
             'INDENT_'                                                           ,$
             'Finally, if you want to overplot data on an existing plot, first'  ,$
             'use XPLOT to create the first plot following steps 1) - 3)'        ,$
             'described above and then Exit XPLOT.  Use XOPLOT for each data set',$
             'you want to overplot, following setps 1) - 3) again (using XOPLOT' ,$
             'instead of XPLOT, of course) and then Exit XOPLOT except for the'  ,$
             'last data set.  For the last one, select Close or Print from the'  ,$
             'File pulldown menu to close the PostScript File.'                  ,$
             'END_TOPIC'                                                         ,$
             ; File - New
             'INDENT_'                                                           ,$
             'Opens a new PostScript file and prompts the USER for its filename.',$
             'END_TOPIC'                                                         ,$
             ; File - Close
             'INDENT_'                                                           ,$
             'Closes the current PostScript file.  Once the PostScript file is'  ,$
             'closed it can no longer be modified from within XPLOT.'            ,$
             'END_TOPIC'                                                         ,$
             ; File - Save
             'INDENT_'                                                           ,$
             'Saves the current plot to a PostScript file. For a single'         ,$
             'plot/page file or for the first plot of a multiple plots/page file',$
             'the current PostScript file is overwritten by the current plot.'   ,$
             'If no PostScript file is currently opened, then a new one is'      ,$
             'created with the filename, idlnnnnn.ps or idlnnnnn.eps depending'  ,$
             'upon the type of PostScript file you specify, Normal or'           ,$
             'Encapsulated, respectively.  For all remaining plots for'          ,$
             'a multiple plots/page file, the current PostScript file is'        ,$
             'updated with the current plot.'                                    ,$
             'END_TOPIC'                                                         ,$
             ; File - Print
             'INDENT_'                                                           ,$
             'Prints the current PostScript file.  If it is still open, then'    ,$
             'the PostScript file is closed before being printed.  Note: this'   ,$
             'option is only available for Normal PostScript files.'             ,$
             'END_TOPIC'                                                         ,$
             ; File - Delete and Exit
             'Deletes the current plot window and exits XPlot.'                  ,$
             'END_TOPIC'                                                         ,$
             ; File - Exit
             'Exits XPlot.'                                                      ,$
             'END_TOPIC'                                                         ,$
             ; Settings
             'INDENT_'                                                           ,$
             'Most of the available graphic keywords for PLOT and PLOTERR'       ,$
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

         XHELPMSG,Topics,Descr,nlines,GROUP=Group,TITLE='XPlot Online Help'

end


;*******************************************************************************
;     END: XPlot ONELINE HELP widgets
;*******************************************************************************

;*******************************************************************************
;   BEGIN: XPlot ABOUT widgets
;*******************************************************************************

PRO MAINAbout_Event, Event

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

PRO XPL_About, GROUP=Group


  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAINAbout = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      TITLE='About XPlot', $
      UVALUE='MAINAbout')


  VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
  CASE VERSION_OS OF
    'win'    : font = 'TIMES NEW ROMAN*BOLD*ITALIC*35'
    'vms'    : font = ''
    'mac'    : font = ''
    ELSE     : font = '-adobe-times-bold-i-*-*-34-*-*-*-*-*-*-*'
  ENDCASE
  LABEL11 = WIDGET_LABEL( MAINAbout, $
      FONT=font, $
      UVALUE='LABEL11', $
      VALUE='XPlot')

  BASE28 = WIDGET_BASE(MAINAbout, $
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


  LABEL12 = WIDGET_LABEL( MAINAbout, $
      UVALUE='LABEL12', $
      VALUE='Version 3.35')

  LABEL13 = WIDGET_LABEL( MAINAbout, $
      UVALUE='LABEL13', $
      VALUE='29-September-95')

  LABEL14 = WIDGET_LABEL( MAINAbout, $
      UVALUE='LABEL14', $
      VALUE=' ')

  LABEL15 = WIDGET_LABEL( MAINAbout, $
      UVALUE='LABEL15', $
      VALUE='H. C. Wen')

  LABEL16 = WIDGET_LABEL( MAINAbout, $
      UVALUE='LABEL16', $
      VALUE='hanwen@slac.stanford.edu')

  LABEL17 = WIDGET_LABEL( MAINAbout, $
      UVALUE='LABEL17', $
      VALUE=' ')

  BASE20 = WIDGET_BASE(MAINAbout, $
      ROW=1, $
      XPAD=100, $
      MAP=1, $
      TITLE='Button Base', $
      UVALUE='BASE20')

  BUTTON21 = WIDGET_BUTTON( BASE20, $
      UVALUE='BUTTON21', $
      VALUE='Ok')


  WIDGET_POSITION, MAINAbout, /CENTER

  XMANAGER, 'MAINAbout', MAINAbout
END

;*******************************************************************************
;     END: XPlot ABOUT widgets
;*******************************************************************************

;*******************************************************************************
;   BEGIN: XPlot TEXT SETTINGS widgets
;*******************************************************************************

PRO MAINtxt_Event, Event

  common XPLOT, XPL_, USER_, DATA_, RESTORE_

  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev, GET_VALUE=text

  CASE Ev OF
  'TEXT10': BEGIN                                ; X-Axis title
      !X.TITLE = text(0)
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE11 [X-Axis]          ; BASE4 [Main]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE7  [Y-Axis]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL15
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT16
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      END
  'TEXT16': BEGIN                                ; Y-Axis title
      !Y.TITLE = text(0)
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE7  [Y-Axis]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE4  [Main]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL18
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT6
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      END
  'TEXT6': BEGIN                                 ; Main title
      !P.TITLE = text(0)
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE4  [Main]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE20 [Subtitle]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL5
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT10
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      END
  'TEXT19': BEGIN                                ; Subtitle
      !P.SUBTITLE = text(0)
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE20 [Subtitle]
      id=WIDGET_INFO(id,/PARENT)                 ; BASE2  [Titles]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL3
      id=WIDGET_INFO(id,/SIBLING)                ; BASE11 [X-Axis]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT10
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      END
  'TEXT35': BEGIN                                ; Overall font size
      !P.CHARSIZE = float(text(0))
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/SIBLING)          ; LABEL41[X-Axis]
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT46
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      END
  'TEXT46': BEGIN                                ; X-Axis font size
      !X.CHARSIZE = float(text(0))
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/SIBLING)          ; LABEL43[Y-Axis]
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT46
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      END
  'TEXT48': BEGIN                                ; Y-Axis font size
      !Y.CHARSIZE = float(text(0))
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE33 [Font Types]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL34[Overall]
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT35
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      END
  'BUTTON60': BEGIN          ;Event for Ok
      ; Collect all entries case USER did not hit ENTER
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE59 [Ok and Cancel]
      id=WIDGET_INFO(id,/PARENT)                 ; MAINtxt[Top Base]
      it=WIDGET_INFO(id,/CHILD)                  ; BASE2  [Titles]
      id=WIDGET_INFO(it,/CHILD)                  ; LABEL3
      ix=WIDGET_INFO(id,/SIBLING)                ; BASE11 [X-Axis]
      id=WIDGET_INFO(ix,/CHILD)                  ; LABEL9
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT6
      WIDGET_CONTROL,id, GET_VALUE=text
      !X.TITLE=text(0)

      iy=WIDGET_INFO(ix,/SIBLING)                ; BASE17 [Y-Axis]
      id=WIDGET_INFO(iy,/CHILD)                  ; LABEL15
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT16
      WIDGET_CONTROL,id, GET_VALUE=text
      !Y.TITLE=text(0)

      im=WIDGET_INFO(iy,/SIBLING)                ; BASE4  [Main]
      id=WIDGET_INFO(im,/CHILD)                  ; LABEL5
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT6
      WIDGET_CONTROL,id, GET_VALUE=text
      !P.TITLE=text(0)

      is=WIDGET_INFO(im,/SIBLING)                ; BASE20 [Subtitle]
      id=WIDGET_INFO(is,/CHILD)                  ; LABEL18
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT19
      WIDGET_CONTROL,id, GET_VALUE=text
      !P.SUBTITLE=text(0)

      id=WIDGET_INFO(it,/SIBLING)                ; BASE31 [Font Sizes]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL32
      id=WIDGET_INFO(id,/SIBLING)                ; BASE33 [Font Types]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL34[Overall]
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT35
      WIDGET_CONTROL,id, GET_VALUE=text
      !P.CHARSIZE = float(text(0))

      id=WIDGET_INFO(id,/SIBLING)                ; LABEL41[X-Axis]
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT46
      WIDGET_CONTROL,id, GET_VALUE=text
      !X.CHARSIZE = float(text(0))

      id=WIDGET_INFO(id,/SIBLING)                ; LABEL43[Y-Axis]
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT48
      WIDGET_CONTROL,id, GET_VALUE=text
      !Y.CHARSIZE = float(text(0))

      XPL_.ok = 1
      WIDGET_CONTROL, Event.Top, /DESTROY
      END
  'BUTTON61': BEGIN          ;Event for Cancel
      XPL_.ok = 0
      WIDGET_CONTROL, Event.Top, /DESTROY
      RETURN
      END
  ENDCASE

  tv, RESTORE_                                      ; Restore original plot
  XPLOT_, X=DATA_.X, Y=DATA_.Y, $                   ; Update display
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with NEW settings
END


pro XPL_txt, GROUP=Group

  common XPLOT

; Save !X, !Y, !P settings in case of Cancel
  Xsave  = !X
  Ysave  = !Y
  Psave  = !P

  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAINtxt = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      TITLE='XPlot Text Settings', $
      UVALUE='MAINtxt')

  BASE2 = WIDGET_BASE(MAINtxt, $
      COLUMN=1, $
      FRAME=1, $
      MAP=1, $
      TITLE='Titles', $
      UVALUE='BASE2')

  LABEL3 = WIDGET_LABEL( BASE2, $
      UVALUE='LABEL3', $
      VALUE='Titles')

  BASE11 = WIDGET_BASE(BASE2, $
      ROW=1, $
      MAP=1, $
      TITLE='X-Axis', $
      UVALUE='BASE11')

  LABEL9 = WIDGET_LABEL( BASE11, $
      UVALUE='LABEL9', $
      VALUE='X-Axis')

  TEXT10 = WIDGET_TEXT( BASE11,VALUE=!X.TITLE,$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT10', $
      XSIZE=42, $
      YSIZE=1)

  BASE17 = WIDGET_BASE(BASE2, $
      ROW=1, $
      MAP=1, $
      TITLE='Y-Axis', $
      UVALUE='BASE17')

  LABEL15 = WIDGET_LABEL( BASE17, $
      UVALUE='LABEL15', $
      VALUE='Y-Axis')

  TEXT16 = WIDGET_TEXT( BASE17,VALUE=!Y.TITLE,$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT16', $
      XSIZE=42, $
      YSIZE=1)

  BASE4 = WIDGET_BASE(BASE2, $
      ROW=1, $
      MAP=1, $
      TITLE='Main', $
      UVALUE='BASE4')

  LABEL5 = WIDGET_LABEL( BASE4, $
      UVALUE='LABEL5', $
      VALUE='Main')

  TEXT6 = WIDGET_TEXT( BASE4,VALUE=!P.TITLE, $
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT6', $
      XSIZE=43, $
      YSIZE=1)

  BASE20 = WIDGET_BASE(BASE2, $
      ROW=1, $
      MAP=1, $
      TITLE='Subtitle', $
      UVALUE='BASE20')

  LABEL18 = WIDGET_LABEL( BASE20, $
      UVALUE='LABEL18', $
      VALUE='Subtitle')

  TEXT19 = WIDGET_TEXT( BASE20,VALUE=!P.SUBTITLE, $
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT19', $
      XSIZE=41, $
      YSIZE=1)


  BASE31 = WIDGET_BASE(MAINtxt, $
      COLUMN=1, $
      FRAME=1, $
      MAP=1, $
      TITLE='Font Sizes', $
      UVALUE='BASE31')

  LABEL32 = WIDGET_LABEL( BASE31, $
      UVALUE='LABEL32', $
      VALUE='Font Sizes')

  BASE33 = WIDGET_BASE(BASE31, $
      ROW=1, $
      MAP=1, $
      TITLE='Font Types', $
      UVALUE='BASE33')

  LABEL34 = WIDGET_LABEL( BASE33, $
      UVALUE='LABEL34', $
      VALUE='Overall')

  txt_val= string(!P.CHARSIZE,FORMAT='(F6.3)')
  TEXT35 = WIDGET_TEXT( BASE33,VALUE=txt_val,$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT35', $
      XSIZE=7, $
      YSIZE=1)

  LABEL41 = WIDGET_LABEL( BASE33, $
      UVALUE='LABEL41', $
      VALUE='    X-Axis')

  txt_val= string(!X.CHARSIZE,FORMAT='(F6.3)')
  TEXT46 = WIDGET_TEXT( BASE33,VALUE=txt_val,$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT46', $
      XSIZE=7, $
      YSIZE=1)

  LABEL43 = WIDGET_LABEL( BASE33, $
      UVALUE='LABEL43', $
      VALUE='    Y-Axis')

  txt_val= string(!Y.CHARSIZE,FORMAT='(F6.3)')
  TEXT48 = WIDGET_TEXT( BASE33,VALUE=txt_val,$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT48', $
      XSIZE=7, $
      YSIZE=1)

  BASE59 = WIDGET_BASE(MAINtxt, $
      ROW=1, $
      XPAD=120, $
      MAP=1, $
      TITLE='Ok and Cancel', $
      UVALUE='BASE59')

  BUTTON60 = WIDGET_BUTTON( BASE59, $
      UVALUE='BUTTON60', $
      VALUE='Ok')

  BUTTON61 = WIDGET_BUTTON( BASE59, $
      UVALUE='BUTTON61', $
      VALUE='Cancel')


  WIDGET_CONTROL, MAINtxt, /REALIZE
  WIDGET_CONTROL,TEXT10, SET_TEXT_SELECT=[0,0]
  WIDGET_CONTROL,TEXT10, /INPUT_FOCUS, GET_VALUE=oval
  WIDGET_CONTROL,TEXT10, SET_TEXT_SELECT=[0,strlen( oval )]

  XMANAGER, 'MAINtxt', MAINtxt, /MODAL

; Restore !X, !Y, !P on Cancel
  if (XPL_.ok eq 0) then begin
    !X   = Xsave
    !Y   = Ysave
    !P   = Psave
    tv, RESTORE_                                      ; Restore original plot
    XPLOT_, X=DATA_.X, Y=DATA_.Y, $                   ; Update display
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with ENTRY settings
  endif
END
;*******************************************************************************
;     END: XPlot TEXT SETTINGS widgets
;*******************************************************************************

;*******************************************************************************
;   BEGIN: XPlot X- and Y-AXIS SETTINGS widgets
;*******************************************************************************

PRO MAINxy_Event, Event

  common XPLOT

  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev,GET_VALUE=val

  BG_ck = STRMID(Ev,0,6)
  if (BG_ck eq 'BGROUP') then begin
      if (val ne Event.Value) then return
  endif
  DESTROY = 0

  CASE Ev OF

  'TEXT68': BEGIN
      !X.RANGE(0)=float(val(0))                  ; X-Axis Minimum
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE47 [Minimum]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE48 [Maximum]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL56
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT70
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      if (!X.RANGE(0) gt !X.RANGE(1)) then return
      END
  'TEXT70': BEGIN
      !X.RANGE(1)=float(val(0))                  ; X-Axis Maximum
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE48 [Maximum]
      id=WIDGET_INFO(id,/PARENT)                 ; BASE6  [X-Axis]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE91 [Y-Axis]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL83[Minimum]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE47
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT85
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      if (!X.RANGE(0) gt !X.RANGE(1)) then return
      END
  'BGROUP59': BEGIN                              ; X-Axis Type

      if (Val eq 1) then begin
         ; Make sure data in plot range is within log domain

         if (DATA_.NP gt 1) then begin
            minX = !X.RANGE(0) < !X.RANGE(1)
            if (minX eq 0) then minX = MIN(DATA_.X)
            if (minX le 0) then begin
                 WIDGET_CONTROL,Event.Id,SET_VALUE=0
                 xmsg, ['Argument domain error in log function,',$
                        'values must be greater than 0'],$
                        TITLE='XPlot ERROR'
                 return
            endif
         endif
      endif
      !X.TYPE = val
      END
  'BGROUP60': !X.STYLE= val                      ; X-Axis Style
  'BGROUP61': BEGIN                              ; X-Axis Gridstyle
      if (Val gt 0) then !X.TICKLEN=1 $
      else !X.TICKLEN=0
      !X.GRIDSTYLE = (Val-1) > 0
      END
  'TEXT85': BEGIN
      !Y.RANGE(0)=float(val(0))                  ; Y-Axis Minimum
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE47 [Minimum]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE48 [Maximum]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL56
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT87
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      if (!Y.RANGE(0) gt !Y.RANGE(1)) then return
      END
  'TEXT87': BEGIN
      !Y.RANGE(1)=float(val(0))                  ; Y-Axis Maximum
      WIDGET_CONTROL,Event.ID, SET_TEXT_SELECT=[0,0]
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE48 [Maximum]
      id=WIDGET_INFO(id,/PARENT)                 ; BASE91 [Y-Axis]
      id=WIDGET_INFO(id,/PARENT)                 ; BASE2  [X- and Y- Axis]
      id=WIDGET_INFO(id,/CHILD)                  ; BASE6  [X-Axis]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL7 [Minimum]
      id=WIDGET_INFO(id,/SIBLING)                ; BASE47
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL50
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT68
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,0]
      WIDGET_CONTROL,id, /INPUT_FOCUS, GET_VALUE=oval
      WIDGET_CONTROL,id, SET_TEXT_SELECT=[0,strlen( oval )]
      if (!Y.RANGE(0) gt !Y.RANGE(1)) then return
      END
  'BGROUP88':BEGIN                               ; Y-Axis Type

      if (Val eq 1) then begin

         ; Make sure data in plot range is within log domain

         minY = !Y.RANGE(0) < !Y.RANGE(1)
         if (minY eq 0) then begin
            if (DATA_.NP eq 1) then minY = MIN(DATA_.X) $
            else minY = MIN(DATA_.Y)
         endif
         if (minY le 0) then begin
              WIDGET_CONTROL,Event.Id,SET_VALUE=0
              xmsg, ['Argument domain error in log function,',$
                     'values must be greater than 0'],$
                     TITLE='XPlot ERROR'
              return
         endif
      endif
      !Y.TYPE   = Val
      END
  'BGROUP89': !Y.STYLE  = Val                    ; Y-Axis Style
  'BGROUP90': BEGIN                              ; Y-Axis Gridstyle
      if (Val gt 0) then !Y.TICKLEN=1 $
      else !Y.TICKLEN=0
      !Y.GRIDSTYLE = (Val-1) > 0
      END
  'BUTTON4': BEGIN      ;Event for Ok
      ; Collect all entries case USER did not hit ENTER
      id=WIDGET_INFO(Event.ID,/PARENT)           ; BASE3  [Ok and Cancel]
      id=WIDGET_INFO(id,/PARENT)                 ; MAINxy [Top Base]
      id=WIDGET_INFO(id,/CHILD)                  ; BASE2  [X- and Y-Axis]
      ix=WIDGET_INFO(id,/CHILD)                  ; BASE6  [X-Axis]
      id=WIDGET_INFO(ix,/CHILD)                  ; LABEL7
      in=WIDGET_INFO(id,/SIBLING)                ; BASE47 [Minimum]
      id=WIDGET_INFO(in,/CHILD)                  ; LABEL50
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT68
      WIDGET_CONTROL,id, GET_VALUE=val
      !X.RANGE(0)=float(val(0))                  ; X-Axis Minimum

      id=WIDGET_INFO(in,/SIBLING)                ; BASE48 [Maximum]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL56
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT70
      WIDGET_CONTROL,id, GET_VALUE=val
      !X.RANGE(1)=float(val(0))                  ; X-Axis Maximum

      iy=WIDGET_INFO(ix,/SIBLING)                ; BASE91 [Y-Axis]
      id=WIDGET_INFO(iy,/CHILD)                  ; LABEL83
      in=WIDGET_INFO(id,/SIBLING)                ; BASE47 [Minimum]
      id=WIDGET_INFO(in,/CHILD)                  ; LABEL84
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT85
      WIDGET_CONTROL,id, GET_VALUE=val
      !Y.RANGE(0)=float(val(0))                  ; Y-Axis Minimum

      id=WIDGET_INFO(in,/SIBLING)                ; BASE48 [Maximum]
      id=WIDGET_INFO(id,/CHILD)                  ; LABEL86
      id=WIDGET_INFO(id,/SIBLING)                ; TEXT87
      WIDGET_CONTROL,id, GET_VALUE=val
      !Y.RANGE(1)=float(val(0))                  ; Y-Axis Maximum

      XPL_.ok = 1
      DESTROY = 1
      END
  'BUTTON5': BEGIN      ;Event for Cancel
      XPL_.ok = 0
      WIDGET_CONTROL, Event.Top, /DESTROY
      RETURN
      END
  ENDCASE

  if TOTAL(abs(!X.RANGE)) ne 0 then begin
       xmin = !X.RANGE(0) < !X.RANGE(1)
       xmax = !X.RANGE(0) > !X.RANGE(1)
       Out_of_range=0
       CASE DATA_.NP OF
          1    : BEGIN
               npts = N_ELEMENTS(DATA_.X)
               if (xmin ge npts) or (xmax lt 0) then Out_of_range = 1
               END
          ELSE : BEGIN
               here = where( (DATA_.X ge xmin) and $
                             (DATA_.X le xmax), nrng )
               Out_of_range = (nrng eq 0)
               END
       ENDCASE
       if Out_of_range then begin
          xmsg, ['No valid points,',$
                 'must have at least 2 distinct points'],TITLE='XPlot ERROR'
          DESTROY=0
       endif
  endif

  tv, RESTORE_                                      ; Restore original plot
  XPLOT_, X=DATA_.X, Y=DATA_.Y, $                   ; Update display
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with NEW settings

  if DESTROY then WIDGET_CONTROL, Event.Top, /DESTROY

END


pro XPL_XY, GROUP=Group

  common XPLOT

; Save !X, !Y, !P settings in case of Cancel
  Xsave  = !X
  Ysave  = !Y
  Psave  = !P

  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAINxy = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      TITLE='XPlot X- and Y-Axis Settings', $
      UVALUE='MAINxy')

  BASE2 = WIDGET_BASE(MAINxy, $
      ROW=1, $
      MAP=1, $
      TITLE='X- and Y- Axis', $
      UVALUE='BASE2')

  BASE6 = WIDGET_BASE(BASE2, $
      COLUMN=1, $
      FRAME=1, $
      MAP=1, $
      TITLE='X-Axis', $
      UVALUE='BASE6')

  LABEL7 = WIDGET_LABEL( BASE6, $
      UVALUE='LABEL7', $
      VALUE='X-Axis')

  BASE47 = WIDGET_BASE(BASE6, $
      ROW=1, $
      MAP=1, $
      TITLE='Minimum', $
      UVALUE='BASE47')

  LABEL50 = WIDGET_LABEL( BASE47, $
      UVALUE='LABEL50', $
      VALUE='Minimum')

  TEXT68 = WIDGET_TEXT( BASE47,VALUE=strtrim(!X.RANGE(0),2), $
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT68', $
      YSIZE=1)

  BASE48 = WIDGET_BASE(BASE6, $
      ROW=1, $
      MAP=1, $
      TITLE='Maximum', $
      UVALUE='BASE48')

  LABEL56 = WIDGET_LABEL( BASE48, $
      UVALUE='LABEL56', $
      VALUE='Maximum')

  TEXT70 = WIDGET_TEXT( BASE48,VALUE=strtrim(!X.RANGE(1),2),$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT70', $
      YSIZE=1)

  BASE62 = WIDGET_BASE(BASE6, $
      ROW=1, $
      MAP=1, $
      TITLE='Type/Style and Gridlines', $
      UVALUE='BASE62')

  BASE17 = WIDGET_BASE(BASE62, $
      COLUMN=1, $
      MAP=1, $
      TITLE='Type and Style', $
      UVALUE='BASE17')

  Btns13382 = [ $
    'Linear ', $
    'Logarithmic' ]
  BGROUP59 = CW_BGROUP( BASE17, Btns13382, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Type', $
      UVALUE='BGROUP59',$
      SET_VALUE=!X.TYPE)

  Btns13384 = [ $
    'Rounded', $
    'Exact', $
    'Extend', $
    'None', $
    'No Box' ]
  BGROUP60 = CW_BGROUP( BASE17, Btns13384, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Style', $
      UVALUE='BGROUP60', $
      SET_VALUE=!X.STYLE)


  Btns13386 = [ $
    'None', $
    'Solid', $
    'Dotted', $
    'Dashed', $
    'Dash Dot', $
    'Dash Dot Dot Dot', $
    'Long Dashes' ]
  BGROUP61 = CW_BGROUP( BASE62, Btns13386, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Gridlines', $
      UVALUE='BGROUP61',$
      SET_VALUE=(!X.GRIDSTYLE+1)*!X.TICKLEN)



  BASE91 = WIDGET_BASE(BASE2, $
      COLUMN=1, $
      FRAME=1, $
      MAP=1, $
      TITLE='Y-Axis', $
      UVALUE='BASE91')

  LABEL83 = WIDGET_LABEL( BASE91, $
      UVALUE='LABEL83', $
      VALUE='Y-Axis')

  BASE47 = WIDGET_BASE(BASE91, $
      ROW=1, $
      MAP=1, $
      TITLE='Minimum', $
      UVALUE='BASE47')

  LABEL84 = WIDGET_LABEL( BASE47, $
      UVALUE='LABEL84', $
      VALUE='Minimum')

  TEXT85 = WIDGET_TEXT( BASE47,VALUE=strtrim(!Y.RANGE(0),2),$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT85', $
      YSIZE=1)


  BASE48 = WIDGET_BASE(BASE91, $
      ROW=1, $
      MAP=1, $
      TITLE='Maximum', $
      UVALUE='BASE48')

  LABEL86 = WIDGET_LABEL( BASE48, $
      UVALUE='LABEL86', $
      VALUE='Maximum')

  TEXT87 = WIDGET_TEXT( BASE48,VALUE=strtrim(!Y.RANGE(1),2),$
      EDITABLE=1, $
      FRAME=1, $
      UVALUE='TEXT87', $
      YSIZE=1)

  BASE62 = WIDGET_BASE(BASE91, $
      ROW=1, $
      MAP=1, $
      TITLE='Type/Style and Gridlines', $
      UVALUE='BASE62')

  BASE17 = WIDGET_BASE(BASE62, $
      COLUMN=1, $
      MAP=1, $
      TITLE='Type and Style', $
      UVALUE='BASE17')

  Btns13400 = [ $
    'Linear ', $
    'Logarithmic' ]
  BGROUP88 = CW_BGROUP( BASE17, Btns13400, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Type', $
      UVALUE='BGROUP88',$
      SET_VALUE=!Y.TYPE)

  Btns13402 = [ $
    'Rounded', $
    'Exact', $
    'Extend', $
    'None', $
    'No Box', $
    'Inhibit Minimum = 0' ]
  BGROUP89 = CW_BGROUP( BASE17, Btns13402, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Style', $
      UVALUE='BGROUP89',$
      SET_VALUE=!Y.STYLE)


  Btns13404 = [ $
    'None', $
    'Solid', $
    'Dotted', $
    'Dashed', $
    'Dash Dot', $
    'Dash Dot Dot Dot', $
    'Long Dashes' ]
  BGROUP90 = CW_BGROUP( BASE62, Btns13404, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Gridlines', $
      UVALUE='BGROUP90',$
      SET_VALUE=(!Y.GRIDSTYLE+1)*!Y.TICKLEN)


  BASE3 = WIDGET_BASE(MAINxy, $
      ROW=1, $
      XPAD=235, $
      MAP=1, $
      TITLE='Ok and Cancel', $
      UVALUE='BASE3')

  BUTTON4 = WIDGET_BUTTON( BASE3, $
      UVALUE='BUTTON4', $
      VALUE='Ok')

  BUTTON5 = WIDGET_BUTTON( BASE3, $
      UVALUE='BUTTON5', $
      VALUE='Cancel')


  WIDGET_CONTROL, MAINxy, /REALIZE
  WIDGET_CONTROL,TEXT68, SET_TEXT_SELECT=[0,0]
  WIDGET_CONTROL,TEXT68, /INPUT_FOCUS, GET_VALUE=oval
  WIDGET_CONTROL,TEXT68, SET_TEXT_SELECT=[0,strlen( oval )]

  XMANAGER, 'MAINxy', MAINxy, /MODAL

; Restore !X, !Y, !P on Cancel
  if (XPL_.ok eq 0) then begin
    !X   = Xsave
    !Y   = Ysave
    !P   = Psave
    tv, RESTORE_                                      ; Restore original plot
    XPLOT_, X=DATA_.X, Y=DATA_.Y, $                   ; Update display
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with ENTRY settings
  endif
END
;*******************************************************************************
;     END: XPlot X- and Y-AXIS SETTINGS widgets
;*******************************************************************************

;*******************************************************************************
;   BEGIN: XPlot SETTINGS widgets
;*******************************************************************************
PRO MAINset_Event, Event

  common XPLOT

  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev,GET_VALUE=val

  BG_ck = STRMID(Ev,0,6)
  if (BG_ck eq 'BGROUP') then begin
      if (val ne Event.Value) then return
  endif

  CASE Ev OF

  'BUTTON67': BEGIN
    XPL_TXT, GROUP=Event.TOP      ;Modify TEXT settings
    WIDGET_CONTROL, Event.ID, /SHOW
    END
  'BUTTON68': BEGIN
    XPL_XY,  GROUP=Event.TOP      ;Modify X-/Y-Axis settings
    WIDGET_CONTROL, Event.ID, /SHOW
    END
  'BUTTON84': BEGIN
    WSHOW
    XY   = MRK_RECT(/HELP,/DATA,/STATUS)
    Xrng = REFORM(XY(0,*)) & Xrng=Xrng(SORT(Xrng))
    Yrng = REFORM(XY(1,*)) & Yrng=Yrng(SORT(Yrng))
    !X.RANGE = Xrng
    !Y.RANGE = Yrng
    !X.STYLE = 1
    !Y.STYLE = 1
    END
  'BGROUP69': !P.LINESTYLE = val            ;Line Style
  'BUTTON58': BEGIN                         ;Select Color Palette
      XLOADCT
      RETURN
      END
  'BUTTON59': BEGIN                         ;Select Background Color
      P_MULTI_SAVE = !P.MULTI(0)            ; via GET_XPALETTE
      P_Bkd        = GET_XPALETTE()
      !P.BACKGROUND= P_Bkd
      !P.MULTI(0)  = P_MULTI_SAVE
      WIDGET_CONTROL, Event.ID, /SHOW
      SL_ID = WIDGET_INFO( Event.ID, /SIBLING )
      WIDGET_CONTROL, SL_ID, SET_VALUE= P_Bkd
      END
  'SLIDER60': !P.BACKGROUND = Event.Value   ; via a slider
  'BUTTON61': BEGIN                         ;Select Foreground Color
      P_MULTI_SAVE = !P.MULTI(0)            ; via GET_XPALETTE
      P_color      = GET_XPALETTE()
      !P.COLOR     = P_color
      !P.MULTI(0)  = P_MULTI_SAVE
      WIDGET_CONTROL, Event.ID, /SHOW
      SL_ID = WIDGET_INFO( Event.ID, /SIBLING )
      WIDGET_CONTROL, SL_ID, SET_VALUE= P_color
      END
  'SLIDER62': !P.COLOR = Event.Value        ; via a slider
  'BGROUP63': BEGIN                         ;PostScript settings
      XPL_.PS.Preview   = 0
      CASE Val OF
      0: XPL_.PS.Type = 0
      1: XPL_.PS.Type   = 1
      2: BEGIN
         XPL_.PS.Type   = 1
         XPL_.PS.Preview= 1
         END
      ELSE: Message,'Unknown button pressed'
      ENDCASE
      RETURN
      END
  'BGROUP81': BEGIN                         ;Select Plotting symbol
      if (val eq 8) then !P.PSYM=10 $
      else !P.PSYM = val
      END
  'BUTTON74': BEGIN                         ; Event for Ok
      XPL_.ok = 1
      WIDGET_CONTROL, Event.Top, /DESTROY
      RETURN
      END
  'BUTTON75': BEGIN                         ; Event for Cancel
      XPL_.ok = 0
      WIDGET_CONTROL, Event.Top, /DESTROY
      RETURN
      END
  ENDCASE

  tv, RESTORE_                                      ; Restore original plot
  XPLOT_, X=DATA_.X, Y=DATA_.Y, $                   ; Update display
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with NEW settings
END


pro XPL_SET, GROUP=Group

  common XPLOT

; Save !X, !Y, !P settings in case of Cancel
  Xsave  = !X
  Ysave  = !Y
  Psave  = !P

  OS = STRUPCASE(STRMID(!VERSION.OS,0,3))
  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAINset = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      TITLE='XPlot Settings', $
      UVALUE='MAINset')

  BASE53 = WIDGET_BASE(MAINset, $
      ROW=1, $
      MAP=1, $
      UVALUE='BASE53')

  BASE70 = WIDGET_BASE(BASE53, $
      COLUMN=1, $
      MAP=1, $
      TITLE='Plot', $
      UVALUE='BASE70')

  BASE4 = WIDGET_BASE(BASE70, $
      COLUMN=1, $
      MAP=1, $
      UVALUE='BASE4')

  BUTTON67 = WIDGET_BUTTON( BASE4, $
      UVALUE='BUTTON67', $
      VALUE='Text')

  BUTTON68 = WIDGET_BUTTON( BASE4, $
      UVALUE='BUTTON68', $
      VALUE='X- and Y-Axis')

  BUTTON84 = WIDGET_BUTTON( BASE4, $
      UVALUE='BUTTON84', $
      VALUE='Select Region')

  BASE7 = WIDGET_BASE(BASE70, $
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

  if (OS eq 'WIN') then YPAD = 8 else YPAD = 12
  BASE87 = WIDGET_BASE(BASE53, $
      ROW=1, $
      YPAD=YPAD, $
      MAP=1, $
      TITLE='PSYM', $
      UVALUE='BASE87')


  Btns661 = [ $
    'None', $
    '+', $
    '*', $
    '.', $
    'Diamond', $
    'Triangle', $
    'Square', $
    'X', $
    'Histogram' ]
  BGROUP81 = CW_BGROUP( BASE87, Btns661, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='Plotting Symbol', $
      UVALUE='BGROUP81',$
      SET_VALUE=!P.PSYM<(n_elements(Btns661)-1))


  if (OS eq 'WIN') then YPAD = 8 else YPAD = 14
  BASE64 = WIDGET_BASE(BASE53, $
      COLUMN=1, $
      YPAD=YPAD, $
      MAP=1, $
      TITLE='Color and Output', $
      UVALUE='BASE64')

  BASE16 = WIDGET_BASE(BASE64, $
      COLUMN=1, $
      YPAD=5, $
      FRAME=1, $
      MAP=1, $
      TITLE='Color', $
      UVALUE='BASE16')

  BUTTON58 = WIDGET_BUTTON( BASE16, $
      UVALUE='BUTTON58', $
      VALUE='Color Palette')

  if OS eq 'WIN' then YPAD=15 $
  else YPAD = 10
  BASE38 = WIDGET_BASE(BASE16, $
      ROW=1, $
      YPAD=YPAD, $
      MAP=1, $
      TITLE='Fgd/Bgd Settings', $
      UVALUE='BASE38')

  BASE44 = WIDGET_BASE(BASE38, $
      COLUMN=1, $
      MAP=1, $
      TITLE='Background', $
      UVALUE='BASE44')

  BUTTON59 = WIDGET_BUTTON( BASE44, $
      UVALUE='BUTTON59', $
      VALUE='Background Color')

   SLIDER60 = WIDGET_SLIDER( BASE44, $
      MAXIMUM=!D.N_COLORS-1L, $
      MINIMUM=0L, $
      TITLE='Background Index', $
      UVALUE='SLIDER60', $
      VALUE=!P.BACKGROUND)


  BASE41 = WIDGET_BASE(BASE38, $
      COLUMN=1, $
      MAP=1, $
      TITLE='Foreground', $
      UVALUE='BASE41')

  BUTTON61 = WIDGET_BUTTON( BASE41, $
      UVALUE='BUTTON61', $
      VALUE='Foreground Color')

  SLIDER62 = WIDGET_SLIDER( BASE41, $
      MAXIMUM=!D.N_COLORS-1L, $
      MINIMUM=0L, $
      TITLE='Foreground Index', $
      UVALUE='SLIDER62', $
      VALUE=!P.COLOR)

  if OS eq 'WIN' then YPAD=18 $
  else YPAD = 10
  BASE17 = WIDGET_BASE(BASE64, $
      COLUMN=1, $
      YPAD=YPAD, $
      MAP=1, $
      TITLE='Output', $
      UVALUE='BASE17')

  Btns13313 = [ $
    'Normal ', $
    'Encapsulated ', $
    'Encapsulated with Interchange Preview' ]
  BGROUP63 = CW_BGROUP( BASE17, Btns13313, $
      COLUMN=1, $
      EXCLUSIVE=1, $
      FRAME=1, $
      LABEL_TOP='PostScript Output', $
      UVALUE='BGROUP63',$
      SET_VALUE=XPL_.PS.Type+XPL_.PS.Preview)

  BASE73 = WIDGET_BASE(MAINset, $
      ROW=1, $
      XPAD=200, $
      MAP=1, $
      UVALUE='BASE73')

  BUTTON74 = WIDGET_BUTTON( BASE73, $
      UVALUE='BUTTON74', $
      VALUE='Ok')

  BUTTON75 = WIDGET_BUTTON( BASE73, $
      UVALUE='BUTTON75', $
      VALUE='Cancel')


  WIDGET_CONTROL, MAINset, /REALIZE

  XMANAGER, 'MAINset', MAINset, /MODAL

; Restore !X, !Y, !P on Cancel
  if (XPL_.ok eq 0) then begin
    !X   = Xsave
    !Y   = Ysave
    !P   = Psave
    tv, RESTORE_                                      ; Restore original plot
    XPLOT_, X=DATA_.X, Y=DATA_.Y, $                   ; Update display
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    with ENTRY settings
  endif
END
;*******************************************************************************
;     END: XPlot SETTINGS widgets
;*******************************************************************************


;*******************************************************************************
;   BEGIN: XPlot MAIN MENU widgets
;*******************************************************************************
PRO PDMENUxp_Event, Event

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

  'File.New': BEGIN
    if (XPL_.PS.closed eq 0) then begin
         rp = YNCANCEL(['Discard current PostScript file:',$
                         XPL_.PS.filename+'?'],TITLE='XPlot WARNING')
         CASE rp OF
              1:BEGIN
                   X_save    = !X                          ;Bugfix, 6/20/95, Closing
                   Y_save    = !Y                          ; an old print file may
                   P_save    = !P                          ; overwrite existing plot
                   DEVICE_MGR, Printer, CLOSE=2, /SILENT   ; settings (e.g. !P.clip)
                   !X        = X_save
                   !Y        = Y_save
                   !P        = P_save
                   XPL_.PS.closed      = 2
                   XPL_.PS.filename    = ''
                   XPL_.PS.exist       = 0
                END
              0:
             -1:return
         ENDCASE
    endif

    if (XPL_.PS.Currpath eq '') then XPL_.PS.Currpath = filepath('',/TMP)
NF: fn = PICKFILE(PATH=XPL_.PS.Currpath, FILTER='*.'+ext(XPL_.PS.type),$
                   TITLE='Select/Enter NEW PostScript filename')
    if (fn eq '') then return


    VERSION_OS = STRLOWCASE(STRMID(!VERSION.OS,0,3))
    case VERSION_OS of
         'win'     : sep = '\'
         'vms'     : sep = ']'
         'mac'     : sep = ':'
         else      : sep = '/'
    endcase
    pos  = rstrpos(fn,sep)
    nlen = strlen(fn)-(pos+1)
    name = strmid(fn,pos+1,nlen)
    path = strmid(fn,0,pos+1)

    fexist    = FINDFILE(fn,COUNT=nEXIST)
    if (nEXIST gt 0) then begin
         rp   = YNCANCEL('Do you want to replace the existing '+name+'?',$
                        TITLE='XPlot WARNING')
         CASE rp OF
              1    :
              0    : goto, NF
             -1    : return
         ENDCASE
    endif

    XPL_.PS.Currpath    = path
    XPL_.PS.filename    = fn
    XPL_.PS.closed      = 0
    XPL_.PS.exist       = 0
    END

  'File.Close': BEGIN
    CASE XPL_.PS.closed OF
         0: BEGIN
              X_save    = !X                          ;save current plot settings
              Y_save    = !Y
              P_save    = !P
              XPL_.PS.closed      = 1
              XPL_.PS.exist       = 1
              DEVICE_MGR, Printer, CLOSE=XPL_.PS.CLOSED, /SILENT
              print,'Closed PostScript file:'+XPL_.PS.filename
              !X        = X_save
              !Y        = Y_save
              !P        = P_save
            END
         1: xmsg,['Current PostScript file:',$
                     XPL_.PS.filename,$
                     'is already closed.'],TITLE='XPlot Info'
         2: xmsg,['No PostScript file currently exists.'],TITLE='XPlot Info'
    ENDCASE
    END

  'File.Save': BEGIN         ; Update PRINTER file

    if (!P.MULTI(0) eq (n_plot-1)) then begin         ;single plots or 1st plot
                                                      ;of a multiple plot/page PS file
         if (XPL_.PS.closed eq 0) then begin
              X_save    = !X                          ;save current plot settings
              Y_save    = !Y
              P_save    = !P
              DEVICE_MGR, Printer, /CLOSE
              !X        = X_save
              !Y        = Y_save
              !P        = P_save
         endif else XPL_.PS.filename   = TMPFILE(prefix,suffix,5)

         XPL_.PS.closed      = 0
         XPL_.PS.exist       = 0
    endif else begin
         XPL_.PS.closed      = 0
         XPL_.PS.exist       = 1
    endelse

    d_display = !D.NAME

    Psave = !P          ; Save system variables associated with display
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

    XPLOT_, X=DATA_.X, Y=DATA_.Y, DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys

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
         xmsg, 'Cannot print Encapsulated PostScript files.',TITLE='XPlot ERROR'
         return
    endif

    CASE XPL_.PS.closed OF
         0: BEGIN
              X_save    = !X                          ;save current plot settings
              Y_save    = !Y
              P_save    = !P
              XPL_.PS.closed      = 1
              XPL_.PS.exist       = 1
              DEVICE_MGR, Printer, /CLOSE, /SILENT, /HARDCOPY
              print,'Closed PostScript file:'+XPL_.PS.filename
              !X        = X_save
              !Y        = Y_save
              !P        = P_save
            END
         1: PRINT_FILE, XPL_.PS.filename
         2: xmsg,['No PostScript file currently exists.'],TITLE='XPlot Info'
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
    XPL_SET, GROUP=Event.TOP
    WIDGET_CONTROL, Event.ID, /SHOW
    END
  'Undo': BEGIN
    !X   = XPL_.Undo.X
    !Y   = XPL_.Undo.Y
    !P   = XPL_.Undo.P

    tv, RESTORE_                                      ; Restore original plot
    XPLOT_, X=DATA_.X, Y=DATA_.Y, $                   ; Update display with
         DX=DATA_.DX, DY=DATA_.DY, _EXTRA=USER_keys   ;    ORIGINAL settings

    END
  'Help.Online Help': BEGIN
    XPL_HELP, GROUP=Event.TOP
    END
  'Help.About': BEGIN
    XPL_ABOUT, GROUP=Event.TOP
    END
  ENDCASE

END


PRO MAINxp_Event, Event


  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

  CASE Ev OF

  ; Event for XPlot PDMenu
  'PDMENUxp': PDMENUxp_Event, Event
  ENDCASE
END



pro XPLOT, X, Y, DX, DY, LANDSCAPE=Landscape, PORTRAIT=Portrait,$
         WINDOW=Window, ANONYMOUS_=Dummy_, _EXTRA=USER_keys1, GROUP=Group, $
         RESET=Reset

         common XPLOT

         NPar = N_PARAMS()
         if (NPar eq 0) or (NPar gt 4) then begin
              XPL_HELP
              return
         endif

         Nundef    = (N_ELEMENTS(X) eq 0) + (N_ELEMENTS(Y) eq 0) $
                   + (N_ELEMENTS(DX)eq 0) + (N_ELEMENTS(DY)eq 0)
         if NPar ne (4-Nundef) then message,'One or more arrays UNDEFINED.'

         if N_ELEMENTS(X) eq 1 then $
              message,'Not enough points to plot.'


         if (!D.N_COLORS gt 256) then DEVICE, DECOMPOSED=0

;   Reset system variables is USER specifies

         if keyword_set(RESET) then begin
              !P.title       = ''
              !P.subtitle    = ''
              !P.multi       = 0
              !P.psym        = 0
              !P.background  = 0
              !P.color       = !D.N_COLORS-1
              !X.type        = 0
              !X.title       = ''
              !X.style       = 0
              !X.gridstyle   = 0
              !X.range       = 0
              !Y.type        = 0
              !Y.title       = ''
              !Y.style       = 0
              !Y.gridstyle   = 0
              !Y.range       = 0
         endif

         IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

         junk   = { CW_PDMENU_S, flags:0, name:'' }

         Xsave  = !X
         Ysave  = !Y
         Psave  = !P

;   Unless USER specifies XTYPE and/or YTYPE keywords, default to LINEAR scale

         !X.type   = 0
         !Y.type   = 0

;   Check to see if XPL_ is defined

         if (N_ELEMENTS( XPL_ ) eq 0) or keyword_set(RESET) then begin

         ;    Reset the PostScript file
              d_display = !D.Name
              Printer   = 'ps'
              SET_PLOT,Printer
              DEVICE,/CLOSE
              SET_PLOT,d_display

         ;    Define the graphics keywords that the USER may specify either
         ;    by the command line or interactively through XPlot
         ;    pulldown menus.

              Tags = { Name:'', SysVar:'', SysIndex:0 }
              Tags = REPLICATE(Tags,21)

              Tags(*).Name = [$
                             'XRANGE'    , $
                             'XTYPE'     , $
                             'XSTYLE'    , $
                             'XGRIDSTYLE', $
                             'XTICKLEN'  , $
                             'XTITLE'    , $
                             'XCHARSIZE' , $
                             'YRANGE'    , $
                             'YTYPE'     , $
                             'YSTYLE'    , $
                             'YGRIDSTYLE', $
                             'YTICKLEN'  , $
                             'YTITLE'    , $
                             'YCHARSIZE' , $
                             'TITLE'     , $
                             'SUBTITLE'  , $
                             'LINESTYLE' , $
                             'PSYM'      , $
                             'CHARSIZE'  , $
                             'COLOR'     , $
                             'BACKGROUND'  ]
              Tags(*).SysVar = [$
                             '!X'        , $
                             '!X'        , $
                             '!X'        , $
                             '!X'        , $
                             '!X'        , $
                             '!X'        , $
                             '!X'        , $
                             '!Y'        , $
                             '!Y'        , $
                             '!Y'        , $
                             '!Y'        , $
                             '!Y'        , $
                             '!Y'        , $
                             '!Y'        , $
                             '!P'        , $
                             '!P'        , $
                             '!P'        , $
                             '!P'        , $
                             '!P'        , $
                             '!P'        , $
                             '!P'          ]

              ;    Determine the corresponding indices into IDL's
              ;    system variables

              i=0
              Xtags= TAG_NAMES(!X)
              repeat begin
                   xt   = strmid(Tags(i).Name,1,strlen(Tags(i).Name)-1)
                   h    = where(Xtags eq xt)
                   Tags(i).SysIndex = h(0)
                   i    = i+1
              endrep until (Tags(i).SysVar ne '!X')

              Ytags= TAG_NAMES(!Y)
              repeat begin
                   yt   = strmid(Tags(i).Name,1,strlen(Tags(i).Name)-1)
                   h    = where(Ytags eq yt)
                   Tags(i).SysIndex = h(0)
                   i    = i+1
              endrep until (Tags(i).SysVar ne '!Y')

              Ptags= TAG_NAMES(!P)
              repeat begin
                   pt   = Tags(i).Name
                   h    = where(Ptags eq pt)
                   Tags(i).SysIndex = h(0)
                   i    = i+1
              endrep until (i eq n_elements(Tags))

              hX_xpl    = WHERE( Tags(*).SysVar eq '!X',nX )    ;  !X indices
              hX_sys    = Tags(hX_xpl).SysIndex

              hY_xpl    = WHERE( Tags(*).SysVar eq '!Y',nY )    ;  !Y indices
              hY_sys    = Tags(hY_xpl).SysIndex

              hP_xpl    = WHERE( Tags(*).SysVar eq '!P',nP )    ;  !P indices
              hP_sys    = Tags(hP_xpl).SysIndex

              here_tag  = { X:hX_xpl, Y:hY_xpl, P:hP_xpl, $
                            nX:nX,    nY:nY,    nP:nP     }
              here_sys  = { X:hX_sys, Y:hY_sys, P:hP_sys, $
                            nX:nX,    nY:nY,    nP:nP     }

              XPL_ = { X:!X, Y:!Y, P:!P, $            ;Printer file defaults
                        Tags:Tags, $                  ;Keywords modified interactively
                        here_tag:here_tag, $
                        here_sys:here_sys, $
                        Undo:{ X:!X, Y:!Y, P:!P }, $  ;Undo defaults
                        PS:{ Type:0,    $             ;PostScript defaults
                             Preview:0, $             ;Add Preview to encapsulated PS
                             Exist:0,   $             ;0=PS doesn't exist, 1=PS does exist
                             Closed:2,  $             ;0=open, 1=close, 2=deleted
                             Filename:'',$            ;Filename of current PS file
                             Currpath:'',$            ;Current path to search
                             Orientation:'LANDSCAPE' } , $
                        ok:0 }
              XPL_.P.color       = 0
              XPL_.P.background  = 255

         endif

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

;   Inspect any EXTRA USER keywords specified on command line call to XPLOT

         USER_ = { nkeys:0 }
         for i=0,ntags-1 do begin

              ;    Make sure USER has not defined a color index out of range

              if (Utags(i) eq 'BACKGROUND') or (Utags(i) eq 'COLOR') then $
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

;   Create a new window if then number of plots left,!P.MULTI(0) = 0

         if !P.MULTI(0) eq 0 then begin
              if (N_ELEMENTS( Window ) eq 0) then Window = !D.WINDOW > 0
              DEVICE_MGR, d_display, ORIENT=Orientation, WINDOW=Window
         endif

;   Save existing plot window

         RESTORE_ = TVRD()

;   Make our first plot

         XPLOT_, X=X, Y=Y, DX=DX, DY=DY, /NEW, _EXTRA=USER_keys
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

  MAINxp = WIDGET_BASE(GROUP_LEADER=Group, $
      ROW=1, $
      MAP=1, $
      TITLE='XPlot Main Menu', $
      UVALUE='MAINxp')

  MenuDesc13277 = [ $
      { CW_PDMENU_S,       1, 'File' }, $ ;        0
        { CW_PDMENU_S,       0, 'New' }, $ ;        1
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


  PDMENUxp = CW_PDMENU( MAINxp, MenuDesc13277, /RETURN_FULL_NAME, $
      UVALUE='PDMENUxp')

  WIDGET_CONTROL, MAINxp, /REALIZE

  XMANAGER, 'MAINxp', MAINxp, /MODAL

         iss = WSHOW_ACTIVE(D_Window)

         if (XPL_.ok eq 0) then begin
              DEVICE_MGR, !D.NAME, WINDOW=Window, /CLOSE
              !P.MULTI(0)=0
         endif

;   Restore IDL's system variables
;   We cannot just restore the ENTIRE structure, because IDL updates some
;   of the tags everytime a plot is made.  Only save the ones we modify
;   and would like to restore when this routine terminates.

         Xtype= !X.type
         Ytype= !Y.type
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

         !X.type        = Xtype                  ;We must preserve the axis type
         !Y.type        = Ytype                  ; in case XOplot is called, 5/25/95
         XPL_.X.type    = Xtype
         XPL_.Y.type    = Ytype

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
;     END: XPlot MAIN MENU widgets
;*******************************************************************************
