;-------------------------------------------------------------
;+
; NAME:
;       INTERPX_DEMO
; PURPOSE:
;       Demonstrate the use of interpx.
; CATEGORY:
; CALLING SEQUENCE:
;       interpx_demo
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: the routine interpx may be used to interpolate
;         across bad points and/or data gaps.  Example calls
;         are shown by this routine.
; MODIFICATION HISTORY:
;       R. Sterner, 7 Sep, 1993
;
; Copyright (C) 1993, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro interpx_demo, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Demonstrate the use of interpx.'
	  print,' interpx_demo'
	  print,'   No args.
	  print,' Notes: the routine interpx may be used to interpolate'
	  print,'   across bad points and/or data gaps.  Example calls'
	  print,'   are shown by this routine.'
	  return
	endif
 
 
	;--------  Make a data set to interpolate  -----------
;	y0=makey(500,25,100,40,0)	   	; Original data.
	y0=makey(500,25)*200		   	; Original data.
	y = y0					; Copy to corrupt.
	k = 0
	r=randomu(k,50)*500			; Indices of bad points.
	y(r)=1000				; Flag bad points with 1000.
	x0=maken(10,30,500)			; Make x array.
	x = x0
	x=[x(0:100),x(130:300),x(330:*)]	; Add data gaps.
	y=[y(0:100),y(130:300),y(330:*)]
 
	;-------- Plot data  --------------
	printat,1,1,/clear
	print,' '
	print,' This demonstrates the use of the interpolation routine'
	print,' interpx.  This routine may be used to interpolate across'
	print,' bad data points and/or flag data gaps so they may be dropped'
	print,' from plots.  This routine will be demonstrated on an example'
	print,' data set.'
	print,' '
	print,' The current plot shows the example data set uncorrupted.'
	plot,x0,y0
	txt = ''
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' The corrupted data has two flaws: bad points and gaps.'
	print,' The bad points have been flagged with 1000.  These'
	print,' points are selected and flagged by some previous user'
	print,' processing. The gaps may be hard to see in this plot but'
	print,' occur from about 14 to 15.1 and 21.9 to 23.2.'
	plot,x,y
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' The plot keyword MAX_VALUE allows one to specify the maximum'
	print,' valid plot value, higher values of y are ignore and the'
	print,' the plot curve is broken where those values occur.'
	print,' An improved plot may be obtained by the command:'
	print,' plot,x,y,max_value=900'
	plot,x,y,max_value=900
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' The gaps may show better in this plot:
	print,' plot,x,y,max_value=900,psym=3'
	print,' where data gaps are just some interval without data, the'
	print,' length is user specified.'
	plot,x,y,max_value=900,psym=3
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' The routine interpx may be used to deal with both bad points'
	print,' and data gaps. This routine interpolates a given curve, x and'
	print,' y, at a set of specified x positions.  In this example the'
	print,' interpolated x positions will have half the spacing of the'
	print,' original data.  Call the interpolated x positions xx.'
	print,' There happened to be 500 points in the original curve.'
	print,' xx may be made as follows: xx=maken(10,30,1000).'
	print,' If the data had no bad points the interpolation could be'
	print,' done as: yy = interpx(x,y,xx), but in this example the bad'
	print,' points would be used in the interpolation giving poor results.'
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' Interpx may be informed of the bad points by the keyword'
	print,' BAD=v where v is LESS THAN the flag value (1000'
	print,' in this example).  So yy=interpx(x,y,xx,bad=999) will work.'
	print,' plot,xx,yy,max=998 shows the interpolated data.'
	print,' Requested values that could not be interpolated due to'
	print,' bad points are flagged with the given value of BAD so'
	print,' MAX_VALUE may be used on the plot command as shown.'
	print,' Note that due to the LESS THAN requirement of both MAX_VALUE'
	print,' for plot and BAD for interpx there is a downward creep of'
	print,' flag values.  This probably causes the most confusion in the'
	print,' use of interpx, so be careful.'
	xx = maken(10,30,1000)
	plot,xx,interpx(x,y,xx,bad=999),max=998
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' Bad points may be interpolated across using the interpx'
	print,' keyword /FIXBAD: yy=interpx(x,y,xx,bad=999,/fixbad)'
	print,' and plotted as: plot,xx,yy (note, there are no longer bad
	print,' points to flag so max_values is not needed on plot).'
	plot,xx,interpx(x,y,xx,bad=999,/fixbad)
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' Using points as plot symbols shows the interpolated x values'
	print,' to be evenly spaced.  Also note that any data gaps are'
	print,' naturally interpolated across.'
	plot,xx,interpx(x,y,xx,bad=999,/fixbad),psym=3
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' Gaps may be preserved by giving a gap size to interpx:'
	print,' yy = interpx(x,y,xx,bad=999,/fixbad, gap=1)'
	print,' where the value given for the GAP keyword is the maximum'
	print,' allowed distance between x values (in data units, not samples)'
	print,' in the input curve.  The gaps in the example data are roughly'
	print,' 1.2 units long, so a value of 1 will work.  The interpolated'
	print,' values inside a gap are set to the flag value (BAD if given,'
	print,' else 32000), as shown in the plot.'
	plot,xx,interpx(x,y,xx,bad=999,/fixbad,gap=1)
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' The MAX_VALUE keyword of plot may again be used to skip'
	print,' over the gaps: plot,xx,yy,max_value=998'
	plot,xx,interpx(x,y,xx,bad=999,/fixbad,gap=1), max=998
	print,' '
	read,' Press RETURN to continue (Q to quit)',txt
	if strupcase(txt) eq 'Q' then return
	print,' '
	print,' Bad points and data gaps are handled independently by'
	print,' interpx.  To skip over both bad points and data gaps just'
	print,' drop the /FIXBAD keyword from the last interpolation command:'
	print,' yy = interpx(x,y,xx,bad=999,gap=1)'
	print,' and plot with a MAX_VALUE: plot,xx,yy,max_value=998'
	plot,xx,interpx(x,y,xx,bad=999,gap=1), max=998
	print,' '
	print,' End of interpx demo.'
	print,' '
	
	return
	end
