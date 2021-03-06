'****************************************************************************************************************************
' Function Name	 : fn_BFG_CheckPackageInstance
' Purpose	 	 : Function to Select User Profile, Customer, Site
' Modified By	: Nagaraj V			06/04/2015
' Parameters	 : 	UserProfile, CustomerName, SiteName, PackageName
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public iCheckCounter : iCheckCounter = 0

Public Function fn_BFG_CheckPackageInstance(ByVal UserProfile, ByVal CustomerName, ByVal SiteName, ByVal PackageName)

	'Variable Declaration
	Dim blnResult
	Dim intCounter

	iCheckCounter = iCheckCounter + 1

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
	Wait 10

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
	
	objPage.WebList("cmbCustomer").WaitProperty "items count", micGreaterThan(1), 1000*60*2

	'Select Customer
	blnResult = selectValueFromPageList("cmbCustomer", CustomerName)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	objPage.WebList("cmbSite").WaitProperty "items count", micGreaterThan(1), 1000*60*2
	
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

	If Not objPage.Link("lnkPackageInstance").Exist(5) Then
			If Browser("brwBFG-IMS").Dialog("dlgMessage").Exist(0) Then Browser("brwBFG-IMS").Dialog("dlgMessage").WinButton("btnOK").Click
			objPage.HighLight
			CreateObject("WScript.Shell").SendKeys "{F5}"
			Wait 5
			Call fn_BFG_CheckPackageInstance(UserProfile, CustomerName, SiteName, PackageName)
			If Environment("Action_Result") Then
				Exit Function
			ElseIf Not Environment("Action_Result") Then
				If iCheckCounter >= 5 Then
					Call ReportLog("Package Instance Creation", "Package Instance Link should be Visible", "Link is not Visible", "FAIL", True)
					Exit Function
				End If
			End If
	Else
			For iCounter = 1 to 15
					For intCounter = 1 to 15
						If objPage.Link("lnkPackageInstance").Exist(5) Then Exit For
					Next '#intCounter

					'Click on Package Link Instance
					blnResult = clickLink("lnkPackageInstance")
						If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				
					For intCounter = 1 to 10
						If objPage.WebTable("tblPackageInstanceMain").Exist(10) Then Exit For
					Next '#intCounter
				
					If Not objPage.WebTable("tblPackageInstanceMain").Exist(2) Then
						Call ReportLog("Package Instance", "Package Instances Page should be populated", "Not Navigated to Package Instances Page", "FAIL", True)
						Environment("Action_Result") = False
						Exit Function
					End If
				
					intRow = objPage.WebTable("tblPackageInstanceMain").GetRowWithCellText(PackageName)
				
					If intRow <= 0 Then
						Call ReportLog("Package Instance Creation", "Package Instance <B>" & PackageName & "</B> should be created", PackageName & " is still not created", "Warnings", True)
						If iCounter <> 15 Then
							objPage.Link("lnkSiteSummary").Click
							Wait 60
							objPage.Sync	
						End If
					
					ElseIf intRow >= 1 Then
						Call ReportLog("Package Instance Creation", "Package Instance <B>" & PackageName & "</B> should be created", PackageName & " is created", "PASS", True)
						Environment("Action_Result") = True
						Exit Function
					End If
				Next '#iCounter
	
				Call ReportLog("Package Instance Creation", "Package Instance <B>" & PackageName & "</B> should be created", PackageName & " is not created", "FAIL", True)
				Browser("brwBFG-IMS").Close
				Environment("Action_Result") = False
	End If

	'Browser("brwBFG-IMS").Close
End Function
