'****************************************************************************************************************************
' Function Name 		:		fn_SQE_AddProducts_Modify_Soft_Changes
' Purpose				: 		Function to Add Products to the Quote
' Author				:	Anil Pal
' Creation Date  		 : 			  04/7/2014
' Modified By			: Nagaraj V || 26/08/2015 || Indentation, Removal of unwanted LOC
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_AddProducts_Modify_Soft_Changes(dQuoteID,dProductCategory,dProduct,dProductFamily,dCountry,dsiteID)

   	'Declaration of variables
	Dim strQuoteID,strProductCategory
	Dim objMsg, objElmProcessing
	Dim blnResult
	Dim intCounter

	'Assigningof values to variables
	strQuoteID = dQuoteID
	strProductCategory = dProductCategory
	strProduct = dProduct
	strProductFamily = dProductFamily
	strsiteID = dsiteID

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

	'Set innertext for Quote ID
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = strQuoteID &"-0"
	odesc("html tag").value = "TD"

	For intCounter = 1 to 10
		Set objElm = objPage.ChildObjects(oDesc)
		If objElm.Count = 1 Then
			Wait 3
			objElm(0).Click
			Exit For
		Else
			Wait 10
		End IF
	Next

	'Check if navigated to Quote Details page.
	 If objPage.Link("lnkAddProduct").Exist Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking on Quote ID","User is Navigated to the Quote Details page ","PASS","")
		blnResult = ClickLink("lnkAddProduct")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Details page on clicking  on Quote ID","User is not navigated to the Quote Details page ","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function		
	End If

	'Click on Add Products
	blnResult = clickLink("lnkRemoveModifyProduct")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
	
	'Wait for Lsit Product Family os Loaded or Not
	objPage.WebList("lstProductFamily").WaitProperty "visible", "True", 10000*6*3
	
	'Select  Product Family
	blnResult = selectValueFromPageList("lstProductFamily", dProductFamily)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Select  Product Category
	blnResult = selectValueFromPageList("lstProductCategory", dProductCategory)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Select product offering
	blnResult = selectValueFromPageList("lstproduct", dProduct)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Select Country
	index = -1
	arrItems = Split(objPage.WebList("lstCountryFilter").GetROProperty("all items"), ";")
	For iCounter = 0 to UBound(arrItems)
		If arrItems(iCounter) = dCountry Then
			index = iCounter
			Exit For
		End If
	Next

	blnResult = objPage.WebList("lstCountryFilter").Exist
	If blnResult Then
		objPage.WebEdit("class:=select2-input select2.*", "name:=WebEdit", "index:=0").Click		
		If objPage.WebList("lstCountryFilter").GetROProperty("value") = "" Then
			index = index + 1
		End If
		Set ObjShell = CreateObject("Wscript.Shell")
		For iCounter = 1 to index - 1
			ObjShell.SendKeys "{DOWN}"
			Wait 1
		Next
		Call ReportLog("Select Country","User should be able to select Country","User is able to select value for Country","PASS","True")
		ObjShell.SendKeys "{ENTER}"
	Else
		Call ReportLog("Select Country","User should be able to select Country","User is not able to select value for Country","FAIL","True")
		Environment.Value("Action_Result") = False  
		
		Exit Function
	End If
	Set oShell = Nothing
	
	Wait 5
	Set objElmProcessing = objPage.WebElement("html id:=siteTable_processing","innertext:=Processing.*", "index:=0")
	If objElmProcessing.WaitProperty("height", micGreaterThan(0), 10000*6*2) Then
		objElmProcessing.WaitProperty "visible", "False", 10000*6*5
	End If
	
	'For selecting the check box for TR
	If objPage.WebTable("tblsite").Exist(10) Then
		objPage.WebTable("tblsite").HighLight
		Wait(2)
		lstCountrystrRowcnt = objPage.WebTable("tblsite").RowCount
		For iTeratorrow = 1 to lstCountrystrRowcnt
			strCellValue = objPage.WebTable("tblsite").GetCellData(iTeratorrow,2)
			If Trim(strCellValue) = Trim(strsiteID) Then
				Set ocheckbox =objPage.WebTable("tblsite").ChildItem(iTeratorrow,1,"WebCheckBox",0)
				ocheckbox.Click
				Exit For
			End If
		Next
	End If

	'Click on Add Product WebButton
	blnResult = objPage.WebButton("btnAddProduct").Exist
	If blnResult = "True" Then
		blnResult = clickButton("btnAddProduct")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else
		Call ReportLog("Click on Add Product","User should be able to click on Add Product","User is not able to click on AddProduct","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
	Wait 5

	'Check for Number of Quote Items
	For intCounter = 1 to 10
		blnResult = objPage.WebElement("webElmNumberOfQuoteItems").Exist
		If blnResult = "True" Then
			strText = GetWebElementText("webElmNumberOfQuoteItems")
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
	blnResult = objPage.Link("lnkContinueToQuoteDetails").Exist
	If blnResult Then
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

	For intCounter = 1 to 10 
		If objPage.WebTable("webTblItems").Exist(10) Then
			blnExist = True
			Exit For 
		Else
			Wait(5)
		End If
	Next

	If blnExist Then
		lstCountrystrRowcnt = objPage.WebTable("webTblItems").RowCount
		For iTeratorrow = 1 to lstCountrystrRowcnt
			strCellValue = objPage.WebTable("webTblItems").GetCellData(iTeratorrow,2)
			If strCellValue = strsiteID Then
				Set ocheckbox =objPage.WebTable("webTblItems").ChildItem(iTeratorrow,1,"WebCheckBox",0)
				ocheckbox.Click
				Exit For
			End If
		Next
	End If

	blnResult = objPage.Link("lnkConfigureProduct").Exist
	If Not blnResult Then
		Call ReportLog("Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link should be visible and enabled upon clicking Continue To Quote Details","Configure Product link is not visible/enabled as expected","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
