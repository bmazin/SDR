pro tvellipse, rmax, rmin, xc, yc, pos_ang, color, DATA = data, $
	NPOINTS = npoints, COLOR=thecolor, MAJOR=major, MINOR=minor, $
        _Extra = _extra
;+
; NAME:
;      TVELLIPSE
;
; PURPOSE:
;      Draw an ellipse on the current graphics device.
;
; CALLING SEQUENCE:
;      TVELLIPSE, rmax, rmin, xc, yc, [ pos_ang, color, COLOR= ,/DATA, NPOINTS=
;                                        LINESTYLE=, THICK=, /MAJOR, /MINOR ]
; INPUTS:
;       RMAX,RMIN - Scalars giving the semi-major and semi-minor axes of
;                   the ellipse
; OPTIONAL INPUTS:
;       XC,YC - Scalars giving the position on the TV of the ellipse center
;               If not supplied (or if XC, YC are negative and /DATA is not 
;               set), and an interactive graphics device (e.g. not postscript)
;               is set,  then the user will be prompted for X,Y
;       POS_ANG - Position angle of the major axis, measured counter-clockwise
;                 from the X axis.  Default is 0.
;       COLOR - Scalar  integer or string specifying color to draw ellipse.   
;               See cgcolor.pro for a list of possible color names

; OPTIONAL KEYWORD INPUT:
;        COLOR - Intensity value or color name used to draw the circle, 
;                overrides parameter value.  Default = 'opposite'
;        /DATA - if this keyword is set and non-zero, then the ellipse radii and
;               X,Y position center are interpreted as being in DATA
;               coordinates.   Note that the data coordinates must have been
;               previously defined (with a PLOT or CONTOUR call).
;        NPOINTS - Number of points to connect to draw ellipse, default = 120
;                  Increase this value to improve smoothness
;        /MAJOR - Plot a line along the ellipse's major axis
;        /MINOR - Plot a line along the ellipse's minor axis
;
;               Any keyword recognized by cgPLOTS is also recognized by TVELLIPSE.
;               In particular, the color, linestyle, thickness and clipping of
;               the ellipses are controlled by the  COLOR, LINESTYLE, THICK and
;               NOCLIP keywords.  (Clipping is turned off by default, set
;               NOCLIP=0 to activate it.)
;
; RESTRICTIONS:
;        TVELLIPSE does not check whether the ellipse is within the boundaries
;        of the window.
;
;        The ellipse is evaluated at NPOINTS (default = 120) points and
;        connected by straight lines, rather than using the more sophisticated
;        algorithm used by TVCIRCLE
;
;        TVELLIPSE does not accept normalized coordinates.
;
;        TVELLIPSE is not vectorized; it only draws one ellipse at a time
;
; EXAMPLE:
;        Draw an ellipse of semi-major axis 50 pixels, minor axis 30
;        pixels, centered on (250,100), with the major axis inclined 25
;        degrees counter-clockwise from the X axis.  Use a double thickness
;        line and device coordinates (default)
;
;	IDL> tvellipse,50,30,250,100,25,thick=2
;
; NOTES:
;        Note that the position angle for TVELLIPSE (counter-clockwise from
;        the X axis) differs from the astronomical position angle
;        (counter-clockwise from the Y axis).
;
; REVISION HISTORY:
;        Written  W. Landsman STX          July, 1989
;        Converted to use with a workstation.  M. Greason, STX, June 1990
;        LINESTYLE keyword, evaluate at 120 points,  W. Landsman HSTX Nov 1995
;        Added NPOINTS keyword, fixed /DATA keyword W. Landsman HSTX Jan 1996
;        Check for reversed /DATA coordinates  P. Mangiafico, W.Landsman May 1996
;        Work correctly when X & Y data scales are unequal  December 1998
;        Removed cursor input when -ve coords are entered with /data
;        keyword set  P. Maxted, Keele, 2002
;        Use _EXTRA keywords including NOCLIP  W. Landsman October 2006
;        Add plotting of major and minor axes and /MAJOR, /MINOR keywords;
;        fixed description of RMAX,RMIN (semi-axes).  J. Guerber Feb. 2007
;        Update to use Coyote graphics W. Landsman Feb 2011
;-
 On_error,2                              ;Return to caller

 if N_params() lt 2 then begin
   print,'Syntax - TVELLIPSE, rmax, rmin, xc, yc, [pos_ang, color, COLOR=,'
   print,'              NPOINTS=, LINESTYLE=, THICK=, /DATA, /MAJOR, /MINOR ]'
   print,'              any other keywords accepted by cgPLOTS'
   return
 endif

 if N_params() lt 4 then $
       cursor, xc, yc, /DEVICE, /NOWAIT      ;Get unroamed,unzoomed coordinates

 if ( (xc LT 0) || (yc LT 0)) && ~keyword_set(data) then begin
       message,'Position cursor in window ' + strtrim(!D.WINDOW,2) + $
              ' -- then hit mouse button',/INF
       cursor, xc, yc, /DEVICE, /WAIT
         message,'Ellipse is centered at (' + strtrim(xc,2) + ',' + $
		strtrim(yc,2) + ')',/INF
 endif

 if N_params() LT 5 then pos_ang = 0.    ;Default position angle
 if N_Elements(TheColor) EQ 0 then begin
     IF N_Elements( Color ) eq 0 THEN Color = cgcolor('opposite')
 endif else color = TheColor
 
 if ~keyword_set(NPOINTS) then npoints = 120   ;Number of points to connect

 phi = 2*!pi*(findgen(npoints)/(npoints-1))       ;Divide circle into Npoints
 ang = pos_ang/!RADEG               	          ;Position angle in radians
 cosang = cos(ang)
 sinang = sin(ang)

 x =  rmax*cos(phi)              ;Parameterized equation of ellipse
 y =  rmin*sin(phi)

 xprime = xc + x*cosang - y*sinang   	;Rotate to desired position angle
 yprime = yc + x*sinang + y*cosang

 if keyword_set(data) then $
   cgplots, xprime, yprime, /DATA, COLOR=color, _STRICT_Extra = _extra else $
   cgplots, round(xprime), round(yprime),  COLOR=color, /DEVICE,  $
                _STRICT_Extra = _extra

 if keyword_set(major) then begin
     xmaj = xc + [rmax,-rmax]*cosang  ; rot & transl points (rmax,0),(-rmax,0)
     ymaj = yc + [rmax,-rmax]*sinang
     if keyword_set(data) then $
       cgplots, xmaj, ymaj, /DATA, COLOR=color, _STRICT_Extra=_extra  $
     else   cgplots, round(xmaj), round(ymaj), $
       /DEVICE, COLOR=color, _STRICT_Extra=_extra
 endif

 if keyword_set(minor) then begin
     xmin = xc - [rmin,-rmin]*sinang  ; rot & transl points (0,rmin),(0,-rmin)
     ymin = yc + [rmin,-rmin]*cosang
     if keyword_set(data) then $
       cgplots, xmin, ymin, /DATA, COLOR=color, _STRICT_Extra=_extra  $
     else   cgplots, round(xmin), round(ymin), $
       /DEVICE, COLOR=color, _STRICT_Extra=_extra
 endif

 return
 end
