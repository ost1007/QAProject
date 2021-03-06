'==========================================================================================================================================
' Function Name	 : fn_TAHITI_VLP_UploadCSVFile
' Purpose	 	 : Login to VLP Application and Upload the CSV File
' Modified By	: Nagaraj V			22/07/2015
' Parameters	 : 	URL, UserID, Password, FileName, Country, Product
' Return Values	 : Not Applicable
'==========================================================================================================================================
Public Function fn_TAHITI_VLP_UploadCSVFile(ByVal URL, ByVal UserID, ByVal Password, ByVal FileName, ByVal Country, ByVal Product, ByVal CustomerID)
	Call fnc_TAHITI_VLP_Login(URL, UserID, Password)
		If Not Environment("Action_Result") Then Exit Function

	Call fn_TAHITI_VLP_UploadFile(FileName, Country, Product, CustomerID)
		If Not Environment("Action_Result") Then Exit Function
End Function
'==========================================================================================================================================
' Description: Login to VLP Application
'==========================================================================================================================================
Public Function fnc_TAHITI_VLP_Login(ByVal URL, ByVal UserID, ByVal Password)

	'Variable Declaration Section
	Dim strSILogin,strMessage
	Dim objButton
	Dim blnResult
	Dim intCounter

	WebUtil.DeleteCookies
	'Invoke the SI application
	SystemUtil.Run "iexplore.exe",URL,,,3

	For intCounter = 1 to 40
		'Check if the page is opened
        blnResult = Browser("brw21CAuthentication").Page("pg21CAuthentication").WebEdit("txtUserName").Exist
        If blnResult Then
			Exit For
		Else
			Wait 2
		End If
	Next

	Browser("brw21CAuthentication").Page("pg21CAuthentication").Sync

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brw21CAuthentication","pg21CAuthentication","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brw21CAuthentication").Page("pg21CAuthentication").Sync

	'Enter the UserName
	blnResult = enterText("txtUserName",UserID)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Enter the Password 
	blnResult = enterSecureText("txtPassword", Password)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

    'Click on Sign On button
    blnResult = clickButton("btnSignOn")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Wait 3
	'Wait for the Yes Button to Appear on Screen    
    For intCounter = 1 To 10
        If Browser("name:=21C Authentication: Warning Screen", "creationtime:=0").Page("title:=21C Authentication: Warning Screen").WebButton("value:= Yes ").Exist(30) Then Exit For
    Next 


	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brw21CAuthentication","pg21CAuthentication","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	'Click on Yes button
    blnResult = clickButton("btnYes")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	With Browser("brwVoiceLogicalProvisioning").Page("pgVoiceLogicalProvisioning")
		For intCounter = 1 to 40
			'Check if the login was successful
			Set objButton = .WebButton("btnLogOut")
			If objButton.Exist Then
				Exit For
			End If
		Next
	End With
	
	If Not objButton.Exist(5) Then
		Call ReportLog("VLP Login","User should be able to login to VLP Application","Login to the VLP Application was not successful","FAIL","TRUE")
		Environment.Value("Action_Result") = False : Exit Function
	Else
		Call ReportLog("VLP Login","Login should be successful","Login Successful and Navigated to the page","PASS","")
	End If
	Environment.Value("Action_Result") = True
End Function
'=============================================================================================================================================
' Description: Function to Upload File and check for success message
'=============================================================================================================================================
Public Function fn_TAHITI_VLP_UploadFile(ByVal FileName, ByVal Country, ByVal Product, ByVal CustomerID)
	blnResult = BuildWebReference("brwVoiceLogicalProvisioning","pgVoiceLogicalProvisioning","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	objPage.WebElement("elmUploadCSV").Click
	objPage.WebElement("elmUploadCSV").FireEvent "ondblclick"

	For intCounter = 1 to 5
		blnExist = objPage.WebFile("wbfCSVFile").Exist
		If blnExist Then
			Exit For
		Else
			objPage.WebElement("elmUploadCSV").Click
			objPage.WebElement("elmUploadCSV").FireEvent "ondblclick"
		End If
	Next

	If Not blnExist Then
		Call ReportLog("Upload CSV File", "Should be visible", "Is not Visible", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Set the File Name
	objPage.WebFile("wbfCSVFile").Set FileName
	Wait 5

	'Set the Customer Name
	'blnResult = enterText("txtCustomerName", CustomerID)
	'	If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
	'objPage.Image("class:=x-form-trigger x-form-trigger-arrow ","file name:=clear\.gif", "index:=1").Click
	'Wait 5	
	
	'Set objElmSelection = objPage.WebElement("class:=x-combo-list-item", "html tag:=DIV", "innerhtml:=" & CustomerID & " -- " & CustomerID, "index:=0")
	'If objElmSelection.Exist(10) Then
	'	objElmSelection.Click
	'Else
	'	Call ReportLog("Customer ID Selection", "Customer ID should be populated for selection", "Customer ID is not populated for selection", "FAIL", True)
	'	Environment("Action_Result") = False : Exit Function
	'End If

	'Set the Country List
	If objPage.WebEdit("txtCountryList").GetROProperty("value") <> Country Then
		blnResult = enterText("txtCountryList", Country)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		
		If objPage.WebElement("elmUploadWindow").Exist(60) Then
			Wait 2
			objPage.WebElement("elmUploadWindow").Image("imgCountryList").Click
			Wait 5
			If objPage.WebElement("class:=x-combo-list-item.*", "html tag:=DIV", "innertext:=" & Country).Exist(60) Then
				objPage.WebElement("class:=x-combo-list-item.*", "html tag:=DIV", "innertext:=" & Country).Click
				Wait 2
			Else
				Call ReportLog("Country List", "Country List should appear after WebEdit is Set", "Country List did not appear after WebEdit is Set", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
		Else
			Call ReportLog("Upload CSV Window", "Upload CSV Window should be visible", "Upload CSV Window is not visible", "FAIL", True)		
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Set the Product Code
	If objPage.WebEdit("txtProductCode").GetROProperty("value") <> Product Then
		blnResult = enterText("txtProductCode", Product)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	End If

	'Click on Submit Button
	blnResult = clickButton("btnSubmit")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Wait 10

	For intCounter = 1 To 5
		blnSuccess = objPage.WebElement("elmCommandSuccess").Exist
			If blnSuccess Then Exit For
	Next

	If Not blnSuccess Then
		Call ReportLog("Success Messgae", "Success Message should appear", "Upload Success message didn't appear", "FAIL", True)
	Else
		Call ReportLog("Success Messgae", "Success Message should appear", "Upload Success", "PASS", True)
	End If

	blnResult = clickButton("btnLogOut")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Wait 2

	blnResult = clickButton("btnYes")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

    Wait 10

	Environment("Action_Result") = blnSuccess
End Function
