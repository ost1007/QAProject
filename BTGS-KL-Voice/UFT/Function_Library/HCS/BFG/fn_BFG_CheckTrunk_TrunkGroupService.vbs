'****************************************************************************************************************************
' Function Name	 : fn_BFG_CheckTrunk_TrunkGroupService
' Purpose	 	 : Function to Check Trunk and Trunk Group Service ID
' Modified By	: Nagaraj V			18/02/2015
' Parameters	 : 	TrunkServiceID, TrunkGroupServiceID
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_BFG_CheckTrunk_TrunkGroupService(ByVal TrunkServiceID, ByVal TrunkGroupServiceID)

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBFG-IMS","pgBFG-IMS","")
		If Not blnResult Then	Environment.Value("Action_Result") = False  :	Exit Function

	'Check for the existence of Associated Element Table
	If Not objPage.WebTable("tblAssociatedElement").Exist Then
		Call ReportLog("Table Associated Element", "Table should be populated", "Table is not populated", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	intRows = objPage.WebTable("tblAssociatedElement").RowCount
    For iRow = 2 to intRows
		strCellData = objPage.WebTable("tblAssociatedElement").GetCellData(iRow, 2)
		strCeaseDate = objPage.WebTable("tblAssociatedElement").GetCellData(iRow, 5)

		If strCeaseDate <> "" Then
			Call ReportLog("Cease Date", "The below inventory is ceased", "The Below inventory is ceased", "INFORMATION", True)
		End If

		If strCellData = "Trunk - OCC" OR strCellData = "Trunk Group - OCC" Then '==1
			Set objLink =objPage.WebTable("tblAssociatedElement").ChildItem(iRow, 3, "Link", 0)
			objLink.Click
			Wait 5
			For intCounter = 1 to 10
				blnResult = objBrowser.Dialog("dlgMessage").Exist(30)
				If blnResult Then
					objBrowser.Dialog("dlgMessage").Activate
					objBrowser.Dialog("dlgMessage").WinButton("btnOK").Click
					Exit For
				End If
			Next

			objPage.WebEdit("txtIdentifier").HighLight
			
			If strCellData = "Trunk - OCC" Then '==2
				strIdentifier = Trim(objPage.WebEdit("txtIdentifier").GetROProperty("value"))
				If Instr(TrunkServiceID, strIdentifier) > 0 Then
					Call ReportLog("Validate Trunk", "Trunk OCC Service ID should match any of " & TrunkServiceID, "Trunk OCC Service ID is found to be " & strIdentifier, "PASS", True)
				Else
					Call ReportLog("Validate Trunk", "Trunk OCC Service ID should match any of " & TrunkServiceID, "Trunk OCC Service ID is found to be " & strIdentifier, "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
			ElseIf strCellData = "Trunk Group - OCC" Then
				strIdentifier = Trim(objPage.WebEdit("txtIdentifier").GetROProperty("value"))
				If TrunkGroupServiceID = strIdentifier Then
					Call ReportLog("Validate Trunk", "Trunk Group - OCC Service ID should match " & TrunkGroupServiceID, "Trunk Group - OCC Service ID is found to be " & strIdentifier, "PASS", True)
				Else
					Call ReportLog("Validate Trunk", "Trunk Group - OCC Service ID should match " & TrunkGroupServiceID, "Trunk Group - OCC Service ID is found to be " & strIdentifier, "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
			End If '==2

			objPage.WebList("lstStatus").HighLight

			'Check Inventory Status to be IN-SERVICE
			strInventoryStatus = Trim(objPage.WebList("lstStatus").GetROProperty("selection"))
			If strInventoryStatus = "IN-SERVICE" Then '==3
				Call ReportLog("Check Inventory Status", "Inventory Status should be IN-SERVICE", "Inventory Status is found to be " & strInventoryStatus, "PASS", True)
			ElseIf strInventoryStatus = "CEASED" And strCeaseDate <> "" Then
				Call ReportLog("Check Inventory Status", "Inventory Status should be CEASED", "Inventory Status is found to be " & strInventoryStatus, "PASS", True)
			Else
				Call ReportLog("Check Inventory Status", "Inventory Status should be IN-SERVICE", "Inventory Status is found to be " & strInventoryStatus, "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If '==3

			'Click on Site Summary Link
			blnResult = clickLink("lnkSiteSummary")
				If Not blnResult Then	Environment.Value("Action_Result") = False  :	Exit Function

			For intCounter = 1 to 100
				If objPage.Link("lnkPackageInstance").Exist(2) Then	Exit For
			Next

			'Click on Package Instance Link
			blnReult = clickLink("lnkPackageInstance")
				If Not blnResult Then	Environment.Value("Action_Result") = False  :	Exit Function

			For intCounter = 1 to 10
				If objPage.WebTable("tblPackageInstanceMain").Exist(10) Then Exit For
			Next
		
			If Not objPage.WebTable("tblPackageInstanceMain").Exist(2) Then
				Call ReportLog("Package Instance", "Package Instances Page should be populated", "Not Navigated to Package Instances Page", "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			End If

		End If  '==1
	Next

	objBrowser.Close

End Function
