'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ConfigureProduct
' Purpose			: 		Function to configure Products added to the Quote
' Author				:		Anil
' Creation Date  		: 		07/7/2014
' Modified History		:		Nagaraj V || 11-Sep-2015 || Refinement of Function
' Return Values	 	: 		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_ConfigureProduct_Cease(ByVal ProductOffering)

	'Declaring of variables
	Dim intCounter, intProductCol, intConfiguredCol, intPricingCol, intOrderTypeCol, intRow, intInitWaitTime
	Dim strConfigured, strOrderType, strFirm, strPricingStatus
	Dim blnConfiguredPopulated, blnFirm
	Dim arrColumnNames
	Dim objElmBaseConfig
	Dim oDescElmDelete
	
	'Check whether the table has been populated or not
	With Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption")
		For intCounter = 1 to 5
			blnResult = .WebTable("tblProductLineItems").Exist
			If blnResult Then
				If .WebTable("tblProductLineItems").GetROProperty("height") > 0 Then Exit For
			ElseIf .WebElement("elmErrLoadingLineItems").Exist(5) Then
				If .WebElement("elmErrLoadingLineItems").GetROProperty("height") > 0 Then
					Call ReportLog("Configure Product","Product Line item should be displayed", .WebElement("elmErrLoadingLineItems").Object.innerText ,"Warnings", True)
					If intCounter = 5 Then Environment("Action_Result") = False : Exit Function	
				Else
					Browser("brwSalesQuoteEngine").Object.Refresh
					Wait 5
					Browser("brwSalesQuoteEngine").Sync
				End If
			End If
		Next
	End With
	
	If Not blnResult Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Table is not loaded still","FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	
	If Not objPage.WebTable("tblProductTableHeader").Exist(60) Then
		Call ReportLog("Product Header", "Table Line Item table should exist", "Table line items header doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function	
	End If
	
	
	'Get Column Index
	arrColumnNames = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	intProductCol = 0 : intConfiguredCol = 0 : intPricingCol = 0 : intOrderTypeCol = 0
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Configured" Then
			intConfiguredCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Pricing Status" Then
			intPricingCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Order Type" Then
			intOrderTypeCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Product" Then
			intProductCol = intCounter + 1
		End If
	Next
	
	If Not objPage.WebTable("tblProductLineItems").Exist(60) Then
		Call ReportLog("Product LineItems", "ProductLineItems table should exist", "Product LineItems header doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		intRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
	End If
	
	'Wait until Configured Status is Populated
	For intCounter = 1 To 30
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intRow, intConfiguredCol)
		If strConfigured = "" Then
			Wait 5
		ElseIf strConfigured = "VALID" OR  strConfigured = "INVALID" Then
			blnResult = True
			Exit For
		End If
	Next
	
	'Wait until Pricing Status is Populated
	For intCounter = 1 To 30
		strPricingStatus = objPage.WebTable("tblProductLineItems").GetCellData(intRow, intPricingCol)
		If strPricingStatus = "" Then
			Wait 5
		Else
			blnResult = True
			Exit For
		End If
	Next
	
	'Check Whether Product Table is populated with Product Offering or not
	intRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
	If intRow <=0 Then
		Call ReportLog("Product Line Item", "<B>" & ProductOffering & "</B> should be populated in Line Item table", "<B>" & ProductOffering & "</B> should be not populated in Line Item table", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check for Configuration Status
	If blnResult Then
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intRow,intConfiguredCol)
		If strConfigured = "VALID" And strPricingStatus = "Firm" And ( ProductOffering = "One Cloud Cisco" OR ProductOffering = "One Cloud Cisco - Site" )Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID'</BR>Pricing Status should be 'Firm' before bulk configuration","PASS", True)
		Else
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as <B>" & strConfigured & "</B></BR> Pricing Status is shown as <B>" & strPricingStatus & "</B> before bulk configuration","FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	'Select Checkbox
	objPage.WebTable("tblProductLineItems").ChildItem(intRow, 1, "WebCheckBox", 0).Set "ON"

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	'Wait for Page to be Navigated to Bulk Configuration
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").Exist Then Exit For
	Next
	
	'Build Web Reference
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgBulkConfiguration","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	intInitWaitTime = 90
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
		End If
	Next
	
	'Wait until Loaded 1 of 12 offerings status is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ offerings", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
		Else
			Exit For
		End If
	Next
	
	'Click on Base Config
	Set objElmBaseConfig = objPage.WebElement("class:=label ng-scope ng-binding.*","innertext:=Base Configuration", "index:=0")
	If objElmBaseConfig.Exist(10) Then
		objElmBaseConfig.Click
	Else
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check if Base Config Table is present or not
	If Not objPage.WebTable("tblBaseConfig").Exist(10) Then
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Select all the Items under Base Configduration
	blnResult = setCheckBox("chkSelectAll", "ON")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	If objPage.WebButton("btnDeleteAsset").WaitProperty("disabled", 0, 1000*60) Then
		blnResult = clickbutton("btnDeleteAsset")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Delete Asset", "Delete Asset button should be enabled on selecting all items", "Delete Asset button is disabled", "FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	Wait 10

	'Check for Number of outstanding saves Status
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Performing deleting.*", "visible:=True", "index:=0").Exist(5) Then
			Wait 3
		Else
			Exit For
		End If
	Next
	
	'Check if there is any dependecy Error Message
	If objPage.WebElement("elmAssetDependecyError").Exist(0) Then
		If objPage.WebElement("elmAssetDependecyError").GetROProperty("height") > 0 Then
			Call ReportLog("Asset Dependency", "Warning Message encountered", GetWebElementText("elmAssetDependecyError"), "FAIL", True)
			objBrowser.CloseAllTabs
			Environment("Action_Result") = False : Exit Function				
		End If
	End If
	
	Set oDescElmDelete = Description.Create
	'Create Description for Delete Object
	oDescElmDelete("micclass").Value = "WebElement"
	oDescElmDelete("class").Value = "ng-binding"
	oDescElmDelete("innertext").Value = "Delete"
	
	Set objElmDelete = objPage.WebTable("class:=bulkGUI","index:=0").ChildObjects(oDescElmDelete)
	If objElmDelete.Count >= 1 Then
		Call ReportLog("Delete Asset", "Delete Asset Operation should be successful", "Delete Operation was successful", "PASS", True)
	Else
		Call ReportLog("Delete Asset", "Delete Asset Operation should be successful", "Delete Operation was unsuccessful", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Click Quote Details Link Present on Right Top
	blnResult = clickWebElement("elmQuoteDetails")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Wait 10

	'Wait for the Page to be Navigated
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Exist Then Exit For
	Next
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	
	'Check Whether Configured and Pricing Status are Populated or not
	blnConfiguredPopulated = False
	For intCounter = 1 to 30
		strConfigured = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intRow, intConfiguredCol))
		If strConfigured = "VALID" Or strConfigured = "INVALID"Then
			blnConfiguredPopulated = True : Exit For
		Else
			Wait 5
		End If
	Next
	
	'Check whether Pricing Status is populated or not
	blnFirm = False
	For intCounter = 1 to 30
		strPricingStatus = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intRow, intPricingCol))
		If strPricingStatus = "N/A" OR (strPricingStatus = "Firm" AND ProductOffering = "One Cloud Cisco")Then
			blnFirm = True : Exit For
		Else
			Wait 5
		End If
	Next
	
	'Check for the Product Configuration and Pricing
	strProduct = objPage.WebTable("tblProductLineItems").GetCellData(intRow, intProductCol)
	If Instr(strProduct, ProductOffering) > 0 AND ( ProductOffering = "One Cloud Cisco" OR ProductOffering = "One Cloud Cisco - Site")  Then
			If strConfigured = "VALID" And strPricingStatus = "N/A" Then
				Call ReportLog(strProduct, "Pricing Status should be <B>N/A</B></BR>Configured Status should be <B>VALID</B>",_
					"Pricing Status should be <B>" & strPricingStatus & "</B></BR>Configured Status should be <B>" & strConfigured & "</B>", "PASS", True)
			
			Rem Not sure on this - R47
			ElseIf strConfigured = "VALID" And strPricingStatus = "Firm" AND ProductOffering = "One Cloud Cisco" Then
				Call ReportLog(strProduct, "Pricing Status should be <B>Firm</B></BR>Configured Status should be <B>VALID</B>",_
					"Pricing Status should be <B>" & strPricingStatus & "</B></BR>Configured Status should be <B>" & strConfigured & "</B>", "PASS", True)
			Else
				Call ReportLog(strProduct, "Pricing Status should be <B>N/A</B></BR>Configured Status should be <B>VALID</B>",_
					"Pricing Status should be <B>" & strPricingStatus & "</B></BR>Configured Status should be <B>" & strConfigured & "</B>", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
	Else
		Call ReportLog("Bulk Configuration", "New product encountered", "New Product encountered - <B>" & strProduct & "</B>", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	strOrderType = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intRow, intOrderTypeCol))
	If strOrderType = "Cease" Then
		Call ReportLog("Validate Order Type", "Order Type should get changed to Cease", "Order Type is changed to <B>" & strOrderType & "</B>", "PASS", True)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Validate Order Type", "Order Type should get changed to Cease", "Order Type is changed to <B>" & strOrderType & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	End If

	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
		 objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Environment.Value("Action_Result") = False : Exit Function
	End If
 End Function

 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
