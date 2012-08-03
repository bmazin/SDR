;-------------------------------------------------------------
;+
; NAME:
;       TETRIS
; PURPOSE:
;       Play tetris game.
; CATEGORY:
; CALLING SEQUENCE:
;       tetris
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         WAIT=tm  Seconds between pieces (def=.08).
;           tm = 0 is very fast, 0.1 is slow.
;         LEVEL=L  Level of random starting pieces (def=0).
;           If L is negative then starting pieces are gray.
;         /BELL means ring bell for each line scored.
;         TOP=tp returns highest level for each piece played.
;           Games are delimited by -1s.
; OUTPUTS:
; COMMON BLOCKS:
;       t_com
;       t_com
;       t_com
;       t_com
;       t_com
;       t_com
;       t_com
;       t_com
;       t_com
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner, 23 and 25 June, 1991
;       R. Sterner, 23 Jun, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
        pro t_init, wt, lev, bell=bell
 
        common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc, $
           t_init_flag
        ;--------  Common variables  -------------
        ;  t_nx, t_ny = X and Y size of playing board.
        ;  t_brd = playing board.
        ;  t_p = current playing piece (used only in t_next?).
        ;  t_seed = random seed used in t_next to get next piece.
        ;  t_r = current rotation (0-3).
        ;  t_x, t_y = current reference point. This is what drops each
        ;    cycle, and can be moved left and right.
        ;  t_pxa, t_pya = X and Y offset for all pieces.
        ;  t_px, t_py = X and Y offsets for current piece.
        ;  t_ca = colors for all pieces.
        ;  t_c = current piece color.
        ;  t_bell = Ring bell for each line scored?
        ;  t_wait = drop cycle delay time.
        ;  t_pflst = array of last element numbers for piece outlines.
        ;  t_pfxa, t_pfya = table of all piece outlines, all rotations.
        ;  t_pfx, t_pfy = current piece outline.
        ;  t_pc, t_lpc, t_hpc = # pieces: current game, last game, session.
        ;  t_ln, t_lln, t_hln = # lines: current game, last game, session.
        ;  t_sc, t_lsc, t_hsc = score: current game, last game, session.
        ;  t_init_flag = 1 if initialized once.
        ;-------------------------------------------------
 
	;--------  Fix for 24 bit color  -------------
	device, decomp=0		; Should restore when done (not yet).
 
        ;--------  init board  --------
        if n_elements(t_init_flag) eq 0 then t_init_flag = 0
	t_bell = 0
	if keyword_set(bell) then t_bell = 1	; Ring bell when line complete?
        if n_elements(wt) eq 0 then wt = -1.	; Time delay.
        if wt eq -1. then wt = 0.05		; Default time delay.
        t_wait = wt                 		; Wait in sec between drops.
        if n_elements(t_ln) eq 0 then t_ln = 0    ; Current game values.
        if n_elements(t_pc) eq 0 then t_pc = 0
        if n_elements(t_sc) eq 0 then t_sc = 0
        if n_elements(t_lln) eq 0 then t_lln = 0  ; Last game values.
        if n_elements(t_lpc) eq 0 then t_lpc = 0
        if n_elements(t_lsc) eq 0 then t_lsc = 0
        if n_elements(t_hln) eq 0 then t_hln = 0  ; Session High values.
        if n_elements(t_hpc) eq 0 then t_hpc = 0
        if n_elements(t_hsc) eq 0 then t_hsc = 0
 
        t_nx = 11                   		; Size in X. (+1)
        t_ny = 21                   		; Size in Y. (+1)
        t_brd = bytarr(t_nx-1, t_ny) 		; Board.
 
	;-----  Set up random starting pieces  -----
	;-----  If level < 0 then plot these pieces in gray (8) ----
	if abs(lev) gt 0 then begin
	  lset = (byte(randomu(i,t_nx-1,abs(lev))*8)<7B)* $
	         byte(randomu(i,t_nx-1,abs(lev)) gt .5)
          if lev lt 0 then lset = 8*(lset ne 0)          
	  t_brd(0,0) = lset
	endif
 
 
        ;--------  Set up piece color array  -------
        t_ca = [1,2,3,4,5,6,7,8]
 
        ;--------  Set up pieces  ------
        ;--------  As offsets:  ----------
        ;---  Set up X offsets for 7 4 part pieces, each with 4 rotations --
        t_pxa = intarr(4,4,7)
        t_pxa(0,0,0) = [[0,1,0,1], $   ; Piece # 0:  X X
                        [0,1,0,1], $   ;             X X
                        [0,1,0,1], $
                        [0,1,0,1]]
 
        t_pxa(0,0,1) = [[-2,-1,0,1], $ ; Piece # 1: X X X X
                        [0,0,0,0], $
                        [-2,-1,0,1],$
                        [0,0,0,0]]
 
        t_pxa(0,0,2) = [[-1,0,1,0], $  ; Piece # 2:  X X X
                        [0,0,0,1], $   ;               X
                        [-1,0,1,0], $
                        [0,0,0,-1]]
 
        t_pxa(0,0,3) = [[-1,0,0,1], $  ; Piece # 3:    X X
                        [0,0,-1,-1], $ ;                 X X
                        [0,-1,-1,-2], $
                        [-1,-1,0,0]]
 
        t_pxa(0,0,4) = [[-1,0,0,1], $  ; Piece # 4:      X X
                        [-1,-1,0,0], $ ;               X X
                        [0,-1,-1,-2], $
                        [0,0,-1,-1]]
 
        t_pxa(0,0,5) = [[-1,0,1,1],$   ; Piece # 5:    X X X
                        [0,0,0,1], $   ;                   X
                        [1,0,-1,-1], $
                        [0,0,0,-1]]
 
        t_pxa(0,0,6) = [[1,0,-1,-1],$  ; Piece # 6:    X X X
                        [0,0,0,1],$    ;               X
                        [-1,0,1,1],$
                        [0,0,0,-1]]
 
        ;---  Set up Y offsets for 7 4 part pieces, each with 4 rotations --
        t_pya = intarr(4,4,7)
 
        t_pya(0,0,0) = [[0,0,1,1],[0,0,1,1],[0,0,1,1],[0,0,1,1]]
        t_pya(0,0,1) = [[0,0,0,0],[-2,-1,0,1],[0,0,0,0],[-2,-1,1,0]]
        t_pya(0,0,2) = [[0,0,0,-1],[-1,0,1,0],[0,0,0,1],[1,0,-1,0]]
        t_pya(0,0,3) = [[0,0,-1,-1],[0,-1,-1,-2],[-1,-1,0,0],[-1,0,0,1]]
        t_pya(0,0,4) = [[-1,-1,0,0],[0,-1,-1,-2],[0,0,-1,-1],[-1,0,0,1]]
        t_pya(0,0,5) = [[0,0,0,-1],[-1,0,1,1],[0,0,0,1],[1,0,-1,-1]]
        t_pya(0,0,6) = [[0,0,0,-1],[1,0,-1,-1],[0,0,0,1],[-1,0,1,1]]
 
        ;------  Setup pieces as outlines  ---------
        t_pflst = [3,3,7,7,7,5,5]       ; Last outline point #.
        t_pfxa = intarr(8,4,7)
        t_pfxa(0,0,0) = [[0,2,2,0,0,0,0,0],$
                         [0,2,2,0,0,0,0,0],$
                         [0,2,2,0,0,0,0,0],$
                         [0,2,2,0,0,0,0,0]]
        t_pfxa(0,0,1) = [[-2,2,2,-2,0,0,0,0],$
                         [0,1,1,0,0,0,0,0],$
                         [-2,2,2,-2,0,0,0,0],$
                         [0,1,1,0,0,0,0,0]]
        t_pfxa(0,0,2) = [[-1,0,0,1,1,2,2,-1],$
                         [0,1,1,2,2,1,1,0],$
                         [-1,2,2,1,1,0,0,-1],$
                         [-1,0,0,1,1,0,0,-1]]
        t_pfxa(0,0,3) = [[-1,0,0,2,2,1,1,-1],$
                         [-1,0,0,1,1,0,0,-1],$
                         [-2,-1,-1,1,1,0,0,-2],$
                         [-1,0,0,1,1,0,0,-1]]
        t_pfxa(0,0,4) = [[-1,1,1,2,2,0,0,-1],$
                        [0,1,1,0,0,-1,-1,0],$
                        [-2,0,0,1,1,-1,-1,-2],$
                        [0,1,1,0,0,-1,-1,0]]
        t_pfxa(0,0,5) = [[-1,1,1,2,2,-1,0,0],$
                         [0,1,1,2,2,0,0,0],$
                         [-1,2,2,0,0,-1,0,0],$
                         [-1,1,1,0,0,-1,0,0]]
        t_pfxa(0,0,6) = [[-1,0,0,2,2,-1,0,0],$
                         [0,2,2,1,1,0,0,0],$
                         [-1,2,2,1,1,-1,0,0],$
                         [0,1,1,-1,-1,0,0,0]]
        t_pfya = intarr(8,4,7)
        t_pfya(0,0,0) = [[0,0,2,2,0,0,0,0],$
                         [0,0,2,2,0,0,0,0],$
                         [0,0,2,2,0,0,0,0],$
                         [0,0,2,2,0,0,0,0]]
        t_pfya(0,0,1) = [[0,0,1,1,0,0,0,0],$
                         [-2,-2,2,2,0,0,0,0],$
                         [0,0,1,1,0,0,0,0],$
                         [-2,-2,2,2,0,0,0,0]]
        t_pfya(0,0,2) = [[0,0,-1,-1,0,0,1,1],$
                         [-1,-1,0,0,1,1,2,2],$
                         [0,0,1,1,2,2,1,1],$
                         [0,0,-1,-1,2,2,1,1]]
        t_pfya(0,0,3) = [[0,0,-1,-1,0,0,1,1],$
                         [-2,-2,-1,-1,1,1,0,0],$
                         [0,0,-1,-1,0,0,1,1],$
                         [-1,-1,0,0,2,2,1,1]]
        t_pfya(0,0,4) = [[-1,-1,0,0,1,1,0,0],$
                         [-2,-2,0,0,1,1,-1,-1],$
                         [-1,-1,0,0,1,1,0,0],$
                         [-1,-1,1,1,2,2,0,0]]
        t_pfya(0,0,5) = [[0,0,-1,-1,1,1,0,0],$
                         [-1,-1,1,1,2,2,0,0],$
                         [0,0,1,1,2,2,0,0],$
                         [-1,-1,2,2,0,0,0,0]]
        t_pfya(0,0,6) = [[-1,-1,0,0,1,1,0,0],$
                         [-1,-1,0,0,2,2,0,0],$
                         [0,0,2,2,1,1,0,0],$
                         [-1,-1,2,2,1,1,0,0]]
 
        ;-------  Scale board to screen  --------
        plot,[0,t_nx-1],[0,t_ny-1],position=[.1,.1,.4,.9],/xsty,/ysty,/nodata
        ;-------  Outline board  -----------------
        erase
        polyfill, [-1,t_nx, t_nx, -1], [-1, -1, t_ny, t_ny], $
          color=10
        polyfill, [-1,t_nx, t_nx, -1], [-1, -1, t_ny, t_ny], $
          color=9, spacing=.15, orient=0
        polyfill, [-1,t_nx, t_nx, -1], [-1, -1, t_ny, t_ny], $
          color=9, spacing=.15, orient=90
        polyfill,[-.2,t_nx-.8,t_nx-.8,-.2],$
          [-.2,-.2,t_ny-.8,t_ny-.8]
        polyfill,[0,1,1,0]*(t_nx-1),[0,0,1,1]*(t_ny-1), color=0
	plots,[-1,t_nx,t_nx,-1,-1],[-1,-1,t_ny,t_ny,-1],thick=3
 
	;------  Show starting board  --------
	if abs(lev) gt 0 then begin
	  for iy = 0, abs(lev) do begin
	    for ix = 0, t_nx-2 do begin
	      c = t_brd(ix,iy)
	      polyfill, [0,1,1,0]+ix, [0,0,1,1]+iy, color=c
	    endfor
	  endfor
	endif
 
        ;------  Menu  -----
        if t_init_flag eq 0 then begin
          sprint,size=1.2, 325, 310, 'A = Move left'
          sprint,size=1.2, 475, 310, 'L = Move right'
          sprint,size=1.2, 325, 290, 'SPACE = Rotate'
          sprint,size=1.2, 475, 290, 'H = Help'
          sprint,size=1.2, 325, 270, 'S = Start'
          sprint,size=1.2, 475, 270, 'Q = Quit'
          sprint,size=1.2, 325, 250, 'P = (un)Pause'
;        xyouts, 350-25, 280+30, /dev, size=1.2, '!3A = Move left'
;        xyouts, 475, 280+30, /dev, size=1.2, 'L = Move right'
;        xyouts, 350-25, 260+30, /dev, size=1.2, 'SPACE = Rotate'
;        xyouts, 475, 260+30, /dev, size=1.2, 'H = Help'
;        xyouts, 475, 240+30, /dev, size=1.2, 'Q = Quit'
;        xyouts, 350-25, 240+30, /dev, size=1.2, 'S = Start'
;        xyouts, 350-25, 220+30, /dev, size=1.2, 'P = Pause/unpause'
 
          sprint,size=1.8, 310,160, 'Pieces'
          sprint,size=1.8, 310,130, 'Lines'
          sprint,size=1.8, 310,100, 'Score'
          sprint,size=1.2, 410,210, 'This'
          sprint,size=1.2, 410,190, 'Game'
          sprint,size=1.2, 480,210, 'Last'
          sprint,size=1.2, 480,190, 'Game'
          sprint,size=1.2, 550,210, 'Session'
          sprint,size=1.2, 550,190, 'High'
;        xyouts, 420, 190, 'Game', size=1.8, /dev
;        xyouts, 520, 190, 'Session', size=1.8, /dev
;        xyouts, 320, 160, 'Pieces:',size=1.8, /dev
;        xyouts, 320, 130, 'Lines:',size=1.8, /dev
;        xyouts, 320, 100, 'Score:',size=1.8, /dev
 
          sprint,size=1.2,410,160,strtrim(t_pc,2)
          sprint,size=1.2,410,130,strtrim(t_ln,2)
          sprint,size=1.2,410,100,strtrim(t_sc,2)
          sprint,size=1.2,480,160,strtrim(t_lpc,2)
          sprint,size=1.2,480,130,strtrim(t_lln,2)
          sprint,size=1.2,480,100,strtrim(t_lsc,2)
          sprint,size=1.2,550,160,strtrim(t_hpc,2)
          sprint,size=1.2,550,130,strtrim(t_hln,2)
          sprint,size=1.2,550,100,strtrim(t_hsc,2)
 
          t_init_flag = 1
        endif else sprint
 
       t_pc = 0	; Current score.
       t_ln = 0
       t_sc = 0
       sprint,16,strtrim(t_pc,2)
       sprint,17,strtrim(t_ln,2)
       sprint,18,strtrim(t_sc,2)
 
;        xyouts, /dev, 420, 160, size=1.8, strtrim(t_pc,2)
;        xyouts, /dev, 520, 160, size=1.8, strtrim(t_hpc,2)
;        xyouts, /dev, 420, 130, size=1.8, strtrim(t_ln, 2)
;        xyouts, /dev, 520, 130, size=1.8, strtrim(t_hln, 2)
;        xyouts, /dev, 420, 100, size=1.8, strtrim(t_sc, 2)
;        xyouts, /dev, 520, 100, size=1.8, strtrim(t_hsc, 2)
 
 
        ;-------  Load color table  --------
        tvlct, $
          [0,255,255,127,255,127,255,127,128,255,  0,  0,255,255,255,255],$
          [0,127,127,255,255,127,189,255,128,255,  0,255,  0,255,255,255],$
          [0,127,255,255,127,255,127,127,128,255,255,233,  0,  0,  0,255]
 
        ;---------  Make title  --------
        xyouts, 25+300, 400+15, /dev, size=3, '!17IDL Tetris', color=10
        xyouts, 25+301, 401+15, /dev, size=3, '!17IDL Tetris', color=10
        xyouts, 25+302, 402+15, /dev, size=3, '!17IDL Tetris', color=11
        xyouts, 25+303, 403+15, /dev, size=3, '!17IDL Tetris', color=11
        xyouts, 25+304, 404+15, /dev, size=3, '!17IDL Tetris', color=12
        xyouts, 25+305, 405+15, /dev, size=3, '!17IDL Tetris', color=12
        xyouts, 25+306, 406+15, /dev, size=3, '!17IDL Tetris', color=13
        xyouts, 25+307, 407+15, /dev, size=3, '!17IDL Tetris', color=13
 
        xyouts, /dev, size=2, 23+392, 370+13, '!13by', color=12
        xyouts, /dev, size=2, 23+342, 336+13, '!13Ray Sterner!3', color=12
        xyouts, /dev, size=2, 24+392, 370+14, '!13by', color=12
        xyouts, /dev, size=2, 24+342, 336+14, '!13Ray Sterner!3', color=12
        xyouts, /dev, size=2, 25+392, 370+15, '!13by', color=6
        xyouts, /dev, size=2, 25+342, 336+15, '!13Ray Sterner!3', color=6
 
 
        return
        end
 
;======================================================================
;--------  t_next = get next piece ready  ------
;       R. Sterner, 23 Jun, 1991
 
        pro t_next, pn
 
        common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        if n_elements(pn) eq 0 then begin
          t_p = byte(randomu(t_seed)*7)  ; Pick a random piece #.
        endif else t_p = pn          ; Use selected piece number.
        t_r = 0                      ; Start in standard position.
        t_c = t_ca(t_p)              ; Look up piece color.
        t_px = t_pxa(*, t_r, t_p)    ; Pull out correct offsets.
        t_py = t_pya(*, t_r, t_p)
        t_pfx = t_pfxa(0:t_pflst(t_p),t_r,t_p)    ; Extract outline.
        t_pfy = t_pfya(0:t_pflst(t_p),t_r,t_p)
        t_x = t_nx/2                 ; Starting position.
        t_y = t_ny
 
        return
        end
 
;======================================================================
;-------  t_drop = drop a piece one position  ------
;       R. Sterner, 23 Jun, 1991
 
        pro t_drop, done=done, range=range
 
       common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        t_plot, 0       ; Erase current position.
        t_y = t_y - 1   ; Drop one position.
 
        flag = 0                                ; Undo flag.
        if min(t_y + t_py) lt 0 then flag = 1   ; Hit bottom.
        if max(t_brd(t_x+t_px, t_y+t_py)) gt 0 then flag = 1    ; Collision.
 
        done = 0                                ; Assume not done yet.
        if flag eq 1 then begin                 ; Done.
          t_y = t_y + 1                         ; Can't move down.
          t_brd(t_x+t_px, t_y+t_py) = t_c       ; Update board with color.
          done = 1                              ; Set done flag.
          range = [min(t_y+t_py), max(t_y+t_py)]  ; Range to check.
        endif
 
        t_plot, 1       ; Plot new position.
        wait, t_wait
 
        return
        end
 
;======================================================================
;-------  t_left = move piece one position left ------
;       R. Sterner, 23 Jun, 1991
 
        pro t_left
 
        common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        t_plot, 0                               ; Erase current position.
 
        t_x = t_x - 1                           ; Shift left 1.
 
        flag = 0                                ; Undo flag.
        if min(t_x + t_px) lt 0 then flag = 1   ; Out of bounds.
        if max(t_brd(t_x+t_px, t_y+t_py)) gt 0 then flag = 1    ; Collision.
 
        if flag eq 1 then t_x = t_x + 1         ; Undo.
 
        t_plot, 1                               ; Plot new position.
 
        return
        end
 
 
;======================================================================
;-------  t_right = move piece one position right ------
;       R. Sterner, 23 Jun, 1991
 
        pro t_right
 
        common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        t_plot, 0             ; Erase current position.
 
        t_x = t_x + 1         ; Shift right 1.
                              
        flag = 0              ; Undo flag.
        if max(t_x + t_px) gt (t_nx-2) then flag = 1    ; Out of bounds.
        if max(t_brd(t_x+t_px, t_y+t_py)) gt 0 then flag = 1    ; Collision.
 
        if flag eq 1 then t_x = t_x - 1                 ; Undo.
 
        t_plot, 1                                       ; Plot new position.
 
        return
        end
 
;======================================================================
;-------  t_rot = rotate a piece one position  ------
;       R. Sterner, 23 Jun, 1991
 
        pro t_rot
 
        common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        t_plot, 0               ; Erase current position.
 
        t_r = (t_r + 1) mod 4   ; Rotate.
        t_px = t_pxa(*,t_r,t_p) ; Extract new offsets.
        t_py = t_pya(*,t_r,t_p)
        t_pfx = t_pfxa(0:t_pflst(t_p),t_r,t_p)    ; Extract outline.
        t_pfy = t_pfya(0:t_pflst(t_p),t_r,t_p)
 
        ;----  Check for out of bounds or collision. -----
        flag = 0                ; Undo flag.
        ;------  Don't rotate out the sides  ---------
        if (min(t_x+t_px) lt 0) or (max(t_x+t_px) gt (t_nx-2)) then flag = 1
        ;------  Don't rotate out the bottom  -----
        if (min(t_y+t_py) lt 0) then flag = 1
        ;------  Check collision with another piece  ------
        if max(t_brd(t_x+t_px, t_y+t_py)) gt 0 then flag = 1    ; Collision.
        if flag eq 1 then begin    ; Undo.
          t_r = (t_r + 3) mod 4    ; Rotate 270 = -90.
          t_px = t_pxa(*,t_r,t_p)  ; Extract new offsets.
          t_py = t_pya(*,t_r,t_p)
          t_pfx = t_pfxa(0:t_pflst(t_p),t_r,t_p)    ; Extract outline.
          t_pfy = t_pfya(0:t_pflst(t_p),t_r,t_p)
        endif
 
        t_plot, 1               ; Plot new position.
 
        return
        end
 
;======================================================================
;------  t_plot.pro = Erase or draw current tetris piece  ---------
;       R. Sterner, 23 Jun, 1991
 
        pro t_plot, flag
 
        common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        c = 0
        if flag eq 1 then c = t_c
 
        if max(t_y+t_pfy) lt t_ny then begin
          polyfill, t_x+t_pfx, t_y+t_pfy, color=c
        endif
 
        return
        end
 
;======================================================================
;-------  t_score = Look for and process a score.  ------
;       R. Sterner, 23 Jun, 1991
 
        pro t_score, r
 
        common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        ;---------  Add score for this piece  --------
;        xyouts, 420, 100, /dev, size=1.8, strtrim(t_sc,2), color=0
        t_sc = t_sc + 7      ; Each piece worth 7 pts.
        sprint,18, strtrim(t_sc, 2)
;        xyouts, 420, 100, /dev, size=1.8, strtrim(t_sc,2)
 
        count = 0                                 ; Lines scored on piece.
        rn = (r(0)+indgen(r(1)-r(0)+1))<(t_ny-1)  ; Range to check.
        for i = 0, n_elements(rn)-1 do begin      ; Check each line.
          if total(t_brd(*,rn(i)) eq 0) eq 0 then begin  ; Score.
           ;---  light up score line  ----
            xp = [0.01,.99,.99,0.01]*(t_nx-1)
            yp = [0.05,0.05,.99,.99]+rn(i)
            polyfill, xp,yp,color=0,spacing=.1,orient=0
            polyfill, xp,yp,color=0,spacing=.1,orient=90
            wait, 0
            ;---  ring bell  -----
            if t_bell then print,string(7b),form='($,a1)'
            ;---  Collapse board  -------
            t_brd(0,rn(i)) = t_brd(*,(rn(i)+1):*)
            ;---  Repaint screen board  -----
            tmp = fltarr(t_ny)
            for j = 0, t_ny-1 do tmp(j) = total(t_brd(*,j))
            mx = 1+max(where(tmp ne 0))
            for z = 0.8, 0., -.2 do begin
            for iy = rn(i), mx do begin
              for ix = 0, t_nx-2 do begin
                c = t_brd(ix,iy)
                polyfill, [0,1,1,0]+ix, (z+[0,0,1,1]+iy)<(t_ny-1), color=c
              endfor
            endfor
            endfor  ; Z
            ;---  Decrement range  ------
            rn = rn - 1
            ;----  Count scored line  -----
            count = count + 1
            ;---  Update score board  -----
;            xyouts, 420, 130, /dev, size=1.8, strtrim(t_ln,2), color=0
            t_ln = t_ln + 1
            sprint,17, strtrim(t_ln,2)
;            xyouts, 420, 130, /dev, size=1.8, strtrim(t_ln,2)
;            xyouts, 420, 100, /dev, size=1.8, strtrim(t_sc,2), color=0
            t_sc = t_sc + 22      ; Each line worth 22 pts.
            sprint,18,strtrim(t_sc,2)
;            xyouts, 420, 100, /dev, size=1.8, strtrim(t_sc,2)
           endif
        endfor
       
        ;--------  Check for a tetris (4 lines scored on 1 piece) ----
        if count eq 4 then begin
;          xyouts, 420, 100, /dev, size=1.8, strtrim(t_sc,2), color=0
          t_sc = t_sc + 48      ; 48 extra points.
          sprint,18,strtrim(t_sc,2)
;          xyouts, 420, 100, /dev, size=1.8, strtrim(t_sc,2)
        endif
 
        return
        end
 
;======================================================================
;-------  t_help.pro = display help text  --------
;       R. Sterner, 4 Aug, 1991
 
        pro t_help
 
        if !version.os eq 'DOS' then device, set_display=2
        print,' '
        print,' Tetris has 7 different playing pieces which drop down'
        print,' from the top of the screen. Points are scored by'
        print,' fitting these pieces together to form horizontal rows'
        print,' having no gaps. Such complete rows dissolve away and add'
        print," to the player's score. Pieces may be moved left and right"
        print,' and rotated to fit together. The more rows completed the'
        print,' higher the score each newly completed row is worth.'
        print,' Extra credit is given for completing 4 rows at the same'
        print,' time.  Upper or lower case key commands may be used, except'
        print,' that the Q (quit) command must be upper case.'
        print,' Both the current game scores and the highest score during'
        print,' the current session of IDL are displayed.'
        print,' '
        print,' The first version of this project was written using PC IDL'
        print,' in an afternoon as a test of the capabilities of IDL on a'
        print,' 386 class machine.'
        print,' 
        txt = ''
        read,' Press RETURN to continue', txt
        if !version.os eq 'DOS' then device, set_display=3
        return
        end
 
;======================================================================
;;------  tetris.pro main tetris routine  ------
;       R. Sterner, 23 Jun, 1991
 
        pro tetris, wait=wt, level=lev, help=hlp, bell=bell, $
          top=top
 
       common t_com, t_nx, t_ny, t_brd, t_p, t_seed, t_r, t_x, t_y, $
           t_pxa, t_pya, t_px, t_py, t_ca, t_c, $
           t_bell, t_wait, t_pflst, t_pfxa, t_pfya, t_pfx, t_pfy, $
           t_pc, t_lpc, t_hpc, t_ln, t_lln, t_hln, t_sc, t_lsc, t_hsc
 
        if keyword_set(hlp) then begin
          print,' Play tetris game.'
          print,' tetris'
	  print,' Keywords:'
	  print,'   WAIT=tm  Seconds between pieces (def=.08).'  
          print,'     tm = 0 is very fast, 0.1 is slow.'
	  print,'   LEVEL=L  Level of random starting pieces (def=0).'
          print,'     If L is negative then starting pieces are gray.'
	  print,"   /BELL means ring bell for each line scored."
          print,'   TOP=tp returns highest level for each piece played.'
          print,'     Games are delimited by -1s.'
          return
        endif
 
        if n_elements(wt) eq 0 then wt = -1.
        if wt eq -1. then wt = 0.08
	if n_elements(lev) eq 0 then lev = 0
 
        top = [-1]      ; Start TOP array.
 
start:  t_init, wt, lev, bell=bell
 
        ;-------  Find top  ----------
        tmp = fltarr(t_ny)
        for j = 0, t_ny-1 do tmp(j) = total(t_brd(*,j))
        mx = 1+max(where(tmp ne 0))
        top = [top,mx]
 
rd:     k = get_kbrd(1)
        if (k eq 'H') or (k eq 'h') then begin
          t_help
          goto, rd
        endif
        if k eq 'Q' then return
	if k ne 's' then goto, rd
 
loop1:  t_next
 
loop2:  k = get_kbrd(0)              ; Get key.
        ku = strupcase(k)            ; Upper case version.
        if k eq ' ' then t_rot       ; Rotate.
        if ku eq 'A' then t_left     ; Move left.
        if ku eq 'L' then t_right    ; Move right.
        if k eq 'Q' then goto, over  ; Game over.
        if ku eq 'P' then begin      ; Pause.
          k = get_kbrd(1)
          goto, loop2
        endif
        t_drop, done=d, range=r      ; Drop piece.
 
        if d eq 1 then begin              ; Piece done moving.
          ;-------  Find top  ----------
          tmp = fltarr(t_ny)
          for j = 0, t_ny-1 do tmp(j) = total(t_brd(*,j))
          mx = 1+max(where(tmp ne 0))
          top = [top,mx]
          if min(r) ge t_ny-1 then begin  ; Game over?
           goto, over
          endif 
          ;------  Update current piece count  ------
;          xyouts, /dev, 420, 160, size=1.8, strtrim(t_pc,2),color=0
          t_pc = t_pc + 1
          sprint,16,strtrim(t_pc,2)
;          xyouts, /dev, 420, 160, size=1.8, strtrim(t_pc,2)
          t_score, r                      ; Update score.
          goto, loop1
        endif
 
        goto, loop2
 
        ;------  Game over  -------
over:   polyfill, [0,1,1,0]*(t_nx-1), [0,0,1,1]*(t_ny-1),$
          color=0, spacing=.1, orient=0
        polyfill, [0,1,1,0]*(t_nx-1), [0,0,1,1]*(t_ny-1),$
          color=0, spacing=.1, orient=90
 
        ;--------  Wait for another start command.  ------
loopw:  k = get_kbrd(1)
        ku = strupcase(k)
 
        ;---------  Update session max and last game values.  -----
        if (ku eq 'S') or (ku eq 'Q') then begin
          t_lpc = t_pc
          t_lln = t_ln
          t_lsc = t_sc
          sprint,19,strtrim(t_lpc,2)
          sprint,20,strtrim(t_lln,2)
          sprint,21,strtrim(t_lsc,2)
;          xyouts,/dev,size=1.8,520,160,strtrim(t_hpc,2),color=0
          t_hpc = t_hpc > t_pc 
;          xyouts,/dev,size=1.8,520,160,strtrim(t_hpc,2)
;          xyouts,/dev,size=1.8,520,130,strtrim(t_hln,2),color=0
          t_hln = t_hln > t_ln 
;          xyouts,/dev,size=1.8,520,130,strtrim(t_hln,2)
;          xyouts,/dev,size=1.8,520,100,strtrim(t_hsc,2),color=0
          t_hsc = t_hsc > t_sc 
;          xyouts,/dev,size=1.8,520,100,strtrim(t_hsc,2)
          sprint,22,strtrim(t_hpc,2)
          sprint,23,strtrim(t_hln,2)
          sprint,24,strtrim(t_hsc,2)
        endif
 
        ;---------  Handle S or Q  ---------
        if ku eq 'S' then begin
          t_init, wt, lev, bell=bell
          top = [top,-1]
          ;-------  Find top  ----------
          tmp = fltarr(t_ny)
          for j = 0, t_ny-1 do tmp(j) = total(t_brd(*,j))
          mx = 1+max(where(tmp ne 0))
          top = [top,mx]
          goto, loop1
        endif
        if ku ne 'Q' then goto, loopw
 
        end
 
