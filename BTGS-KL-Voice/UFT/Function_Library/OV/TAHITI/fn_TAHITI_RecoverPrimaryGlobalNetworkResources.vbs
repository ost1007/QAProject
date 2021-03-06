'=============================================================================================================
'Description: Function to update rPACS and check Response
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			12/08/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_RecoverPrimaryGlobalNetworkResources
'=============================================================================================================
Public Function fn_TAHITI_RecoverPrimaryGlobalNetworkResources()
		'Variable Declaration
		Dim Message
		
		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		blnResult = clickFrameButton("btnUpdaterPACS")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		Wait 20

		strInnerText = objPage.Frame("frmContent").Object.documentElement.innertext
		If Instr(strInnerText, "Request has been send successfully to rPACS") > 0 Then
			Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has been send successfully to rPACS", "PASS", True)
		Else
			Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has not been send successfully to rPACS", "FAIL", True)
			Environment("Action_Result") = False : Exit FUnction
		End If

		Message = "Successful Response Received from rPACS for Recover Primary Global Network Resources (Cease)"
		blnVerification = False
		For intCounter = 1 To 10
			strText = objPage.Frame("name:=notesFrame").Object.documentElement.innerText
			strInnerHTML = objPage.Frame("name:=notesFrame").Object.documentElement.innerHtml
			If Instr(strText, Message) > 0 Then
				Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message exists</BR>" & strInnerHTML, "PASS", True)
				blnVerification = True 
				Environment("Action_Result") = True : Exit Function
			Else
				Wait 30
				objPage.Link("name:=All", "index:=0").Click
				Wait 5
			End If
		Next

		If Not blnVerification Then
			Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message exists</BR>" & strInnerHTML, "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
End Function