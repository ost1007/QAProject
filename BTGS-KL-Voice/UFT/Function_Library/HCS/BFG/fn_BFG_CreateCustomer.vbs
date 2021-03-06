'****************************************************************************************************************************
' Function Name	 : fn_BFG_CreateCustomer
' Purpose	 	 : Function to Create Customer in BFG
' Modified By	: BT Test Automation Team			05/07/2016
' Parameters	 : 	UserProfileGroup, CustomerName, Country
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_BFG_CreateCustomer(ByVal UserProfileGroup, ByVal CustomerName, ByVal Country)
	
	'Variable Declaration
	Dim intCounter, intRow
	Dim strInnerText, strLEID, strLEName
	Dim blnNewCustomer, blnExist
	
	Const MSGNORESULTS = "No results found with those characters in customer name"

	blnResult = BuildWebReference("brwBFG-IMS", "pgBFG-IMS", "")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = selectValueFromPageList("cmbProfile", UserProfileGroup)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickButton("btnContinue")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 10
		If objPage.Link("lnkSearch4ExistingCustomers").Exist(30) Then Exit For
	Next
	
	blnResult = clickLink("lnkSearch4ExistingCustomers")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 10
		If objPage.WebList("lstSearchTerm").Exist(30) Then Exit For
	Next
	
	blnResult = selectValueFromPageList("lstSearchTerm", "Customer Name")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtCustomerName", CustomerName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickButton("btnSearch")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	blnNewCustomer = False
	
	For intCounter = 1 To 30
		strInnerText = objPage.Frame("title:=BFG IMS - Customer Search \(text\)").Object.body.innertext
		If Instr(strInnerText, MSGNORESULTS) > 0 Then
			Call ReportLog("Message", MSGNORESULTS & " - message should appear", MSGNORESULTS & " - message appeared", "PASS", True)
			blnNewCustomer = True
			Exit For
		ElseIf objPage.WebTable("tblCustomerDetails").Exist(10) Then
			Exit For
		Else
			Wait 10
		End If	
	Next
	
	If Not blnNewCustomer Then
		Call ReportLog("Message", MSGNORESULTS & " - message should appear", MSGNORESULTS & " - <B>message did not appear</B>", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	blnResult = clickButton("btnAddCustomer")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	For intCounter = 1 To 10
		If objPage.WebElement("elmCheckCustomer").Exist(30) Then Exit For
	Next
	
	blnResult = enterText("txtCustName", CustomerName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	blnResult = clickButton("btnCheck")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	

	For intCounter = 1 To 30
		If objPage.WebButton("btnAddCustomer").Exist(10) Then Exit For
	Next
	
	blnResult = clickButton("btnAddCustomer")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	For intCounter = 1 To 10
		blnExist = objPage.WebElement("elmValidateLE").Exist(30)
		If blnExist Then Exit For
	Next
	
	If blnExist Then
		Call ReportLog("Navigation", "Should be navigated to Validate LE Page", "Navigated to Validate LE Page", "Information", False)
	Else
		Call ReportLog("Navigation", "Should be navigated to Validate LE Page", "Not navigated to Validate LE Page", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	If Country = "UNITED KINGDOM" Then
		blnResult = enterText("txtLECustomerName", "BT Global Services")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		blnResult = clickButton("btnSearch")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
		For intCounter = 1 To 15
			blnExist = objPage.WebButton("btnSelect").Exist(10)
				If blnExist Then Exit For	
		Next
		
		If Not blnExist Then
			Call ReportLog("Search LE", "On Search of LE details should be displayed", "LE details table is not displayed", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog("Search LE", "On Search of LE details should be displayed", "LE details table is displayed", "Information", False)
		End If

		blnResult = clickButton("btnSelect")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		blnResult = clickButton("btnAddCustomer-NonUK")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	For intCounter = 1 To 10
		blnExist = objPage.WebElement("elmAddCustomer").Exist(30)
		If blnExist Then Exit For
	Next
	
	If blnExist Then
		Call ReportLog("Navigation", "Should be navigated to Add Customer Page", "Navigated to Add Customer LE Page", "Information", False)
	Else
		Call ReportLog("Navigation", "Should be navigated to Add Customer Page", "Not navigated to Add Customer Page", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If
	
	objPage.WebEdit("txtCustName").WaitProperty "height", micGreaterThan(0), 1000*60*3
	
	blnResult = enterText("txtCustName", CustomerName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtCustReference", "AUTO" & RandomNumber(10000, 99999))
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	For intCounter = 1 To 10
		blnExist = objPage.WebList("lstRegisteredCountry").Exist(30)
		If blnExist Then Exit For
	Next
	
	objPage.WebList("lstRegisteredCountry").WaitProperty "items count", micGreaterThan(0), 1000*60*3
	
	blnResult = selectValueFromPageList("lstRegisteredCountry", Country)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
	strLEID = Trim(objPage.WebEdit("txtCustomerLE_ID").GetROPRoperty("value"))
	If strLEID <> "" Then
		Call ReportLog("Capture LE ID", "LE ID should be captured", "LE ID is found to be <B>" & strLEID & "</B>", "PASS", True)
	End If
	
	strLEName = Trim(objPage.WebEdit("txtCustomerLE_Name").GetROPRoperty("value"))
	If strLEName <> "" Then
		Call ReportLog("Capture LE Name", "LE Name should be captured", "LE Name is found to be <B>" & strLEName & "</B>", "PASS", True)
	End If
	
	blnResult = clickButton("btnAddCustomer")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	For intCounter = 1 To 10
		If objPage.WebList("lstSearchTerm").Exist(30) Then Exit For
	Next
	
	blnResult = selectValueFromPageList("lstSearchTerm", "Customer Name")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = enterText("txtCustomerName", CustomerName)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	blnResult = clickButton("btnSearch")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	
	For intCounter = 1 To 15
		blnExist = objPage.WebTable("tblCustomerDetails").Exist(10)
			If blnExist Then Exit For	
	Next
	
	If Not blnExist Then
		Call ReportLog("Search Customer", "On Search of Customer, details should be displayed", "Customer Details is not displayed", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Search Customer", "On Search of Customer, details should be displayed", "Customer details table is displayed", "Information", True)
	End If
	
	
	intRow = objPage.WebTable("tblCustomerDetails").GetRowWithCellText(CustomerName)
	If intRow <= 0 Then
		Call ReportLog("Search Customer", "On Search of Customer, details of <B>[" & CustomerName & "]</B> should be displayed", "Customer Details is not displayed", "FAIL", True)
		Environment("Action_Result") = False
	Else
		strCustomerID = objPage.WebTable("tblCustomerDetails").GetCellData(intRow, 1)
		Call SetXLSOutValue(Environment.Value("TestDataPath"),Environment("StrTestDataSheet"), StrTCID, "dCustomerID", strCustomerID)
		If strCustomerID = "" Then
			Call ReportLog("Capture Customer ID", "Customer ID should be captured", "Customer ID is not generated", "FAIL", True)
			Environment("Action_Result") = False
		Else
			Call ReportLog("Capture Customer ID", "Customer ID should be captured", "Customer ID is found to be <B>" & strCustomerID & "</B>", "PASS", False)
			Environment("Action_Result") = True
		End If
	End If
	
	objBrowser.Close	

End Function
