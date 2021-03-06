'=============================================================================================================
'Description: Function to handle In Service Notification (Provide)
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			28/08/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_PlanConfigurationOfCoreTransmissionPath
'=============================================================================================================
Public Function fn_TAHITI_InServiceNotificationProvide()

	Dim dictAttributes

    Set dictAttributes = CreateObject("Scripting.Dictionary")
	dictAttributes.RemoveAll

	'Get the Attribute Value from Test Data Sheet
	strValues = GetAttributeValue("dInServiceNotificationProvide")
	If strValues = "" Then
		Call ReportLog("Get Attribute Value", "Attribute Values for <B>dPlanConfigurationOfCoreTransmissionPath</B> should be retrieved", "unable to find the Test Data", "FAIL", False)
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

	'Enter OrderManagementAccessAccepted
	If dictAttributes.Exists("OrderManagementAccessAccepted") Then
		objFrame.WebList("lstOrderManagementAccessAccepted").Click
        Wait 5
		blnResult = selectValueFromList("lstOrderManagementAccessAccepted", dictAttributes.Item("OrderManagementAccessAccepted"))
			If Not blnResult Then Envrironment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Input Parameter", "[OrderManagementAccessAccepted] Input Parameter should be entered for dInServiceNotificationProvide", "Input parameter is missing", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If

	'Enter TechnicalAssuranceAccessAccepted
	If dictAttributes.Exists("TechnicalAssuranceAccessAccepted") Then
		objFrame.WebList("lstTechnicalAssuranceAccessAccepted").Click
		Wait 3
		blnResult = selectValueFromList("lstTechnicalAssuranceAccessAccepted", dictAttributes.Item("TechnicalAssuranceAccessAccepted"))
			If Not blnResult Then Envrironment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Input Parameter", "[TechnicalAssuranceAccessAccepted] Input Parameter should be entered for dInServiceNotificationProvide", "Input parameter is missing", "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
End Function