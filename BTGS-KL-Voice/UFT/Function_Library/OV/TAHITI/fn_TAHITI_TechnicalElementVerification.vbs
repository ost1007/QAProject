'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_TechnicalElementVerification
' Purpose	 	 : Function to Verify technical Elements displayed in Application
' Author	 	  	: Nagaraj V || 19/11/2015 || #N/A
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_TAHITI_TechnicalElementVerification(ByVal TechnicalElementName, ByVal TechnicalElementValue, ByVal TechnicalElementPresence)
	'Variable Declaration
	Dim arrTechElmNames, arrTechElmValues, arrTechElmPresence
	Dim strTechElmName, strTechElmValue, strActualTechElmValue, strTechElement
	Dim intCounter, intSourceIndex
	Dim blnFail
	
	'Varaible Initialization
	arrTechElmNames = Split(TechnicalElementName, "|")
	arrTechElmValues = Split(TechnicalElementValue, "|")
	arrTechElmPresence = Split(TechnicalElementPresence, "|")
	
	'Checking whether TechnicalElementName = TechnicalElementValue in Count
	If UBound(arrTechElmNames) <>  UBound(arrTechElmValues) Then
		Call ReportLog("Mismatch in Test Data", "Mismatch in Techinical Element Name and Technical Element Value", "TechnicalElementName has attributes " & UBound(arrTechElmNames) &_
		"</BR>TechnicalElementValue has attributes " & 	 UBound(arrTechElmValues), "FAIL", False)
		Environment("Action_Result") = False : Exit Function
	End If
	
	'Building Reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	blnFail = False
	For intCounter = LBound(arrTechElmNames) To UBound(arrTechElmNames)
		strTechElmName = Trim(arrTechElmNames(intCounter))
		strTechElmValue = Trim(arrTechElmValues(intCounter))
		Set objElm = objFrame.WebElement("html tag:=TD", "innertext:=" & strTechElmName, "index:=0")
		If objElm.Exist(10) Then
			intSourceIndex = objElm.GetROProperty("source_index")
			strActualTechElmValue = Trim(objFrame.WebElement("source_index:=" & (intSourceIndex + 1)).GetROProperty("innerText"))
			If strActualTechElmValue =  strTechElmValue Then
				Call ReportLog("Technical Element Check", "<B>" & strTechElmName & "</B> should contain <B>" & strTechElmValue & "</B>",_
					"<B>" & strTechElmName & "</B> contains <B>" & strActualTechElmValue & "</B>", "PASS", False)
			Else
				Call ReportLog("Technical Element Check", "<B>" & strTechElmName & "</B> should contain <B>" & strTechElmValue & "</B>",_
					"<B>" & strTechElmName & "</B> contains <B>" & strActualTechElmValue & "</B>", "FAIL", True)
				blnFail = True
			End If
		Else
			Call ReportLog("Technical Element Check", "<B>" & strTechElmName & "</B> should be visible", "<B>" & strTechElmName & "</B> is not visible", "FAIL", True)
		End If
	Next '#intCounter
	
	For intCounter = LBound(arrTechElmPresence) To UBound(arrTechElmPresence)
		strTechElement = Trim(arrTechElmPresence(intCounter))
		Set objElm = objFrame.WebElement("html tag:=STRONG", "innertext:=" & strTechElement & "\s*", "index:=0")
		If objElm.Exist(10) Then
			Call ReportLog("Technical Elm. Presence", strTechElement & " - should be visible", strTechElement & " - is visible", "PASS", False)
		Else
			Call ReportLog("Technical Elm. Presence", strTechElement & " - should be visible", strTechElement & " - is not present", "FAIL", False)
		End If
	Next '#intCounter
	
	Environment("Action_Result") = True
End Function
