;+
; NAME:
;        MRK_RECT
;
; PURPOSE:
;        Allows the USER to interactively position and size a rectangle
;        on an existing plot.
;
; CATEGORY:
;        Graphics.
;
; CALLING SEQUENCE:
;
;        Result = MRK_RECT( [Window] )
;
; OPTIONAL INPUTS:
;
;        Window:   Index of the plot window that the rectangle is to be drawn in.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;        STATUS:   Set this keyword to display the coordinates of the current
;                  cursor position in the lower left-hand corner of the plot
;                  window. (0=Default)
;
;        ERASE:    Set this keyword to erase the rectangle and status
;                  coordinates after the position and size of the rectangle
;                  has been selected. (0=Default)
;
;        HELP:     Set this keyword to display a instruction window on how
;                  to interactively position the rectangle on the plot.
;                  (0=Default)
;
;        DATA:     Set this keyword to display and return rectangle position
;                  in data coordinates. (1=Default)
;
;        NORMAL:   Set this keyword to display and return rectangle position
;                  in normalized coordinates. (0=Default)
;
;        DEVICE:   Set this keyword to display and return rectangle position
;                  in device coordinates. (0=Default)
;
; OUTPUTS:
;        Returns the position of the rectanlge in the coordinates specified
;        USER (DATA=Default).  Result(*,0) = [X0,Y0] is the position of the
;        first corner.  Result(*,1) = [X1,Y1] is the position of the
;        diagonally opposite corner.
;
; EXAMPLE:
;        plot,indgen(100)
;        rect_position = MRK_LINE(/HELP)
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;        17-JUN-1995    Small bug-fix, TITLE of instructions incorrect (Mrk_Line)
;        10-SEP-1996    Display status before setting point.
;-
function MRK_RECT, Window, STATUS=Status, ERASE=Erase, HELP=Help, $
                   NORMAL=NORMAL_, DEVICE=DEVICE_, DATA=DATA_

         NP=N_PARAMS()

         if !D.WINDOW eq -1 then message,'No existing plot.'
         if NP eq 0 then Window=!D.WINDOW

         wset, Window
         wshow, Window

         if (NOT keyword_set(NORMAL_)) and $
            (NOT keyword_set(DEVICE_)) and $
            (NOT keyword_set(DATA_)) then DATA_ = 1
         LINESTYLE = 0                                ; solid line
         COLOR     = !D.N_COLORS-1                    ; white (B-W Linear)
         statline  = ''

;   Save original window

         orig_plot = tvrd()

;   Display HELP instructions

         if keyword_set( HELP ) then begin
              object = 'rectangle'
              instr  = ['1. Place the mouse pointer within the plot',$
                        'area and then press and hold mouse button 1',$
                        'to mark a corner of the '+object+'.',$
                        '',$
                        '2. Move the mouse until the '+object+' is at',$
                        'the desired size.',$
                        '',$
                        '3. Release the mouse button.']
              xmsg, instr, TITLE='Mrk_Rect Instruction',/NOBUTTON, $
                   /LEFT, /TOP, MSG_ID=Msg_ID, /ALIGN
         endif

 ;   Define active plot region

         Xleft   = !X.MARGIN(0)*!D.X_CH_SIZE
         Xright  = !D.X_SIZE - !X.MARGIN(1)*!D.X_CH_SIZE
         Ybottom = !Y.MARGIN(0)*!D.Y_CH_SIZE
         Ytop    = !D.Y_SIZE - !Y.MARGIN(1)*!D.Y_CH_SIZE
         Rmargin = [[Xleft,Ybottom],[Xright,Ytop]]
         Rmargin = CONVERT_COORD( Rmargin, /DEVICE, TO_DATA=DATA_, $
                                  TO_DEVICE=DEVICE_, TO_NORMAL=NORMAL_ )

         DEVICE, GET_GRAPHICS_FUNCTION=GXsave, $
                 SET_GRAPHICS_FUNCTION=6         ; Exclusive OR existing pixels

;   Make sure first point is within the plot region

         repeat begin
            repeat begin
                 CURSOR,X0,Y0,/CHANGE,DATA=DATA_,DEVICE=DEVICE_,NORMAL=NORMAL_
                 DX = (X0 - Rmargin(0,0))*(Rmargin(0,1) - X0)
                 DY = (Y0 - Rmargin(1,0))*(Rmargin(1,1) - Y0)
                 if KEYWORD_SET(STATUS) then begin
                      XYOUTS,0,0,/NORMAL,statline   ; erase old status line
                      statline = '('+arr2str(X0,4)+','+arr2str(Y0,4)+')'
                      XYOUTS,0,0,/NORMAL,statline
                 endif
            endrep until (!ERR eq 1)
         endrep until (DX gt 0) and (DY gt 0)

;   Draw first rectangle

         R = [X0,Y0]
         plots,R,DATA=DATA_,DEVICE=DEVICE_,NORMAL=NORMAL_,$
              LINESTYLE=LINESTYLE,COLOR=COLOR
         if keyword_set(STATUS) then begin
              XYOUTS,0,0,/NORMAL,statline   ; erase old status line
              statline = '('+arr2str(X0,4)+','+arr2str(Y0,4)+')'
              XYOUTS,0,0,/NORMAL,statline
         endif
         Rlast = CONVERT_COORD( X0,Y0, DATA=DATA_, DEVICE=DEVICE_,$
                   NORMAL=NORMAL_, /TO_DEVICE)
         Rsign = SIGN(Rlast(0)) or SIGN(Rlast(1))

;   Loop until USER releases mouse button 1

         while (!err) or (Rsign lt 0) do begin

              CURSOR, X1,Y1, /CHANGE, DATA=DATA_,DEVICE=DEVICE_,NORMAL=NORMAL_
              Rcurr = CONVERT_COORD( X1,Y1, DATA=DATA_, $
                             DEVICE=DEVICE_, NORMAL=NORMAL_, /TO_DEVICE)
              Rcurr = ROUND(Rcurr)          ; Round to nearest pixel

              dR        = TOTAL(ABS(Rcurr - Rlast))
              Rsign     = SIGN(Rcurr(0)) or SIGN(Rcurr(1))
              if (dR gt 0) and (Rsign gt 0) then begin

                   ;  Make sure coordinates are within plot region

                   X1 = X1 > Rmargin(0,0)
                   X1 = X1 < Rmargin(0,1)
                   Y1 = Y1 > Rmargin(1,0)
                   Y1 = Y1 < Rmargin(1,1)

                   ;    erase previous rectangle

                   plots,R,DATA=DATA_,DEVICE=DEVICE_,NORMAL=NORMAL_,$
                        LINESTYLE=LINESTYLE,COLOR=COLOR

                   ;    draw new rectangle

                   R = [ [X0,Y0], [X1,Y0], [X1,Y1], [X0,Y1], [X0,Y0] ]
                   plots,R,DATA=DATA_,DEVICE=DEVICE_,NORMAL=NORMAL_,$
                        LINESTYLE=LINESTYLE,COLOR=COLOR

                   if keyword_set(STATUS) then begin
                        XYOUTS,0,0,/NORMAL,statline         ; erase old status line
                        statline = '('+arr2str(X1,4)+$
                                      ','+arr2str(Y1,4)+')'
                        XYOUTS,0,0,/NORMAL,statline         ; draw new status line
                   endif

                   Rlast = Rcurr

              endif
         endwhile

;   Restore plot window

         DEVICE,SET_GRAPHICS_FUNCTION=GXsave     ; OVERWRITE existing pixels

         tv, orig_plot
         if NOT keyword_set(ERASE) then $
              plots,R,DATA=DATA_,DEVICE=DEVICE_,NORMAL=NORMAL_,$
                        LINESTYLE=LINESTYLE,COLOR=COLOR

         if keyword_set(HELP) then WIDGET_CONTROL,Msg_ID, /DESTROY
         wshow,Window

;   Return position of rectangle

         return, [[X0,Y0],[X1,Y1]]

end
