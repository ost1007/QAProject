'=============================================================================================================
'Description: Function to Confirm SubProject Closure
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			13/08/2015 				NA
'Return Values : NA
'Example: fn_TAHITI_ConfirmSubProjectClosure
'=============================================================================================================
Public Function fn_TAHITI_ConfirmSubProjectClosure()

	'Variable Declaration
	Dim strCeaseProofDocPath

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
	'Click on Matrix Config
	blnResult = clickFrameLink("lnkOrderAttachments")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 10
	objBrowser.Sync

	'Building reference
	blnResult = BuildWebReference("","","frmViewOrderAttachments")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	strCeaseProofDocPath = fn_TAHITI_CreateCeaseProofDoc(GetAttributeValue("dOrderID"))
	If Not CreateObject("Scripting.FileSystemObject").FileExists(strCeaseProofDocPath) Then
		Call ReportLog("Cease Proof Doc", "Cease Proof doc should exist in path <B>" & strCeaseProofDocPath & "</B>", "Cease Proof doc does not exist in path <B>" & strCeaseProofDocPath & "</B>", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Cease Proof Doc", "Cease Proof doc should exist in path <B>" & strCeaseProofDocPath & "</B>", "Cease Proof doc exists in path <B>" & strCeaseProofDocPath & "</B>", "Information", False)
	End If

	objFrame.WebFile("webFileOrderAttachment").Set strCeaseProofDocPath
	Wait 2

	'Click on upload button
	blnResult = clickFrameButton("btnUploadFile")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 10

	'Check whether there is any error after uploading
	Set objElmError = objFrame.WebElement("innertext:=Error uploading the file.*", "index:=0")
	If objElmError.Exist Then
		Call ReportLog("Upload CeaseProof File", "Error encountered", objElmError.GetROProperty("innertext"), "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	
End Function