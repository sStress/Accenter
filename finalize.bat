c:\perl\perl.exe -x -pi.~ %0 %1 %2 %3 %4 %5
pause
exit
#!perl

s/\'/`/g;
s/�/�`/g;
s/``/`/g;