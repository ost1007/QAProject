'===============================================================================================================================================
' Function Name 		:		fn_SQE_AddProducts
' Purpose			: 		Function to Add Products to the Quote
' Author				:		Linta C.K. || 04/7/2014
' Modified History		:		Nagaraj V || 04/08/2015 || Migrating to UFT Supported Controls and New OR Implementations
' Return Values	 	: 		Not Applicable
'===============================================================================================================================================
Public Function fn_SQE_AddProducts(dQuoteID, dProductCategory, dProduct, dProductFamily, dOrderType)

   	'Declaration of variables
	Dim strQuoteID, strProductCategory, strClass
	Dim objMsg, objElm
	Dim blnResult, blnShowingQuoteOption_AddProductExists, blnShowingAddProduct_AddProductLinkExists
	Dim intCounter

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
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is displayed correctly as - " & strText,"PASS", True)
		Else
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	'Wait for Product Family to be populated
	For intCounter = 1 To 5
		If objPage.WebList("lstProductFamily").Exist(60) Then
			Exit For
		End If
	Next
	
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
	
	'Function Call to select Product from dropdown
	Setting.WebPackage("ReplayType") = 2 'Mouse Mode
	Call fn_SQE_SelectProductFamilyVariantOffering(dProductFamily, dProductCategory, dProduct)
		If Not Environment("Action_Result") Then Exit Function
	Setting.WebPackage("ReplayType") = 1 'Event Mode

	'Click on Add Product WebButton
	blnResult = objPage.WebButton("btnAddProduct").Exist(60)
	If blnResult = "True" Then
		blnResult = clickButton("btnAddProduct")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Add Product","User should be able to click on Add Product","User is not able to click on AddProduct","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If

	'Check for Number of Quote Items
	For intCounter = 1 to 20
		blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(30)
		If blnResult Then
			strText = GetWebElementText("elmQuoteItemsCount")
			If Right(Trim(strText),1) = "1" Then
				Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as <B>1</B>","Number of Quote Items is displayed correctly as - <B>" & strText & "</B", "PASS", True)
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
	blnResult = objPage.Link("lnkContinue2QuoteOption").Exist(5)
	If blnResult Then
		blnResult = clickLink("lnkContinue2QuoteOption")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Link Continue To Quote Details","User should be able to click on Continue To Quote Details","User is not able to click on Continue To Quote Details","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If

	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").Exist(1000*60*5)
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL", True)
		Environment.Value("Action_Result") = False : Exit Function
	End If
End Function
