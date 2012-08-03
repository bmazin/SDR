; $Id: xsurface.pro,v 1.2 1993/06/22 16:46:50 steve Exp $

; Copyright (c) 1991-1993, Research Systems, Inc.  All rights reserved.
;        Unauthorized reproduction prohibited.
;+
; NAME:
;        XSURFACE
;
; PURPOSE:
;        This routine provides a graphical interface to the SURFACE and
;        SHADE_SURFACE commands.  Different controls are provided to change
;        the viewing angle and other plot parameters.  The command used to
;        generate the resulting surface plot is shown in a text window.
;
; CATEGORY:
;        Widgets.
;
; CALLING SEQUENCE:
;        XSURFACE, Data [, X, Y ]
;
; INPUT PARAMETERS:
;        Data:     The two-dimensional array to display as a wire-mesh or
;             shaded surface.
;
; OPTIONAL INPUT PARAMETERS:
;
;           X:  A vector or two-dimensional array specifying the
;               X coordinates of the grid. If this argument is a
;               vector, each element of X specifies the X coordinate
;               for a column of Z (e.g., X(0) specifies the X coor-
;               dinate for Z(0,*)). If X is a two-dimensional array,
;               each element of X specifies the X coordinate of the
;               corresponding point in Z (Xij specifies the X coordi-
;               nate for Zij).
;
;               This argument is converted to single-precision
;               floating-point before plotting.
;
;           Y:  A vector or two-dimensional array specifying the
;               Y coordinates of the grid. If this argument is a
;               vector, each element of Y specifies the Y coordinate
;               for a row of Z (e.g., Y(0) specifies the Y coordi-
;               nate for Z(*,0)). If Y is a two-dimensional array,
;               each element of Y specifies the Y coordinate of the
;               corresponding point in Z (Yij specifies the Y coordi-
;               nate for Zij).
;
;               This argument is converted to single-precision
;               floating-point before plotting.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;          AX:  This keyword specifies the angle of rotation,
;               about the X axis, in degrees towards the viewer.
;               This keyword is effective only if !P.T3D is not set.
;               If !P.T3D is set, the three-dimensional to two-
;               dimensional transformation used by SURFACE is taken
;               from the 4 by 4 array !P.T.
;
;               The surface represented by the two-dimensional
;               array is first rotated, AZ (see below) degrees about
;               the Z axis, then by AX degrees about the X axis,
;               tilting the surface towards the viewer (AX > 0), or
;               away from the viewer.
;
;               The AX and AZ keyword parameters default to +30
;               degrees if omitted and !P.T3D is 0.
;
;               The three-dimensional to two-dimensional trans-
;               formation represented by AX and AZ, can be saved in
;               !P.T by including the SAVE keyword.
;
;           AZ: This keyword specifies the counterclockwise
;               angle of rotation about the Z axis. This keyword is
;               effective only if !P.T3D is not set. The order of
;               rotation is AZ first, then AX.
;
;           BOTTOM:    The color index used to draw the bottom surface.
;               If not specified, the bottom is drawn with the same
;               color as the top.
;
;           HORIZONTAL:    A keyword flag which if set causes SURFACE to
;               only draw lines across the plot perpendicular to the
;               line of sight. The default is for SURFACE to draw
;               both across the plot and from front to back.
;
;           LEGO:    Set this keyword to produce "Lego" style plots.
;               Each data value is rendered as a box covering the XY
;               extent of the cell and with a height proportional to
;               the Z value.
;
;           LOWER_ONLY:    Set this keyword to draw only the lower surface
;               of the object. By default, both surfaces are drawn.
;
;           MAX_VALUE:    The largest data value to be plotted. Data
;               larger than this value are treated as missing data
;               and are not plotted.
;
;           SAVE:   Set this keyword to save the 3D to 2D transfor-
;               mation matrix established by SURFACE in the system
;               variable field !P.T. Use this keyword when combining
;               the output of SURFACE with additional output from
;               other routines in the same plot.
;
;               When used with AXIS, the SAVE keyword parameter
;               saves the scaling parameters established by the call
;               in the appropriate axis system variable, !X, !Y, or
;               !Z. This causes subsequent overplots to be scaled to
;               the new axis.
;
;               Example
;
;               To display a two-dimensional array using SUR-
;               FACE, and to then superimpose contours over the sur-
;               face (this example assumes that !P.T3D is zero, its
;               default value.), enter the following commands:
;
;               SURFACE, Z, /SAVE	Make a surface plot and save the
;               transformation.
;
;               CONTOUR, Z, /NOERASE, /T3D	Make contours, don't erase, use the
;               3D to 2D transform placed in !P.T
;               by SURFACE.
;
;               To display a surface and to then display a flat
;               contour plot, registered above the surface:
;
;               SURFACE, Z, /SAVE	Make the surface, save transform.
;
;               CONTOUR, Z, /NOERASE, /T3D, ZVALUE=1.0
;               Now display a flat contour plot, at
;               the maximum Z value (normalized
;               coordinates). You can display the
;               contour plot below the surface with
;               by using a ZVALUE of 0.0.
;
;           SHADES:    This keyword allows user-specified coloring of
;               the mesh surfaces. Set this keyword to an array that
;               specifies the color index of the lines emanating
;               from each data point toward the top and right.
;
;           SKIRT:    This keyword represents a Z-value at which to
;               draw a skirt around the array. The Z value is
;               expressed in data units. The default is no skirt.
;
;               If the skirt is drawn, each point on the four
;               edges of the surface is connected to a point on the
;               skirt which has the given Z value, and the same X
;               and Y values as the edge point. In addition, each
;               point on the skirt is connected to its neighbor.
;
;           UPPER_ONLY:    Set this keyword to draw only the upper surface
;               of the object. By default, both surfaces are drawn.
;
;           XTYPE:    Set this keyword to specify a logarithmic X
;               axis.
;
;           YTYPE:    Set this keyword to specify a logarithmic Y
;               axis.
;
;           ZAXIS:    This keyword specifies the placement of the Z
;               axis for the SURFACE plot.
;
;               By default, SURFACE draws the Z axis at the
;               upper left corner of the axis box. To suppress the Z
;               axis, use ZAXIS=-1 in the call. The position of the
;               Z axis is determined from the value of ZAXIS as fol-
;               lows: 1 = lower right, 2 = lower left, 3 = upper
;               left, and 4 = upper right.
;
;   Graphics Keywords Accepted
;
;       See Chapter 2, Graphics Keywords and System
;       Variables, for the description of graphics and plot-
;       ting keywords not listed above. BACKGROUND CHANNEL
;       CHARSIZE CHARTHICK CLIP COLOR DATA DEVICE FONT LINE-
;       STYLE NOCLIP NODATA NOERASE NORMAL POSITION SUBTITLE
;       T3D THICK TICKLEN TITLE XCHARSIZE XMARGIN XMINOR
;       XRANGE XSTYLE XTHICK XTICKLEN XTICKNAME XTICKS
;       XTICKV XTICK_GET XTITLE YCHARSIZE YMARGIN YMINOR
;       YRANGE YSTYLE YTHICK YTICKLEN YTICKNAME YTICKS
;       YTICKV YTICK_GET YTITLE ZCHARSIZE ZMARGIN ZMINOR
;       ZRANGE ZSTYLE ZTHICK ZTICKLEN ZTICKNAME ZTICKS
;       ZTICKV ZTICK_GET ZTITLE ZVALUE.
;
; KEYWORD PARAMETERS:
;        GROUP:    The widget ID of the widget that calls XSURFACE.  When this
;             keyword is specified, the death of the caller results in the
;             death of XSURFACE.
;
; SIDE EFFECTS:
;        The XMANAGER is initiated if it is not already running.
;
; RESTRICTIONS:
;        XSURFACE does not accept any of the keywords that the IDL command
;        SURFACE does.
;
; PROCEDURE:
;        Create and register the widget with the XMANAGER and then exit.
;
; MODIFICATION HISTORY:
;        Created from a template written by: Steve Richards, January, 1991.
;-

;------------------------------------------------------------------------------
;        procedure XSurface_draw
;------------------------------------------------------------------------------

PRO XSurface_draw

COMMON orientation, zrot, thedata, xrot, skirt, shade, axes, thedraw, $
              xmargin, ymargin, upper, commandid, $
              xbins, ybins, extra_keywords

WSET, thedraw

IF(shade EQ 0) THEN BEGIN
  IF(skirt EQ 0) THEN $
    SURFACE, thedata, $
              xbins,  $
              ybins,  $
              XSTYLE = axes, $
              YSTYLE = axes, $
              ZSTYLE = axes, $
              UPPER_ONLY = upper, $
              XMARGIN = xmargin, $
              YMARGIN = ymargin, $
              AZ = zrot, $
              AX = xrot, $
              _EXTRA=extra_keywords $
  ELSE SURFACE, thedata, $
              xbins,  $
              ybins,  $
              XSTYLE = axes, $
              YSTYLE = axes, $
              ZSTYLE = axes, $
              UPPER_ONLY = upper, $
              XMARGIN = xmargin, $
              YMARGIN = ymargin, $
              AZ = zrot, $
              AX = xrot, $
              SKIRT = MIN(thedata),$
              _EXTRA=extra_keywords
ENDIF ELSE BEGIN
  IF(skirt EQ 0) THEN $
    SHADE_SURF, thedata, $
              xbins,  $
              ybins,  $
              XSTYLE = axes, $
              YSTYLE = axes, $
              ZSTYLE = axes, $
              UPPER_ONLY = upper, $
              XMARGIN = xmargin, $
              YMARGIN = ymargin, $
              AZ = zrot, $
              AX = xrot, $
              _EXTRA=extra_keywords $
    ELSE SHADE_SURF, thedata, $
              xbins,  $
              ybins,  $
              XSTYLE = axes, $
              YSTYLE = axes, $
              ZSTYLE = axes, $
              UPPER_ONLY = upper, $
              XMARGIN = xmargin, $
              YMARGIN = ymargin, $
              AZ = zrot, $
              AX = xrot, $
              SKIRT = MIN(thedata), $
              _EXTRA=extra_keywords
ENDELSE

IF(shade EQ 0) THEN command = "SURFACE, data" $
ELSE command = "SHADE_SURF, data"
IF(xrot NE 30.0) THEN command = command + STRING(xrot, $
                             FORMAT = '(", AX = ",I3.3)')
IF(zrot NE 30.0) THEN command = command + STRING(zrot, $
                             FORMAT = '(", AZ = ",I3.3)')
IF(skirt NE 0) THEN command = command + ", /SKIRT"
IF(xmargin(0) NE 10.0) THEN $
         command = command + STRING(xmargin, $
         FORMAT = '(", XMARGIN = [",F4.1,", ",F4.1,"]")')
IF(ymargin(0) NE 4.0) THEN $
         command = command + STRING(ymargin, $
         FORMAT = '(", YMARGIN = [",F4.1,", ",F4.1,"]")')
IF(upper NE 0) THEN command = command + ", /UPPER_ONLY"
IF(axes NE 0) THEN command = command + $
         ", XSTYLE = 4, YSTYLE = 4, ZSTYLE = 4"

WIDGET_CONTROL, commandid, SET_VALUE = command

END


;------------------------------------------------------------------------------
;        procedure XSurface_ev
;------------------------------------------------------------------------------

PRO XSurface_ev, event

COMMON orientation, zrot, thedata, xrot, skirt, shade, axes, thedraw, $
              xmargin, ymargin, upper, commandid, $
              xbins, ybins, extra_keywords

WIDGET_CONTROL, event.id, GET_UVALUE = eventval  ;find the user value
                                       ;of the widget where
                                       ;the event occured
CASE eventval OF

  "       0": BEGIN
              zrot = (zrot + 15) mod 360
              IF(zrot LT 0) THEN zrot = 360 + zrot
              XSurface_draw
              WIDGET_CONTROL, event.id, SET_BUTTON = 0
               END

  "       1": BEGIN
              zrot = (zrot - 15) mod 360
              IF(zrot LT 0) THEN zrot = 360 + zrot
              XSurface_draw
              WIDGET_CONTROL, event.id, SET_BUTTON = 0
               END

  "       2": BEGIN
              xrot = (xrot - 15) mod 360
              IF(xrot LT 0) THEN xrot = 360 + xrot
              XSurface_draw
              WIDGET_CONTROL, event.id, SET_BUTTON = 0
               END

  "       3": BEGIN
              xrot = (xrot + 15) mod 360
              IF(xrot LT 0) THEN xrot = 360 + xrot
              XSurface_draw
              WIDGET_CONTROL, event.id, SET_BUTTON = 0
               END

  "       4": BEGIN     ;shrink
              xmargin = xmargin * 1.2
              ymargin = ymargin * 1.2
              XSurface_draw
              WIDGET_CONTROL, event.id, SET_BUTTON = 0
               END

  "       5": BEGIN     ;grow
              xmargin = xmargin * 0.8
              ymargin = ymargin * 0.8
              XSurface_draw
              WIDGET_CONTROL, event.id, SET_BUTTON = 0
               END

  "SKIRTON": IF(event.select EQ 1) THEN BEGIN
              skirt = 1
              XSurface_draw
              ENDIF

  "SKIRTOFF":  IF(event.select EQ 1) THEN BEGIN
              skirt = 0
              XSurface_draw
               ENDIF

  "SHADEOFF":  IF(event.select EQ 1) THEN BEGIN
              shade = 0
              XSurface_draw
               ENDIF

  "SHADEON":  IF(event.select EQ 1) THEN BEGIN
              shade = 1
              XSurface_draw
               ENDIF

  "AXESOFF":  IF(event.select EQ 1) THEN BEGIN
              AXES = 4
              XSurface_draw
               ENDIF

  "AXESON":  IF(event.select EQ 1) THEN BEGIN
              AXES = 0
              XSurface_draw
               ENDIF

  "UPPERON": IF(event.select EQ 1) THEN BEGIN
              upper = 0
              XSurface_draw
               ENDIF

  "UPPEROFF": IF(event.select EQ 1) THEN BEGIN
              upper = 1
              XSurface_draw
               ENDIF

  "XLOADCT": XLoadct, GROUP = event.top

  "XPALETTE": XPalette, GROUP = event.top

  "XMANTOOL": XMTool, GROUP = event.top

  "EXIT": WIDGET_CONTROL, event.top, /DESTROY

  ELSE:; MESSAGE, "Event User Value Not Found"

ENDCASE

END ;============= end of XSurface event handling routine task =============



;------------------------------------------------------------------------------
;        procedure XSurface
;------------------------------------------------------------------------------

PRO XSurface, DATA, X, Y, GROUP = GROUP, _EXTRA=Plot_keywords

COMMON orientation, zrot, thedata, xrot, skirt, shade, axes, thedraw, $
              xmargin, ymargin, upper, commandid, $
              xbins, ybins, extra_keywords

IF(XRegistered("XSurface")) THEN RETURN   ;only one instance of
                                       ;the XSurface widget
                                       ;is allowed.  If it is
                                       ;already managed, do
                                       ;nothing and return

np=n_params()
extra_keywords={ TITLE: '' }
if keyword_set( Plot_keywords ) then extra_keywords=Plot_keywords
thesize = SIZE(DATA)
case NP of
    1    : begin
              xbins= findgen(thesize(1))
              ybins= findgen(thesize(2))
           end
    2    : begin
              xbins= X
              ybins= findgen(thesize(2))
           end
    3    : begin
              xbins= X
              ybins= Y
           end
    else : message,'Must be called with 1-3 parameters: DATA [, X, Y]'
endcase
zrot = 30.
xrot = 30.
skirt = 0
shade = 0
axes = 0
xmargin = [10.0, 3.0]
ymargin = [4.0, 2.0]
upper = 0
commandid = 0L

XSurfacebase = WIDGET_BASE(TITLE = "XSurface", $
              /COLUMN)

XPdMenu, [    '"Done"                  EXIT',  $
              '"Tools"  {',             $
                        '"XLoadct"     XLOADCT', $
                        '"XPalette"    XPALETTE', $
                        '"XManagerTool" XMANTOOL', $
                        '}'],            $
          XSurfacebase

thebase = WIDGET_BASE(XSurfacebase, /ROW)

ver      = widget_info(/version)
case ver.style OF
'OPEN LOOK': BEGIN
           XSurfacepalette = WIDGET_BASE(thebase, $
                        /COLUMN, $
                        /FRAME, $
                        /EXCLUSIVE)
         END
ELSE:        BEGIN
           XSurfacepalette = WIDGET_BASE(thebase, $
                        /COLUMN, $
                        /FRAME)
         END
ENDCASE

controls = [                            $
              [                         $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 248B, 255B, 063B, 000B],   $
              [128B, 007B, 000B, 224B, 001B],   $
              [112B, 000B, 000B, 000B, 014B],   $
              [136B, 000B, 016B, 000B, 016B],   $
              [052B, 000B, 048B, 000B, 056B],   $
              [172B, 000B, 080B, 000B, 032B],   $
              [124B, 000B, 144B, 000B, 040B],   $
              [164B, 007B, 016B, 001B, 048B],   $
              [012B, 248B, 031B, 062B, 056B],   $
              [036B, 000B, 000B, 228B, 033B],   $
              [004B, 000B, 000B, 008B, 062B],   $
              [012B, 000B, 000B, 016B, 048B],   $
              [036B, 000B, 000B, 016B, 032B],   $
              [008B, 000B, 000B, 008B, 000B],   $
              [112B, 000B, 000B, 004B, 000B],   $
              [128B, 007B, 000B, 002B, 000B],   $
              [000B, 248B, 031B, 001B, 000B],   $
              [000B, 000B, 144B, 000B, 000B],   $
              [000B, 000B, 080B, 000B, 000B],   $
              [000B, 000B, 048B, 000B, 000B],   $
              [000B, 000B, 016B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B]   $
              ],                        $
;             dnz.bmdef
              [                         $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 252B, 255B, 031B, 000B],   $
              [128B, 007B, 000B, 224B, 001B],   $
              [112B, 000B, 000B, 000B, 014B],   $
              [008B, 000B, 008B, 000B, 017B],   $
              [028B, 000B, 012B, 000B, 044B],   $
              [004B, 000B, 010B, 000B, 053B],   $
              [020B, 000B, 009B, 000B, 062B],   $
              [012B, 128B, 008B, 224B, 037B],   $
              [028B, 124B, 248B, 031B, 048B],   $
              [132B, 039B, 000B, 000B, 036B],   $
              [124B, 016B, 000B, 000B, 032B],   $
              [012B, 008B, 000B, 000B, 048B],   $
              [004B, 008B, 000B, 000B, 036B],   $
              [000B, 016B, 000B, 000B, 016B],   $
              [000B, 032B, 000B, 000B, 014B],   $
              [000B, 064B, 000B, 224B, 001B],   $
              [000B, 128B, 248B, 031B, 000B],   $
              [000B, 000B, 009B, 000B, 000B],   $
              [000B, 000B, 010B, 000B, 000B],   $
              [000B, 000B, 012B, 000B, 000B],   $
              [000B, 000B, 008B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B]   $
              ],                        $
              ;upz.bm
              [                         $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 128B, 255B, 001B, 000B],   $
              [000B, 064B, 169B, 002B, 000B],   $
              [000B, 160B, 254B, 007B, 000B],   $
              [000B, 160B, 068B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 008B, 016B, 000B, 000B],   $
              [000B, 008B, 016B, 000B, 000B],   $
              [000B, 008B, 144B, 001B, 000B],   $
              [000B, 008B, 112B, 006B, 000B],   $
              [000B, 008B, 016B, 008B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 006B, 096B, 000B],   $
              [000B, 008B, 001B, 128B, 000B],   $
              [000B, 136B, 000B, 000B, 001B],   $
              [000B, 200B, 015B, 240B, 003B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 016B, 004B, 008B, 000B],   $
              [000B, 016B, 004B, 008B, 000B],   $
              [000B, 016B, 005B, 008B, 000B],   $
              [000B, 080B, 004B, 008B, 000B],   $
              [000B, 032B, 147B, 004B, 000B],   $
              [000B, 160B, 042B, 005B, 000B],   $
              [000B, 064B, 149B, 002B, 000B],   $
              [000B, 128B, 255B, 001B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B]   $
              ],                        $
              ;dnx.bm
              [                         $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 128B, 255B, 001B, 000B],   $
              [000B, 064B, 149B, 002B, 000B],   $
              [000B, 160B, 042B, 005B, 000B],   $
              [000B, 032B, 147B, 004B, 000B],   $
              [000B, 080B, 004B, 008B, 000B],   $
              [000B, 016B, 005B, 008B, 000B],   $
              [000B, 016B, 004B, 008B, 000B],   $
              [000B, 016B, 004B, 008B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 200B, 015B, 240B, 003B],   $
              [000B, 136B, 000B, 000B, 001B],   $
              [000B, 008B, 001B, 128B, 000B],   $
              [000B, 008B, 006B, 096B, 000B],   $
              [000B, 008B, 008B, 016B, 000B],   $
              [000B, 008B, 016B, 008B, 000B],   $
              [000B, 008B, 112B, 006B, 000B],   $
              [000B, 008B, 144B, 001B, 000B],   $
              [000B, 008B, 016B, 000B, 000B],   $
              [000B, 008B, 016B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 016B, 032B, 000B, 000B],   $
              [000B, 160B, 068B, 000B, 000B],   $
              [000B, 160B, 254B, 007B, 000B],   $
              [000B, 064B, 169B, 002B, 000B],   $
              [000B, 128B, 255B, 001B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B]   $
              ],                        $
              ;shrink.bm
              [                         $
              [000B, 000B, 008B, 000B, 000B],   $
              [000B, 000B, 008B, 000B, 000B],   $
              [000B, 000B, 073B, 000B, 000B],   $
              [000B, 000B, 042B, 000B, 000B],   $
              [000B, 000B, 028B, 000B, 000B],   $
              [000B, 000B, 008B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [128B, 255B, 255B, 255B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [132B, 000B, 000B, 000B, 033B],   $
              [136B, 000B, 000B, 000B, 017B],   $
              [144B, 000B, 000B, 000B, 009B],   $
              [191B, 000B, 000B, 000B, 253B],   $
              [144B, 000B, 000B, 000B, 009B],   $
              [136B, 000B, 000B, 000B, 017B],   $
              [132B, 000B, 000B, 000B, 033B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 000B, 000B, 000B, 001B],   $
              [128B, 255B, 255B, 255B, 001B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 008B, 000B, 000B],   $
              [000B, 000B, 028B, 000B, 000B],   $
              [000B, 000B, 042B, 000B, 000B],   $
              [000B, 000B, 073B, 000B, 000B],   $
              [000B, 000B, 008B, 000B, 000B],   $
              [000B, 000B, 008B, 000B, 000B]   $
              ],                        $
              ;grow.bm
              [                         $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [248B, 255B, 255B, 255B, 031B],   $
              [008B, 000B, 000B, 000B, 016B],   $
              [008B, 000B, 008B, 000B, 016B],   $
              [008B, 000B, 028B, 000B, 016B],   $
              [008B, 000B, 042B, 000B, 016B],   $
              [008B, 000B, 073B, 000B, 016B],   $
              [008B, 000B, 008B, 000B, 016B],   $
              [008B, 000B, 008B, 000B, 016B],   $
              [008B, 000B, 008B, 000B, 016B],   $
              [008B, 000B, 008B, 000B, 016B],   $
              [008B, 000B, 008B, 000B, 016B],   $
              [008B, 000B, 000B, 000B, 016B],   $
              [008B, 000B, 000B, 000B, 016B],   $
              [008B, 001B, 000B, 000B, 016B],   $
              [136B, 000B, 000B, 128B, 016B],   $
              [072B, 000B, 000B, 000B, 017B],   $
              [232B, 063B, 000B, 000B, 018B],   $
              [072B, 000B, 000B, 252B, 023B],   $
              [136B, 000B, 000B, 000B, 018B],   $
              [008B, 001B, 000B, 000B, 017B],   $
              [008B, 000B, 000B, 128B, 016B],   $
              [008B, 000B, 000B, 000B, 016B],   $
              [008B, 000B, 000B, 000B, 016B],   $
              [008B, 000B, 000B, 000B, 016B],   $
              [008B, 000B, 016B, 000B, 016B],   $
              [008B, 000B, 016B, 000B, 016B],   $
              [008B, 000B, 016B, 000B, 016B],   $
              [008B, 000B, 016B, 000B, 016B],   $
              [008B, 000B, 146B, 000B, 016B],   $
              [008B, 000B, 084B, 000B, 016B],   $
              [008B, 000B, 056B, 000B, 016B],   $
              [008B, 000B, 016B, 000B, 016B],   $
              [008B, 000B, 000B, 000B, 016B],   $
              [248B, 255B, 255B, 255B, 031B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B],   $
              [000B, 000B, 000B, 000B, 000B]   $
              ]                         $
            ]

FOR i = 0,N_ELEMENTS(controls(0,0,*))-1 DO $
  toss = WIDGET_BUTTON(XSurfacepalette, $
              VALUE = controls(*,*,i), $
              UVALUE = STRING(i))

XSurfacedisplay = WIDGET_DRAW(thebase, $
              XSIZE = 950, $
              YSIZE = 500, $
              RETAIN = 2)

XSurfacecontrols = WIDGET_BASE(XSurfacebase, $
              /ROW)

skirtbase = WIDGET_BASE(XSurfacecontrols, $
              /COLUMN, $
              /EXCLUSIVE, $
              /FRAME)

skirtoff = WIDGET_BUTTON(skirtbase, $
              VALUE = "No Skirt", $
              UVALUE = "SKIRTOFF")

skirton = WIDGET_BUTTON(skirtbase, $
              VALUE = "Skirt", $
              UVALUE = "SKIRTON")

shadebase = WIDGET_BASE(XSurfacecontrols, $
              /COLUMN, $
              /EXCLUSIVE, $
              /FRAME)

shadeoff = WIDGET_BUTTON(shadebase, $
              VALUE = "Wire Frame", $
              UVALUE = "SHADEOFF")

shadeon = WIDGET_BUTTON(shadebase, $
              VALUE = "Shaded Surface", $
              UVALUE = "SHADEON")


axesbase = WIDGET_BASE(XSurfacecontrols, $
              /COLUMN, $
              /EXCLUSIVE, $
              /FRAME)

axeson = WIDGET_BUTTON(axesbase, $
              VALUE = "Show Axes", $
              UVALUE = "AXESON")

axesoff = WIDGET_BUTTON(axesbase, $
              VALUE = "Hide Axes", $
              UVALUE = "AXESOFF")

upperbase = WIDGET_BASE(XSurfacecontrols, $
              /COLUMN, $
              /EXCLUSIVE, $
              /FRAME)

upperon = WIDGET_BUTTON(upperbase, $
              VALUE = "Show Top and Bottom", $
              UVALUE = "UPPERON")

upperoff = WIDGET_BUTTON(upperbase, $
              VALUE = "Only Show Top", $
              UVALUE = "UPPEROFF")

commandbase = WIDGET_BASE(XSurfacebase, $
              /FRAME, $
              /COLUMN)

commandlabel = WIDGET_LABEL(commandbase, $
              VALUE = "IDL Commmand To Produce Above Output:")

case ver.style of
'OPEN LOOK':  commandid = WIDGET_LABEL(commandbase, VALUE = "SURFACE, data")
ELSE:          commandid = WIDGET_TEXT(commandbase, $
                        VALUE = "SURFACE, data", $
                        /SCROLL, $
                        YSIZE = 1)
ENDCASE

WIDGET_CONTROL, XSurfacebase, /REALIZE   ;create the widgets
                                       ;that is defined

WIDGET_CONTROL, skirtoff, /SET_BUTTON
WIDGET_CONTROL, shadeoff, /SET_BUTTON
WIDGET_CONTROL, axeson, /SET_BUTTON
WIDGET_CONTROL, upperon, /SET_BUTTON
WIDGET_CONTROL, XSurfacedisplay, GET_VALUE = temp & thedraw = temp

IF(N_PARAMS() gt 0) THEN BEGIN
         thedata = DATA
         XSurface_draw
END

XManager, "XSurface", XSurfacebase, $    ;register the widgets
              EVENT_HANDLER = "XSurface_ev", $ ;with the XManager
              GROUP_LEADER = GROUP

END ;================ end of XSurface background task =====================



