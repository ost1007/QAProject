'=============================================================================================================
'Description: Function to Click on Matrix Config and update the dates
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			08/07/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_PerformNumberManagement
'=============================================================================================================
Public Function fn_TAHITI_PerformNumberManagement()
	Dim strValues, arrAttributeValues
	Dim dictAttributes
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False : Exit Function
	End If
	
	'Click on Matrix Config
	blnResult = clickFrameLink("lnkMatrixConfig")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 10
	objBrowser.Sync

	intRows = objFrame.WebTable("tblAttributeList").RowCount
	For iRow = 2 to intRows
		strNumberType = objFrame.WebTable("tblAttributeList").ChildItem(iRow, 6, "WebList", 0).GetROProperty("selection")
		'Port In Date
        objFrame.WebTable("tblAttributeList").ChildItem(iRow, 8, "WebEdit", 0).Set "01/01/2001"
		'Port Out Date
		objFrame.WebTable("tblAttributeList").ChildItem(iRow, 9, "WebEdit", 0).Set "01/01/2001"
		'Cut Over Date
		objFrame.WebTable("tblAttributeList").ChildItem(iRow, 12, "WebEdit", 0).Set "01/01/2001"
		If strNumberType = "Cutover" Then
			objFrame.WebTable("tblAttributeList").ChildItem(iRow, 12, "WebEdit", 0).Set (Date + 10)
		ElseIf strNumberType = "Porting" Then
			strPortingType = objFrame.WebTable("tblAttributeList").ChildItem(iRow, 7, "WebList", 0).GetROProperty("selection")
			If strPortingType = "In" Then
				objFrame.WebTable("tblAttributeList").ChildItem(iRow, 8, "WebEdit", 0).Set (Date + 10)
				'Gaining Service Provider
				objFrame.WebTable("tblAttributeList").ChildItem(iRow, 35, "WebEdit", 0).Set "BTC"
                'Loosing Service Provider
				objFrame.WebTable("tblAttributeList").ChildItem(iRow, 36, "WebEdit", 0).Set "ALT"
			ElseIf strPortingType = "Out" Then
				objFrame.WebTable("tblAttributeList").ChildItem(iRow, 9, "WebEdit", 0).Set (Date + 10)
			End If
		End If
	Next

	Call ReportLog("Matrix Attributes", "Dates Should be Set", "Dates are set", "INFORMATION", True)

	blnResult = clickFrameButton("btnSave")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	objPage.Frame("frmTahitiNavigator").Link("lnkTaskDetails").Click
	Wait 5

	Set dictAttributes = Nothing
End Function
