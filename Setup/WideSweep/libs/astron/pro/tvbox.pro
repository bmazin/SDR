pro tvbox,width,x,y,color,DATA = data,Color=TheColor, ANGLE = angle, $
                 _EXTRA = _EXTRA
;+
; NAME:
;      TVBOX
; PURPOSE:
;      Draw a box(es) or rectangle(s) of specified width
; EXPLANATION: 
;      Positions can be specified either by the cursor position or by 
;      supplying a vector of X,Y positions.   
;
; CALLING SEQUENCE:
;      TVBOX, width, [ x, y, color, /DATA, ANGLE= ,COLOR =, _EXTRA =  ]
;
; INPUTS:
;      WIDTH -  either a scalar giving the width of a box, or a 2 element
;               vector giving the length and width of a rectangle.
;
; OPTIONAL INPUTS:           
;      X  -  x position for box center, scalar or vector
;      Y  -  y position for box center, scalar or vector.   If vector, then Y
;            must have the same number of elements as X
;            Positions are specified in device coordinates unless /DATA is set
;            If X and Y are not specified, and device has a cursor, then 
;            TVBOX will draw a box at current cursor position
;      COLOR - String or integer specifying the color  to draw the box(es)
;            If COLORS is a scalar then all boxes are drawn with the same
;            color value.   Otherwise, the Nth box is drawn with the
;            Nth value of color.    Color can also be specified as 
;            string (e.g.'red').   See cgCOLOR for a list of available
;            color names.     Default = "opposite".    
; OUTPUTS:
;      None
;
; OPTIONAL KEYWORD INPUTS:
;      ANGLE - numeric scalar specifying the clockwise rotation of
;              the boxes or rectangles.
;      COLOR - Scalar or vector, overrides the COLOR input parameter
;      /DATA - if this keyword is set and non-zero, then the box width and
;             X,Y position center are interpreted as being in DATA 
;             coordinates.   Note that data coordinates must be previously
;             defined (e.g. with a PLOT or CONTOUR call).
;
;      Any keyword recognized by cgPLOTS is also recognized by TVBOX.   
;      In particular, the linestyle, thickness and clipping of the boxes
;      is controlled by the  LINESTYLE, THICK and NOCLIP keywords.
;      (Clipping is turned off by default, set NOCLIP=0 to activate it.)
;
; SIDE EFFECTS:
;       A square or rectangle will be drawn on the device
;       For best results WIDTH should be odd when using the default DEVICE
;       coordinates.  (If WIDTH is even, the actual size of the box will be 
;       WIDTH + 1, so that box remains centered.)
;
; EXAMPLES:
;       (1) Draw a double thick box of width 13, centered at 221,256 in the
;       currently active window
;
;           IDL> tvbox, 13, 221, 256, thick=2
;
;       (2) Overlay a "slit" with dimension 52" x 2" on a previously displayed
;           image at a position angle (East of North) of 32 degrees.    The 
;           slit is to be centered at XC, YC and the plate scale 
;           arcsec_per_pixel is known.
;
;           IDL> w = [2.,52.]/arcsec_per_pixel ;Convert slit size to pixel units
;           IDL> tvbox,w,XC,YC,ang=-32          ;Draw slit
; RESTRICTIONS:
;         Allows use of only device (default) or data (if /DATA is set) 
;           coordinates.   Normalized coordinates are not allowed
; PROCEDURES USED:
;       ZPARCHECK, cgplots
; REVISON HISTORY:
;       Written, W. Landsman   STX Co.           10-6-87
;       Modified to take vector arguments. Greg Hennessy Mar 1991
;       Fixed centering of odd width    W. Landsman    Sep. 1991
;       Let the user specify COLOR=0, accept vector color, W. Landsman Nov. 1995
;       Fixed typo in _EXTRA keyword  W. Landsman   August 1997
;       Added ANGLE keyword    W.Landsman     February 2000 
;       Make sure ANGLE is a scalar   W. Landsman  September 2001
;       Don't round coordinates if /DATA is set.   M. Perrin  August 2005
;       Use STRICT_EXTRA to flag valid keywords W. Landsman Sep 2005
;       Check that width has only 1 or 2 elements W. Landsman August 2010
;       Use Coyote Graphcis  W. Landsman February 2011
;-
 compile_opt idl2
 On_error,2

 npar = N_params()                         ;Get number of parameters

 if ( npar LT 1 ) then begin
     print,'Syntax - TVBOX, width,[ x, y, color, THICK= ,/DATA, ANGLE=, COLOR=]'
     return
 endif

 zparcheck, 'TVBOX', width, 1, [1,2,3,4,5], [0,1], 'Box Width'

 if N_elements(width) GT 2 then message, $
     'ERROR - First parameter (box width) must have 1 or 2 values' 
 if ( N_elements(width) EQ 2 ) then w = width/2. else w = [width,width]/2.

; Can't figure out in IDL how to figure out if the device has a cursor so
; we'll just check for a postscript device

 if ( npar LT 3 ) then if  (!D.NAME NE 'PS') then begin 
    cursor,x,y,/DEVICE,/NOWAIT          ;Read X,Y from the window
    if (x LT 0) or (y LT 0) then begin
       message,'Position cursor in window ' + strtrim(!D.WINDOW,2) + $
              ' -- then hit mouse button',/INF
       cursor,x,y,/DEVICE,/WAIT
       message, 'Box is centered at (' + strtrim(x,2) + ',' + $
                 strtrim(y,2) + ')',/INF
    endif
 endif else message, $
     'ERROR - X,Y position must be specified for Postscript device'

 if N_elements(TheColor) EQ 0 then begin 
     if N_elements(color) EQ 0 then color = cgcolor('opposite')
 endif else color = TheColor    
 nbox = N_elements(x)                      ;Number of boxes to draw
 if ( nbox NE N_elements(Y) ) then $
       message,'ERROR - X and Y positions must have same number of elements'

 ; only round coordinates to integers if using device coords;
 ; data coords can potentially be fractional.
 if keyword_set(data) then begin
         xs = x & ys = y
 endif else begin
        xs = round(x)  &  ys = round(y)
 endelse

 Ncol = N_elements(color)
 xbox = [1,1,-1,-1,1]*w[0]
 ybox = [-1,1,1,-1,-1]*w[1]
 if keyword_set(angle) then begin           ;Non-zero rotation angle?
       ang = angle[0]/!RADEG
       xprime =  xbox*cos(ang) + ybox*sin(ang)
       yprime = -xbox*sin(ang) + ybox*cos(ang)
       xbox = xprime
       ybox = yprime
 endif
 for i = 0l, nbox-1 do begin

  j = i < (Ncol-1)
  xt = xs[i] + xbox      ;X edges of rectangle
  yt = ys[i] + ybox     ;Y edges of rectangle
   
;Plot the box in data or device coordinates 

  if keyword_set( DATA ) then $ 
  cgplots, xt, yt, /DATA,  COLOR=color[j], _STRICT_EXTRA = _EXTRA  else $
  cgplots, round(xt), round(yt), /DEVICE, COLOR=color[j], _STRICT_EXTRA = _EXTRA

 endfor

 return
 end
