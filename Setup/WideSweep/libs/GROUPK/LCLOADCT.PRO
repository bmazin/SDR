
;+
; NAME:
;        LCLOADCT
;
; PURPOSE:
;        Defines the color palette used by LIGHT_CURVE and other plotting routines.
;
; CATEGORY:
;        Image Display.
;
; CALLING SEQUENCE:
;
;        LCLOADCT
;
; OPTIONAL INPUT KEYWORDS:
;
;        UNLOAD    : Set this keyword to unload the LIGHT_CURVE color table
;                    and restore the B-W LINEAR color table.
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, May 1994.
;-
pro LCLOADCT,UNLOAD=unload

    common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
    common lc_colors, ncolors, linecolors, black, cyan, white

    if keyword_set( UNLOAD ) then begin
         loadct, 0  ;load B-W color table
         ncolors = 0 & linecolors = 0 & black = 0 & cyan = 0 & white=0
         return
    endif

    pastels = 18
    loadct, pastels   ; load the pastels pre-defined color table

    indices = [   3, 235, 230, 225, 223, 211, 185, 150, $ ; These point to various
                139, 132, 122,  95,  79,  63, 31 , $      ; colors on the pastels
                  5, 237, 232, 227, 225, 213, 187, 152, $ ; palette
                142, 134, 124,  97,  81,  65, 33 , $
                  7, 237, 232, 227, 225, 213, 187, 152, $
                144, 136, 126,  99,  83,  67, 35   ]

    ni        = N_ELEMENTS( indices )
    nrgb      = ni+2
    r_curr    = intarr( nrgb )
    g_curr    = intarr( nrgb )
    b_curr    = intarr( nrgb )

    r_curr(0) = 0       ; black
    g_curr(0) = 0
    b_curr(0) = 0

    r_curr(1:ni) = r_orig( indices )
    g_curr(1:ni) = g_orig( indices )
    b_curr(1:ni) = b_orig( indices )

    r_curr(ni+1) = 255  ; white
    g_curr(ni+1) = 255
    b_curr(ni+1) = 255

    tvlct, r_curr, g_curr, b_curr  ; load this more limited color table

    black = 0
    cyan  = 9
    white = nrgb-1

;   Now define the sequence of line colors to be used if we need to
;   overplot additional curves

    linecolors = [        1,             5,            7,           11, $
    ;                   red,        yellow,        green,         blue,

                         12,             3,            6,           10, $
    ;                purple,        orange, green-yellow,   light-blue,

                         14,             4,            8,           11, $
    ;               magenta, yellow-orange,   blue-green, light purple,

                          2,            15, $
    ;           dark-orange,      red-pink
                       1+15,          5+15,         7+15,        11+15, $
                      12+15,          3+15,         6+15,        10+15, $
                      14+15,          4+15,         8+15,        11+15, $
                       2+15,         15+15, $
                       1+30,          5+30,         7+30,        11+30, $
                      12+30,          3+30,         6+30,        10+30, $
                      14+30,          4+30,         8+30,        11+30, $
                       2+30,         15+30  ]

    ncolors = N_ELEMENTS( linecolors )

end
