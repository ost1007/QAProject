set current_path=%cd%
set	DISABLE_SIKULI_LOG=yes
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot --exitonfailure -d Output\TACNF01\CLSC01\ -v TC_ID:TACNF01 -v IMAGE_FOLDER:imgs 03_OrderCreation_Full.txt