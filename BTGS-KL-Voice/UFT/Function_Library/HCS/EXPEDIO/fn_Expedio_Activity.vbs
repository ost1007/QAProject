
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_Aactivity
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder,dExpedioRef
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_Activity(dCustomerVisibleButton)

   Dim strCustomerVisible
	strCustomerVisible = dCustomerVisibleButton

''Click on Contact Details Button
	blnResult  = clickLink("lnkContactdetails")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	Wait(3)

'''''Select Table row
   blnResult = objPage.WebTable("tblActivityId").Exist
	strRow = objPage.WebTable("tblActivityId").RowCount
	strCol = objPage.WebTable("tblActivityId").ColumnCount(strRow)
	 If blnResult Then
'		 Set ObjWebelement = objPage.WebTable("tblCustomername").ChildItem(1,1,"WebElement",0)
'                ObjWebelement.Click
	objPage.WebTable("tblActivityId").object.rows(strRow-1).cells(strCol-1).click

	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
        Call EndReport()
        Exit Function
	 End If

''Select Customert Visible Radio Button
	blnResult  =selectWebRadioGroup("rdCustomerVisible", strCustomerVisible)
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''Click on Pass Button
	blnResult  = clickLink("lnkPass")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

End Function	



