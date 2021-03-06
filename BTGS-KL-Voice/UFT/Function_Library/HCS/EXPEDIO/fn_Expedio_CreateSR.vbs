
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_CreateSR
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder,dCustomerName,dCustomerRef,dTitle,dRequestType,dFirstName,dLastName,dPhoneNumber,dEmailID
' Return Values	 : Not Applicable
'****************************************************************************************************************************


Public Function fn_Expedio_CreateSR(dTypeOfOrder,dCustomerName,dCustomerRef,dTitle,dRequestType,dFirstName,dLastName,dPhoneNumber,dEmailID)

   Dim strCustomer,strTitle,strType,strChannel,strFirstNameCopied,strLastNameCopied,strEmailIdCopied,strPhoneNumberCopied,arrFirstName,arrLastName,arrPhoneNumber,arrEmailId
	strCustomerref = dCustomerRef
	strTitle = 	dTitle
	strRequesttype = dRequestType
	strFirstName = dFirstName
	strLasttName = dLastName
	strPhoneNumber =  dPhoneNumber
	strEmailId = dEmailID
	strTypeOfOrder = dTypeOfOrder
	strCustomerName = dCustomerName

	arrFirstName = Split(strFirstName, "|")
	arrLastName = Split(strLasttName, "|")
	arrPhoneNumber = Split(strPhoneNumber, "|")
	arrEmailId = Split(strEmailId, "|")


'''''Set Build Reference
''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBMCRemedyMidTier7.1","pgExpedioOM","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

''Click on Create SR Button
	blnResult  = clickLink("lnkCreateSR")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

'''''''''''''''''''''''''''''''''''
 'Select Contract
                blnResult = objPage.WebEdit("txtCustomerName").Exist
                If blnResult = "True" Then
                                blnResult = objPage.Image("ImgMenuForCustomer").Exist
                                If blnResult = "True" Then
                                                blnResult = clickImage("ImgMenuForCustomer")
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
																	For intCounter = 0 to objElm.Count -1
																					If strCustomerName =objElm(intCounter).GetROProperty("innertext") then 
																					objElm(intCounter).Highlight
																					Wait 2
																					objElm(intCounter).FireEvent "onmouseover"
																					Wait 1
																					objElm(intCounter).Click
																					Exit For
																					End if
																					
																	Next
                                                                End If
                                                End If
                                End If
                Else
                                Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","TRUE")
                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                Call EndReport()
                                Exit Function
                End If
'''''''''''''''''''''''''''''
'''''Enter Customer Reference
    blnResult = enterText("txtCustomerRef",strCustomerref)
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''''Enter Title
    blnResult = enterText("txtTitle",strTitle)
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

'''Enter Request
                blnResult = objPage.WebEdit("txtRequesttype").Exist
                If blnResult = "True" Then
                                blnResult = objPage.Image("ImgMenuforRequesttype").Exist
                                If blnResult = "True" Then
                                                blnResult = clickImage("ImgMenuforRequesttype")
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
																	For intCounter = 0 to objElm.Count -1
																					If strRequesttype =objElm(intCounter).GetROProperty("innertext") then 
																					objElm(intCounter).Highlight
																					Wait 2
																					objElm(intCounter).FireEvent "onmouseover"
																					Wait 1
																					objElm(intCounter).Click
																					Exit For
																					End if
																					
																	Next
                                                                End If
                                                End If
                                End If
                Else
                                Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","TRUE")
                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                Call EndReport()
                                Exit Function
                End If

'''Validating the Type Field
	strType = objpage.WebEdit("txtType").GetROProperty("value")
	If strType= "" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

'''Validating the Channel Field
	strChannel =objPage.WebEdit("txtChannel").GetROProperty("value")
    If strChannel= "" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

'''Enter  First Name in "Request/Originator" Section
    blnResult = enterText("txtFirstName",arrFirstName(0))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

'''Enter  Last Name in "Request/Originator" Section
    blnResult = enterText("txtLastName",arrLastName(0))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

'''Enter Phone Number in "Request/Originator" Section
    blnResult = enterText("txtPhoneNumber",arrPhoneNumber(0))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

'''Enter Email ID in "Request/Originator" Section
    blnResult = enterText("txtEmailId",arrEmailId(0))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

'''Click on Copy Button
	blnResult  = clickLink("lnkCopy")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If
'

'''Validating the First Name in Delegate Requestor/Contact Section
	strFirstNameCopied = objPage.WebEdit("txtFirstNameCopied").GetROProperty("value")
	If strFirstNameCopied= "" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
'		Exit Function
	End If

''Validating the Last Name in Delegate Requestor/Contact Section
	strLastNameCopied = objPage.WebEdit("txtLastNameCopied").GetROProperty("value")
	If strLastNameCopied= "" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
'		Exit Function
	End If

''Validating the Phone Number in Delegate Requestor/Contact Section
	strPhoneNumberCopied = objPage.WebEdit("txtPhoneNumberCopied").GetROProperty("value")
	If strPhoneNumberCopied= "" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
'		Exit Function
	End If

'Validating the Email Id in Delegate Requestor/Contact Section
	strEmailIdCopied = objPage.WebEdit("txtEmailIdCopied").GetROProperty("value")
	If strEmailIdCopied= "" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
'		Exit Function
	End If	

'''Click on SaveSR Button
	blnResult  = clickLink("lnkSaveSR")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
'	Exit Function
	End If

	blnResult  = WebElementExist("webElmAddSites")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call ReportLog("Add Sites","User navigation should be succesful","Add Sites is not loaded" ,"FAIL","TRUE")
	Call EndReport()
	Exit Function
	Else
	Call ReportLog("Add Sites","User navigation should be succesful","Add Sites is successfully Displayed" ,"PASS","TRUE")
	End If
End Function
