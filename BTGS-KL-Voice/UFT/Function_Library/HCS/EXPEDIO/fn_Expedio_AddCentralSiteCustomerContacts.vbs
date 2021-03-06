'*******************************************************************************************************************************************************************************
' Description	 : Function to Fill Central Site Cusomter Contacts
' History	 	 : 		Author		Date	Changes Implemented
' Created By	 : 	Nagaraj V	30/06/2015	NA
' Parameters	 : 	Role, JobTitle, FirstName, LastName, EMail, PhoneNumber
' Return Values	 : Not Applicable
'*******************************************************************************************************************************************************************************
Public Function fn_Expedio_AddCentralSiteCustomerContacts(ByVal Role, ByVal JobTitle, ByVal FirstName, ByVal LastName, ByVal EMail, ByVal PhoneNumber)

	'Variable Declaration
	Dim arrFirstName, arrLastName, arrPhoneNumber, arrJobTitle, arrRole, arrEMail
	Dim intCounter 

	'Variable Assignment Section
	arrFirstName = Split(FirstName, "|")
	arrLastName = Split(LastName, "|")
	arrPhoneNumber = Split(PhoneNumber, "|")
	arrJobTitle = Split(JobTitle, "|")
	arrRole = Split(Role, "|")
	arrEMail = Split(EMail, "|")

	'Build Reference
	blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	For intCounter = 0 to UBound(arrFirstName)
		'Enter Role
		objPage.WebEdit("txtCentralContactRoles").Click :Wait 1
		'blnResult = enterText("txtCentralContactRoles", arrRole(intCounter))
		objPage.Image("alt:=Menu for Role", "index:=0").Object.Click
		blnResult = fn_Expedio_SelectValueFromDropDown(objPage, arrRole(intCounter), objPage.WebEdit("txtCentralContactRoles"))
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		'Enter Job Title
		blnResult = enterText("txtCentralJobTitle", arrJobTitle(intCounter))
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		'Enter First Name
		blnResult = enterText("txtCentralFirstName", arrFirstName(intCounter))
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		'Enter Last Name
		blnResult = enterText("txtCentralLastName", arrLastName(intCounter))
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		'Enter EMail
		blnResult = enterText("txtCentralEMail", arrEMail(intCounter))
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		'Enter Phone Number
		blnResult = enterText("txtCentralPhoneNumber", arrPhoneNumber(intCounter))
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		'Click on Save
		blnResult = clickLink("lnkCentralContactSave")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

		If objPage.Frame("frmBMCRemedyUserNote").WebElement("elmCustomerContact").WaitProperty("height", micGreaterThan(0), 10000*6*5) Then
			Call ReportLog("Customer Contact", "Customer Contact Message should appear", "Customer Contact Message is visible", "INFORMATION", False)
			objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
		Else
			Call ReportLog("Customer Contact", "Customer Contact Message should appear", "Customer Contact Message is not visible", "Warnings", True)
			objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
		End If

		blnSearch = False
			For intInnerCounter = 1 to 10
                Set objTable = objPage.WebTable("column names:=First Name;Last Name.*")
				If objTable.Exist(5) and objTable.GetRowWithCellText(Trim(arrRole(iCounter))) > 0 Then
					blnSearch = True
					Exit For
				Else
					Wait 6
				End If
		Next

		If Not blnSearch Then
			Call ReportLog("Add Customer Contact", "Should be able to add Customer contact", "Unable to add Customer Contact", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
	Next 'iCounter

	Environment("Action_Result") = True	

End Function
