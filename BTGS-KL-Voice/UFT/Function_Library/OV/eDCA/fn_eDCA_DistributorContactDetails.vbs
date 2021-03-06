'****************************************************************************************************************************
' Function Name	 : fn_eDCA_DistributorContactDetails
' Purpose	 	 : Function to enter values in Distributor Contact details Page
' Author	 	 : Linta CK
' Creation Date  	 : 24/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_DistributorContactDetails(dOrderType,dOrderCreatorFirstName,dOrderCreatorLastName,dOrderCreatorEIN,dOrderDesignerFirstName,dOrderDesignerLastName,dOrderDesignerEIN,dAccountMgrFirstName,dAccountMgrLastName,dAccountMgrEIN)

	'Variable Declaration Section
	Dim strOrderCreatorFirstName,strOrderCreatorLastName,strOrderCreatorEIN
	Dim strOrderDesignerFirstName,strOrderDesignerLastName,strOrderDesignerEIN
	Dim strAccountMgrFirstName,strAccountMgrLastName,strAccountMgrEIN
	Dim strRetrievedText,strMessage
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strOrderCreatorFirstName = dOrderCreatorFirstName
	strOrderCreatorLastName = dOrderCreatorLastName
	strOrderCreatorEIN = dOrderCreatorEIN
	strOrderDesignerFirstName = dOrderDesignerFirstName
	strOrderDesignerLastName = dOrderDesignerLastName
	strOrderDesignerEIN = dOrderDesignerEIN
	strAccountMgrFirstName = dAccountMgrFirstName
	strAccountMgrLastName = dAccountMgrLastName
	strAccountMgrEIN = dAccountMgrEIN

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If dOrderType = "PROVIDE"  OR dOrderType = "ADD" Then
			blnResult = clickButton("btnSearchOrderCreatorDetails")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
			blnResult = fn_eDCA_SearchContact(strOrderCreatorFirstName,strOrderCreatorLastName,strOrderCreatorEIN)
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorFirstName").GetROProperty("value")
			Call ReportLog("Order Creator First Name","Order Creator First Name should be populated","Order Creator First Name is populated with the value - "&strRetrievedText,"PASS","")
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorLastName").GetROProperty("value")
			Call ReportLog("Order Creator Last Name","Order Creator Last Name should be populated","Order Creator Last Name is populated with the value - "&strRetrievedText,"PASS","")
			
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorEIN").GetROProperty("value")
			Call ReportLog("Order Creator EIN","Order Creator EIN should be populated","Order Creator EIN is populated with the value - "&strRetrievedText,"PASS","")
		
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorEmail").GetROProperty("value")
			Call ReportLog("Order Creator Email","Order Creator Email should be populated","Order Creator Email is populated with the value - "&strRetrievedText,"PASS","")
		
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorPhone").GetROProperty("value")
			Call ReportLog("Order Creator Phone","Order Creator Phone should be populated","Order Creator Phone is populated with the value - "&strRetrievedText,"PASS","")
		
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorMobile").GetROProperty("value")
			Call ReportLog("Order Creator Mobile","Order Creator Mobile should be populated","Order Creator Mobile is populated with the value - "&strRetrievedText,"PASS","")
	Else
			strRetrievedText = objpage.WebEdit("txtOrderCreatorFirstName").GetROProperty("Value")
			If strRetrievedText = "" Then
					blnResult = clickButton("btnSearchOrderCreatorDetails")
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
					blnResult = fn_eDCA_SearchContact(strOrderCreatorFirstName,strOrderCreatorLastName,strOrderCreatorEIN)
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			
					strRetrievedText = objpage.WebEdit("txtOrderCreatorFirstName").GetROProperty("Value")
					Call ReportLog("Order Creator First Name","Distributor First Name should be populated","Distributor First Name is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorLastName").GetROProperty("value")
					Call ReportLog("Order Creator Last Name","Order Creator Last Name should be populated","Order Creator Last Name is populated with the value - "&strRetrievedText,"PASS","")
					
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorEIN").GetROProperty("value")
					Call ReportLog("Order Creator EIN","Order Creator EIN should be populated","Order Creator EIN is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorEmail").GetROProperty("value")
					Call ReportLog("Order Creator Email","Order Creator Email should be populated","Order Creator Email is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorPhone").GetROProperty("value")
					Call ReportLog("Order Creator Phone","Order Creator Phone should be populated","Order Creator Phone is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorMobile").GetROProperty("value")
					Call ReportLog("Order Creator Mobile","Order Creator Mobile should be populated","Order Creator Mobile is populated with the value - "&strRetrievedText,"PASS","")
			Else
					Call ReportLog("Order Creator First Name","Distributor First Name should be populated","Distributor First Name is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorLastName").GetROProperty("value")
					Call ReportLog("Order Creator Last Name","Order Creator Last Name should be populated","Order Creator Last Name is populated with the value - "&strRetrievedText,"PASS","")
					
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorEIN").GetROProperty("value")
					Call ReportLog("Order Creator EIN","Order Creator EIN should be populated","Order Creator EIN is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorEmail").GetROProperty("value")
					Call ReportLog("Order Creator Email","Order Creator Email should be populated","Order Creator Email is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorPhone").GetROProperty("value")
					Call ReportLog("Order Creator Phone","Order Creator Phone should be populated","Order Creator Phone is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderCreatorMobile").GetROProperty("value")
					Call ReportLog("Order Creator Mobile","Order Creator Mobile should be populated","Order Creator Mobile is populated with the value - "&strRetrievedText,"PASS","")
			End If
	End If

	If dOrderType = "PROVIDE"  OR dOrderType = "ADD" Then
			blnResult = clickButton("btnSearchOrderDesignerDetails")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

			blnResult = fn_eDCA_SearchContact(strOrderDesignerFirstName,strOrderDesignerLastName,strOrderDesignerEIN)
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerFirstName").GetROProperty("value")
			Call ReportLog("Order Designer First Name","Order Designer First Name should be populated","Order Designer First Name is populated with the value - "&strRetrievedText,"PASS","")
		
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerLastName").GetROProperty("value")
			Call ReportLog("Order Designer Last Name","Order Designer Last Name should be populated","Order Designer Last Name is populated with the value - "&strRetrievedText,"PASS","")
		
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerEIN").GetROProperty("value")
			Call ReportLog("Order Designer EIN","Order Designer EIN should be populated","Order Designer EIN is populated with the value - "&strRetrievedText,"PASS","")
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerEmail").GetROProperty("value")
			Call ReportLog("Order Designer Email","Order Designer Email should be populated","Order Designer Email is populated with the value - "&strRetrievedText,"PASS","")
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerPhone").GetROProperty("value")
			Call ReportLog("Order Designer Phone","Order Designer Phone should be populated","Order Designer Phone is populated with the value - "&strRetrievedText,"PASS","")
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerMobile").GetROProperty("value")
			Call ReportLog("Order Designer Mobile","Order Designer Mobile should be populated","Order Designer Mobile is populated with the value - "&strRetrievedText,"PASS","")
	Else
			strRetrievedText = objpage.WebEdit("txtOrderDesignerFirstName").GetROProperty("Value")
			If strRetrievedText = "" Then
					blnResult = clickButton("btnSearchOrderDesignerDetails")
						If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
					blnResult = fn_eDCA_SearchContact(strOrderDesignerFirstName,strOrderDesignerLastName,strOrderDesignerEIN)
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerFirstName").GetROProperty("value")
					Call ReportLog("Order Designer First Name","Order Designer First Name should be populated","Order Designer First Name is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerLastName").GetROProperty("value")
					Call ReportLog("Order Designer Last Name","Order Designer Last Name should be populated","Order Designer Last Name is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerEIN").GetROProperty("value")
					Call ReportLog("Order Designer EIN","Order Designer EIN should be populated","Order Designer EIN is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerEmail").GetROProperty("value")
					Call ReportLog("Order Designer Email","Order Designer Email should be populated","Order Designer Email is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerPhone").GetROProperty("value")
					Call ReportLog("Order Designer Phone","Order Designer Phone should be populated","Order Designer Phone is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerMobile").GetROProperty("value")
					Call ReportLog("Order Designer Mobile","Order Designer Mobile should be populated","Order Designer Mobile is populated with the value - "&strRetrievedText,"PASS","")
		  Else
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerFirstName").GetROProperty("value")
					Call ReportLog("Order Designer First Name","Order Designer First Name should be populated","Order Designer First Name is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerLastName").GetROProperty("value")
					Call ReportLog("Order Designer Last Name","Order Designer Last Name should be populated","Order Designer Last Name is populated with the value - "&strRetrievedText,"PASS","")
				
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerEIN").GetROProperty("value")
					Call ReportLog("Order Designer EIN","Order Designer EIN should be populated","Order Designer EIN is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerEmail").GetROProperty("value")
					Call ReportLog("Order Designer Email","Order Designer Email should be populated","Order Designer Email is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerPhone").GetROProperty("value")
					Call ReportLog("Order Designer Phone","Order Designer Phone should be populated","Order Designer Phone is populated with the value - "&strRetrievedText,"PASS","")
			
					strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtOrderDesignerMobile").GetROProperty("value")
					Call ReportLog("Order Designer Mobile","Order Designer Mobile should be populated","Order Designer Mobile is populated with the value - "&strRetrievedText,"PASS","")
	
			End If
	End If

	If dOrderType = "ADD" OR dOrderType = "PROVIDE"  Then
			blnResult = clickButton("btnSearchAccountMgrDetails")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function

			blnResult = fn_eDCA_SearchContact(strAccountMgrFirstName,strAccountMgrLastName,strAccountMgrEIN)
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrFirstName").GetROProperty("value")
			Call ReportLog("Account Manager First Name","Account Manager First Name should be populated","Account Manager First Name is populated with the value - "&strRetrievedText,"PASS","")
		
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrLastName").GetROProperty("value")
			Call ReportLog("Account Manager Last Name","Account Manager Last Name should be populated","Account Manager Last Name is populated with the value - "&strRetrievedText,"PASS","")
		
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrEIN").GetROProperty("value")
			Call ReportLog("Account Manager EIN","Account Manager EIN should be populated","Account Manager EIN is populated with the value - "&strRetrievedText,"PASS","")
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrEmail").GetROProperty("value")
			Call ReportLog("Account Manager Email","Account Manager Email should be populated","Account Manager Email is populated with the value - "&strRetrievedText,"PASS","")
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrPhone").GetROProperty("value")
			Call ReportLog("Account Manager Phone","Account Manager Phone should be populated","Account Manager Phone is populated with the value - "&strRetrievedText,"PASS","")
	
			strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrMobile").GetROProperty("value")
			Call ReportLog("Account Manager Mobile","Account Manager Mobile should be populated","Account Manager Mobile is populated with the value - "&strRetrievedText,"PASS","")

	Else

			strRetrievedText = objpage.WebEdit("txtAccountMgrFirstName").GetROProperty("Value")
			If strRetrievedText = "" Then
				blnResult = clickButton("btnSearchOrderDesignerDetails")
					If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
				blnResult = fn_eDCA_SearchContact(strAccountMgrFirstName,strAccountMgrLastName,strAccountMgrEIN)
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrFirstName").GetROProperty("value")
				Call ReportLog("Account Manager First Name","Account Manager First Name should be populated","Account Manager First Name is populated with the value - "&strRetrievedText,"PASS","")
			
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrLastName").GetROProperty("value")
				Call ReportLog("Account Manager Last Name","Account Manager Last Name should be populated","Account Manager Last Name is populated with the value - "&strRetrievedText,"PASS","")
			
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrEIN").GetROProperty("value")
				Call ReportLog("Account Manager EIN","Account Manager EIN should be populated","Account Manager EIN is populated with the value - "&strRetrievedText,"PASS","")
		
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrEmail").GetROProperty("value")
				Call ReportLog("Account Manager Email","Account Manager Email should be populated","Account Manager Email is populated with the value - "&strRetrievedText,"PASS","")
		
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrPhone").GetROProperty("value")
				Call ReportLog("Account Manager Phone","Account Manager Phone should be populated","Account Manager Phone is populated with the value - "&strRetrievedText,"PASS","")
		
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrMobile").GetROProperty("value")
				Call ReportLog("Account Manager Mobile","Account Manager Mobile should be populated","Account Manager Mobile is populated with the value - "&strRetrievedText,"PASS","")
	
		Else
	
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrFirstName").GetROProperty("value")
				Call ReportLog("Account Manager First Name","Account Manager First Name should be populated","Account Manager First Name is populated with the value - "&strRetrievedText,"PASS","")
			
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrLastName").GetROProperty("value")
				Call ReportLog("Account Manager Last Name","Account Manager Last Name should be populated","Account Manager Last Name is populated with the value - "&strRetrievedText,"PASS","")
			
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrEIN").GetROProperty("value")
				Call ReportLog("Account Manager EIN","Account Manager EIN should be populated","Account Manager EIN is populated with the value - "&strRetrievedText,"PASS","")
		
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrEmail").GetROProperty("value")
				Call ReportLog("Account Manager Email","Account Manager Email should be populated","Account Manager Email is populated with the value - "&strRetrievedText,"PASS","")
		
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrPhone").GetROProperty("value")
				Call ReportLog("Account Manager Phone","Account Manager Phone should be populated","Account Manager Phone is populated with the value - "&strRetrievedText,"PASS","")
		
				strRetrievedText = Browser("brweDCAPortal").Page("pgeDCAPortal").WebEdit("txtAccountMgrMobile").GetROProperty("value")
				Call ReportLog("Account Manager Mobile","Account Manager Mobile should be populated","Account Manager Mobile is populated with the value - "&strRetrievedText,"PASS","")
		End If
	End If

	'Click on Next Button
	Call ReportLog("Distributor Contact Details","Distributor Contact Details Page should be completed","Distributor Contact Details completed successfully","PASS","TRUE")
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Order Contact Details Page
	Set objMsg = objpage.Webelement("webElmOrderContactDetails")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Distributor Contact Details","Should be navigated to Order contact Details page on clicking Next Buttton","Not navigated to Order contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment.Value("Action_Result")=False : Exit Function
	Else
		strMessage = GetWebElementText("webElmOrderContactDetails")
		Call ReportLog("Distributor Contact  Details","Should be navigated to Order contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
		Environment.Value("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
