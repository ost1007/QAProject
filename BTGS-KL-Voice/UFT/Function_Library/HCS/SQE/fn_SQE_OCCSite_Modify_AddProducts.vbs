'===========================================================================================================================================
' Description		: Function to Add Products to the Quote
' History			: Author				Date			Changes Impleented
' Creation By		: Nagaraj V	  22/06/2015			NA
' Example		: fn_SQE_OCCSite_AddProducts(dQuoteID, dProductCategory, dProduct, dProductFamily, dCountry, dSiteName)	
' Return Values	: Not Applicable
'===========================================================================================================================================
Public Function fn_SQE_OCCSite_Modify_AddProducts(dQuoteID, dProductCategory, dProduct, dProductFamily, dCountry, dSiteName)

   	'Declaration of variables
	Dim strQuoteID,strProductCategory
	Dim objMsg
	Dim blnResult
	Dim intCounter

	'Assigningof values to variables
	strQuoteID = dQuoteID
	strProductCategory = dProductCategory
	strProduct = dProduct
	strProductFamily = dProductFamily

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Set innertext for Quote ID
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = strQuoteID & "-0"
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
		Call ReportLog("Quote Id","User should be able to click on Quote Id","Quote ID<B>" & strQuoteID & "</B> does not exist on page","FAIL", True)
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
	
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	

	blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(60)
	If blnResult Then
		strText = GetWebElementText("elmQuoteItemsCount")
		If Right(Trim(strText),1) = "0" Then
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is displayed correctly as - " & strText,"PASS", True)
		Else
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is not displayed correctly.Instead displayed as - " & strText,"FAIL", True)
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
	
	'Wait for Product Family to be populated
	For intCounter = 1 To 5
		If objPage.WebEdit("txtProductFamily").Exist(60) Then
			Exit For
		End If
	Next
	
	'Function Call to select Product from dropdown
	Setting.WebPackage("ReplayType") = 2 'Mouse Mode
	Call fn_SQE_SelectProductFamilyVariantOffering(dProductFamily, dProductCategory, dProduct)
		If Not Environment("Action_Result") Then Exit Function
	Setting.WebPackage("ReplayType") = 1 'Event Mode
	
	
	''Wait for Product Family to be populated
	'For intCounter = 1 To 5
	'	If objPage.WebList("lstProductFamily").Exist(60) Then
	'		Exit For
	'	End If
	'Next
	'
	''Select  Product Family
	'blnResult = enterText("txtProductFamily", dProductFamily)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'Wait 2
	'blnResult = selectValueFromPageList("lstProductFamily", dProductFamily)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'	
	'Wait 10
	'
	''Select  Product Category
	'blnResult = enterText("txtProductVariant", dProductCategory)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'Wait 2
	'blnResult = selectValueFromPageList("lstProductVariant", dProductCategory)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'
	''Select product offering
	'blnResult = enterText("txtProductOffering", dProduct)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'Wait 2
	'blnResult = selectValueFromPageList("lstProductOffering", dProduct)
	'	If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Select the Country
	If dCountry <> "" Then	
		blnResult = selectValueFromPageList("lstCountryFilter", dCountry)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	If objPage.WebEdit("txtSearchStateCitySite").Exist(60) Then
		'Enter the Site Name to Search
		blnResult = enterText("txtSearchStateCitySite", dSiteName)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		'Click on Search
		blnResult = clickButton("btnSearchStateCitySite")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	For intCounter = 1 to 15
		blnExist = objPage.WebTable("tblSiteFullDet").Exist(30)
			If blnExist Then Exit For
	Next '#intCounter
	
	If Not blnExist Then
		Call ReportLog("tblSiteFullDet", "tblSiteFullDet - Table should be visible", "tblSiteFullDet - Table is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	intRow = objPage.WebTable("tblSiteFullDet").GetRowWithCellText(UCase(dSiteName))
    	If intRow <= 0 Then
		objPage.WebList("lstSiteTablelength").Select Cstr("100")
		'Wait 10
		objPage.WebTable("tblSiteFullDet").RefreshObject
		Wait 2
		intRow = objPage.WebTable("tblSiteFullDet").GetRowWithCellText(UCase(dSiteName))
		If intRow < 0 Then
			Call ReportLog("WebTable: Site Details","Table should be populated","Table is not populated with site name: " & dSiteName,"FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If
	End If
	
	If dProduct = "One Cloud Cisco - Site" Then
		intSiteName = -1 : intAssetStatus = -1
		With Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct").WebTable("tblSiteFullDetHeader")
			If Not .Exist(60) Then
				Call ReportLog("tblSiteFullDetHeader", "Table should exist", "Table doesn't exist", "Fail", True)
				Environment("Action_Result") = False : Exit Function
			End If
			arrColumnNames = Split(.GetROProperty("column names"), ";")
			For index = 0 To UBound(arrColumnNames)
				If arrColumnNames(index) = "Site Name" Then
					intSiteName = index + 1
				ElseIf arrColumnNames(index) = "Asset Status" Then
					intAssetStatus =  index + 1
				End If
			Next
		End With
		
		If intSiteName = -1 OR intAssetStatus = -1 Then
			Call ReportLog("tblSiteFullDetHeader", "Site Name and Asset Status should exist", "Either of the fields doesn't exist", "Fail", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		intRowCount = objPage.WebTable("tblSiteFullDet").RowCount
		For iRow = 2 To intRowCount
			strSiteName = objPage.WebTable("tblSiteFullDet").GetCellData(iRow, intSiteName)
			strAssetStatus = objPage.WebTable("tblSiteFullDet").GetCellData(iRow, intAssetStatus)
			If strSiteName = dSiteName And strAssetStatus = "IN_SERVICE" Then
				intRow = iRow
				Exit For
			End If
		Next
	End If
	
	If Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct").WebTable("tblSiteFullDetHeader").Exist(10) Then
		strStatus = Trim(objPage.WebTable("tblSiteFullDet").GetCellData(intRow, intAssetStatus))
		If strStatus = "IN_SERVICE" Then
			Call ReportLog("Check Site Status", dSiteName & " - site should be 'IN_SERVICE'", dSiteName & " - site is found to be - " & strStatus, "PASS", True)
		Else
			Call ReportLog("Check Site Status", dSiteName & " - site should be 'IN_SERVICE'", dSiteName & " - site is found to be - " & strStatus, "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	objPage.WebTable("tblSiteFullDet").ChildItem(intRow, 1, "WebCheckBox", 0).Set "ON"

	'Click on RemoveModify Product WebButton
	blnResult = objPage.WebButton("btnRemoveModifyProduct").Exist(60)
	blnResult = clickButton("btnRemoveModifyProduct")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Check for Number of Quote Items
	For intCounter = 1 to 20
		blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(60)
		If blnResult Then
			strText = GetWebElementText("elmQuoteItemsCount")
			If Right(Trim(strText),1) = "1" Then
				Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is displayed correctly as</BR>" & strText,"PASS", True)
				Exit For
			ElseIf objPage.WebElement("html id:=commonError", "class:=error").Exist(5) Then
				strText = objPage.WebElement("html id:=commonError", "class:=error").GetROProperty("innertext")
				Call ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1", "Encountered Error:= " & strText,"FAIL", True)
				Environment.Value("Action_Result") = False : Exit Function
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
	blnResult = objPage.Link("lnkContinue2QuoteOption").Exist
	If blnResult Then
		blnResult = clickLink("lnkContinue2QuoteOption")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Link Continue To Quote Details","User should be able to click on Continue To Quote Details","User is not able to click on Continue To Quote Details","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").Exist(60)
		If blnResult Then Exit For
	Next
	
	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").WaitProperty("height", micGreaterThan(0), 1000*60*5)
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
End Function

'*************************************************************************************************************************************************************************************
'End of function
'**************************************************************************************************************************************************************************************
