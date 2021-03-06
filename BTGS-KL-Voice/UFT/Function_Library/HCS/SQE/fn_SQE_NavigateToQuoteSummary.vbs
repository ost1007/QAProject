'****************************************************************************************************************************
' Function Name 		:		fn_SQE_NavigateToQuoteSummary
' Purpose				: 		Function to Navigate To Quote Summary
' Author				:		Linta C.K.
' Creation Date  		: 		23/7/2014	
' Modified By			: 		Nagaraj V || 21-Aug-2015 || Migration to UFT Supported Controls
' Return Values	 		: 		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_NavigateToQuoteSummary(dOrderType)

   	'Declaration of variables
	Dim blnResult
	Dim strOrderType
	Dim objWebTable, objLoaderImage, objList
	Dim index, iCounter, intLinkCount

	'Assigningof values to variables
	strOrderType = dOrderType

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwIPSDKProductBundling","pgIPSDKProductBundling","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Check for Ajax Loading Image
	Set objLoaderImage = objPage.Image("file name:=ajax-loader\.gif")
	For iCounter = 1 to 2
		If objLoaderImage.Exist(5) Then
			If objLoaderImage.GetROProperty("height") = 0 Then	
				Exit For '#iCounter
			Else
				Wait 30
			End If
		Else
			Exit For '#iCounter
		End If
	Next
	
	'Check Whether table has been loaded or not
	Set objWebTable = objPage.WebTable("webTblMasterQuote")
	If Not objWebTable.Exist(20) Then
		Call ReportLog("WebTable - Product Selection", "Product Selection WebTable should be Loaded", "Product Selection WebTable is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Check whether Additional Product is loaded or not
	intProductRow = objPage.WebTable("webTblMasterQuote").GetRowWithCellText("Additional Product")
	If intProductRow <= 0 Then
		Call ReportLog("WebTable - Product Selection", "Product Selection WebTable should be Loaded with Additional Product", "Product Selection WebTable is not loaded with Additional Product Field", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	Set oWebChkBox  = objPage.WebTable("webTblMasterQuote").ChildItem(intProductRow, 1, "WebCheckBox", 0)
	If oWebChkBox.Exist(0) Then
		If oWebChkBox.GetROProperty("height") <> 0 Then
			oWebChkBox.Set "ON"
			Set objList = objPage.WebTable("webTblMasterQuote").ChildItem(intProductRow, 3, "WebList", 0)
			
			'Select the Order Type
			objList.Select strOrderType
		
			'Click on Add To Master Quote
			If objPage.WebButton("btnAddProduct2Quote").Exist Then
				blnResult = clickButton("btnAddProduct2Quote")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If
		
			'Check whether product configuration has been saved successfully or not
			For intCounter = 1 to 3
				blnResult = objPage.WebElement("innertext:=Product\(s\) saved success.*", "index:=0").Exist(60)
				If blnResult Then	
					Call ReportLog("Product Bundling", "Product should be saved successfully", "Add Product to Quote was successful", "PASS", True)
					Exit For '#intCounter
				End If
			Next '#intCounter
		
			If Not blnResult Then
				Call ReportLog("Product Bundling", "Product should be saved successfully", "Add Product to Quote was unsuccessful", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
		End If
	End If
	
	objPage.WebTable("webTblMasterQuote").RefreshObject

	'Get Whether Link is Populated or not after adding Product to Quote
	intLinkCount = objPage.WebTable("webTblMasterQuote").ChildItemCount(intProductRow, 3, "Link")
	If intLinkCount = 0 Then
		Call ReportLog("Product Bundling", "Product should be saved successfully and link should be enabled to navigate to SQE", "Product should be saved successfully and link should is not visible to navigate to SQE", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Product Bundling", "Product should be saved successfully and link should be enabled to navigate to SQE", "Product should be saved successfully and link should is visible to navigate to SQE", "PASS", True)
	End If

	'Click on Order type to navigate to Quote Summary
	Set objTable = objPage.WebTable("webTblMasterQuote")
	Set objLink = objTable.ChildItem(intProductRow, 3, "Link", 0)

	If IsObject(objLink) Then
		If objLink.Exist(0) AND objLink.GetROProperty("height") = 0 Then
			Call ReportLog("SQE Landing Page", "Configuration Link should be present to navigate to Quote Option Details Page", "Configuration Link is not present to navigate to Quote Option Details Page", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			objLink.Click
		End If
	End If
	
	'Loop to Navigate to Customer Project Page
	For iCounter = 1 To 5 Step 1
		If Browser("brwSalesQuoteEngine").Page("pgShowingAddProduct").Exist Then Exit For
	Next
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingAddProduct","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	'Check if navigated to Quote Options Page after clicking on Order Type Link
	If objPage.Link("lnkQuoteOptions").Exist Then
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Order Type Link","User is Navigated to the Quote Options page ","PASS","")
		Environment.Value("Action_Result") = True
	Else
		Call ReportLog("SQE Navigation","User should be able to navigate to Quote Options page on clicking Order Type Link","User is not navigated to the Quote Options page ","FAIL","True")
		Environment.Value("Action_Result") = False
		Exit Function
	End If
End Function
'===================================================================================================================================





'=============== QTP WorkAround ==============
	'index = -1
	'arrItems = Split(objList.GetROProperty("all items"), ";")
	'For iCounter = 0 to UBound(arrItems)
	'	If arrItems(iCounter) = strOrderType Then
	'		index = iCounter
	'		Exit For
	'	End If
	'Next

	'blnResult = objList.Exist
	'If blnResult = "True" Then
	'	objList.HighLight
	'	objList.Click
	'	Set ObjShell = CreateObject("Wscript.Shell")
	'	For iCounter = 1 to index
	'		ObjShell.SendKeys "{DOWN}"
	'		Wait 1
	'	Next
	'	Wait 3
	'	Set ObjShell = Nothing
	'Else
    '  	Call ReportLog("Select Product Family","User should be able to select Product Family","User is able to select value for Product Family","FAIL","True")
	'	Environment.Value("Action_Result") = False : Exit Function
	'End If

	

	'Select strOrderType

'=================================================== Interface Change in T1 =======================================================
'''''''''''	'Select Product as Additional Product
'	If objPage.WebList("lstProduct").Exist Then
'''		Wait 2
'          	blnResult = selectValueFromPageList("lstProduct","Additional Product")
'			Wait 1
'			If Not blnResult Then
'				Environment.Value("Action_Result") = False  
'				Call EndReport()
'				Exit Function
'			End If
'    End If

''''''''	''Select Order Type
'	If objPage.WebList("lstOrderType").Exist Then
''		Wait 2
'		blnResult = selectValueFromPageList("lstOrderType",strOrderType)
'		Wait 1
'		If Not blnResult Then
'			Environment.Value("Action_Result") = False  
'			Call EndReport()
'			Exit Function
'		End If
'	End If
'===================================================================================================================================
