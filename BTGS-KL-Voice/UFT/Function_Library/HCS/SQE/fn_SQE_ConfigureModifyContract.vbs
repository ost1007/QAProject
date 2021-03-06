'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ConfigureProduct
' Purpose					: 		Function to configure Products added to the Quote
' Author					 :		 Murali T
' Modified by		  	    :		Nagaraj V || 03/03/2015
' Creation Date  		  : 		  13/02/2014
' Modified Date  		  :		
' Parameters	  	      :			                 					     
' Return Values	 	      : 			Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_ConfigureModifyContract(ByVal ProductNames, ByVal Quantities, ByVal ModifyType)

	'Declaring of variables	
	Dim iCol, iRow, iProd, intQuantityCol, intStencilCol, intRowCount, intColumnCount, intQuantityLen, intCounter
	Dim arrColumns, arrQuantity, arrProducts
	Dim strColumnName, strStencil, strQuantity, strModifyType, strInnerText
	Dim oShell
	Dim blnValid, blnConfigured, blnPricing

	arrProducts = Split(ProductNames, "|")
	arrQuantity = Split(Quantities, "|")
	strModifyType = ModifyType
    
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSalesQuoteEngine","pgShowingQuoteOption","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	If Not objPage.WebTable("tblProductTableHeader").Exist(0) Then
		Call ReportLog("Table Product", "Table Column have been changed", "Table Columns have been changed: " & objPage.WebTable("tblProductTableHeader").GetTOProperty("column names"), "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Get Column Index
	arrColumnNames = Split(objPage.WebTable("tblProductTableHeader").GetROProperty("column names"), ";")
	intProductCol = 0 : intConfiguredCol = 0 : intPricingCol = 0 : intOrderTypeCol = 0
	For intCounter = LBound(arrColumnNames) to UBound(arrColumnNames)
		If arrColumnNames(intCounter) = "Configured" Then
			intConfiguredCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Pricing Status" Then
			intPricingCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Order Type" Then
			intOrderTypeCol = intCounter + 1
		ElseIf arrColumnNames(intCounter) = "Product" Then
			intProductCol = intCounter + 1
		End If
	Next
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(2, intConfiguredCol))
		If strCellData = "VALID" Then
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as 'VALID' before bulk configuration","PASS", True)
			blnValid = True
			Exit For
		Else
			Wait 5
		End If
	Next

	'Check for Configuration Status
	If Not blnValid Then
		Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' before bulk configuration.","Configuration Status is shown as '" & strConfigured & "' before bulk configuration","FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Select All Product Line Items for Configuration
	objPage.WebCheckBox("html id:=selectAll").Set "ON"

	'Click on Configure Product
	blnResult = objPage.Link("lnkConfigureProduct").Exist(10)
	If blnResult Then
		blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else		
		Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
		Environment.Value("Action_Result") = False : Exit Function
	End If

	'Wait for the Page to be Loaded
	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgBulkConfiguration").Exist
			If blnResult Then Exit For			
	Next
	
	'Build Browser Reference
	blnResult = BuildWebReference("","pgBulkConfiguration","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
	'Click on OCC Region Pricing Scheme
	blnResult = clickWebElement("elmOCCRegionPricingScheme")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 5
	'Click on OCC Region Pricing Scheme > Rates
	blnResult = clickWebElement("elmRates")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 5	
	'Click on OCC Region Pricing Scheme > Rates > Base Configuration
	blnResult = clickWebElement("elmBaseConfig")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Wait 5
	
	'Wait for Rate Bulk Config Table to be visible
	For intCounter = 1 To 5
		blnResult = objPage.WebTable("tblPricingRateBulkConfiguration").Exist
		If blnResult Then Exit For		
	Next
	
	If Not blnResult Then
		Call ReportLog("Stencils Table", "Stencils Table under Rates>Base Configuration should be loaded", "Stencils Table under Rates>Base Configuration is not loaded", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	objPage.WebTable("tblPricingRateBulkConfiguration").RefreshObject
	intQuantityCol = -1 : intStencilCol = -1
	'Get the Column Index
	arrColumns = Split(objPage.WebTable("tblPricingRateBulkConfiguration").GetROProperty("column names"), ";")
	For iCol = 0 To UBound(arrColumns)
		strColumnName = Trim(arrColumns(iCol))
		If strColumnName = "Quantity" Then
			intQuantityCol = iCol + 1
		ElseIf InStr(1, strColumnName, "Stencil") > 0 Then
			intStencilCol = iCol + 1
		End If
	Next
	
	'Exit if Column Names have been changed
	If intStencilCol = -1 OR intQuantityCol = -1 Then
		Call ReportLog("Get Column Index", "Column under Rates>Base COnfiguration have been changed", "Column under Rates>Base COnfiguration have been changed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	intRowCount = objPage.WebTable("tblPricingRateBulkConfiguration").RowCount
	For iRow = 2  To intRowCount
		intColumnCount = objPage.WebTable("tblPricingRateBulkConfiguration").ColumnCount(iRow)
		If intColumnCount > 1 Then
			strCellData = Split(objPage.WebTable("tblPricingRateBulkConfiguration").GetCellData(iRow, intStencilCol), "(quote)")
			For iProd = 0 To UBound(arrProducts)
				strStencil = Trim(arrProducts(iProd))
				strQuantity = Trim(arrQuantity(iProd))
				If Trim(strCellData(0)) = strStencil Then
					intQuantityLen = Len(Cstr(objPage.WebTable("tblPricingRateBulkConfiguration").GetCellData(iRow, intQuantityCol)))
					Set oShell = CreateObject("Wscript.Shell")
					For iDelCntr = 1 to intQuantityLen
						objPage.WebTable("tblPricingRateBulkConfiguration").ChildItem(iRow, intQuantityCol, "WebElement", 0).click
						oShell.SendKeys "{DELETE}"
					Next
					objPage.WebTable("tblPricingRateBulkConfiguration").ChildItem(iRow, intQuantityCol, "WebElement", 0).click
					oShell.SendKeys strQuantity
					objPage.WebTable("tblPricingRateBulkConfiguration").ChildItem(iRow, intQuantityCol, "WebElement", 0).click
					Exit For '#iProd
				End If
			Next '#iProd
		End If '#intColumnCount
	Next '#iRow

	Wait 3

	'Click on Trunk Group OCC
	blnResult = clickWebElement("elmTrunkGroupOCC")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Wait until Number of outstanding saves status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Number of outstanding saves: \d+", "index:=0").Exist(5) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
	'Click on Trunk OCC under Trunk Group - OCC > Trunk - OCC
	blnResult = clickWebElement("elmTrunkOCC")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Call ReportLog("Trunk OCC", "Capture Trunk OCC State", "Capture Trunk OCC State", "Information", True)

	'Modified By  --- Nagaraj V
	'If Cstr(strModifyType)="DECREASE" Then
	'	'objPage.WebElement("webElmTrunkGroupOCC").Click : wait 4
	'	objPage.webelement("webElmTrunkOCC").Click : wait 4
	'	objPage.WebElement("webElmBaseConfigUnderTruckOCC").Click : wait 4
	'
	'	'Check for the Row whose Action is None and Delete that Asset 
	'	Set objTrunkTable = objPage.WebTable("innertext:=FilterBulkStatusAction.*","html tag:=TABLE")
	'
	'	intRows = objTrunkTable.GetROProperty("rows")
	'	For iRow = 1 to intRows
	'		strCellData = LCase(Trim(objTrunkTable.GetCellData(iRow, 3)))
	'		If strCellData = "none" Then
	'			objTrunkTable.ChildItem(iRow, 1, "WebCheckBox", 0).Set "ON"
	'			Exit For
	'		End If
	'	Next
	'
	'	'Click on Delete Asset Button
	'	blnResult = clickbutton("btnDeleteAsset")
	'		If Not Environment("Action_Result") Then Environment("Action_Result") = False : Exit Function
	'
	'	Wait 3
	'	'Wait until Performing deleting status is not visible
	'	For intCounter = 1 to 25
	'		If objPage.WebElement("innertext:=Performing deleting.*", "index:=0").Exist(5) Then	
	'			Wait 15
	'		Else
	'			Exit For
	'		End If
	'	Next
	'
	'	'Get the webElement and check for Delete Properties
	'	Set objTableItem = objPage.WebTable("innertext:=FilterBulkStatusAction.*","html tag:=TABLE").ChildItem(iRow,3,"WebElement",0)
	'
	'	Dim oDesc : Set oDesc = Description.Create
	'	oDesc("micclass").Value = "WebElement" : oDesc("innertext").Value = "Delete"
	'
	'	Set objElesDelete = objTableItem.ChildObjects(oDesc)
	'
	'	If objElesDelete.Count < 0 Then
	'		Call ReportLog("Asset Deletion", "Asset should be deleted", "Asset deletion was unsuccessfull", "FAIL", True)
	'		Environment("Action_Result") = False : Exit Function
	'	End If
	'
	'	Set objEleDelete = objElesDelete(objElesDelete.Count - 1)
	'	strColor = objEleDelete.Object.currentStyle.color
	'	strStrike = objEleDelete.Object.currentStyle.textDecoration
	'	
	'	If strColor = "red" AND strStrike = "line-through" Then
	'		Call ReportLog("Check Delete Props", "Deleted item should be in red colo and text decoration should be striked", "Color found <B> " & strColor & " </B> Text Decoration is found to be <B> " & strStrike & "</B>", "PASS", True)
	'	Else
	'		Call ReportLog("Check Delete Props", "Deleted item should be in red colo and text decoration should be striked", "Color found <B> " & strColor & " </B> Text Decoration is found to be <B> " & strStrike & "</B>", "FAIL", True)
	'		Environment("Action_Result") = False : Exit Function
	'	End If
	'End If

	'Modified by ---- Nagaraj V
	If Cstr(strModifyType) = "INCREASE" Then
		If objPage.WebElement("elmTrunkOCCCount").Exist Then
			strTrunkColor = objPage.WebElement("elmTrunkOCCCount").Object.currentStyle.backgroundColor
			If strTrunkColor = "#ffff00" Then
				Call ReportLog("Check BG Color", "BG Color should be changed to yellow", "BG Color is changed to yellow and found to be " & strTrunkColor, "PASS", True)
				strInnerText = Trim(objPage.WebElement("elmTrunkOCCCount").GetROProperty("innertext"))
				objPage.WebElement("html tag:=A", "innertext:=" & strInnerText, "index:=0").Click : Wait 5
				'Add Trunk - OCC till the list is disabled for selection
				Do
					objPage.WebList("Link2New").RefreshObject
					'Select Trunk OCC
					blnResult = selectValueFromPageList("Link2New", "Trunk - OCC")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					
					'Click on Add Button
					blnResult = clickButton("btnAdd")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Wait 5

					objPage.WebList("Link2New").RefreshObject
					isDisabled = objPage.WebList("Link2New").Object.disabled
				Loop While (Not isDisabled)
				
				'Click on Add Button
				blnResult = clickButton("btnOk")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
		End If
	End If
	
	
	objPage.WebElement("elmModifyBaseConfiguration").Click : Wait 10

	''Build Web Reference
	'blnResult = BuildWebReference("brwBulkConfiguration","pgBulkConfiguration","")
	'	If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	'
	''Click on Base Configuration
	'objPage.WebElement("elmModifyBaseConfiguration").Click
	'
	'Wait 2
	'
	''Select Checkbox for Pricing
	'Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty1").RefreshObject
	'Set oWebElmChild = 	Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebTable("webTblBaseConfigQty1").ChildItem(1,1,"WebCheckBox",0)
	'oWebElmChild.Click
	'
	'blnResult = clickbutton("btnPrice")
	'	If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	'
	'For intCounter = 1 to 20
	'	If objPage.WebElement("class:=status-bar","innertext:=Performing pricing","visible:=True", "index:=0").Exist(5) Then
	'		Wait 20
	'	Else
	'		Exit For
	'	End If
	'Next
	'
	''Build Web Reference
	'blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
	'	If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	'
	''Check whether Pricing is FIrmed or not
	'If objPage.WebTable("webTblBaseConfigQty1").GetRowWithCellText("Firm") < 0 Then
	'	Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done", "FAIL", True)
	'	Environment("Action_Result") = False
	'	Exit Function
	'End If
	'
	''Build Web Reference
	'blnResult = BuildWebReference("brwBulkConfiguration","pgBulkConfiguration","")
	'	If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Click Quote Details Link Present on Left Top
	blnResult = clickWebElement("elmQuoteDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgShowingQuoteOption").Exist
			If blnResult Then Exit For			
	Next
	
	blnResult = BuildWebReference("","pgShowingQuoteOption","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	'Select all Product Line Items for Configuration
	objPage.WebCheckBox("html id:=selectAll").Set "ON"
	
	'Click on Calculate Button
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(2, intConfiguredCol))
		If strCellData = "VALID" Then
			Call ReportLog("Configure Product", "Configuration should be <B>VALID</B>", "Product Configuration is found to be <B>" & strCellData & "</B>", "PASS", True)
			blnValid = True
			Exit For
		Else
			Wait 5
		End If
	Next

	If Not blnValid Then
		Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done & configuration is found to be: " & strCellData, "FAIL", True)
		Environment("Action_Result") = False
	End If
	
	'Check for Pricing is Firm or Not
	blnPricing = False
	For intCounter = 1 to 20
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(2, intPricingCol))
		If strCellData = "Firm" Then
			Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "PASS", True)
			blnPricing = True
			Exit For
		Else
			Wait 5
		End If
	Next
	
	If Not blnPricing Then
		Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	End If

	objPage.WebCheckBox("html id:=selectAll").Set "ON"

    	
End Function
	
 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
