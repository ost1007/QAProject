set DISABLE_SIKULI_LOG=yes
set current_path=%cd%
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -i CustomerCreation -d Output\ Create_Customer.txt