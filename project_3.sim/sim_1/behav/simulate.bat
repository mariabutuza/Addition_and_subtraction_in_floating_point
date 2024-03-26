@echo off
set xv_path=D:\\Programe\\Vivado\\2016.4\\bin
call %xv_path%/xsim AddSubVMTest_behav -key {Behavioral:sim_1:Functional:AddSubVMTest} -tclbatch AddSubVMTest.tcl -view C:/Users/Dell/Desktop/incercredenumire/project_3/AddSubVMTest_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
