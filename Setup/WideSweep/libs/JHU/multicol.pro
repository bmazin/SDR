;-------------------------------------------------------------
;+
; NAME:
;       MULTICOL
; PURPOSE:
;       Reformat a string array into multi-columns.
; CATEGORY:
; CALLING SEQUENCE:
;       out = multicol(in)
; INPUTS:
;       in = input 1-d string array to reformat.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         LINES=ln how many lines per page (def=50).
;           This is in addition to a page number and column headers.
;         COLUMNS=col how many columns per page (def=2).
;         SPACES=sp array of spaces before each column (def=none).
;           Reuses last element repeatedly if needed.
;         HEADER=h column header string array, must be
;           same width as IN, getting this right may be tricky.
;         /PAGE means print page number.
;         TOP=txt Line of text for top of each page.
; OUTPUTS:
;       out = reformated string array.            out
;         2-d array: out(lines, pages), so
;         out(*,0) is first page.
; COMMON BLOCKS:
; NOTES:
;       Notes: input string array may already have several
;         columns of text. For example: let A and B be 1-d
;         arrays, like fltarr(20).  Let SA=string(transpose(A)),
;         and SB=string(transpose(b)).  Then S=SA+SB is a one
;         column string array with A(i) and B(i) in each element.
;         S may be sent to MULTICOL to reformat to several columns.
; MODIFICATION HISTORY:
;       R. Sterner, 20 Sep, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function multicol, in, lines=lines, columns=columns, spaces=spaces, $
	  header=head, page=page, top=top, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Reformat a string array into multi-columns.'
	  print,' out = multicol(in)'
	  print,'   in = input 1-d string array to reformat.  in'
	  print,'   out = reformated string array.            out'
	  print,'     2-d array: out(lines, pages), so'
	  print,'     out(*,0) is first page.'
	  print,' Keywords:'
	  print,'   LINES=ln how many lines per page (def=50).'
	  print,'     This is in addition to a page number and column headers.'
	  print,'   COLUMNS=col how many columns per page (def=2).'
	  print,'   SPACES=sp array of spaces before each column (def=none).'
	  print,'     Reuses last element repeatedly if needed.'
          print,'   HEADER=h column header string array, must be'
          print,'     same width as IN, getting this right may be tricky.'
          print,'   /PAGE means print page number.'
          print,'   TOP=txt Line of text for top of each page.'
	  print,' Notes: input string array may already have several'
	  print,'   columns of text. For example: let A and B be 1-d'
	  print,'   arrays, like fltarr(20).  Let SA=string(transpose(A)),'
	  print,'   and SB=string(transpose(b)).  Then S=SA+SB is a one'
	  print,'   column string array with A(i) and B(i) in each element.'
	  print,'   S may be sent to MULTICOL to reformat to several columns.'
	  return, ''
	endif
 
	;-------  Make sure parameters are defined  ------
	if n_elements(lines) eq 0 then lines = 50	; Def = 50 lines/page.
	if n_elements(columns) eq 0 then columns = 2	; Def = 2 columns.
	if n_elements(spaces) eq 0 then spaces = [0]	; Def = no margin.
        if n_elements(page) eq 0 then page = 0		; Def = no page nums.
	topflag = 0					; Assume no top line.
        if n_elements(top) ne 0 then topflag = 1	; There is a top line.
	toppage = topflag OR page			; Top line or page?
 
	nsa = n_elements(in)		; Number of elements in input array.
	lsp = n_elements(spaces)-1	; Last index in SPACE.
	npp = lines*columns		; Number of items per page.
	pages = ceil(float(nsa)/npp)	; Number of pages needed.
        if n_elements(head) eq 0 then begin
          hflag = 0
          nhd = 0
        endif else begin
          hflag = 1
          nhd = n_elements(head)
        endelse
 
	;------  Fix up input array a bit  -------
	sa = [in(0:*),'']		; Add element # nsa = null.
 
	;------  Setup output array  ---------
	out = strarr(lines+toppage+nhd, pages)
 
	;------  Loop through pages  ---------
	for ip = 0, pages-1 do begin
	  ;------  Add top line and page number if needed  ------
	  if topflag then txt = spc(spaces(0))+top else txt = spc(50+spaces(0))
          if page then txt = txt + 'Page '+strtrim(ip+1,2)
          if toppage then out(0,ip) = txt
	  llo = ip*npp			; Index of 1st item in SA on 1st line.
	  lhi = llo + lines - 1		; Index of 1st item in SA on last line.
          ;-------  Loop through header lines  ---------
          for ih = 0, nhd-1 do begin
            txt = ''
            ;---------  Loop through header columns  ----
	    for ic = 0, columns-1 do begin
	      ;-----  Add leading spaces and element from head -----
	      txt = txt+spc(spaces(ic<lsp))+head(ih)
            endfor ; ic. End columns loop.
	    out(ih+toppage, ip) = txt	; Insert completed line in output.
          endfor ; ih. End header lines.
	  ;-------  Loop through lines on a page  ------
	  for il = llo, lhi do begin
	    txt = ''			; Start with a blank line.
	    ;------  Loop through columns  -------
	    for ic = 0, columns-1 do begin
	      ;-----  Add leading spaces and element from SA  -----
	      txt = txt+spc(spaces(ic<lsp))+sa((il+ic*lines)<nsa)
	    endfor ; ic. End columns loop.
	    out(il-llo+nhd+toppage, ip) = txt  ; Insert line in output.
	  endfor ; il. End lines loop.
	endfor ; ip. End pages loop.
 
	return, out
 
	end
