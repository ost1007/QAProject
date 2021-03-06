'=============================================================================================================
'Description: To Create a New Site
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			01/10/2014 	v1.0
'Example: fn_Expedio_SeacrhQuote_AddChannelContact(dTypeOfOrder, dQuoteID, dChannelContactEIN, dDistributorRoles)
'=============================================================================================================
Public Function fn_Expedio_SearchQuote_AddChannelContact(ByVal dQuoteID, ByVal dChannelContactEIN, ByVal dDistributorRoles)
	On Error Resume Next
		Dim intRow
		Dim objQuoteTable, objQuoteElm
		Dim strText
		Dim blnContactAdded

		Set objPage = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI")

		For intCounter = 1 to 10
			If objPage.Exist Then
				Exit For
			End If
		Next
	
		blnResult = BuildWebReference("brwIPSDKWEBGUI","pgIPSDKWEBGUI","")
			If Not blnResult Then Environment("Action_Result")=False : Exit Function
	
		'Click on Quote Details Link
		blnResult = clickLink("lnkQuoteDetails")
			If Not blnResult Then Environment("Action_Result")=False : Exit Function
	
		Wait 2
	
		'Click on Search Quote Link
	   	blnResult = clickLink("lnkSearchQuote")
	   		If Not blnResult Then Environment("Action_Result")=False : Exit Function
	
		Set objQuoteTable = objPage.WebTable("tblQuoteDetails")
	
		'Check if Table has been loaded and row count is greater than 0
		For intCounter = 1 to 20
			If objQuoteTable.Exist Then
				If objQuoteTable.RowCount > 0 Then
					Exit For
				Else
					Wait 5
				End If
			End If
		Next
	
		intRow = objQuoteTable.GetRowWithCellText(dQuoteID)
		strText = objQuoteTable.GetCellData(intRow, 8)
		If Trim(UCase(strText)) = "ORDERED" OR Trim(UCase(strText)) = "DRAFT" Then
			Call ReportLog("Quote Status", "Quote Status should be ORDERED/DRAFT", "Quote Status is found to be " & strText, "PASS", False)
			Set objQuoteElm = objQuoteTable.ChildItem(intRow, 1, "WebElement", 0)
			objQuoteElm.HighLight
			objQuoteElm.Click
			Wait 5
		Else
			Call ReportLog("Quote Status", "Quote Status should be ORDERED/DRAFT", "Quote Status is found to be " & strText, "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		'Addition of Channel Contact
		arrEIN = Split(dChannelContactEIN, "|")
		arrRoles = Split(dDistributorRoles, "|")

		If UBound(arrEIN) < 1 Or UBound(arrRoles) < 1 Then
			Call ReportLog("Channel Contacts", "Enter Channel Contact needs atleast three EIN and roles", "Invalid Test Data entered", "FAIL", False)
			Environment("Action_Result") = False
			Exit Function
		End If

		objPage.Link("lnkChannelContactReset").Object.Click
		Wait 2

		strPhoneNumber = RandomNumber(6600000, 6699999)
		
		For intCounter = 0 to UBound(arrRoles)
			strEIN = Trim(arrEIN(intCounter)) : strRole = Trim(arrRoles(intCounter))

			For intInnerCounter = 1 to 5
				If CStr(objPage.WebEdit("txtEIN").GetROProperty("value")) <> CStr(strEIN) Then
					blnResult = enterText("txtEIN", strEIN)
					Wait 2
				Else
					Exit For
				End If
			Next

			If Not blnResult Then Environment("Action_Result") =  False : Exit Function

			blnResult = clickLink("lnkSearchBTDirectory")
				If Not blnResult Then Environment("Action_Result") =  False : Exit Function
			
			intSetupErrorCounter = 0
			
			With Browser("brwBTDirectorySearch").Page("pgBTDirectorySearch")
				For intInnerCounter = 1 to 7
					If .WebTable("tblContactResult").Exist(5) Then
						intRow = .WebTable("tblContactResult").GetRowWithCellText(strEIN)
						If intRow > 0 Then 
							.Link("lnkSelect").Click
							Wait 2 : blnExist = True
							Exit For  '#intInnerCounter
						End If
					ElseIf .Frame("frmBMCRemedyUserError").WebElement("elmPlugInTimeOut").Exist(5) Then
						Set objBrowser = Browser("brwBTDirectorySearch")
						Call ReportLog("Search BT Directory", "Search should be successful", .Frame("frmBMCRemedyUserError").WebElement("elmPlugInTimeOut").GetROProperty("innerText"), "FAIL", True)
						Environment("Action_Result") = False : Exit Function
					ElseIf .Frame("frmBMCRemedyUserError").WebElement("elmUnableToSetupCommunication").Exist(5) Then
						If .Frame("frmBMCRemedyUserError").Link("lnkOK").Exist(5) Then
							.Frame("frmBMCRemedyUserError").Link("lnkOK").Click
							intSetupErrorCounter = intSetupErrorCounter + 1
							If intSetupErrorCounter = 4 Then
								Set objBrowser = Browser("brwBTDirectorySearch")
								Call ReportLog("Search BT Directory", "Search should be successful", .Frame("frmBMCRemedyUserError").WebElement("elmUnableToSetupCommunication").GetROProperty("innerText"), "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							Else
								intCounter = intCounter - 1
							End If
						End If
					End If
				Next '#intInnerCounter
			End With
			
			If intSetupErrorCounter = 0 Then
				If Not blnExist Then
					Call ReportLog("Select Button", "Select Button should exist after Searching EIN", "Select Button is not visible", "FAIL", True)
					Environment("Action_Result") =  False : Exit Function
				End If

				'If Phone number doesn't exist in BT Directory
				If objPage.WebElement("elmPhoneNumber").WebEdit("txtPhoneNumber").GetROProperty("value") = "" Then
					For intInnerCounter = 1 to 5
						If CStr(objPage.WebElement("elmPhoneNumber").WebEdit("txtPhoneNumber").GetROProperty("value")) <> CStr(strPhoneNumber) Then
							objPage.WebElement("elmPhoneNumber").WebEdit("txtPhoneNumber").Set strPhoneNumber
						Else
							Exit For
						End If
					Next
				Else
					blnResult = True
				End If

				If Not blnResult Then Environment("Action_Result") =  False : Exit Function

				'Since it is List Focus should be brought to enable editing
				objPage.WebEdit("txtDistributorRole").Click
				Wait 1

				'Enter Distributor Role
				objPage.WebEdit("txtDistributorRole").Object.Click
				objPage.WebEdit("txtDistributorRole").Object.InnerText = strRole
				Wait 2
				objPage.WebEdit("txtDistributorRole").Object.Click
				CreateObject("Wscript.Shell").SendKeys "{ENTER}"
				'objPage.Image("alt:=Menu for Distributor Role").Object.Click
				
				Wait 2
				Call ReportLog("Distributor Role", "Distributor Role should be entered", "Distrinutor Role <B>" & objPage.WebEdit("txtDistributorRole").GetROProperty("value") & "</B> is entered", "Information", False)
	
				'Click on Save
	           	 	blnResult = clickLink("lnkChannelContactSave")
					If Not blnResult Then Environment("Action_Result") =  False : Exit Function
	
				For intInnerCounter = 1 to 2
					If objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Exist Then
						objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Click
						Exit For
					End If
				Next
	
				If objPage.Frame("frmBMCRemedyUserNote").Link("lnkOK").Exist(5) Then
					objPage.WebButton("btnCloseRight").Click
				End If
			
				blnContactAdded = False
				For intInnerCounter = 1 to 10
					If objPage.WebTable("tblChannelContact").Exist(10) Then
						If objPage.WebTable("tblChannelContact").GetRowWithCellText(strRole) < 1 Then
							Wait 5
						Else
							blnContactAdded = True
							Exit For '#intInnerCounter
						End If
					End If
				Next '#intInnerCounter
				If Not blnContactAdded Then
					Call ReportLog("Add Channel Contact", "Contact should be added successfully", "Add Channel Contact for above Role was unsuccessful", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
			End if
		Next '#intCounter
End Function
