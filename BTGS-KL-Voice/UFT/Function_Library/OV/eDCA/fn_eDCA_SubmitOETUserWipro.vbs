'************************************************************************************************************************************
' Function Name	 :  fn_eDCA_SubmitOETUserWipro
' Purpose	 	 :  Submiting the order to classic
' Author	 	 : Vamshi Krishna G
' Creation Date    : 12/06/2013
' Return values :	Nil
'**************************************************************************************************************************************	
Public function fn_eDCA_SubmitOETUserWipro(dTypeOfOrder)

	'Declaration section
	Dim strTypeOfOrder
	Dim intCounter

	'Assignment of variables
	strTypeOfOrder = dTypeOfOrder

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Clicking on Submit link on left side
	If Instr(UCase(dTypeOfOrder), "MODIFY") = 0 Then
		Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSubmit").Click
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	For intCounter = 1 To 5 Step 1
		If Instr(Ucase(strTypeOfOrder), "PROVIDE") > 0 OR Ucase(strTypeOfOrder) = "MPLSPLUSIA" Then 
			If Ucase(strTypeOfOrder) = "SHAREDACCESSPROVIDE" OR Ucase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE" Then Exit For
			
			For intInnerCounter = 1 To 5
				blnResult = objPage.WebButton("btnValidateTrunkGroupAndTrunkFriendlyName").Exist
					If blnResult Then Exit For '#intInnerCounter 
			Next
			
			If objPage.Webbutton("btnValidateTrunkGroupAndTrunkFriendlyName").Exist(60) Then
				'Click on ValidateTrunkGroupAndTrunkFriendlyName button
				blnResult = clickButton("btnValidateTrunkGroupAndTrunkFriendlyName")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Wait 5					
			End If
			
			Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
			
			For intInnerCounter = 1 To 5 
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync				
			Next
			
			If Not objPage.WebButton("btnUploadPass1DataToClassic").WaitProperty("disabled", False, 30000) Then
				Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
				blnPrevNext = True
			Else
				Exit For
			End If
		End If
	Next
	
	If Not objPage.WebButton("btnUploadPass1DataToClassic").WaitProperty("disabled", False, 3000) Then
		Call ReportLog("Uplaod Pass", "Upload Pass1 Data To Classic button should be enabled", "Upload Pass1 Data To Classic button is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Click on UploadPass1DataToClassic
	blnResult = clickButton("btnUploadPass1DataToClassic")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Call ReportLog("Uplaod Pass", "Upload Pass1 Data To Classic button should be able to click", "Upload Pass1 Data To Classic clicked successfully", "PASS", True)

	'Pop Up message obtained. Click on OK
	If Browser("brweDCAPortal").Dialog("dlgVpnalert").Exist then
		Call ReportLog("Alert Notification In Submit page","Alert Notifiaction #This will take few minutes to,Please click OK to continue uploading# should be retrived","Alert Notifiaction# This will take few minutes to,Please click OK to continue uploading # is retrived","PASS","")
		'Click on OK button
		Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOk").Click
	Else
		Call ReportLog("Alert Notification In Submit Page","Alert Notifiaction# This will take few minutes to,Please click OK to continue uploading #should be retrived","Alert Notifiaction# This will take few minutes to,Please click OK to continue uploading# not retrived","PASS","TRUE")
	End If

	'Capturing the order submission messages
	For intCounter = 0 to 10
		strRetrievedText = objPage.WebElement("webElmOrderSubmissionMessageToClassic").GetROProperty("innertext")
		If Instr(strRetrievedText, "Error in Retriving Order Uploading Status") > 0 Then
			Call ReportLog("OrderSubmissionMessageToClassic","OrderSubmissionMessageToClassic should be populated","OrderSubmissionMessageToClassic is populated with the value - "&strRetrievedText,"FAIL", True)
			Environment("Action_Result") = False : Exit Function
		ElseIf Instr(strRetrievedText, "waiting") > 0 Then
			Wait 60
		ElseIf Instr(strRetrievedText, "Please Click Show Error for error Description") > 0 Then
			Call ReportLog("OrderSubmissionMessageToClassic","OrderSubmissionMessageToClassic should be populated","OrderSubmissionMessageToClassic is populated with the value - " & strRetrievedText,"FAIL", True)
			Environment("Action_Result") = False 
			blnResult = clickLink("lnkSignout")
			Browser("brweDCAPortal").Close
			Exit Function
		ElseIf strRetrievedText <> "" Then
			Call ReportLog("OrderSubmissionMessageToClassic","OrderSubmissionMessageToClassic should be populated","OrderSubmissionMessageToClassic is populated with the value - "&strRetrievedText,"PASS", True)
			Exit For
		Else
			Wait 60
		End If
	Next

	If strRetrievedText = "" Then
		Call ReportLog("OrderSubmissionMessageToClassic","OrderSubmissionMessageToClassic should be populated","OrderSubmissionMessageToClassic is not populated","FAIL","TRUE")	
		blnResult = clickLink("lnkSignout")
		Browser("brweDCAPortal").Close
		Environment("Action_Result") = False
		Exit Function
	End If

	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Signing out from eDCA application
	blnResult = clickLink("lnkSignout")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Closing Browser
	Browser("brweDCAPortal").Close

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
