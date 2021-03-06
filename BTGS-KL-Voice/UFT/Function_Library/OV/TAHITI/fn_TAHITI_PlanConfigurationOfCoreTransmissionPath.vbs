'=============================================================================================================
'Description: Function to handle Plan Configuration Of CoreTransmission Path
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			28/08/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_PlanConfigurationOfCoreTransmissionPath
'=============================================================================================================
Public Function fn_TAHITI_PlanConfigurationOfCoreTransmissionPath()

	Dim dictAttributes
	Dim blnSelected
	Dim intCounter
	Dim strSelectedValue
	Dim objEthernetAccessTE

    	Set dictAttributes = CreateObject("Scripting.Dictionary")
	dictAttributes.RemoveAll

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	'Enter Access Supplier Circuit ID
	If objFrame.WebEdit("txtAccessSupplierCircuitID").Exist(10) Then
		'Get the Attribute Value from Test Data Sheet
		strValues = GetAttributeValue("dPlanConfigurationOfCoreTransmissionPath")
		If strValues = "" Then
			Call ReportLog("Get Attribute Value", "Attribute Values for <B>dPlanConfigurationOfCoreTransmissionPath</B> should be retrieved", "unable to find the Test Data", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	
		arrAttributeValues = Split(strValues, ",")
		For Each attrValue in arrAttributeValues
			arrSplitAttr = Split(Trim(attrValue), ":")
			dictAttributes(Trim(arrSplitAttr(0))) = Trim(arrSplitAttr(1))
		Next
		
		If dictAttributes.Exists("AccessSupplierCircuitID") Then
			blnResult = enterFrameText("txtAccessSupplierCircuitID", dictAttributes.Item("AccessSupplierCircuitID"))
				If Not blnResult Then Envrironment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Input Parameter", "[AccessSupplierCircuitID] Input Parameter should be entered for dPlanConfigurationOfCoreTransmissionPath", "Input parameter is missing", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
End Function
