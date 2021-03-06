'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SearchFullLegalCompanyName(FullLegalCompanyName)
' Purpose	 	 : Function to search and select Full Legal Company Name
' Author	 	 : Linta CK
' Creation Date  	 : 29/05/2013               					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_SearchFullLegalCompanyName(dFullLegalCompanyName)

	Dim strFullLegalCompanyName,strMessage
	Dim objMsg
	Dim blnExist,blnFlag,blnDisabled

	'Assignment of variables
   	strFullLegalCompanyName = dFullLegalCompanyName

	blnExist = Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebEdit("btnTextBox1").Exist
	
	If blnExist Then
		Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").Sync
		Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebEdit("btnTextBox1").Set strFullLegalCompanyName
		Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").Sync
		Call ReportLog("Customer Details","User should be able to enter Full Legal Company Name","Entered Full Legal Company Name successfully","PASS","")
		Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
		Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebButton("btnSearch").Click
		wait (5)
		For intLoopCount = 1 to 60
			blnExist = Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch").WebList("btnListBox1").Exist
			If blnExist Then
				blnFlag = True
				Exit For
			Else
				blnFlag = False
				Wait 2
			End If
		Next
		
		If blnFlag Then
			With Browser("brweDCAPortal").Window("SearchWebpageDialog").Page("pgSearch")
				If Not .WebList("btnListBox1").WaitProperty("items count", micGreaterThan(0), 60000) Then
					Call ReportLog("Customer Search", "ListBox should be Populated with data after search", "Items are not populated with Customer Details", "FAIL", True)
					fn_eDCA_SearchFullLegalCompanyName = False
					Exit Function
				End If

				strListBoxItemvalue = .WebList("btnListBox1").GetItem(1)
				If strListBoxItemvalue = "" Then
					fn_eDCA_SearchFullLegalCompanyName = False
					Call ReportLog("Full Legal Company Name","Full Legal Company Name should be retrieved on Search","Full Legal Company Name is not valid","FAIL","True")
					Exit Function
				Else
					fn_eDCA_SearchFullLegalCompanyName = True
				End If

				.WebList("btnListBox1").Select strListBoxItemvalue
				Call ReportLog("Full Legal Company Name","Full Legal Company Name should be populated and able to be selected","Full Legal Company Name is populated and selected successfully","PASS","")
				Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
				
				For intLoopCount = 1 to 60
					blnDisabled = .WebButton("btnSelect").GetROProperty("disabled")
					If blnDisabled = "0" Then
						wait 2
						.WebButton("btnSelect").Click
						Exit For
					Else
						Wait 2
					End If
				Next
			End With
		Else			
			Call ReportLog("Full Legal Company Name","Full Legal Company Name should be retrieved on Search","Full Legal Company Name is not valid","FAIL","True")
			fn_eDCA_SearchFullLegalCompanyName = False
			Exit function
		End If
	End If

End Function