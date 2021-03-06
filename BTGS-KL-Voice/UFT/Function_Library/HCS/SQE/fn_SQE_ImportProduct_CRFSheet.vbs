Public Function fn_SQE_ImportProduct_CRFSheet(ByVal ProductName, ByVal FileLocation)
	Dim blnResult, blnRefresh
	Dim strRFOLocation, strConfigureStatus
	Dim intRow, intCounter, intConfiguredCol, intPricingStatusCol
	Dim objCheckBox, objFso

	strRFOLocation = FileLocation
	On Error Resume Next
		'Function to set the browser and page objects by passing the respective logical names
		blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

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
		
		arrColumns = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
		For intCounter = 0 To UBound(arrColumns) Step 1
			If Trim(arrColumns(intCounter)) = "Configured" Then
				intConfiguredCol = intCounter + 1
			ElseIf Trim(arrColumns(intCounter)) = "Pricing Status" Then
				intPricingStatusCol = intCounter + 1
			End If
		Next '#intCounter
		
		'Search with ProdName and Click on CheckBox
		intRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(ProductName)
		If intRow <=0 Then
			Call ReportLog("Product Check", "WebTable with Product Name should be loaded", "WebTable with Product Name: <B>" & ProductName & "</B> is not present", "PASS", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		Set objCheckBox = objPage.WebTable("tblProductLineItems").ChildItem(intRow, 1, "WebCheckBox", 0)
		objCheckBox.Set "ON"

		'Check whether Link Import Order is visible or not
		If objPage.Link("innertext:=Import Product").GetROProperty("height") <= 0 Then
			Call ReportLog("CheckBox Product", "WebCheckBox should be clicked", "Unable to click on CheckBox", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		Else
			blnResult = clickLink("lnkImportProduct")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If

		'Create file system object   
		Set objFso = CreateObject("Scripting.FileSystemObject")

		'Check file is exist or not
		If objFso.FileExists(FileLocation) Then
			Call ReportLog("CRF Sheet Upload","CRF Sheet should exist in the location - " & strRFOLocation, "CRF Sheet exists in the location - " & FileLocation, "PASS", False)
		Else
			Call ReportLog("CRF Sheet Upload","CRF Sheet should exist in the location - " & strRFOLocation, "CRF Sheet does not exist in the location - " & FileLocation, "FAIL", False)
			Environment.Value("Action_Result") = False  
			Exit Function
		End If

		'If objPage.Webfile("wfBrowseFile").Exist Then
		'	objPage.Webfile("wfBrowseFile").Set FileLocation : Wait 5
		'Else
		'	Call ReportLog("Browse Button", "Browse button should be clicked", "Browse button is not clickable", "FAIL", True)
		'End If
		
		If objPage.Webfile("wfBrowseFile").Exist Then
			objPage.Webfile("wfBrowseFile").Click
			For intCounter = 1 To 5
				If objBrowser.Dialog("dlgChooseFile2Upload").WinComboBox("cmbFileName").Exist Then
					objBrowser.Dialog("dlgChooseFile2Upload").WinComboBox("cmbFileName").HighLight
					objBrowser.Dialog("dlgChooseFile2Upload").WinComboBox("cmbFileName").Click
					Wait 1
					'objBrowser.Dialog("dlgChooseFile2Upload").WinComboBox("cmbFileName").Select strRFOLocation
					CreateObject("WScript.Shell").SendKeys strRFOLocation : Wait 2
					objBrowser.Dialog("dlgChooseFile2Upload").WinButton("btnOpen").Click : Wait 5
					Exit For '#intCounter
				End If
			Next '#intCounter
		Else
			Call ReportLog("Browse Button", "Browse button should be clicked", "Browse button is not clickable", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If

		'Check for upload option
		For intCounter = 1 to 10
			blnResult = objPage.WebButton("btnUpload").Exist
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
			Call ReportLog("Upload CRF","CRF Sheet should be uploaded","CRF Sheet Upload Failed","FAIL", True)
			objBrowser.Close : Exit Function
		Else
			strRetrievedText = GetWebElementText("elmImportProduct")
			Call ReportLog("Import CRF Sheet", "Import CRF Sheet should be initialized", strRetrievedText, "PASS", True)
		End If

		blnResult = clickButton("btnClose")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'If Page displays upload initialized
		If blnRefresh Then
			objBrowser.HighLight : CreateObject("WScript.Shell").SendKeys "{F5}"
			objPage.Sync
			Wait 10
		End If
		
		blnValid = False
		'Check if Product Configured is valid or not
		If objPage.WebTable("tblProductLineItems").Exist(60) Then
			For intCounter = 1 to 20
				strConfigureStatus = Trim(ObjPage.WebTable("tblProductLineItems").GetCellData(intRow, intConfiguredCol))
				If  strConfigureStatus = "VALID" Then
					blnValid = True
					Call ReportLog("BCM Product Configuration","BCM Product Configuration status should be 'Valid'","BCM Product Configuration status is - "&strConfigureStatus,"PASS", "True")
					Exit For
				ElseIf strConfigureStatus = "" Then
					Wait 60
				Else
					'objBrowser.HighLight : CreateObject("WScript.Shell").SendKeys "{F5}"
					'objPage.Sync
					objBrowser.fRefresh
					objBrowser.Sync
					Wait 10
					objPage.WebTable("tblProductLineItems").WaitProperty "height", micGreaterThan(0), 1000*60*3
				End If
			Next
		End If

		If Not blnValid Then
			Call ReportLog("CRF Product Configuration","CRF Product Configuration status should be 'Valid'","CRF Product Configuration status is - "& strCocnfigureStatus,"FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		If ProductName <> "Active Directory Integration" Then
			blnFirm = False
			'Check if Product Configured is Firm or not
			If objPage.WebTable("tblProductLineItems").Exist(4) Then
				For intCnter = 1 to 20
					objPage.WebTable("tblProductLineItems").RefreshObject
					strFirm = UCase(objPage.WebTable("tblProductLineItems").GetCellData(intRow, intPricingStatusCol))
					If  strFirm = Trim("FIRM")Then
						Call ReportLog("CRF Product Configuration","CRF Product Pricing status should be Firm'","CRF Product Pricing Status is - " & strFirm, "PASS", True)
						blnFirm = True
						Exit For
					Else
						'objBrowser.HighLight : CreateObject("WScript.Shell").SendKeys "{F5}"
						'objPage.Sync
						objBrowser.fRefresh
						objBrowser.fSync
						Wait 15
					End If
				Next
			End If
	
			If Not blnFirm Then
				Call ReportLog("CRF Product Configuration","CRF Product Pricing status should be Firm'","CRF Product Pricing Status is - " & strFirm, "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			End If
	
			'Click on Pricing Link
			blnResult = clickLink("lnkPricing")
			If Not blnResult Then
				Environment("Action_Result") = False
				Exit Function
			End If
	
			For intCounter = 1 to 10
				blnResult = objPage.WebElement("elmStandardPricing").Exist
				If blnResult Then
					Wait 2
					Call ReportLog("Capture Pricing","Standard Pricing Page is to captured'","Standard Pricing Page is captured", "INFORMATION", True)
					Wait 2
					Exit For
				End If
			Next
	
			For intCounter = 1 to 10
				blnResult = objPage.WebTable("tblStandardPricingTab").Exist(30)
				If blnResult Then
					Call ReportLog("Capture Pricing","Standard Pricing Page is to captured'","Standard Pricing Page is captured", "INFORMATION", True)
					Exit For
				End If
			Next
			
			'Click on Details Link
			blnResult = clickLink("lnkDetails")
			If Not blnResult Then
				Environment("Action_Result") = False
				Exit Function
			Else
				Wait 10
			End If
	
			blnValid = False
			'Check if Product Configured is valid or not
			If objPage.WebTable("tblProductLineItems").Exist(60) Then
				For intCnter = 1 to 20
					objPage.WebTable("tblProductLineItems").RefreshObject
					strConfigureStatus = objPage.WebTable("tblProductLineItems").GetCellData(intRow, intConfiguredCol)
					If  strConfigureStatus = Trim("VALID")Then
						Call ReportLog("CRF Product Configuration","CRF Product Configuration status should be 'Valid'","CRF Product Configuration status is - "& strConfigureStatus,"PASS","True")
						blnValid = True
						Exit For
					Else
						Wait 15
					End If
				Next
			End If
	
			If Not blnValid Then
				Call ReportLog("CRF Product Configuration","CRF Product Configuration status should be 'Valid'","CRF Product Configuration status is - "& strConfigureStatus,"FAIL","True")
				Environment("Action_Result") = False
				Exit Function
			End If
	
			blnFirm = False
			'Check if Product Configured is Firm or not
			If objPage.WebTable("tblProductLineItems").Exist(60) Then
				For intCnter = 1 to 20
					objPage.WebTable("tblProductLineItems").RefreshObject
					strFirm = UCase(objPage.WebTable("tblProductLineItems").GetCellData(intRow, intPricingStatusCol))
					If  strFirm = Trim("FIRM")Then
						Call ReportLog("CRF Product Configuration","CRF Product Pricing status should be Firm'","CRF Product Pricing Status is - " & strFirm, "PASS", True)
						blnFirm = True
						Exit For
					Else
						Wait 15
					End If
				Next
			End If
	
			If Not blnFirm Then
				Call ReportLog("CRF Product Configuration","CRF Product Pricing status should be Firm'","CRF Product Pricing Status is - " & strFirm, "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			Else
				Environment("Action_Result") = True
			End If
		End If

		Environment("Action_Result") = True
End Function
