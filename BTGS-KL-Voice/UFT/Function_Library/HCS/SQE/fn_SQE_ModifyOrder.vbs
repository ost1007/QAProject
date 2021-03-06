'****************************************************************************************************************************
' Function Name 		:		fn_SQE_AddProducts
'
' Purpose				: 		Function to Add Products to the Quote
'
' Author				:		Murali.T
'Modified by		  : 			
' Creation Date  		 : 			  04/7/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_ModifyOrder(dQuoteID, dProductCategory, dProduct, dProductFamily)

	'Assigningof values to variables
	strQuoteID = dQuoteID
	strProductCategory = dProductCategory
	strProduct = dProduct
	strProductFamily = dProductFamily

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Check if navigated to Quote Options Page after clicking on Additional Products Configuration link

	If objPage.Link("lnkQuoteOptions").Exist Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Additional Product's Config link","User is Navigated to the Quote Options page ","PASS","")
	Else
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Additional Product's Config link","User is not navigated to the Quote Options page ","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function		
	End If

	'Set innertext for Quote ID
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	oDesc("innertext").value = strQuoteID
	oDesc("html tag").value = "TD"

	For intCounter = 1 to 10
		Set objElm = objPage.ChildObjects(oDesc)
		If objElm.Count = 1 Then
			objElm(0).Click
			Exit For
		Else
			Wait 10
		End IF
	Next

	If objElm.Count = 0 Then
		Call ReportLog("Quote Id","User should be able to click on Quote Id","Quote ID does not exist on page","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	'Check if navigated to Quote Details page.
	 If objPage.Link("lnkAddProduct").Exist Then
			Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking on Quote ID","User is Navigated to the Quote Details page ","PASS","")
	Else
			Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking  on Quote ID","User is not navigated to the Quote Details page ","FAIL","True")
			Environment.Value("Action_Result") = False : Exit Function		
	End If

	'Click on Add Products
	blnResult = clickLink("lnkAddProduct")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Check if Adding Products is already done, by validating the disabled status for Configure Product link
	For intCounter = 1 to 20
		 blnResult = objPage.Link("lnkConfigureProduct").Exist
		If blnResult = "True" Then
			strClass = Trim(objPage.Link("lnkConfigureProduct").GetROProperty("class"))
			If strClass = "main-action" Then
				Wait 5
			ElseIf strClass = "main-action disabled" Then
				Exit For
			End If
		End If
	Next

	If strClass = "main-action" Then
		Exit Function
	End If
     
	'Clicking on RemoveModifyProduct tab
	blnResult =  ObjPage.Link("lnkRemoveModifyProduct").Exist
	If  blnResult Then
		ObjPage.Link("lnkRemoveModifyProduct").HighLight
		ObjPage.Link("lnkRemoveModifyProduct").Click
	Else
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	Wait 6
	
	'Validating the Procesing Bar
	blnResult = ObjPage.WebElement("WebElmProcessing").Exist
	If blnResult Then
		Wait 5
	End If
	
	'Select  Product Family
	blnResult = selectValueFromPageList("lstProductFamily", dProductFamily)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select  Product Category
	blnResult = selectValueFromPageList("lstProductCategory", dProductCategory)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Select product offering
	blnResult = selectValueFromPageList("lstproduct", dProduct)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Validating the Procesing Bar
	blnResult = ObjPage.WebElement("WebElmProcessing").Exist
	If blnResult Then
		Wait 5
	End If

    	'Clicking on RemoveModifyProduct tab
	blnResult =  ObjPage.WebButton("btnRemoveModifyProduct").Exist(10)
	If  blnResult Then
		ObjPage.WebButton("btnRemoveModifyProduct").HighLight
		ObjPage.WebButton("btnRemoveModifyProduct").Click
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
	Wait 6

	'Check for Number of Quote Items
	For intCounter = 1 to 10
		blnResult = objPage.WebElement("webElmNumberOfQuoteItems").Exist
		If blnResult = "True" Then
			strText = GetWebElementText("webElmNumberOfQuoteItems")
			If Right(Trim(strText),1) = "0" Then
				Call  ReportLog("Number of Quote Items","Number of Quote Items should be displayed as 1","Number of Quote Items is not displayed correctly.Instead displayed as - "&strText,"FAIL","True")
				Environment("Action_Result") = False
				Exit Function
			End If			
		End If
	Next

	'Click on Continue to Quote details
	blnResult = objPage.Link("lnkContinueToQuoteDetails").Exist(10)
	If blnResult = "True" Then
		blnResult = clickLink("lnkContinueToQuoteDetails")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else
		Call ReportLog("Click on Link Continue To Quote Details","User should be able to click on Continue To Quote Details","User is not able to click on Continue To Quote Details","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If
End Function
