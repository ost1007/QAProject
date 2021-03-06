'=============================================================================================================
'Description: Function to handle In fn_TAHITI_Confirm Access Dates (Cease)
'History	  : Name				Date			Changes Implemented
'Created By	 :  Nagaraj			16/10/2015 				NA
'Return Values : Not Applicable
'Example: fn_TAHITI_ConfirmAccessDatesCease
'=============================================================================================================
Public Function fn_TAHITI_ConfirmAccessDatesCease()
	
	Dim oDesc
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
		
	'Variable Assignment
	strcurrentdate =  Date
	strmonth = Split(strcurrentdate,"/")
	strcurrentmonth = strmonth(1)
	If strcurrentmonth = "06" OR strcurrentmonth = "07" Then
		strmonth =  MonthName(strcurrentmonth, False)
	ElseIf strcurrentmonth = "09" Then
		strmonth =  Left(MonthName(strcurrentmonth, False), 4)
	Else
		strmonth =  MonthName(strcurrentmonth, True)
	End If
	strdate = Day(Now)
	stryear = Year(Now)
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Set oDesc = Description.Create
	oDesc("micclass").Value = "WebTable"
	oDesc("class").Value = "outputText"
	
	Set objTable = objFrame.ChildObjects(oDesc)
	If objTable.Count <= 0 Then
		Exit Function	
	End If
	
	arrWebEdit = Array("Date Order Received with the Access Supplier: (*)","Access Supplier's Order Approved Date: (*)","Date Access Supplier's Inform BT of Commit Delivery Date: (*)","Access Supplier Stop bill date: (*)")
	
	'Check all Dates are populated or not
	For iCntr = 0 To objTable.Count - 1
		For Each strWebEdit in arrWebEdit
			iRow = objTable(iCntr).GetRowWithCellText(strWebEdit)
			If iRow > 0 Then
				Set objWebEdit = objTable(iCntr).ChildItem(iRow, 2, "WebEdit", 0)
				If Not IsEmpty(objWebEdit) Then
					strRetrievedText = Trim(objWebEdit.GetROProperty("value"))
					If strRetrievedText = "" Then
						Set objImage = objTable(iCntr).ChildItem(iRow, 2, "Image", 0)
						If Not IsEmpty(objImage) Then 
							objImage.Click : Wait 2
							Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
							Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click : Wait 2
						End If '#IsEmpty(objImage)
					Else
						Call ReportLog("Check Mandate Value", "<B>" & strWebEdit & "</B> should be populated", "<B>" & strWebEdit & "</B> is populated with <B>" & strRetrievedText & "</B>", "Information", False)
					End If
				End If '#IsEmpty(objWebEdit)
			End If '#iRow
		Next '#iRow
	Next '#iCntr
	
	'Select Access Order Acceptance
	If objFrame.WebList("lstAccessOrderAccepted").Exist Then
		blnResult = fn_TAHITI_SelectValueFromObject(objFrame.WebList("lstAccessOrderAccepted"), "Accepted")	
		If Not blnResult Then
			Environment("Action_Result") = False : Exit Function			
		End If
	End If
End Function
