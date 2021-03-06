'****************************************************************************************************************************
' Function Name	 : fn_BFG_SelectProfile
' Purpose	 	 : Function to Select User Profile, Customer, Site and Validate Service ID of Root
' Modified By	: Nagaraj V			18/02/2015
' Parameters	 : 	UserProfile, CustomerName, SiteName, ServiceID
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_BFG_SelectProfile(ByVal UserProfile, ByVal CustomerName, ByVal SiteName, ByVal ServiceID)

	'Variable Declaration
	Dim blnResult
	Dim intCounter

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwBFG-IMS","pgBFG-IMS","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Exit Function
	End If

	'Select User Profile
	blnResult = selectValueFromPageList("cmbProfile", UserProfile)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Continue Button after Selecting User Profile
	blnResult = clickButton("btnContinue")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	objPage.Sync
	
	Set objLink = objPage.Link("lnkCustomerSearchList")

	For intCounter = 1 to 100
		If objLink.Exist(2) Then
			Call ReportLog("Search Page", "BFG IMS Search Page should be navigated", "Navigated to BFG IMS Search Page", "PASS", False)
			Exit For
		End If
	Next

	'Click On Customer Search List
	If Not objLink.Exist(0) Then
		Call ReportLog("Search Page", "BFG IMS Search Page should be navigated", "Not Navigated to BFG IMS Search Page", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	Else
		objLink.Click
		Environment("Action_Result") = True
	End If

	objPage.Sync

	'Check the existense and Select the customer name
	Set objList = objPage.WebList("cmbCustomer")
	For intCounter = 1 to 100
		If objList.Exist(2) Then
			Call ReportLog("Search Page", "BFG IMS Search Page should be navigated", "Navigated to BFG IMS Search Page", "PASS", False)
			Exit For
		End If
	Next

	If Not objLink.Exist(0) Then
		Call ReportLog("Search Page", "BFG IMS Search Page should be navigated", "Not Navigated to BFG IMS Search Page", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	'Select Customer
	blnResult = selectValueFromPageList("cmbCustomer", CustomerName)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Select SiteName if it is not Blank or else continue with Central Site
	If SiteName <> "" Then
		blnResult = selectValueFromPageList("cmbSite", SiteName)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	End If

	For intCounter = 1 to 100
		If objPage.WebButton("btnSiteSummary").Object.disabled Then 
			Wait 2
		Else
			Exit For
		End If
	Next

	'Check whether Site Summary Button is enabled and click on it
	If Not objPage.WebButton("btnSiteSummary").Object.disabled Then 
		blnResult = clickButton("btnSiteSummary")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Button Site Summary", "Should be enabled", "Button is disabled", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	For intCounter = 1 to 150
		blnResult = objPage.WebElement("elmResultsSummary").Exist(2)
		If blnResult Then
			Call ReportLog("Results Summary", "Results Summary Page should be populated", "Navigated to Results Summary Page", "PASS", False)
			Exit For
		End If
	Next
	
	If Not blnResult Then
		Call ReportLog("Results Summary", "Results Summary Page should be populated", "Not Navigated to Results Summary Page", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	'Click on Package Link Instance
	blnResult = clickLink("lnkPackageInstance")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	For intCounter = 1 to 10
		If objPage.WebTable("tblPackageInstanceMain").Exist(10) Then
			Exit For
		End If
	Next

	If Not objPage.WebTable("tblPackageInstanceMain").Exist(2) Then
		Call ReportLog("Package Instance", "Package Instances Page should be populated", "Not Navigated to Package Instances Page", "FAIL", True)
		Environment("Action_Result") = False
		Exit Function
	End If

	strServiceID = Trim(objPage.WebTable("tblPackageInstanceMain").GetCellData(2, 1))
	If ServiceID <> "" Then
		If strServiceID = ServiceID Then
			Call ReportLog("Validate Service ID", "Service ID should be written as " & ServiceID, "Validated Service ID", "PASS", True)
			Environment("Action_Result") = True
		Else
			Call ReportLog("Validate Service ID", "Service ID should be written as " & ServiceID, "Service ID is found to be " & strServiceID, "FAIL", True)
			Environment("Action_Result") = False
		End If
	Else
		Call ReportLog("Validate Service ID", "Capture Service ID", "Service ID is found to be " & strServiceID, "PASS", True)
		Environment("Action_Result") = True
	End If
	
End Function
