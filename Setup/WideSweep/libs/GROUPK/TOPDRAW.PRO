;+
; NAME:
;        TOPDRAW
;
; PURPOSE:
;        Interprets a TOP DRAWER file and makes plots to the display
;        and/or printer output.
;
; CATEGORY:
;        Graphics.
;
; CALLING SEQUENCE:
;
;        TOPDRAW [, File]
;
; OPTIONAL INPUTS:
;        File:     Name of the TOP DRAWER file.  If this parameter is not
;                  specified then the USER will be prompted for a TOP DRAWER
;                  file.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        PATH:     String specifying the path to look for TOP DRAWER files.
;
;        PRINT:    Set this keyword to ONLY print one TOP DRAWER file.
;                  The TOP DRAWER plot will not be sent to the display.
;                  (0=Default).
;
; COMMON BLOCKS:
;        XYOUTS_:  For internal use only.
;
; RESTRICTIONS:
;        You must have the IDL Astronomy Users Library installed.  Three of
;        their routines are called: PLOTERR, OPLOTERR and OS_FAMILY.
;
;        Not all TOP DRAWER commands are available.  For the ones that are,
;        some of them do not have the full functionality of the original
;        commands.  See handout, "Top Drawer for IDL" for further details
;        on what commands are available and their restrictions.
;
; EXAMPLE:
;        Create the following simple text file, called example.top:
;
;        1    10
;        2    15
;        3    32.03
;        5    20.3
;        6    0.23
;        7    1.3
;        8    3.5
;        10   5
;        12   6
;        JOIN
;
;        and and the IDL prompt, type:
;
;        TOPDRAW,'example.top'
;
;        You will see a simple xy-plot of the data with a widget menu
;        providing the option to print the plot.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May 1996.
;-
function VALIDNUM, Str
;
;   Checks to see if Str starts off with a valid number
;
         numflag   = STRMID(Str,0,1)
         ISnum     = ((numflag ge '0') and (numflag le '9')) or $
                      (numflag eq '.') or  (numflag eq '-')
         return, ISnum
end

pro ABORT, Strs
;
;   Make sure all files are closed before aborting program
;
         CLOSE, /ALL
         Nstrs     = N_ELEMENTS(Strs)
         for i=0,Nstrs-2 do print,Strs(i)
         message, Strs(Nstrs-1)
end


function SIZE_TOP2IDL
;
;   A default TOP DRAWER SIZE=2 corresponds roughly to
;   an IDL 'SIZE' of 1.2
;
         return, 0.6
end

function CONVERT_COORD_TOP2IDL, XTOP, YTOP, DEVICE=Device_, NORMAL=Normal_
;
;   Converts TOP DRAWER 'text' units [inches] to
;   IDL device or normal units
;
         xscale_device  = !D.X_SIZE/14.
         yscale_device  = !D.Y_SIZE/10.
         xscale_normal  = 1/14.
         yscale_normal  = 1/10.

         NP   = N_PARAMS()
         if keyword_set( Device_ ) then begin
              vec = xscale_device*xTOP
              if (NP eq 2) then vec = [vec, yscale_device*yTOP]
         endif else if keyword_set( Normal_ ) then begin
                   vec = xscale_normal*xTOP
                   if (NP eq 2) then vec = [vec, yscale_normal*yTOP]
              endif else ABORT,'DEVICE or NORMAL keyword must be set.'

         return, vec
end




pro DEFAULTS, PLOTkeys, OPLOTkeys, ERRkeys, HISTkeys, FLAGS=Flags
;
;   Define all the default values for all the KEYWORDS and parameters
;   stored for the IDL graphics routines
;

         defTOP    = 1.45
         TOPtick   = 3*0.1
         defTICK   = CONVERT_COORD_TOP2IDL(TOPtick,TOPtick,/NORMAL)
         defTICKy  = defTICK(1)
         defTICKx  = defTICK(1)*!D.X_SIZE/!D.Y_SIZE
;
;   This structure holds all the KEYWORDS common to the following IDL
;   routines: PLOT and PLOTERR
;
         PLOTkeys  = { $
                   CHARSIZE  : 0.0          ,$
                   CHARTHICK : defTOP       ,$
                   MAX_VALUE : 1e999        ,$
                   NODATA    : 0            ,$
                   TICKLEN   : defTICKy     ,$
                   TITLE     : ''           ,$
                   XCHARSIZE : 0.           ,$
                   XRANGE    : [0.,0.]      ,$
                   XSTYLE    : 0            ,$
                   XTHICK    : defTOP       ,$
                   XTICKLEN  : defTICKx     ,$
                   XTITLE    : ''           ,$
                   XTYPE     : 0            ,$
                   YCHARSIZE : 0.           ,$
                   YRANGE    : [0.,0.]      ,$
                   YSTYLE    : 0            ,$
                   YTHICK    : defTOP       ,$
                   YTICKLEN  : defTICKy     ,$
                   YTITLE    : ''           ,$
                   YTYPE     : 0            ,$
                   NOERASE   : 0             }
;
;   This structure holds all the KEYWORDS common to the following IDL
;   routines: OPLOT, OPLOTERR, PLOT and PLOTERR
;
         OPLOTkeys = { $
                   LINESTYLE : 0       ,$
                   PSYM      : 3       ,$   ; Default for TOP DRAWER
                   SYMSIZE   : 0.0     ,$
                   THICK     : defTOP   }

;
;   This structure holds specialized KEYWORDS for the following IDL
;   routines: PLOTERR and OPLOTERR
;
         HATLENGTH = CONVERT_COORD_TOP2IDL( 0.1, /DEVICE )*SIZE_TOP2IDL()
         ERRkeys   = { $
                   HATLENGTH : HATLENGTH,   $
                   ERRTHICK  : defTOP       }
;
;   This structure holds the KEYWORDS for the following IDL
;   routine: HIST1D
;
         HISTkeys  = { $
                   MIN       : 0  ,$
                   MAX       : 0  ,$
                   BINSIZE   : 1   }
;
;   This structure holds information for multiple plots and titles
;
         Flags     = { $
                   OPLOT     : 0  ,$
                   TITLE     : 3   }   ; 1 = X, 2 = Y, 3 = Main
end


pro ADD_DATA, Var, Data, ORDER=order
;
;   Parses a row of data and concatenates it to the Data array
;

;   Exract a row of data

         if (N_ELEMENTS(Order) eq 0) then begin
              nvec = N_ELEMENTS(Var)
              row  = float(Var(0))
              for i=1,nvec-1 do row = [row,float(Var(i))]
              Order= FINDGEN(nvec)+1
              if (nvec eq 3) then Order(2) = 4
              Order= [[Order],[1+FLTARR(nvec)]]
         endif else begin
              here = WHERE( Order(*,0) gt 0, nvec )
              if (nvec gt 1) then here = here(SORT(Order(here,0)))
              row  = float( Var(here(0)) ) * Order( here(0),1 )
              for i=1,nvec-1 do row = [row,float(Var(here(i)))*Order(here(i),1)]
         endelse

;   Append it to existing Data array

         Type = SIZE(Data)
         NULL = Type(Type(0)+1) eq 7
         if NULL then Data = row else Data = [Data,row]
end

;-------------------------------------------------------------------------------
;
;   SET commands
;
;-------------------------------------------------------------------------------

pro SET_AXES, Var, PLOTkeys

; SET {AXIS|AXES} [{ALL|TOP|BOTTOM|RIGHT|LEFT} {ON|OFF}]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         i         = 0
         XSTYLE    = PLOTkeys.XSTYLE
         YSTYLE    = PLOTkeys.YSTYLE
         repeat begin
              token     = STRMID(Var(i),0,3)
              i         = (i+1)
              i_        = i < (N-1)
              case token of
              'ALL': case Var(i_) of
                     'OFF': XSTYLE =( YSTYLE=4 )
                     'ON' : XSTYLE =( YSTYLE= [-4,-8] )
                     else :
                     endcase
              'TOP': case Var(i_) of
                     'OFF': XSTYLE = 8
                     'ON' : XSTYLE = [-4,-8]
                     else :
                     endcase
              'BOT': case Var(i_) of
                     'OFF': XSTYLE = 4           ; Both TOP & BOTTOM axes suppressed
                     'ON' : XSTYLE = [-4,-99]
                     else :
                     endcase
              'RIG': case Var(i_) of
                     'OFF': YSTYLE = 8
                     'ON' : YSTYLE= [-4,-8]
                     else :
                     endcase
              'LEF': case Var(i_) of
                     'OFF': YSTYLE = 4           ; Both RIGHT & LEFT axes suppressed
                     'ON' : YSTYLE= [-4,-99]
                     else :
                     endcase
              else : BEGIN
                   i    = (i-1)
                   print, unk+Var(i)
                   END
              endcase

              i         = i+1
         endrep until (i ge N)

         case 1 of
              (XSTYLE(0) eq 0) :
              (XSTYLE(0) gt 0) : PLOTkeys.XSTYLE = XSTYLE
              (XSTYLE(0) lt 0) : if (PLOTkeys.XSTYLE eq ABS(XSTYLE(0))) or $
                                    (PLOTkeys.XSTYLE eq ABS(XSTYLE(1))) then $
                                    PLOTkeys.XSTYLE = 0
         endcase

         case 1 of
              (YSTYLE(0) eq 0) :
              (YSTYLE(0) gt 0) : PLOTkeys.YSTYLE = YSTYLE
              (YSTYLE(0) lt 0) : if (PLOTkeys.YSTYLE eq ABS(YSTYLE(0))) or $
                                    (PLOTkeys.YSTYLE eq ABS(YSTYLE(1))) then $
                                    PLOTkeys.YSTYLE = 0
         endcase
end

pro SET_BAR, Var, ERRkeys

; SET BAR [SIZE] xxx

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         HATLENGTH = ERRkeys.HATLENGTH
         i         = 0
         repeat begin
              token     = STRMID(Var(i),0,3)
              if (token eq 'SIZ') then i = (i+1) < (N-1)

              hatTOP    = float(Var(i))
              HATLENGTH = CONVERT_COORD_TOP2IDL(hatTOP,/DEVICE )*SIZE_TOP2IDL()

              i         = i+1
         endrep until (i ge N)

         ERRkeys.HATLENGTH = HATLENGTH
end

pro SET_GRID, Var, PLOTkeys

; SET GRID {OFF|HORIZONTAL|VERTICAL|ON|SYMBOL [X] [SIZE n]}

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         i         = 0
         XTICKLEN  =( YTICKLEN=0.0 )
         TICKLEN   = 0.02
         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'OFF': TICKLEN =( XTICKLEN =( YTICKLEN=0.02 ))
              'ON' : TICKLEN = 1
              'HOR': YTICKLEN= 1
              'VER': XTICKLEN= 1
              else :
              endcase

              i         = i+1
         endrep until (i ge N)

         PLOTkeys.TICKLEN    =  TICKLEN
         PLOTkeys.XTICKLEN   =  XTICKLEN
         PLOTkeys.YTICKLEN   =  YTICKLEN
end


pro SET_INTENSITY, Var, PLOTkeys, OPLOTkeys

; SET INTENSITY level

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         scale= SIZE_TOP2IDL()

         level= scale*ABS(float(Var(0)))

         OPLOTkeys.THICK     = level
         PLOTkeys.CHARTHICK  = level
         PLOTkeys.XTHICK     = level
         PLOTkeys.YTHICK     = level

end


pro SET_LABELS, Var, PLOTkeys

; SET LABELS [SIZE=n] [ON|OFF] [{ALL|TOP|BOTTOM|RIGHT|LEFT} {ON|OFF}]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         inf  = 100000
         scale= SIZE_TOP2IDL()
         OFF  = 1e-10

         i    = 0
         szX  = PLOTkeys.XCHARSIZE
         szY  = PLOTkeys.YCHARSIZE
         szP  = PLOTkeys.CHARSIZE
         repeat begin
              token     = STRMID(Var(i),0,3)
              i         = i+1
              i_        = i < (N-1)
              case token of
              'SIZ': BEGIN
                   p    = STRPOS(Var(i-1),'=')
                   if (p ne -1) then begin
                        i  = i-1
                        sz = float(STRMID( Var(i),p+1,inf))
                   endif else sz= float(Var(i_))
                   sz   = scale*ABS(sz)
                   if (szP ne OFF) then szP = sz
                   END
              'ON' : BEGIN
                   i = (i-1)
                   if (szX eq OFF) then szX = 1
                   if (szY eq OFF) then szY = 1
                   END
              'OFF': BEGIN
                   i = (i-1)
                   PLOTkeys.TITLE = ''
                   szX =( szY=OFF )
                   END
              'ALL': case Var(i_) of
                   'OFF': BEGIN
                          PLOTkeys.TITLE = ''
                          szX =( szY=OFF )
                          END
                   'ON' : BEGIN
                          if (szX eq OFF) then szX = 1
                          if (szY eq OFF) then szY = 1
                          END
                   else :
                   endcase
              'TOP': case Var(i_) of
                   'OFF': PLOTkeys.TITLE=''
                   'ON' :
                   else :
                   endcase
              'BOT': case Var(i_) of
                   'OFF': szX = OFF
                   'ON' : if (szX eq OFF) then szX = 1
                   else :
                   endcase
              'RIG':
              'LEF': case Var(i_) of
                   'OFF': szY = OFF
                   'ON' : if (szY eq OFF) then szY = 1
                   else :
                   endcase
              else : BEGIN
                   i = (i-1)
                   print, unk+Var(i)
                   END
              endcase

              i         = i+1
         endrep until (i ge N)

         PLOTkeys.XCHARSIZE  = szX
         PLOTkeys.YCHARSIZE  = szY
         PLOTkeys.CHARSIZE   = szP
end

pro SET_LIMITS, Var, PLOTkeys

; SET LIMITS [X [FROM] xxx [TO] xxx] [Y [FROM] yyy [TO] yyy]
;             [XMIN xxx] [XMAX XXX] [YMIN yyy] [YMAX yyy]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         i         = 0
         XRANGE    = PLOTkeys.XRANGE
         YRANGE    = PLOTkeys.YRANGE
         XSTYLE    = PLOTkeys.XSTYLE
         YSTYLE    = PLOTkeys.YSTYLE
         MAX_VALUE = PLOTkeys.MAX_VALUE
         repeat begin
              token     = STRMID(Var(i),0,3)
              i         = (i+1)
              i_        = i < (N-1)
              case token of
              'X'  : BEGIN
                   tok2 = STRMID(Var(i_),0,3)
                   if (tok2 eq 'FRO') then i=(i+1) < (N-1)
                   XRANGE(0) = float(Var(i))

                   i = (i+1) < (N-1)
                   tok2 = STRMID(Var(i),0,2)
                   if (tok2 eq 'TO') then i=(i+1) < (N-1)
                   XRANGE(1) = float(Var(i))
                   XSTYLE    = 1
                   END
              'Y'  : BEGIN
                   tok2 = STRMID(Var(i_),0,3)
                   if (tok2 eq 'FRO') then i=(i+1) < (N-1)
                   YRANGE(0) = float(Var(i))

                   i = (i+1) < (N-1)
                   tok2 = STRMID(Var(i),0,2)
                   if (tok2 eq 'TO') then i=(i+1) < (N-1)
                   YRANGE(1) = float(Var(i))
                   YSTYLE    = 1
                   END
              'XMI':
              'XMA':
              'YMI':
              'YMA': MAX_VALUE = float(Var(i_))
              else : BEGIN
                   i = (i-1)
                   print, unk+Var(i)
                   END
              endcase

              i         = i+1
         endrep until (i ge N)

         PLOTkeys.XRANGE     = XRANGE
         PLOTkeys.YRANGE     = YRANGE
         PLOTkeys.XSTYLE     = XSTYLE
         PLOTkeys.YSTYLE     = YSTYLE
         PLOTkeys.MAX_VALUE  = MAX_VALUE

end


pro SET_ORDER, Var, Order

; SET ORDER [X [fctr]] [Y [fctr]] [Z [fctr]]
;        [DX|RX [fctr]] [DY|RY [fctr]] [DZ|RZ [fctr]]
;        [SYMBOL] [DUMMY]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         i    = 0
         ord  = -1
         fac  = -1.0
         repeat begin
              token     = STRMID(Var(i),0,3)
              i         = (i+1)
              i_        = i < (N-1)
              factor    = 1.0
              if VALIDNUM(Var(i_)) then factor = float(Var(i_)) $
              else i    = (i-1)
              dflag     = -10
              case token of
                   'X'       : dflag = 1
                   'Y'       : dflag = 2
                   'Z'       : print, unk+Var(i_)
                   'DX'      : dflag = 3
                   'DY'      : dflag = 4
                   'RX'      : print, unk+Var(i_)
                   'RY'      : print, unk+Var(i_)
                   'RZ'      : print, unk+Var(i_)
                   'DUM'     : dflag = 0
                   else      : if NOT VALIDNUM(Var(i_)) then print, unk+Var(i_)
              endcase
              if (dflag ne -10) then begin
                   ord  = [ord,dflag]
                   fac  = [fac,factor]
              endif
              i         = i+1
         endrep until (i ge N)

         Order = [[ord(1:*)], [fac(1:*)]]
end


pro SET_SCALE, Var, PLOTkeys

; SET SCALE {X|Y} [n1 [n2]] [BASE n] [LINEAR|LOGARITHMIC|MONTHS|YEARS|USER n|
;                  NORMAL [MEAN x] [DEVIATION s] ]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         i         = 0
         XTYPE     = PLOTkeys.XTYPE
         YTYPE     = PLOTkeys.YTYPE
         axis      = -1
         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'X'  : axis = 0
              'Y'  : axis = 1
              'LIN': case axis of
                        0    : XTYPE = 0
                        1    : YTYPE = 0
                        else : ABORT,'Invalid TOPDRAW format, SET SCALE ....'
                     endcase
              'LOG': case axis of
                        0    : XTYPE = 1
                        1    : YTYPE = 1
                        else : ABORT,'Invalid TOPDRAW format, SET SCALE ....'
                     endcase
              else : if NOT VALIDNUM(Var(i)) then print, unk+Var(i)
              endcase

              i         = i+1
         endrep until (i ge N)

         PLOTkeys.XTYPE   = XTYPE
         PLOTkeys.YTYPE   = YTYPE
end

pro SET_SYMBOL, Var, OPLOTkeys

; SET SYMBOL [x] [SIZE n]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         scale= SIZE_TOP2IDL()

         i         = 0
         PSYM      = OPLOTkeys.PSYM
         SYMSIZE   = OPLOTkeys.SYMSIZE
         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'SIZ': BEGIN
                   i = (i+1) < (N-1)
                   SYMSIZE = scale*ABS(float(Var(i)))
                   END
              '0O' : PSYM = 7
              '1O' : PSYM = 1
              '2O' : PSYM = 4
              '3O' : PSYM = 6
              '4O' : PSYM = 4
              '5O' : PSYM = 6
              '6O' : PSYM = 7
              '7O' : PSYM = 1
              '8O' : PSYM = 2
              '9O' : PSYM = 2
              else :
              endcase

              i         = i+1
         endrep until (i ge N)

         OPLOTkeys.PSYM      = PSYM
         OPLOTkeys.SYMSIZE   = SYMSIZE
end

pro SET_TICKS, Var, PLOTkeys

; SET TICKS [SIZE n] [ON|OFF] [{ALL|TOP|BOTTOM|RIGHT|LEFT} {ON|OFF}]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         def  = 0.02
         scale= 0.2     ; Default TOP=0.1, IDL=0.02
         OFF  = 1e-10

         i    = 0
         XTICKLEN  = PLOTkeys.XTICKLEN
         YTICKLEN  = PLOTkeys.YTICKLEN
         TICKLEN   = PLOTkeys.TICKLEN
         repeat begin
              token     = STRMID(Var(i),0,3)
              i         = (i+1)
              i_        = i < (N-1)
              case token of
              'SIZ': BEGIN
                   topt = 3*float(Var(i_))
                   txy  = CONVERT_COORD_TOP2IDL(topt,topt,/NORMAL)
                   TICKLEN   = txy(1)
                   XTICKLEN  = txy(1)*!D.X_SIZE/!D.Y_SIZE
                   YTICKLEN  = txy(1)
                   END
              'ON' : BEGIN
                   i    = (i-1)
                   TICKLEN = def
                   END
              'OFF': BEGIN
                   i    = (i-1)
                   TICKLEN =( XTICKLEN =( YTICKLEN=0 ))
                   END
              'ALL': case Var(i_) of
                     'OFF': TICKLEN =( XTICKLEN =( YTICKLEN=0 ))
                     'ON' : TICKLEN = def
                     else :
                     endcase
              'TOP': case Var(i_) of
                     'OFF': XTICKLEN = OFF
                     'ON' : XTICKLEN = def
                     else :
                     endcase
              'BOT': case Var(i_) of
                     'OFF': XTICKLEN = OFF
                     'ON' : XTICKLEN = def
                     else :
                     endcase
              'RIG': case Var(i_) of
                     'OFF': YTICKLEN = OFF
                     'ON' : YTICKLEN = def
                     else :
                     endcase
              'LEF': case Var(i_) of
                     'OFF': YTICKLEN = OFF
                     'ON' : YTICKLEN = def
                     else :
                     endcase
              else : BEGIN
                   i = (i-1)
                   print, unk+Var(i)
                   END
              endcase

              i         = i+1
         endrep until (i ge N)

         PLOTkeys.XTICKLEN   = XTICKLEN
         PLOTkeys.YTICKLEN   = YTICKLEN
         PLOTkeys.TICKLEN    = TICKLEN
end

pro SET_TITLE, Var, PLOTkeys

; SET TITLE [SIZE n]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         scale= SIZE_TOP2IDL()

         i         = 0
         CHARSIZE  = PLOTkeys.CHARSIZE
         repeat begin
              if VALIDNUM(Var(i)) then CHARSIZE = scale*ABS(float(Var(i)))
              i         = i+1
         endrep until (i ge N)

         PLOTkeys.CHARSIZE   = CHARSIZE
end


pro SET_WINDOW, Var, DEFAULT=Default

; SET WINDOW [X xxx [TO] xxx] [Y yyy [TO] yyy]
; SET WINDOW [X n1 OF n2] [Y n1 OF n2]

         if keyword_set(Default) then begin
              !P.POSITION         = 0
              return
         endif

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         i    = 0
         repeat begin
              token     = STRMID(Var(i),0,3)
              i         = (i+1)
              i_        = i < (N-1)
              case token of
              'X'  : BEGIN
                   if (Var(i_+1) eq 'OF') then begin
                        n1x  = long(Var(i_))
                        i    = (i+2) < (N-1)
                        n2x  = long(Var(i))
                   endif else begin
                        x1   = float(Var(i_))
                        i    = (i+1) < (N-1)
                        if (Var(i) eq 'TO') then i = (i+1) < (N-1)
                        x2   = float(Var(i))
                   endelse
                   END
              'Y'  : BEGIN
                   if (Var(i_+1) eq 'OF') then begin
                        n1y  = long(Var(i_))
                        i    = (i+2) < (N-1)
                        n2y  = long(Var(i))
                   endif else begin
                        y1   = float(Var(i_))
                        i    = (i+1) < (N-1)
                        if (Var(i) eq 'TO') then i = (i+1) < (N-1)
                        y2   = float(Var(i))
                   endelse
                   END
              else : BEGIN
                   i    = (i-1)
                   if (token ne '') then print,unk+Var(i)
                   END
              endcase
              i         = i+1
         endrep until (i ge N)

         if (N_ELEMENTS(x1) gt 0) and (N_ELEMENTS(y1) gt 0) then begin
              xy1  = CONVERT_COORD_TOP2IDL( x1, y1, /NORMAL )
              xy2  = CONVERT_COORD_TOP2IDL( x2, y2, /NORMAL )
              !P.POSITION = [xy1,xy2]
         endif else if (N_ELEMENTS(n1x) gt 0) and (N_ELEMENTS(n1y) gt 0) then begin
                   nplot= ((n1y-1) > 0)*n2x + n1x
                   ntot = n2x*n2y
                   iplot= ntot - nplot
                   !P.MULTI  = [iplot,n2x,n2y]
              endif
end


;-------------------------------------------------------------------------------
;
;   DATA commands
;
;-------------------------------------------------------------------------------



pro BIN_, Var, HISTkeys

; BIN [BINS=n] [FROM xmin] [TO xmax] [BY dx]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         inf  = 100000

         XDEF = -92347.99343
         xmin =( xmax  =( nbins =( binsize=( XDEF ))))

         i    = 0
         TOP       =( BOTTOM =( LEFT=0 ))
         TEXT      = '_NULL_'
         repeat begin
              token     = STRMID(Var(i),0,3)
              i         = (i+1)
              i_        = i < (N-1)
              case token of
              'BIN': BEGIN
                   p    = STRPOS(Var(i-1),'=')
                   if (p eq -1) then nbins     = long(Var(i_))  $
                   else begin
                        i = (i-1)
                        nbins = long(STRMID( Var(i),p+1,inf))
                   endelse
                   END
              'FRO': xmin      = float(Var(i_))
              'TO' : xmax      = float(Var(i_))
              'BY' : binsize   = float(Var(i_))
              else : BEGIN
                   i    = (i-1)
                   val = float(Var(i))
                   if (xmin eq XDEF) then xmin = val $
                   else if (xmax eq XDEF) then xmax = val $
                        else binsize = val
                   END
              endcase

              i         = i+1
         endrep until (i ge N)

         if (binsize eq XDEF) then begin
              if (nbins eq XDEF) then binsize = 1 $
              else binsize = (xmax - xmin)/float(nbins-1)
         endif

         HISTkeys.MIN        = xmin
         HISTkeys.MAX        = xmax
         HISTkeys.BINSIZE    = binsize
end


pro SMOOTH_, Var, Data

; SMOOTH {X|Y} [LEVEL n] [POINTS n1 [TO] n2]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'
         if (dim gt 1) then nvec = type(2) else nvec = 1
         npts = type(1)
         n1   = 0
         n2   = npts-1

         i    = 0
         axis = 0
         nlev = 5
         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'X'  : axis    = 1
              'Y'  : axis    = 2
              'LEV': BEGIN
                   i    = (i+1) < (N-1)
                   nlev = long( Var(i) )
                   END
              'POI': BEGIN
                   i    = (i+1) < (N-1) & n1   = long(Var(i))-1
                   i    = (i+1) < (N-1) & if (Var(i) eq 'TO') then i=(i+1)<(N-1)
                   n2   = long(Var(i))-1
                   END
              else : if (token ne '') then print,unk+Var(i)
              endcase
              i         = i+1
         endrep until (i ge N)

         if (axis eq 0) then return else z = Data(*,axis-1)
         z    = z(n1:n2)
         z    = SMOOTH(z,nlev)

         Data(n1:n2,axis-1)  = z
end


pro XYDXDY_, Var, Data, DataType, ORDER=Order1

; {X|Y|DX|DY} [{BINS|POINTS} [n1 [TO] n2|n2]] [FROM xxx] [TO xxx] [BY xxx]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'
         if (dim gt 1) then nvec = type(2) else nvec = 1
         npts = type(1)

         if (N_ELEMENTS(Order1) gt 0) then begin
              here = WHERE( (Order1(*,0) ge 1) and (Order1(*,0) le 4), nhere )
              if (nhere eq 0) then ABORT,'Invalid SET ORDER command.'
              vectype = Order1(here,0)
              vectype = vectype(SORT(vectype))
         endif else begin
              vectype     = INDGEN(nvec) + 1
              if (nvec eq 3) then vectype(2) = 4
         endelse

         case DataType of
              'X'  : dtype   = 1
              'Y'  : dtype   = 2
              'DX' : dtype   = 3
              'DY' : dtype   = 4
         endcase

         i    = 0
         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'FRO': BEGIN
                   i    = (i+1) < (N-1)
                   xFROM= float(Var(i))
                   END
              'TO' : BEGIN
                   i    = (i+1) < (N-1)
                   xTO  = float(Var(i))
                   END
              'BY' : BEGIN
                   i    = (i+1) < (N-1)
                   xBY  = float(Var(i))
                   END
              'BIN': BEGIN
                   bin  = 1
                   i    = (i+1)
                   i_   = i < (N-1)
                   ISnum     = VALIDNUM( Var(i_) )
                   if (ISnum) then begin
                        n1   = long(Var(i_))
                        i    = (i+1) < (N-1)
                        if (Var(i) eq 'TO') then begin
                             i  = i+1 < (N-1)
                             n2 = long(Var(i))
                        endif else begin
                             ISnum     = VALIDNUM( Var(i) )
                             if (ISnum) then n2 = long(Var(i)) else begin
                                  n2   = n1
                                  n1   = 1
                             endelse
                        endelse
                   endif else i = (i-1)
                   END
              'POI': BEGIN
                   bin  = 0
                   i    = (i+1)
                   i_   = i < (N-1)
                   ISnum     = VALIDNUM( Var(i_) )
                   if (ISnum) then begin
                        n1   = long(Var(i_))
                        i    = (i+1) < (N-1)
                        if (Var(i) eq 'TO') then begin
                             i  = i+1 < (N-1)
                             n2 = long(Var(i))
                        endif else begin
                             ISnum     = VALIDNUM( Var(i) )
                             if (ISnum) then n2 = long(Var(i)) else begin
                                  n2   = n1
                                  n1   = 1
                             endelse
                        endelse
                   endif else i = (i-1)
                   END
              else : if VALIDNUM(Var(i)) then xTO = float(Var(i)) $
                        else print,unk+Var(i)
              endcase
              i         = i+1
         endrep until (i ge N)

         if (N_ELEMENTS(n1) eq 0) then begin
              n1   = 0
              n2   = npts - 1
         endif else begin
              n1   = n1 - 1
              n2   = n2 - 1
         endelse
         mpts = n2 - n1 + 1

;   Generate linear sequence

         FROM = N_ELEMENTS(xFROM)
         TO   = N_ELEMENTS(xTO)
         BY   = N_ELEMENTS(xBY)
         ck   = FROM + TO + BY
         if (ck ne 2) then ABORT,'Syntax error for {X|Y|DX|DY} command.'

         case 1 of
         FROM and TO :  BEGIN
                        xBY   = (xTO - xFROM)/( mpts - 1. )
                        if (bin) then xBY = xBY*(mpts - 1.)/mpts
                        END
         FROM and BY :
         TO   and BY :  xFROM = xTO - xBY*( mpts - 1. )
         endcase
         if (bin) then XMIN = xFROM + 0.5*xBY else XMIN = xFROM
         xpts = xMIN + xBY*FINDGEN( mpts )

;   See if data type exists in current data array

         here = WHERE( vectype eq dtype, nhere )
         if (nhere eq 1) then Data( n1:n2, (vectype(here)-1) < (nvec-1)) = xpts $
         else begin
              Data2= FLTARR( npts, nvec+1 )
              Data2( n1:n2, (dtype-1) < nvec ) = xpts
              for i=0,nvec-1 do $
                   Data2( *,(vectype(i)-1) < nvec ) =  Data( *,i )
              Data = TEMPORARY(Data2)
         endelse
end


;-------------------------------------------------------------------------------
;
;   ACTION commands
;
;-------------------------------------------------------------------------------


pro BARGRAPH_, Var, Data, PLOTkeys, OPLOTkeys, Flag_OPLOT

; BARGRAPH [POINTS n1 [TO] n2] [SOLID|DOTS|DASHES|PATTERNED]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'

         i    = 0
         X    = DATA(*,0)
         Y    = DATA(*,1)
         npts = N_ELEMENTS(X)
         n1   = 0
         n2   = npts-1
         LINESTYLE = OPLOTkeys.LINESTYLE

         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'POI': BEGIN
                   i    = (i+1) < (N-1) & n1   = long(Var(i))-1
                   i    = (i+1) < (N-1) & if (Var(i) eq 'TO') then i=(i+1)<(N-1)
                   n2   = long(Var(i))-1
                   END
              'SOL': LINESTYLE = 0
              'DOT': LINESTYLE = 1
              'DAS': LINESTYLE = 2
              'DOT': LINESTYLE = 3
              'PAT': LINESTYLE = 1
              else : if (token ne '') then print,unk+Var(i)
              endcase
              i         = i+1
         endrep until (i ge N)

         OPLOTkeys.LINESTYLE = LINESTYLE
         OPLOTkeys.PSYM      = 10
         X    = X(n1:n2)
         Y    = Y(n1:n2)

         if keyword_set( Flag_OPLOT ) then oplot, X, Y, _EXTRA=OPLOTkeys $
         else begin
              keys = CREATE_STRUCT( PLOTkeys, OPLOTkeys )
              plot, X, Y, _EXTRA=keys
         endelse
end


pro HISTOGRAM_, Var, Data, PLOTkeys, OPLOTkeys, ERRkeys, HISTkeys, Flag_OPLOT

; HISTOGRAM [POINTS n1 [TO] n2] [SOLID|DOTS|DASHES|PATTERNED]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'

         i    = 0
         X    = DATA(*,0)
         npts = N_ELEMENTS(X)
         ntot = N_ELEMENTS(Data)
         twoD = (ntot gt npts)
         if twoD then Y = DATA(*,1)

         n1   = 0
         n2   = npts-1
         LINESTYLE = OPLOTkeys.LINESTYLE

         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'POI': BEGIN
                   i    = (i+1) < (N-1) & n1   = long(Var(i))-1
                   i    = (i+1) < (N-1) & if (Var(i) eq 'TO') then i=(i+1)<(N-1)
                   n2   = long(Var(i))-1
                   END
              'SOL': LINESTYLE = 0
              'DOT': LINESTYLE = 1
              'DAS': LINESTYLE = 2
              'DOT': LINESTYLE = 3
              'PAT': LINESTYLE = 1
              else : if (token ne '') then print,unk+Var(i)
              endcase
              i         = i+1
         endrep until (i ge N)

         OPLOTkeys.LINESTYLE= LINESTYLE
         OPLOTkeys.PSYM     = 10
         X    = X(n1:n2)
         if twoD then Y = Y(n1:n2)

         if (HISTkeys.MIN ne HISTkeys.MAX) then begin
              xMIN      = HISTkeys.MIN
              xMAX      = HISTkeys.MAX
              BINSIZE   = HISTkeys.BINSIZE

              if twoD then $
                   h = HIST1D( X,Y, _EXTRA=HISTkeys, OBIN=obin ) $
              else h = HIST1D( X,   _EXTRA=HISTkeys, OBIN=obin )
              Data = [ [obin],[h] ]
         endif
         OPLOTkeys.PSYM = 10

         PLOT_, '', Data, PLOTkeys, OPLOTkeys, ERRkeys, Flag_OPLOT
end


pro JOIN_, Var, Data, PLOTkeys, OPLOTkeys, ERRkeys, Flag_OPLOT

; JOIN [level] {{SPLINE|GENERAL} [POINTS n1 [TO] n2] [SOLID|DOTS|DASHES|PATTERNED|FUNNY]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'

         i    = 0
         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'
         if (dim gt 1) then nvec = type(2) else nvec = 1
         npts = type(1)

         n1   = 0
         n2   = npts-1
         if (N eq 1) and (Var(0) eq '') then goto, NOPAR_J
         LINESTYLE = OPLOTkeys.LINESTYLE

         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'SPL':
              'GEN':
              'POI': BEGIN
                   i    = (i+1) < (N-1) & n1   = long(Var(i))-1
                   i    = (i+1) < (N-1) & if (Var(i) eq 'TO') then i=(i+1)<(N-1)
                   n2   = long(Var(i))-1
                   END
              'SOL': LINESTYLE = 0
              'DOT': LINESTYLE = 1
              'DAS': LINESTYLE = 2
              'PAT': LINESTYLE = 1
              'FUN':
              else : if (NOT VALIDNUM(Var(i))) then print,unk+Var(i)
              endcase
              i         = i+1
         endrep until (i ge N)

         OPLOTkeys.LINESTYLE = LINESTYLE
NOPAR_J:

         if (nvec ge 1) then X    = data(n1:n2,0)
         if (nvec ge 2) then Y    = data(n1:n2,1)
         if (nvec ge 3) then dY   = data(n1:n2,2)
         if (nvec eq 4) then begin
              dX   = dY
              dY   = data(n1:n2,3)
         endif

         PSYMsave       = OPLOTkeys.PSYM
         OPLOTkeys.PSYM = 0
         if keyword_set( Flag_OPLOT ) then begin
              OERRkeys  = CREATE_STRUCT( OPLOTkeys, ERRkeys )
              case nvec of
                   1    : oplot, X,    _EXTRA=OPLOTkeys
                   2    : oplot, X, Y, _EXTRA=OPLOTkeys
                   3    : oploterr, X, Y, dY, _EXTRA=OERRkeys
                   4    : oploterr, X, Y, dX, dY, _EXTRA=OERRkeys
              endcase
         endif else begin
              keys      = CREATE_STRUCT( PLOTkeys, OPLOTkeys )
              PERRkeys  = CREATE_STRUCT( PLOTkeys, OPLOTkeys, ERRkeys )
              case nvec of
                   1    : plot, X,    _EXTRA=keys
                   2    : plot, X, Y, _EXTRA=keys
                   3    : ploterr, X, Y, dY, _EXTRA=PERRkeys
                   4    : ploterr, X, Y, dX, dY, _EXTRA=PERRkeys
              endcase
         endelse
         OPLOTkeys.PSYM = PSYMsave
end


pro PLOT_, Var, Data, PLOTkeys, OPLOTkeys, ERRkeys, Flag_OPLOT

; PLOT [POINTS n1 [TO] n2]

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '

         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'

         i    = 0
         type = SIZE(Data)
         dim  = type(0)
         if (dim lt 1) then ABORT,'Invalid Data array.'
         if (dim gt 1) then nvec = type(2) else nvec = 1
         npts = type(1)

         n1   = 0
         n2   = npts-1

         repeat begin
              token     = STRMID(Var(i),0,3)
              case token of
              'POI': BEGIN
                   i    = (i+1) < (N-1) & n1   = long(Var(i))-1
                   i    = (i+1) < (N-1) & if (Var(i) eq 'TO') then i=(i+1)<(N-1)
                   n2   = long(Var(i))-1
                   END
              else : if (token ne '') then print,unk+Var(i)
              endcase
              i         = i+1
         endrep until (i ge N)

         if (nvec ge 1) then X    = data(n1:n2,0)
         if (nvec ge 2) then Y    = data(n1:n2,1)
         if (nvec ge 3) then dY   = data(n1:n2,2)
         if (nvec eq 4) then begin
              dX   = dY
              dY   = data(n1:n2,3)
         endif


         if keyword_set( Flag_OPLOT ) then begin
              OERRkeys  = CREATE_STRUCT( OPLOTkeys, ERRkeys )
              case nvec of
                   1    : oplot, X,    _EXTRA=OPLOTkeys
                   2    : oplot, X, Y, _EXTRA=OPLOTkeys
                   3    : oploterr, X, Y, dY, _EXTRA=OERRkeys
                   4    : oploterr, X, Y, dX, dY, _EXTRA=OERRkeys
              endcase
         endif else begin
              keys      = CREATE_STRUCT( PLOTkeys, OPLOTkeys )
              PERRkeys  = CREATE_STRUCT( PLOTkeys, OPLOTkeys, ERRkeys )
              case nvec of
                   1    : plot, X,    _EXTRA=keys
                   2    : plot, X, Y, _EXTRA=keys
                   3    : ploterr, X, Y, dY, _EXTRA=PERRkeys
                   4    : ploterr, X, Y, dX, dY, _EXTRA=PERRkeys
              endcase
         endelse
end


function GET_TEXT, Str

         pos1 = STRPOS(Str,'"') > STRPOS(Str,'''')
         if (pos1 eq -1) then return, '_NULL_'

         inf  = 100000
         pos2 = STRPOS(Str,'"',pos1+1) > STRPOS(Str,'''',pos1+1)
         if (pos2 eq -1) then pos2 = inf

         pos1 = pos1+1
         pos2 = pos2-1
         len  = pos2 - pos1 + 1
         TEXT = STRMID(Str,pos1,len)
         return, TEXT
end

pro TITLE_, Var, TOPline, PLOTkeys, Oflag_TITLE

; TITLE [TOP|BOTTOM|RIGHT|LEFT|xxx yyy [DATA|XDATA|YDATA] [CENTER] [LINES=n]]
;        [SIZE n] [ANGLE x] [SPACES n] [INDEX n] 'text'

         N    = N_ELEMENTS(Var)
         unk  = 'Unrecognized command: '
         inf  = 100000

         i    = 0
         TOP       =( BOTTOM =( LEFT =( XYPOS = 0 )))
         ALIGNMENT = 0
         common XYOUTS_, Position, XYtext, EXTRAkeys
         repeat begin
              token     = STRUPCASE(STRMID(Var(i),0,3))
              case token of
              'TOP': TOP     = 1
              'BOT': BOTTOM  = 1
              'RIG':
              'LEF': LEFT    = 1
              'DAT':
              'XDA':
              'YDA':
              'CEN': ALIGNMENT = 0.5
              'LIN': BEGIN
                   p    = STRPOS(Var(i),'=')
                   if (p eq -1) then i=i+1
                   END
              'SIZ': BEGIN
                   i = (i+1) < (N-1)
                   scale     = SIZE_TOP2IDL()
                   PLOTkeys.CHARSIZE = scale*ABS(float(Var(i)))
                   END
              'ANG': i = (i+1) < (N-1)
              'SPA': i = (i+1) < (N-1)
              'IND': i = (i+1) < (N-1)
              else : BEGIN
                   if (i eq 0) then begin
                        XYPOS     = 1
                        if VALIDNUM( Var(i)) then begin
                             X    = float(Var(i))
                             i    = (i+1) < (N-1)
                             Y    = float(Var(i))
                             DATAcoord =( DEVICEcoord=0 )
                             if ((i+1) ge N) then DEVICEcoord=1 $
                             else begin
                                  i = (i+1) < (N-1)
                                  tok2 = STRUPCASE(STRMID(Var(i),0,3))
                                  if (tok2 eq 'DAT') then DATAcoord=1 $
                                  else begin
                                       DEVICEcoord=1
                                       i    = (i-1) > 0
                                  endelse
                             endelse
                             if DEVICEcoord then begin
                                  XY   = CONVERT_COORD_TOP2IDL( X, Y, /DEVICE )
                                  X    = XY(0)
                                  Y    = XY(1)
                             endif
                        endif else if (N_ELEMENTS(EXTRAkeys) gt 0) then begin
                                  DEVICEcoord    = EXTRAkeys.DEVICE
                                  DATAcoord      = EXTRAkeys.DATA
                             endif
                   endif else begin
                        tok2 = STRUPCASE(STRMID(Var((i-1) > 0),0,3))
                        if (tok2 ne 'LIN') then i    = N-1
                   endelse
                   END
              endcase

              i         = i+1
         endrep until (i ge N)

         TEXT = GET_TEXT( TOPline )
         if (TEXT ne '_NULL_') then begin
              case 1 of
              TOP       : PLOTkeys.TITLE    = TEXT
              BOTTOM    : PLOTkeys.XTITLE   = TEXT
              LEFT      : PLOTkeys.YTITLE   = TEXT
              XYPOS     : BEGIN
                        EXTRAkeys = { $
                                       DEVICE    : DEVICEcoord, $
                                       DATA      : DATAcoord,   $
                                       ALIGNMENT : ALIGNMENT,   $
                                       CHARSIZE  : PLOTkeys.CHARSIZE,  $
                                       CHARTHICK : PLOTkeys.CHARTHICK  }
                        if (N_ELEMENTS(X) gt 0) then Position  = [X,Y] $
                        else begin
                             CS   = PLOTkeys.CHARSIZE
                             if (CS eq 0) then CS = 1
                             dy   = CS*!D.Y_CH_SIZE
                             if EXTRAkeys.DATA then begin
                                  dum  = 0.0
                                  d    = CONVERT_COORD(dum,dy,/DEVICE,/TO_DATA)
                                  dy   = d(1)
                             endif
                             Position(1) = Position(1) - dy
                        endelse
                        if (TEXT ne '') then begin
                             XYOUTS, Position(0), Position(1), TEXT, $
                                        _EXTRA=EXTRAkeys
                             PLOTkeys.NOERASE = 1
                        endif
                        XYtext    = TEXT
                        END
              else      :
              endcase
              Oflag_TITLE = 1*BOTTOM + 2*LEFT + 3*TOP + 4*XYPOS
         endif
end


pro MORE_, Var, TOPline, PLOTkeys, Flag_TITLE

; MORE 'text'

         N    = N_ELEMENTS(Var)
         inf  = 100000

         TEXT = GET_TEXT( TOPline )
         if (TEXT eq '_NULL_') then return

         case Flag_TITLE of
              1    : PLOTkeys.XTITLE = PLOTkeys.XTITLE + TEXT
              2    : PLOTkeys.YTITLE = PLOTkeys.YTITLE + TEXT
              3    : PLOTkeys.TITLE  = PLOTkeys.TITLE  + TEXT
              4    : BEGIN
                   common XYOUTS_, Position, XYtext, EXTRAkeys
                   if (N_ELEMENTS(Position) gt 1) then begin
                        if (XYtext ne '') then $
                             XYOUTS, Position(0), Position(1), XYtext, $
                                  COLOR=!P.background, _EXTRA=EXTRAkeys
                        XYtext = XYtext + TEXT
                        XYOUTS, Position(0), Position(1), XYtext,$
                                  _EXTRA=EXTRAkeys
                   endif else print,'Ignoring TOP DRAWER command: ',Var
                   END
              else : ABORT,'Invalid input argument value.'
         endcase
end

pro CASE_, Var, TOPline, PLOTkeys, Flag_TITLE

; CASE 'text'

         N    = N_ELEMENTS(Var)
         inf  = 100000

         C2_text = GET_TEXT( TOPline )
         if (C2_text eq '_NULL_') then return
         common XYOUTS_, Position, XYtext, EXTRAkeys

         case Flag_TITLE of
              1    : C1_text = PLOTkeys.XTITLE
              2    : C1_text = PLOTkeys.YTITLE
              3    : C1_text = PLOTkeys.TITLE
              4    : C1_text = XYtext
              else : ABORT,'Invalid input argument value.'
         endcase

         C1b  = BYTE(C1_text)
         nC1  = N_ELEMENTS(C1b)
         C1b  = REFORM(C1b,1,nC1,/OVERWRITE)
         C1   = STRUPCASE(STRING(C1b))

         C2b  = BYTE(C2_text)
         nC2  = N_ELEMENTS(C2b)
         C2b  = REFORM(C2b,1,nC2,/OVERWRITE)
         C2   = STRUPCASE(STRING(C2b))

         chars= C1
         C12  = C1(0:nC2-1) + C2
         for i=0,nC2-1 do begin
              case C2(i) of
;   Roman
              'L'  : chars(i) = STRLOWCASE(C1(i))
              ''   : chars(i) = STRUPCASE(C1(i))
;   Greek
              'F'  : case C1(i) of                         ; UPPER case
                     'A': chars(i) = '!4A!X'               ; Alpha
                     'B': chars(i) = '!4B!X'               ; Beta
                     'C': chars(i) = '!4V!X'               ; Chi
                     'D': chars(i) = '!4D!X'               ; Delta
                     'E': chars(i) = '!4E!X'               ; Epsilon
                     'F': chars(i) = '!4U!X'               ; Phi
                     'G': chars(i) = '!4C!X'               ; Gamma
                     'H': chars(i) = '!4G!X'               ; Eta
                     'I': chars(i) = '!4I!X'               ; Iota
                     'K': chars(i) = '!4J!X'               ; Kappa
                     'L': chars(i) = '!4K!X'               ; Lambda
                     'M': chars(i) = '!4L!X'               ; Mu
                     'N': chars(i) = '!4M!X'               ; Nu
                     'O': chars(i) = '!4O!X'               ; Omicron
                     'P': chars(i) = '!4P!X'               ; Pi
                     'Q': chars(i) = '!4H!X'               ; Theta
                     'R': chars(i) = '!4Q!X'               ; Rho
                     'S': chars(i) = '!4R!X'               ; Sigma
                     'T': chars(i) = '!4S!X'               ; Tau
                     'U': chars(i) = '!4T!X'               ; Upsilon
                     'W': chars(i) = '!4X!X'               ; Omega
                     'X': chars(i) = '!4N!X'               ; Xi
                     'Y': chars(i) = '!4W!X'               ; Psi
                     'Z': chars(i) = '!4F!X'               ; Zeta
                     else:
                     endcase
              'G'  : case C1(i) of                         ; LOWER case
                     'A': chars(i) = '!4a!X'               ; Alpha
                     'B': chars(i) = '!4b!X'               ; Beta
                     'C': chars(i) = '!4v!X'               ; Chi
                     'D': chars(i) = '!4d!X'               ; Delta
                     'E': chars(i) = '!4e!X'               ; Epsilon
                     'F': chars(i) = '!4u!X'               ; Phi
                     'G': chars(i) = '!4c!X'               ; Gamma
                     'H': chars(i) = '!4g!X'               ; Eta
                     'I': chars(i) = '!4i!X'               ; Iota
                     'K': chars(i) = '!4j!X'               ; Kappa
                     'L': chars(i) = '!4k!X'               ; Lambda
                     'M': chars(i) = '!4l!X'               ; Mu
                     'N': chars(i) = '!4m!X'               ; Nu
                     'O': chars(i) = '!4o!X'               ; Omicron
                     'P': chars(i) = '!4p!X'               ; Pi
                     'Q': chars(i) = '!4h!X'               ; Theta
                     'R': chars(i) = '!4q!X'               ; Rho
                     'S': chars(i) = '!4r!X'               ; Sigma
                     'T': chars(i) = '!4s!X'               ; Tau
                     'U': chars(i) = '!4t!X'               ; Upsilon
                     'W': chars(i) = '!4x!X'               ; Omega
                     'X': chars(i) = '!4n!X'               ; Xi
                     'Y': chars(i) = '!4w!X'               ; Psi
                     'Z': chars(i) = '!4f!X'               ; Zeta
                     else:
                     endcase

;   Subscripts and Superscripts
              'X'  : case C1(i) of
                     '0'  : chars(i) = '!D'                ; Enter Subscript Mode
                     '1'  : chars(i) = '!N'                ; Leave Subscript Mode
                     '2'  : chars(i) = '!U'                ; Enter Superscript Mode
                     '3'  : chars(i) = '!N'                ; Leave Superscript Mode
                     else :
                     endcase

;   Math Symbol
              'M'  : case C1(i) of
                     'I'  : chars(i) = '!9i!X'             ; Integral Sign
                     'X'  : chars(i) = '!9X!X'             ; Times Sign
                     '/'  : chars(i) = '/'                 ; Division Sign
                     'A'  : chars(i) = '!9A!X'             ; Approximately Equal
                     'Y'  : chars(i) = '!9d!X'             ; Partial Derivative
                     'Z'  : chars(i) = '!10g!X'            ; Del
                     'J'  : chars(i) = '!9J!X'             ; Line Integral
                     'P'  : chars(i) = '!20S!X'            ; Group Plus
                     '*'  : chars(i) = ''                  ; Group Multiply
                     'R'  : chars(i) = '!9?!X'             ; Proportional to
                     '+'  : chars(i) = '!9+!X'             ; Plus or Minus
                     '2'  : chars(i) = '!9S!X'             ; Square Root
                     'M'  : chars(i) = '!9l!X'             ; Less or Equal
                     'H'  : chars(i) = '!9b!X'             ; Greater or Equal
                     'N'  : chars(i) = '!9=!X'             ; Not Equal
                     '0'  : chars(i) = '!9$!X'             ; Infinity
                     else :
                     endcase

; Other Special Symbols

              else :
              endcase

              case C12(i) of
              'UW' : chars(i) = '!97!X'                    ; Up Arrow
              'DW' : chars(i) = '!95!X'                    ; Down Arrow
              'LW' : chars(i) = '!94!X'                    ; Left Arrow
              'RW' : chars(i) = '!96!X'                    ; Right Arrow
              'DP' : chars(i) = '!9O!X'                    ; Dagger
              'FP' : chars(i) = '!9o!X'                    ; Double Dagger
              'BS' : chars(i) = '!17<!X'                   ; Left Angle Bracket
              'ES' : chars(i) = '!17>!X'                   ; Right Angle Bracket
              '(S' : chars(i) = '!6[!X'                    ; Left Bracket
              ')S' : chars(i) = '!6]!X'                    ; Right Bracket
              'LS' : chars(i) = '!10[!X'                   ; Left Brace
              'RS' : chars(i) = '!10]!X'                   ; Right Brace
              'PP' : chars(i) = '!9&!X'                    ; New Paragraph
              'HK' : chars(i) = '!8h!X'                    ; H-Bar
              'LK' : chars(i) = '!4k!X'                    ; Lambda-Bar
              'DM' : chars(i) = '!9%!X'                    ; Degrees
              'UD' : chars(i) = '_'                        ; Underscore
              '/S' : chars(i) = '\'                        ; Backwards Slash
              else :
              endcase
         endfor

         TEXT = chars(0)
         for i=1,N_ELEMENTS(chars)-1 do TEXT = TEXT + chars(i)

         case Flag_TITLE of
              1    : PLOTkeys.XTITLE = TEXT
              2    : PLOTkeys.YTITLE = TEXT
              3    : PLOTkeys.TITLE  = TEXT
              4    : BEGIN
                   if (N_ELEMENTS(Position) gt 1) then begin
                        if (XYtext ne '') then $
                             XYOUTS, Position(0), Position(1), XYtext, $
                                  COLOR=!P.background, _EXTRA=EXTRAkeys
                        XYtext = TEXT
                        XYOUTS, Position(0), Position(1), XYtext,$
                                  _EXTRA=EXTRAkeys
                   endif else print,'Ignoring TOP DRAWER command: ',Var
                   END
              else : ABORT,'Invalid input argument value.'
         endcase

end


pro TOPDRAW, File1, PATH=Path, PRINT=Print_

         NP = N_PARAMS()
         if (NP eq 1) then File=File1 else File=''
         OS = STRUPCASE(STRMID(OS_FAMILY(),0,3))
         if (N_ELEMENTS(Path) eq 0) then CD,CURRENT=Path
         inf  = 100000L

FLOOP:   if (File eq '') then begin
              case OS of
                   'WIN'     : Filter='*.top'
                   'AIX'     : Filter='*.topdraw'
                   'MAC'     : Filter='*.topdraw'
                   else      : Filter='*.topdraw'
              endcase
              file  = PICKFILE(TITLE='Select TOP DRAWER File',$
                             FILTER=Filter, PATH=Path)
         endif

         if (file eq '') then return
         case OS of
              'WIN': delimiter = '\'
              'AIX': delimiter = '/'
              'MAC': delimiter = ':'
              else : delimiter = '/'
         endcase
         pos  = RSTRPOS(file,delimiter)
         if (pos eq -1) then Path='' else Path=STRMID(File,0,pos+1)

         openr, lui, file, /GET_LUN
         TOPline   = ''

         printout  = KEYWORD_SET(Print_)
         if printout then landscape,'ps' $
         else landscape, TITLE='Click on plot to continue...'

         DEFAULTS, PLOTkeys, OPLOTkeys, ERRkeys, HISTkeys, FLAGS=Flags
         SET_WINDOW, /DEFAULT
         X_minor   = !X.MINOR & !X.MINOR = 5
         Y_minor   = !Y.MINOR & !Y.MINOR = 5
         repeat begin

              repeat readf, lui, TOPline until ((TOPline ne '') or EOF(lui))

;   Read in any data

              NewDataBlock   = 0
              TOPparse  = STRPARSE(TOPline)

              Dataline  = VALIDNUM( TOPparse(0) )
              if Dataline then Data = '_NULL_'
              while (Dataline and (NOT EOF(lui))) do begin
                   ADD_DATA, TOPparse, data, ORDER=order             ; Data
                   readf, lui, TOPline
                   TOPparse  = STRPARSE(TOPline)
                   Dataline  = VALIDNUM( TOPparse(0) )
                   NewDataBlock   = 1
              endwhile
              if NewDataBlock then begin
                   here = WHERE(order(*,0) gt 0,nvec)
                   npts = N_ELEMENTS( data )
                   nrow = npts/nvec
                   Data = REFORM(Data, nvec, nrow, /OVERWRITE)
                   Data = TRANSPOSE( Data )
              endif

;   Convert TOPDRAWER commands to IDL

NEW_SEMI:     pos_semi  = STRPOS(TOPline,';')
              if (pos_semi ne -1) then begin
                   TOPparse  = STRPARSE(STRMID(TOPline,0,pos_semi))
                   TOPline2  = STRMID(TOPline,pos_semi+1,inf)
                   TOPline   = STRMID(TOPline,0,pos_semi+1)
              endif

              TOPflag   = STRUPCASE(STRMID(TOPparse(0),0,3))
              if (N_ELEMENTS(TOPparse) gt 1) then $
                   Var  = STRUPCASE(TOPparse(1:*))$
              else Var  =''

              case TOPflag of

;   SET commands

              'SET': BEGIN                                      ; SET
                   TOPflag2  = STRUPCASE(STRMID(TOPparse(1),0,3))
                   if (N_ELEMENTS(TOPparse) gt 2) then $
                        Var  = STRUPCASE(TOPparse(2:*)) $
                   else Var  = ''
                   case TOPflag2 of
                   'AXE': SET_AXES,    Var, PLOTkeys            ; AXES
                   'AXI': SET_AXES,    Var, PLOTkeys            ; AXIS
                   'BAR': SET_BAR,     Var, ERRkeys             ; BAR
                   'GRI': SET_GRID,    Var, PLOTkeys            ; GRID
                   'INT': SET_INTENSITY,Var,PLOTkeys,OPLOTkeys  ; INTENSITY
                   'LAB': SET_LABELS,  Var, PLOTkeys            ; LABELS
                   'LIM': SET_LIMITS,  Var, PLOTkeys            ; LIMITS
                   'ORD': SET_ORDER,   Var, Order               ; ORDER
                   'SCA': SET_SCALE,   Var, PLOTkeys            ; SCALE
                   'SYM': SET_SYMBOL,  Var, OPLOTkeys           ; SYMBOL
                   'TIC': SET_TICKS,   Var, PLOTkeys            ; TICKS
                   'TIT': SET_TITLE,   Var, PLOTkeys            ; TITLE
                   'WIN': BEGIN
                          SET_WINDOW,  Var                      ; WINDOW
                          Flags.OPLOT = 0
                          END
                   else :
                   endcase
                   END
              'SYM': SET_SYMBOL,  Var, OPLOTkeys                ; SYMBOL

;   DATA commands

              'BIN': BIN_,        Var, HISTkeys                 ; BIN
              'FRE': BIN_,        Var, HISTkeys                 ; FREQUENCY
              'SMO': SMOOTH_,     Var, Data                     ; SMOOTH
              'X'  : XYDXDY_,     Var, Data, 'X',  ORDER=Order  ; X
              'Y'  : XYDXDY_,     Var, Data, 'Y',  ORDER=Order  ; Y
              'DX' : XYDXDY_,     Var, Data, 'DX', ORDER=Order  ; DX
              'DY' : XYDXDY_,     Var, Data, 'DY', ORDER=Order  ; DY

;   ACTION commands

              'BAR': BEGIN                                      ; BARGRAPH
                   BARGRAPH_,     Var, Data, PLOTkeys, $
                                  OPLOTkeys, Flags.OPLOT
                   DEFAULTS, PLOTkeys, OPLOTkeys
                   PLOTkeys.NOERASE = 1
                   Flags.OPLOT = 1
                   END
              'CAS': CASE_, Var, TOPline, PLOTkeys, Flags.TITLE ; CASE
              'HIS': BEGIN                                      ; HISTOGRAM
                   HISTOGRAM_,    Var, Data, PLOTkeys, $
                                  OPLOTkeys, ERRkeys, $
                                  HISTkeys, Flags.OPLOT
                   DEFAULTS, PLOTkeys, OPLOTkeys, ERRkeys, HISTkeys
                   PLOTkeys.NOERASE = 1
                   Flags.OPLOT = 1
                   END
              'JOI': BEGIN                                      ; JOIN
                   JOIN_,         Var, Data, PLOTkeys, $
                                  OPLOTkeys, ERRkeys, Flags.OPLOT
                   DEFAULTS, PLOTkeys, OPLOTkeys, ERRkeys
                   PLOTkeys.NOERASE = 1
                   Flags.OPLOT = 1
                   END
              'MOR': MORE_, Var, TOPline, PLOTkeys, Flags.TITLE ; MORE
              'NEW': BEGIN                                      ; NEW FRAME
                   first_plot= !P.MULTI(0) eq 0
                   if (printout eq 0)            and $
                      (N_ELEMENTS(Data) gt 1)    and $
                      (first_plot)               then begin
                        cursor,dum,dum,/DOWN
                   endif
                   DEFAULTS, PLOTkeys, OPLOTkeys, ERRkeys, HISTkeys, FLAGS=Flags
                   SET_WINDOW, /DEFAULT
                   Data      = '_NULL_'
                   if (first_plot) then begin
                        plot,INDGEN(2),/NODATA,XSTYLE=4,YSTYLE=4
                        !P.MULTI(0) = 0
                   endif
                   END
              'PLO': BEGIN                                      ; PLOT
                   if (N_ELEMENTS( TOPparse ) gt 1) then begin
                   TOPflag2 = STRMID(Var(1),0,3)
                        case TOPflag2 of
                        'AXI': Nodata = 1                       ; AXIS
                        'AXE': Nodata = 1                       ; AXES
                        else : Nodata = 0
                        endcase
                   endif else Nodata = 0
                   PLOTkeys.NODATA     = Nodata
                   if Nodata then j=1 else j=0
                   PLOT_,         Var(j:*), Data, PLOTkeys, $
                                  OPLOTkeys, ERRkeys, Flags.OPLOT
                   DEFAULTS, PLOTkeys, OPLOTkeys, ERRkeys
                   PLOTkeys.NOERASE = 1
                   Flags.OPLOT = 1
                   END
              'TIT': BEGIN
                   TITLE_, Var, TOPline, PLOTkeys, Oflag_TITLE  ; TITLE
                   Flags.TITLE = Oflag_TITLE
                   END
              else : BEGIN
                   comment   = STRTRIM(TOPline,1)
                   if (STRMID(comment,0,1) eq '(') then print,comment
                   END
              endcase

              if (pos_semi ne -1) then begin
                   TOPline   = TOPline2
                   TOPparse  = STRPARSE(TOPline)
                   goto, NEW_SEMI
              endif

         endrep until EOF(lui)

         free_lun,lui

         if printout then landscape,'ps',/CLOSE,/HARDCOPY
         SET_WINDOW,/DEFAULT
         PLOTkeys =( OPLOTkeys =( ERRkeys =( HISTkeys=( Data=0 ))))
         !X.MINOR = X_minor
         !Y.MINOR = Y_minor

;   If interactive mode prompt for USER action

         if (NOT printout) then begin
              rp   = YNCANCEL('Print TOP DRAWER Plot(s)?',/LEFT,/TOP,$
                                  TITLE='TOP DRAWER for IDL')
              case rp of
                   1    : BEGIN
                        xmsg,'Processing TOP DRAWER PostScript file...', $
                             TITLE='TOP DRAWER message', $
                             /LEFT, /TOP, /NOBUTTON, MSG_ID = MSG_ID
                        TOPDRAW, File, /PRINT
                        WIDGET_CONTROL,MSG_ID,/DESTROY
                        END
                   0    :
                  -1    : return
              endcase
              File = ''
              goto, FLOOP
         endif
end
