'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ImportBCMWorkBook
' Purpose				: 		Function to Upload BCM Sheet
' Author				:		Nagaraj/Anil Pal
' Creation Date  		: 		18/12/2014					     
' Return Values	 		: 		Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_ImportBCMWorkBook(ByVal dProductName, ByVal dFileLocation)
	
	'Variable Declaration
	Dim blnResult, blnRefresh
	Dim strRFOLocation
	Dim strConfigureStatus
	Dim objCheckBox, objFSO
	Dim intCounter, intConfiguredCol, intPricingStatusCol, intProdRow
	Dim arrColumns
	
	'Initilization	
	strRFOLocation = dFileLocation
	
	'Create file system object   
	Set objFSO = CreateObject("Scripting.FileSystemObject")
			
	'Check file is exist or not
	If objFSO.FileExists(strRFOLocation) Then
		Call ReportLog("BCM Sheet","BCM Sheet should exist in the location - "&strRFOLocation,"BCM Sheet exists in the location - " & strRFOLocation,"PASS", False)
		Set objFSO = Nothing
	Else
		Call ReportLog("BCM Sheet","BCM Sheet should exist in the location - "&strRFOLocation,"BCM Sheet does not exist in the location - "&strRFOLocation,"FAIL", False)
		Set objFSO = Nothing
		Environment.Value("Action_Result") = False : Exit Function
	End If
	
	On Error Resume Next
		'Function to set the browser and page objects by passing the respective logical names
		blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		arrColumns = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
		For intCounter = 0 To UBound(arrColumns) Step 1
			If Trim(arrColumns(intCounter)) = "Configured" Then
				intConfiguredCol = intCounter + 1
			ElseIf Trim(arrColumns(intCounter)) = "Pricing Status" Then
				intPricingStatusCol = intCounter + 1
			End If
		Next '#intCounter

		'Check if WebTable with Exists or not
		objPage.WebTable("tblProductLineItems").RefreshObject
		blnResult = objPage.WebTable("tblProductLineItems").Exist
		If blnResult Then
			Call ReportLog("Check TableItems", "WebTable with Product Summary should be displayed", "WebTable with Product Summary is displayed", "PASS", True)
		Else
			Call ReportLog("Check TableItems", "WebTable with Product Summary should be displayed", "WebTable with Product Summary is not displayed", "FAIL", True)
			Environment("Action_Result") = True
			Exit Function
		End If

		'Search with ProdName and Click on CheckBox
		intRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(dProductName)
		If intRow <= 0 Then
			Call ReportLog("Product Check", "WebTable with Product Name should be loaded", "WebTable with Product Name: <B>" & dProductName & "</B> is not present", "PASS", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		Set objCheckBox = objPage.WebTable("tblProductLineItems").ChildItem(intRow, 1, "WebCheckBox", 0)
		objCheckBox.Set "ON"

		'Check whether Link Import Order is visible or not
		If objPage.Link("innertext:=Import Product", "visible:=True").Exist(60) Then
			If objPage.Link("innertext:=Import Product").GetROProperty("height") <= 0 Then
				Call ReportLog("CheckBox Product", "WebCheckBox should be clicked", "Unable to click on CheckBox", "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			Else
				blnResult = clickLink("lnkImportProduct")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
		Else
			Call ReportLog("CheckBox Product", "WebCheckBox should be clicked", "Unable to click on CheckBox", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If
			
		If objPage.Webfile("wfBrowseFile").Exist(60) Then
			'Below object has been disabled - in Observation R44
			'objPage.Webfile("wfBrowseFile").Set strRFOLocation : Wait 10
			objPage.Webfile("wfBrowseFile").Click
			Call fn_SQE_HandleDialogChooseFileToUpload(strRFOLocation)
				If Not Environment("Action_Result") Then Exit Function			
		Else
			Call ReportLog("Browse Button", "Browse button should be clicked", "Browse button is not clickable", "FAIL", True)
		End If
	
		'Check for upload option
		For intCounter = 1 to 10
			blnResult = objPage.WebButton("btnUpload").Exist(30)
			If blnResult Then
				blnResult = clickButton("btnUpload")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Exit For
			Else
				Wait 5
			End If
		Next
	
		If Not blnResult Then
			Call ReportLog("Upload button","Upload button should exist","Upload button does not exist","FAIL","True")
			Environment.Value("Action_Result") = False : Exit Function
		End If

		blnRefresh = False

		'Check if Upload has been initialized or not
		blnRefresh = objPage.WebElement("elmImportProduct").WaitProperty("height", micGreaterThan(0), 1000*60*3)

		If Not blnRefresh Then
			Call ReportLog("Upload BCM","BCM Sheet should be uploaded","BCM Sheet Upload Failed","FAIL", True)
			objBrowser.Close : Exit Function
		Else
			strRetrievedText = GetWebElementText("elmImportProduct")
			Call ReportLog("Import BCM Sheet", "Import BCM Sheet should be initialized", strRetrievedText, "PASS", True)
		End If
		
		blnResult = clickButton("btnClose")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'If Page displays upload initialized
		If blnRefresh Then
			Wait 10
			objBrowser.fRefresh
			objPage.Sync
			Wait 10
		End If

		objPage.WebTable("tblProductLineItems").WaitProperty "height", micGreaterThan(0), 1000*60*3
		
		If objPage.WebTable("tblProductLineItems").Exist(60) Then		
			For intCounter = 1 to 10
				strConfigureStatus = Trim(ObjPage.WebTable("tblProductLineItems").GetCellData(intRow, intConfiguredCol))
				If  strConfigureStatus = "VALID" Then
					Call ReportLog("BCM Product Configuration","BCM Product Configuration status should be 'Valid'","BCM Product Configuration status is - "&strConfigureStatus,"PASS", "True")
					Exit For
				ElseIf strConfigureStatus = "" Then
					Wait 60
				Else
					objBrowser.RefreshObject
					objBrowser.fRefresh
					objPage.Sync
					Wait 10
					objPage.WebTable("tblProductLineItems").WaitProperty "height", micGreaterThan(0), 1000*60*3
				End If
			Next
		End If
		
		'Terminate if Configuration Status is INVALID
		If strConfigureStatus <> "VALID" Then
			Call ReportLog("BCM Product Configuration","BCM Product Configuration status should be 'Valid'","BCM Product Configuration status is - "&strConfigureStatus,"FAIL","True")
			Environment("Action_Result") = False  : Exit Function
		End If

		If objPage.WebTable("tblProductLineItems").Exist(4) Then
			For intCnter = 1 to 10
				strPricingStatus = Trim(ObjPage.WebTable("tblProductLineItems").GetCellData(intRow, intPricingStatusCol))
				If  strPricingStatus = "Firm" Then
					Call ReportLog("BCM Product Configuration","BCM Product Pricing status should be 'Valid'","BCM Product Pricing status is - "&strPricingStatus,"PASS", True)
					Exit For
				Else
					objBrowser.HighLight : CreateObject("WScript.Shell").SendKeys "{F5}"
					objPage.Sync
					objPage.WebTable("tblProductLineItems").WaitProperty "height", micGreaterThan(0), 1000*60*3
					Wait 10
				End If
			Next
		End If
		
		'Terminate if Pricing status is not Firm
		If strPricingStatus <> "Firm" Then
			Call ReportLog("BCM Product Configuration","BCM Product Pricing status should be 'Firm'","BCM Product Pricing status is - "&strPricingStatus,"FAIL", True)
			Environment("Action_Result") = False  : Exit Function
		End If
End Function
