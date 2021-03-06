Public Function fn_SQE_AddCentralSiteContacts(ByVal Role, ByVal JobTitle, ByVal FirstName, ByVal LastName, ByVal Email, ByVal PhoneNumber)
	
	arrFirstName = Split(FirstName, "|")
	arrLastName = Split(LastName, "|")
	arrPhoneNumber = Split(PhoneNumber, "|")
	arrJobTitle = Split(JobTitle, "|")
	arrRole = Split(Role, "|")
	arrEmail = Split(Email, "|")

	For intCounter = 1 To 10
		blnResult = Browser("brwCustomerQuoteManagement").Page("pgCustomerQuoteManagement").WebElement("elmCustomerSite").Exist(30)
		If blnResult Then Exit For
	Next
	
	blnResult = BuildWebReference("brwCustomerQuoteManagement", "pgCustomerQuoteManagement", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = clickWebElement("elmCustomerContacts")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	
	For intCounter = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(10) Then
			Wait 10
		Else
			Exit For
		End If
	Next
		
	For iCounter = 0 to UBound(arrFirstName)
		blnResult = selectValueFromPageList("lstSiteContactRole", arrRole(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		blnResult = enterText("txtSiteContactJobTitle", arrJobTitle(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		blnResult = enterText("txtSiteContactFirstName", arrFirstName(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		blnResult = enterText("txtSiteContactLastName", arrLastName(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		blnResult = enterText("txtSiteContactEmail", arrEmail(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		blnResult = enterText("txtSiteContactPhone", arrPhoneNumber(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		If Not objPage.WebButton("btnCreateSiteContact").Exist(60) Then
			Call ReportLog("Create Button", "Create button should be displayed", "Create button is not displayed", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		Wait 3
		
		If Not objPage.WebButton("btnCreateSiteContact").object.isDisabled Then
			blnResult = clickButton("btnCreateSiteContact")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Wait 5
			If objPage.WebElement("elmSiteContactMsg").Exist(60) Then
				blnResult = objPage.WebElement("elmSiteContactMsg").WaitProperty("height", micGreaterThan(0), 1000*60*2)
				If Not blnResult Then
					Call ReportLog("Create Site Contact", "Site Contact message should appear", "Site creation message did not appear", "FAIL", True)
					Environment("Action_Result") = False: Exit Function
				End If
				blnResult = clickButton("btnOkay")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			End If
		Else
			Call ReportLog("Add Site Contact", arrRole(iCounter) & " - role is already selected", arrRole(iCounter) & " - role is already selected", "Information", False)
		End If
	Next '#iCounter	
End Function
