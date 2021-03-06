'=============================================================================================================
'Description: To add Contacts to Site Contact
'History	  : Name				Date			Version
'Created By	 :  Nagaraj			24/09/2014 	v1.0
'Modified By : 	Nagaraj 		23/04/2015  v1.1 - Functionality changed and page - Searhc Sites and then add
'Example: fn_Expedio_AddSiteContact(dFirstName, dLastName, dPhoneNumber, dJobTitle, ByVal dRole)
'=============================================================================================================
'Public Function fn_Expedio_AddSiteContact(ByVal dFirstName, ByVal dLastName, ByVal dPhoneNumber, ByVal dJobTitle, ByVal dRole) v1.0
Public Function fn_Expedio_AddSiteContact(ByVal SiteName, ByVal dFirstName, ByVal dLastName, ByVal dPhoneNumber, ByVal dJobTitle, ByVal dRole)
	On Error Resume Next
		Dim arrFirstName, arrLastName, arrPhoneNumber, arrRole, arrJobTitle
		Dim iCounter, intinnerCounter
		Dim blnExist, blnSearch

	'Split the Values and store it array for continous addition
		arrFirstName = Split(dFirstName, "|")
		arrLastName = Split(dLastName, "|")
		arrPhoneNumber = Split(dPhoneNumber, "|")
		arrJobTitle = Split(dJobTitle, "|")
		arrRole = Split(dRole, "|")

		For intCounter = 1 to 5
			blnExist = Browser("brwIPSDKWEBGUI").Page("pgIPSDKWEBGUI").Exist
			If blnExist Then
				Exit For
			End If
		Next
        
		blnResult = BuildWebReference("brwIPSDKWEBGUI", "pgIPSDKWEBGUI", "")
		If Not blnResult Then
			Environment("Action_Result") = False
			Exit Function
		End If		

		strURL = Browser("brwIPSDKWEBGUI").GetROProperty("url")
		If Instr(strURL, "expediomt.t1.nat.bt.com") > 0 Then
			strTitle = "txtJobTitleT1"
		Else
			strTitle = "txtJobTitle"
		End If

		'Click on Search Site Link
		If objPage.Link("name:=Search Site", "index:=0").Exist Then
	        objPage.Link("name:=Search Site", "index:=0").Click
			Call ReportLog("Link:= Search Site", "Link should exist and is to be clicked", "Link exists and is been clicked", "PASS", False)
		Else
			Call ReportLog("Link:= Search Site", "Link should exist", "Link doesn't Exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If

		Wait 5

		For intcounter = 0 to 10
			blnResult = Browser("creationtime:=1").Page("title:=.*").WebElement("innertext:=Loading.*").Exist(10)
			If  blnResult Then
				Wait 5
			Else
				Exit For
			End If
		Next

		Set tblSiteDetails = objPage.WebTable("class:=BaseTable","column names:=BFG Site ID;Site Name;.*")
		For intCounter = 1 To 10
			If tblSiteDetails.Exist(30) Then
				Exit For '#intCounter
			End If
		Next
		
		If Not tblSiteDetails.WaitProperty("visible", "True", 60000) Then
			Call ReportLog("WebTable:= Site Table", "WebTable should exist", "WebTable doesn't Exist", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If

		intRow = tblSiteDetails.GetRowWithCellText(UCase(SiteName))
		tblSiteDetails.Object.rows(intRow - 1).cells(1).Click

		Wait 20

		'Loop to Add the values into Site Contact Detail and Click on Save
		For iCounter = 0 to UBound(arrFirstName)
		
			'Enter FirstName
			If objPage.WebEdit("xpath:=//DIV[contains(@class, 'FirstName_SearchSite')]/TEXTAREA[1]", "index:=0").Exist(10) Then
				objPage.WebEdit("xpath:=//DIV[contains(@class, 'FirstName_SearchSite')]/TEXTAREA[1]", "index:=0").Set Trim(arrFirstName(iCounter))
				Call ReportLog("WebEdit:= FirstName", "WebEdit should exist", "WebEdit exists and value <B>" & arrFirstName(iCounter) & "</B> is entered" , "PASS", False)
			Else
				Call ReportLog("WebEdit:= FirstName", "WebEdit should exist", "WebEdit doesn't Exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			'Enter LastName
			If objPage.WebEdit("xpath:=//DIV[contains(@class, 'LastName_SearchSite')]/TEXTAREA[1]", "index:=0").Exist(10) Then
				objPage.WebEdit("xpath:=//DIV[contains(@class, 'LastName_SearchSite')]/TEXTAREA[1]", "index:=0").Set Trim(arrLastName(iCounter))
				Call ReportLog("WebEdit:= LastName", "WebEdit should exist", "WebEdit exists and value <B>" & arrLastName(iCounter) & "</B> is entered" , "PASS", False)
			Else
				Call ReportLog("WebEdit:= LastName", "WebEdit should exist", "WebEdit doesn't Exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			Wait 5
			objPage.Image("alt:=Menu for Role", "index:=1").Object.Click 
			Wait 5
			
			Set oDesc = Description.Create
			oDesc("micclass").Value = "WebElement"
			oDesc("class").Value = "MenuEntryName.*"
			oDesc("html tag").Value = "TD"
			Set objElms = objPage.WebTable("class:=MenuTable", "index:=0").ChildObjects(oDesc)
			For intCounter = 0 to objElms.Count - 1
				If Cstr(Trim(objElms(intCounter).GetROProperty("innertext"))) = Cstr(Trim(arrRole(iCounter))) Then
					objElms(intCounter).HighLight
					objElms(intCounter).FireEvent "onmouseover"
					objElms(intCounter).Click
					Exit For
				End If
			Next
			Wait 60
			
			If Trim(arrRole(iCounter)) = "Site Primary Contact" Then
				'Enter EMail
				If objPage.WebEdit("xpath:=//DIV[contains(@class, 'EMail_SearchSite')]/TEXTAREA[1]", "index:=0").Exist(10) Then
					objPage.WebEdit("xpath:=//DIV[contains(@class, 'EMail_SearchSite')]/TEXTAREA[1]", "index:=0").Set Trim(arrFirstName(iCounter)) & "." & Trim(arrLastName(iCounter)) & "@bt.com"
					Call ReportLog("WebEdit:= EMail", "WebEdit should exist", "WebEdit exists and value <B>" & Trim(arrFirstName(iCounter)) & "." & Trim(arrLastName(iCounter)) & "@bt.com" & "</B> is entered" , "PASS", False)
				Else
					Call ReportLog("WebEdit:= EMail", "WebEdit should exist", "WebEdit doesn't Exist", "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If
			Else
				objPage.WebEdit("xpath:=//DIV[contains(@class, 'EMail_SearchSite')]/TEXTAREA[1]", "index:=0").Set ""
			End If
			
			'Enter JobTitle
			If objPage.WebEdit("xpath:=//DIV[contains(@class, 'JobTitle_SearchSite')]/TEXTAREA[1]", "index:=0").Exist(10) Then
				objPage.WebEdit("xpath:=//DIV[contains(@class, 'JobTitle_SearchSite')]/TEXTAREA[1]", "index:=0").Set Trim(arrJobTitle(iCounter))
				Call ReportLog("WebEdit:= Job Title", "WebEdit should exist", "WebEdit exists and value <B>" & arrJobTitle(iCounter) & "</B> is entered" , "PASS", False)
			Else
				Call ReportLog("WebEdit:= Job Title", "WebEdit should exist", "WebEdit doesn't Exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If
			
			'Enter Phone Number
			If objPage.WebEdit("xpath:=//DIV[contains(@class, 'PhoneNo_SearchSite')]/TEXTAREA[1]", "index:=0").Exist(10) Then
				objPage.WebEdit("xpath:=//DIV[contains(@class, 'PhoneNo_SearchSite')]/TEXTAREA[1]", "index:=0").Set Trim(arrPhoneNumber(iCounter))
				Call ReportLog("WebEdit:= Phone Number", "WebEdit should exist", "WebEdit exists and value <B>" & arrPhoneNumber(iCounter) & "</B> is entered" , "PASS", False)
			Else
				Call ReportLog("WebEdit:= Phone Number", "WebEdit should exist", "WebEdit doesn't Exist", "FAIL", True)
				Environment("Action_Result") = False : Exit Function
			End If			

			objPage.Link("name:=Create Contact", "index:=0").Object.Click
			Wait 2

			For intInnerCounter = 1 to 5
				If objPage.WebButton("btnCloseRight").Exist(10) Then
					objPage.WebButton("btnCloseRight").Click
					Exit For
				End If
			Next

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
				Call ReportLog("Add Site Contact", "Should be able to add site contact", "Unable to add site Contact", "FAIL", True)
				Environment("Action_Result") = False
				Exit Function
			End If

		Next 'iCounter
		Environment("Action_Result") = True
End Function
