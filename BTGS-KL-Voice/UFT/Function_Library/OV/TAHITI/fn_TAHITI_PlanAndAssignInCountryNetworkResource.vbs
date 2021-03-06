'=============================================================================================================
'Description: Function to handle PlanAndAssignInCountryNetworkResource
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			28/08/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_PlanAndAssignInCountryNetworkResource
'=============================================================================================================
Public Function fn_TAHITI_PlanAndAssignInCountryNetworkResource()

	Dim dictAttributes
	Dim blnSelected
	Dim intCounter
	Dim strSelectedValue
	Dim objEthernetAccessTE

    Set dictAttributes = CreateObject("Scripting.Dictionary")
	dictAttributes.RemoveAll

	'Get the Attribute Value from Test Data Sheet
	strValues = GetAttributeValue("dPlanAndAssignInCountryNetworkResource")
	If strValues = "" Then
		Call ReportLog("Get Attribute Value", "Attribute Values for <B>dPlanAndAssignInCountryNetworkResource</B> should be retrieved", "unable to find the Test Data", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If

	arrAttributeValues = Split(strValues, ",")
	For Each attrValue in arrAttributeValues
		arrSplitAttr = Split(Trim(attrValue), ":")
		dictAttributes(Trim(arrSplitAttr(0))) = Trim(arrSplitAttr(1))
	Next

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Update all the Ethernet Access TE
	Set objEthernetAccessTE = objFrame.WebTable("tblEthernetAccessTE")
	If objEthernetAccessTE.Exist Then
			With objEthernetAccessTE
		
					strCellValue = "Circuit Service ID: (*)"
					strEnterValue = dictAttributes("CircuitServiceID")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebEdit", 0)
					blnResult = fn_TAHITI_EnterValueToObject(objChildItem, strEnterValue )
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be Entered", "value is not getting entered", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be entered", "value is set", "PASS", False)
						End If
		
					strCellValue = "POP cabling required?: (*)"
					strSelectValue = dictAttributes("POPCablingRequired")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
						End If
		
					strCellValue = "Existing fibre with existing capacity?: (*)"
					strSelectValue = dictAttributes("ExistingFibreWithExistingCapacity")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
						End If
		
					strCellValue = "New Fibre/Radio required?: (*)"
					strSelectValue = dictAttributes("NewFibreRadioRequired")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
						End If
		
					strCellValue = "New/Additional Equipment Required?: (*)"
					strSelectValue = dictAttributes("NewAdditionalEquipmentRequired")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strSelectValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strSelectValue & " value should be selected", "value is selected", "PASS", False)
						End If
			End With '#objEthernetAccessTE
	End If
End Function