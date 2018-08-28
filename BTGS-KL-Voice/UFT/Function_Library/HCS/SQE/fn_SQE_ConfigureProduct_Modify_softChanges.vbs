'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ConfigureProduct_ModifySoftChanges
' Purpose				: 		Function to configure Products added to the Quote
' Author				:		 Nagaraj V
' Creation Date  		 : 		  26/08/2015
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_ConfigureProduct_ModifySoftChanges1(ByVal ActualConfigureProduct,ByVal Quantity, ByVal ServiceType, ByVal GroupingLevel, ByVal ActivityLevel)

	'Declaring of variables
	Dim intQuantity, intInitWaitTime, intCounter
	Dim strConfigured, strConfigureProduct 
	Dim blnValid

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	'Check for Configuration Status
	blnResult = objPage.WebTable("webTblItems").Exist
	If blnResult Then
		strConfigured = objPage.WebTable("webTblItems").GetCellData(2,12)
		If strConfigured = "VALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID' before bulk configuration","PASS","False")
		Else
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as '" & strConfigured & "' before bulk configuration","FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult Then
		objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Call ReportLog("Select All", "Select All checkbox should be visible", "Select All checkbox is visible", "FAIL", True)
		Environment.Value("Action_Result") = False  : Exit Function
	End If

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

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
	
	objPage.WebElement("innertext:=Configure", "index:=1").HighLight
	objPage.WebElement("innertext:=Configure", "index:=1").Click
	
	Wait 20

	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''QTP 11.0 Workaround'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	'Set abc = createobject("Wscript.Shell")
	'Wait 5
	'abc.SendKeys "{TAB},8"
	'abc.SendKeys "{TAB},8"
	'Wait 5
	'abc.SendKeys "{DOWN},8"
	'Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebButton("btnAdd").Click
	'Wait 3
	'If objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Exist(5) Then
		'objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Click
	'End If
	
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

	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Wait 5
	'Anil Code
	'Set objElmBaseConfigSoftChange = Description.Create
	'objElmBaseConfigSoftChange("micclass").Value = "WebElement"
	'objElmBaseConfigSoftChange("class").Value = "label ng-scope ng-binding unselected"
	'objElmBaseConfigSoftChange("innertext").Value = "Base Configuration"
	'
	'Set elmBaseConfig = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").ChildObjects(objElmBaseConfigSoftChange)
	'elmBaseConfig(16).Click

	Set objElmBaseConfigSoftChange = Description.Create
	objElmBaseConfigSoftChange("micclass").Value = "WebElement"
	objElmBaseConfigSoftChange("class").Value = "label ng-scope ng-binding unselected"
	objElmBaseConfigSoftChange("innertext").Value = "Base Configuration"
	
	'Selecting Base Config Under Soft Change-Site Move and Change-Site Soft Change Or Move and Change-Site Soft Change
	Set elmBaseConfig = objPage.WebElement("class:=accordion-group ng-scope","outertext:=.*Move and Change-Site Soft Change.*").ChildObjects(objElmBaseConfigSoftChange)																									
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
	
	iRow = objPage.WebTable("webTblBaseConfigQty1").GetRowWithCellText("Not Priced")
	With objPage.WebTable("webTblBaseConfigQty1")
		'Enter the Quantity
		strQuantity = CStr(.GetCellData(iRow, 6))
		If strQuantity <> Cstr(Quantity) Then
			For iKeyCounter = 1 To Len(strQuantity)
				.ChildItem(iRow, 6, "WebElement", 0).Click
				CreateObject("WScript.Shell").SendKeys "{DELETE}" : Wait 1
			Next '#iKeyCounter
			
			.ChildItem(iRow, 6, "WebElement", 0).Click : Wait 2
			CreateObject("Mercury.DeviceReplay").SendString Quantity : Wait 2
			CreateObject("WScript.Shell").SendKeys "{TAB}" : Wait 2
		End If
		
		'Enter the Service Type
		.ChildItem(iRow, 7, "WebElement", 0).Click
		Wait 2
		.ChildItem(iRow, 7, "WebList", 0).Select ServiceType
		Wait 2
		.ChildItem(iRow, 7, "WebElement", 0).Click
		Wait 2
		
		'Select the Grouping Level
		.ChildItem(iRow, 8, "WebElement", 0).Click : Wait 2
		.ChildItem(iRow, 8, "WebList", 0).Click : Wait 2
		.ChildItem(iRow, 8, "WebElement", 0).Click : Wait 2
		.ChildItem(iRow, 8, "WebList", 0).Select GroupingLevel : Wait 2
		.ChildItem(iRow, 8, "WebElement", 0).Click : Wait 2
		
		'Select the Activity Level
		.ChildItem(iRow, 9, "WebElement", 0).Click : Wait 2
		.ChildItem(iRow, 9, "WebList", 0).Click : Wait 2
		.ChildItem(iRow, 9, "WebElement", 0).Click : Wait 2
		.ChildItem(iRow, 9, "WebList", 0).Select ActivityLevel : Wait 2
		.ChildItem(iRow, 9, "WebElement", 0).Click : Wait 2
	End With
	

	Set oWebElement = description.Create
	oWebElement("micclass").value = "WebElement"
	oWebElement("innertext").value = "Soft Change-Site.*"
	
	Set oWebElmChild = Browser("brwShowingAddProduct").Page("pgShowingAddProduct").ChildObjects(oWebElement)
	oWebElmChild(5).Click

	Wait 10

	'Select Checkbox
	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty1").RefreshObject
	Set oWebElmChild = 	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty1").ChildItem(1,1,"WebCheckBox",0)
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
			strConfigured = Trim(objPage.WebTable("webTblItems").GetCellData(iProdRow ,12))
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
	
	For intCounter = 1 to 20
		objPage.WebTable("webTblItems").RefreshObject
		blnResult = objPage.WebTable("webTblItems").Exist
		If blnResult Then
           		iProdRow = objPage.WebTable("webTblItems").GetRowWithCellText("One Cloud Cisco - Site")
			strPricing = Trim(objPage.WebTable("webTblItems").GetCellData(iProdRow ,10))
			If strPricing = "Firm" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","PASS", True)
				Exit For
			ElseIf strConfigured = "ERROR" Then
				Call ReportLog("Pricing Product","Pricing should be shown as <B>'Firm'</B> after bulk configuration.","Pricing is shown as " & strPricing & " after bulk configuration","FAIL","True")
				Environment("Action_Result") = False : Exit Function
			End If
		Else
			Wait 5
		End If
	Next '#intCounter
	
	

 End Function

 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
