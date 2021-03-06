'****************************************************************************************************************************
' Function Name	 : fn_eDCA_ProductSelectionMPLSDetails(ProductName,CoSModel,ServiceDeliveryManagementOption,ProactiveFaultManagement,ChangeManagement,SNMPReadOnly,CPEHealthReportsRequired)
' Purpose	 	 : Function to enter details in Product Selection Page
' Author	 	 : Linta CK
' Creation Date  	 : 29/05/2013
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_ProductSelectionMPLSDetails(dProductName,dCoSModel,dServiceDeliveryManagementOption,dProactiveFaultManagement,dChangeManagement,dSNMPReadOnly,dCPEHealthReportsRequired)
	
	'Variable Declaration
	Dim strProductName,strCoSModel,strServiceDeliveryManagementOption
	Dim strProactiveFaultManagement,strChangeManagement,strSNMPReadOnly
	Dim strCPEHealthReportsRequired,strMessage
	Dim objMsg
	Dim blnResult

	'Assignment of variables
	strProductName = dProductName
	strCoSModel = dCoSModel
	strServiceDeliveryManagementOption = dServiceDeliveryManagementOption
	strProactiveFaultManagement = dProactiveFaultManagement
	strChangeManagement = dChangeManagement
	strSNMPReadOnly = dSNMPReadOnly
	strCPEHealthReportsRequired = dCPEHealthReportsRequired

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
	If blnResult= False Then
		Environment.Value("Action_Result")=False
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	 If objPage.WebList("lstProductName").Exist Then
		strEnabled = objPage.WebList("lstProductName").GetROProperty("disabled") 
		If strenabled = 1 Then
			strListValue = objPage.WebList("lstProductName").GetROProperty("Value") 
			Call ReportLog("Product Name","Product Name List Should be Enaled","Product Name List default value is -  "&strListValue,"PASS","")
		Else
			blnResult = selectValueFromPageList("lstProductName",strProductName)
			If blnResult= False Then
				Environment.Value("Action_Result")=False
				Call EndReport()
				Exit Function
			End If
		End If
	 End If
		
	
	If objPage.WebList("lstCoSModel").Exist Then
		'Select CoS Model
		blnResult = selectValueFromPageList("lstCoSModel",strCoSModel)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If objPage.WebList("lstServiceDeliveryManagementOption").Exist Then
		'Select Service Delivery and Management Option
		blnResult = selectValueFromPageList("lstServiceDeliveryManagementOption",strServiceDeliveryManagementOption)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If objPage.WebList("lstProactiveFaultManagement").Exist Then

		'Select Proactive Fault Management 
		blnResult = selectValueFromPageList("lstProactiveFaultManagement",strProactiveFaultManagement)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If objPage.WebList("lstChangeManagement").Exist Then

		'Select Change Management
		blnResult = selectValueFromPageList("lstChangeManagement",strChangeManagement)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	If objPage.WebList("lstSNMPReadOnly").Exist Then

		'Select SNMP Read Only
		blnResult = selectValueFromPageList("lstSNMPReadOnly",strSNMPReadOnly)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	End If

	If objPage.WebList("lstCPEHealthReportsRequired").Exist Then
		'Select CPE Health Reports Required
		blnResult = selectValueFromPageList("lstCPEHealthReportsRequired",strCPEHealthReportsRequired)
		If blnResult= False Then
			Environment.Value("Action_Result")=False
			Call EndReport()
			Exit Function
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

End Function 

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
