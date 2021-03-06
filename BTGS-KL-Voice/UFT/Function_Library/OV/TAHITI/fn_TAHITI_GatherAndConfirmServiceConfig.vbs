Public Function fn_TAHITI_GatherAndConfirmServiceConfig()

	Dim dictAttributes
	Dim blnSelected
	Dim intCounter
	Dim strSelectedValue

	Set dictAttributes = CreateObject("Scripting.Dictionary")
	dictAttributes.RemoveAll

	'Get the Attribute Value from Test Data Sheet
	strValues = GetAttributeValue("dGatherAndConfirmServiceConfig")
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
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	objFrame.WebList("lstCustomerConfigData").Click
	blnResult = selectValueFromList("lstCustomerConfigData", dictAttributes.Item("CustomerConfigDataAvailableProvide"))
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Wait 5

	On Error Resume Next
		For intCounter = 1 To 5
			blnSelected  = False
			strSelectedValue = objFrame.WebList("lstCustomerConfigData").GetROProperty("selection")
			If strSelectedValue <> dictAttributes.Item("CustomerConfigDataAvailableProvide") Then
				objFrame.WebList("lstCustomerConfigData").Select dictAttributes.Item("CustomerConfigDataAvailableProvide")
				Wait 5
			Else
				blnSelected  = True
				Exit For
			End If
		Next
	On Error GoTo 0

	If Not blnSelected Then
		Call ReportLog("lstCustomerConfigData", "Unable to Select Value", "Unable to selecte Value " & dictAttributes.Item("CustomerConfigDataAvailableProvide"), "FAIL", True)
		Environment("Action_Result") = False
	Else
		Environment("Action_Result") = True
	End If

	fn_TAHITI_GatherAndConfirmServiceConfig = blnSelected
End Function
