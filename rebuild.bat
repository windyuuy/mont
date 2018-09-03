@echo off
cd moonscript
call moonc *.moon cmd/*.moon compile/*.moon parse/*.moon transform/*.moon
cd ..
@rem pause
echo on
