'=============================================================================================================
'Description: Function to Click on Matrix Config and select remove against all the number blocks
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			13/08/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_UpdateNumberManagement
'=============================================================================================================
Public Function fn_TAHITI_UpdateNumberManagement(ByRef MNUMToBeUsed)

		'Variable Declaration
		Dim intRows, iRow
		
		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
		'Click on Matrix Config
		blnResult = clickFrameLink("lnkMatrixConfig")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		Wait 10
		objBrowser.Sync

		'Check whether Table exists or not
		If Not objFrame.WebTable("tblAttributeList").WaitProperty("rows", micGreaterThan(1), 10000*6) Then
			Call ReportLog("Number Block Table", "Number Block Table should be visible", "Number Block Table is not visible", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		intRows = objFrame.WebTable("tblAttributeList").RowCount
		For iRow = 2 to intRows
			 objFrame.WebTable("tblAttributeList").ChildItem(iRow, 5, "WebList", 0).Select "Remove"
			 Wait 2
		Next '#iRow

		blnResult = clickFrameButton("btnSave")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		Wait 10
		
		'If MNUM is no then dependency of UpdateMNUMCease is removed
		MNUMToBeUsed = "No"
		If objFrame.WebElement("xpath:=//TR[TD[normalize-space()='MNUM to be Used:']]/TD[2]").Exist(10) Then
			MNUMToBeUsed = Trim(objFrame.WebElement("xpath:=//TR[TD[normalize-space()='MNUM to be Used:']]/TD[2]").GetROProperty("innertext"))
		End If
		
		objPage.Frame("frmTahitiNavigator").Link("lnkTaskDetails").Click
		Wait 5

End Function
