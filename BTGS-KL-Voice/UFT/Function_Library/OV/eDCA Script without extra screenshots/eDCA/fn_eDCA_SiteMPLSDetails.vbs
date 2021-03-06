'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SiteMPLSDetails
' Purpose	 	 : 	Function to enter values in Site Page
' Author	 	 : Sathish Lakshminarayana
' Creation Date    : 29/05/2013                					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_eDCA_SiteMPLSDetails(dResilience,dCustomizationLevel,dPricing,dMinimumPeriodOfService,dCPESupplier,dCPEMaintainer)

		Dim strResilience,strCustomizationLevel,strPricing,strMinimumPeriodOfService,strCPESupplier,strCPEMaintainer
		Dim objMsg
		Dim blnResult

		'Assignment of Variables

		srtResilience = dResilience
		strCustomizationLevel = dCustomizationLevel
		strPricing = dPricing
		strMinimumPeriodOfService = dMinimumPeriodOfService
		strCPESupplier = dCPESupplier
		strCPEMaintainer = dCPEMaintainer

	     
		'Function to set the browser and page objects by passing the respective logical names
		blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
			If Not blnResult Then	Environment("Action_Result") = False : Exit Function

		If objPage.WebList("lstResilience").Exist(10) Then
			'Select  Resilience value  from drop down list-  Site page
			blnResult = selectValueFromPageList("lstResilience",srtResilience)
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebList("lstCustomizationLevel").Exist(10) Then
			'Select  CustomizationL evel value  from drop down list-  Site page
			blnResult = selectValueFromPageList("lstCustomizationLevel",strCustomizationLevel)
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebList("lstPricing").Exist(10) Then
			'Select  Pricing  value  from drop down list-  Site page
			blnResult = selectValueFromPageList("lstPricing",strPricing)
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End if

		If objPage.WebEdit("txtMinimumPeriodOfService").Exist(10) Then
			'Enter minium period of service  -  Site page
			blnResult = enterText("txtMinimumPeriodOfService",strMinimumPeriodOfService)
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebList("lstCPESupplier").Exist(10) Then
            'Select  CPE Supplier value  from drop down list-  Site page
			blnResult = selectValueFromPageList("lstCPESupplier",strCPESupplier)
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebList("lstCPEMaintainer").Exist(10) Then
			'Select  CPE Maintainer  value  from drop down list-  Site page
			blnResult = selectValueFromPageList("lstCPEMaintainer",strCPEMaintainer)
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		If objPage.WebButton("btnNext").Exist(60) Then
			'Click on Next Button
			blnResult = clickButton("btnNext")
				If Not blnResult Then	Environment("Action_Result") = False : Exit Function
		End If
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
		'Check if Navigated to Site Location Details Page
		Set objMsg = objpage.Webelement("webElmSiteLocationDetails")
		If Not objMsg.Exist(60*5) Then
			Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		Else
			strMessage = GetWebElementText("webElmSiteLocationDetails")
			Call ReportLog("Site Location Details page","Should be navigated to Site Location Details page on clicking Next Buttton","Not navigated to Site Location Details page on clicking Next Buttton","PASS","")
			Call ReportLog("Site Location Details page","Should be navigated to Site Location Details  page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		End If
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
