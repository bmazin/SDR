;-------------------------------------------------------------
;+
; NAME:
;       TXTMENU_HELP
; PURPOSE:
;       Gives detailed help for the TXTMENU routine.
; CATEGORY:
; CALLING SEQUENCE:
;       txtmenu_help
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: not meant to be run directly, but by the
;         command txtmenu,/morehelp
;       
;       There is a set of screen menu support routines:
;       TXTMENU --- the screen menu routine itself.
;       TXTIN --- prompts and reads user input allowing defaults.
;       TXTMESS --- displays a message on the screen.
;       TXTYESNO --- asks a yes/no questions and returns answer.
;       TXTFILE --- prompts for a single file (and directory).
;       TXTPICK --- prompts for multiple files.
;       TXTMETER --- displays a 0 to 100% updatable meter on screen.
; MODIFICATION HISTORY:
;       R. Sterner, 27 Feb, 1992
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro txtmenu_help, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Gives detailed help for the TXTMENU routine.'
	  print,' txtmenu_help'
	  print,' Note: not meant to be run directly, but by the'
	  print,'   command txtmenu,/morehelp'
	  print,' '
	  print,' There is a set of screen menu support routines:'
	  print,' TXTMENU --- the screen menu routine itself.'
	  print,' TXTIN --- prompts and reads user input allowing defaults.'
	  print,' TXTMESS --- displays a message on the screen.'
	  print,' TXTYESNO --- asks a yes/no questions and returns answer.'
	  print,' TXTFILE --- prompts for a single file (and directory).'
	  print,' TXTPICK --- prompts for multiple files.'
	  print,' TXTMETER --- displays a 0 to 100% updatable meter on screen.'
	  return
	endif
 
	;------  Set up help menu  --------
	menu = [$
	  '|5|3|Help on using TXTMENU||', $
	  '|5|5|  Quit help| |QUIT|', $
	  '|5|7|There are 3 modes selected by the following keywords:||', $
	  '|5|9|INITIALIZE| |INIT|', $
	  '|5|11|SELECTION| |SEL|', $
	  '|5|13|UPDATE| |UP|', $
	  '|5|15|Other help topics:||', $
	  '|5|17|Menu format| |FORM|', $
	  '|5|19|All keywords| |ALL|', $
	  '|5|21|Example| |EX|', $
	  '|25|9|Must be done first||', $
	  '|25|11|Used to select a menu item||', $
	  '|25|13|Used to update one item without doing the entire screen||', $
	  '|25|17|Detailed description of menu format||', $
	  '|25|19|Brief description of all keywords||', $
	  '|25|21|A short example||']
 
	ss = 'INIT'		; Start with the menu item INIT.
 
	;------  Display menu  -------------
loop:	txtmenu, init=menu
	txtmenu, select=ss, uvalue=opt
 
	;------  Process selected option  ---------
	case opt of
'QUIT':	return
'INIT':	begin
	 txtmess,[$
	 'The first call to TXTMENU must use the INITIALIZE keyword.',$
	 '  Ex: TXTMENU, INITIALIZE=txtarr',$
	 'This keyword initializes the screen menu based', $
	 'on the contents of the given string array, txtarr.',$
	 'Each element of txtarr defines one menu item where the',$
	 'format is: /column/line/tag/value/uvalue/  (see Menu format).',$
	 ' ',$
	 'The following keywords may only be used with INITIALIZE:',$
	 '   (They may never actually be needed)',$
	 'SEPERATOR=ss sets the text string to place between a tag name',$
	 '  and its value (def=": ").',$
	 'DELIMITER=dd returns the menu item delimiter (see Menu format).', $
	 'XY=xy returns array of all menu item positions (see Menu format).',$
	 'TAG=tt returns array of all menu tags (see Menu format).',$
	 'VALUE=vv returns array of all menu item values (see Menu format).',$
	 'UVALUE=vv returns array of all menu item uvalues (see Menu format).']
	end
'SEL':	begin
	  txtmess,[$
	   'TXTMENU menu items are selected using the SELECTION keyword.',$
	   '  Ex: TXTMENU, SELECTION=s',$
	   'This keyword allows menu items to be selected using the keyboard',$
	   'arrow keys to move from one item to another.  The variable s',$
	   'must be defined before calling TXTMENU and must have a valid',$
	   'value.  The value must be the menu item number (first is 0) or',$
	   'one of the user values, uvalue, specified in the menu setup as',$
	   'described under the Menu format help option.',$
	   'Menu items are highlighted with inverse video when there are',$
	   'the current item and may be selected by pressing either RETURN',$
	   'or the SPACE key.  The returned value of SELECT is always the',$
 	   'menu item number. The following keywords may be used with SELECT:',$
	   'UVALUE=u  returns the user value associated with the selected',$
	   '  menu item (if any).  See Menu format on how to set uvalues.',$
	   '  User values are useful as the selector in a case statement.',$
	   '/MULTIPLE inhibits the un-highlighting of an item on exit so the',$
	   '  program calling TXTMENU can make multiple calls until to select',$
	   '  multiple items until a quit option is selected. Useful for',$
	   '  selecting multiple files from a list.']
	end
'UP':	begin
	  txtmess,[$
	    'Single menu items may be updated without reprinting everything.',$
	    '  Ex: TXTMENU,UPDATE=txt',$
	    'where txt has the same format for a menu item as used in the',$
	    'menu setup (see Menu format).  The menu item position given',$
	    'in txt must agree with an existing menu item, but tag, value,',$
	    'and uvalue may be changed.  UPDATE is normally used after the',$
	    'SELECTION option has been used to select an item and a new',$
	    'value been obtained from the user (perhaps using TXTIN).']
	end
'FORM':	begin
	  txtmess,[$
	    'The menu definition array format',$
	    ' ',$
	    'The screen menu is defined by a string array where each menu',$
	    'item is defined by one element in the string array. Each menu',$
	    'item is defined by 5 parameters: (1) the X position (column',$
	    'from 1 to 80), (2) the Y position (line from 1 (=top) to 24),',$
	    '(3) name of item (tag), (4) the item value if any, and (5) an',$
	    'optional user value which may be returned when an item is',$
	    'selected.  The menu item description is formatted as follows:',$
	    '         /column/line/tag/value/uvalue/',$
	    'where / may be any delimiter (avoid \).',$
	    'Ex:  /5/1/Number of dogs/101/ will display:',$
	    'Number of dogs: 101     at column 5 line 1.',$
	    ' ',$
	    'The menu layout array may contain null strings and strings',$
	    'with * in column 1, both are ignored. This is useful in',$
	    'reading a menu layout array from a text file.',$
	    ' ',$
	    'More details on each menu item parameter follows next.']
 
	  txtmess,[$
	    'Column: runs from 1 to 80.',$
	    'Line: runs from 1 (top) to 24 (bottom).',$
	    'Tag: Text which is displayed at the indicated position.',$
	    '  Tags commonly describe the value which follows, or',$
	    '  the action taken when that menu item is selected.',$
	    '  Tags may also be titles or other informative text.',$
	    'Value: Text that gives the value for tag. There are 3 cases:',$
	    '  If the value is non-white space and non-null it is displayed.',$
	    '  If the value is a null string (//) then the tag is displayed',$
	    '    underlined and may not be selected (but is still numbered).',$
	    '    This is good for titles or other information.',$
	    '    Underscore (_) may be used as a null value (use with uval).',$
            '  If the value is a space (/ /) the menu item acts like a',$
	    '    button and is not followed by the seperator.',$
	    '  Options may be turned on or off by modifying the menu array',$
	    '  entry for that item to have or not have a space as its value.',$
	    "  Ex: '/5/8/Compute/'+val+'/' where val=' ' or '' will",$
	    '  turn the Compute option on or off.',$
	    ' ',$
	    '  A description of the last menu item parameter, uvalues, follows']
	  txtmess,[$
	    'Uvalue: optional text that may be anything the user specifies.',$
	    '  This value may be returned from the selection mode of TXTMENU',$
	    '  in the keyword UVALUE, as in:',$
	    '     TXTMENU, SELECT=s, UVALUE=u',$
	    '  Its intended purpose is to associate a short constant flag',$
	    '  value with each menu item so the flag can be used in a case',$
	    '  statement to process the menu item.  The value returned in the',$
	    '  keyword SELECTION is the menu item number which can change',$
	    '  if the menu is modified, the UVALUE will not change.  Uvalues',$
	    '  could be things like QUIT for a quit option, HELP for a',$
	    '  help option, PROC for a processing option, and so on.',$
	    ' ',$
	    'In the SELECTION mode of TXTMENU the UVALUE of the option to',$
	    'highlight as the current item may be sent as the SELECTION',$
	    'value, as in: S="HELP" & TXTMENU,SELECT=s',$
	    'In this way one option can determine which option should come',$
	    'next and suggest it to the user by highlighting it.',$
	    ' ',$
	    'This is the end of the menu format help.']
	end
'ALL':	begin
	  txtmess,y=1,[$
	    '--- A brief description of all the TXTMENU keywords ---',$
	    ' ',$
	    'INITIALIZE=txtarr  Decode and start a screen menu as defined',$
	    '    in the string array txtarr (1 element per menu item).',$
	    '  SEPERATOR=ss sets the text string to place between a tag name',$
            '      and its value (def=": ").',$
            '  DELIMITER=dd returns the menu item delimiter.', $
            '  XY=xy returns array of all menu item positions (like "/5/7/").',$
            '  TAG=tt returns array of all menu tags.',$
            '  VALUE=vv returns array of all menu item values.',$
            '  UVALUE=vv returns array of all menu item uvalues.',$
	    'SELECTION=s starts menu selection at the menu item number s or',$
	    '    the item with uvalue=s, and returns the item number of a',$
	    '    selected option (number not uvalue, use UVALUE=u for that).',$
	    '  UVALUE=u returns the uvalue of the selected menu item.',$
	    '  /MULTIPLE inhibits item unhighlighting on exit from selection.',$
	    'UPDATE=txt update the single menu item defined in the string txt',$
	    '    which has the same format as an element in the INITIALIZE',$
	    '    string array used to set up the menu.  The position of the',$
	    '    updated item must match the menu item being updated, but',$
	    '    the item tag, value, and uvalue may be changed.']
	end
'EX':	begin
	  txtmess,[$
	    'A brief example will be given on using TXTMENU.',$
	    ' ',$
	    'First set up a menu definition array:',$
	    "  cval = 'Red'",$
	    "  t = ['|5|3|This is an example screen menu||',$",$
	    "       '|5|5|Quit| |QUIT|',$",$
	    "       '|25|5|Ring bell| |BELL|',$",$
	    "       '|5|7|Enter color. Now|'+cval+'|CLR|',$",$
	    "       '|5|9|The Process option shows a screen meter||',$",$
	    "       '|5|11|Process| |PRC|']",$
	    ' ',$
	    'Next the calls needed to use this menu will be shown.']
	  txtmess,y=1,[$
	    'Using the menu',$
	    ' ',$
	    "         s = 'CLR'                   ; Set initial selection.",$
	    '         txtmenu, init=t             ; Start menu.',$
	    'loop:    txtmenu,select=s,uval=opt   ; Select an option.',$
	    '         case opt of                 ; Process the option.',$
	    "'QUIT':  return",$
	    "'BELL':  bell",$
	    "'CLR':   begin",$
	    "           txtin,'Enter a new color.',in,def=cval",$
	    "           cval = in",$
	    "           txtmenu,update='|5|7|Enter color. Now|'+cval+'|CLR|'",$
	    "         end",$
	    "'PRC':   begin",$
	    "           ... code to do screen meter ...",$
	    "         end",$
	    "         endcase",$
	    "         goto, loop",$
	    ' ',$
	    'Next you may actually try this menu.']
	  cval = 'Red'
	  t = ['|5|3|This is an example screen menu||',$
	    '|5|5|Quit| |QUIT|',$
	    '|25|5|Ring bell| |BELL|',$
	    '|5|7|Enter color. Now|'+cval+'|CLR|',$
	    '|5|9|The Process option shows a screen meter||',$
	    '|5|11|Process| |PRC|']
	    s = 'CLR'                   ; Set initial selection.
	    txtmenu, init=t             ; Start menu.
eloop:      txtmenu,select=s,uval=opt   ; Select an option.
	    case opt of                 ; Process the option.
'QUIT':     goto, loop
'BELL':     bell
'CLR':      begin
	      txtin,'Enter a new color.',txt,def=cval
	      cval = txt
	      txtmenu,update='|5|7|Enter color. Now|'+cval+'|CLR|'
	    end
'PRC':      begin
	      time = maken(0,1,100)^2
	      txtmeter,0,title='Processing progress:',/init
	      for i=0,99 do begin
	        txtmeter,time(i)
	        wait,.05
	      endfor
	      wait,3
	      txtmeter, /clear
	    end
	    endcase
	    goto, eloop
	end
	endcase
	goto, loop
 
	end
