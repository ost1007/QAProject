'****************************************************************************************************************************
' Function Name	 	: 	fn_Expedio_FaultQuestionnaire
'
' Purpose	 	 		: Function to enter values in Fault Questionnaire
'
' Author	 	 		: Linta CK & Jayasingh SP
'
' Creation Date  : 	24/07/2014
'
' Parameters	 : 	
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************


Public Function fn_Expedio_FaultQuestionnaire(dCID,dCustomer,dContract,dCustomerName,dCustomerTelNo,dProactivityValue,dIncidentDescription,dTier1Value,dTier2Value,dTier3Value)

	'Declaration of Variables
	Dim obj
	Dim strProactivityValue
	Dim strIncidentDescription
	Dim strTier1Value
	Dim strTier2Value
	Dim strTier3Value
	
	'Assigning variables
	strCID = dCID
	strCustomer = dCustomer
	strContract = dContract
	strdCustomerName = dCustomerName
	strdCustomerTelNo = dCustomerTelNo
	strProactivityValue = dProactivityValue
	strIncidentDescription = dIncidentDescription
	strTier1Value = dTier1Value
	strTier2Value = dTier2Value
	strTier3Value = dTier3Value
	
	'Check for Expedio Fault Questionnaire Page
	Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").RefreshObject
	For intCounter = 1 to 30
		blnResult = Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").Exist
		If blnResult = "True" Then
			Wait 2
			blnResult = Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").WebElement("webElmExpedioIncidentQuestionnaire").Exist
			If blnResult = "True" Then
				Call ReportLog("Expedio Fault Questionnaire Page","Should be navigated to Expedio Fault Questionnaire Page","Is navigated to Expedio Fault Questionnaire Page","PASS","")
				Exit For
			Else
				Wait 10
			End If
		End If
	Next

	If blnResult = "False" Then
		Call ReportLog("Expedio Fault Questionnaire Page","Should be navigated to Expedio Fault Questionnaire Page","Is not navigated to Expedio Fault Questionnaire Page","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Function to build web reference
	blnResult = BuildWebReference("brwExpedioCreationTime1","pgTYS:FaultQuestionnaire","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").Sync

	'Check CID is populated
	If objPage.WebEdit("txtCID+").Exist Then
		strText = objPage.WebEdit("txtCID+").GetROProperty("innertext")
		If Trim(strText) = Trim(strCID) Then
			Call ReportLog("CID Field","CID field should be populated with "&strCID,"CID field is populated with "&strText,"PASS","")
		Else
			Call ReportLog("CID Field","CID field should be populated with "&strCID,"CID field is not populated","FAIL","True")
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else
		Call ReportLog("CID Field","CID field should exist","CID field does not exist","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Check Customer is populated
		If objPage.WebEdit("txtCustomer+").Exist Then
		strText = objPage.WebEdit("txtCustomer+").GetROProperty("innertext")
		If Trim(strText) = Trim(strCustomer) Then
			Call ReportLog("Customer Field","Customer field should be populated with "&strCustomer,"Customer field is populated with "&strText,"PASS","")
		Else
      		Call ReportLog("Customer Field","Customer field should be populated with "&strCustomer,"Customer field is not populated","FAIL","True")
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else
		Call ReportLog("Customer Field","Customer field should exist","Customer field does not exist","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Check Contract is populated
	If objPage.WebEdit("txtContract+").Exist Then
		strText = objPage.WebEdit("txtContract+").GetROProperty("innertext")
		If Trim(strText) = Trim(strContract) Then
			Call ReportLog("Contract Field","Contract field should be populated with "&strContract,"Contract field is populated with "&strText,"PASS","")
		Else
			Call ReportLog("Contract Field","Contract field should be populated with "&strContract,"Contract field is not populated","FAIL","True")
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else
		Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","True")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").RefreshObject
	Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").Sync

	'Enter % in Site field and Enter
	If objPage.WebEdit("txtSite+").Exist Then
            set WshShell = CreateObject("WScript.Shell")
			wait(5)
		blnResult = enterText("txtSite+","%")
            If blnResult = "True" Then
			objPage.WebEdit("txtSite+").Click			
			WshShell.SendKeys (Chr(13))
		Else
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Site Field","Site field should exist","Site field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	For intCounter = 1 to 10
		intReadOnly = objPage.WebEdit("txtSite+").GetROProperty("readonly")
		If intReadOnly = 1 Then
			strText = objPage.WebEdit("txtSite+").GetROProperty("innertext")
			Call ReportLog("Site Field","Site field should be populated","Site field is populated with value - "&strText,"PASS","")

			'Writing data to Excel file
			call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"),StrTCID,"dSite",strText)
			Exit For
		Else
			Wait 5
		End If
	Next

	If intReadOnly = 0 Then
		Call ReportLog("Site Field","Site field should be populated","Site field is not populated","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	'Select Element

	'Enter % in Element field and press Enter
	If objPage.WebEdit("txtElement+").Exist Then
            set WshShell = CreateObject("WScript.Shell")
		blnResult = enterText("txtElement+","%")
            If blnResult = "True" Then
			objPage.WebEdit("txtElement+").Click			
			WshShell.SendKeys (Chr(13))
		Else
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Element Field","Element field should exist","Element field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

	For intCounter = 1 to 10
		blnResult = objBrowser.Window("wndSelection list--Webpage").Page("pgSelectionList").WebTable("webTblElements").Exist
		If blnResult = "True" Then
			intRow = objBrowser.Window("wndSelection list--Webpage").Page("pgSelectionList").WebTable("webTblElements").GetRowWithCellText(strElement,2,6)
			
			If intRow >= 6 Then
				Set objPrdctElm = objBrowser.Window("wndSelection list--Webpage").Page("pgSelectionList").WebTable("webTblElements").ChildItem(intRow,2,"WebElement",0)
				If IsObject(objPrdctElm) = True Then
					objPrdctElm.Click
					Wait 3
					objBrowser.Window("wndSelection list--Webpage").Page("pgSelectionList").Link("lnkOK").Click
				End If
				Call ReportLog("Element Field","Required Element should be displayed in the list","Required Element is displayed in the list","PASS","")
				Exit For
			End If
		Else
			Wait 5
		End If
	Next

	If intRow < 2 Then
		Call ReportLog("Element Field","Element field should be displayed in the list","Required Element is not displayed in the list","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

      'Function to build web reference
	blnResult = BuildWebReference("brwExpedioCreationTime1","pgTYS:FaultQuestionnaire","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").Sync
	
	'Enter CustomerName
   blnResult = objPage.WebEdit("txtcustomersName+").Exist
	If blnResult= "True" Then
		set WshShell = CreateObject("WScript.Shell")
		blnResult = enterText("txtcustomersName+",strdCustomerName)
            If blnResult = "True" Then
			Wait 2
		Else
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("CustomerName Field","CustomerName field should exist","CustomerName field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	
	'Enter CustomerTelNo
	blnResult = objPage.WebEdit("txtCustomersTelNo").Exist
	If blnResult= "True" Then
		set WshShell = CreateObject("WScript.Shell")
		blnResult = enterText("txtCustomersTelNo",strdCustomerTelNo)
            If blnResult = "True" Then
			Wait 2
		Else
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("CustomerTelNo","CustomerTelNo field should exist","CustomerTelNo field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	
	'Select the Severity Value
	blnResult = objPage.WebEdit("txtSeverity").Exist
	If blnResult = "True" Then
		set obj = Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").WebEdit("txtSeverity")
		Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").Image("imgMenuForSeverity").Click
		iRow =Browser("brwExpedioCreationTime1").Window("wndSelection list--Webpage").Page("pgSelectionList").WebTable("Column 1").RowCount
		iCol = Browser("brwExpedioCreationTime1").Window("wndSelection list--Webpage").Page("pgSelectionList").WebTable("Column 1").ColumnCount(1)
		iRowSelect = Browser("brwExpedioCreationTime1").Window("wndSelection list--Webpage").Page("pgSelectionList").WebTable("Column 1").GetRowWithCellText("P4")
		 set objWebElement = Browser("brwExpedioCreationTime1").Window("wndSelection list--Webpage").Page("pgSelectionList").WebTable("Column 1").ChildItem(iRowSelect,1,"WebElement",0)
		objWebElement.Click
		Browser("brwExpedioCreationTime1").Window("wndSelection list--Webpage").Page("pgSelectionList").Link("lnkOK").Click
	Else
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If
	
	'Select the Proactivity Value
	
	blnResult = objPage.WebEdit("txtProactivity").Exist
	If blnResult = "True" Then
		Set obj = Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").WebEdit("txtProactivity")
		Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").Image("imgMenuForProactivity").Click
 'For clicking an option in the list

	blnResult = objPage.WebTable("class:=MenuTable").Exist
	rowCnt = Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("Alarm detected & incident").RowCount
	For strIterator = 1 to rowCnt
	strcellData = Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("Alarm detected & incident").GetCellData(strIterator,1)
	If strcellData = strProactivityValue Then
	webElmNumber = strIterator-1
	wait 1
	End If
	Next
 If blnResult = "True" Then
	Set objDesc = Description.Create
	objDesc("micClass").Value = "WebElement"
	objDesc("class").value = "MenuEntryName.*"
	Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
		If objElm.Count >= 1 Then
		Wait 2
		objElm(webElmNumber).FireEvent "onmouseover"
		Wait 1
		objElm(webElmNumber).Click
		End If
 End If
End If

'Enter the Description
 blnResult = objPage.WebEdit("txtIncidentDescription").Exist
	If blnResult= "True" Then
		set WshShell = CreateObject("WScript.Shell")
		blnResult = enterText("txtIncidentDescription",strIncidentDescription)
            If blnResult = "True" Then
			Wait 2
		Else
			Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Description Field","Description  field should exist","Description  field does not exist","FAIL","TRUE")
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If


'Select the Tier1 Value

	blnResult = objPage.Image("imgPCMenuForTier1").Exist
	If blnResult = "True" Then
		Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").Image("imgPCMenuForTier1").Click
		
 'For clicking an option in the list

	blnResult = objPage.WebTable("class:=MenuTable").Exist
	rowTier1Cnt = Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("BAU FAILURE").RowCount
	For strIterator = 1 to rowTier1Cnt
	strcellData =Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("BAU FAILURE").GetCellData(strIterator,1)
	If strcellData = strTier1Value Then
	webElmNumber = strIterator-1
	wait 1
	End If
	Next
 If blnResult = "True" Then
	Set objDesc = Description.Create
	objDesc("micClass").Value = "WebElement"
	objDesc("class").value = "MenuEntryName.*"
	Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
		If objElm.Count >= 1 Then
		Wait 2
		objElm(webElmNumber).FireEvent "onmouseover"
		Wait 1
		objElm(webElmNumber).Click
		End If
 End If
End If


'Select the Tier2 Value

	blnResult = objPage.Image("imgPCMenuForTier2").Exist
	If blnResult = "True" Then
		Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").Image("imgPCMenuForTier2").Click
		
 'For clicking an option in the list

	blnResult = objPage.WebTable("class:=MenuTable").Exist
	rowTier1Cnt = Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("CUSTOMER PROBLEM").RowCount
	For strIterator = 1 to rowTier1Cnt
	strcellData =Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("CUSTOMER PROBLEM").GetCellData(strIterator,1)
	If strcellData = strTier2Value Then
	webElmNumber = strIterator-1
	wait 1
	End If
	Next
 If blnResult = "True" Then
	Set objDesc = Description.Create
	objDesc("micClass").Value = "WebElement"
	objDesc("class").value = "MenuEntryName.*"
	Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
		If objElm.Count >= 1 Then
		Wait 2
		objElm(webElmNumber).FireEvent "onmouseover"
		Wait 1
		objElm(webElmNumber).Click
		End If
 End If
End If



'Select the Tier3 Value

	blnResult = objPage.Image("imgPCMenuForTier3").Exist
	If blnResult = "True" Then
		Browser("brwExpedioCreationTime1").Page("pgTYS:FaultQuestionnaire").Image("imgPCMenuForTier3").Click
		
 'For clicking an option in the list

	blnResult = objPage.WebTable("class:=MenuTable").Exist
	rowTier1Cnt = Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("ACCESS/PASSWORD/SERVICE").RowCount
	For strIterator = 1 to rowTier1Cnt
	strcellData =Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebTable("ACCESS/PASSWORD/SERVICE").GetCellData(strIterator,1)
	If strcellData = strTier3Value Then
	webElmNumber = strIterator-1
	wait 1
	End If
	Next
 If blnResult = "True" Then
	Set objDesc = Description.Create
	objDesc("micClass").Value = "WebElement"
	objDesc("class").value = "MenuEntryName.*"
	Set objElm = objPage.WebTable("class:=MenuTable").childObjects(objDesc)
		If objElm.Count >= 1 Then
		Wait 2
		objElm(webElmNumber).FireEvent "onmouseover"
		Wait 1
		objElm(webElmNumber).Click
		End If
 End If
	Browser("brwExpedioCreationTime1").Page("pgTYS: Fault Questionnaire").WebElement("lnkOK").Click
End If
End Function
'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
