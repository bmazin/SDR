;+
; NAME:
;        MRK_LINE
;
; PURPOSE:
;        Allows the USER to interactively position a line on an existing plot.
;
; CATEGORY:
;        Graphics.
;
; CALLING SEQUENCE:
;
;        Result = MRK_LINE( [Window] )
;
; OPTIONAL INPUTS:
;
;        Window:   Index of the plot window that the line is to be drawn in.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        STATUS:   Set this keyword to display the coordinates of the current
;                  cursor position in the lower left-hand corner of the plot
;                  window. (0=Default)
;
;        ERASE:    Set this keyword to erase the line and status coordinates
;                  after the position of the line has been selected. (0=Default)
;
;        HELP:     Set this keyword to display a instruction window on how
;                  to interactively position the line on the plot. (0=Default)
;
;        VERTICAL: Set this keyword to position a vertical line. (0=Default)
;
;        HORIZONTAL:    Set this keyword to position a horizontal line. (0=Default)
;
;        DATA:     Set this keyword to display and return line position in
;                  data coordinates. (1=Default)
;
;        NORMAL:   Set this keyword to display and return line position in
;                  normalized coordinates. (0=Default)
;
;        DEVICE:   Set this keyword to display and return line position in
;                  device coordinates. (0=Default)
;
; OUTPUTS:
;        Returns the position of the line in the coordinates specified by the
;        USER (DATA=Default) as a (2,2) dimensioned array or a scalar if
;        the horizontal or vertical keyword is set.  If a vertical line is selected,
;        then the X-coordinate of that line is returned.  If a horizontal line is
;        selected then the Y-coordinate of that line is returned. Otherwise, the
;        (*,0) array specifies the position, (X0,Y0) of the "LEFT" endpoint, and
;        the (*,1) array specifies the position, (X1,Y1) of the "RIGHT" endpoint.
;
; EXAMPLE:
;        plot,indgen(100)
;        x_position = MRK_LINE(/VERTICAL,/HELP)
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;        07-SEP-1996    Draw an ARBITRARY line by default.
;        10-SEP-1996    Display status before setting point.
;-
function MRK_LINE, Window, STATUS=Status, ERASE=Erase, HELP=Help, $
                   VERTICAL=Vertical, HORIZONTAL=Horizontal, $
                   NORMAL=Normal_, DEVICE=Device_, DATA=Data_

         NP=N_PARAMS()

         if !D.WINDOW eq -1 then message,'No existing plot.'
         if NP eq 0 then Window=!D.WINDOW

         wset, Window
         wshow, Window

         if (NOT KEYWORD_SET(Normal_)) and $
            (NOT KEYWORD_SET(Device_)) and $
            (NOT KEYWORD_SET(Data_)) then Data_ = 1
         LINESTYLE = 0                                ; solid line
         COLOR     = !D.N_COLORS-1                    ; white (B-W Linear)
         statline  = ''

;   Save original window

         orig_plot = tvrd()

         Orientation = 0
         if KEYWORD_SET( Horizontal) then Orientation = 1
         if KEYWORD_SET( Vertical  ) then Orientation = 2

;   Display Help instructions

         if KEYWORD_SET( Help ) then begin
              object = 'line'
              instr  = ['1. Place the mouse pointer within the plot',$
                        'area and then press and hold mouse button 1.',$
                        '',$
                        '2. Move the mouse until the '+object+' is in',$
                        'the desired location.', $
                        '',$
                        '3. Release the mouse button.']
              xmsg, instr, TITLE='Mrk_Line Instruction',/NOBUTTON, $
                   /LEFT, /TOP, MSG_ID=Msg_ID, /ALIGN
         endif

         DEVICE, GET_GRAPHICS_FUNCTION=GXsave, $
                 SET_GRAPHICS_FUNCTION=6         ; Exclusive OR existing pixels

;   Define active plot region

         Xleft   = !X.MARGIN(0)*!D.X_CH_SIZE
         Xright  = !D.X_SIZE - !X.MARGIN(1)*!D.X_CH_SIZE
         Ybottom = !Y.MARGIN(0)*!D.Y_CH_SIZE
         Ytop    = !D.Y_SIZE - !Y.MARGIN(1)*!D.Y_CH_SIZE
         Rmargin = [[Xleft,Ybottom],[Xright,Ytop]]
         Rmargin = CONVERT_COORD( Rmargin, /DEVICE, TO_DATA=Data_, $
                                  TO_DEVICE=Device_, TO_NORMAL=Normal_ )
         R       = Rmargin

;   Make sure first point is within the plot region

         repeat begin
              repeat begin
                   CURSOR,X0,Y0,/CHANGE,DATA=Data_,DEVICE=Device_,NORMAL=Normal_
                   DX = (X0 - Rmargin(0,0))*(Rmargin(0,1) - X0)
                   DY = (Y0 - Rmargin(1,0))*(Rmargin(1,1) - Y0)
                   if KEYWORD_SET(STATUS) then begin
                        XYOUTS,0,0,/NORMAL,statline   ; erase old status line
                        statline = '('+arr2str(X0,4)+','+arr2str(Y0,4)+')'
                        XYOUTS,0,0,/NORMAL,statline
                   endif
              endrep until (!ERR eq 1)
         endrep until (DX gt 0) and (DY gt 0)

;   Draw first line

         CASE Orientation OF
         0    : BEGIN
                   R(*,0) = [X0,Y0,0]
                   R(*,1) = [X0,Y0,0]
                END
         1    : R(1,*)  = Y0
         2    : R(0,*)  = X0
         ENDCASE
         plots,R,DATA=Data_,DEVICE=Device_,NORMAL=Normal_,$
              LINESTYLE=LINESTYLE, COLOR=COLOR
         if KEYWORD_SET(STATUS) then begin
              XYOUTS,0,0,/NORMAL,statline         ; erase old status line
              statline = '('+arr2str(X0,4)+','+arr2str(Y0,4)+')'
              XYOUTS,0,0,/NORMAL,statline
         endif
         Rlast = CONVERT_COORD( X0,Y0, DATA=Data_, DEVICE=Device_,$
                   NORMAL=Normal_, /TO_DEVICE)
         Rsign = SIGN(Rlast(0)) or SIGN(Rlast(1))

;   Loop until USER releases mouse button 1

         while (!err) or (Rsign lt 0) do begin

              CURSOR, X1,Y1, /CHANGE, DATA=Data_,DEVICE=Device_,NORMAL=Normal_
              Rcurr = CONVERT_COORD( X1,Y1, DATA=Data_, $
                             DEVICE=Device_, NORMAL=Normal_, /TO_DEVICE)
              Rcurr = ROUND(Rcurr)          ; Round to nearest pixel

              dR        = TOTAL(ABS(Rcurr - Rlast))
              Rsign     = SIGN(Rcurr(0)) or SIGN(Rcurr(1))
              if (dR gt 0) and (Rsign gt 0) then begin

                   ;  Make sure coordinates are within plot region

                   X1 = X1 > Rmargin(0,0)
                   X1 = X1 < Rmargin(0,1)
                   Y1 = Y1 > Rmargin(1,0)
                   Y1 = Y1 < Rmargin(1,1)

                   ; erase previous line then draw a new one

                   plots,R,DATA=Data_,DEVICE=Device_,NORMAL=Normal_,$
                        LINESTYLE=LINESTYLE, COLOR=COLOR

                   CASE Orientation OF
                   0    : R(*,1)  = [X1,Y1,0]
                   1    : R(1,*)  = Y1
                   2    : R(0,*)  = X1
                   ENDCASE
                   plots,R,DATA=Data_,DEVICE=Device_,NORMAL=Normal_,$
                        LINESTYLE=LINESTYLE, COLOR=COLOR

                   if KEYWORD_SET(STATUS) then begin
                        XYOUTS,0,0,/NORMAL,statline         ; erase old status line
                        statline = '('+arr2str(X1,4)+$
                                      ','+arr2str(Y1,4)+')'
                        XYOUTS,0,0,/NORMAL,statline         ; draw new status line
                   endif

                   Rlast = Rcurr
              endif
         endwhile

;   Restore plot window

         DEVICE,SET_GRAPHICS_FUNCTION=GXsave     ; Restore previous graphics fcn

         tv, orig_plot
         if NOT KEYWORD_SET(ERASE) then $
              plots,R,DATA=Data_,DEVICE=Device_,NORMAL=Normal_,$
                   LINESTYLE=LINESTYLE, COLOR=COLOR

         if KEYWORD_SET(Help) then WIDGET_CONTROL,Msg_ID, /DESTROY
         wshow,Window

;   Return position of line

         CASE Orientation OF
         0    : BEGIN
                   R0   = R(0:1,0)
                   R1   = R(0:1,1)
                   if (X0 gt X1) then R = [[R1],[R0]] else R = [[R0],[R1]]
                   return, R
                END
         1    : return, Y1
         2    : return, X1
         ENDCASE
end
