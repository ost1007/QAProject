
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_AddSites
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_Expedio_AddSites(dTypeOfOrder)

   Dim strExpedioRef,strTypeOfOrder,strRow,strCol
    strTypeOfOrder = dTypeOfOrder
    
	''''Set Build Reference
''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBMCRemedyMidTier7.1","pg"&strTypeOfOrder,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
'''
'''''''''	'Click on Add Site Button
	blnResult  = clickLink("lnkAddsite")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If
'
'	''''Set Build Reference
'''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwconsole(Search)","pgEXPMultiSiteAdd","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
'
''''''''''''	'Click on Search Site Button
	blnResult  = clickLink("lnkSearchsites")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If
' 
	 blnResult = objPage.WebTable("tblCustomername").Exist
	strRow = objPage.WebTable("tblCustomername").RowCount
	strCol = objPage.WebTable("tblCustomername").ColumnCount(strRow)
	 If blnResult Then
'		 Set ObjWebelement = objPage.WebTable("tblCustomername").ChildItem(1,1,"WebElement",0)
'                ObjWebelement.Click
	objPage.WebTable("tblCustomername").object.rows(strRow-1).cells(strCol-1).click

	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
        Call EndReport()
        Exit Function
	 End If
'
'''''''	'Click on Add Selected Site Button
	blnResult  = clickLink("lnkAddselectedsites")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''''''''''''Need to clarify whether click on Update contacts button is required, Its not required
'''''''''''	'Click on Update Contact Button
''''''''''	blnResult  = clickLink("lnkUpdatecontacts")
''''''''''	If blnResult = "False" Then		
''''''''''    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
''''''''''	Call EndReport()
''''''''''	Exit Function
''''''''''	End If

	'Click on Add sites to BoM Button
	blnResult  = clickLink("lnkAddsitestoBoM")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If
'
'	''''Set Build Reference
'''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwconsole(Search)","pgEXPMultiSiteAdd","frmPopup")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
'''
''''Click on Pop up OK Button
	Set ObjLink = ObjFrame.Link("lnkOK")
	If ObjLink.Exist Then
		ObjLink.highlight
		ObjLink.click
     End If
	

''''	blnResult  =clickFrameLink("lnkOK")
''	If blnResult = "False" Then		
''    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
''	Call EndReport()
''	Exit Function
''	End If

		''''Set Build Reference
''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBMCRemedyMidTier7.1","pg"&strTypeOfOrder,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If



'''Set ObjLink = ObjPage.Link("lnkSaveSR")
'''	If ObjLink.Exist Then
'''		ObjLink.highlight
'''		ObjLink.click
'''     End If
'
Browser("brwBMCRemedyMidTier7.1").Page("pgExpedioOM").Link("lnkSaveSR").Click

'Click on Save SR Button
'	blnResult  = clickLink("lnkSaveSR")
'	If blnResult = "False" Then		
'    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
'	Call EndReport()
'	Exit Function
'	End If

'''Fetching the Expedio Reference Number
	blnResult = objPage.Link("lnkExpedioReference").Exist
	If blnResult Then
		strExpedioRef = objPage.Link("lnkExpedioReference").GetROProperty("innertext")
		If strExpedioRef <> "" Then
'		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
        Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dExpedioRef",strExpedioRef)
        Else
		Call ReportLog("Expedio Reference","Expedio Reference Should generate","Expedio Reference is not generated" ,"FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Exit Function
        End If
	End if	

	End Function
