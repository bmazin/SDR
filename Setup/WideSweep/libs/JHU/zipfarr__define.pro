	;====================================================================
	;  zipfarr__define.pro = Array of zipped files.
	;  Allows items to be stored by index in zipped files.
	;  R. Sterner, 2007 May 07
	;
	;  Currently will only work for numeric items.
	;
	;  Object quick start:
	;	z = obj_new('zipfarr')
	;	z->help
	;====================================================================

	;====================================================================
	;  HELP = List some help for this object.
	;====================================================================

	pro zipfarr::help

	print,' Zipped file array object.  This object manages an array of'
	print,' zipped files intended as a temporary storage area.  When'
	print,' the array is closed the zipped files are deleted by default.'
	print,' Items may be stored or retrieved by index.'
	print,' Currently will only work for numeric items.'
	print,' '
	print,' To create a zipped file array object:'
	print,"   z = obj_new('zipfarr', basename=base)"
	print,'     base = Base file name, like imgarr_00.dat'
	print,'     Default = zipfarr_00.dat'
	print,'       The main file name (imgarr) and extension (dat) are'
	print,'       determined from the given basename.  The array index is'
	print,'       the value between the last _ and the . before the'
	print,'       extension.  The default number of digits in this index'
	print,'       is determined from the basename.'
	print,' To start a zipped file array:'
	print,'   z->open, [base], error=err'
	print,'     base = Optional base file name (see above).'
	print,'     Must close an existing array before opening a new one.'
	print,'     ERROR=err Error flag: 0=ok.'
	print,' To terminate a zipped file array:'
	print,'   z->close, [/keep]'
	print,'     All the zipped files are deleted unless /keep is used.'
	print,' To put an item into the zipped file array:'
	print,'   z->put, index, item'
	print,'     index = Index into zipped file array.  in'
	print,'     item = Item to save.                   in'
	print,'       If index is numeric it will be converted to a string'
	print,'       with as many digits as was in the basename if possible.'
	print,'       The index must be a scalar, either an integer or a string'
	print,'       with no whitespace.'
	print,' To retrieve an item from the zipped file array:'
	print,'   z->get, index, item'
	print,'     index = Index into zipped file array.  in'
	print,'     item = Item to retrieve.               out'
	print,' To list indices used:'
	print,'   z->list'

	end


	;====================================================================
	;  LIST = List used indices and data descriptors
	;====================================================================

	pro zipfarr::list

	if self.oflag eq 0 then begin
	  print,' No array open.'
	  return
	endif

	if not ptr_valid(self.list) then begin
	  print,' No indices to list.'
	  return
	endif

	print,' Number of indices used: '+strtrim(self.num,2)
	print,'          Index  Descriptor'

	list = *self.list			; List of used files.
	get_lun, lun

	for i=0,self.num-1 do begin
	  f = list[i]				; File name.
	  in = getwrd(f,del='.')			; Index.
	  in = strmid(in,strlen(self.fnam)+1,99)
	  openr, lun, f, /compress
	  len = 0L
	  readu, lun, len
	  b = bytarr(len)
	  readu, lun, b
	  close, lun
	  desc = string(b)
	  print,' ',i,'   ',in,'   ',desc
	endfor
	free_lun, lun

	end


	;====================================================================
	;  DEBUG = Stop to allow internal inspection
	;====================================================================

	pro zipfarr::debug

	stop

	end


	;====================================================================
	;  ZFILE = Get file name from index
	;====================================================================

	pro zipfarr::zfile, in, file_name

	if isnumber(in) then begin
	  in2 = long(in)			; Force integer.
	  nd = floor(alog10(in2>1)) + 1		; # digits.
	  n = nd>self.ddig			; Default #.
	  ntxt = strtrim(n,2)
	  fmt = '(I'+ntxt+'.'+ntxt+')'		; Build format.
	  itxt = string(in2,form=fmt)		; Numeric index string.
	endif else begin
	  itxt = strtrim(in,2)			; Non-numeric index string.
	endelse
	file_name = self.fnam+'_'+itxt +'.'+self.fext	; File for index.

	end


	;====================================================================
	;  GET = Get an item from a zipped file array
	;====================================================================

	pro zipfarr::get, in, item, error=err

	if n_params(0) lt 2 then begin
	  print,' Error in zipfarr->get: Must give both index and item.'
	  err = 1
	  return
	endif

	;---  Find file name for given index  ---
	self->zfile, in, file_name

	;---  Check that file exists  -----
	f = file_search(file_name, count=cnt)
	if cnt eq 0 then begin
	  err = 1
	  print,' Error in zipfarr->get: Nothing saved in given index.'
	  print,'   Index was ',in
	  return
	endif

	;---  Read item from file  ---
	openr, lun, file_name, /get_lun, /compress
	len = 0L
	readu, lun, len
	b = bytarr(len)
	readu, lun, b
	desc = string(b)
	item = typ2num(desc)
	readu, lun, item
	free_lun, lun

	end


	;====================================================================
	;  PUT = Put an item into a zipped file array
	;====================================================================

	pro zipfarr::put, in, item, error=err

	if self.oflag ne 1 then begin
	  print,' Error in zipfarr->put: No array is open.'
	  return
	endif

	if n_params(0) lt 2 then begin
	  print,' Error in zipfarr->put: Must give both index and item.'
	  err = 1
	  return
	endif

	if n_elements(in) eq 0 then begin
	  print,' Error in zipfarr->put: index is undefined.'
	  err = 1
	  return
	endif

	if n_elements(item) eq 0 then begin
	  print,' Error in zipfarr->put: item is undefined.'
	  err = 1
	  return
	endif

	;---  Find file name for given index  ---
	self->zfile, in, file_name

	;---  Add file name to list if not there  ---
	if ptr_valid(self.list) then list=*self.list else list=['']
	w = where(list eq file_name, cnt)
	if cnt eq 0 then begin
	  ptr_free, self.list
	  if list[0] eq '' then list=file_name else list=[list,file_name]
	  self.list = ptr_new(list)		; Add file name to list.
	  self.num = self.num + 1		; Count it.
	endif

	;---  Save item in file  ---
	desc = datatype(item,/descriptor)	; Get data descriptor for item.
	len = strlen(desc)			; # chars in desc.
	openw, lun, file_name, /get_lun, /compress
	writeu, lun, len			; Length of descriptor.
	writeu, lun, byte(desc)			; Write descriptor as bytes.
	writeu, lun, item			; Write item.
	free_lun, lun				; Close file.

	end


	;====================================================================
	;  CLOSE = Close a zipped file array
	;====================================================================

	pro zipfarr::close, keep=keep

	if self.oflag eq 0 then begin
	  print,' Error in zipfarr->close: No array is open.'
	  return
	endif

	self.oflag = 0

	if keyword_set(keep) then return

	list = *self.list
	ptr_free, self.list
	for i=0,self.num-1 do begin
	  file_delete, list[i]
	endfor
	self.list = ptr_new()
	self.num = 0

	end


	;====================================================================
	;  OPEN = Open a zipped file array
	;====================================================================

	pro zipfarr::open, base, error=err

	if self.oflag eq 1 then begin
	  print,' Error in zipfarr->open: An array is already open.'
	  err = 1
	  return
	endif

	if n_elements(base) gt 0 then begin
	  self->init_base, base, error=err
	  if err ne 0 then return
	endif

	self.oflag = 1				; Flag as open.

	end


	;====================================================================
	;  INIT_BASE = Deal with base file name
	;====================================================================

	pro zipfarr::init_base, base, error=err

	filebreak, base, name=nam, ext=ext	; Find name and extension.
	fnam = getwrd(nam,del='_',-99,-1,/last)	; Base part of name.
	find = getwrd(nam,del='_',/last)	; Index part.
	self.fnam = fnam			; Base part of name.
	self.ddig = strlen(find)		; Default # digits.
	self.fext = ext				; File extension.
	err = 0

	end


	;====================================================================
	;  CLEANUP = Cleanup pointers
	;====================================================================

	pro zipfarr::cleanup
	ptr_free, self.list
	end


	;====================================================================
	;  INIT = Init object
	;====================================================================

	function zipfarr::init, basename=base

	if n_elements(base) eq 0 then base='zipfarr_00.dat'
	self->init_base, base, error=err
	if err ne 0 then return, 0

	return, 1
	end


	;====================================================================
	;  Zipped file array object structure
	;====================================================================

	pro zipfarr__define

	tmp = { zipfarr,            $
		oflag:0,       $    ; Open flag.
		fnam:'',       $    ; Zipped file base name.
		ddig:0,        $    ; Default # digits in index.
		fext:'',       $    ; Zipped file extension.
		num:0,         $    ; Number of files in use.
		list:ptr_new(),$    ; List of files in use.
		dum:0 }

	end

