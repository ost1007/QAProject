set current_path=%cd%
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -i Classics --removekeywords wuks --removekeywords name:*Execution* -d Output\ Create_Customer.txt