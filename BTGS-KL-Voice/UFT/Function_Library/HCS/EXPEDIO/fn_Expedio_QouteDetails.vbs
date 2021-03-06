'****************************************************************************************************************************
' Function Name	 : fn_Expedio_QouteDetails
' Purpose	 	 : Function to login to EXPEDIO Application.
' Author	 	 : Linta
' Creation Date  : 19/08/2014
' Modified			: Nagaraj V || 16/3/2015
' Parameters	 :  dQuoteName,dOrderType,dOppurtunityReferenceNumber, dContractTerm, dCurrency
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_QouteDetails(dQuoteName, dOrderType, dOppurtunityReferenceNumber, dContractTerm, dCurrency)

	'Variable Declaration
	Dim strQuoteName, strOrderType, strOppurtunityReferenceNumber, strContractTerm, strCurrency

	'Assigning local variables with function parameters
	strQuoteName = dQuoteName
	strOrderType = dOrderType
	strOppurtunityReferenceNumber = dOppurtunityReferenceNumber
	strContractTerm = dContractTerm
	strCurrency = dCurrency

	blnExist = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Exist(120)
	blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Quote Details Link
	blnResult = clickLink("lnkQuoteDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	
	For intCounter = 1 To 10
		If objPage.WebEdit("txtQuoteName").Exist(30) Then Exit For
	Next

	'Enter Quote Name
	blnResult =enterText("txtQuoteName", strQuoteName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	blnResult = objPage.WebEdit("txtOrderType").Exist(60)
	If blnResult Then
            blnResult = objPage.Image("imgMenuforOrderType").Exist(60)
            If blnResult Then
			Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Image("imgMenuforOrderType").Object.click
			rowCnt = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebTable("tblDropDown").RowCount
			For strIterator = 1 to rowcnt
				strcellData = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebTable("tblDropDown").GetCellData(strIterator,1)
				If strcellData = strOrderType Then
					webElmNumber = strIterator-1
					Exit for
				End If
			Next
			
			blnResult = objPage.WebTable("class:=MenuTable").Exist(60)
			If blnResult Then
				Set objDesc = Description.Create
				objDesc("micClass").Value = "WebElement"
				objDesc("class").value = "MenuEntryName.*"
				Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
				If objElm.Count >= 1 Then
					objElm(webElmNumber).FireEvent "onmouseover"
					objElm(webElmNumber).Click
				End If
			End If
		Else
			Call ReportLog("Order Type","Order Type field should exist","Order Type field does not exist","FAIL","TRUE")
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	Else
		Call ReportLog("Order Type","Order Type field should exist","Order Type field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 
		Exit Function
	End if

	'Selecting the Contract Term
	Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Sync
	blnResult = objPage.WebEdit("txtContractTerm").Exist(60)
	If blnResult Then
		blnResult = objPage.Image("imgMenuforContractTerm").Exist(60)
		If blnResult Then
			Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Image("imgMenuforContractTerm").Object.click

			blnResult = objPage.WebTable("class:=MenuTable").Exist(60)
			rowCnt =Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebTable("tblDropDown").RowCount

			For strIterator = 1 to rowcnt
				strcellData = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebTable("tblDropDown").GetCellData(strIterator,1)
				If strcellData = strContractTerm Then
					webElmNumber = strIterator-1
					Exit for
				End If
			Next
			
			blnResult = objPage.WebTable("class:=MenuTable").Exist(60)
			If blnResult Then
				Set objDesc = Description.Create
				objDesc("micClass").Value = "WebElement"
				objDesc("class").value = "MenuEntryName.*"
				Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
				If objElm.Count >= 1 Then
					 objElm(webElmNumber).FireEvent "onmouseover"
					 objElm(webElmNumber).Click
				End If
			End If
		Else
			Call ReportLog("Contract Term","Contract Term field should exist","Contract Term  field does not exist","FAIL","TRUE")
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	Else
		Call ReportLog("Contract Term","Contract Term field should exist","Contract Term  field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 
		Exit Function
	End if

	'Selecting the Currency
	Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Sync
	
	blnResult = objPage.WebEdit("txtCurrency").Exist(60)
	If blnResult Then
		blnResult = objPage.Image("imgMenuforCurrency").Exist(60)
		If blnResult Then
			Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Image("imgMenuforCurrency").Object.click
			
			rowCnt = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebTable("tblDropDown").RowCount
			For strIterator = 1 to rowcnt
				strcellData = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebTable("tblDropDown").GetCellData(strIterator,1)
				If strcellData = strCurrency Then
					webElmNumber = strIterator-1
					Exit for
				End If
			Next
			
			blnResult = objPage.WebTable("class:=MenuTable").Exist(60)
			If blnResult Then
				Set objDesc = Description.Create
				objDesc("micClass").Value = "WebElement"
				objDesc("class").value = "MenuEntryName.*"
				Set objElm = objPage.WebTable("tblDropDown").childObjects(objDesc)
				If objElm.Count >= 1 Then
					objElm(webElmNumber).FireEvent "onmouseover"
					objElm(webElmNumber).Click
					End If
				End If
			Else
				Call ReportLog("Contract Term","Contract Term field should exist","Contract Term  field does not exist","FAIL","TRUE")
				Environment.Value("Action_Result")=False
				Exit Function
		End If
	Else
		Call ReportLog("Contract Term","Contract Term field should exist","Contract Term  field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Exit Function
	End if

	'Enter Oppurtunity Reference Number
	blnResult =enterText("txtoppurtunityreferencenumber", strOppurtunityReferenceNumber)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on "Save Button
	blnResult = clickLink("lnkSave")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	For intcounter = 1 to 12
		blnResult = ObjPage.Link("lnkOK").Exist(60)
		If Not blnResult Then
			Wait 5
		 Else
		 	Call ReportLog("Create Quote", "Capture Quote Creation Details", "Capture Quote Creation Details", "Information", True)
			blnResult = clickLink("lnkOK")
			If Not blnResult Then                                                           
				Environment.Value("Action_Result") = False : Exit Function
			Else
				Exit For
			End If
		End If
	Next
	 
	On Error Resume Next
		If Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebButton("btnCloseRight").Exist(10) Then
			Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").WebButton("btnCloseRight").Click
		End If
	On Error Goto 0

End Function
