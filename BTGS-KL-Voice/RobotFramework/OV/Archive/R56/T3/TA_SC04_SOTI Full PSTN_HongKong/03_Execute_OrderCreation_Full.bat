set current_path=%cd%
set	DISABLE_SIKULI_LOG=yes
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -d OutputTestImgDir\ -v TC_ID:R55_TA_SC04_01 -v IMAGE_FOLDER:img_Veena 03_OrderCreation_Full.txt