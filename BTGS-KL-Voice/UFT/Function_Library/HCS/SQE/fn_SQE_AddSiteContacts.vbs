Public Function fn_SQE_AddSiteContacts(ByVal SiteName, ByVal FirstName, ByVal LastName, ByVal PhoneNumber, ByVal JobTitle, ByVal Role)

	Dim arrFirstName, arrLastName, arrPhoneNumber, arrJobTitle, arrRole
	Dim elmSite
	Dim intInitWait, iWaitCntr
	
	
	
	
	
	arrFirstName = Split(FirstName, "|")
	arrLastName = Split(LastName, "|")
	arrPhoneNumber = Split(PhoneNumber, "|")
	arrJobTitle = Split(JobTitle, "|")
	arrRole = Split(Role, "|")

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwCustomerQuoteManagement","pgCustomerQuoteManagement","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	blnResult = clickWebElement("elmSiteContacts")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Set elmSite = objPage.WebElement("class:=ng-binding","html tag:=SPAN","innertext:=" & SiteName, "index:=0")
	If Not elmSite.Exist(120) Then
		Call ReportLog("Create Site Contact", SiteName & " - should be visible", SiteName & " - site is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	elmSite.Highlight
	elmSite.Click
	
	intInitWait = 30
	For iWaitCntr = 1 To 30
		If objPage.WebElement("elmPleaseWait").Exist(intInitWait) Then
			intInitWait = 10
			Wait 10
		Else
			Exit For '#iWaitCntr
		End If	
	Next '#iWaitCntr
	
	
	For iCounter = 0 to UBound(arrFirstName)
		blnResult = selectValueFromPageList("lstSiteContactRole", arrRole(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		blnResult = enterText("txtSiteContactJobTitle", arrJobTitle(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		blnResult = enterText("txtSiteContactFirstName", arrFirstName(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		blnResult = enterText("txtSiteContactLastName", arrLastName(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		strEMailID = arrFirstName(iCounter) & "." & arrLastName(iCounter) & "@bt.com"
		blnResult = enterText("txtSiteContactEmail", strEMailID)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		blnResult = enterText("txtSiteContactPhone", arrPhoneNumber(iCounter))
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		If Not objPage.WebButton("btnCreateSiteContact").Exist(60) Then
			Call ReportLog("Create Button", "Create button should be displayed", "Create button is not displayed", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		
		If Not objPage.WebButton("btnCreateSiteContact").object.isDisabled Then
			blnResult = clickButton("btnCreateSiteContact")
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Wait 20
			If objPage.WebElement("elmSiteContactCreateMsg").Exist(60) Then
				blnResult = objPage.WebElement("elmSiteContactCreateMsg").WaitProperty("height", micGreaterThan(0), 1000*60*2)
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
	
	blnNavigatedToInitialScreen = False
	strAdditonalDetails = ""
	Set elmAdditionalInfo = objPage.WebElement("class:=additionalInfo", "index:=0")
	With elmAdditionalInfo
		If Not .Exist(60) Then
			Call ReportLog("Additional Info", "Additional Info header containing customer details should be displayed", "Additional Info header is not displayed", "Information", True)
		Else
			strAdditonalDetails = .GetROProperty("innerText")
		End If
	End With
		
	'Navigating to Manage Quotes after creation of Site
	blnResult = clickWebElement("elmManageQuotes")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 3
		objBrowser.fSync
	Next
		
	For iWaitCntr = 1 To 50
		If objPage.WebElement("elmPleaseWait").Exist(5) Then
			Wait 5
		Else
			Exit For '#iWaitCntr
		End If	
	Next '#iWaitCntr
	
	If objPage.Link("lnkExistingCustomer").Exist(30) Then
		If strAdditonalDetails = "" Then
			Call ReportLog("Navigation Error", "On clicking Manage Quotes it should navigate to Quotes Page", "Navigation has moved to Select Customer Page and Additional detail has thrown eror", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			blnResult = fn_SQE_GetCustomerDetails(strAdditonalDetails, SalesChannel, CustomerName)
			If Not blnResult Then
				Call ReportLog("Capture Data", "SalesChannel & CustomerName should be captured", "SalesChannel/CustomerName is not captured", "FAIL", False)
				Environment("Action_Result") = False : Exit Function
			End If
			
			blnResult = fn_SQE_SearchCustomerAndNavigate(SalesChannel, CustomerName, "ManageQuote")
				If Not Environment("Action_Result") Then Exit Function
		End If
	End If
	
End Function
