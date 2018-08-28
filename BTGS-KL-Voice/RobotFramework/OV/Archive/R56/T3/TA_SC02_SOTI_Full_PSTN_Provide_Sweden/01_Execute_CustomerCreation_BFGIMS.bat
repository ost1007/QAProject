set current_path=%cd%
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -i BFGIMS -v TC_ID:R56SWESOTI02 -d OutputBFG01\ --exitonfailure 01_CustomerCreation_Full.txt
