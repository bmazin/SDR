;-------------------------------------------------------------
;+
; NAME:
;       TXTDB_RD
; PURPOSE:
;       Read a text file data base.
; CATEGORY:
; CALLING SEQUENCE:
;       s = txtdb_rd(file)
; INPUTS:
;       file = name of text file with data base.  in
;         File may instead be the text array that would have
;         been read from the file (same format).
; KEYWORD PARAMETERS:
;       Keywords:
;         ERROR=err Error flag: 0=ok.
;         /QUIET do not show tabs warning.
;         TAB=tab Spaces/tab (def=8).
;         /DEBUG use debug mode.  Shows how text is processed.
;           May also do DEBUG=n to show details for n'th data item.
;         DROP=com_chars List of comment characters (def=';*').
;            Any line starting with any will be dropped.  By default
;            drops lines with ; or * in column 1.
;         /NODROP do not drop any lines.
; OUTPUTS:
;       s = returned structure with data.         out
; COMMON BLOCKS:
; NOTES:
;       Note: The text file with the data to read must have a
;       certain layout.  It is an ordinary text file, perhaps
;       wider than normal if that is needed.  It can have the
;       following sections:
;         Header lines    (n lines, optional) |
;         Data decription (3 lines, required)  > This group may be
;         Data lines      (n lines, required) |  repeated any number
;         Blank line      (1 line, required)  |  of times.
;         Trailer lines   (n lines, optional)
;       An example: (The string "<--" below is not part of file):
;       Header line 1                 <-- Header lines
;       Header line 2                     ...
;       code  length  weight  color   <-- Tag line
;        int   flt     flt     str    <-- Type line
;       ----- ------  ------  -----   <-- Reference line
;         1    2.34    32.7     Red   <-- data lines
;         2    3.17    25.5    Blue       ...
;         3    1.42    14.3   Green
;                                     <-- Blank line, end of data
;       Trailer line 1                <-- Trailer lines
;       Trailer line 2                    ...
;       
;       Blank data entries are allowed and will be returned as 0 or
;       null strings.  However each data line must have at least
;       one entry since a blank line terminates the data block.
;       
;       After the blank line at the end of the data lines, the
;       pattern: header lines, tag line, type line, reference line,
;       data lines may be repeated any number of times.  Just
;       make sure each group of data lines is followed by a
;       blank line.  Header lines are optional as before.
;       
;       The reference line is the key line.  It defines the column
;       locations for the data, tag names, and data types, so those
;       items must all fall within the width defined in the
;       reference line. The reference line must use groups of dashes
;       to specify these positions.  Do help,typ2num() to see
;       how to specify the data types.  Also * or ; as data type
;       will ignore that column, useful for row labels.
;       
;       Text before the data lines are returned in items named
;       __textxxx where xxx is a 3 digit count.
;       Any trailer text will be returned the same way.
;       
;       The data will be in arrays with names given in the tag line.
; MODIFICATION HISTORY:
;       R. Sterner, 2003 Aug 26
;       R. Sterner, 2003 Aug 28 --- Allowed multiple data blocks.
;       R. Sterner, 2003 Sep 02 --- Renamed from rd_txtdb.pro.
;       R. Sterner, 2003 Sep 03 --- Allowed ignored data columns.
;       R. Sterner, 2003 Dec 09 --- Did strtrim on each item, instead of
;       strcompress,/remove_all.  That allows spaces in strings.
;       R. Sterner, 2004 Feb 25 --- Allowed text array to be given.
;       R. Sterner, 2006 Mar 21 --- Added new data type: DMS.
;       R. Sterner, 2006 Mar 27 --- Added new keywords: DROP=drop, /NODROP.
;       R. Sterner, 2006 Jun 08 --- Fixed loop limits to be long int.
;
; Copyright (C) 2003, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function txtdb_rd, file, error=err, debug=debug, quiet=quiet, $
	  tab=tab, drop=drop, nodrop=nodrop, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read a text file data base.'
	  print,' s = txtdb_rd(file)'
	  print,'   file = name of text file with data base.  in'
	  print,'     File may instead be the text array that would have'
	  print,'     been read from the file (same format).'
	  print,'   s = returned structure with data.         out'
	  print,' Keywords:'
	  print,'   ERROR=err Error flag: 0=ok.'
	  print,'   /QUIET do not show tabs warning.'
	  print,'   TAB=tab Spaces/tab (def=8).'
	  print,'   /DEBUG use debug mode.  Shows how text is processed.'
	  print,"     May also do DEBUG=n to show details for n'th data item."
	  print,"   DROP=com_chars List of comment characters (def=';*')."
	  print,'      Any line starting with any will be dropped.  By default'
	  print,'      drops lines with ; or * in column 1.'
	  print,'   /NODROP do not drop any lines.'
	  print,' Note: The text file with the data to read must have a'
	  print,' certain layout.  It is an ordinary text file, perhaps'
	  print,' wider than normal if that is needed.  It can have the'
	  print,' following sections:'
	  print,'   Header lines    (n lines, optional) |'
	  print,'   Data decription (3 lines, required)  > This group may be'
	  print,'   Data lines      (n lines, required) |  repeated any number'
	  print,'   Blank line      (1 line, required)  |  of times.'
	  print,'   Trailer lines   (n lines, optional)'
	  print,' An example: (The string "<--" below is not part of file):'
	  print,' Header line 1                 <-- Header lines'
	  print,' Header line 2                     ...'
	  print,' code  length  weight  color   <-- Tag line'
	  print,'  int   flt     flt     str    <-- Type line'
	  print,' ----- ------  ------  -----   <-- Reference line'
	  print,'   1    2.34    32.7     Red   <-- data lines'
	  print,'   2    3.17    25.5    Blue       ...'
	  print,'   3    1.42    14.3   Green'
	  print,'                               <-- Blank line, end of data'
	  print,' Trailer line 1                <-- Trailer lines'
	  print,' Trailer line 2                    ...'
	  print,' '
	  print,' Blank data entries are allowed and will be returned as 0 or'
	  print,' null strings.  However each data line must have at least'
	  print,' one entry since a blank line terminates the data block.'
	  print,' '
	  print,' After the blank line at the end of the data lines, the'
	  print,' pattern: header lines, tag line, type line, reference line,'
	  print,' data lines may be repeated any number of times.  Just'
	  print,' make sure each group of data lines is followed by a'
	  print,' blank line.  Header lines are optional as before.'
	  print,' '
	  print,' The reference line is the key line.  It defines the column'
	  print,' locations for the data, tag names, and data types, so those'
	  print,' items must all fall within the width defined in the'
	  print,' reference line. The reference line must use groups of dashes'
	  print,' to specify these positions.  Do help,typ2num() to see'
	  print,' how to specify the data types.  Also * or ; as data type'
	  print,' will ignore that column, useful for row labels.'
	  print,' '
	  print,' Text before the data lines are returned in items named'
	  print,' __textxxx where xxx is a 3 digit count.'
	  print,' Any trailer text will be returned the same way.'
	  print,' '
	  print,' The data will be in arrays with names given in the tag line.'
	  return,''
	endif
 
	if n_elements(tab) eq 0 then tab=8
 
	;------  Get text -------
	;------  Read text from file  --------
	if n_elements(file) eq 1 then begin
	  t = getfile(file,err=err)	; Read text file.
	  if err ne 0 then return,''
	;------  Text was given  --------------
	endif else begin
	  t = file
	endelse
 
	;------  Deal with any commented out lines  ------
	if not keyword_set(nodrop) then begin
	  if n_elements(drop) eq 0 then drop=';*'
	  t = drop_comments(t, ignore=drop, /notrim)
	endif
 
	n = n_elements(t)		; # lines.
 
	;------  Deal with tabs  -------
	bt = byte(t)			; Convert to bytes.
	w = where(bt eq 9,cnt9)		; Check for tabs.
	if cnt9 ne 0 then begin		; Found tabs.
	  if not keyword_set(quiet) then begin
	    print,' Warning in txtdb_rd: tabs found in '+file
	    print,'   Removing assuming '+strtrim(tab,2)+' spaces/tab'
	  endif
	  for i=0L,n-1 do t(i)=detab(t(i),tab=tab)  ; Detab.
	endif
 
	;------  Search for reference line (all -)  ------
	tc = strcompress(t,/rem)	; Remove all whitespace.
	b = byte(tc)			; Convert to byte.
	flag = 0			; Ref line found yet? 0=no.
	if keyword_set(debug) then begin
	  print,' Read file '+file
	  print,' Removed all white space.'
	  print,' Number of lines in file = ',n
	endif
 
	irefa = [0]			; Start iref array with a seed value.
	for i=0L,n-1 do begin		; Search for reference line.
	  bb = b(*,i)			; I'th line (as bytes).
	  w = where((histogram(bb))(1:*) gt 0,cnt)  ; # diff chars in line.
	  if cnt eq 1 then begin	; Ref line should have only 1 kind.
	    if bb(0) ne 45 then continue   ; and must be a -.
	    flag = 1			; Found reference line.
	    irefa = [irefa,i]		; Remember index of ref line.
	    if keyword_set(debug) then begin
	      print,' Found reference line at line # ',i
	      print,' Ref line: '+t(i)
	    endif
	  endif
	endfor
 
	if flag ne 0 then irefa=irefa(1:*)	; Drop seed value.
	numref = n_elements(irefa)
 
	;------  No reference line found  --------
	if flag eq 0 then begin
	  print,' Error in txtdb_rd: could not find the reference line.'
	  print,'   The reference line uses groups of - to delimit columns.'
	  print,'   The groups are separated by a space.  No other characters.'
	  print,'   are allowed in the reference line.'
	  err = -1
	  return,''
	endif
	if irefa(0) lt 2 then begin
	  print,' Error in txtdb_rd: Must have tag line and type line above'
	  print,'   reference line in data base file.  Reference line too'
	  print,'   close to top of file.'
	  err = -2
	  return,''
	endif
 
	itxt0 = 0			; Start index in text array t.
	hdrcnt = 0			; Header counter.
 
	;-----  Loop through reference lines -----------
	for ir = 0L, numref-1 do begin
	  iref = irefa(ir)		; Next reference line index.
 
	  ;------  Get reference line, type line, tag line, header  ----
	  ref = t(iref)			; Reference line.
	  typ = t(iref-1)		; Data type line.
	  tag = t(iref-2)		; Tag name line.
	  ih_lo = itxt0			; First header line.
	  ih_hi = iref-3		; Last header line.
	  if ih_hi lt itxt0 then begin	; No header.
	    hflag = 0			; Indicate no header.
	    hdr = ''			; Null header.
	  endif else begin
	    hflag = 1			; Indicate a header.
	    hdr = t(ih_lo:ih_hi)	; Extract header lines.
	  endelse
	  if keyword_set(debug) then begin
	    if hflag then print,' Found header text' else $
	      print,' No header text'
	    print,' tag line: '+tag
	    print,' typ line: '+typ
	  endif
 
	  ;-----  Get data lines  -----------
	  w = where(strlen(tc(iref:*)) eq 0, cnt) ; Find blank line after data.
	  if cnt eq 0 then begin
	    id_lo = iref+1	; First data line.
	    id_hi = n-1		; Last data line.
	  endif else begin
	    id_lo = iref+1	; First data line.
	    id_hi = iref+w(0)-1	; Last data line.
	  endelse
	  data = t(id_lo:id_hi)	; Extract data lines.
	  if keyword_set(debug) then begin
	    ndata = n_elements(data)
	    print,' Number of data lines: ',ndata
	  endif
	  itxt0 = id_hi + 2	; Start of next header if any.
 
	  ;-----  Make sure number of items all agree  -----
	  fndwrd,ref,nref,loc,len		; Find columns of data items.
	  if nwrds(typ) ne nref then begin
	    print,' Error in txtdb_rd: Number of data types must match number'
	    print,'   of groups of -s in reference line.'
	    err = -3
	    return,''
	  endif
	  if nwrds(tag) ne nref then begin
	    print,' Error in txtdb_rd: Number of tag names must match number'
	    print,'   of groups of -s in reference line.'
	    err = -4
	    return,''
	  endif
 
	  ;-------  Add header text to structure  ---------
	  htag = '__text'+string(hdrcnt,form='(I3.3)')
	  hdrcnt = hdrcnt + 1
	  if n_elements(s) eq 0 then begin
	    s = create_struct(htag,hdr)
	  endif else begin
	    s = create_struct(s,htag,hdr)
	  endelse
 
	  ;----  Loop through data items adding to structure  -----
	  for i=0L,nref-1 do begin
	    start = loc(i)
	    length = len(i)
	    typ_i = strtrim(strmid(typ,start,length),2)
	    tag_i = strtrim(strmid(tag,start,length),2)
	    if (typ_i eq '*') or (typ_i eq ';') then continue
	    cnv = typ2num(typ_i,err=err,ftype=ftyp)
	    if err ne 0 then begin
	      print,' Error in txtdb_rd: Unknown data type: '+typ_i
	      print,'   Processig aborted.'
	      err = -5
	      return,''
	    endif
	    dat_i = strmid(data,start,length)
	    if keyword_set(debug) then begin
	      print,' '
	      print,'   Data item # '+strtrim(i,2)+'  Tag: '+tag_i
	      print,'     Start char: ',start
	      print,'     Length: ',length
	      print,'     Convert to typ: '+typ_i
	      print,'     Data = '+dat_i(0)
	    endif
;	    datcnv = strcompress(dat_i,/rem) + cnv
	    datcnv = strtrim(dat_i,2) + cnv
	    if ftyp eq 'DMS' then datcnv=dms2d(datcnv)	; Special case 'D M S'.
	    s = create_struct(s,tag_i,datcnv)
	  endfor
 
	endfor ; ir
 
	;-----  Finish structure  ---------
	if itxt0 lt n then begin
	  hdr = t(itxt0:n-1)
	  htag = '__text'+string(hdrcnt,form='(I3.3)')
	  s = create_struct(s,htag,hdr)
	endif
 
	return, s
 
	end
