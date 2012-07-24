#!/bin/bash

rm -rf xst

echo "xst -ifn "system_xst.scr" -intstyle silent"

echo "Running XST synthesis ..."

xst -ifn "system_xst.scr" -intstyle silent -ise ../__xps/ise/system.ise 
if [ $? -ne 0 ]; then
  exit 1
fi

echo "XST completed"

rm -rf xst

mv ../implementation/system.ngc .
ngcbuild ./system.ngc ../implementation/system.ngc -sd ../implementation -i -ise ../__xps/ise/system.ise
if [ $? -ne 0 ]; then
  exit 1
fi
