;-------------------------------------------------------------
;+
; NAME:
;       LECTURE
; PURPOSE:
;       Select specified lecture notes from a notes file.
; CATEGORY:
; CALLING SEQUENCE:
;       lecture, notes, slides, lect
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /NOCOMMENTS doesn't pass comments from slides file'
;            on to lecture file.
;         /NONUMBERS doesn't pass slide numbers from slides file'
;            on to lecture file.
;         /ONELINE uses first note line to make a one line listing.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       notes = name of notes file.              in
;           File format:  Slide id lines must start in column 1,
;           and may contain any number of ids (like Rigel, Beta Ori, ...),
;           where ids are delimited by commas.
;           Note lines must be indented and there may be any number of such lines.
;           Notes continue until next id line.  Comments may occur anywhere and
;           are designated by a * in column 1.
;           Example notes file:
;           *----- catagory xxx  ------------
;           id_a_1, [id_a_2, id_a_3, ...]
;             notes line 1
;             notes line 2
;             . . .
;           id_b_1, [id_b_2, id_b_3, ...]
;             . . .
;       slides = name of slides file.            in
;           File format: Each line has slide number, space(s),
;           slide id.  Slide id is the slide name as listed in the notes file.
;           Slides file may contain comments.  Comments have * in column 1 and
;           are passed directly into the lecture file unless /NOCOMMENTS are used.
;           Slide numbers are also passed into the lecture file unless /NONUMBERS
;           is used.  Use /one for one line listing for individual slides.
;           Example slides file:
;           1  id_a_1, id_a_2, id_a_3
;           2  id_b_1 /one
;           . . .
;       lect = name of resulting lecture file.   in
;           Same format as notes file.  Order of notes is that given in the slides file.
;           Must use /NONUMBERS keyword to get format identical to notes file.
;       Notes: Missing parameters are prompted for.
;         Notes file may be re-arranged by creating a slides file with the
;         desired order.  Use the keyword /NONUMBERS to suppress the output of slide numbers.
;         The resulting lecture file is then the re-arranged notes file.
; MODIFICATION HISTORY:
;       R. Sterner, 4 Feb 1990
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro lecture, notes, slides, lect, help=hlp, nocomments=nocom,$
		nonumbers=nonum, oneline=one
 
	if keyword_set(hlp) then begin
	  print,' Select specified lecture notes from a notes file.'
	  print,' lecture, notes, slides, lect'
	  print,'   notes = name of notes file.              in'
	  print,'       File format:  Slide id lines must start in column 1,'
	  print,'       and may contain any number of ids (like Rigel, Beta Ori, ...),'
	  print,'       where ids are delimited by commas.
	  print,'       Note lines must be indented and there may be any number of such lines.'
	  print,'       Notes continue until next id line.  Comments may occur anywhere and'
	  print,'       are designated by a * in column 1.'
	  print,'       Example notes file:'
	  print,'       *----- catagory xxx  ------------
	  print,'       id_a_1, [id_a_2, id_a_3, ...]'
	  print,'         notes line 1'
	  print,'         notes line 2'
	  print,'         . . .'
	  print,'       id_b_1, [id_b_2, id_b_3, ...]'
	  print,'         . . .'
	  print,'   slides = name of slides file.            in'
	  print,'       File format: Each line has slide number, space(s),'
	  print,'       slide id.  Slide id is the slide name as listed in the notes file.'
	  print,'       Slides file may contain comments.  Comments have * in column 1 and'
	  print,'       are passed directly into the lecture file unless /NOCOMMENTS are used.'
	  print,'       Slide numbers are also passed into the lecture file unless /NONUMBERS'
	  print,'       is used.  Use /one for one line listing for individual slides.'
	  print,'       Example slides file:'
	  print,'       1  id_a_1, id_a_2, id_a_3
	  print,'       2  id_b_1 /one
	  print,'       . . .
	  print,'   lect = name of resulting lecture file.   in'
	  print,'       Same format as notes file.  Order of notes is that given in the slides file.'
	  print,'       Must use /NONUMBERS keyword to get format identical to notes file.'
	  print,' Keywords:'
	  print,"   /NOCOMMENTS doesn't pass comments from slides file'
	  print,'      on to lecture file.'
	  print,"   /NONUMBERS doesn't pass slide numbers from slides file'
	  print,'      on to lecture file.'
	  print,'   /ONELINE uses first note line to make a one line listing.'
	  print,' Notes: Missing parameters are prompted for.'
	  print,'   Notes file may be re-arranged by creating a slides file with the'
	  print,'   desired order.  Use the keyword /NONUMBERS to suppress the output of slide numbers.'
	  print,'   The resulting lecture file is then the re-arranged notes file.'
	  return
	endif
 
 
	;-----------  prompt for missing parameters  ---------------
	if n_params(0) lt 3 then begin
	  print,' '
	  print,' ---==< Lecture notes >==---'
	  print,' '
	endif
 
	if n_elements(notes) eq 0 then begin
 	  notes = ''
	  read,' Enter name of input notes file: ', notes
	  if notes eq '' then return
	endif
 
	if n_elements(slides) eq 0 then begin
 	  slides = ''
	  read,' Enter name of input slides file: ', slides
	  if slides eq '' then return
	endif
 
	if n_elements(lect) eq 0 then begin
 	  lect = ''
	  read,' Enter name of output lecture file: ', lect
	  if lect eq '' then return
	endif
 
	;--------  Try to open files  -----------
	get_lun, lunn
	get_lun, luns
	get_lun, lunl
 
	on_ioerror, serr
stry:	openr, luns, slides
	goto, sskip
serr:	print,' Slides file not found: ',slides
 	slides = ''
	read,' Enter name of input slides file: ', slides
	if slides eq '' then goto, done
	goto, stry
 
sskip:	on_ioerror, nerr
ntry:	openr, lunn, notes
	goto, nskip
nerr:	print,' Notes file not found: ',notes
	notes = ''
	read,' Enter name of input notes file: ', notes
	if notes eq '' then goto, done
	goto, ntry
 
nskip:	on_ioerror, null
	openw, lunl, lect
 
	;-------  read in notes  --------
	print,' '
	print,' Reading notes file '+notes+' . . .'
	t = ''					; Record to read.
	s = ''					; String array containing notes.
	indx = ''				; Index of ids.
 	while not eof(lunn) do begin		; Loop through notes file.
	  readf, lunn, t			; read one line.
	  s = [s,t]				; Save it.
	  indx = [indx, strmid(t,0,1)]		; Save first char of line.
	endwhile
	s = s(1:*)				; Trim notes file.
	indx = indx(1:*)			; Trim first char array.
	index = where((indx ne ' ') and (indx ne '*'))
	lindex = n_elements(index) - 1
	for i = 0, lindex do begin		; Lowercase id lines, so it is done only once.
	  ii = index(i)
 	  s(ii) = strlowcase(s(ii))
	endfor
	index = [index, n_elements(s)]
 
	;----------  loop through the slides file  ----------
	print,' '
	print,' Processing slides file '+slides+' . . .'
	stxt = ''
	while not eof(luns) do begin	
	  readf, luns, stxt			; read slides file text.
	  c1 = strmid(stxt,0,1)			; Get first char.
	  ;-------  process slides file comment line ------
	  if c1 eq '*' then begin
	    if not keyword_set(nocom) then printf, lunl, stxt
	    goto, skip
	  endif
	  ;------  Not a comment, assume id --------
	  ids = getwrd(strlowcase(stxt), 1, 99)
	  loc = wordpos(ids, '/one')
	  ids = repword(ids, loc, '', old)			; Remove /one flag from id line.
	  if loc ge 0 then loc = loc + 1
	  stxt = repword(stxt, loc, '')
	  one_l = 0
	  if old eq '/one' then one_l = 1
	  if c1 ne ' ' then begin
	    for ip = 0, nwrds(ids, delim=',')-1 do begin	; Look at each id phrase.
	      id = getwrd(ids,ip, delim=',')			;   Get ip'th phrase = id.
	      for jj = 0, lindex do begin			;   Look for id somewhere in s.
	        t = s(index(jj))				;   Pull out notes file id line.
	        if strpos(t,id) ge 0 then goto, hit		; Found id.
	      endfor
	    endfor  ; ip
	    if keyword_set(nonum) then begin
	      printf, lunl, getwrd(stxt,1,99) + ' --- No notes.'  ; No id match, no notes, no numbers.
	    endif else begin
	      printf, lunl, stxt + ' --- No notes.'		  ; No id match, no notes, numbers.
	    endelse
	    goto, skip
	    ;-----  hit  -----------
	    ;-----  One line  --------
hit:	    if (keyword_set(one)) or (one_l eq 1) then begin
	      t = strtrim(s(index(jj)+1), 1)
	      if keyword_set(nonum) then begin				    ; Hit.  One line.
	        printf, lunl, getwrd(stxt,1,99) + ' --- ' + t  		    ;  No numbers.
	      endif else begin
	        printf, lunl, stxt + ' --- ' + t			    ;  Numbers.
	      endelse
	      goto, skip
	    endif
	    ;------  multi-line  ----------
	    if keyword_set(nonum) then begin			; Hit.  Multi-line.
	      printf, lunl, getwrd(stxt,1,99)			;  No numbers.
	    endif else begin
	      printf, lunl, stxt				;  Numbers.
	    endelse
	    for j = index(jj)+1, index(jj+1)-1 do begin		; List notes.
	      printf, lunl, '  '+s(j)
	    endfor
	    goto, skip
	  endif
skip:
	endwhile
 
done:	close, lunn, luns, lunl
	free_lun, lunn
	free_lun, luns
	free_lun, lunl
	print,' '
	print,' Output lecture file '+lect+' complete.'
	bell
	return
 
	end
