;+
; NAME:
;        WHEREGION
;
; PURPOSE:
;        This function returns an array of indices corresponding to the
;        array elements that lie within a region marked interactively
;        by the USER.
;
; CATEGORY:
;        Graphics.
;
; CALLING SEQUENCE:
;
;        Result = WHEREGION( [X,] Y [,Count] )
;
; INPUTS:
;        Y:        1-D array.
;
; OPTIONAL INPUTS:
;        X:        1-D array of same dimension as Y.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        HELP:     Set this keyword to display a instruction window on how
;                  to interactively position the rectangle on the plot.
;                  (0=Default)
;
;        Any KEYWORDS provided will be directly passed to the PLOT routine.
;        Thus, any of PLOT's graphics keywords may be used.
;
; OUTPUTS:
;        Returns an array of indices pointing to the array elements that
;        lie within the USER specified region. (Similar to the WHERE function.)
;
; OPTIONAL OUTPUTS:
;
;        Count:    A named variable that, on exit, is set to the number of
;                  array elements that lie within the USER specified region.
;                  This value is returned as a longword integer.
;
; EXAMPLE:
;        ;Define an array of times
;        t = findgen(100)
;
;        ;Now select region between 0 and 50 by clicking in the
;        ;appropriate plotting region.
;        here = WHEREGION( t )
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, February 1995.
;        17-JUN-1995    Rewritten to use MRK_RECT and to do multiple selections.
;                       Used _EXTRA keyword to pass all graphics keywords to PLOT.
;        31-OCT-1995    Added the Count output variable.
;        10-SEP-1996    Allow USER-defined XRANGE and YRANGE keywords, added HELP
;                       keyword
;-
function WHEREGION, X1, Y, Count, ANONYMOUS_=Dummy_, _EXTRA=PLOT_KEYWORDS, $
         XRANGE=Xrange, YRANGE=Yrange, HELP=Help

         NP   = N_PARAMS()

         if (NP lt 1) or (NP gt 3) then $
              message,'Must be called with 1-3 parameters: [X,] Y [, Count]'

         szx  = SIZE(X1)
         if (szx(0) ne 1) then message,'Must be called with 1-d array(s)'

         X    = X1
         nx   = N_ELEMENTS(x)
         ny   = N_ELEMENTS(y)

         if (N_ELEMENTS(Xtitle)   eq 0) then Xtitle=''
         if (N_ELEMENTS(Ytitle)   eq 0) then Ytitle=''
         if (N_ELEMENTS(Title)    eq 0) then Title=''
         if (N_ELEMENTS(Subtitle) eq 0) then Subtitle=''
         if (N_ELEMENTS(Psym)     eq 0) then Psym=0
         if (N_ELEMENTS(Xrange)   eq 0) then Xrange=[MIN(X,MAX=xmax)]
         if (N_ELEMENTS(Yrange)   eq 0) then Yrange=[MIN(Y,MAX=xmax)]
         if ((NP eq 2) and (nx ne ny)) OR (NP eq 1) then begin
              Y=X
              X=findgen(nx)
              if (Xtitle eq '') then Xtitle='Bin Number'
         endif
         nplots = !P.MULTI(1)*!P.MULTI(2) > 1
         xrng = Xrange
         yrng = Yrange

;   Setup UNDO information

         x_undo = REFORM([xrng],2,1)
         y_undo = REFORM([yrng],2,1)
         n_undo = 1

         if !D.WINDOW eq -1 then Window,0,TITLE='Please Select Region'
         if (nplots gt 1) then begin
              if (!P.multi(0) eq 0) then ERASE
              init   = tvrd()
         endif

;   Plot initial data

         plot, X, Y, _EXTRA=PLOT_KEYWORDS, $
              XRANGE=xrng, YRANGE=yrng, /XSTYLE, /YSTYLE

;   Loop for USER's Selected Region

         Actions   = ['Select Again',$
                      'Undo Selection',$
                      'Done with Selection']
         rp        = 0

         repeat begin
              if (rp eq 0) then begin
                   r    = MRK_RECT(HELP=Help,/STATUS)
                   xrng = REFORM(r(0,*))
                   yrng = REFORM(r(1,*))
                   xrng = xrng(SORT(xrng))       ; Make sure we have
                   yrng = yrng(SORT(yrng))       ;    correctly ordered ranges

              endif

              if (nplots gt 1) then tv,init       ;Restore original plots

              !P.MULTI(0) = (!P.MULTI(0)+1) MOD nplots
              here = WHERE( (X ge xrng(0))  and (X le xrng(1))  and $
                            (Y ge yrng(0))  and (Y le yrng(1)), npts )
              if (npts eq 0) then goto, NOPTS

              plot, X(here), Y(here), _EXTRA=PLOT_KEYWORDS, $
                   XRANGE=xrng, YRANGE=yrng, /XSTYLE, /YSTYLE

              rp   = XBUTTON( Actions, TITLE='WHEREgion Menu', $
                              /LEFT, /TOP, /COLUMN )

RETRY:        case rp of
                   0    : begin
                     x_undo = [REFORM(x_undo,2*n_undo),xrng]    ;Save UNDO
                     y_undo = [REFORM(y_undo,2*n_undo),yrng]    ; information
                     n_undo = n_undo + 1
                     x_undo = REFORM(x_undo,2,n_undo)
                     y_undo = REFORM(y_undo,2,n_undo)
                     end
                   1    : begin                  ;UNDO current selection
                     xrng   = x_undo(*,n_undo-1)
                     yrng   = y_undo(*,n_undo-1)
                     n_undo = (n_undo-1) > 1
                     x_undo = x_undo(*,0:n_undo-1)
                     y_undo = y_undo(*,0:n_undo-1)
                     end
                   2    : begin
NOPTS:               if (npts eq 0) then begin
                          rpq = YNCANCEL(['No Points in Selected Region.',$
                                  'Continue Anyway?'],TITLE='WHEREgion WARNING')
                          if (rpq ne 1) then begin
                             rp = 1
                             goto, RETRY
                          endif
                     endif
                     end
              endcase
         endrep until (rp eq 2)

         Count     = npts
         if (NP eq 2) and (nx ne ny) then Y = Count
         return, here
end
