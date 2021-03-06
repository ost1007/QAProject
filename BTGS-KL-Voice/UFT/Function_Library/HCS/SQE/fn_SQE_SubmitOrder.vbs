'****************************************************************************************************************************
' Function Name 		:		fn_SQE_SubmitOrder
' Purpose				: 		Function to Submit Order
' Author				:		Linta C.K || 08/7/2014
' Modified History		:		Nagaraj V || 09-Sep-2015 || Modification to Code and New OR implementation
' Return Values	 		: 		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_SubmitOrder()

	'Declaring of variables
	Dim intCounter, intloopCounter
	Dim blnDisabled, blnSubmit
	Dim strRetrievedText, strStatus, strMessage
      
	'Assigning variables
	On Error Resume Next

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 20
		blnDisabled = objPage.Link("lnkSubmitOrder").Object.isDisabled
		If blnDisabled Then
			Wait 5
		Else
			Exit For
		End If
	Next '#intCounter
	
	If blnDisabled Then
		Call ReportLog("Submit Order", "Sumbit Order should be enabled for Submission", "Submit Order is disabled", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = clickLink("lnkSubmitOrder")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function


	blnResult = objPage.WebElement("elmSubmissionMsg").Exist
	If blnResult Then
		strRetrievedText = GetWebElementText("elmSubmissionMsg")
		Call ReportLog("Initiating Submit Order","Message - 'initiating Submit Order' should exist.", strRetrievedText,"PASS", True)
	End If

	For intCounter = 1 to 10
		If objPage.Image("image type:=Plain Image", "file name:=spinning\.gif").Exist Then
			Wait 30
		Else
			Exit For
		End If
	Next

	If Not objPage.Link("lnkSubmitOrder").Object.disabled Then
		If objPage.Image("image type:=Plain Image", "file name:=spinning\.gif").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
			objPage.Image("image type:=Plain Image", "file name:=spinning\.gif").WaitProperty "height", 0, 1000*60*2
		End If
	End If

	If Not blnResult Then
		Call ReportLog("Order Succesful Submission Message","Order Succesful Submission Message should exist","Order Succesful Submission Message is not displayed after a long waiting period also.","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 to 20
		objPage.WebTable("tblOrders").RefreshObject
		Wait 2
		strStatus = UCase(Trim(objPage.WebTable("tblOrders").GetCellData(2,3)))
		If strStatus = "SUBMITTED" Then
			Call ReportLog("Order Status","Order Status should be 'Submitted'.","Order Status is displayed as 'Submitted'.","PASS", True)
			blnSubmit = True
			Exit For '#intCounter
		ElseIf strStatus = "FAILED" Then
			Call ReportLog("Order Status","Order Status should be 'Submitted'.","Order Status is displayed as 'Failed'.","FAIL", True)
			Environment("Action_Result") = False
			Exit For
		Else
			blnSubmit = False
			Wait 10
		End If
	Next '#intCounter

	If Not blnSubmit Then
		Call ReportLog("Order Status","Order Status should be 'Submitted'.","Order Status is displayed not as 'Submitted', instead - " & strStatus,"FAIL","True")
		Environment.Value("Action_Result") = False
	Else
		Environment.Value("Action_Result") = True
	End If
	Browser("brwSalesQuoteEngine").Close

End Function


'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
