;===============================================================
;       eqv3_load_help = Load help text variables
;	R. Sterner, 2000 May 11
;	R. Sterner, 2004 Oct 11 --- Documented FLAGS.'
;	Separated to keep file short for fast loading.
;===============================================================
 
	pro eqv3_load_help, t_1, t_2, t_3, t_4, t_5, t_6, t_7, t_8, t_9
 
	;-----  Grab all help text in one big chunk (into txt)  ----------
	text_block, txt, /quiet
;# Section 1
; Overview
;
; The Equation Viewing tool, EQV3, makes it easy to execute
; IDL code and vary parameters used in that code.
; Parameters may be varied by moving a slider
; bar allowing the effects of hundreds of values to be
; examined in seconds.  The IDL code itself may be modified
; with the result being instantly displayed.  Code
; changes and the current parameter settings may be saved
; in a new equation file and the current plot may be sent
; to the printer.
;
; The code is displayed in the current plot window which
; must have suitable scaling already set.  Actually the
; code need not be graphical at all, print,bindgen(n) will
; display a variable number of integers depending on the
; slider setting for parameter n.
;
; The IDL command line is not blocked so other IDL commands
; may be given, including plotting in the current plot window.
;
;# Section 2
; Plot Window
;
; The plot window is the current window when EQV3 is called.
; EQV3 assumes suitable scaling has been set up before it is
; called.  Example calls that may set up such scaling are
; PLOT, IZOOM, MAP_SET and so on.  Make sure the correct window
; is current before calling EQV3 if graphics are to be used.
;
;# Section 3
; Code display and entry area
;
; The current code is shown in the top text area of
; the EQV3 widget.  The code may be modified just by
; deleting or typing text in this area.  Press RETURN (ENTER)
; to see the results of the change.  Several items to note:
;  
; The parameters in the code must be the
; same as named in the adjustable paramaters below.
;  
; The variable names used in the equation may be changed.
; To do so, change one parameter in the equation, but DO
; NOT press RETURN after.  Then make the same name change
; in the parameter control panel and press RETURN.  Repeat
; for each parameter.
; 
;# Section 4
; Adjustable parameters
;  
; Below the code display area is the adjustable
; parameter control panel.  Each adjustable parameter in
; the code has a set of labeled text entry fields,
; three buttons, and a slider bar.  These are discussed below.
;  
; Parameter name: The left-most text entry field for each
;     parameter.  See note on name changing under the code
;     help section.
;  
; Optional Parameter units: If units were defined in the
;     equation file they will be displayed here.
;
; Parameter value field: The text entry field to the right
;     of the parameter name.  It displays the current value of
;     the parameter.  It will be updated as the slider bar
;     is moved.  If a new value is entered, press RETURN.
;  
; Parameter range fields: these give the min and max values
;     for the slider bar.  These values may be changed by
;     typing new values and pressing RETURN (ENTER).
;  
; Range Min and Max buttons: these set the range min or
;    max to the current parameter value.  They make it easy
;    decrease the range for finer control.  To increase the
;    range new values must be typed in the fields.
;
; Default value button: This is the button on the right for
;    each parameter.  It resets the value to the entry value
;    which is the default set in the equation file.
;  
; Slider bar: the mouse is used to move the slider bar
;     pointer to change the value of the corresponding
;     adjustable parameter.
;  
; Note: there may be extra parameters unused in the code.
; These may be used to add new adjustable parameters.
; 
;# Section 5
; Command buttons
;
; On the left of the bottom line are several command buttons:
; 
; File
;    Quit --- Execute any exit code, then quit.
;    Quit and List --- Execute any exit code, List, then quit.
;    List --- List the current equation and parameter values.
;    Snap --- Save the current equation and parameter settings
;             to a new equation file.
;
; Display
;    Bring window to front --- Useful if the window is hidden.
;    Refresh plot window --- Not available for maps.  Clears
;         away any graphics added after starting EQV3.
;    Optional process buttons: If the file xview.txt exists in your
;      home directory it may contain added processing buttons.
;      See the section "Adding functions and printers" for details.
;
; Print --- May contain a list of PS printers.  Obtained fro the file
;      xview.txt in your home directory.   See the section "Adding
;      functions and printers" for details.
;
; Help
;    Various help topics.
;
;# Section 6
; The Equation File format
;
; Note: The terms equation file, equation viewer, and so on are leftovers
; from when the software was restricted to dealing with equations only.
; EQV3 has been generalized to execute fragments of IDL code, but the
; the term equation is still scattered throughout the documentation.
;
; The equation viewer, EQV3, may be given an initialization
; file called an equation file.  The calling syntax is:
;   eqv3, name
; where the default extension is .eqv,
; like gaussian.eqv.  So eqv3,'gaussian' is ok.
;  
; Equation files set up code and parameter values.
;  
; Equation files contain 3 types of lines: comment lines,
; null lines, and keyword/value lines.  Comment lines have
; * in line 1.  Null lines have no text.  Keyword/value
; lines have a keyword starting in column 1.  The keyword
; is followed by a colon (:).  The value is on the rest of
; line.  Only equation lines may be continued by adding a $
; to the end of the each line to be continued.
;  
; Example equation file:
;  
; *---------  gaussian.equ = Gaussian curve  -----------
; *	R. Sterner, 25 Oct, 1993
;  
; eq: plot,amp*exp(-(maken(-10,10,100)-mu)^2/sigma)
; par: amp -10 10 8
; par: mu -10 10 0
; par: sigma 0 100 6
;
; init: plot,[-10,10],[-10,10],col=32,back=23
; init: imgneg
; exit: erase
;  
; All the recognized keywords are listed below in example
; lines with a discussion on the next line(s).
;  
; eq: plot,a*sin(maken(-10,10,100)/b)
;     The initial code.  It may be continued by
;     ending lines with a $.  Don't forget & between lines, for example:
; eq: win_redirect &$
;     erase & tvscl,rot(p1,a,miss=0)>lo<hi,ix,iy &$ 
;     win_copy
; flags: name1=v1 name2=v2 ... namen=vn
;     Optional single flags line giving names and initial settings (0 or 1).
;     Values are only 0 or 1.  Will create a line of toggle buttons, one
;     button for each flag.  Can use flags by name in the code given for eq.
;     Example:
;       eq: map_set,/cont,noborder=1-border
;       flags: border=0
; par: lo 0 1 0
; par: hi 0 1 255
; par: ix 0 500 100
; par: iy 0 500 100
; par: a 0 360 0
;     Adjustable parameter definition line.  Must have 4
;     items: parameter name, slider bar min, slider bar max,
;     starting value.  May have an optional 5th item, the
;     word int which forces the integer value to be returned.
;     Int may be useful as a flag of some sort.
;     May also have an optional units definition in the parameter
;     definition line, but it must be last and have the form
;     units=something.  For example:
;     par:  v0  0  1000  325 units=feet/sec
;     (spaces around the = do not matter, the units are anything
;     after the =).  There is one parameter line for each
;     adjustable parameter in the code. Extra parameter lines
;     may be used to define potiential new parameters.
;
; init: plot,[-10,10],[-10,10]
;     As many initialization lines as desired.  These get executed
;     in the order found in the file before anything else is done.
;     May be anywhere in the eqv file.  Useful to set up a plot
;     window if not overlaying an image.
; exit: erase,50 & wait,.1
; exit: erase,100 & wait,.1
;     As many exit lines as desired.  These are handled just like the
;     initialization lines but when the program is exited.
;     One example use for init and exit lines is to do a device,decomp=0
;     on startup and device,decomp=1 on exit.  This allows color table use.
;
;# Section 7
; Adding functions and printers
;
; The first step is to set up a PostScript printer description file
; so that the routine psinit may be used.  The details are found on
; the web page http://fermi.jhuapl.edu/s1r/idl/s1rlib/psinit/psinit.html
;
; The next step is to setup some user defined commands.
; The user may define options which are set up
; as buttons at run time.  These options are defined
; in a simple text file called xview.txt in the user's
; home directory.  Currently two types of options are supported,
; print and process.  The setup file has a simple format of one
; line per option:
;
;    type: label text / comand or printer
;
; type is either the word print or process.
; label text is the text that will appear on the button so
;   should not be too long.
; comand or printer can a printer number or substring of the
;   printer description given by psinit,/list, or a command to
;   be executed if type is process.
;
; Null lines and lines with * as the first character are ignored.
; An example setup file is
;
;*------  xview.txt = user defined xview commands  ---------
;*       R. Sterner, 1997 Oct 1
;
;print: Phaser 340 paper / Paper Color
;print: Phaser 340 trans / Transparency Color
;
;process: Negative / imgneg
;
;  The JHU/APL IDL library routines xview.pro and eqv2.pro both
;  use the file xview.txt to set up user defined print buttons.
;  Note: eqv2.pro adds process options to the dispay menu button.
 
 
 
	one = strmid(txt,0,1)		; Grab first char.
	w = where(one eq '#')		; Indices.
	w = [w,n_elements(txt)]		; Add end index.
 
	t_1 = txt(w(0)+1:w(1)-1)
	t_2 = txt(w(1)+1:w(2)-1)
	t_3 = txt(w(2)+1:w(3)-1)
	t_4 = txt(w(3)+1:w(4)-1)
	t_5 = txt(w(4)+1:w(5)-1)
	t_6 = txt(w(5)+1:w(6)-1)
	t_7 = txt(w(6)+1:w(7)-1)
 
	end
