'=============================================================================================================
'Description: Function to Fill Attributes for Notify Billing of Cease
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			11/08/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_NotifyBillingOfCease
'=============================================================================================================
Public function fn_TAHITI_NotifyBillingOfCease()
	'Variable Declaration
	Dim strBillingRecordSetUp

	'Variable Assignment
	strBillingRecordSetUp = "Passed"

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

	'Update all the Billing Record Setup Attributes
	Set objTblBillingRecordSetup = objFrame.WebTable("xpath:=//TABLE[@id='grpOrder Management']")
	With objTblBillingRecordSetup
		If Not .Exist Then
			Call ReportLog("Order Managemen", "Order Managemen Table should exist", "Order Managemen does not exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If

		strCellValue = "Billing Record Setup:"
		strSelectValue = strBillingRecordSetUp
		iRow = .GetRowWithCellText(strCellValue)
		Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
		blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
			If Not blnResult Then 
				Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			Else
				Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
			End If
	End With
End Function