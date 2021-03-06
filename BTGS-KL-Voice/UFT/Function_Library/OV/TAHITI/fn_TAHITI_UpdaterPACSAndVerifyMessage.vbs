'=============================================================================================================
'Description: Utility Function to click on update rPACS button and verify the response
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			02/09/2015 				NA
'Return Values : Boolean
'Example: fn_TAHITI_UpdaterPACSAndVerifyMessage()
'=============================================================================================================
Public Function fn_TAHITI_UpdaterPACSAndVerifyMessage()
	Dim blnVerification
	Dim strInnerText, strText, strTaskName, strInnerHTML
	Dim intCounter

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	blnResult = clickFrameButton("btnUpdaterPACS")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

    strTaskName = objPage.Frame("frmContent").WebElement("elmTaskDetails").GetROProperty("innertext")
	If Instr(strTaskName, "Activate Service for Test and Turnup (Change)") > 0  Then
		Message = "Successful Response Received from rPACS for Activate Service for Test and Turnup (Change)"
	Else
		Call ReportLog("New Task encountered", "Please check the task name generated to use this function", "", "Warnings", True)
		fn_TAHITI_UpdaterPACSAndVerifyMessage = False : Exit Function
	End If

	Wait 20

	strInnerText = objPage.Frame("frmContent").Object.documentElement.innertext
	If Instr(strInnerText, "Request has been send successfully to rPACS") > 0 Then
		Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has been send successfully to rPACS", "PASS", True)
	Else
		Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has not been send successfully to rPACS", "FAIL", True)
		Environment("Action_Result") = False : Exit FUnction
	End If

	blnVerification = False
	For intCounter = 1 To 50
		strText = objPage.Frame("name:=notesFrame").Object.documentElement.innerText
		strInnerHTML = objPage.Frame("name:=notesFrame").Object.documentElement.innerHtml
		If Instr(strText, Message) > 0 Then
			Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message exists</BR>" & strInnerHTML, "PASS", True)
			blnVerification = True
			Exit For
		Else
			Wait 30
			objPage.Link("name:=All", "index:=0").Click
			Wait 5
		End If
	Next

	If Not blnVerification Then
		Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message doen't exists</BR>" & strInnerHTML, "FAIL", True)
	End If

	fn_TAHITI_UpdaterPACSAndVerifyMessage = blnVerification
End Function

		
