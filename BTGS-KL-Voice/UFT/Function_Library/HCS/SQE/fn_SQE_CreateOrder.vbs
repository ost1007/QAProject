'****************************************************************************************************************************
' Function Name 		:		fn_SQE_CreateOrder
' Purpose				: 		Function to Create Order
' Author				:		Linta C.K.
' Creation Date  		: 		08/7/2014 
' Return Values	 		:		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_CreateOrder(ByVal OrderName)

	'Declaring of variables
	Dim blnResult, blnProcessing
	Dim strColumn, strConfigured
	Dim arrColumns
	Dim objOrderDetailHeaderTable
	Dim intValidCol, intProductCol, intInnerCounter, intCounter, intInitWaitTime

	'Assigning variables
	blnProcessing = True

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgOfferDetails","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	intInitWaitTime = 10

	'Wait until Processing Tab is there
	For intInnerCounter = 1 to 5
		blnProcessing = objPage.WebElement("innertext:=Processing.*", "index:=0", "visible:=False").Exist(10)
		If blnProcessing Then
			Exit For
		Else
			Wait intInitWaitTime
		End If
	Next

	Set objOrderDetailHeaderTable = objPage.WebTable("tblOrdersHeader")
	
	For intCounter = 1 to 5
		blnResult = objOrderDetailHeaderTable.Exist(60)
		If blnResult Then
			Exit For
		End If
	Next
	
	If Not blnResult Then
		Call ReportLog("tblOrdersHeader", "WebTable should exist", "WebTable doesn't exist/Column names have changed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	intValidCol = 0 : intProductCol = 0
	arrColumns = Split(objOrderDetailHeaderTable.GetROProperty("column names"), ";")
	For intCounter = LBound(arrColumns) to UBound(arrColumns)
		strColumn = arrColumns(intCounter)
		If strColumn =  "Valid" Then
			intValidCol = intCounter + 1
		ElseIf strColumn = "Product" Then
			intProductCol = intCounter + 1
		End If
	Next

	'Check for Configuration Status	
	Set objOrderDetailTable = objPage.WebTable("tblOfferDetails")
	For intCounter = 1 to 20
		strConfigured = objOrderDetailTable.GetCellData(2, intValidCol)	
		If strConfigured = "VALID" Then
			Exit For
		Else
			Wait 10
		End If
	Next
	
	If strConfigured = "VALID" Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
	Else
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as <B>[" & strConfigured & "]</B> after bulk configuration","FAIL", True)
		objBrowser.Close
		Environment("Action_Result") = False : Exit Function
	End If

	'Select Checkbox
	blnResult = setCheckBox("chkListOfOfferItems", "ON")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Create Order
	blnResult = clickLink("lnkCreateOrder")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Enter Order Name
	blnResult = enterText("txtOrderName", OrderName)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Save
	blnResult = clickButton("btnSave")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Check if navigated to Orders Link
	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkOrders").Exist(300)
	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkOrders").WaitProperty("height", micGreaterThan(0), 1000*60*5)
	If blnresult Then
		Call ReportLog("Save Order Details","User should be able to save Order details and navigate to Orders link","User should be navigated to Orders Page","PASS", False)
	Else
		Call ReportLog("Save Order Details","User should be able to save Order details and navigate to Orders link","User is unable to save Order details and unable navigate to Orders page","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If
End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
