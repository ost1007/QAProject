'=============================================================================================================
'Description: Function to handle PortInOutAndTestServiceWithCustomer
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			01/08/2015 				NA
'Return Values : Boolean
'Example: fn_TAHITI_PortInOutAndTestServiceWithCustomer
'=============================================================================================================
Public Function fn_TAHITI_PortInOutAndTestServiceWithCustomer()
		'Variable Declaration
		Dim oDictParamValue
		Dim arrParamValues, arrValue
		Dim strParamAttribute
		Dim objTblPortInOut, objChildItem
		Dim iRow
		Dim PortInOutAndTestServiceWithCustomer

		'Get the attribute name from DataSheet
		PortInOutAndTestServiceWithCustomer = GetAttributeValue("dPortInOutAndTestServiceWithCustomer")
		
		Set oDictParamValue = CreateObject("Scripting.Dictionary")
	
		arrParamValues = Split(PortInOutAndTestServiceWithCustomer, ",")
		For Each strParamAttribute In arrParamValues
				arrValue = Split(Trim(strParamAttribute), ":")
				oDictParamValue(Trim(arrValue(0))) = Trim(arrValue(1))
		Next

		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Set objTblPortInOut = objFrame.WebTable("xpath:=//TABLE[@id='grpPort In/Out and Test Service']")
		With objTblPortInOut 
				If Not .Exist Then
					Call ReportLog("Port In/Out and Test Service", "WebTable should exist", "WebTable doesn't exist", "FAIL", True)
					fn_TAHITI_PortInOutAndTestServiceWithCustomer = False : Exit Function
				End If

				strCellValue = "Port In/Out Completed?: (*)"
				strSelectValue = oDictParamValue("PortInOutCompleted")
				iRow = .GetRowWithCellText(strCellValue)
				Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
				blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
					If Not blnResult Then 
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
						fn_TAHITI_PortInOutAndTestServiceWithCustomer = False : Exit Function
					Else
						Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
					End If
		End With

		fn_TAHITI_PortInOutAndTestServiceWithCustomer = True
End Function