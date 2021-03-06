Public Function fn_Classic_Login(ByVal ApplicationPath, ByVal StartupFolderPath, ByVal Username, ByVal Password)
	'Variable Declaration
	Dim iCounter
	Dim oFSO
	
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	If Not oFSO.FolderExists(StartupFolderPath) Then
		Call ReportLog("Folder Exists", StartupFolderPath & " - Folder should exist", StartupFolderPath & " - Folder doesn't exist", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If Not oFSO.FileExists(ApplicationPath) Then
		Call ReportLog("Clarify.Exe Exists", ApplicationPath & " - should exist", ApplicationPath & " - doesn't exist", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If oFSO.FolderExists(StartupFolderPath & "\CBcache")  Then
		For Each File In oFSO.GetFolder(StartupFolderPath & "\CBcache").Files
			File.Delete
		Next	
	End If
	
	'Delete the below folders as these are cache files
	If oFSO.FileExists(StartupFolderPath & "\CLAST31.cfy") Then oFSO.DeleteFile(StartupFolderPath & "\CLAST31.cfy")
	If oFSO.FileExists(StartupFolderPath & "\CLAST31.6810") Then oFSO.DeleteFile(StartupFolderPath & "\CLAST31.6810")
	
	InvokeApplication ApplicationPath, StartupFolderPath
	For iCounter = 1 To 5 Step 1
		blnResult = Window("AmdocsCRM").Dialog("AmdocsCRMLogin").WinEdit("txtUserName").Exist(60)
		If blnResult Then
			Window("AmdocsCRM").Dialog("AmdocsCRMLogin").Activate
			Exit For '#iCounter
		End If
	Next '#iCounter
	
	blnResult = BuildAmdocsWindowReference("AmdocsCRM", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterDialogText("AmdocsCRMLogin", "txtUserName", Username)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterDialogText("AmdocsCRMLogin", "txtPassword", Password)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickDialogButton("AmdocsCRMLogin", "btnLogin")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = Dialog("Clarify").WinButton("btnYes").Exist(60*5)
	If blnResult Then
		Dialog("Clarify").WinButton("btnYes").Click
	Else
		Call ReportLog("Application Authorization", "Dialog prompting with Authorization of system should exist", "Dialog is not visible after 5mins", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If
	
	blnResult = Window("AmdocsCRM").WinToolbar("StingrayMenuBar").Exist(60*5)
	If blnResult Then
		Call ReportLog("Login", "Should be Nagivated to Amdocs CRM Window", "Nagivated to Amdocs CRM Window", "PASS", True)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Login", "Should be Nagivated to Amdocs CRM Window", "Could not nagivate to Amdocs CRM Window", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If
End Function
