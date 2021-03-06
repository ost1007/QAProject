'=============================================================================================================
'Description: Function to OrderOrModifyFibreChange
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			12/10/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_OrderOrModifyFibreChange
'=============================================================================================================
Public function fn_TAHITI_OrderOrModifyFibreChange()
		'Variable Declaration
		Dim dictAttributes
		
		Set dictAttributes = CreateObject("Scripting.Dictionary")
		dictAttributes.RemoveAll
		
		'Get the Attribute Value from Test Data Sheet
		strValues = GetAttributeValue("dOrderOrModifyFibre_Change")
		If strValues = "" Then
			Call ReportLog("Get Attribute Value", "Attribute Values for <B>dGatherAndConfirmServiceConfig</B> should be retrieved", "unable to find the Test Data", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
		
		arrAttributeValues = Split(strValues, ",")
		For Each attrValue in arrAttributeValues
			arrSplitAttr = Split(Trim(attrValue), ":")
			dictAttributes(Trim(arrSplitAttr(0))) = Trim(arrSplitAttr(1))
		Next

		'Building reference
		blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brwTahitiPortal").Page("pgTahitiPortal").Sync

		'Update all the Access Alarm Check Attributes
		Set objTblEthernetAccessTE = objFrame.WebTable("innertext:=.*Circuit Service ID.*", "class:=outputText", "index:=1")
		If objTblEthernetAccessTE.Exist Then
			With objTblEthernetAccessTE
		
					strCellValue = "Circuit Service ID: (*)"
					strTextValue = dictAttributes("CircuitServiceID")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebEdit", 0)
					blnResult = fn_TAHITI_EnterValueToObject(objChildItem, strTextValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strTextValue & " value should be entered", "value is not entered", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strTextValue & " value should be entered", "value is entered", "PASS", False)
						End If
						
					strCellValue = "Access Delivery Status: (*)"
					strTextValue = dictAttributes("AccessDeliveryStatus")
					iRow = .GetRowWithCellText(strCellValue)
					Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
					blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, strTextValue)
						If Not blnResult Then 
							Call ReportLog(strCellValue, strTextValue & " value should be selected", "value is not getting selected", "FAIL", True)
							Environment("Action_Result") = False : Exit Function
						Else
							Call ReportLog(strCellValue, strTextValue & " value should be selected", "value is selected", "PASS", False)
						End If
			End With
		End If

		Environment("Action_Result") = True

End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
