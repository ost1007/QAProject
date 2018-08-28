set current_path=%cd%
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -d Output\ --exitonfailure 01_CustomerCreation_Full.txt