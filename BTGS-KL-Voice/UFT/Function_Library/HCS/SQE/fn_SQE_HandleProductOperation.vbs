'****************************************************************************************************************************
' Function Name 		:		fn_SQE_HandleProductOperation
' Purpose				: 	Function to Handle Product Addition, Removal, Migrate
' Created History		:		Nagaraj V || 23-09-2015 || v1.0
' Return Values	 		: 		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_HandleProductOperation(ByVal Operation, ByVal QuoteID, ByVal ProductFamily, ByVal ProductCategory, ByVal Product)
   	'Declaration of variables
	Dim strClass
	Dim objMsg, objElm
	Dim blnResult
	Dim intCounter
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Set innertext for Quote ID
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = QuoteID & "-0"
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
		Call ReportLog("Quote Id","User should be able to click on Quote Id","Quote ID does not exist on page","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function
	End If
	
	'Check if navigated to Quote Details page.
	 If Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct").Link("lnkAddProduct").Exist(60) Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking on Quote ID","User is Navigated to the Quote Details page ","PASS","")
	Else
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking  on Quote ID","User is not navigated to the Quote Details page ","FAIL","True")
		Environment.Value("Action_Result") = False  
		Exit Function		
	End If
	
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	'Check if Adding Products is already done, by validating the disabled status for Configure Product link
	objPage.Link("lnkAddProduct").WaitProperty "height", micGreaterThan(0), 1000*60*5

	blnResult = clickLink("lnkAddProduct")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	objBrowser.Page("pgShowingAddProduct").WebElement("elmQuoteItemsCount").WaitProperty "visible", "True", 1000*60*2
	
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	

	'Handle Product Operation
	If Operation = "Add Product" Then
		blnResult = clickLink("lnkAddProduct")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	ElseIf  Operation = "Migrate Product" Then
		blnResult = clickLink("lnkMigrateProduct")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Invalid Operation", "Invalid Operation Specified in Execution Sheet", Operation & " - is unhandled", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Wait 5
	
	For intCounter = 1 To 2
		If objBrowser.Page("pgShowingAddProduct").WebElement("elmQuoteItemsCount").Exist(60) Then Exit For
	Next '#intCounter

	blnResult = objPage.WebElement("elmQuoteItemsCount").Exist(5)
	If blnResult Then
		strText = GetWebElementText("elmQuoteItemsCount")
		If Right(Trim(strText),1) = "0" Then
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is displayed correctly as - "&strText,"PASS","")
		Else
			Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 0","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL","True")
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	'	'Select  Product Family
	'	blnResult = selectValueFromPageList("lstProductFamily", ProductFamily)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'
	'	'Select  Product Category
	'	blnResult = selectValueFromPageList("lstProductVariant", ProductCategory)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	'
	'	'Select product offering
	'	blnResult = selectValueFromPageList("lstProductOffering", Product)
	'		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Function Call to select Product from dropdown
	Setting.WebPackage("ReplayType") = 2 'Mouse Mode
	Call fn_SQE_SelectProductFamilyVariantOffering(ProductFamily, ProductCategory, Product)
		If Not Environment("Action_Result") Then Exit Function
	Setting.WebPackage("ReplayType") = 1 'Event Mode

	'Click on Specific Button based on Operation Type
	If Operation = "Add Product" Then
		For intCounter = 1 To 5 Step 1
			If objPage.WebButton("btnAddProduct").Exist Then Exit For
		Next
		blnResult = clickButton("btnAddProduct")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	ElseIf  Operation = "Migrate Product" Then
		For intCounter = 1 To 5 Step 1
			If objPage.WebButton("btnMigrateProduct").Exist Then Exit For
		Next
		blnResult = clickButton("btnMigrateProduct")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Invalid Operation", "Invalid Operation Specified in Execution Sheet", Operation & " - is unhandled", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If

	'Check for Number of Quote Items
	For intCounter = 1 to 10
		blnResult = objPage.WebElement("elmQuoteItemsCount").Exist
		If blnResult = "True" Then
			strText = GetWebElementText("elmQuoteItemsCount")
			If Right(Trim(strText),1) = "1" Then
				Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is displayed correctly as - "&strText,"PASS","")
				Exit For
			Else
				Wait 5
			End If	
		End If
	Next

	If Right(Trim(strText),1) = "0" Then
		Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL","True")
		Environment("Action_Result") = False : Exit Function
	End If

	'Click on Continue to Quote details
	blnResult = objPage.Link("lnkContinue2QuoteOption").Exist
	If blnResult Then
		blnResult = clickLink("lnkContinue2QuoteOption")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Click on Link Continue To Quote Details","User should be able to click on Continue To Quote Details","User is not able to click on Continue To Quote Details","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").WaitProperty("height", micGreaterThan(0), 1000*60*5)
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	Call fn_SQE_CheckMigration(QuoteID)
	If Not Environment("Action_Result") Then Exit Function
	
End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************

Public Function fn_SQE_CheckMigration(QuoteID)
	objBrowser.fSync
	'Check whether the table has been populated or not
	For intCounter = 1 to 5
		blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").Exist(60)
		If blnResult Then
			If Browser("brwSalesQuoteEngine").Page("pgShowingQuoteOption").WebTable("tblProductLineItems").GetROProperty("height") > 0 Then Exit For
		End If
	Next
	
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
		
	blnResult = clickLink("lnkQuoteOptions")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	objBrowser.fSync
	For intCounter = 1 to 5
		blnResult = Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct").Exist(60)
		If blnResult Then Exit For
	Next
	
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	'Set innertext for Quote ID
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = QuoteID & "-0"
	odesc("html tag").value = "TD"

	For intCounter = 1 to 10
		Set objElm = objPage.ChildObjects(oDesc)
		If objElm.Count >= 1 Then
			Set elmMigration = objPage.WebElement("class:=migrationQuote","html tag:=TD", "index:=0")
			If Not elmMigration.Exist(10) Then
				Call ReportLog("Check Migration Flag", "Migration Flag should be set to <B>Yes</B>", "Migration Flag is not visible in Application", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			strMIgration = Trim(elmMigration.GetROProperty("innerText"))
			If StrComp(strMIgration, "Yes", vbTextCompare) = 0 Then
				Call ReportLog("Check Migration Flag", "Migration Flag should be set to <B>Yes</B>", "Migration Flag is found to be <B>" + strMIgration + "</B>", "True", True)
			Else
				Call ReportLog("Check Migration Flag", "Migration Flag should be set to <B>Yes</B>", "Migration Flag is found to be <B>" + strMIgration + "</B>", "FAIL", True)
			End If			
			objElm(0).Click
			objBrowser.fSync
			Exit For
		Else
			Wait 10
		End IF
	Next

	If objElm.Count = 0 Then
		Call ReportLog("Quote Id","User should be able to click on Quote Id","Quote ID does not exist on page","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	blnResult = objBrowser.Page("pgShowingQuoteOption").Link("lnkConfigureProduct").WaitProperty("height", micGreaterThan(0), 1000*60*5)
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
End Function
