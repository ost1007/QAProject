set current_path=%cd%
set	DISABLE_SIKULI_LOG=yes
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -d Output\ --variable TC_ID:DR55_UK_PSTN --exitonfailure 03_OrderCreation_Full.txt