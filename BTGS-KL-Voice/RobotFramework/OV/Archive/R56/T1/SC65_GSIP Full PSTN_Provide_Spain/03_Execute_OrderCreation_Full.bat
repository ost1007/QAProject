set current_path=%cd%
set	DISABLE_SIKULI_LOG=yes
cd C:\AmdocsCRM8.1.0.4\ClarifyClient
start clarify.exe
cd %current_path%
pybot -d OutputTestImgDir\ -v TC_ID:R56_SC65_SP_C1_7 -v IMAGE_FOLDER:img_Veena 03_OrderCreation_Full.txt
