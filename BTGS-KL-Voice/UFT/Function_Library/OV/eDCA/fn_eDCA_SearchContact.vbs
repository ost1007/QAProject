'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SearchContact(FirstName,LastName,EIN)
' Purpose	 	 : Function to search for a Contact
' Author	 	 : Linta CK
' Creation Date  	 : 28/05/2013    
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_SearchContact(dFirstName,dLastName,dEIN)

   	Dim strFirstName,strLastName,strEIN,strMessage,strListBoxItemvalue
	Dim blnResult
	Dim objMsg

	'Assignment of variables
	strFirstName = dFirstName
	strLastName = dLastName
	strEIN = dEIN

	For intCounter = 1 to 10
		blnResult = Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebEdit("txtFirstNameSearch").Exist(20)
		If blnResult = "False" Then
			Wait 5
		Else
			Exit For
		End If
	Next
	
	If blnResult Then
		'Enter First Name
		If strFirstName <>"" Then
			Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebEdit("txtFirstNameSearch").Set strFirstName
		End If
	
		'Enter Last Name
		If strLastName <>"" Then
			Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebEdit("txtLastNameSearch").Set strLastName	     
		End If
	
		'Enter EIN
		If strEIN <>"" Then
			Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebEdit("txtEINSearch").Set strEIN     
		End If
		
		'Click on Search
		Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebButton("btnSearch").Click
		Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").Sync
		wait 5
		blnResult = Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebList("btnListBox1").Exist
		If Not Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebList("btnListBox1").WaitProperty("items count", micGreaterThanOrEqual(1), 10000) Then
			Call ReportLog("fn_eDCA_SearchContact", "List should be populated with atleast 1 record", "List is not populated", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If
		If blnResult Then
			strListBoxItemvalue = Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebList("btnListBox1").GetItem(1)
			If strListBoxItemvalue = "" Then
				fn_eDCA_SearchContact = False
				Call ReportLog("Full Legal Company Name","Full Legal Company Name should be retrieved on Search","Full Legal Company Name is not valid","FAIL","True")
				Exit Function
			Else
				fn_eDCA_SearchContact = True
			End If
			Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebList("btnListBox1").Select strListBoxItemvalue
			wait 2
			'Click on Select
			Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebButton("btnSelect").WaitProperty "disabled", "0", 10000
			Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebButton("btnSelect").Click
		End If
	End If

End Function
