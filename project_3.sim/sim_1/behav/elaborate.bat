@echo off
set xv_path=D:\\Programe\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto 4f6bd7f03e3d40e585f3f40903acc16b -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot AddSubVMTest_behav xil_defaultlib.AddSubVMTest -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
