set current_path=%cd%
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -i BFGIMS -d Output\ --exitonfailure -v TC_ID:DR55_SC61 01_CustomerCreation_Full.txt