'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ConfigureProduct_Modify_StandardChanges
' Purpose			: 		Function to configure Products added to the Quote
' Author				:		 Anil Pal
' Modified By			:	Nagaraj V || 26/08/2015 || Removed/corrected LOC
' Return Values	 	: 	Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_ConfigureProduct_Modify_StandardChanges(ByVal ActualConfigureProduct,ByVal Quantity, ByVal ServiceType, ByVal GroupingLevel, ByVal ActivityLevel)

	'Declaring of variables
	Dim intQuantity
	Dim intConfiguredCol, intProductCol, intPricingStatusCol
	Dim arrColumnNames
	Dim strProduct

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
		If Not blnResult Then  Environment.Value("Action_Result") = False : Exit Function

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then  Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	objBrowser.Sync
	objPage.Sync

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

	'Build Web Reference
	blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False 	
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
	
	'Selection of Standard Changes Product
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	oDesc("class").value = "label ng-scope ng-binding.*"
	oDesc("innertext").value = ActualConfigureProduct

	Set oCol = objPage.ChildObjects(oDesc)
	For intCounter = 1 to oCol.Count-1
		strConfigureProduct = oCol(intCounter).GetROProperty("innertext")
		If strConfigureProduct = ActualConfigureProduct Then
			oCol(intCounter).Click
			Wait 2
			Exit For
		End If
	Next

	''Click on Configure Link
	Set oWebElement = description.Create
	oWebElement("micclass").value = "WebElement"
	oWebElement("innerhtml").value = "Configure"
	Set oWebElmChild = objPage.ChildObjects(oWebElement)
	oWebElmChild(0).Click
	
	For intCounter = 1 to 5
		blnResult = objPage.WebList("lstLinktoNew").Exist
		If blnResult Then
			If objPage.WebList("lstLinktoNew").GetROProperty("items count")>0 then 
				Exit For
			Else
				Wait(2)
			End If
		End If
	Next

	'Select the Item to be Configured
	blnResult = selectValueFromPageList("lstLinktoNew", ActualConfigureProduct)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	If objPage.WebButton("name:=Ok", "index:=0", "class:=action-ok btn-mini", "height:=25").Exist(5) Then
		objPage.WebButton("name:=Ok", "index:=0", "class:=action-ok btn-mini", "height:=25").Highlight
		objPage.WebButton("name:=Ok", "index:=0", "class:=action-ok btn-mini", "height:=25").Click
	End If
	
	If objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Exist(5) Then
		objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Highlight
		objPage.WebButton("name:=Ok", "index:=1", "class:=action-ok btn-mini", "height:=25").Click
	End If
	Wait 3
	
	For intCounter = 1 to 3
		blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").Exist(10)
		If Not blnResult Then
			Exit For
		End If
	Next

	'Code to Click on Base Config under Standard Change-Site --> Move and Change-Site Standard Change
	Set oWebElement = description.Create
	oWebElement("micclass").value = "WebElement"
	oWebElement("innertext").value = ActualConfigureProduct
	Set oWebElmChild = 	objPage.ChildObjects(oWebElement)
	oWebElmChild(5).Click

	Wait(10)

	Set oDescBaseConfig = Description.Create
	oDescBaseConfig("micclass").Value = "WebElement"
	oDescBaseConfig("class").Value = "label ng-scope ng-binding (unselected|selected)"
	oDescBaseConfig("innerhtml").Value = "Base Configuration"

	Set oElmBaseConfig =objPage.WebElement("class:=accordion-group ng-scope","innertext:=Standard Change-Site Base Configuration.*").ChildObjects(oDescBaseConfig)
	oElmBaseConfig(1).Click
	Wait 3

'	If objPage.WebTable("webTblBaseConfigQty").Exist(10) Then	
'			strRowCnt = objPage.WebTable("webTblBaseConfigQty").RowCount
'			Set oWebElmChild = 	objPage.WebTable("webTblBaseConfigQty").ChildItem(2,6,"WebElement",0)
'
'			'Delete Existing quantity if its not matching
'			intPrevQuantity = Trim(oWebElmChild.GetROProperty("innertext"))
'			If CStr(intPrevQuantity) <> CStr(strQuantity) Then
'				intQuantityLen = Len(intPrevQuantity)
'				For iDelCounter = 1 To intQuantityLen
'					oWebElmChild.Click
'					CreateObject("WScript.Shell").SendKeys "{DELETE}"
'					Wait 1
'				Next
'
'				Set OdeviceReplay = CreateObject("Mercury.DeviceReplay")
'				OdeviceReplay.SendString strQuantity
'				Wait 1
'			End If
'			
'			Set oWebElmChild = 	objPage.WebTable("webTblBaseConfigQty").ChildItem(2,7,"WebElement",0)
'			oWebElmChild.Click
'			Wait 2
'			Set oWebList= 	objPage.WebTable("webTblBaseConfigQty").ChildItem(2,7,"WebList",0)
'	
'			oWebList.Click
'
'			index = -1
'			arrItems = Split(oWebList.GetROProperty("all items"), ";")
'			For iCounter = 0 to UBound(arrItems)
'					If arrItems(iCounter) = dServiceType Then
'					index = iCounter
'						Exit For
'					End If
'			Next
'			
'			Set ObjShell = CreateObject("Wscript.Shell")
'			ObjPage.WebList("lstservicetype").Select dServiceType
'			oWebElmChild.Click
'			
'			For iCounter = 1 to index+1
'				ObjShell.SendKeys "{DOWN}"
'				Wait 1
'				oWebElmChild.Click
'				Wait 1
'			Next
'			Wait 4
'	
'			Set oWebElmChild1 = objPage.WebTable("webTblBaseConfigQty").ChildItem(2,8,"WebElement",0)
'			oWebElmChild1.Click
'			Set oWebList1= 	objPage.WebTable("webTblBaseConfigQty").ChildItem(2,8,"WebList",0)
'			oWebList1.Click
'								
'			'''''Selection of Grouping level
'			index = -1
'			arrItems = Split(oWebList1.GetROProperty("all items"), ";")
'			For iCounter = 0 to UBound(arrItems)
'					If arrItems(iCounter) = dGroupinglevel Then
'					index = iCounter
'						Exit For
'					End If
'			Next
'			
'			Set ObjShell = CreateObject("Wscript.Shell")
'			oWebElmChild1.Click
'				
'			For iCounter = 1 to index+1
'					ObjShell.SendKeys "{DOWN}"
'					Wait 1
'					oWebElmChild1.Click
'					Wait 1
'			Next
'			Wait 4
'	
'			Set oWebElmChild2 = 	objPage.WebTable("webTblBaseConfigQty").ChildItem(2,9,"WebElement",0)
'			oWebElmChild2.Click
'	
'			Set oWebList2= 	objPage.WebTable("webTblBaseConfigQty").ChildItem(2,9,"WebList",0)
'			oWebList2.Click
'	
'			index = -1
'				arrItems = Split(oWebList2.GetROProperty("all items"), ";")
'				For iCounter = 0 to UBound(arrItems)
'						If arrItems(iCounter) = dActivitylevel Then
'						index = iCounter
'							Exit For
'						End If
'				Next
'	
'				Set ObjShell = CreateObject("Wscript.Shell")
'				oWebElmChild2.Click
'				
'			For iCounter = 1 to index+1
'					ObjShell.SendKeys "{DOWN}"
'					Wait 1
'					oWebElmChild2.Click
'					Wait 1
'			Next
'		Wait 1
'	End If
	
	iRow = objPage.WebTable("webTblBaseConfigQty").GetRowWithCellText("Not Priced")
	With objPage.WebTable("webTblBaseConfigQty")
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
		.ChildItem(iRow, 7, "WebElement", 0).Click : Wait 2
		.ChildItem(iRow, 7, "WebList", 0).Select ServiceType : Wait 2
		.ChildItem(iRow, 7, "WebElement", 0).Click : Wait 2
		
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
	oWebElement("innertext").value = ActualConfigureProduct

	Set oWebElmChild = objPage.ChildObjects(oWebElement)
	oWebElmChild(5).Click

	Set oWebElmChild = 	objPage.WebTable("webTblBaseConfigQty").ChildItem(1,1,"WebCheckBox",0)
	oWebElmChild.Click
		
		'=================== Moved to Quote Option Details Page in R38 ========================
		'blnResult = objPage.WebButton("btnPrice").Exist
		'wait 3
		'blnResult = clickbutton("btnPrice")
		'If Not blnResult Then
		'	Environment.Value("Action_Result") = False  
		'	
		'	Exit Function
		'End If
		'
		'For intCounter = 1 to 5
		'	blnResult = objPage.WebElement("webElmNumberOfOutstandingSaves").Exist(10)
		'	If Not blnResult Then
		'		Exit For
		'	End If
		'Next
		'
		'Wait(10)
		'
		'
		'For intCounter = 1 to 60
		'	blnResult = objPage.WebTable("webTblBaseConfigQty").Exist
		'	If blnResult = "True" Then
		'		wait 5
		'		strPricingStatus = objPage.WebTable("webTblBaseConfigQty").GetCellData(2,10)
		'		If strPricingStatus = "Not Priced" Then
		'			Wait 15
		'		ElseIf strPricingStatus = "Firm" Then
		'			Call ReportLog("Calculate Price","Pricing Status should be changed from Not Priced to Firm","Pricing Status is shown as - "&strPricingStatus,"PASS","False")
		'			Exit For
		'		End If
		'	End If
		'Next
		'
		'If strPricingStatus = "Not Priced" Then
		'	Wait 10
		'	Call ReportLog("Calculate Price","Pricing Status should be changed from Not Priced to Firm","Pricing Status is not changed and is shown as - "&strPricingStatus,"FAIL","True")				
		'	Environment.Value("Action_Result") = False  
		'	
		'	Exit Function
		'End If

	blnResult = objPage.WebElement("webElmQuoteDetails").Exist
	If blnResult = "True" Then
		blnResult = clickWebElement("webElmQuoteDetails")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Exit Function
		End If
	End If

	objPage.Sync

	Browser("brwSQE").Page("pgSQE").WebTable("webTblItems").WaitProperty "height", micGreaterThan(0), 10000*6

	'Wait For the Calculate Price Button to be Visible
	objPage.Link("lnkCalculatePrice").WaitProperty "visible", "True", 10000*5

	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
		 objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Exit Function
	End If

	'=================== New Requirement in R39 ===============================
	'Click on Calculate Price
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Wait 60
	
	blnResult = BuildWebReference("brwSQE", "pgSQE", "")
		If Not blnResult Then	Environment("Action_Result") = False : Exit Function

	'Get Column Index
	arrColumnNames = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	intProductCol = 0 : intConfiguredCol = 0 : intPricingStatusCol = 0
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Configured" Then
			intConfiguredCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Product" Then
			intProductCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Pricing Status" Then
			intPricingStatusCol = intCounter + 1
		End If
	Next

	'Check Whether Configured and Pricing Status are Populated or not
	For intCounter = 1 to 20
		objPage.WebTable("webTblItems").RefreshObject
		strConfigured = Trim(objPage.WebTable("webTblItems").GetCellData(2, intConfiguredCol))
		If strConfigured = "VALID" Or strConfigured = "INVALID" Then
			Exit For
		ElseIf strConfigured = "" Then
			Wait 20
		Else
			Wait 5
			objBrowser.WinToolbar("text:=Page Control", "index:=0").Press 1 : Wait 5
		End If
	Next

	For intCounter = 1 to 20
		objPage.WebTable("webTblItems").RefreshObject
		strPricing = Trim(objPage.WebTable("webTblItems").GetCellData(2, intPricingStatusCol))
		If strPricing = "Firm" Then
			Exit For
		ElseIf strPricing = "" Then
			Wait 20
		Else
			Wait 5
			objBrowser.WinToolbar("text:=Page Control", "index:=0").Press 1 : Wait 5
		End If
	Next

	strProduct = objPage.WebTable("webTblItems").GetCellData(2, intProductCol)
	If Instr(strProduct, "One Cloud Cisco - Site") > 0 Then
			If strConfigured = "VALID" And strPricing = "Firm" Then
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

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
