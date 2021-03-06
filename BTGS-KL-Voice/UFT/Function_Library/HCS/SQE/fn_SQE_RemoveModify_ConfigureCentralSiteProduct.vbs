Public Function fn_SQE_RemoveModify_ConfigureCentralSiteProduct(ByVal ProductOffering)

	'Variable Declaration
	Dim strConfigured, strCellData, strPricing, strProduct
	Dim objElmBaseConfig
	Dim arrColumnNames
	Dim intCounter, intInitWaitTime, intConfiguredCol, intProductCol, intPricingStatusCol
	Dim oDescElmDelete

	'Variable Assignment
	Set oDescElmDelete = Description.Create

	'Check whether the table has been populated or not
	For intCounter = 1 to 5
		blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").Exist(30)
		If blnResult Then
			If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").GetROProperty("height") > 0 Then Exit For
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Table is not loaded still","FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	
	
	If Not objPage.WebTable("tblProductTableHeader").Exist(60) Then
		Call ReportLog("tblProductTableHeader", "tblProductTableHeader should be displayed", "tblProductTableHeader is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Get Column Index
	arrColumnNames = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	intProductCol = 0 : intConfiguredCol = 0
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Configured" Then
			intConfiguredCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Product" Then
			intProductCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Pricing Status" Then
			intPricingStatusCol = intCounter + 1
		End If
	Next
	
	If Not objPage.WebTable("tblProductLineItems").Exist(60) Then
		Call ReportLog("tblProductLineItems", "tblProductLineItems should be displayed", "tblProductTableHeader is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	intProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
	If intProdRow <= 0 Then
		Call ReportLog("Product Line Items Table", "Product Line Items table should be populated with <B>" & ProductOffering & "</B>", "Product Line Items table is not populated with <B>" & ProductOffering & "</B>", "FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 To 50
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intConfiguredCol)
		If strConfigured = "" Then
			Wait 5
		ElseIf strConfigured = "VALID" OR  strConfigured = "INVALID" Then
			blnResult = True
			Exit For
		End If
	Next

	'Check for Configuration Status
	If blnResult Then
		iRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductOffering)
		strPricing = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iRow,intPricingStatusCol))
		strConfigured = Trim(objPage.WebTable("tblProductLineItems").GetCellData(iRow,intConfiguredCol))

		If strConfigured = "VALID" And strPricing = "Firm" And Instr(ProductOffering, "Internet Service Access") > 0 Then
			Call ReportLog("Pre Configure Status for " & ProductOffering, "Configuration Status: Valid" & "</BR>Pricing Status: Firm", "Configuration Status: " & strConfigured & "</BR>Pricing Status: " & strPricing,"PASS", True)
		Else
			Call ReportLog("Pre Configure Status for " & ProductOffering, "Configuration Status: Valid" & "</BR>Pricing Status: Firm", "Configuration Status: " & strConfigured & "</BR>Pricing Status: " & strPricing,"FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Select Checkbox
	objPage.WebTable("tblProductLineItems").ChildItem(iRow, 1, "WebCheckBox", 0).Set "ON"

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False  : Exit Function
	End If
	
	'Wait for Page to be Navigated to Bulk Configuration
	For intCounter = 1 To 5 Step 1
		If objBrowser.Page("pgBulkConfiguration").Exist Then Exit For
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

	If objPage.WebButton("name:=DetailsHide Details", "height:=25").Exist Then
		objPage.WebButton("name:=Cancel", "height:=25").Click
		Wait 5
	End If

	'Click on Base Config
	Set objElmBaseConfig = objPage.WebElement("class:=label ng-scope ng-binding.*","innertext:=Base Configuration", "index:=0")
	If objElmBaseConfig.Exist(10) Then
		Call ReportLog("Bulk Configuration", "Page should be navigated to Bulk Configuration", "Successfully navigated", "Information", False)
		objElmBaseConfig.Click
	Else
		Call ReportLog("Bulk Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Check whether Base Configuration table is visible or not
	Set objtblBaseConfig = objPage.WebTable("class:=bulkGUI","index:=0")
	If Not objtblBaseConfig.Exist Then
		Call ReportLog("Bulk Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Check for Bulk Selection CheckBox
	Set objchkBulk = Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").WebCheckBox("chkSelectAll")
	If Not objchkBulk.Exist(60) Then
		Call ReportLog("Bulk Configuration", "Bulk Selection CheckBox should exist", "Bulk Selection Checkbox doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		objchkBulk.Set "ON" : Wait 3
	End If

	'Click on Delete Asset
	blnResult = clickButton("btnDeleteAsset")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	Wait 10

	'Check for Number of outstanding saves Status
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Performing deleting.*", "visible:=True", "index:=0").Exist(5) Then
			Wait 3
		Else
			Exit For
		End If
	Next

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
	objPage.WebElement("elmQuoteDetails").Click

	Wait 10

	'Wait for the Page to be Navigated
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Exist(60) Then Exit For
	Next
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function
	
	'Check Whether Configured and Pricing Status are Populated or not
	blnConfiguredPopulated = False
	For intCounter = 1 to 20
		strConfigured = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intConfiguredCol))
		If strConfigured = "VALID" Or strConfigured = "INVALID"Then
			blnConfiguredPopulated = True : Exit For
		Else
			Wait 5
		End If
	Next

	blnPricingPupulated = False
	For intCounter = 1 to 20
		strPricing = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intPricingStatusCol))
		If strPricing <> "" Then
			blnPricingPupulated = True : Exit For
		Else
			Wait 5
		End If
	Next

	strProduct = objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intProductCol)
	If Instr(strProduct, "Internet Service Access") > 0 Then
			If strConfigured = "VALID" And strPricing = "N/A" Then
				Call ReportLog(strProduct, "Pricing Status should be <B>N/A</B></BR>Configured Status should be <B>VALID</B>",_
					"Pricing Status should be <B>" & strPricing & "</B></BR>Configured Status should be <B>" & strConfigured & "</B>", "PASS", True)
			Else
				Call ReportLog(strProduct, "Pricing Status should be <B>N/A</B></BR>Configured Status should be <B>VALID</B>",_
					"Pricing Status should be <B>" & strPricing & "</B></BR>Configured Status should be <B>" & strConfigured & "</B>", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
	Else
		Call ReportLog(strProduct, "New product encountered", "New Product encountered", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
		 objPage.WebCheckBox("html id:=selectAll").Set "ON"
		 Environment("Action_Result") = True
	Else
		Environment.Value("Action_Result") = False : Exit Function
	End If

End Function
