;-------------------------------------------------------------
;+
; NAME:
;       RGB
; PURPOSE:
;       Explore RGB color system.
; CATEGORY:
; CALLING SEQUENCE:
;       rgb
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: R,G, and B may be varied by key presses.
;         Has a simple color matching mode.
;         Press ? for commands.
; MODIFICATION HISTORY:
;       R. Sterner, 1994 Jan 19
;
; Copyright (C) 1994, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro rgb, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Explore RGB color system.'
	  print,' rgb'
	  print,'   No arguments.'
	  print,' Notes: R,G, and B may be varied by key presses.'
	  print,'   Has a simple color matching mode.'
	  print,'   Press ? for commands.'
	  return
	endif
 
	window,0,xs=300,ys=600, title='Explore RGB color system'
	loadct,0
	tv,bytarr(300,300)+255,0
	b = bytarr(100,100)+1
	tv,b,100,100
	tv,b,100,400
 
	r = 255
	g = 0
	b = 0
	tvlct,r,g,b,1
 
	print,' '
	print,' Explore RGB color system'
	print,' Allows colors to be created by varying the amount of red,'
	print,'   green, and blue which is displayed.'
	print,' Press ? for commands (Q to quit).'
	print,' '
 
	repeat begin
	  k = strupcase(get_kbrd(1))
	  case k of
'R':	    r = (r+1)<255
'G':	    g = (g+1)<255
'B':	    b = (b+1)<255
'E':	    r = (r-1)>0
'F':	    g = (g-1)>0
'V':	    b = (b-1)>0
'T':	    r = (r+10)<255
'H':	    g = (g+10)<255
'N':	    b = (b+10)<255
'W':	    r = (r-10)>0
'D':	    g = (g-10)>0
'C':	    b = (b-10)>0
'O':	    tvlct,0,0,0
'M':	    tvlct,byte(randomu(s)*256),$
		  byte(randomu(s)*256),$
		  byte(randomu(s)*256)
'?':	    begin
	      print,' '
	      print,' Explore RGB color system'
	      print,' Keys to change value by: -10  -1  +1 +10'
	      print,'                 For Red:   W   E   R   T'
	      print,'                   Green:   D   F   G   H'
	      print,'                    Blue:   C   V   B   N'
	      print,' To restore original background (black): O'
	      print,' To make a random background to match:   M'
	      print,' To print these commands:                ?'
	      print,' To Quit:                                Q'
	    end
else:
	  endcase
	  tvlct,r,g,b,1
	  print,r,g,b,form="(x,'R: ',I3,'  G: ',I3,'  B: ',I3)"
	endrep until k eq 'Q'
	
	return
	end
