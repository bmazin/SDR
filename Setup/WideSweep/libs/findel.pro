;+
; NAME:
;            FINDEL
;
; PURPOSE:
;            Find the index in ARRAY that is the closest match to 
;            a scalar VALUE.
;
; CATEGORY:
;            Array Handling (?)
;
; CALLING SEQUENCE:
;
;            result = findel(value, array, /matrix)
;
; INPUTS:
;
;            ARRAY - vector to be searched
;            VALUE - Scalar value to be matched
;
; OUTPUTS:
;
;            RESULT - The index of ARRAY which is the closest to VALUE
;
; EXAMPLE:
;
;            IDL> array = [1.3, 2.4, 3.5, 4.2]
;            IDL> value = 3.1
;            IDL> result = findel(value, array)
;            IDL> print,result
;                       2
;            IDL> print,array[result]
;                  3.50000
;
; MODIFICATION HISTORY:
;
; Wheel reinvented (I'm sure) sometime around 12.17.2002 by JohnJohn
; 11.16.2003  JohnJohn - If /matrix set return array containing [col,row].
;                        
;-
function findel,value,array,matrix=matrix,array=retarray
on_error,2    ;Return to caller if an error occurs
diff = abs(array - value)
dum = min(diff,ind)
if keyword_set(retarray) then matrix=1
if keyword_set(matrix) then begin
    sz = size(array)
    ncol = sz[1]
    col = ind mod ncol
    row = ind / ncol
    ind = [col, row]
endif
return,ind
end
