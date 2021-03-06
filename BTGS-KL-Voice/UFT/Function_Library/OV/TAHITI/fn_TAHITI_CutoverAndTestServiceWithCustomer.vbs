'=============================================================================================================
'Description: Function to Enter the particulars for CutoverAndTestServiceWithCustomer
'History	  : Name				Date			Changes Implemented
'Created By	 :  BT Automation Team			24/08/2016 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_CutoverAndTestServiceWithCustomer
'=============================================================================================================

Public Function fn_TAHITI_CutoverAndTestServiceWithCustomer()

	Dim dictAttributes
	Dim blnSelected
	Dim intCounter
	Dim strSelectedValue

	Set dictAttributes = CreateObject("Scripting.Dictionary")
	dictAttributes.RemoveAll

	'Get the Attribute Value from Test Data Sheet
	strValues = GetAttributeValue("dCutoverAndTestServiceWithCustomer")
	If strValues = "" Then
		Call ReportLog("Get Attribute Value", "Attribute Values for <B>dCutoverAndTestServiceWithCustomer</B> should be retrieved", "unable to find the Test Data", "FAIL", False)
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
	
	If objFrame.WebList("lstCutoverCompleted").Exist(10) Then
		'Enter CutoverCompleted
		If dictAttributes.Exists("CutoverCompleted") Then
			objFrame.WebList("lstCutoverCompleted").Click
	        Wait 5
			blnResult = selectValueFromList("lstCutoverCompleted", dictAttributes.Item("CutoverCompleted"))
				If Not blnResult Then Envrironment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Input Parameter", "[CutoverCompleted] Input Parameter should be entered for dCutoverAndTestServiceWithCustomer", "Input parameter is missing", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End If
	
	
	If objFrame.WebList("lstCutoverRescheduledDate").Exist(10) Then
		'Enter CutoverCompleted
		If dictAttributes.Exists("CutoverRescheduledDate") Then
			objFrame.WebList("lstCutoverRescheduledDate").Click
	        Wait 5
			blnResult = selectValueFromList("lstCutoverRescheduledDate", dictAttributes.Item("CutoverRescheduledDate"))
				If Not blnResult Then Envrironment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Input Parameter", "[CutoverRescheduledDate] Input Parameter should be entered for dCutoverAndTestServiceWithCustomer", "Input parameter is missing", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

End Function
