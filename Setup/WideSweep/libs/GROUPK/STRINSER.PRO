;+
; NAME:
;        STRINSERT
;
; PURPOSE:
;        The STRINSERT procedure inserts the contents of one string into
;        another WITHOUT overwriting any existing characters.  The source
;        string, Source is inserted into the destination string,
;        Destination between the given positions, Position-1 and Position.
;        The length of the destination string is increased by the length
;        of the source string, Source. If the insertion position extends
;        beyond the length of Destination, then Source is appended to the
;        end of Destination.
;
; CATEGORY:
;        String Processing.
;
; CALLING SEQUENCE:
;
;        STRINSERT, Destination, Source [, Position]
;
; INPUTS:
;        Destination:   The named string variable into which Source
;                  is inserted.  Destination must be a named variable of
;                  type string.  If it is an array, Source is inserted
;                  into every element of the array.
;
;        Source:   A scalar string to be inserted into Destination.
;                  If this argument is not a string, it is converted
;                  using IDL's default formatting rules.
;
; OPTIONAL INPUTS:
;
;        Position: The character position before which the insertion
;                  is begun.  If Position is omitted, the insertion
;                  begins before the first character (character
;                  position 0).  If Position is less than zero, zero
;                  is used for the initial position.
;
; EXAMPLE:
;
;        If the variable A contains the string "IBM is fun", the
;        substring "'s OS/2 Warp' can be inserted after "IBM"
;        by entering:
;
;        STRINSERT, A, '''s OS/2 Warp', 3
;
; MODIFICATION HISTORY:
;        Written by:    Han Wen, June 1995.
;-
pro STRINSERT, Destination, Source1, Position

;   Check integrity of input parameter

         NP        = N_PARAMS()
         if (NP lt 2) then message,'Must be called with 2-3 parameters, '+$
                   'Destination, Source [, Position]'
         if (NP eq 2) then Position = 0

         sz        = SIZE(Destination)
         ns        = n_elements(sz)
         if (sz(ns-2) ne 7) then message,'Parameter must be of string type.'

         Source    = STRING(Source1)
         nstr      = N_ELEMENTS(Destination)

         len       = MAX(strlen(Destination))
         prefix    = STRMID(Destination,0,Position)
         suffix    = STRMID(Destination,Position,len-(Position))

         Destination = prefix + Source + suffix
end
