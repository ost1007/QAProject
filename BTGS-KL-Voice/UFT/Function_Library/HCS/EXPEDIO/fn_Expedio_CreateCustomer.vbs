'*******************************************************************************************************************************************************************************
' Description	 : Function to Create Customer
' History	 	 : 		Author		Date	Changes Implemented
' Created By	 : 	Nagaraj V	29/06/2015	NA
' Parameters	 : 	SalesChannel, CustomerName
' Return Values	 : Not Applicable
'*******************************************************************************************************************************************************************************
Public Function fn_Expedio_CreateCustomer(ByVal SalesChannel, ByVal CustomerName)

	Dim strFriendlyName, strNote
	Dim intCounter

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	If Not objPage.WebEdit("txtNewCustSalesChannel").Exist(60) Then
		Call ReportLog("Sales Channel", "Sales Channel Field should exist", "Sales channel field doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If objPage.Frame("frmBMCRemedyUserNote").WebElement("elmUseCQMMessage").Exist(60) Then
		objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
		objBrowser.fSync : Wait 5
	End If
	
	If Trim(objPage.WebEdit("txtNewCustSalesChannel").GetROProperty("value")) <> SalesChannel Then
		'Enter Sales Channel Name under New Customer
		objPage.WebEdit("txtNewCustSalesChannel").Click : Wait 1
		objPage.Image("alt:=Menu for Sales Channel", "index:=1").Object.Click
		'blnResult = enterText("txtNewCustSalesChannel", SalesChannel)
		blnResult = fn_Expedio_SelectValueFromDropDown(objPage, SalesChannel, objPage.WebEdit("txtNewCustSalesChannel"))
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	End If
	
	'Enter Customer Name
	If objPage.WebEdit("txtNewCustomerName").Exist(0) Then
		objPage.WebEdit("txtNewCustomerName").Set CustomerName
		If Not objPage.WebEdit("txtNewCustomerName").WaitProperty("value", CustomerName, 10000) Then
			Call ReportLog("txtNewCustomerName", "Value should be set as <B>" & CustomerName & " </B>", "Value couldn't be set", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("txtNewCustomerName", "Value should be set as <B>" & CustomerName & " </B>", "Value is set successfully", "PASS", False)
		End If
	Else
		Call ReportLog("txtNewCustomerName", "TextBox Should Exist", "Text doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Click on Create Customer Link
    blnResult = clickLink("lnkCreateCustomer")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Check whether the frame is loaded or not
	
	For intCounter = 1 To 6 Step 1
		If Browser("brwAssociateCustomer").Page("pgAssociateCustomer").Frame("frmBMRemedyNote").Exist(60) Then
			Exit For			
		End If
	Next
	
	If Not Browser("brwAssociateCustomer").Page("pgAssociateCustomer").Frame("frmBMRemedyNote").Exist(0) Then
		Call ReportLog("Associate Customer", "Associate Customer Page should be displayed", "Is Displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'If Not Browser("brwAssociateCustomer").Page("pgAssociateCustomer").Frame("frmBMRemedyNote").WaitProperty("height", micGreaterThan(0), 60000) Then
	'	Call ReportLog("Associate Customer", "Associate Customer Page should be displayed", "Is Displayed", "FAIL", True)
	'	Environment("Action_Result") = False : Exit Function
	'End If

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwAssociateCustomer","pgAssociateCustomer","frmBMRemedyNote")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Verify whether customer exists or not
	If objFrame.WebElement("elmNote").Exist Then
		strNote = objFrame.WebElement("elmNote").GetROProperty("innertext")
		If Instr(strNote, "No relevant customers found in BFG") > 0 Then
			Call ReportLog("Pop Up", "Customer should be available in BFG", strNote, "PASS", True)
			blnResult = clickFrameLink("lnkOK")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Else
			Call ReportLog("Pop Up", "Customer should not be available in BFG", strNote, "FAIL", True)
			Environment.Value("Action_Result")=False : Exit Function
		End If
	End If

	'Click on Create Customer
	blnResult = clickLink("lnkCreateCustomer")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Wait Until we get Customer Creation Note
	Set oElmCustCreationNote = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Frame("frmBMCRemedyUserNote").WebElement("elmCustomerCreationNote")
	blnResult = oElmCustCreationNote.WaitProperty("height", micGreaterThan(0), 1000*60*15)
	If Not blnResult Then
		oElmCustCreationNote.WaitProperty "height", micGreaterThan(0), 1000*60*15
		oElmCustCreationNote.RefreshObject
		If oElmCustCreationNote.Exist Then
			blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","frmBMCRemedyUserNote")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Call ReportLog("Customer Creation", "Customer Creation Note should appear", oElmCustCreationNote.GetROProperty("innertext"), "PASS", True)
		Else
			Call ReportLog("Customer Creation", "Customer Creation Note should appear", "Customer Creation Note is not displayed", "FAIL", True)
			Environment.Value("Action_Result")=False : Exit Function
		End If
	Else
		blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","frmBMCRemedyUserNote")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Call ReportLog("Customer Creation", "Customer Creation Note should appear", oElmCustCreationNote.GetROProperty("innertext"), "PASS", True)
	End If

	'Click on Ok Link in Pop Up
	blnResult = clickFrameLink("lnkOK")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	strFriendlyName = objPage.WebEdit("txtFriendlyContractName").GetROProperty("value")
	Call ReportLog("Capture Friendly Name", "Capture Contract Friendly Name", "Contract Friendly Name is <B>" & strFriendlyName & "</B>", "PASS", True)

End Function
