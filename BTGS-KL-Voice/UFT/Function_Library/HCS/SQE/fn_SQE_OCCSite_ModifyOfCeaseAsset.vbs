'=============================================================================================================
'Description	: Function to cease the asset in Modify Jouorney
'History		: Name			Date	Version	Changes Implemented
'Created By	: Nagaraj	24/06/2015 	v1.0		N/A
'Modified By	: Nagaraj	27/04/2016 	v2.0		Modified to Handle IP PBX Private Connect Cease
'Example		: fn_SQE_OCCSite_ModifyOfCeaseAsset(SiteName, ModifyAssetPath, AssetName)
'=============================================================================================================
Public Function fn_SQE_OCCSite_ModifyOfCeaseAsset(ByVal SiteName, ByVal ModifyAssetPath, ByVal AssetName)
	Dim oDesc
	Dim blnValid, blnPricing
	Dim intCounter, iRow, intSiteRow
	Dim arrColumnNames
	Dim intProductCol, intConfiguredCol, intPricingCol, intOrderTypeCol, intStencilCol, iCnt, intCol, intInitWaitTime
	Dim strCellData, strTreeNodePath, strClassProp
	Dim objElmBaseConfig, oLineItem, oLevel0TreeNode, oLevel1TreeNode
	
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
	
	intSiteRow = objPage.WebTable("tblProductLineItems").GetRowWithCellText(SiteName)
	If intSiteRow <= 0 Then
		Call ReportLog("Search Site", "<B>" & SiteName & "</B> should exist", "<B>" & SiteName & "</B> does not exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intSiteRow, intConfiguredCol))
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
		blnResult = objBrowser.Page("pgBulkConfiguration").Exist(60)
			If blnResult Then Exit For			
	Next
	
	'Build Browser Reference
	blnResult = BuildWebReference("","pgBulkConfiguration","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	'Wait until Loading Products is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loading Products.*", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next
	
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 25
		If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(10) Then	
			Wait 15
		Else
			Exit For
		End If
	Next

	'Click on Base Config
	Set objElmBaseConfig = objPage.WebElement("class:=label ng-scope ng-binding.*","innertext:=Base Configuration", "index:=0")
	If objElmBaseConfig.Exist(60) Then
		objElmBaseConfig.Click
	Else
		Call ReportLog("Configuration", "Base Configuration should be visible under Configuring Product", "Base Configuration is not visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	strTreeNodePath = Split(ModifyAssetPath, "|")

	'Check for existence of Specified Line Item on Left Tree and click on the Line Item
	Set oLineItem = objPage.WebElement("class:=label ng-scope ng-binding.*","html tag:=SPAN","innertext:=" & Trim(strTreeNodePath(0)) )
	If oLineItem.Exist(60) Then
		oLineItem.Click : Wait 2
		Call ReportLog("Configure Product", "Tree Node Level 0 of <B>[" & strTreeNodePath(0) & "]</B> should exist", "Tree Node Level 0 exists and is clicked", "PASS", False)
	Else
		Call ReportLog("Configure Product", "Tree Node Level 0 of <B>[" & strTreeNodePath(0) & "]</B> should exist", "Tree Node Level 0 does not exist", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If UBound(strTreeNodePath) = 1 Then
		Set oLevel0TreeNode = objPage.WebElement("class:=treeNode ng-scope level0 validity-pending","innertext:=" & Trim(strTreeNodePath(0)) & ".*")
		If Not oLevel0TreeNode.Exist Then
			Call ReportLog("Configure Product", "Tree Node Level 0 of <B>[" & strTreeNodePath(0) & "]</B> should exist", "Tree Node Level 0 does not exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If

		'Check for expanded inner tree item presence
		Set oLevel1TreeNode = oLevel0TreeNode.WebElement("class:=label ng-scope ng-binding.*","innertext:=" & Trim(strTreeNodePath(1)), "index:=0")
		If Not oLevel1TreeNode.Exist Then
			Call ReportLog("Configure Product", "Tree Node Level 1 of <B>[" & strTreeNodePath(1) & "]</B> should exist", "Tree Node Level 1 does not exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			oLevel1TreeNode.Click : Wait 2
			Call ReportLog("Configure Product", "Tree Node Level 1 of <B>[" & strTreeNodePath(1) & "]</B> should exist", "Tree Node Level 1 exists and is clicked", "PASS", False)
		End If
	End If

	'Cease the Asset
	If AssetName = "Virtual User" OR AssetName = "Mobile User" Then
			Set oLineItemBaseConfig = objPage.WebTable("column names:=.*;Status;Site;.*", "index:=0", "visible:=True")
			If Not oLineItemBaseConfig.Exist(60) Then
				Call ReportLog("Base Config Table", "Base Config Table should be loaded", "Base Configuration Table is not loaded or Column names might have changed", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			intStencilCol = -1
			arrColumnNames = Split(oLineItemBaseConfig.GetROPRoperty("column names"), ";")
			For iCnt = 1 To UBound(arrColumnNames)
				If Instr(arrColumnNames(iCnt), "Stencil") > 0 Then
					intStencilCol = iCnt + 1
					Exit For
				End If
			Next
			
			If intStencilCol = -1 Then
				Call ReportLog("Base Config Table", "Table should contain Stencils Column", "Table doesn't contain Stencils column", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
	
			blnFound = False
			intRow = oLineItemBaseConfig.RowCount
			'Get the WebList from Table and check the selection with AssetName to select the checkBox
			For iRow = 1 To intRow
				intCol = oLineItemBaseConfig.ColumnCount(iRow)
				If intCol > 1 Then
					Set oStencil = oLineItemBaseConfig.ChildItem(iRow, intStencilCol, "WebList", 0)
					If Trim(oStencil.GetROProperty("selection")) = AssetName Then
						oLineItemBaseConfig.ChildItem(iRow, 1, "WebCheckBox", 0).Set "ON"
						blnFound = True
						Exit For
					End If
				End If
			Next
	
			'If Given AssetName doesn't exist in Table
			If Not blnFound Then
				Call ReportLog("Cease Asset", "<B>" & AssetName & "</B> should exist", "Asset doesn't Exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
	ElseIf AssetName = "PRIVATE PBX CONNECT" Then
			'Wait until Loaded 0 of 1 assets status is not visible
			For intCounter = 1 to 25
				If objPage.WebElement("innertext:=Loaded \d+ of \d+ assets", "index:=0").Exist(10) Then	
					Wait 15
				Else
					Exit For '#intCounter
				End If
			Next '#intCounter
	
			Set oLineItemBaseConfig = objPage.WebTable("column names:=.*;Status;Site;.*", "index:=0", "visible:=True")
			If Not oLineItemBaseConfig.Exist(60) Then
				Call ReportLog("Base Config Table", "Base Config Table should be loaded", "Base Configuration Table is not loaded or Column names might have changed", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			Else
				iRow = oLineItemBaseConfig.RowCount - 1
			End If
			
			'Select All
			blnResult = setCheckBox("chkSelectAll", "ON")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
			Call ReportLog("Cease Asset", "<B>" & AssetName & "</B> is not yet Scripted", "Contact Automation Team", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
	End If

	'Click on Delete Asset
	blnResult = clickButton("btnDeleteAsset")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	intInitWaitTime = 10
	'Wait until Loaded 0 of 1 assets status is not visible
	For intCounter = 1 to 50
		If objPage.WebElement("innertext:=Performing deleting.*", "index:=0").Exist(intInitWaitTime) Then	
			Wait 5
			intInitWaitTime = 3
		Else
			Exit For
		End If
	Next

	Set oDesc = Description.Create
	oDesc("micclass").Value = "WebElement"
	oDesc("class").Value = ".*Delete.*"

	oLineItemBaseConfig.RefreshObject
	'Check whether the asset is delected or not
	Set oDeleteWebElm = oLineItemBaseConfig.ChildItem(iRow, 3, "WebElement", 0).ChildObjects(oDesc)
	If oDeleteWebElm.Count = 0 Then
		Call ReportLog("Delete Asset", "Asset should be deleted Successfully", "Delete Operation was unsuccessfult", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	strClassProp = oDeleteWebElm(0).GetROProperty("class")
	If Instr(strClassProp, "Delete") > 0 Then
		Call ReportLog("Delete Asset", "Asset should be deleted Successfully", "Asset is successfully delected new class is found to be " & strClassProp, "PASS", True)
	Else
		Call ReportLog("Delete Asset", "Asset should be deleted Successfully", "Asset is successfully delected new class is found to be " & strClassProp, "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Click Quote Details Link Present on Left Top
	blnResult = clickWebElement("elmQuoteDetails")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	For intCounter = 1 To 5
		blnResult = objBrowser.Page("pgShowingQuoteOption").Exist(60)
			If blnResult Then Exit For			
	Next
	
	blnResult = BuildWebReference("","pgShowingQuoteOption","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 5
		If objPage.link("lnkCalculatePrice").WaitProperty("class", "main-action actionBtnDisable", 1000*60*1) Then
			Exit For
		Else
			'Select all Product Line Items for Configuration
			objPage.WebCheckBox("html id:=selectAll").Set "ON"	
		End If
	Next
	
	'Click on Calculate Button
	blnResult = clickLink("lnkCalculatePrice")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Wait 60
	
	'Check for Configuration is Valid or Not
	blnValid = False
	For intCounter = 1 to 50
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intSiteRow, intConfiguredCol))
		If strCellData = "VALID" Then
			Call ReportLog("Configure Product", "Configuration should be <B>VALID</B>", "Product Configuration is found to be <B>" & strCellData & "</B>", "PASS", True)
			blnValid = True
			Exit For
		ElseIf strCellData = "" Then
			Wait 10
		Else
			objPage.HighLight : Wait 2
			objBrowser.fRefresh
			'CreateObject("WScript.Shell").SendKeys "{F5}"
			Wait 10 : objPage.Sync
		End If
	Next '#intCounter

	If Not blnValid Then
		Call ReportLog("Configure Product", "Pricing should be done", "Pricing is not done & configuration is found to be: " & strCellData, "FAIL", True)
		Environment("Action_Result") = False
	End If
	
	'Check for Pricing is Firm or Not
	blnPricing = False
	For intCounter = 1 to 20
		strCellData = Trim(objPage.WebTable("tblProductLineItems").GetCellData(intSiteRow, intPricingCol))
		If strCellData = "Firm" And (AssetName = "Virtual User" OR AssetName = "Mobile User")Then
			Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "PASS", True)
			blnPricing = True
			Exit For
		ElseIf (strCellData = "N/A" OR strCellData = "FIRM" ) And AssetName = "PRIVATE PBX CONNECT" Then
			Call ReportLog("Product Pricing", "Pricing should be <B>N/A Or Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "PASS", True)
			blnPricing = True
			Exit For
		Else
			Wait 10
		End If
	Next
	
	If Not blnPricing Then
		Call ReportLog("Product Pricing", "Pricing should be <B>Firm</B>", "Product Pricing is found to be <B>" & strCellData & "</B>", "FAIL", True)
		Environment("Action_Result") = False
	End If

	objPage.WebCheckBox("html id:=selectAll").Set "ON"
End Function
