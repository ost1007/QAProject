
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_Search
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder,dExpedioRef
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_Search(dTypeOfOrder,dExpedioRef)

   Dim strExpedioRef,strTypeOfOrder
    strTypeOfOrder = dTypeOfOrder
	strExpedioRef = dExpedioRef

''''Set Build Reference
''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBMCRemedyMidTier7.1","pg"&strTypeOfOrder,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

'Click on Create SR Button
	blnResult  = clickLink("lnkSearchSR")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	'''''Enter Expedio Reference
    blnResult = enterText("txtExpedioRef",strExpedioRef)
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	''Click on Search Button
	blnResult  = clickLink("lnkSearch")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

'''''   Need to add the code for Validate & Assign Task  given at page no. 4 in Exp_Automation doc file

 blnResult = objPage.WebTable("tblCustomername").Exist
 If blnResult = "True" Then
 	strRow = objPage.WebTable("tblCustomername").RowCount
	strCol = objPage.WebTable("tblCustomername").ColumnCount(strRow)
'		 Set ObjWebelement = objPage.WebTable("tblCustomername").ChildItem(1,1,"WebElement",0)
'                ObjWebelement.Click
	objPage.WebTable("tblCustomername").object.rows(strRow-1).cells(strCol-1).click
        Set objDesc = Description.Create
        objDesc("micClass").Value = "WebElement"
		  Set objElm = objPage.WebTable("class:=BaseTable").childObjects(objDesc)
          If objElm.Count >= 1 Then
              Wait 2
              objElm.FireEvent "ondblclick"
          End If
	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
        Call EndReport()
        Exit Function
End If
 
End Function
