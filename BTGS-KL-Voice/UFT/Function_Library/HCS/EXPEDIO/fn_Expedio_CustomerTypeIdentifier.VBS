'****************************************************************************************************************************
' Function Name	 	: 	fn_Expedio_FaultQuestionnaire
'
' Purpose	 	 		: Function to get the values of  Customer Type Identifier
'Browser("TYS: *Fault (Modify)").Page("TYS: *Fault (Modify)").Link("Common GUI").Click

' Author	 	 		: Jayasingh SP
'
' Creation Date  : 	03/09/2014
'
' Parameters	 : 	
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_CustomerTypeIdentifier()

'Variable Declaration Section
Dim blnResult
Dim intCounter


'Check for Common Gui  Link


	For intCounter = 1 to 30
		blnResult = Browser("brwRef :XF04199190").Page("pgRef :XF04199193").Exist
		If blnResult = "True" Then
			Wait 1
			blnResult =Browser("brwRef :XF04199190").Page("pgRef :XF04199193").Link("lnkCommon GUI").Exist
			If blnResult = "True" Then
				Call ReportLog("Common GUI Link Page","Should be navigated toCommon GUI Link Page"," Common GUI Link Page","PASS","")
				Exit For
			Else
				Wait 1
			End If
		End If
	Next

	If blnResult = "False" Then
		Call ReportLog("Common GUI Link Page","Should be navigated to Common GUI Link Page","Is not navigated to Common GUI Link Page Page","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Function to build web reference

	blnResult = BuildWebReference("brwRef :XF04199190","pgRef :XF04199193" ,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	Browser("brwRef :XF04199190").Page("pgRef :XF04199193").Sync

blnResult = objPage.Link("lnkSave").Exist
	If blnResult = "True" Then
		Browser("brwRef :XF04199190").Page("pgRef :XF04199193").Link("lnkSave").Click
	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function


   End If


   'Click on Element Details

blnResult = objPage.Link("lnkElement Information").Exist
	If blnResult = "True" Then
		Browser("brwRef :XF04199190").Page("pgRef :XF04199193").Link("lnkElement Information").Click
	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function

   End If

	Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Sync
	
	For intCounter = 1 to 30
	  blnResult = Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Exist
	    wait (3)
	  If blnResult = "True" Then
	  wait (2)
      blnResult = Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Link("lnk1Circuit Details").Exist
	   If blnResult = "True" Then
			Call ReportLog("Circuit Details Page","Should be navigated to Circuit Details Page","Is navigated to Circuit DetailsPage","PASS","")
				Exit For
			Else
				Wait (3)
		End If
	End If
 	Next

	If blnResult = "False" Then
		Call ReportLog("Circuit DetailsPage","Should be navigated to Circuit Details Page","Is not navigated to Circuit Details Page","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
		wait (2)
		Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").RefreshObject

	'Function to build web reference  for second page in function

blnResult = BuildWebReference("brw1Element Infomation (apgst318)","pg1Element Infomation (apgst318)" ,"")
	If blnResult= "False" Then
		MsgBox("fail")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If


'Click on Circuit Details

blnResult = objPage.Link("lnk1Circuit Details").Exist
 If blnResult = "True" Then
    Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Link("lnk1Circuit Details").Click
	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
End If
End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
