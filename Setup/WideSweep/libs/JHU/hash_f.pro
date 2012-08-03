;------  hash_f.pro = Hash function  -----
;	R. Sterner, 2004 Mar 29
 
	function hash_f, key
 
	return, long(total(byte(key))) mod 6000L
 
	end
