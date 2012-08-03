;-------------------------------------------------------------
;+
; NAME:
;       INGEST_BINDATA
; PURPOSE:
;       Ingest binary data in a byte array into a structure.
; CATEGORY:
; CALLING SEQUENCE:
;       s = ingest_bindata(text, bindata)
; INPUTS:
;       text = String array with data description.  in
;       bindata = Byte array with binary data.      in
; KEYWORD PARAMETERS:
;       Keywords:
;         COMMENTS=cmt  Returned array of comments for each tag.
;         /REVBITS means extract bit fields starting from most
;           significant bit (else least).
;         /SWAP_ENDIAN means swap endian of each item.
;           (does not apply to extracted bit fields).
;         /CHECK means check text for total bytes.
;           Returns check text in s.  Does not extract data.
;           Use TOT_BYTES=nbyts to return total number of bytes.
;         LENCHECK=maxlen check tag names for length (def=8 char).
;           Use /COMMENT to check comment lengths (def=48).
;         /QUIET do not list check text for /CHECK mode or LENCHECK
;            mode.  Still lists any error messages.
;         /DETAILS gives details on text description.
;         /NOCOPY do not grab lines with + in column 1.
;         ERROR=err Error count (0=none).
; OUTPUTS:
;       s = Returned structure.                     out
; COMMON BLOCKS:
; NOTES:
;       Note: Ex comment check: t=ingest_bindata(txt,bin,comment=cmt)
;                             more,tag_names(t)+' --- '+cmt
;         From the total number of bytes returned by TOT_BYTES in
;         /CHECK can get a structure for directly reading the data:
;         s=ingest_bindata(text,bytarr(nrec),comment=cmt)
;         (Can do direct reads only if there are no bit extractions)
; MODIFICATION HISTORY:
;       R. Sterner, 2002 Oct 10
;       R. Sterner, 2002 Oct 22 --- Added LENCHECK=maxlen, COMMENT=cmt.
;       R. Sterner, 2002 Nov 19 --- Added + to copy text to structure (/nocopy).
;       R. Sterner, 2002 Nov 20 --- Added comment check to /lencheck.
;       R. Sterner, 2003 Jan 17 --- Returned total number of bytes.
;       R. Sterner, 2003 May 02 --- Changed default comments length to 48.
;       R. Sterner, 2004 Oct 12 --- Cleared up some help text.
;
; Copyright (C) 2002, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function ingest_bindata, text, bin, check=check, quiet=quiet, $
	  details=details, revbits=revbits, swap_endian=endian, $
	  error=errcnt, lencheck=lencheck, comments=cmt, $
	  nocopy=nocopy, tot_bytes=tot_bytes, help=hlp
 
	if keyword_set(hlp) then begin
hlp:	  print,' Ingest binary data in a byte array into a structure.'
	  print,' s = ingest_bindata(text, bindata)'
	  print,'   text = String array with data description.  in'
	  print,'   bindata = Byte array with binary data.      in'
	  print,'   s = Returned structure.                     out'
	  print,' Keywords:'
	  print,'   COMMENTS=cmt  Returned array of comments for each tag.'
	  print,'   /REVBITS means extract bit fields starting from most'
	  print,'     significant bit (else least).'
	  print,'   /SWAP_ENDIAN means swap endian of each item.'
	  print,'     (does not apply to extracted bit fields).'
	  print,'   /CHECK means check text for total bytes.'
	  print,'     Returns check text in s.  Does not extract data.'
	  print,'     Use TOT_BYTES=nbyts to return total number of bytes.'
	  print,'   LENCHECK=maxlen check tag names for length (def=8 char).'
	  print,'     Use /COMMENT to check comment lengths (def=48).'
	  print,'   /QUIET do not list check text for /CHECK mode or LENCHECK'
	  print,'      mode.  Still lists any error messages.'
	  print,'   /DETAILS gives details on text description.'
	  print,'   /NOCOPY do not grab lines with + in column 1.'
	  print,'   ERROR=err Error count (0=none).'
	  print,' Note: Ex comment check: t=ingest_bindata(txt,bin,comment=cmt)'
	  print,"                       more,tag_names(t)+' --- '+cmt"
	  print,'   From the total number of bytes returned by TOT_BYTES in'
	  print,'   /CHECK can get a structure for directly reading the data:'
	  print,'   s=ingest_bindata(text,bytarr(nrec),comment=cmt)'
	  print,'   (Can do direct reads only if there are no bit extractions)'
	  return,''
	endif
 
	if keyword_set(details) then begin
	  print,' Details on ingest_bindata data description string array'
	  print,' '
	  print,' Each line in the data description string array defines'
	  print,' an item in the binary data. Each line has a tag name and'
	  print,' the data type of the item.  Arrays are allowed.'
	  print,' A description may follow the data type.  For example:'
	  print,'   ONE    INT       First item.'
	  print,'   TWO    FLT       Second item.'
	  print,'   THREE  LON(2,3)  Third item.'
	  print,'   FOUR   BYT(10)   Fourth item.'
	  print,' Allowed data types are: BYT, INT, LON, FLT, DBL, COMPLEX,'
	  print,'   DCOMPLEX, UINT, ULON, LONG64, ULONG64.'
	  print,'   Any array dimensions follow the data type in parantheses.'
	  print,' '
	  print,' Bit fields may be extracted.  Bit fields are indicated by a'
	  print,' tag of # followed by a data type giving the number of bits'
	  print,' to extract from.  An example of bit fields:'
	  print,'   #       UINT'
	  print,'   SOURCE  4 bits  Data source.'
	  print,'   FLAG    1 bit   Flag value.'
	  print,' There could be up to 16 bits extracted from this UINT. The'
	  print,' first item after a bit field tag is the number of bits, only'
	  print,' this number is used.'
	  print,' '
	  print,' A ! instead of or as the first character of a tag means'
	  print,' do not return that item or bit field in the structure.'
	  print,' Such ignored items are still needed in the description'
	  print,' to account for the bits in the binary data.'
	  print,' '
	  print,' * or ; in column 1 are considered comments and dropped.'
	  print,' Only the first two items on each line are used.  The'
	  print,' first is a tag or the bit field indicator.  The second'
	  print,' is the data type or number of bits to extract.  So the'
	  print,' data type may be followed by a description of the item.'
	  print,' White space, comments, and null lines could be used freely'
	  print,' in the text file.'
	  print,' '
	  print,' If + occurs in column 1 then the following text is included'
	  print,' in the returned structure with tags names of ___$xxxx'
	  print,' where xxxx is a 4 digit counter (0001,0002,...). Use'
	  print,' /NOCOPY to avoid picking up such text.'
	  return,''
	endif
 
	;--------------------------------------------------
	;  Preprocess text (drop comments)
	;--------------------------------------------------
	if n_elements(text) eq 0 then goto, hlp		; No args.
	txt = drop_comments(text,/trailing)		; Drop comments.
	n = n_elements(txt)				; # items.
 
	;--------------------------------------------------
	;  Length check
	;--------------------------------------------------
	if n_elements(lencheck) ne 0 then begin
	  lenchk = lencheck
	  if lenchk eq 1 then begin		; Default length limit.
	    if keyword_set(cmt) then begin
	      lenchk = 48			; FITS comment.
	    endif else begin
	      lenchk = 8			; FITS tag.
	    endelse
	  endif
	  lentxt = strtrim(lenchk,2)
	  out0 = spc(75)			; Blank line.
	  out = out0				; Blank text line.
	  if keyword_set(cmt) then begin	; Comments.
	    pt1 = 3				; Comment.
	    pt2 = 8+lenchk			; Comment length.
	    pt3 = 14+lenchk			; Error flag.
	    strput,out,'Comment',pt1		; Insert items into text line.
	    strput,out,'Length',pt2		; Insert items into text line.
	  endif else begin			; Tags.
	    pt1 = 6				; Tag name.
	    pt2 = 17+lenchk			; Tag length.
	    pt3 = 22+lenchk			; Error flag.
	    strput,out,'Tag',pt1		; Insert items into text line.
	    strput,out,'Length',pt2		; Insert items into text line.
	  endelse
	  tprint,out,/init		; Add line into internal text array.
	  tprint,' '
	  ;----------  Loop through items in data description  ---------
	  for i=0,n-1 do begin			; Loop through text.
	    t = txt(i)				; i'th item.
	    tg0 = strmid(t,0,1)			; First tag char.
	    a = getwrd(t,1)			; Datatype.
	    if tg0 eq '+' then begin		; Comment.
	      tprint,strmid(t,1,999)		; Print it.
	      goto, skiplc
	    endif
	    if (tg0 ne '#') and (tg0 ne '!') then begin	 ; Line with tag.
	      if keyword_set(cmt) then begin	; Checking comment length.
	        if isnumber(a) then begin
		  tg = getwrd(t,3,99)		; Bit Field comment.
		endif else begin
		  tg = getwrd(t,2,99)		; Tag comment.
		endelse
	      endif else begin			; Checking tag length.
	        tg = getwrd(t,0)		; Get tag.
	      endelse
	      len0 = strlen(tg)
	      len = string(len0,form='(I2)')
	      out = out0
	      if len0 le lenchk then begin
	        tg2 = tg + spc(lenchk,tg) + ' '
	        errtxt = ''
	      endif else begin
                tg2 = strmid(tg,0,lenchk) + ' ' + strmid(tg,lenchk,99)
	        errtxt = '<-- Too long.  Limit = '+lentxt
	      endelse
	      strput,out,tg2,pt1
	      strput,out,len,pt2
	      strput,out,errtxt,pt3
	      tprint,out
	    endif
skiplc:
	  endfor
	  tprint,out=chk_txt				; Get internal text.
	  if not keyword_set(quiet) then tprint,/print	; Print internal text.
	  return, chk_txt				; Return text.
	endif
 
	;--------------------------------------------------
	;  Check text (do not extract data)
	;--------------------------------------------------
	if keyword_set(check) then begin
	  out0 = spc(75)	; Blank line.
	  pt1 = 1+5		; Tag name.
	  pt2 = 20+5		; Data Type.
	  pt3 = 30+5		; Bits in data type.
	  pt4 = 40+5		; Start byte in array of binary data.
	  pt5 = 50+5		; Total bits including current item.
	  pb1 = 5+5		;   Bit field name.
	  pb2 = 25+5		;   Number of bits.
	  pb3 = 40+5		;   Offset bits into source item.
	  out = out0			; Blank text line.
	  strput,out,'Tag',pt1		; Insert items into text line.
	  strput,out,'Type',pt2
	  strput,out,'Bits',pt3
	  strput,out,'Byte #',pt4
	  strput,out,'Tot Bits',pt5
	  tprint,out,/init		; Add line into internal text array.
	  tprint,' '
 
	  tot_bits = 0L				; Cumulative bits.
	  bit_offset = 0			; Offset into bitfield.
	  errcnt = 0				; Total errors found.
 
	  ;----------  Loop through items in data description  ---------
	  for i=0,n-1 do begin			; Loop through text.
	    t = txt(i)				; i'th item.
	    tg = getwrd(t,0)			; Tag.
	    tg0 = strmid(tg,0,1)		; First tag char.
	    a = getwrd(t,1)			; Datatype.
	    out = out0
	    if tg0 eq '+' then begin		; Comment.
	      tprint,strmid(t,1,999)		; Print it.
	      goto, skip
	    endif
	    ;------  Datatype or #  --------------
	    if not isnumber(a) then begin	; Actual datatype.
	      num = typ2num(a,bits=nbits,err=err,/quiet) ; # bits for item.
	      if err ne 0 then begin
		tprint,' >>>===> '+tg+': has unkown datatype of '+a+'. Skipped.'
		errcnt = errcnt + 1
		goto, skip
	      endif
	      start_byte = tot_bits/8		; Byte index into binary data.
	      tot_bits = tot_bits + nbits	; Running sum of bits.
	      if tg0 eq '!' then begin		; Ignore items tagged !.
		tg1 = strmid(tg,1,99)
		if tg1 eq '' then tg1='Ignored'
		strput,out,'<<'+tg1+'>>',pt1
		strput,out,a,pt2
	      endif else begin			; Actual data item to extract.
		strput,out,tg,pt1
		strput,out,a,pt2
	      endelse
	      strput,out,string(nbits,form='(I5)'),pt3
	      strput,out,string(start_byte,form='(I5)'),pt4
	      strput,out,string(tot_bits,form='(I5)'),pt5
	      if tg eq '#' then begin		; Start bit fields.
		strput,out,'Bitfield:',pt1
		strput,out,a,pt2
	        bit_offset = 0			; Reset offset into bit field.
	      endif
	    ;------  Bit field  -----------------------
	    endif else begin			; Datatype was bits to extract.
	      if tg0 eq '!' then begin		; Ignore items tagged !.
		tg1 = strmid(tg,1,99)
		if tg1 eq '' then tg1='Ignored'
		strput,out,'<<'+tg1+'>>',pb1
		strput,out,'Bits: '+string(a,form='(I2)'),pb2
		strput,out,'Offset: '+string(bit_offset,form='(I2)'),pb3
	      endif else begin			; Actual bit field to extract.
		strput,out,tg,pb1
		strput,out,'Bits: '+string(a,form='(I2)'),pb2
		strput,out,'Offset: '+string(bit_offset,form='(I2)'),pb3
	      endelse
	      if (a gt (nbits-bit_offset)) or (bit_offset ge nbits) then begin
		tprint,' >>>===> '+tg+': does not fit in bit field.' 
		errcnt = errcnt + 1
		goto, skip
	      endif
	      bit_offset = bit_offset + a	; Offset to next bit field.
	    endelse
	    tprint,out
skip:
	  endfor
 
	  tprint,' '
	  tot_bytes = tot_bits/8
	  tprint,' Total number of bytes: '+strtrim(tot_bytes,2)
	  tprint,' '
	  if errcnt gt 0 then begin
	    tprint,' Byte count will be off because there '+ $
	      plural(errcnt,'was ','were ')+strtrim(errcnt,2)+$
	      ' error'+plural(errcnt)+'.'
	  endif
	  tprint,out=chk_txt				; Get internal text.
	  if not keyword_set(quiet) then tprint,/print	; Print internal text.
	  return, chk_txt				; Return text.
	endif
 
 
	;--------------------------------------------------
	;  Extract data
	;--------------------------------------------------
	tot_bits = 0L			; Cumulative bits.
	bit_offset = 0			; Offset into bitfield.
	errcnt = 0			; Total errors found.
	cmt = ['']			; Array of comments.
	copy_pre = '___$'		; Prefix for text to copy.
	copy_cnt = 0L			; Counter for text to copy.
 
	for i=0,n-1 do begin	; Loop through items in data description text.
	  t = txt(i)			; i'th item.
	  tg = getwrd(t,0)		; Tag.
	  tg0 = strmid(tg,0,1)		; First tag char.
	  a = getwrd(t,1)		; Datatype.
	  offset = tot_bits/8		; Byte offset into binary data.
	  ;------  Deal with text to copy to structure  ----------
	  if tg0 eq '+' then begin
	    if keyword_set(nocopy) then goto, skip2	; Ignore.
	    tg = copy_pre+string(copy_cnt,form='(I4.4)'); Make up tag name.
	    copy_cnt = copy_cnt + 1L
	    val = strmid(t,1,999)			; Drop leading +.
	    if n_elements(s) eq 0 then $
	      s = create_struct(tg,val) else $		; Create structure.
	      s = create_struct(s,tg,val)		; Add to structure.
	    cmt = [cmt,'']				; Keep comments synced.
	    goto, skip2
	  endif
	  ;------  Datatype or #  --------------
	  if not isnumber(a) then begin	; Actual data item (datatype=a).
	    ;--------  Extract item  ------------
	    if tg0 ne '!' then begin	; Extract data.
	      num = typextract(a,offset,bin,bits=nbits,err=err)
	      if err ne 0 then begin
		print,' Error in ingest_bindata:'
	        print,' >>>===> '+tg+': has unkown datatype of '+a+'. Skipped.'
	        errcnt = errcnt + 1
	        goto, skip2
	      endif
	      ;-------  Swap endian?  -------------
	      if keyword_set(endian) then num=swap_endian(num)
	      if tg0 ne '#' then begin			; Don't add bit field
	        if n_elements(s) eq 0 then $
		  s = create_struct(tg,num) else $	; Create structure.
		  s = create_struct(s,tg,num)		; Add to structure.
	        cmt = [cmt,getwrd(t,2,99)]		; Grab any comment.
	      endif
	    ;--------  Just count bits  -------------
	    endif else begin
	      tmp = typ2num(a,bits=nbits,err=err,/quiet) ; # bits for item.
	    endelse
	    tot_bits = tot_bits + nbits		; Running sum of bits.
	    ;--------  Get ready for a bit field  ----------
	    if tg eq '#' then bit_offset=0	; Reset offset into bitfield.
	  ;------  Bit field  -----------------------
	  endif else begin			; Datatype was bits to extract.
	    start_bit = bit_offset		; Extract from lsb.
	    if keyword_set(revbits) then $	; Extract from msb.
		start_bit = nbits-bit_offset-a
	    ;-------  Check for fit  ----------------
	    if (start_bit + a) gt nbits then begin
		print,' Error in ingest_bindata: ' + $
		  tg + ': does not fit in bit field.'
	        print,' '+tg+' is '+strtrim(a,2)+' bits starting at bit '+$
		  strtrim(start_bit,2)
		errcnt = errcnt + 1
		goto, skip2
	    endif
	    if (tg0 ne '!') then begin		; Extract bits.
	      val = getbits(num,start_bit,a,/reduce)	; Extract bits.
	      cmt = [cmt,getwrd(t,3,99)]		; Grab any comment.
	      if n_elements(s) eq 0 then $
		s = create_struct(tg,val) else $	; Create structure.
		s = create_struct(s,tg,val)		; Add to structure.
	    endif
	    bit_offset = bit_offset + a
	  endelse
skip2:
	endfor
 
	cmt = cmt(1:*)		; Drop seed value.
 
	return, s
 
	end
