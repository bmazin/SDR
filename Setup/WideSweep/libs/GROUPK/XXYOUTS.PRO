;
; NAME:
;        XXYOUTS
;
; PURPOSE:
;        This procedure is a "superset" of OPLOT and OPLOTERR with the
;        addtional feature of allowing the USER to interactively change
;        many of its settings "on the fly" (e.g. line style, plotting
;        symbol, etc.) via various widget menus.  It accepts ALL of the
;        keywords used by OPLOT and OPLOTERR and some additional keywords
;        described below.  The USER may also print the plot directly
;        from the main widget menu, (it can handle multiple plots/window).
;
; CATEGORY:
;        Plotting and Widgets.
;
; CALLING SEQUENCE:
;
;        XXYOUTS, [X,] Y, [DX, [DY]]
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
;        NO_MENU:  Set this keyword to suppress the appearance of a widget
;                  menu after the plot has been made (0=Default).
;
;        NO_HARDCOPY:   Normally, when you press the Print Plot Window button,
;                  the printer output is sent directly to the printer. Set this
;                  keyword to suppress sending the printer output to the
;                  printer. (0=Default)
;
; OPTIONAL OUTPUTS:
;        The USER may select to send the plot to the printer if the NO_HARDCOPY
;        keyword is not set. A temporary printer output file is created for
;        each plot created.  This file is deleted if the USER selects the
;        Delete Plot Window button and kept if the Quit button is selected.
;
; RESTRICTIONS:
;        You MUST call XPLOT before calling this routine.  (Do NOT try to
;        compile this routine before running XPLOT)
;
;        If you are interested in sending the plots to the printer, do not
;        mix usage of XPLOT, PLOT, PLOTERR and XXYOUTS, OPLOT, OPLOTERR.  XPLOT
;        and XXYOUTS cannot keep track of plots made using the PLOT, PLOTERR,
;        OPLOT or OPLOTERR routines.
;
; PROCEDURE:
;        Use this routine EXACTLY as you would use OPLOT or OPLOTERR.  This
;        routine handles printing multiple plots by creating a temporary
;        printer output file everytime the USER selects the Quit button.
;        If you do NOT want this file deleted, then select the Quit button
;        to exit this routine.  Selecting Delete Plot Window will DELETE
;        any temporary printer output file created.
;
; EXAMPLE:
;        x    = findgen(100)
;        y    = sin(x/20)
;        y2   = cos(x/10)
;
;        XPLOT,x,y,TITLE='Title',XTITLE='X-Axis',YTITLE='Y-Axis'
;        XXYOUTS,x,y2
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, January 1995.
;        01-FEB-1995    Added the NO_MENU keyword. (1.01)
;        02-FEB-1995    Save printer output system variables to XPLOT
;                       common. (1.20)
;
pro XXYOUTS, X, Y, String, TEXT_OBJECT=Text_object, $
              ANONYMOUS_=Dummy_, _EXTRA=USER_keys

         common XPLOT, XPL_

;   Check the number of parameters

         NP = N_PARAMS()
         if (NP ne 1) and (NP ne 3) then $
              message,'Must be called with 1 or 3 parameters: '+$
                             '[X, Y, ] String

         if NP eq 1 then String = X

         if N_ELEMENTS(TEXT_OBJECT) eq 0 then Text_object='the text'

;   Check to see if XPL_ is defined

         if N_ELEMENTS( XPL_ ) eq 0 then $
              message,'XPLOT must be called first.'

;   Check our keywords for user definitions otherwise use defaults

         printer   = 'PS'
         d_display = !D.NAME
         if (d_display ne 'WIN') AND (d_display ne 'X') then $
              message,'Sorry, device must be set to display: WIN or X'

         if NP eq 1 then begin
              d_window  = !D.WINDOW
              xmsg,['Position mouse cursor within plot area',$
                    'where you wish '+Text_object+' to be drawn',$
                    'and click mouse button 1.'],$
                    TITLE='XXYOUTS Query',/NOBUTTON, MSG_ID=Msg_ID,$
                    /LEFT, /TOP
              iss = WSHOW_ACTIVE( d_window )
              cursor, X, Y, /DATA, /DOWN
              WIDGET_CONTROL,Msg_ID,/DESTROY
              iss = WSHOW_ACTIVE( d_window )
         endif

         XYOUTS, X, Y, String, _EXTRA=USER_keys

         P_save = !P
         X_save = !X
         Y_save = !Y

         DEVICE_MGR, Printer, /APPEND, $
                   ORIENTATION=Orientation, /SILENT

         !P = XPL_.P         ;Restore system variables associated
         !X = XPL_.X         ;with the printer output from the
         !Y = XPL_.Y         ;previous plot

         if NP eq 3 then XYOUTS, X, Y, String, _EXTRA=USER_keys $
         else XYOUTS, String, _EXTRA=USER_keys

         XPL_.P    = !P      ;Save the system variables associated
         XPL_.X    = !X      ;with the printer output for the
         XPL_.Y    = !Y      ;next plot

         SET_PLOT, d_display

         !P = P_save    ;Restore !X and !Y system variables
         !X = X_save    ;associated with the display
         !Y = Y_save
         wshow
end
