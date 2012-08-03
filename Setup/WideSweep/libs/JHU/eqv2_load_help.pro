;===============================================================
;       eqv2_load_help = Load help text variables
;	R. Sterner, 1998 Apr 24.
;	Separated to keep file short for fast loading.
;===============================================================
 
	pro eqv2_load_help, t_1, t_2, t_3, t_4, t_5, t_6, t_7, t_8, t_9
 
	;-----  Grab all help text in one big chunk (into txt)  ----------
	text_block, txt, /quiet
;# Section 1
; Overview
;
; The Equation Viewing tool, EQV2, makes it easy to study
; an equation and see what each parameter in it does.
; Equation parameters may be varied by moving a slider
; bar allowing the effects of hundreds of values to be
; examined in seconds.  The equation itself may be modified
; with the result being instantly displayed.  Equation
; changes and the current parameter settings may be saved
; in a new equation file and the current plot may be sent
; to the printer.
;
; The equation is plotted in the current plot window which
; must have suitable scaling already set.  The curve may
; be plotted over an image non-destructively.  The equation
; may be Y = function(X) (function),  X = f(T) & Y = g(T)
; (parametric), or procedure,par1,par2,...,X,Y (procedure).
;
; The IDL command line is not blocked so other IDL commands
; may be given, including plotting in the current plot window.
;
;# Section 2
; Plot Window
;
; The plot window is the current window when EQV2 is called.
; EQV2 assumes suitable scaling has been set up before it is
; called.  Example calls that may set up such scaling are
; PLOT, IZOOM, MAP_SET and so on.  Make sure the correct window
; is current before calling EQV2.
;
;# Section 3
; Equation display and entry area
;
; The current equation is shown in the top text area of
; the EQV2 widget.  The equation may be modified just by
; deleting or typing text in this area.  Press RETURN (ENTER)
; to see the results of the change.  Several items to note:
;  
; The independent variable in the equation must be the
; same as named in the middle of the bottom widget line or
; an error will occur.  The default independent variable is x.
;  
; Parametric equations may be plotted as follows:
; Define the independent variable in the equation
; file to be t.  Then in the equation area
; enter the two parametric equations for x and y separated
; by &.  For example: x=a*sin(b*t) & y=c*cos(d*t)
; The range and resolution of parameter t is set in the
; independent variable area on the bottom widget line.
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
; Below the equation display area is the adjustable
; parameter control panel.  Each adjustable parameter in
; the equation has a set of labeled text entry fields,
; three buttons, and a slider bar.  These are discussed below.
;  
; Parameter name: The left-most text entry field for each
;     parameter.  See note on name changing under the equation
;     help section.
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
; Note: there may be extra parameters unused in the equation.
; These may be used to add new adjustable parameters.
; 
;# Section 5
; Command buttons
;
; On the left of the bottom line are several command buttons:
; 
; File
;    Quit --- On exit may erase curve, burn it in, or abort exit.
;    List --- List the current equation and parameter values.
;    Snap --- Save the current equation and parameter settings
;             to a new equation file.
;
; Off --- Toggle plotted curve on or off.  Useful for viewing graphics
;         or imagery beneath the plotted curve.
;
; Display
;    Bring window to front --- Useful if the window is hidden.
;    Refresh plot window --- Not available for maps.  Clears
;         away any graphics added after starting EQV2.
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
; The inpendent variable
;
; The independent variable is either X or T.  X is normally used
; for a simple function of one variable, like Y = sin(X) for example.
; T is normally used for parametric equations, like X=R*cos(T) & Y=R*sin(T).
; It is not necessary to use the independent variable, you may generate
; your own using something like FINDGEN or MAKEX, but the independent
; variable is generated anyway so might as well be used.
;
;# Section 7
; The scale factor
;
; A scale factor may be applied to the X values after the equation is
; executed but before it is plotted.  This may in some cases be useful
; for displaying harmonics.  It is normally 1.
;
;# Section 8
; The Equation File format
;
; The equation viewer, EQV2, may be given an initialization
; file called an equation file.  The calling syntax is:
;   eqv2, name
; where the default extension is .eqv,
; like gaussian.eqv.  So eqv2,'gaussian' is ok.
;  
; Equation files set up an equation, parameter values,
; independent variable range, and number of points.
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
; title: Gaussian Curve
; eq: y = amp*exp(-(x-mu)^2/sigma)
; xrange: -10, 10
; n_points: 100
; par: amp -10 10 8
; par: mu -10 10 0
; par: sigma 0 100 6
;
; init: plot,[-10,10],[-10,10]
; init: imgneg
;  
; All the recognized keywords are listed below in example
; lines with a discussion on the next line(s).
;  
; title: Polar Curve # 2.
;     Optional.  Used as the widget title.  Useful as a reminder.
; eq:   y = a*sin(x/b)
;     The initial equation.  It may be continued by
;     ending lines with a $.
; xrange: 0  10
;     The independent variable range if x is used.
;     Use only one of xrange or trange.
; trange: 0  150
;     The independent variable range if t is used.  Intended for parametric
;     equations.  Use only one of xrange or trange.
; n_points: 1000
;     Number of points in the independent variable range.
;     Defaults to 100.
; par: a       1.00000      10.0000      3.12625
; par: b       1.00000      10.0000      3.68875
;     Adjustable parameter definition line.  Must have 4
;     items: parameter name, slider bar min, slider bar max,
;     starting value.  May have an optional 5th item, the
;     word int which forces the integer value to be returned.
;     Int may be useful as a flag of some sort.  There is one
;     parameter line for each adjustable parameter in the equation.
;     Extra parameter lines may be used to define potiential new
;     parameters.
;
; init: plot,[-10,10],[-10,10]
;     As many initialization lines as desired.  These get executed
;     in the order found in the file before anything else is done.
;     May be anywhere in the eqv file.  Useful to set up a plot
;     window if not overlaying an image.
;
;# Section 9
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
	t_8 = txt(w(7)+1:w(8)-1)
	t_9 = txt(w(8)+1:w(9)-1)
 
	end
