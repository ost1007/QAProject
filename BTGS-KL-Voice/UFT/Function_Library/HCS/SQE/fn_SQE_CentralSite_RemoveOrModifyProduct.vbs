'****************************************************************************************************************************
' Function Name 		: fn_SQE_CentralSite_RemoveOrModifyProduct
' Purpose				: Function to Remove or Modify Central Site Products
' Created By By			: Nagaraj V || 26/08/2015 || v1.0
' Return Values	 		: Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_CentralSite_RemoveOrModifyProduct(dQuoteID, dProductFamily, dProductCategory, dProduct)

   	'Declaration of variables
	Dim objMsg
	Dim intCounter, intRow, intAssetStatus,intProduct, iCol
	Dim blnResult, blnShowingQuoteOption_AddProductExists, blnShowingAddProduct_AddProductLinkExists, blnINService
	Dim strAssetStatus, strProductName

	blnShowingQuoteOption_AddProductExists = False
	blnShowingAddProduct_AddProductLinkExists = False
	blnINService = False

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Check if navigated to Quote Options Page after clicking on Additional Products Configuration link
	If objPage.Link("lnkQuoteOptions").Exist(60) Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Additional Product's Config link","User is Navigated to the Quote Options page ","PASS", False)
	Else
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Additional Product's Config link","User is not navigated to the Quote Options page ","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function		
	End If

	'Set innertext for Quote ID
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = dQuoteID & "-0" 'Need to Remove
	odesc("html tag").value = "TD"

	For intCounter = 1 to 30
		Set objElm = objPage.ChildObjects(oDesc)
		If objElm.Count >= 1 Then
			objElm(0).Click
			Exit For
		Else
			Wait 10
		End IF
	Next

	If objElm.Count = 0 Then
		Call ReportLog("Quote Id","User should be able to click on Quote Id","Quote ID does not exist on page","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	If objElm.Count = 0 Then
		Call ReportLog("Quote Id","User should be able to click on Quote Id","Quote ID does not exist on page","FAIL", True)
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	'Loop to check which Page exists
	For intCounter = 1 To 50
		If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Link("lnkAddProduct").Exist(2) Then
			blnShowingQuoteOption_AddProductExists = True
			Exit For '#intCounter
		ElseIf Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct").Link("lnkAddProduct").Exist(2) Then
			blnShowingAddProduct_AddProductLinkExists = True
			Exit For '#intCounter
		End if
	Next '#intCounter
	
	'Fail If Neither of Page (Quote Options and Add Product Page is showing the control
	If Not blnShowingQuoteOption_AddProductExists AND Not blnShowingAddProduct_AddProductLinkExists Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking on Quote ID","User is not navigated to the Quote Details page ","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking on Quote ID","User is Navigated to the Quote Details page ","PASS", False)
	
	If blnShowingQuoteOption_AddProductExists Then
			blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
			
			'Wait until lnkAddProduct link is visible and height is > 0
			If objPage.Link("lnkAddProduct").Exist(60*5) Then
				objPage.Link("lnkAddProduct").WaitProperty "height", micGreaterThan(0), 1000*60*3
			End If
		
			'Click on Add Products
			If dOrderType = "Provide" Then
				blnResult = clickLink("lnkAddProduct")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Else
				blnResult = clickLink("lnkRemove/ModifyProduct")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
	End If '#blnShowingQuoteOption_AddProductExists
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Check for Number of Quote Items
	blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(60)
	If blnResult Then
		strText = GetWebElementText("elmQuoteItemsCount")
		If Right(Trim(strText),1) = "0" Then
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is displayed correctly as - " & strText,"PASS", False)
		Else
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Click on Remove/Modify Product Tab
	blnResult = clickLink("lnkRemove/ModifyProduct")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 5
		blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(60)
			If blnResult Then Exit For
	Next
	
	'Wait until Processing is finished
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=innertext:=Processing\.\.\.", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
'	'Select  Product Family
'	objPage.WebEdit("txtProductFamily").Click
'	blnResult = enterText("txtProductFamily", dProductFamily)
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	Wait 2
'	blnResult = selectValueFromPageList("lstProductFamily", dProductFamily)
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'		
'	Wait 10
'
'	'Select  Product Category
'	objPage.WebEdit("txtProductVariant").Click
'	blnResult = enterText("txtProductVariant", dProductCategory)
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	Wait 2
'	blnResult = selectValueFromPageList("lstProductVariant", dProductCategory)
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'
'	'Select product offering
'	objPage.WebEdit("txtProductOffering").Click
'	blnResult = enterText("txtProductOffering", dProduct)
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
'	Wait 2
'	blnResult = selectValueFromPageList("lstProductOffering", dProduct)
'		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Setting.WebPackage("ReplayType") = 2 'Mouse Mode
	Call fn_SQE_SelectProductFamilyVariantOffering(dProductFamily, dProductCategory, dProduct)
		If Not Environment("Action_Result") Then Exit Function
	Setting.WebPackage("ReplayType") = 1 'Event Mode

	For intCounter = 1 To 5
		blnExist = objPage.WebTable("tblSiteFullDet").Exist(60)
		If blnExist Then Exit For
	Next
	
	If Not blnExist Then
		Call ReportLog("Product Table", "Product Table should exist", "Product Table doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If Not objPage.WebTable("tblSiteFullDetHeader").Exist(60) Then
		Call ReportLog("Product Table Header", "Product Table Header should exist", "Product Table Header doesn't exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		arrColumnNames = Split(objPage.WebTable("tblSiteFullDetHeader").GetROProperty("column names"), ";")
		For iCol = 0 to UBound(arrColumnNames)
			If arrColumnNames(iCol) = "Asset Status" Then
				intAssetStatus = iCol + 1
			ElseIf arrColumnNames(iCol) = "Product" Then
				intProduct = iCol + 1
			End If
		Next
	End If

	intRow = objPage.WebTable("tblSiteFullDet").GetRowWithCellText(dProduct)
   	If intRow <= 0 Then
		objPage.WebList("lstSiteTablelength").Select Cstr("100")
		objPage.WebList("lstSiteTablelength").Object.Click
		CreateObject("WScript.Shell").SendKeys "{UP}"
		CreateObject("WScript.Shell").SendKeys "{DOWN}"
		Wait 10
		objPage.WebTable("tblSiteFullDet").RefreshObject
		Wait 2
		intRow = objPage.WebTable("tblSiteFullDet").GetRowWithCellText(dProduct)
		If intRow < 0 Then
			Call ReportLog("WebTable: Site Details","Table should be populated","Table is not populated with Product " & dProduct,"FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	intRowCount = objPage.WebTable("tblSiteFullDet").RowCount
	For iRow = 2 To intRowCount
		strProductName = objPage.WebTable("tblSiteFullDet").GetCellData(iRow, intProduct)
		strAssetStatus = objPage.WebTable("tblSiteFullDet").GetCellData(iRow, intAssetStatus)
		If strProductName = dProduct AND ( strAssetStatus = "IN_SERVICE" OR strAssetStatus = "IN-SERVICE") Then
			blnINService = True
			Exit For
		ElseIf Instr(strProductName, dProduct) > 0 AND ( strAssetStatus = "IN_SERVICE" OR strAssetStatus = "IN-SERVICE" ) Then
			blnINService = True
			Exit For
		End If
	Next
	
	If Not blnINService Then
		Call ReportLog("Check Asset Status", "Asset Status should be IN_SERVICE", "Asset Status is not IN_SERVICE", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Check Asset Status", "Asset Status should be IN_SERVICE", "Asset Status is found to be - " & strAssetStatus, "Information", True)
	End If

	objPage.WebTable("tblSiteFullDet").ChildItem(iRow, 1, "WebCheckBox", 0).Set "ON"
	
	'Click on RemoveModify Product WebButton
	blnResult = objPage.WebButton("btnRemoveModifyProduct").Exist(60)
	If blnResult Then
		blnResult = objPage.WebButton("btnRemoveModifyProduct").WaitProperty("disabled", 0, 1000*60*3)
		If Not blnResult Then
			Call ReportLog("btnRemoveModifyProduct", "RemoveModifyProduct Button should be enabled", "RemoveModifyProduct Button is disabled", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			blnResult = clickButton("btnRemoveModifyProduct")
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End If
	Else
		Call ReportLog("Click on Add Product","User should be able to click on Add Product","User is not able to click on AddProduct","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If

	'Check for Number of Quote Items
	For intCounter = 1 to 10
		blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(60)
		If blnResult Then
			strText = GetWebElementText("elmQuoteItemsCount")
			If Right(Trim(strText),1) = "1" Then
				Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is displayed correctly as - " & strText,"PASS", True)
				Exit For
			Else
				Wait 30
			End If	
		End If
	Next

	If Right(Trim(strText),1) = "0" Then
		Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Click on Continue to Quote details
	blnResult = objPage.Link("lnkContinue2QuoteOption").Exist(60)
	blnResult = clickLink("lnkContinue2QuoteOption")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").Exist(120)
	If Not blnResult Then
		Call ReportLog("Navigation to Quote Option","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected", "FAIL", True)
		Environment.Value("Action_Result") = False
	Else
		Call ReportLog("Navigation to Quote Option","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is visible and navigate to Showing Quote Options Page", "PASS", True)
		Environment.Value("Action_Result") = True
	End If
End Function
