'=============================================================================================================
' Description	: Function to Modify Or Remove Central Site Product
' History	  	 : Name				Date			Changes Implemented
' Created By	   :  Nagaraj			08/07/2015 				NA
' Return Values : Not Applicable
' Example: fn_SQE_CentralSite_RemoveOrModifyProducts "000000000205465", "One Cloud", "One Cloud Cisco-Build Order", "Internet Service Access"
'=============================================================================================================
Public Function fn_SQE_CentralSite_RemoveOrModifyProducts(ByVal QuoteID, ByVal ProductFamily, ByVal ProductCategory, ByVal Product)

   	'Declaration of variables
	Dim strQuoteID, strProductCategory, strText
	Dim objMsg, objElmQuoteID, objProductTable
	Dim blnResult, blnExist
	Dim intCounter, intChecked
	Dim oDescElmQuoteID
	Dim oShell

	'Assigning values to variables
	strQuoteID = QuoteID
	strProductCategory = ProductCategory
	strProduct = Product
	strProductFamily = ProductFamily
	Set oShell = CreateObject("WScript.Shell")

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Check if navigated to Quote Options Page after clicking on Additional Products Configuration link
	If objPage.Link("lnkQuoteOptions").Exist Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Additional Product's Config link","User is Navigated to the Quote Options page ","PASS","")
	Else
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Additional Product's Config link","User is not navigated to the Quote Options page ","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function		
	End If

	'Set innertext for Quote ID
	Set oDescElmQuoteID = Description.Create
	oDescElmQuoteID("micClass").value = "WebElement"
	oDescElmQuoteID("innertext").value = strQuoteID
	oDescElmQuoteID("html tag").value = "TD"

	For intCounter = 1 to 10
		Set objElmQuoteID = objPage.ChildObjects(oDescElmQuoteID)
		If objElmQuoteID.Count = 1 Then
			objElmQuoteID(0).Click
			Exit For
		Else
			Wait 10
		End IF
	Next

	If objElmQuoteID.Count = 0 Then
		Call ReportLog("Quote Id","User should be able to click on Quote Id","Quote ID <B>" & strQuoteID & "does not exist on page","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	If Not Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Link("lnkAddProduct").Exist(120) Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking  on Quote ID","User is not navigated to the Quote Details page ","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	'Check if navigated to Quote Details page.
	If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").Link("lnkAddProduct").WaitProperty("height", micGreaterThan(0), 1000*60*2) Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking on Quote ID","User is Navigated to the Quote Details page ","PASS","")
	Else
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking  on Quote ID","User is not navigated to the Quote Details page ","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function		
	End If

	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Check if Adding Products is already done, by validating the disabled status for Configure Product link
	objPage.Link("lnkAddProduct").WaitProperty "height", micGreaterThan(0), 1000*60*5

	blnResult = clickLink("lnkAddProduct")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct").WebElement("elmQuoteItemsCount").Exist
	If blnResult Then
		blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		strText = GetWebElementText("elmQuoteItemsCount")
		If Right(Trim(strText),1) = "0" Then
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is displayed correctly as - "&strText,"PASS","")
		Else
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL","True")
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
	'Click on Remove/Modify Product Tab
	blnResult = clickLink("lnkRemove/ModifyProduct")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	objPage.WebList("lstProductFamily").WaitProperty "height", micGreaterThan(0), 1000*60
	
	'Select  Product Family
	blnResult = selectValueFromPageList("lstProductFamily", strProductFamily)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Select  Product Category
	blnResult = selectValueFromPageList("lstProductVariant", strProductCategory)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Select product offering
	blnResult = selectValueFromPageList("lstProductOffering", strProduct)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 5

	'Check for the existence of SiteTable/ProductTable
	Set objProductTable = objPage.WebTable("tblSiteFullDet")
	With objProductTable 
		For intCounter = 0 to 15
			blnExist = .Exist
			If blnExist Then Exit For
		Next
	End With	

	If Not blnExist Then
		Call ReportLog("Product Table", "Product Table should be displayed on Selecting Product", "Check whether the Product is <B>IN SERVICE</B> in BFG IMS", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Check whether Product offered exists in table or not
	iRow = objProductTable.GetRowWithCellText(strProduct)
	If iRow <= 0 Then
		Call ReportLog("Product Table", "<B>" & strProduct & " Product should exist in the table", "<B>" & strProduct & " Product doesn't exist in table", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		intChecked = CInt(objPage.WebTable("tblSiteFullDet").ChildItem(iRow, 1, "WebCheckBox", 0).GetROProperty("checked"))
		If intChecked = 1 Then
			Call ReportLog("Product Table", "<B>" & strProduct & " Product should be checked", "<B>" & strProduct & " Product is checked by default", "PASS", True)
		Else
			Call ReportLog("Product Table", "<B>" & strProduct & " Product should be checked", "<B>" & strProduct & " Product is not checked by default", "Warnings", True)
			objPage.WebTable("tblSiteFullDet").ChildItem(iRow, 1, "WebCheckBox", 0).Click
		End If
	End If

    	'Click on RemoveModify Product WebButton
	blnResult = objPage.WebButton("btnRemoveModifyProduct").Exist
	If blnResult Then
		blnResult = clickButton("btnRemoveModifyProduct")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Add Product","User should be able to click on Add Product","User is not able to click on AddProduct","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	'Check for Number of Quote Items
	For intCounter = 1 to 10
		blnResult = objPage.WebElement("elmQuoteItemsCount").Exist
		If blnResult = "True" Then
			strText = GetWebElementText("elmQuoteItemsCount")
			If Right(Trim(strText),1) = "1" Then
				Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is displayed correctly as - " & strText,"PASS", True)
				Exit For
			Else
				Wait 5
			End If	
		End If
	Next

	If Right(Trim(strText),1) = "0" Then
        Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is not displayed correctly.Instead displayed as - "& strText,"FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Click on Continue to Quote details
	blnResult = objPage.Link("lnkContinue2QuoteOption").Exist
	If blnResult Then
		blnResult = clickLink("lnkContinue2QuoteOption")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Link Continue To Quote Details","User should be able to click on Continue To Quote Details","User is not able to click on Continue To Quote Details","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").WaitProperty("height", micGreaterThan(0), 1000*60*5)
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	Environment.Value("Action_Result") = True
End Function
