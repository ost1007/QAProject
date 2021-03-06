'=================================================================================================================================
' Description	: Check the Status of Associated Elements
' History		:		Name		Date		Version
' Created By	: 	Nagaraj V	28/04/2015		v1.0
' Example	: fn_BFG_CheckAssociatedElementsStatus "PRIVATE PBX CONNECT|Site Number Range-Private", "IN_SERVICE|IN-SERVICE"
'=================================================================================================================================
Public Function fn_BFG_CheckAssociatedElementsStatus(ByVal ElementProducts, ByVal Status)
	
	Dim iRow, intRowCount, intCntr, intElementsProductCol, iElmProdCounter, intInitialStartRow
	Dim strAssociatedURL, strElementProductName, strStatus
	Dim arrElementProducts, arrStatus, arrColumnNames
	
	'Variable Assignment
	arrElementProducts = Split(ElementProducts, "|")
	arrStatus = Split(Status, "|")
	intElementsProductCol = -1
	
	If Not Browser("brwBFG-IMS").Page("pgBFG-IMS").WebTable("tblAssociatedElement").Exist(60) Then
		Call ReportLog("Associated Elements", "Associated Elements Table should exist", "Associated Elements Table doesn't exist", "FAIL", True)
	Else
		arrColumnNames = Split(Browser("brwBFG-IMS").Page("pgBFG-IMS").WebTable("tblAssociatedElement").GetROProperty("column names"), ";")
		For intCntr = LBound(arrColumnNames) To UBound(arrColumnNames)
			If arrColumnNames(intCntr) = "Element's Product" Then
				intElementsProductCol = intCntr + 1
				Exit For '#intCntr
			End If
		Next '#intCntr
		
		'Terminate If Column Could not be found
		If intElementsProductCol = -1 Then
			Call ReportLog("Element's Product Column", "Element's Product Column should exist", "Element's Product Column doesn't exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	intRowCount = Browser("brwBFG-IMS").Page("pgBFG-IMS").WebTable("tblAssociatedElement").RowCount
	For iElmProdCounter = LBound(arrElementProducts) To UBound(arrElementProducts)
		intInitialStartRow = 1
		strElementProductName = arrElementProducts(iElmProdCounter)
		strStatus = arrStatus(iElmProdCounter)
		With Browser("brwBFG-IMS").Page("pgBFG-IMS").WebTable("tblAssociatedElement")
			iRow = .GetRowWithCellText(strElementProductName, intElementsProductCol, intInitialStartRow)
			While iRow > 0
				intLinkCount = .ChildItemCount(iRow, intElementsProductCol, "Link")
				If intLinkCount = 0 Then
					Call ReportLog("Associated Element", "<B><I>" & strElementProductName & "</I></B> - should exist as Link", "<B><I>" & strElementProductName & "</I></B> - exists as plain text", "Warnings", True)
				Else
					Set oLink = .ChildItem(iRow, intElementsProductCol, "Link", 0)
					strAssociatedURL = oLink.GetROProperty("url")
					Call fn_BFG_CheckStatusOfElementsProduct(strAssociatedURL, strStatus)
				End If
				intInitialStartRow = iRow + 1
				If intRowCount > intInitialStartRow Then
					iRow = .GetRowWithCellText(strElementProductName, intElementsProductCol, intInitialStartRow)
				Else
					iRow = 0
				End If
			Wend
		End With
	Next '#iElmProdCounter
	
	If Browser("brwBFG-IMS").Exist(0) Then Browser("brwBFG-IMS").CloseAllTabs
End Function

'=================================================================================================================================
' Description: Check the Status of Associated Element by Navigating to URL
'=================================================================================================================================
Public Function fn_BFG_CheckStatusOfElementsProduct(ByVal URL, ByVal Status)
	Dim oIE
	Dim oDesc
	Dim intCounter
	Dim strActualStatus, strFeatureOption, strRetrievedDate
	
	'Launch URL and Wait until is loaded
	Set oIE = CreateObject("InternetExplorer.Application")
	With oIE
		.Navigate URL, 2048
		.Visible = True
		.FullScreen = True
		'While (.Busy OR .ReadyState <> 4)
		'	Wait 1
		'Wend
	End With '#oIE
	
	Set oDesc = Description.Create
	oDesc("url").Value = URL
	oDesc("url").RegularExpression = False
	oDesc("creationtime").Value = 0
	
	Set objBrowser = Browser(oDesc)
	If Not objBrowser.Exist(60) Then
		Call ReportLog("View Feature Page", "View Feature Page should be loaded", "View Feature Page is not loaded", "FAIL", True)
	Else
		objBrowser.fSync
	End If
	
	Set objPage = objBrowser.Page("title:=.*")
	
	'Check If Feature Option is displayed or not
	For intCounter = 1 To 30
		blnResult = objPage.WebList("name:=FOI_FEO_ID").Exist(5)
			If blnResult Then Exit For '#intCounter
	Next '#intCounter
	
	If Not blnResult Then
		Call ReportLog("Feature Option", "Feature Option should exist", "Feature Option doesn't exist", "FAIL", True)
		objBrowser.Close
		Exit Function
	Else
		strFeatureOption = objPage.WebList("name:=FOI_FEO_ID").GetROProperty("selection")
	End If
	
	'Check If Status is displayed or not
	For intCounter = 1 To 30
		blnResult = objPage.WebList("name:=FOI_STA_ID").Exist(5)
			If blnResult Then Exit For '#intCounter
	Next '#intCounter
	
	If Not blnResult Then
		Call ReportLog("FOI Status", "FOI Status should exist", "FOI Status doesn't exist", "FAIL", True)
		objBrowser.Close
		Exit Function
	End If
	
	strActualStatus = Trim(objPage.WebList("name:=FOI_STA_ID").GetROProperty("selection"))
	If strActualStatus = Status Then
		Call ReportLog("Status Check", "Status of <B>" & strFeatureOption & "</B> - should be <B>" & Status & "</B>", "Status of <B>" & strFeatureOption & "</B> - is found to be <B>" & strActualStatus & "</B>", "PASS", True)
	Else
		Call ReportLog("Status Check", "Status of <B>" & strFeatureOption & "</B> - should be <B>" & Status & "</B>", "Status of <B>" & strFeatureOption & "</B> - is found to be <B>" & strActualStatus & "</B>", "FAIL", True)
		objBrowser.Close
		Environment("Action_Result") = False : Exit Function
	End If
	
	If Status = "CEASED" Then
		'Check If Cease Date is displayed or not
		For intCounter = 1 To 30
			blnResult = objPage.WebEdit("name:=FOI_CEASE_DATE").Exist(5)
				If blnResult Then Exit For '#intCounter
		Next '#intCounter
		
		If Not blnResult Then
			Call ReportLog("Feature Option", "Feature Option Cease Date Field should exist", "Feature Option Cease Date Field doesn't exist", "FAIL", True)
			objBrowser.Close
			Exit Function
		Else
			objPage.WebEdit("name:=FOI_CEASE_DATE").HighLight : Wait 2
			strRetrievedDate = objPage.WebEdit("name:=FOI_CEASE_DATE").GetROProperty("value")
			If Trim(strRetrievedDate) = "" Then
				Call ReportLog("Feature Option", "Feature Option Cease Date Field should exist", "Feature Option Cease Date Field exists and is BLANK", "FAIL", True)
			Else
				Call ReportLog("Feature Option", "Feature Option Cease Date Field should exist", "Feature Option Cease Date Field exists <B>" & strRetrievedDate & "</B>" , "Information", True)
			End If
		End If
	End If '#Status = "CEASED"
	objBrowser.Close
End Function
