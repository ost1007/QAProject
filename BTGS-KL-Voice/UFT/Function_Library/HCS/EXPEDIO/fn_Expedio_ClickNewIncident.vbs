

'****************************************************************************************************************************
' Function Name	 	: 	fn_Expedio_ClickNewIncident
'
' Purpose	 	 		: Function to click on NewIncident Link
'
' Author	 	 		: Linta CK
'
' Creation Date  : 	16/07/2014
'
' Parameters	 : 	dCustomer
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************


Public Function fn_Expedio_ClickNewIncident(dCustomer)

	'Variable Declaration Section
	Dim strCustomer
	Dim blnResult
	Dim intCounter

	'Assignment of Variables
	strCustomer = dCustomer


	'Set BuildWebReference
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBMCRemedyMidTier7.1","pgExpedioIM","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	Browser("brwBMCRemedyMidTier7.1").Page("pgExpedioIM").Sync

	'Enter Customer
	blnResult = objPage.WebEdit("txtCustomer").Exist
	If blnResult= "True" Then
		set WshShell = CreateObject("WScript.Shell")
		blnResult = enterText("txtCustomer",strCustomer)
            If blnResult = "True" Then
			objPage.WebEdit("txtCustomer").Click			
			WshShell.SendKeys (Chr(13))
		Else
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Customer Field","Customer field should exist","Customer field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	For intCounter = 1 to 10
		intReadOnly = objPage.WebEdit("txtCustomer").GetROProperty("readonly")
		If intReadOnly = 1 Then
			Exit For
		Else
			Wait 10
		End If
	Next

	If intReadOnly = 0 Then
		Call ReportLog("Incident List","Incident List should exist for the searched customer - "&strCustomer,"Incident List does not  exist for the searched customer","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	blnResult = objPage.WebEdit("txtCID").Exist
	If blnResult = "True" Then
		For intCounter = 1 to 10
			strRetrievedText = objPage.WebEdit("txtCID").GetROProperty("innertext")
			If strRetrievedText <> "" Then
				Call ReportLog("CID Field","CID Field should be populated upon selecting Customer","CID Field is populated as -  "&strRetrievedText ,"PASS","")

				'Writing data to Excel file
				call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dCID",strRetrievedText)
				Exit For				
			Else
				Wait 5				
			End If
		Next

		If strRetrievedText = "" Then
			Call ReportLog("CID Field","CID Field should be populated upon selecting Customer","CID Field is not populated","FAIL","TRUE")
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else
      	Call ReportLog("CID Field","CID field should exist","CID field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Select Contract
	blnResult = objPage.WebEdit("txtContract").Exist
	If blnResult = "True" Then
		blnResult = objPage.Image("imgMenuForContract").Exist
		If blnResult = "True" Then
			blnResult = clickImage("imgMenuForContract")
			If blnResult = "False" Then				
				Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
				Call EndReport()
				Exit Function
			End If
			blnResult = objPage.WebTable("class:=MenuTable").Exist
			If blnResult = "True" Then
				Set objDesc = Description.Create
				objDesc("micClass").Value = "WebElement"
				objDesc("class").value = "MenuEntryName.*"

				Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
				If objElm.Count >= 1 Then
					Wait 2
                              objElm(0).FireEvent "onmouseover"
					Wait 1
					objElm(0).Click
				End If
			End If
			'clickWebElement("webElmContractName")
			If blnResult = "False" Then				
				Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
				Call EndReport()
				Exit Function
			End If
		End If
	Else
		Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Check if Contract field is populated with value
      For intCounter = 1 to 10
		strRetrievedText = objPage.WebEdit("txtContract").GetROProperty("innertext")
		If strRetrievedText <> "" Then
			Call ReportLog("Contract Field","Contract Field should be populated upon selecting Customer","Contract Field is populated as -  "&strRetrievedText ,"PASS","")

			'Writing data to Excel file
			call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dContract",strRetrievedText)
			Exit For				
		Else
			Wait 5				
		End If
	Next

	If strRetrievedText = "" Then
		Call ReportLog("Contract Field","Contract Field should be populated upon selecting Customer","Contract Field is not populated","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Click on New Incident link
	blnResult = objPage.Link("lnkNewIncident").Exist
	If blnResult = "True" Then
		blnResult = clickLink("lnkNewIncident")
		If blnResult = "False" Then				
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
