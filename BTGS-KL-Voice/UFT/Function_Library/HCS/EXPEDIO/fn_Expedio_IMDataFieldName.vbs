'****************************************************************************************************************************
' Function Name	 	: 	fn_Expedio_FaultQuestionnaire
'
' Purpose	 	 		: Function to get the values of  Customer Type Identifier
'Browser("TYS: *Fault (Modify)").Page("TYS: *Fault (Modify)").Link("Common GUI").Click

' Author	 	 		: Jayasingh SP
'
' Creation Date  : 	05/09/2014
'
' Parameters	 : 	
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_Expedio_IMDataFieldName(dDualHoming)


	'Declaration of Variables
	Dim strDualHomingVal
	
	'Assigning variables
	strDualHomingVal = dDualHoming
	
	''Check for Element Details Page
	
	For intCounter = 1 to 20
	  blnResult = Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Exist
	  If blnResult = "True" Then
	  wait 2
      blnResult = Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Link("lnk1Circuit Details").Exist
	   If blnResult = "True" Then
			Call ReportLog("Circuit Details Page","Should be navigated to Circuit Details Page","Is navigated to Circuit DetailsPage","PASS","")
				Exit For
			Else
				Wait 3
		End If
	End If
 	Next

	If blnResult = "False" Then
		Call ReportLog("Circuit DetailsPage","Should be navigated to Circuit Details Page","Is not navigated to Circuit Details Page","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	
	'Function to build web reference in function

blnResult = BuildWebReference("brw1Element Infomation (apgst318)","pg1Element Infomation (apgst318)" ,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

   'Click on Site Details and  then Invoice Order

blnResult = objPage.Link("lnk1Site Details").Exist
	If blnResult = "True" Then
	Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Link("lnk1Site Details").Click
			If blnResult = objPage.Link("lnk1Onevoice Order").Exist Then
			Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Link("lnk1Onevoice Order").Click
			wait 2
			Else 
					Call ReportLog("Onevoice Order Field","Onevoice Order field should exist","Onevoice Order field does not exist","FAIL","TRUE")
					 Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
				     Call EndReport()
					  Exit Function
			End If
			wait 1
End If


	'Function to build web reference second page in function

blnResult = BuildWebReference("brwExpedioBillofMaterials","pgTYS: DLG: Onevoice Details" ,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	Browser("brwExpedioBillofMaterials").Page("pgTYS: DLG: Onevoice Details").Sync

'Fetching the Customer Type Identifier Value 

blnResult = objPage.WebEdit("txtCustomerTypeIdentifier").Exist
If blnResult = "True" Then
	strCustomerTypeIdentifier =  Browser("brwExpedioBillofMaterials").Page("pgTYS: DLG: Onevoice Details").WebEdit("txtCustomerTypeIdentifier").GetROProperty("innertext")
		If strCustomerTypeIdentifier <> "" Then
				Call ReportLog("CustomerTypeIdentifier value","CustomerTypeIdentifier value should be present"," CustomerTypeIdentifier value is : " & strCustomerTypeIdentifier,"PASS","")
				Browser("brwExpedioBillofMaterials").Page("pgTYS: DLG: Onevoice Details").Link("lnkClose").Click
		 Else 
				Call ReportLog("CustomerTypeIdentifier value","CustomerTypeIdentifier value should be present","CustomerTypeIdentifier value is blank","Warnings","")
				Browser("brwExpedioBillofMaterials").Page("pgTYS: DLG: Onevoice Details").Link("lnkClose").Click
		End If 

		Else
			MsgBox("CustomerType Identifier Blank----TestCase Failed")
			Call ReportLog("Onevoice Order Field","Onevoice Order field should exist","Onevoice Order field does not exist","FAIL","TRUE")
			 Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			 Call EndReport()
			 Exit Function
End If
'Check for Circuit Details Link
 
	For intCounter = 1 to 30
		blnResult = Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Exist
		If blnResult = "True" Then
			Wait 1
			blnResult = Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Link("lnk1Circuit Details").Exist
			If blnResult = "True" Then
				Call ReportLog("Circuit Details Link Page","Should be navigated toCircuit Details Link Page"," Circuit Details  Link Page","PASS","")
				Exit For
			Else
				Wait 1
			End If
		End If
	Next

	If blnResult = "False" Then
		Call ReportLog("Circuit Details  Link Page","Should be navigated to Circuit Details  Link Page","Is not navigated to Circuit Details Link Page Page","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

'	Function to build web reference

blnResult = BuildWebReference("brw1Element Infomation (apgst318)","pg1Element Infomation (apgst318)" ,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Sync
	Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").RefreshObject
'Click on Circuit Details

blnResult = objPage.Link("lnk1Circuit Details").Exist
 If blnResult = "True" Then
    Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Link("lnk1Circuit Details").Click
    Browser("brw1Element Infomation (apgst318)").Page("pg1Element Infomation (apgst318)").Image("imgMenu1ForExtraDetails").Click
'	Window("Windows Internet Explorer").Dialog("Message from webpage").WinButton("OK").Click
	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
End If 


'	Function to build web reference  second page in function
'Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("pgSelection list").Sync
'
'blnResult = BuildWebReference("Selection list -- Webpage","pgSelection list" ,"")
'	If blnResult= "False" Then
'		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
'		Call EndReport()
'		Exit Function
'	End If

'Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("pgSelection list").WebTable("Column 1").Click
For intCounter = 1 to 20
	  blnResult = Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("Selection list").Exist
	  wait(1)
	  If blnResult = "True" Then
		  	iRow =Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("Selection list").WebTable("Column 1").RowCount
			iCol = Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("Selection list").WebTable("Column 1").ColumnCount(1)
			iRowSelect = Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("Selection list").WebTable("Column 1").GetRowWithCellText("No-1")
			 set objWebElement = Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("Selection list").WebTable("Column 1").ChildItem(iRowSelect,1,"WebElement",0)
			set WshShell = CreateObject("WScript.Shell")
			WshShell.SendKeys"{ENTER}"

	  wait 2
	  Call ReportLog("SelectList Page","Should be navigated to SelectListPage","Is navigated to SelectListPage","PASS","")
				Exit For
			Else
				Wait 3
		End If
 	Next

	If blnResult = "False" Then
		Call ReportLog("SelectListPage","Should be navigated to SelectList Page","Is not navigated to SelectList Page","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If



'		objWebElement.Click
'		Window("brwWindows Internet Explorer").Window("Selection list -- Webpage").Page("pgSelection list").WebElement("OK").Click



'	Function to build web reference  third page in function
Browser("brwCircuit Detail (apgst318)").Page("pgCircuit Detail (apgst318)").Sync

blnResult = BuildWebReference("brwCircuit Detail (apgst318)","pgCircuit Detail (apgst318)" ,"")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
'	Browser("brwExpedioBillofMaterials").Page("pgCircuit Detail (apgst318)").Sync

'Checking whether Local DLCI / RemoteDLCI /  DualHoming / CustomerCLI  Value is present

    strLocalDLCI = Browser("brwCircuit Detail (apgst318)").Page("pgCircuit Detail (apgst318)").WebEdit("txtLocalDLCI").GetROProperty("innertext")
	If strLocalDLCI <> "" Then
		Call ReportLog("Local DLCI value","Local DLCI value should be present"," Local DLCI value is : " & strLocalDLCI,"PASS","")
	Else
		Call ReportLog("Local DLCI value","Local DLCI value should be present"," Local DLCI value is blank","Warnings","")
	End If
	

	strRemoteDLCI = Browser("brwCircuit Detail (apgst318)").Page("pgCircuit Detail (apgst318)").WebEdit("txtRemoteDLCI").GetROProperty("innertext")
	If strRemoteDLCI <> "" Then
		Call ReportLog("RemoteDLCI value","RemoteDLCI value should be present"," RemoteDLCI value is : " & strRemoteDLCI,"PASS","")
		Else
		Call ReportLog("RemoteDLCI value","RemoteDLCI value should be present"," RemoteDLCI value is blank","Warnings","")
	End If
	
	strDualHoming = Browser("brwCircuit Detail (apgst318)").Page("pgCircuit Detail (apgst318)").WebEdit("txtDualHoming").GetROProperty("innertext")
	If strDualHoming = strDualHomingVal Then
		Call ReportLog("DualHoming value","DualHoming value should be present"," DualHoming value is : " & strDualHoming,"PASS","")
	Else
			Call ReportLog("DualHoming value","DualHoming value should be present"," DualHoming value is blank","Warnings","")
	End If


	strCustomerDLCI = Browser("brwCircuit Detail (apgst318)").Page("pgCircuit Detail (apgst318)").WebEdit("txtCustomerCLI").GetROProperty("innertext")
	If  strCustomerDLCI <> "" Then
		Call ReportLog("CustomerDLCI value","CustomerDLCI value should be present"," CustomerDLCI value is : " & strCustomerDLCI,"PASS","")
	Else
		Call ReportLog("CustomerDLCI value","CustomerDLCI value should be present","CustomerDLCI value is blank","Warnings","")
	End If
	

	If strCustomerTypeIdentifier = "" or strLocalDLCI = "" or strRemoteDLCI = "" or strDualHoming <> strDualHomingVal or strCustomerDLCI="" Then
		Call ReportLog("ExtraCircuitDetails value ","Mandatory CircuitDetails values should be present ","One or more Mandatory CircuitDetails values are blank ","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function	
	Else 
		Call ReportLog("ExtraCircuitDetails value","ExtraCircuitDetails value should be present"," All Mandatory ExtraCircuitDetails value are present","PASS","")
	End If
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
