;-------------------------------------------------------------
;+
; NAME:
;       VARY
; PURPOSE:
;       Execute IDL code varying parameters using sliders.
; CATEGORY:
; CALLING SEQUENCE:
;       vary
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /LAST execute last setup if any.
; OUTPUTS:
; COMMON BLOCKS:
;       vary_com
; NOTES:
;       Notes: Useful to execute IDL code or a routine using
;       a number of parameters with various values.  The parameters
;       may be given sliders that can vary their values.  Also
;       up to 5 existing variable may be specified as part of
;       the IDL code to execute.  The variables and slider
;       parameters are indicated in the IDL code text using special
;       characters to tag each: variables start with # and
;       slider parameters start with $.  Example IDL code:
;         tv,shift(#img1,$xshift,$yshift),chan=2
;       The image in img1 will be shifted by xshift and yshift
;       (controlled by 2 sliders) and displayed in the green channel.
;       This routine will prompt for the IDL code text and the
;       min, max, and default for each slider parameter.
;       The IDL code may also be a call to a procedure, so complex
;       operations are possible.  The entered IDL code will be
;       modified: the variables will be replaced with P1, P2, ...
;       and the $ tags for the parameters will be dropped when
;       the code is displayed in the slider widget.
; MODIFICATION HISTORY:
;       R. Sterner, 2005 May 13
;       R. Sterner, 2005 Jul 11 --- Added /uniq to slider param call.
;
; Copyright (C) 2005, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro vary, last=last, help=hlp
 
	common vary_com, ctxt0, prng0
 
	if keyword_set(hlp) then begin
	  print,' Execute IDL code varying parameters using sliders.'
	  print,' vary'
	  print,'   Inputs are prompted for.'
	  print,' Keywords:'
	  print,'   /LAST execute last setup if any.'
	  print,' Notes: Useful to execute IDL code or a routine using'
	  print,' a number of parameters with various values.  The parameters'
	  print,' may be given sliders that can vary their values.  Also'
	  print,' up to 5 existing variable may be specified as part of'
	  print,' the IDL code to execute.  The variables and slider'
	  print,' parameters are indicated in the IDL code text using special'
	  print,' characters to tag each: variables start with # and'
	  print,' slider parameters start with $.  Example IDL code:'
	  print,'   tv,shift(#img1,$xshift,$yshift),chan=2'
	  print,' The image in img1 will be shifted by xshift and yshift'
	  print,' (controlled by 2 sliders) and displayed in the green channel.'
	  print,' This routine will prompt for the IDL code text and the'
	  print,' min, max, and default for each slider parameter.'
	  print,' The IDL code may also be a call to a procedure, so complex'
	  print,' operations are possible.  The entered IDL code will be'
	  print,' modified: the variables will be replaced with P1, P2, ...'
	  print,' and the $ tags for the parameters will be dropped when'
	  print,' the code is displayed in the slider widget.'
	  return
	endif
 
	;--------------------------------------------------------
	;  Upgrade notes
	;
	;  Use xtxtin to get code to execute.  Then it can be
	;  edited somewhat.
	;  Better use xtxtin for parameters too.  Or better,
	;  make a simple entry widget with parameter name and
	;  labeled areas for min, max, def, and a checkbox for
	;  int.  Like:
	;-----------------------------------------------------------------.
	;  xshift: Min _____  Max _____ Default ____ Integer? O   OK Quit |
	;-----------------------------------------------------------------'
 
	;--------------------------------------------------------
	;  Get IDL code to execute
	;
	;  For /LAST reprocess last entered code to pick up
	;  any changed variables.
	;--------------------------------------------------------
	if keyword_set(last) then begin		; Do last command.
	  if n_elements(ctxt0) eq 0 then begin	; Was none.
	    print,' Error in vary: No last code to execute.'
	    print,' Must enter something before last command may be used.'
	    return
	  endif
	  ctxt = ctxt0				; Copy entered code.
	  goto, prvar				; Jump to process variables.
	endif
	ctxt = ''
cloop:	print,' '
	print,' Enter IDL code to execute (? for help).'
	print,' Tag variables with # and slider parameters with $.'
	print,' Example: tv,shift(#img1,$xshift,$yshift),chan=2'
	read,' IDL Code: ',ctxt
	if ctxt eq '' then return
	if ctxt eq '?' then begin
	  print,' Example code: tv,shift(#img1,$xshift,$yshift),chan=2'
	  goto, cloop
	endif
	ctxt0 = ctxt				; Save in common.
 
	;--------------------------------------------------------
	;  Find variables and grab copies
	;
	;  Variables in the IDL code text are grabbed from the
	;  calling level (1 up) and placed into p1, p2, ...
	;--------------------------------------------------------
prvar:	taggedwords,ctxt,tag='#',vars,count=nvars,/uniq	; Find variables.
	if nvars gt 0 then begin			; Found some variables.
	  for i=0,nvars-1 do begin			; Process each one.
	    nam = vars(i)				; Variable name.
	    val = scope_varfetch(nam,lev=-1)		; Get a copy from above.
	    pnam = 'P'+strtrim(i+1,2)			; New name: P1,P2,...
	    cmd = pnam+'=temporary(val)'		; Put in P1,p2,...
	    err = execute(cmd)
	    ctxt = stress(ctxt,'R',0,'#'+nam,pnam)	; Rename to P1,P2,...
	  endfor
	endif
 
	;--------------------------------------------------------
	;  Find parameters and set values
	;--------------------------------------------------------
	taggedwords,ctxt,tag='$',par,count=npar,/rem,/uniq ; Find parameters.
	if keyword_set(last) then begin		; Do last command.
	  prng = prng0				; Use last par ranges.
	  goto, eqv				; Jump to eq execute.
	endif
	if npar eq 0 then begin			; No params.
	  print,' Error in vary: No parameters to vary found.'
	  print,'   Come back when you have something to vary.'
	  return
	endif
	prng = strarr(npar)
	txt = ''
	print,' For each parameter listed below enter 3 values:'
	print,'   min_range, max_range, default'
	print,' Example: -100 100 0 [int]'
	print,' May also add int to end to force to integer value.'
	print,' '
	for i=0,npar-1 do begin			; Process each one.
ploop:	  read,' '+par(i)+': ',txt
	  if txt eq '' then begin
	    print,' To abort enter Q'
	    goto, ploop
	  endif
	  if strupcase(txt) eq 'Q' then return
	  prng(i) = 'par: '+par(i)+' '+txt
	endfor
	prng0 = prng			; Save in common.
 
	;--------------------------------------------------------
	;  Pack up text array and send to eqv3
	;--------------------------------------------------------
eqv:	t = ['eq: '+ctxt,prng]
	eqv3, t, p1=p1,p2=p2,p3=p3,p4=p4,p5=p5,/wait
 
	end
