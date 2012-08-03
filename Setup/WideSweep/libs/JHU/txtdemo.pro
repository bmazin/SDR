;--------  txtdemo.pro = demonstrate and test txt routines  --------
;	R. Sterner, 25 Feb, 1992

	pro txtdemo, help=hlp

	if keyword_set(hlp) then begin
	  print,' Demonstrate and test txt routines.'
	  print,' txtdemo'
	  print,'   No inputs, a screen menu will appear.'
	  return
	endif

	menu = [$
	  '|5|3|TXT routine demonstration and test||',$
	  '|5|5|QUIT| |QUIT|', $
	  '|20|5|HELP| |HELP|', $
	  '|5|7|Select one of the following routines to demonstrate:||',$
	  '|5|9|txtmess| |MESS|', $
	  '|5|11|txtin| |IN|', $
	  '|5|13|txtfile| |FILE|', $
	  '|5|15|txtpick| |PICK|', $
	  '|40|9|txtgetfile| |GET|', $
	  '|40|11|txtyesno| |YES|', $
	  '|40|13|txtmeter| |METER|']

	is = 'MESS'

loop1:	txtmenu, init=menu
loop2:	txtmenu, select=is, uval=uval
	is = uval

	case is of
	;------  QUIT  -------
'QUIT':	begin
	  printat,1,1,/clear
	  return
	end
	;------  HELP  -------
'HELP':	begin
	  txtmess,['TXTDEMO both demonstrates and tests the txt routines.',$
	   'The TXT routines are a set of routines that apply direct',$
	   'screen addressing to perform various functions such as display',$
	   'messages, prompt and read user input, display interactive menus',$
	   'allow file selection from a list, and display a percentage meter.',$
	   'These routines all use ANSI standard escape sequences so are',$
	   'fairly portable to various text display screens.  They also',$
	   'minimize output so work quite well even at 2400 baud over modems.',$	   ' ','The initial screen menu demonstrates the routine txtmenu.',$
	   'Select any of the routines using the arrow keys as',$
	   'described by the ? for help option.']
	  goto, loop1
	end
	;------  txtmess  -------
'MESS':	begin
	  txtmess,'This is a message displayed by txtmess'
	  goto, loop1
	end
	;------  txtfile -------
'FILE':	begin
	  txtfile,tmp
	  txtmess,['The selected file was:',tmp],wait=3
	  goto, loop1
	end
	;------  txtgetfile -------
'GET':	begin
	  txtgetfile,tmp
	  txtmess,['The selected file was:',tmp],wait=3
	  goto, loop1
	end
	;------  txtyesno -------
'YES':	begin
	  ans = txtyesno('Are you hungry?')
	  txtmess,['The answer was '+(['no','yes'])(ans)], wait=3
	  goto, loop1
	end
	;------  txtin  ------
'IN':	begin
	  txtin,'Enter a value (def="no entry").',txt,def='no entry'
	  ;---  menu text array is updated so that future complete  ---
	  ;---  menu display will be correct even though for this   ---
	  ;---  option only the changed part of the screen is updated. ---
	  menu(5) = '|5|11|txtin|'+txt+'|'
	  ;---  Only update the changed part of the screen display ---
	  txtmenu,update=menu(5)
	  ;---  Just go for another selection, not menu redisplay ---
	  goto, loop2
	end
	;------  txtpick  -------
'PICK':	begin
	  cd, curr=curr
	  txtmess,['To demonstrate this option you will be prompted for',$
	    'a directory and a wild card that will selected a number of',$
	    'files.  These may be varied to see what happens for various',$
	    'numbers of files in the selection list.']
loop6:	  printat,1,1,/clear
	  txtin, 'Enter directory. Enter . for current directory.'+$
	   ' Press RETURN to quit.',dir
	  if dir eq '' then goto, loop1
	  if dir eq '.' then dir = curr
	  txtin,'Enter file name wildcard.',wild
	  if wild eq '' then goto, loop1
	  txtin,'Enter S for single (def) or M for multiple file selection.',$
	    mode,def='S'
	  mode = strupcase(mode)

	  name = filename(dir,wild,/nosym)
	  list = findfile(name,count=count)
	  if count lt 1 then begin
	    txtmess,'No files found'
	    goto, loop6
	  endif

	  txtpick, list, out, multiple=(mode eq 'M')
	  if out(0) eq 'none' then goto,loop1
	  if n_elements(out) eq 1 then t = 'Selected file is:' else $
	    t = 'Selected files are:'
	  txtmess,[t,out]
	  goto, loop6
	end
	;------  txtmeter  -------
'METER':	begin
	  txtmess,['txtmeter displays a 0 to 100% meter on the screen.',$
	    'The setting on this meter may be updated, either up or down',$
	    'from the last value specified.  This demo will set up an',$
	    'array of random number from 0 to 100% and sequentually',$
	    'display their values on the screen meter.']
	  y = makey(200)
	  y = y-min(y)
	  y = y/max(y)
	  txtmeter, y(0),/init,title='Example screen meter',y=10
	  for i=0,199 do begin
	    txtmeter,y(i)
	    wait,.05
	  endfor
	  goto, loop1
	end
else:	begin

	end
	endcase

	end
