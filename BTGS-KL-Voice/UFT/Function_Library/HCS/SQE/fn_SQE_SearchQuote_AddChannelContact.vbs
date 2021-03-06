'=================================================================================================================================
' Description	: Function to Fill Details and Create Quote
' History		:		Name		Date		Version
' Created By	: 	Nagaraj V	29/04/2015		v1.0
' Example	: fn_SQE_CreateQuote "OCC_CONTRACT", "Provide", "12", "GBP", "QT_BCM"
'=================================================================================================================================
Public Function fn_SQE_SearchQuote_AddChannelContact(ByVal QuoteID, ByVal ChannelContactEIN, ByVal DistributorRoles)
	'Variable Declaration
	Dim arrEIN, arrRoles
	Dim intInitWait, iWaitCntr, intServiceUnavailableCounter
	Dim elmQuoteID
	Dim oDesc
	Dim strPhoneNumber
	Dim blnServiceUnavailableEncountered
	
	'Addition of Channel Contact
	arrEIN = Split(ChannelContactEIN, "|")
	arrRoles = Split(DistributorRoles, "|")
	blnServiceUnavailableEncountered = False
	intServiceUnavailableCounter = 0
	Set oDesc = Description.Create
	
	If UBound(arrEIN) <> UBound(arrRoles) Then
		Call ReportLog("Channel Contacts", "Channel Contacts and Roles should match", "EIN has <B>" & UBound(arrEIN) + 1 & "</B></BR>	whereas </BR><B>" & UBound(arrRoles) & "</B> entries", "FAIL", False)
		Environment("Action_Result") = False
		Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwCustomerQuoteManagement","pgCustomerQuoteManagement","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickWebElement("elmViewQuote")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	intInitWait = 30
	For iWaitCntr = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(intInitWait) Then
			intInitWait = 10
			Wait 10
		Else
			Exit For '#iWaitCntr
		End If	
	Next '#iWaitCntr
	
	'Search for Quote ID and click on it
	Set elmQuoteID = objPage.WebElement("html tag:=DIV","innertext:=" & Trim(QuoteID), "visible:=True", "index:=0")
	If elmQuoteID.Exist(60) Then
		elmQuoteID.Click
	Else
		Call ReportLog("Search Quote ID", "<B>" & QuoteID & "</B> should be visible under view quote", "<B>" & QuoteID & "</B> is not visible under view quote", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	intInitWait = 10
	For iWaitCntr = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(intInitWait) Then
			intInitWait = 5
			Wait 10
		Else
			Exit For '#iWaitCntr
		End If	
	Next '#iWaitCntr
	
	blnResult = objPage.WebEdit("txtQuoteRefID").Exist(120)
	If Not blnResult Then
		Call ReportLog("Quote Ref ID WebEdit", "Quote Ref ID should be displayed on clicking Quote ID", "Quote Ref ID is not displayed on clicking Quote ID", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		blnResult = objPage.WebEdit("txtQuoteRefID").WaitProperty("value", Trim(QuoteID), 1000*60*2)
		If Not blnResult Then
			strActualQuoteID = objPage.WebEdit("txtQuoteRefID").GetROProperty("value")
			Call ReportLog("Quote Ref ID WebEdit", "Quote Ref ID should be populated with " & QuoteID, "Quote Ref ID is populated with " & strActualQuoteID, "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	strPhoneNumber = RandomNumber(6600000, 6699999)	
	
	For iCnt = LBound(arrEIN) To UBound(arrEIN)
			'Enter EIN
			blnResult = enterText("txtEIN", Trim(arrEIN(iCnt)))
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			'Click on Search Directory
			blnResult = clickButton("btnSearchBTDirectory")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			blnResult = objPage.WebElement("elmBTDirectoryGrid").Exist(60)
			If Not blnResult Then
				Call ReportLog("Search EIN", "On Search of EIN Directory Grid should be populated", "Directory Grid is not populated", "FAIL", True)
				Environment("Action_Result") = False : Exit For
			Else
				oDesc("micclass").Value = "WebElement"
				'oDesc("html tag").Value = "DIV"
				oDesc("innertext").Value = Trim(arrEIN(iCnt))
				
				For iEINCounter = 1 To 15
					objPage.WebElement("elmBTDirectoryGrid").RefreshObject
					Set oEINResult = objPage.WebElement("elmBTDirectoryGrid").ChildObjects(oDesc)
					If oEINResult.Count >= 1 Then
						Exit For '#iEINCounter
					Else
						Wait 5
					End If
				Next '#iEINCounter
				
				If oEINResult.Count = 0 Then
					Call ReportLog("Search EIN", "On Search of EIN Directory Grid should be populated", "Directory Grid is not populated with " & Trim(arrEIN(iCnt)), "FAIL", True)
					Environment("Action_Result") = False : Exit For
				Else
					oEINResult(0).Click
					Wait 5
				End If
			End If
	
			If objPage.WebEdit("txtPhoneNumber").GetROProperty("value") = "" Then
				blnResult = enterText("txtPhoneNumber", strPhoneNumber)
					If Not blnResult Then Environment("Action_Result") = False : Exit For
			End If
			
			'Select Distributor Role
			blnResult = selectValueFromPageList("lstDistributorRole", Trim(arrRoles(iCnt)))
				If Not blnResult Then Environment("Action_Result") = False : Exit For
			
			blnResult = objPage.WebButton("btnChannelContactSave").WaitProperty("disabled", 0, 1000*60*2)
			If Not blnResult Then
				Call ReportLog("Save Channel Contact", "On filling all details Save Butotn should be enabled", "Save button is disabled", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			Else
				blnResult = clickButton("btnChannelContactSave")
					If Not blnResult Then Environment("Action_Result") = False : Exit For
			End If
			
			If objPage.WebElement("elmMsgChannelContacts").Exist(120) Then
				strRetrivedText = objPage.WebElement("elmMsgChannelContacts").GetROProperty("innertext")
				Call ReportLog("Channel Contact", "On Clicking Save button, Message should appear stating contact has been created", strRetrivedText, "Pass", False)
				objPage.WebButton("btnOkay").Click : Wait 2
				intServiceUnavailableCounter = 0
			ElseIf objPage.WebElement("elmMsgServiceUnavailable").Exist(10) And intServiceUnavailableCounter <= 3 Then
				objPage.WebButton("btnOkay").Click : Wait 2
				blnResult = clickButton("btnReset")
					If Not blnResult Then Environment("Action_Result") = False : Exit For
				intServiceUnavailableCounter = intServiceUnavailableCounter + 1
				iCnt = iCnt - 1
				Wait 5
			ElseIf objPage.WebElement("elmMsgServiceUnavailable").Exist(10) Then
				Call ReportLog("Channel Contact", "On Clicking Save button, Message should appear stating contact has been created", "Service is Unavailable even after retry of 3times", "FAIL", True)
				Environment("Action_Result") = False : Exit For
			Else
				Call ReportLog("Channel Contact", "On Clicking Save button, Message should appear stating contact has been created", "Message did not appear", "FAIL", True)
				Environment("Action_Result") = False : Exit For
			End If
	Next '#iCnt
	
	objBrowser.Close
End Function
