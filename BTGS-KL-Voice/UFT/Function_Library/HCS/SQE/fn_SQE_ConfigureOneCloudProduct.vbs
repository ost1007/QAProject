'=============================================================================================================
'Description: Function to Configure One Cloud Product
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			30/09/2014 	v1.0
'Example: fn_SQE_ConfigureOneCouldProduct(dRFOFilePath, dCustNwSetID, dInternalTrunkRef)
'=============================================================================================================
'Public Function fn_SQE_ConfigureOneCloudProduct(ByVal dSiteName)
Public Function fn_SQE_ConfigureOneCloudProduct(ByVal dSiteName, ByVal dBIBOAttr, ByVal dProductNames, ByVal dProductQuantity, ByVal dSiteNumberRangeLineService)

 	'Check whether the table has been populated or not
	For intCounter = 1 to 5
		blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").Exist
		If blnResult Then
			If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").GetROProperty("height") > 0 Then Exit For
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Configure Product","Should be navigated to Showing Quote Option page","Configuration Table is not loaded still","FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then	Environment.Value("Action_Result") = False : Exit Function

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
	
	intProdRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText("One Cloud Cisco - Site")
	If intProdRow <= 0 Then
		Call ReportLog("Showing Quote Option", ProductOffering & " - should be visible under Line Items Table", ProductOffering & " - line item is not populated in Line Items table", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 To 30
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
		strConfigured = objPage.WebTable("tblProductLineItems").GetCellData(intProdRow,intConfiguredCol)
		If strConfigured = "INVALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as <B>INVALID</B> before bulk configuration.","Configuration Status is shown as <B>" & strConfigured & "</B> before bulk configuration","PASS", True)
		Else
			Call ReportLog("Configure Product","Configuration Status should be shown as 'INVALID' before bulk configuration.","Configuration Status is shown as <B>" & strConfigured & "</B> before bulk configuration","FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Select Checkbox
	objPage.WebTable("tblProductLineItems").ChildItem(intProdRow, 1, "WebCheckBox", 0).Set "ON"

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
	
	Setting.WebPackage("ReplayType") = 2 '# Changes to Mouse mode
	
	'Click on Base Config
	Set objElmBaseConfig = objPage.WebElement("class:=label ng-scope ng-binding.*","innertext:=Base Configuration", "index:=0")
	If objElmBaseConfig.Exist(10) Then
		objElmBaseConfig.Click
	Else
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If

	'Check if Base Config Table is present or not
	If Not objPage.WebTable("tblBaseConfig").Exist(10) Then
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If

'	arrColumnNames = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")

	iRow = objPage.WebTable("tblBaseConfig").GetRowWithCellText(UCase(dSiteName))
	If iRow <= 0 Then
		Call ReportLog("Check Site Name", "Base Config Table should contain Site Name", "Base Config Table doesn't contains [" & dSiteName & "] site name", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Select BIBO
	Call fn_SelectBulkConfigTableFieldValues(iRow, dBIBOAttr, "Break In Break Out Mode")
	If Not Environment.Value("Action_Result") Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Exit Function
	End If

	blnResult = clickWebElement("elmLineService-OCC")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False
		Exit Function
	End If
	
	intInitWaitTime = 15
	'Wait Number of outstanding saves is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=.*Number of outstanding saves.*", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
		End If
	Next
	
	Set oDesc = Description.Create
	oDesc("micclass").value = "WebElement"
	oDesc("innertext").Value = "Configure"
	oDesc("html tag").Value = "A"
	
	Set elmConfigure = objPage.WebTable("tblBaseConfig").ChildObjects(oDesc)
	If elmConfigure.Count <= 0 Then
		Call ReportLog("Configure Link", "Configure Link shold be visible", "Configure Link is not visible", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False
		Exit Function
	Else
		elmConfigure(0).Click
	End If

	Wait 10
	
	If Not objPage.WebList("Link2New").Exist(120) Then
		Call ReportLog("Link2New", "Link2New should be visible on click of Configure Link", "Link2New should is not visible on click of Configure Link", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False
		Exit Function
	Else
		blnResult = objPage.WebList("Link2New").WaitProperty("items count", micGreaterThan(1), 1000*60*5)
		If Not blnResult Then
			Call ReportLog("Link2new", "Items should be populated", "Items are not populated", "FAIL", True)
			Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
			Environment.Value("Action_Result") = False
			Exit Function
		End If
	End If
	
	arrLineServices = Split(dProductNames, "|")
	arrQuantity = Split(dProductQuantity, "|")
	
	If UBound(arrLineServices) <> UBound(arrQuantity) Then
		Call ReportLog("Check Data", "ProductName and Quantity count should match", "ProductName and Quantity count doesn't match. Revisit Data Setup", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False
	End If
	
	Set oDict = CreateObject("Scripting.Dictionary")
	For index = LBound(arrLineServices) TO UBound(arrLineServices)
		strLineService = Trim(arrLineServices(index))
		oDict.Add strLineService, Trim(arrQuantity(index))
	
		blnResult = SelectValueFromPageList("Link2New", Trim(strLineService))
		If Not blnResult Then
			Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
			Environment.Value("Action_Result") = False
			Exit Function
		End If
		
		Wait 1
		blnResult = clickButton("btnAdd")
		If Not blnResult Then
			Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
			Environment.Value("Action_Result") = False
			Exit Function
		End If
		Wait 1
	Next '#strRate
		
	blnResult = clickButton("btnOk")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment.Value("Action_Result") = False
		Exit Function
	End If
	
	Wait 5
	
	intInitWaitTime = 15
	'Wait Number of outstanding saves is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=.*Loading Grid*", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
		End If
	Next
	
	Set elmBaseConfig = objPage.WebElement("elmLineService-OCC").WebElement("elmBaseConfiguration")
	If Not elmBaseConfig.Exist(60) Then
		Call ReportLog("Base Config", "Base Configuration under Line service OCC should exist", "Base Configuration under Line Service OCC doesn't exist", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	Else
		elmBaseConfig.Click
	End If

	arrColumnNames = Split(objPage.WebTable("tblBaseConfig").GetROProperty("column names"), ";")
	intQuantity = 0 : intStencil = 0
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Quantity" Then
			intQuantity = intCounter + 1
		ElseIf Instr(arrColumnNames(intCounter), "Stencil") > 0 Then
			intStencil = intCounter + 1
		End If
	Next '#intCounter
	
	If intQuantity = 0 OR intStencil = 0 Then
		Call ReportLog("Base Config Table", "Table doesn't contain Quantity/Stencil", "Table doesn't contain Quantity/Stencil", "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	CreateObject("WScript.Shell").SendKeys "^{HOME}"
	
	intRows = objPage.WebTable("tblBaseConfig").RowCount
	For iRow = 2 To intRows
		intColumns = objPage.WebTable("tblBaseConfig").ColumnCount(iRow)
		If intColumns > 1 Then
			Set lstStencil = objPage.WebTable("tblBaseConfig").ChildItem(iRow, intStencil, "WebList", 0)
			strStencil = lstStencil.GetROProperty("selection")
			Call fn_SetBulkConfigTableFieldValues(iRow, oDict.Item(strStencil), "Quantity")
			If Not Environment.Value("Action_Result") Then
				Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
				Exit Function
			End If
		End If
	Next

	Call ReportLog("SnapIt", "Stencil Quantity should be entered", "Stencil Quantity is entered", "Information", True)
	
	blnResult = clickWebElement("elmModifyBaseConfiguration")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
	intInitWaitTime = 15
	'Wait Number of outstanding saves is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=.*Number of outstanding saves.*", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
		End If
	Next
	
	'Click Quote Details Link Present on Right Top
	objPage.WebElement("elmQuoteDetails").Click

	'Wait for the Page to be Navigated
	For intCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Exist(60) Then Exit For
	Next

	blnResult = BuildWebReference("brwSalesQuoteEngine", "pgShowingQuoteOption", "")
	If Not blnResult Then
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If

	index = -1
	arrColumns = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	For intCounter = 0 to UBound(arrColumns)
		If arrColumns(intCounter) = "Configured" Then
			index = intCounter + 1
			Exit For
		End If
	Next
	
	If index = -1 Then
		Call ReportLog("Get Configured Column Index", "Should be able to Fetch Configured Column index using Table Header", "Unable to Get the index - check for Object Prop", "FAIL", False)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	Wait 10
	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist(30)
	If blnResult Then
	 	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	 	Wait 5
	Else
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Click on Calculate Button
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnValid = False
	For intCounter = 1 to 20
		strCellData = objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, index)
		If strCellData = "VALID" Then
			blnValid = True
			Exit For
		Else
			Wait 10
		End If
	Next

	If blnValid Then
		Call ReportLog("Configure Product", "Product should be Configured after calculating Pricing", "Product is Configured and Status is <B>" & strCellData & "</B>", "PASS", True)
		Environment("Action_Result") = True
	Else
		Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done & configuration is found to be: " & strCellData, "FAIL", True)
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False
	End If
	
	blnPriced = False	
	For intCounter = 1 to 20
		objPage.WebTable("tblProductLineItems").RefreshObject
		blnResult = objPage.WebTable("tblProductLineItems").Exist(30)
		If blnResult Then
			strPricing = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intProdRow, intPricingStatusCol))
			If strPricing = "Firm" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","PASS", True)
				blnPriced = True
				Exit For
			ElseIf strPricing = "ERROR" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL",True)
				Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
				Environment("Action_Result") = False : Exit Function
			ElseIf strPricing = "" Then
				Wait 20
			End If
		Else
			Wait 5
		End If
	Next '#intCounter
	
	Setting.WebPackage("ReplayType") = 1 '# Changes to Event Mode
	If Not blnPriced Then
		Call ReportLog("Pricing Product","Pricing should be shown as <B>'N/A'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL","True")
		Setting.WebPackage("ReplayType") = 1 '# Changes to Event mode
		Environment("Action_Result") = False : Exit Function
	End If
	
	
End Function


Sub RegexSelectDOM(Object, sPattern)
    Dim oRegExp, oOptions, ix

    'Create RegExp Object
    Set oRegExp = New RegExp
    oRegExp.IgnoreCase = False
    oRegExp.Pattern = sPattern

    'DOM options
    Set oOptions = Object.Object.Options

    For ix = 0 to oOptions.Length - 1
        'If RegExp pattern matches list item, we're done!
        If oRegExp.Test(oOptions(ix).Text) Then
            oOptions(ix).selected = true
            Set oRegExp = Nothing
            Exit Sub
        End If
    Next
End Sub
