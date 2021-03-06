
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_AddContacts
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder,dExpedioRef
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_AddContacts(dTypeOfOrder,dExpedioRef,dContractType,dFirstName,dLastName,dPhoneNumber,dEmailID,dKCIButton)

   Dim strExpedioRef,strTypeOfOrder,strContracttype,strFirstName,strLastName,strPhoneNumber,strEmailId,arrFirstName,arrLastName,arrPhoneNumber,arrEmailId
    strTypeOfOrder = dTypeOfOrder
	strExpedioRef = dExpedioRef
	strContracttype = dContractType
	strFirstName = dFirstName
	strLastName = dLastName
	strPhoneNumber = dPhoneNumber
	strEmailId = dEmailID
	strKCI = dKCIButton

    arrFirstName = split(strFirstName,"|")
	arrLastName = split(strLastName,"|")
	arrPhoneNumber = split(strPhoneNumber,"|")
	arrEmailId = split(strEmailId,"|")

	''''Set Build Reference
''''Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSRoverview","pgContactDetails","")
	If blnResult= "False" Then
		Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
		Call EndReport()
		Exit Function
	End If

''Click on Contact Details Button
	blnResult  = clickLink("lnkContactdetails")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

For intCounter = 0 to 4

''''''''''''''''''''''''''''''''''
 'Select Contract
                blnResult = objPage.WebEdit("txtContracttype").Exist
                If blnResult = "True" Then
                                blnResult = objPage.Image("ImgMenuforContacttype").Exist
                                If blnResult = "True" Then
                                                blnResult = clickImage("ImgMenuforContacttype")
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
																					If strContracttype =objElm(intCounter).GetROProperty("innertext") then 
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
''''Enter First Name
    blnResult = enterText("txtFirstName",arrFirstName(i))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	'''Enter Last Name
    blnResult = enterText("txtCustomerlastname",arrLastName(i))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	''Enter Email Id
    blnResult = enterText("txtPhoneNumber",arrPhoneNumber(i))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	'Enter Email Id
    blnResult = enterText("txtEmailId",arrEmailId(i))
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

''Select KCR Radio Button
	blnResult  =selectWebRadioGroup("rdGrpSendKCIEmail", strKCI)
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

	''Click on Add Button
	blnResult  = clickLink("lnkAdd")
	If blnResult = "False" Then		
    Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
	Call EndReport()
	Exit Function
	End If

 Next

 End function
