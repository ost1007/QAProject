'****************************************************************************************************************************
' Function Name	 : fn_Expedio_SearchCustomer
' Purpose	 	 : Function to select sales channel and search customer
' Author	 	 : Linta
' Creation Date  : 19/08/2014
' Parameters	 :  dTypeOfOrder
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_SearchCustomer(SalesChannel, CustomerName)								
	
	Dim intCounter, intRowCount, iRow
	Dim blnSalesChannelFound 
	Dim strCellData
	Dim oDesc
	Dim objElm
	
	For intCounter = 1 to 5
		blnExist = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Exist(60)
			If blnExist Then Exit For
	Next

	'Setting the Build Reference
	blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check if Sales Channel Exists or not
	If Not objPage.WebEdit("txtSalesChannel").Exist(60) Then
		Call ReportLog("Sales Channel", "Sales Channel field should exist", "Sales Channel field does not exist","FAIL", True)
		Environment.Value("Action_Result")=False : Exit Function
	End If
	
	If objPage.Frame("frmBMCRemedyUserNote").WebElement("elmUseCQMMessage").Exist(60) Then
		objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
		objBrowser.fSync : Wait 5
	End If
	
	If Trim(objPage.WebEdit("txtSalesChannel").GetROProperty("value")) <> SalesChannel Then	
		'Check if Sales Channel Exists or not with DropDown
		If Not objPage.Image("imgMenuforSalesChannel").Exist(60) Then
			Call ReportLog("Sales Channel", "Sales Channel field should exist with Image dropdown", "Sales Channel Dropdown Image is not displayed","FAIL", True)
			Environment.Value("Action_Result")=False : Exit Function
		Else
			objPage.Image("imgMenuforSalesChannel").Object.Click
		End If
		
		With objPage.WebTable("class:=MenuTable")
			If Not .Exist(60) Then
				Call ReportLog("Sales Channel", "On clicking Sales Channel Drop Down list should be populated", "On clicking Sales Channel Drop Down list is not displayed", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			intRowCount = .RowCount
			For iRow = 1 To intRowCount
				strCellData = .GetCellData(iRow, 1)
				If Trim(strCellData) = Trim(SalesChannel) Then
					Set elmSalesChannel = .ChildItem(iRow, 1, "WebElement", 0)
					Set oDesc = Description.Create
					oDesc("micClass").Value = "WebElement"
					oDesc("class").value = "MenuEntryName.*"
					oDesc("innertext").Value = Trim(strCellData)
					Set objElm = objPage.WebTable("class:=MenuTable").childObjects(oDesc)
					If objElm.Count >= 1 Then
						Setting.WebPackage("ReplayType") = 2 'Mouse
						objElm(0).Click
						blnSalesChannelFound = True
						Setting.WebPackage("ReplayType") = 1 'Browser Events
						blnSalesChannelFound = True
						Wait 10
					End If
					Exit For '#iRow
				End If
			Next '#iRow
		End With
		
		If Not blnSalesChannelFound Then
			Call ReportLog("Sales Channel Selection", "<I>" & SalesChannel & "</I> - Sales channel should exist", "<I>" & SalesChannel & "</I> - Sales channel doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Sales Channel Selection", "<I>" & SalesChannel & "</I> - Sales channel should exist", "<I>" & SalesChannel & "</I> - Sales channel exists and is selected", "PASS", False)
		End If
	End If
	'	'Selecting the Sales Channel
	'	blnResult = objPage.WebEdit("txtSalesChannel").Exist(60)
	'	If blnResult Then
	'		blnResult = objPage.Image("imgMenuforSalesChannel").Exist(60)
	'		If blnResult Then
	'				objPage.Image("imgMenuforSalesChannel").Object.click
	'				blnResult = objPage.WebTable("class:=MenuTable").Exist(60)
	'				rowCnt =  objPage.WebTable("class:=MenuTable").RowCount
	'				For strIterator = 1 to rowcnt
	'					strcellData = objPage.WebTable("class:=MenuTable").GetCellData(strIterator,1)
	'					If strcellData = strSalesChannel Then
	'						webElmNumber = strIterator-1
	'						Exit for
	'					End If
	'				Next
	'		
	'				If blnResult Then
	'					Set objDesc = Description.Create
	'					 objDesc("micClass").Value = "WebElement"
	'					 objDesc("class").value = "MenuEntryName.*"
	'					 Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
	'					 If objElm.Count >= 1 Then
	'						 objElm(webElmNumber).FireEvent "onmouseover"
	'						 objElm(webElmNumber).Click
	'					 End If
	'				End If
	'		Else
	'				Call ReportLog("Sales Channel","Sales Channel field should exist","Sales Channel field does not exist","FAIL","TRUE")
	'				Environment.Value("Action_Result")=False
	'				Exit Function
	'		End If
	'	End if
	
	objPage.WebEdit("txtSearchCustomer").Click
	blnResult = enterText("txtSearchCustomer", CustomerName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 2
	objPage.WebEdit("txtSearchCustomer").Click 
	objPage.WebEdit("txtSearchCustomer").HighLight
	Wait 2
	CreateObject("WScript.Shell").SendKeys "{ENTER}"
	Wait 5
	
	For intCounter = 1 To 3
		objBrowser.fSync	
	Next
	
	If objPage.Frame("frmBMCRemedyUserError").WebElement("elmInvalidCustomer").Exist(10) Then
		Call ReportLog("Invalid Customer", CustomerName & " - Customer Name should be valid and existing", "Invalid Customer name", "Fail", True)
		objPage.Frame("frmBMCRemedyUserError").Link("lnkOK").Click
		Call fn_Expedio_Logout()
		Environment("Action_Result") = False : Exit Function
	End If

	'For intCounter = 1 To 5
	'	blnResult = objPage.WebEdit("txtNewCustomerName").WaitProperty("value", CustomerName, 1000*60)
	'	If blnResult Then
	'		Call ReportLog("IPSDK WEB GUI(Search)","Customer should be searched","Customer searched successfully " & CustomerName, "PASS", True)
	'		Environment("Action_Result") = True
	'		Exit For '#intCounter
	'	End If
	'Next '#intCounter
	'
	'If Not blnResult Then
	'	Call ReportLog("IPSDK WEB GUI(Search)","Customer should be searched","Customer search was unsuccessful", "FAIL", True)
	'	Environment("Action_Result") = False : Exit Function
	'End If

End Function
