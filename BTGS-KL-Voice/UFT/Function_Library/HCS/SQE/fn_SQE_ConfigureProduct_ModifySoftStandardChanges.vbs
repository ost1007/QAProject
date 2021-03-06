'***************************************************************************************************************************************************************************************************************************
' Function Name 		:		fn_SQE_ConfigureProduct_ModifySoftChanges
' Purpose				: 		Function to configure Products added to the Quote
' Author				:		 Nagaraj V
' Creation Date  		 : 		  26/08/2015
' Return Values	 	: 			Not Applicable
'***************************************************************************************************************************************************************************************************************************
Public Function fn_SQE_ConfigureProduct_ModifySoftStandardChanges(ByVal ActualConfigureProduct,ByVal Quantity, ByVal ServiceType, ByVal GroupingLevel, ByVal ActivityLevel)

	'Declaring of variables
	Dim intQuantity, intInitWaitTime, intCounter
	Dim strConfigured, strConfigureProduct 
	Dim blnValid, blnPriced
	Dim intConfiguredCol, intPricingCol, intOrderTypeCol, intProductCol
	Dim arrColumnNames

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False  : Exit Function
		
	
	If Not objPage.WebTable("tblProductTableHeader").Exist(120) Then
		Call ReportLog("tblProductTableHeader", "Product Table Header should exist", "Product Table Header columns might be changed", "FAIL", True)
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

	'Check for Configuration Status
	blnResult = objPage.WebTable("webTblItems").Exist(120)
	If blnResult Then
		intProdRow = objPage.WebTable("webTblItems").GetRowWithCellText("One Cloud Cisco - Site")
		For intCounter = 1 To 10 Step 1
			strConfigured = objPage.WebTable("webTblItems").GetCellData(intProdRow, intConfiguredCol)
			If strConfigured = "VALID" Then
				Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID' before bulk configuration","PASS", True)
				Exit For '#intCounter
			ElseIf strConfigured = "" Then
				Wait 20
			End If
		Next
	Else
		Call ReportLog("webTblItems", "Line Items table should exist", "Line Items table doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If strConfigured <> "VALID" Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as '" & strConfigured & "' before bulk configuration","FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult Then
		objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Call ReportLog("Select All", "Select All checkbox should be visible", "Select All checkbox is visible", "FAIL", True)
		Environment.Value("Action_Result") = False  : Exit Function
	End If

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist(60)
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then Environment("Action_Result") = False  : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	Wait 60

	'Check if navigated to Bulk Configuration Page
	blnResult = objPage.WebElement("webElmBulkConfiguration").WaitProperty("visible", "True", 10000*6*3)
	If blnResult Then
		Call ReportLog("Navigation","Should be navigated to Bulk configuration page","Navigated to Bulk Configuration page after clicking on Configure Product link","PASS","False")
	Else		
		Call ReportLog("Navigation","Should be navigated to Bulk configuration page","Navigated to Bulk Configuration page was unsuccessful","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If

	intInitWaitTime = 10
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
	
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	oDesc("class").value = "label ng-scope ng-binding.*"
	oDesc("innertext").value = ActualConfigureProduct
	Set oCol = objPage.ChildObjects(oDesc)
	
	'Select the Actual Product that needs to be modified
	For intProductCounter = 0 to oCol.Count-1
		strConfigureProduct = oCol(intProductCounter).GetROProperty("innertext")
		If strConfigureProduct = ActualConfigureProduct Then
			oCol(intProductCounter).Click
			Exit For
		End If
	Next
	
	For intCounter = 1 to 10
		If objPage.WebElement("innertext:=Configure", "index:=1").Exist Then
			Exit For
		End If
	Next
	
	'Click on Configure Link
	objPage.WebElement("innertext:=Configure", "index:=1").Click
	
	If Not objPage.WebList("lstLinktoNew").Exist(60) Then
		Call ReportLog("lstLinktoNew", "WebList should exist", "WebList doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End if
	
	If Not objPage.WebList("lstLinktoNew").WaitProperty("items count", micGreaterThanOrEqual(1), 1000*60*2) Then
		Call ReportLog("lstLinktoNew", "WebList should be populated with Items", "WebList is not populated with Items for selection", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Select the Item to be Configured
	blnResult = selectValueFromPageList("lstLinktoNew", ActualConfigureProduct)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Click on Add Button
	blnResult = clickButton("btnAdd")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	If objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Exist(5) Then
		objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Click
	End If
	
	'Wait until Number of outstanding saves is disappeared
	For intCounter = 1 To 10 Step 1
		blnResult = objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10)
		If blnResult Then
			Wait 15
		Else
			Exit For
		End If
	Next '#intCounter
	
	For intOuterCounter = 1 To 2
		Set oWebElement = description.Create
		oWebElement("micclass").value = "WebElement"
		oWebElement("class").value = "accordion-toggle ng-binding"
		oWebElement("innertext").value = ".*" & ActualConfigureProduct & ".*"
			
		Set oWebElmChild = objPage.ChildObjects(oWebElement)
		If Not oWebElmChild.Count >=1 Then
			Call ReportLog(ActualConfigureProduct, ActualConfigureProduct & " toggle element should be present", ActualConfigureProduct & " toggle is not present", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		oWebElmChild(0).Click
		Wait 5
		
		Set objElmBaseConfigSoftChange = Description.Create
		objElmBaseConfigSoftChange("micclass").Value = "WebElement"
		objElmBaseConfigSoftChange("class").Value = "label ng-scope ng-binding unselected"
		objElmBaseConfigSoftChange("innertext").Value = "Base Configuration"
		
		'Selecting Base Config Under Soft Change-Site Move and Change-Site Soft Change Or Move and Change-Site Soft Change
		If ActualConfigureProduct = "Standard Change-Site" Then
			Set elmBaseConfig = objPage.WebElement("class:=accordion-group ng-scope","outertext:=.*Move and Change-Site Standard Change.*", "index:=0").ChildObjects(objElmBaseConfigSoftChange)
		Else
			Set elmBaseConfig = objPage.WebElement("class:=accordion-group ng-scope","outertext:=.*Move and Change-Site Soft Change.*", "index:=0").ChildObjects(objElmBaseConfigSoftChange)
		End If
		
		If elmBaseConfig.Count = 0 Then
			Call ReportLog(ActualConfigureProduct, ActualConfigureProduct & " should be configured", ActualConfigureProduct & " - unable to configure", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		'Set elmBaseConfig = objPage.WebElement("class:=accordion-group ng-scope","outertext:=.*Move and Change-Site Soft Change.*|.*Move and Change-Site Standard Change.*").ChildObjects(objElmBaseConfigSoftChange)
		elmBaseConfig(0).Click
		Wait 5
		
		'Wait until Number of outstanding saves is disappeared
		For intCounter = 1 To 10 Step 1
			blnResult = objPage.WebElement("innertext:=Loading Grid.*", "index:=0").Exist(10)
			If blnResult Then
				Wait 15
			Else
				Exit For
			End If
		Next '#intCounter
		
		
		If Not objPage.WebTable("tblBaseConfigStandardSoftChange").Exist(60) Then
			Call ReportLog("tblBaseConfigStandardSoftChange", "WebTable should exist", "WebTable doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		intQuantity = -1 : intServiceType = -1 :intGroupingLevel = -1 :intActivityLevel = -1
		
		iRow = objPage.WebTable("tblBaseConfigStandardSoftChange").GetRowWithCellText("Not Priced")
		
		'Enter Quantity
		Call fn_SetBulkConfigTableFieldValues(iRow, Quantity, "Quantity")
			If Not Environment("Action_Result") Then Exit Function
		
		'Select Service Type
		Call fn_SelectBulkConfigTableFieldValues(iRow, ServiceType , "Service Type")
			If Not Environment("Action_Result") Then Exit Function
		
		If Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").WebElement("elmError").Exist(60) Then
			If intCounter = 2 Then
				Call ReportLog("Error Popup", "Encountered Error", "Encountered error to Re-Sync", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			Call ReportLog("Error Popup", "Encountered Error", "Encountered error to Re-Sync.  Retrying again", "Information", True)
			Browser("brwSalesQuoteEngine").Page("pgBulkConfiguration").WebElement("elmError").WebButton("btnOk").Click
			
			For intSyncCounter = 1 To 10
				Browser("brwSalesQuoteEngine").fSync
			Next '#intSyncCounter
			
			objPage.RefreshObject
			For intCounter = 1 To 5
				If objPage.WebElement("html tag:=SPAN","innertext:= Soft Change-Site ", "index:=0").Exist(60) Then
					intInitWaitTime = 30
					'Wait until Loaded 0 of 1 assets status is not visible
					For intLoadCounter = 1 to 50
						If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(intInitWaitTime) Then	
							Wait 5
							intInitWaitTime = 3
						Else
							Exit For '#intLoadCounter
						End If
					Next '#intLoadCounter
					Exit For '#intCounter
				End If	
			Next
		Else
			Exit For '#intCounter
		End If
	Next
	
	'Select Grouping Level
	Call fn_SelectBulkConfigTableFieldValues(iRow, ActivityLevel , "Activity Level")
		If Not Environment("Action_Result") Then Exit Function
	
	
	
	'	With objPage.WebTable("tblBaseConfigStandardSoftChange")
	'		'Get Column Names
	'		arrColumnNames = Split(.GetROProperty("column names"), ";")
	'		For iCnt = 0 To UBound(arrColumnNames)
	'			If Instr(arrColumnNames(iCnt), "Quantity") > 0 Then
	'				intQuantity = iCnt + 1
	'			ElseIf Instr(arrColumnNames(iCnt), "Service Type") > 0 Then
	'				intServiceType = iCnt + 1
	'			ElseIf Instr(arrColumnNames(iCnt), "Grouping Level") > 0 Then
	'				intGroupingLevel = iCnt + 1
	'			ElseIf Instr(arrColumnNames(iCnt), "Activity Level") > 0 Then
	'				intActivityLevel = iCnt + 1
	'			End If
	'		Next
	'		
	'		If intQuantity = -1 OR intServiceType = -1 OR intGroupingLevel = -1 OR intActivityLevel = -1 Then
	'			Call ReportLog("Base Config Table", "Column names under Base Config Table of Standard/Soft Change has been changed", "Contact Automation Team", "FAIL", True)
	'			Environment("Action_Result") = False : Exit Function
	'		End If
	'	
	'		'Enter the Quantity
	'		strQuantity = CStr(.GetCellData(iRow, 6))
	'		If strQuantity <> Cstr(Quantity) Then
	'			For iKeyCounter = 1 To Len(strQuantity)
	'				.ChildItem(iRow, intQuantity, "WebElement", 0).Click
	'				CreateObject("WScript.Shell").SendKeys "{DELETE}" : Wait 1
	'			Next '#iKeyCounter
	'			
	'			.ChildItem(iRow, intQuantity, "WebElement", 0).Click : Wait 2
	'			CreateObject("Mercury.DeviceReplay").SendString Quantity : Wait 2
	'			CreateObject("WScript.Shell").SendKeys "{TAB}" : Wait 2
	'		End If
	'		
	'		'Enter the Service Type
	'		.ChildItem(iRow, intServiceType, "WebElement", 0).Click : Wait 2
	'		.ChildItem(iRow, intServiceType, "WebList", 0).Select ServiceType : Wait 2
	'		.ChildItem(iRow, intServiceType, "WebElement", 0).Click : Wait 2
	'		
	'		'Select the Grouping Level
	'		.ChildItem(iRow, intGroupingLevel, "WebElement", 0).Click : Wait 2
	'		.ChildItem(iRow, intGroupingLevel, "WebList", 0).Click : Wait 2
	'		.ChildItem(iRow, intGroupingLevel, "WebElement", 0).Click : Wait 2
	'		.ChildItem(iRow, intGroupingLevel, "WebList", 0).Select GroupingLevel : Wait 2
	'		.ChildItem(iRow, intGroupingLevel, "WebElement", 0).Click : Wait 2
	'		
	'		'Select the Activity Level
	'		.ChildItem(iRow, intActivityLevel, "WebElement", 0).Click : Wait 2
	'		.ChildItem(iRow, intActivityLevel, "WebList", 0).Click : Wait 2
	'		.ChildItem(iRow, intActivityLevel, "WebElement", 0).Click : Wait 2
	'		.ChildItem(iRow, intActivityLevel, "WebList", 0).Select ActivityLevel : Wait 2
	'		.ChildItem(iRow, intActivityLevel, "WebElement", 0).Click : Wait 2
	'	End With
	

	Set oWebElement = description.Create
	oWebElement("micclass").value = "WebElement"
	oWebElement("innertext").value = ActualConfigureProduct & ".*"
	
	Set oWebElmChild = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").ChildObjects(oWebElement)
	oWebElmChild(5).Click

	Wait 10

	'Select Checkbox
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("tblBaseConfigStandardSoftChange").RefreshObject
	Set oWebElmChild = 	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("tblBaseConfigStandardSoftChange").ChildItem(1,1,"WebCheckBox",0)
	oWebElmChild.Click

	blnResult = objPage.WebElement("webElmQuoteDetails").Exist
	If blnResult Then
		blnResult = clickWebElement("webElmQuoteDetails")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Exit Function
		End If
	End If
	objPage.Sync
	Wait 5
	
	'Wait until Number of outstanding saves is disappeared
	For intCounter = 1 To 10 Step 1
		blnResult = objPage.WebElement("innertext:=Number of outstanding saves.*", "index:=0").Exist(10)
		If blnResult Then
			Wait 15
		Else
			Exit For
		End If
	Next '#intCounter

	blnValid = False
	objPage.WebTable("webTblItems").RefreshObject
	For intCounter = 1 to 20
		objPage.WebTable("webTblItems").RefreshObject
		blnResult = objPage.WebTable("webTblItems").Exist
		If blnResult = "True" Then
           		iProdRow = objPage.WebTable("webTblItems").GetRowWithCellText("One Cloud Cisco - Site")
			strConfigured = Trim(objPage.WebTable("webTblItems").GetCellData(iProdRow, intConfiguredCol))
			If strConfigured = "VALID" Then
				Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
				blnValid = True
				Exit For
			End If
		Else
			Wait 5
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Configure Product Status Check","WebTable should exist with Product Details.","WebTable does not exist with Product Details","FAIL","True")
		Environment.Value("Action_Result") = False   : Exit Function
	End If

	If Not blnValid Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration","PASS","False")
		Environment("Action_Result") = False
		Exit Function
	End If

	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
		 objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
	
	'============================ Perform Pricing ===============================	
	'Build Web Reference
	blnResult = BuildWebReference("brwSQE","pgSQE","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
	 	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Click on Calculate Button
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnPriced = False	
	For intCounter = 1 to 20
		objPage.WebTable("webTblItems").RefreshObject
		blnResult = objPage.WebTable("webTblItems").Exist
		If blnResult Then
           		iProdRow = objPage.WebTable("webTblItems").GetRowWithCellText("One Cloud Cisco - Site")
			strPricing = Trim(objPage.WebTable("webTblItems").GetCellData(iProdRow, intPricingCol))
			If strPricing = "Firm" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","PASS", True)
				blnPriced = True
				Exit For
			ElseIf strPricing = "ERROR" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL",True)
				Environment("Action_Result") = False : Exit Function
			ElseIf strPricing = "" Then
				Wait 20
			End If
		Else
			Wait 5
		End If
	Next '#intCounter
	
	If Not blnPriced Then
		Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Check for Configured Status
	strConfigured = objPage.WebTable("webTblItems").GetCellData(iProdRow, intConfiguredCol)
	If strConfigured = "VALID" Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID' before bulk configuration","PASS","False")
	Else
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as '" & strConfigured & "' before bulk configuration","FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
	 	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Environment("Action_Result") = False : Exit Function
	End If

 End Function

 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
