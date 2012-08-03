;---------  liner.pro = IDL liner  -------------
;	R. Sterner, 2002 Oct 19
 
	pro liner
 
	;----  Get keywords  --------------------
lp:	list = ''
	read,' Enter list of keywords: ',list
	if list eq '' then return
	list = repchr(list,',')
	n = nwrds(list)
 
	;-----  Get one line descriptions  -------
	whoami, dir
	f = filename(dir,'alph.one',/nosym)
	txt = getfile(f)
 
	for i=0, n-1 do begin
	  wd = getwrd(list,i)
	  strfind, txt, wd, index=in, /quiet
	  if in(0) eq -1 then goto, lp
	  txt = txt(in)
	endfor
 
	print,' '
	more, txt
	print,' '
 
	goto, lp
 
	end
