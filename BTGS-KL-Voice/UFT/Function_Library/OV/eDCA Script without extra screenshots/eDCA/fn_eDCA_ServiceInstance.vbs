'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ServiceInstance()
' Purpose	 	 : Function to click on Edit button in Service Instance Page
' Author	 	 : Linta CK
' Creation Date  	 : 30/05/2013       					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_ServiceInstance(dOrderType,dSearch,deDCAOrderId,dTypeOfOrder)

	Dim objMsg
	Dim blnResult
	Dim strMessage
	strData = "Full PSTN"

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If dOrderType = "CEASE" Then
		If objPage.WebButton("btnView").Exist(60) Then
			'Click on Edit Button
			blnResult = clickButton("btnView")
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	Else
		blnResult = clickButton("btnEdit")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	If dTypeOfOrder = "OVAPROVIDE" Then
		For intCounter = 1 To 50
			If objpage.Webelement("webElmBillingDetails").Exist(5) Then
				strMessage = GetWebElementText("webElmBillingDetails")
				Call ReportLog("Service Instance","Should be navigated to Billing Details page on clicking Next Buttton","Navigated to the page - " & strMessage,"PASS","")
				Environment("Action_Result") = True : Exit Function
			ElseIf objpage.Webelement("webElmConfigureAccess").Exist(5) Then
				strMessage = GetWebElementText("webElmConfigureAccess")
				Call ReportLog("Service Instance","Should be navigated to Configure Access page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
				Environment("Action_Result") = True : Exit Function
			End If	
		Next '#intCounter
	
		Call ReportLog("Service Instance","Should be navigated to either Configure Access/Billing Details page on clicking Next Buttton","Not navigated to either Configure Access/Billing Details on clicking Edit Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function	

	ElseIf dTypeOfOrder = "GSIPMODIFY" Then
		Call fn_eDCA_BillingDetails(dOrderType,deDCAOrderId,dBillingSiteId,dContractMSANo,dTariffOption,dTariffDetailFileLocation,dUsageReportDeliveryMethod,dCompanyName,dAddressLine1,dCityBillingDetails,dRegionState,dPostZIPCode,dBillingContactName,dBillingContactPhoneNumber,dBillingContactEmailAddress,dServiceDescription,dProductDescription,dInvoicePeriod)
		'			If objPage.WebList("lstSubServiceType").Exist Then
		'				blnResult = selectValueFromPageList("lstSubServiceType", strData)
		'				If blnResult= False Then
		'					Environment.Value("Action_Result")=False
		'					Call EndReport()
		'					Exit Function
		'				End If
		'				If Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Exist Then
		'					Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").HighLight
		'					Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
		'				End if
		'					strRetrivedText = objPage.WebList("lstSubServiceType").GetROProperty("value")
		'					Call ReportLog("Service Instance Page","Field Sub Service Type","Field Sub Service Type is change to - "&strRetrievedText,"PASS","")
		'			End If
		'		End If

	Elseif dTypeOfOrder = "GSIPCEASE" Then
		Call  fn_eDCA_Submit(dTypeOfOrder,dSearch,deDCAOrderId)
		Exit Function
	
	Elseif dTypeOfOrder = "OB_FULLPSTN_MODIFY" then 
		If objPage.WebList("lstSubServiceType").Exist(60) Then
			blnResult = selectValueFromPageList("lstSubServiceType", strData)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			
			If Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Exist Then
				Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").HighLight
				Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
			End if
			strRetrivedText = objPage.WebList("lstSubServiceType").GetROProperty("value")
			Call ReportLog("Service Instance Page","Field Sub Service Type","Field Sub Service Type is change to - "&strRetrievedText,"PASS","")
		End If
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Exit Function
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Check if Navigated to Configure Access Page
	If dOrderType = "CEASE" Then
		Set objMsg = objpage.Webelement("webElmServiceInstance")
		objMsg.WaitProperty "visible", True,1000*60*5
		If objMsg.Exist = False Then
			Call ReportLog("Service Instance","Should be navigated to Service Instance page on clicking Next Buttton","Not navigated to Service Instance page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmServiceInstance")
			Call ReportLog("Service Instance","Should be navigated to Service Instance page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If
	End If 

	If dOrderType = "ADD" OR dOrderType = "PROVIDE" Then
		For intCounter = 1 To 50
			If objpage.Webelement("webElmBillingDetails").Exist(5) Then
				strMessage = GetWebElementText("webElmBillingDetails")
				Call ReportLog("Service Instance","Should be navigated to Billing Details page on clicking Next Buttton","Navigated to the page - " & strMessage,"PASS","")
				Environment("Action_Result") = True : Exit Function
			ElseIf objpage.Webelement("webElmConfigureAccess").Exist(5) Then
				Call ReportLog("Service Instance","Should be navigated to Configure Access page on clicking Next Buttton","Navigated to Configure Access page on clicking Next Buttton"," True", False)
				Environment("Action_Result") = True : Exit Function
			End If
		Next '#intCOunter
		
		Call ReportLog("Service Instance","Should be navigated to Billing Details / Configure Access page on clicking Next Buttton","Not Naviagted to any of Specified Page","FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	If dOrderType = "MODIFY" Then
		Set objMsg = objpage.Webelement("webElmPricingDetails")
		'objMsg.WaitProperty "visible", True,1000*60*5
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("Service Instance","Should be navigated to Pricing Details page","Not navigated to Pricing Details page ","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmPricingDetails")
			Call ReportLog("Service Instance","Should be navigated to Pricing Details page","Navigated to the page - "&strMessage,"PASS","")
		End If
	End if

End Function 

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
