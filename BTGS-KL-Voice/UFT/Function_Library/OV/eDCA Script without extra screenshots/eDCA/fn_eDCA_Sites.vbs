'****************************************************************************************************************************
' Function Name	 : fn_eDCA_Sites
' Author	 	 : Vamshi Krishna G
' Creation Date  : 30/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_Sites(dOrderType,dCountry,dTypeOfOrder)

	'Variable declaration section
    Dim blnResult
	Dim strCountry
	Dim objMsg

	'Assignment of value to variable
	strCountry =dCountry
	
	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function

   Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If dOrderType = "PROVIDE" OR dOrderType = "ADD" Then
		'Click on Add Site button
		blnResult = clickButton("btnAddSite")
			If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		If objPage.WebList("lstCountry").Exist Then
			'Selecting Country  from dropdown
			blnResult = selectValueFromPageList("lstCountry", strCountry)
				If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function
		End If
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'Click on GetSitesFromClassic
		blnResult = clickButton("btnGetSitesfromClassic")
			If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		If dCountry = "Germany"  Then
				blnResult = ObjPage.WbfGrid("tblPricingDetails").Exist 
				If blnResult  Then
						strColCount = ObjPage.WbfGrid("tblPricingDetails").Object.Rows(2).Cells.Length
						strColName = ObjPage.WbfGrid("tblPricingDetails").GetCellData(1,2)
						strValue = ObjPage.WbfGrid("tblPricingDetails").GetCellData(2,2)
						If strValue <> "" or strColName <> "" Then
							Call ReportLog("Sites","Column Value for --"&strColName,"Is - "&strValue,"PASS","")
						Else
							Call ReportLog("Sites","System Should Fecth the data from Classis", "No Value Displayed","FAIL","")
							Environment("Action_Result") = False : Exit Function
						End If
		
						strColName = ObjPage.WbfGrid("tblPricingDetails").GetCellData(1,3)
						strValue = ObjPage.WbfGrid("tblPricingDetails").GetCellData(2,3)
						If strValue <> "" or strColName <> "" Then
							Call ReportLog("Sites","Column Value for --"&strColName,"Is - "&strValue,"PASS","")
						Else
							Call ReportLog("Sites","System Should Fecth the data from Classis", "No Value Displayed","FAIL","")
							Environment("Action_Result") = False : Exit Function
						End If
		
						strColName = ObjPage.WbfGrid("tblPricingDetails").GetCellData(1,4)
						strValue = ObjPage.WbfGrid("tblPricingDetails").GetCellData(2,4)
						If strValue <> "" or strColName <> "" Then
							Call ReportLog("Sites","Column Value for --"&strColName,"Is - "&strValue,"PASS","")
						Else
							Call ReportLog("Sites","System Should Fecth the data from Classis", "No Value Displayed","FAIL","")
							Environment("Action_Result") = False : Exit Function
						End If
		
						strColName = ObjPage.WbfGrid("tblPricingDetails").GetCellData(1,5)
						strValue = ObjPage.WbfGrid("tblPricingDetails").GetCellData(2,5)
		
						If strValue = strCountry Then
							If strValue <> "" or strColName <> "" Then
								Call ReportLog("Sites","Column Value for --"&strColName,"Is - "&strValue,"PASS","")
							Else
								Call ReportLog("Sites","System Should Fecth the data from Classis", "No Value Displayed","FAIL","")
								Environment("Action_Result") = False : Exit Function
							End If
						 Else
							Call ReportLog("Sites","System Should display the Country Name as--"&strCountry, "Expected Country Name is not displayed","FAIL","")
							Environment("Action_Result") = False : Exit Function
						End If
				End If
		End If

		'Click on AddNewBranchSiteLink
		blnResult = clickLink("lnkAddNewBranchSite")
			If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If dOrderType = "CEASE"  or dOrderType = "MODIFY" or dTypeOfOrder = "P2PEtherNetProvide" or dOrderType = "PROVIDE" or dOrderType = "ADD"   Then
	'Click on Edit Button
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		'add by FKH - blnResult = ObjPage.WbfGrid("tblPricingDetails").Exist 
		If Browser("brweDCAPortal").Page("pgeDCAPortal").WebButton("btnEdit").Exist(10) Then
			blnResult = clickButton("btnEdit")
				If blnResult= False Then Environment.Value("Action_Result") = False : Exit Function
		End If
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Site page
	Set objMsg = objpage.WebElement("webElmSite")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Sites","Should be navigated to Site page on clicking Edit Buttton","Not navigated to Site page on clicking Edit Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmSite")
		Call ReportLog("Sites","Should be navigated to Site page on clicking Edit Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
