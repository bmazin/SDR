pro plotsym2, psym, psize, FILL=fill    ;Define some plotting symbols
;+
; NAME:
;   PLOTSYM2
; PURPOSE:
;   Define useful plotting symbols not in the standard !PSYM definitions.
;   After symbol has been defined with PLOTSYM, a plotting command should
;   follow with either PSYM = 8 or !P.PSYM = 8 (see USERSYM)
;
; CALLING SEQUENCE:
;   PLOTSYM, PSYM,[ PSIZE, /FILL]
;
; INPUTS:
;   PSYM -  The following integer values of PSYM will create the
;        corresponding plot symbols
;        0 - circle
;        1 - downward arrow (upper limit), base of arrow begins at plot
;             value
;        2 - upward arrow (lower limt)
;        3 - 5 pointed star
;        4 - triangle
;        5 - upside down triangle
;        6 - left pointing arrow
;        7 - right pointing arrow
;        8 - square
;   Arrows are defined such that their base begins at their origin.
;
; OPTIONAL INPUTS:
;   PSIZE - Size of the plotting symbol in multiples of the default size
;        (default PSIZE=1).  Does not need to be an integer
;
; OPTIONAL INPUT KEYWORD:
;   FILL -  Parameter indicating whether to fill the symbol (see USERSYM)
;        The default is 0, unfilled symbol.  Does not affect arrows
;        or character symbols.
;
; OUTPUTS:
;   None
;
; EXAMPLES:
;   Plot Y vs. X with filled stars as the symbol, twice the default size
;   IDL> PLOTSYM, 3 ,2, /FILL        ;Plotting symbol is a filled star,
;                       ;twice default size
;   IDL> PLOT,X,Y,PSYM=8             ;Set PSYM = 8 to get star symbol
;
;   Now plot Y vs. X with open circle as the symbol
;   IDL> PLOTSYM, 0               ;Plotting symbol is a circle
;   IDL> PLOT,X,Y,PSYM=8
;
; METHOD:
;   Appropiate X,Y vectors are used to define the symbol and passed to the
;   USERSYM command.
;
; REVISION HISTORY
;   Written       W. Landsman         June 1992
;   18-JAN-1996    Added a square symbol, HCW.
;-
 On_error,2

 if N_elements(psym) LT 1 then begin
     print,'Syntax - plotsym, psym, [ size, /FILL ]'
     print,'PSYM values 0 - circle, 1 - down arrow, 2 - up arrow, 3 - star
     print,' 4 - triangle, 5 - upside down triangle, 6 - left arrow,' + $
           ' 7 - right arrow'
     return
 endif

 if ( N_elements(psize) LT 1 ) then psize = 1 else psize = psize > 0.1

 if not keyword_set(FILL) then fill = 0

  case psym of
  0:  begin          ;Circle
    ang = 2*!PI*findgen(49)/48.     ;Get position every 5 deg
    xarr = psize*cos(ang)  &  yarr = psize*sin(ang)
    end
1:  begin                                     ;Down arrow
    xarr = [0,0,.5,0,-.5]*psize
    yarr = [0,-2,-1.4,-2,-1.4]*psize
    fill = 0
    end
2:  begin                                     ;Up arrow
    xarr = [0,0,.5,0,-.5]*psize
    yarr = [0,2,1.4,2,1.4]*psize
    fill = 0
    end
3:  begin                                     ;Star
    r = psize
    ang = (720. / 5*findgen(6) + 45) / !RADEG  ;Define star angles every 144 deg
    xarr = r*cos(ang)  & yarr = r*sin(ang)
    end
4:  begin                                     ;Triangle
    xarr = [-1,0,1,-1]*psize
    yarr = [-1,1,-1,-1]*psize
    end
5:  begin                                     ;Upside down triangle
    xarr = [-1, 0, 1, -1]*psize
    yarr = [ 1,-1, 1, 1]*psize
    end
6:  begin                                     ;Left pointing arrow
    yarr = [0, 0, 0.5, 0, -.5]*psize
    xarr = [0,-2,-1.4,-2,-1.4]*psize
    fill = 0
    end
7:  begin                                     ;Left pointing arrow
    yarr = [ 0, 0, 0.5, 0, -.5] * psize
    xarr = [ 0, 2, 1.4, 2, 1.4] * psize
    fill = 0
    end
8:  begin                                     ;Square
    xarr = [-1,-1,1, 1,-1] * psize
    yarr = [-1, 1,1,-1,-1] * psize
    end
 else: message,'Unknown plotting symbol value of '+strtrim(psym,2)
 endcase

 usersym, xarr, yarr, FILL = fill

 return
 end
