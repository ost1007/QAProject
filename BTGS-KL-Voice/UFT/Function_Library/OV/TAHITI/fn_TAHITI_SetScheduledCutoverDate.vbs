'=============================================================================================================
'Description: Function to Check CutoverDate
'History	  : Name				Date			Changes Implemented
'Created By	 :  BT Automation Team			24/08/2016 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_SetScheduledCutoverDate
'=============================================================================================================
Public Function fn_TAHITI_SetScheduledCutoverDate()

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
	'Click on Matrix Config
	blnResult = clickFrameLink("lnkMatrixConfig")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 10
	objBrowser.Sync
	
	intRows = objFrame.WebTable("tblAttributeList").RowCount
	For iRow = 2 to intRows
		strNumberType = objFrame.WebTable("tblAttributeList").ChildItem(iRow, 6, "WebList", 0).GetROProperty("selection")
		If strNumberType = "Cutover" Then
			objFrame.WebTable("tblAttributeList").ChildItem(iRow, 12, "WebEdit", 0).highLight
			strDate = objFrame.WebTable("tblAttributeList").ChildItem(iRow, 12, "WebEdit", 0).GetROProperty("value")
			If DateDiff("d", Date, strDate) > 0 Then
				Call ReportLog("Check Cutover Date", "Cutover date should be future date","Cutover date is found to be <B>" & strDate & "</B>","Information", True)
			Else
				objFrame.WebTable("tblAttributeList").ChildItem(iRow, 12, "WebEdit", 0).Set (Date + 10)
				Call ReportLog("Check Cutover Date", "Cutover date should be future date","Cutover date is found to be <B>" & strDate & "</B> & updated with <B>" & Date + 10 & "</B>","Information", True)
				blnResult = clickFrameButton("btnSave")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				
				Wait 10
				
				objPage.Frame("frmTahitiNavigator").Link("lnkTaskDetails").Click
				Wait 5
			End If
		End If
	Next 'iRow

End Function
