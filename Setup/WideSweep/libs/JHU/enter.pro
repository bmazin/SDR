;-------------------------------------------------------------
;+
; NAME:
;       ENTER
; PURPOSE:
;       Prompted entries allowing defaults. Help, IDL/DCL commands.
; CATEGORY:
; CALLING SEQUENCE:
;       value = enter(type, prompt, default, [exit_flag, help_text])
; INPUTS:
;       type = Data type to return.                     in
;          Allowed types are:
;          'STRING' = string
;          'BYTE' = byte
;          'INTEGER' = integer
;          'LONG' = long integer
;          'FLOAT' = float
;          'DOUBLE' = double float
;       prompt = prompt string.                         in
;          Any occurence of $DEF in the prompt string
;          is replaced by the default value, so the
;          prompt message may display the default.
;       default = default value.                        in
;       help_text = text to display for ? command.      in
;          String or string array for multiple lines.
;          $DEF in the help string is replaced by
;          the def. value.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       exit_flag = exit status flag.                   out
;          Valid values are:
;           0 = normal exit.
;           1 = quit on return.
;          -1 = backup to last entry.
;          11 = invalid data type.
;          12 = def. val. cannot convert to desired
;               data type.
;       value = returned value of desired type.         out
; COMMON BLOCKS:
; NOTES:
;       Notes: The following commands are allowed as ENTER entries:
;         Value requested.
;         Null entry. Gives default value
;           (for calling error may return error flag).
;         Expressions. Processes given IDL expression.
;         Q. Returns quit value (1) in exit flag.
;         B. Returns backup value (-1) in exit flag.
;         IDL statment. Executes given IDL statement.
;         $ statement. Executes given shell statement.
; MODIFICATION HISTORY:
;       R. Sterner.  17 Oct, 1986.
;       RES 9 OCT, 1989 --- CONVERTED TO SUN.
;       RES 13 Nov, 1989 --- put $DEF in prompt and help_text.
;       R. Sterner, 27 Jan, 1993 --- dropped reference to array.
;       Dr. Jenny Lovell, CSIRO Earth Observation Centre, Australia
;       Fixed a bug in testing if input is a number.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION ENTER, TYP, PROMPT, DEF, EXIT_FLAG, HELP_TEXT, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN	
	  print,' Prompted entries allowing defaults. Help, IDL/DCL commands.'
	  print,' value = enter(type, prompt, default, [exit_flag, help_text])'
	  print,'   type = Data type to return.                     in'
	  print,'      Allowed types are:'
	  print,"      'STRING' = string"
	  print,"      'BYTE' = byte"
	  print,"      'INTEGER' = integer"
	  print,"      'LONG' = long integer"
	  print,"      'FLOAT' = float"
	  print,"      'DOUBLE' = double float"
	  print,'   prompt = prompt string.                         in'
	  print,'      Any occurence of $DEF in the prompt string'
	  print,'      is replaced by the default value, so the'
	  print,'      prompt message may display the default.'
	  print,'   default = default value.                        in'
	  print,'   exit_flag = exit status flag.                   out'
	  print,'      Valid values are:'
	  print,'       0 = normal exit.'
	  print,'       1 = quit on return.'
	  print,'      -1 = backup to last entry.'
	  print,'      11 = invalid data type.'
	  print,'      12 = def. val. cannot convert to desired'
	  print,'           data type.'
	  print,'   help_text = text to display for ? command.      in' 
	  print,'      String or string array for multiple lines.'
	  print,'      $DEF in the help string is replaced by'
	  print,'      the def. value.'
	  print,'   value = returned value of desired type.         out'
	  print,' Notes: The following commands are allowed as ENTER entries:'
	  print,'   Value requested.'
	  print,'   Null entry. Gives default value'
	  print,'     (for calling error may return error flag).'
	  print,'   Expressions. Processes given IDL expression.'
	  print,'   Q. Returns quit value (1) in exit flag.'
	  print,'   B. Returns backup value (-1) in exit flag.'
	  print,'   IDL statment. Executes given IDL statement.'
	  print,'   $ statement. Executes given shell statement.'
	  RETURN, ''
	ENDIF
 
	IF N_PARAMS(0) LT 5 THEN HELP_TEXT = ['']
	NHELP = N_ELEMENTS(HELP_TEXT)
	hlp_txt = help_text
	defstr = strtrim(def,2)
	prmpt = prompt
	prmpt = stress(prmpt, 'R',0,'$DEF',defstr)
	FOR I = 0, NHELP-1 DO $
	  HLP_TXT(I) = stress(hlp_txt(i),'R',0,'$DEF',defstr)
 
 
	TYP = STRUPCASE(TYP)				; force type upper.
 
;------------  get entry  ---------------------
LOOP:	PRINT,prmpt,format='($,a)'	; print prompt (no CR after).
	TXT = ''			; make TXT be a text string.
	READ, '', TXT			; read TXT.
;------------  end of get entry  --------------
 
;------------  null entry  --------------------
	IF TXT EQ '' THEN BEGIN		; try to return default.
	  CASE TYP OF			; try to convert to desired type.
'STRING':   X = STRTRIM(DEF,2)
'BYTE':	    BEGIN
	      if isnumber(def) eq 0 then goto, deferr
	      X = long(DEF)
	      IF (X GT 255) OR (X LT 0) THEN GOTO, DEFERR
	      X = BYTE(X)
	    END
'INTEGER':  begin
	      if isnumber(def) eq 0 then goto, deferr
	      X = long(DEF)
	      if (x gt 32767) or (x lt -32768) then goto, deferr
	    end
'LONG':	    begin
	      if isnumber(def) eq 0 then goto, deferr
	      X = LONG(DEF)
	    end
'FLOAT':    begin
	      if isnumber(def) eq 0 then goto, deferr
	      X = FLOAT(DEF)
	    end
'DOUBLE':   begin
	      if isnumber(def) eq 0 then goto, deferr
	      X = DOUBLE(DEF)
	    end
ELSE:	    BEGIN
	     PRINT,' Error in ENTER: unknown data type.'
	     EXIT_FLAG = 11
	     RETURN, 0
	    END
	  ENDCASE
	  EXIT_FLAG = 0			; no error.
	  RETURN, X			; return converted default.
DEFERR:	  BEGIN				; conversion error on DEF.
	    PRINT,' Error in ENTER: cannot convert given default to '+$
	      TYP+' data type.'
	    EXIT_FLAG = 12
	    RETURN, 0
	  END
	ENDIF
;------------  end of null entry  --------------------
 
;------------  check for ?  ---------------------------
	IF GETWRD(TXT, 0) EQ '?' THEN BEGIN
	  PRINT,' '
	  FOR I = 0, NHELP-1 DO PRINT,' '+HLP_TXT(I)
	  TXT = 'The desired data type for this entry is ' + TYP + '.'
	  PRINT,' The following are allowed as entries:'
	  PRINT,' A value as requested.  ' + TXT
	  PRINT,' Null entry.            RETURN gives the default value.'
	  PRINT,' Expression.            IDL expression, like SQRT(2)'
	  PRINT,' Q                      Quits.'
	  PRINT,' B                      Backs up to last entry.'
	  PRINT,' IDL statment.          Executes the given IDL statement.'
	  PRINT,' $ statement.           Executes the given shell statement.'
	  PRINT,' '
	  GOTO, LOOP
	ENDIF
;-----------  end of ?  -----------------------------
 
 
;------------  check for quit command  ---------------
	IF STRUPCASE(GETWRD(TXT,0)) EQ 'Q' THEN BEGIN
	  EXIT_FLAG = 1
	  RETURN, 0
	ENDIF
;------------  end of quit command  ---------------
 
 
;------------  check for backup command  ---------------
	IF STRUPCASE(GETWRD(TXT,0)) EQ 'B' THEN BEGIN
	  EXIT_FLAG = -1
	  RETURN, 0
	ENDIF
;------------  end of quit command  ---------------
 
 
;------------  check for idl command  --------
	IF STRUPCASE(GETWRD(TXT,0)) EQ 'IDL' THEN BEGIN
	  I = EXECUTE(GETWRD(TXT,-1))
	  GOTO, LOOP
	ENDIF
;-----------  end of idl command  ---------------------
 
 
;------------  check for shell  command  --------
	IF STRSUB(TXT,0,0) EQ '$' THEN BEGIN
	  SPAWN,STRSUB(TXT,1,999)
	  GOTO, LOOP
	ENDIF
;-----------  end of DCL command  ---------------------
 
 
;------------  expression or value  -------------------
	IF TYP EQ 'STRING' THEN BEGIN	; put string entry in ' '
	  TXT = "IN = '" + TXT + "'"
	ENDIF ELSE BEGIN		; but not other entries.
	  TXT = "IN = " + TXT
	ENDELSE
	I = EXECUTE(TXT)		; May give error message.
	IF I NE 1 THEN BEGIN
	  PRINT,' '
	  PRINT,' Enter ? for help.'
	  PRINT,' '
	  GOTO, LOOP
	ENDIF
	CASE TYP OF			; try to convert to desired type.
'STRING': X = STRTRIM(IN,2)
'BYTE':	  BEGIN
	    if isnumber(in) eq 0 then goto, exerr
	    X = long(IN)
	    IF (X GT 255) OR (X LT 0) THEN GOTO, EXERR
	    X = BYTE(X)
	  END
'INTEGER':begin
	    if isnumber(in) eq 0 then goto, exerr
	    X = long(IN)
	    if (x gt 32767) or (x lt -32768) then goto, exerr
	  end
'LONG':	  begin
	    if isnumber(in) eq 0 then goto, exerr
	    X = LONG(IN)
	  end
'FLOAT':  begin
	    if isnumber(in) eq 0 then goto, exerr
	    X = FLOAT(IN)
	  end
'DOUBLE': begin
	    if isnumber(in) eq 0 then goto, exerr
	    X = DOUBLE(IN)
	  end
ELSE:	  BEGIN
	    PRINT,' Error in ENTER: unknown data type.'
	    EXIT_FLAG = 11
	    RETURN, 0
	  END
	ENDCASE
	EXIT_FLAG = 0			; no error.
	RETURN, X			; return converted entry.
EXERR:	BEGIN				; conversion error on IN.
	  PRINT,' Error in ENTER: cannot convert given entry to '+TYP+$
	    ' data type.'
	  GOTO, LOOP
	END
;------------  end of expression or value  ------------
 
	END
