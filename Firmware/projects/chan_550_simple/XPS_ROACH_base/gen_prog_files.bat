copy implementation\system.bit ..\bit_files\chan_550_simple_2012_Jul_23_1908.bit
mkbof.exe -o implementation\system.bof -s core_info.tab -t 3 implementation\system.bin
copy implementation\system.bof ..\bit_files\chan_550_simple_2012_Jul_23_1908.bof
