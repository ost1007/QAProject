'===================================================================================================================================================
' Function Name 		:	fn_SQE_OCCSite_AddProducts
' Purpose			: 	Function to Add Products to the Quote
' Author				:	Nagaraj V		
' Creation Date  		:	12/10/2014		
' Return Values	 	:	Not Applicable
'===================================================================================================================================================
Public Function fn_SQE_OCCSite_AddProducts(dQuoteID, dOrderType, dProductCategory, dProduct, dProductFamily, dCountry, dSiteName)

   	'Declaration of variables
	Dim strQuoteID, strProductCategory, strText
	Dim objMsg, objElm
	Dim blnResult, blnShowingQuoteOption_AddProductExists, blnShowingAddProduct_AddProductLinkExists
	Dim intCounter
	Dim oDesc

	'Assigningof values to variables
	strQuoteID = dQuoteID
	strProductCategory = dProductCategory
	strProduct = dProduct
	strProductFamily = dProductFamily
	blnShowingQuoteOption_AddProductExists = False
	blnShowingAddProduct_AddProductLinkExists = False

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Set innertext for Quote ID
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = strQuoteID & "-0"
	odesc("html tag").value = "TD"

	For intCounter = 1 to 10
		Set objElm = objPage.ChildObjects(oDesc)
		If objElm.Count >= 1 Then
			objElm(0).Click
			Exit For
		Else
			Wait 10
		End IF
	Next

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
	
	
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	

	blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(60)
	If blnResult Then
		strText = GetWebElementText("elmQuoteItemsCount")
		If Right(Trim(strText),1) = "0" Then
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is displayed correctly as - "&strText,"PASS", False)
		Else
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
		
	'	'Select  Product Family
	'	blnResult = enterText("txtProductFamily", dProductFamily)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'	Wait 2
	'	blnResult = selectValueFromPageList("lstProductFamily", dProductFamily)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'		
	'	Wait 10
	'
	'	'Select  Product Category
	'	blnResult = enterText("txtProductVariant", dProductCategory)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'	Wait 2
	'	blnResult = selectValueFromPageList("lstProductVariant", dProductCategory)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'
	'	'Select product offering
	'	blnResult = enterText("txtProductOffering", dProduct)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'	Wait 2
	'	blnResult = selectValueFromPageList("lstProductOffering", dProduct)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Country
	'	index = -1
	'	arrItems = Split(objPage.WebList("lstCountryFilter").GetROProperty("all items"), ";")
	'	For iCounter = 0 to UBound(arrItems)
	'		If arrItems(iCounter) = dCountry Then
	'			index = iCounter
	'			Exit For
	'		End If
	'	Next
	
	'Function Call to select Product from dropdown
	Setting.WebPackage("ReplayType") = 2 'Mouse Mode
	Call fn_SQE_SelectProductFamilyVariantOffering(dProductFamily, dProductCategory, dProduct)
		If Not Environment("Action_Result") Then Exit Function
	Setting.WebPackage("ReplayType") = 1 'Event Mode
	
	'Select the Country
	blnResult = selectValueFromPageList("lstCountryFilter", dCountry)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	If objPage.WebEdit("txtSearchStateCitySite").Exist(60) Then
		'Enter the Site Name to Search
		blnResult = enterText("txtSearchStateCitySite", dSiteName)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		'Click on Search
		blnResult = clickButton("btnSearchStateCitySite")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	'	blnResult = objPage.WebList("lstCountryFilter").Exist(60)
	'	If blnResult Then
	'		objPage.WebEdit("class:=select2-input select2.*", "name:=WebEdit", "index:=0").Click		
	'		If objPage.WebList("lstCountryFilter").GetROProperty("value") = "" Then
	'			index = index + 1
	'		End If
	'		Set ObjShell = CreateObject("Wscript.Shell")
	'		For iCounter = 1 to index - 1
	'			ObjShell.SendKeys "{DOWN}"
	'			Wait 1
	'		Next
	'		Call ReportLog("Select Country","User should be able to select Country","User is able to select value for Country","PASS", True)
	'		ObjShell.SendKeys "{ENTER}"
	'	Else
	'		Call ReportLog("Select Country","User should be able to select Country","User is not able to select value for Country","FAIL", True)
	'		Environment.Value("Action_Result") = False  
	'		Exit Function
	'	End If

	'Set oShell = Nothing

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
		'objPage.WebList("lstSiteTablelength").Select Cstr("100")
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

	objPage.WebTable("tblSiteFullDet").ChildItem(intRow, 1, "WebCheckBox", 0).Set "ON"

	'Click on Add Product WebButton
	blnResult = objPage.WebButton("btnAddProduct").Exist(60)
	blnResult = clickButton("btnAddProduct")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Check for Number of Quote Items
	For intCounter = 1 to 20
		blnResult = objPage.WebElement("elmQuoteItemsCount").Exist
		If blnResult Then
			strText = GetWebElementText("elmQuoteItemsCount")
			If Right(Trim(strText),1) = "1" Then
				Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is displayed correctly as - "&strText,"PASS", False)
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
	blnResult = objPage.Link("lnkContinue2QuoteOption").Exist
	If blnResult Then
		blnResult = clickLink("lnkContinue2QuoteOption")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Link Continue To Quote Details","User should be able to click on Continue To Quote Details","User is not able to click on Continue To Quote Details","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If

	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").WaitProperty("height", micGreaterThan(0), 1000*60*5)
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If
End Function

'*************************************************************************************************************************************************************************************
'End of function
'**************************************************************************************************************************************************************************************

'================================ QTP 11.0 WorkArounds =================================
'Select  Product Family
	'index = -1
	'arrItems = Split(objPage.WebList("lstProductFamily").GetROProperty("all items"), ";")
	'For iCounter = 0 to UBound(arrItems)
	'	If arrItems(iCounter) = dProductFamily Then
	'		index = iCounter
	'		Exit For
	'	End If
	'Next

	'blnResult = objPage.WebList("lstProductFamily").Exist
	'If blnResult = "True" Then
	'	objPage.WebList("lstProductFamily").HighLight
	'	objPage.WebList("lstProductFamily").Click
	'	Set ObjShell = CreateObject("Wscript.Shell")
	'	For iCounter = 1 to index
	'		ObjShell.SendKeys "{DOWN}"
	'		Wait 1
	'	Next
	'	Wait 3
	'	Set ObjShell = Nothing
	'	Call ReportLog("Select Product category","User should be able to select Product category","User is able to select value for Product Family","PASS",False)
	'Else
    '  	Call ReportLog("Select Product category","User should be able to select Product category","User is able to select value for Product Family","FAIL", True)
	'	Environment.Value("Action_Result") = False  
	'	
	'	Exit Function
	'End If
	
'Select product offering
	'index = -1
	'arrItems = Split(objPage.WebList("lstProductCategory").GetROProperty("all items"), ";")
	'For iCounter = 0 to UBound(arrItems)
	'	If arrItems(iCounter) = dProductCategory Then
	'		index = iCounter
	'		Exit For
	'	End If
	'Next


	'blnResult = objPage.WebList("lstProductCategory").Exist
	'If blnResult = "True" Then
	'	objPage.WebList("lstProductCategory").HighLight
	'	objPage.WebList("lstProductCategory").Click
	'	Set ObjShell = CreateObject("Wscript.Shell")
	'			Set ObjShell = CreateObject("Wscript.Shell")
	'			For iCounter = 1 to index
	'				ObjShell.SendKeys "{DOWN}"
	'				wait 1
	'			Next
	'			Set ObjShell = Nothing
	'			Call ReportLog("Select Product category","User should be able to select Product category","User is able to select value for Product Category ","PASS", True)
	'
	'Else
    '  	Call ReportLog("Select Product category","User should be able to select Product category","User is not able to select value for Product Category ","FAIL", True)
	'	Environment.Value("Action_Result") = False  
	'	
	'	Exit Function
	'End If

	
'Select product offering
	'index = -1
	'
	'Select Case dProduct
	'	Case "One Cloud Cisco - Site", "One Cloud Cisco Site"
	'			index = -1
	'			arrItems = Split(objPage.WebList("lstProduct").GetROProperty("all items"), ";")
	'			For iCounter = 0 to UBound(arrItems)
	'				If arrItems(iCounter) =  "One Cloud Cisco - Site" OR arrItems(iCounter) =  "One Cloud Cisco Site" Then
	'					index = iCounter
	'					Exit For
	'				End If
	'			Next
	'	Case Else
	'			arrItems = Split(objPage.WebList("lstProduct").GetROProperty("all items"), ";")
	'			For iCounter = 0 to UBound(arrItems)
	'				If arrItems(iCounter) = dProduct Then
	'					index = iCounter
	'					Exit For
	'				End If
	'			Next
	'End Select
	
	'blnResult = objPage.WebList("lstProduct").Exist
	'If blnResult = "True" Then
	'	objPage.WebList("lstProduct").HighLight
	'	objPage.WebList("lstProduct").Click
	'	Set ObjShell = CreateObject("Wscript.Shell")
	'	For iCounter = 1 to index
	'		ObjShell.SendKeys "{DOWN}"
	'		Wait 1
	'	Next
	'	Call ReportLog("Select Product","User should be able to select Product","User is able to select value for Product Varient","PASS", True)
	'Else
	'	Call ReportLog("Select Product","User should be able to select Product","User is not able to select value for Product Varient","FAIL", True)
	'	Environment.Value("Action_Result") = False  
	'	
	'	Exit Function
	'End If

	'Set oShell = Nothing
	'Wait 5
	'objPage.WebList("lstProduct").Click
	'CreateObject("Wscript.Shell").SendKeys "{TAB}"
