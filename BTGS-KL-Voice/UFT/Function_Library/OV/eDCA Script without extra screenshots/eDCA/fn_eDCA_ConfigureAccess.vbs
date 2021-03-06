'************************************************************************************************************************************
' Function Name	 :  fn_eDCA_ConfigureAccess
' Purpose	 	 :  Function to enter NIS details
' Author	 	 : Vamshi Krishna G
' Creation Date    : 17/06/2013
'Return values :	Nil
'**************************************************************************************************************************************	
Public Function fn_eDCA_ConfigureAccess(dTypeOfOrder, dCoSPolicy, dAccessType, dGPoP, dAccessSupplier, dAccessEnhancedServiceRestoration, dSLA)

   'fncConfigureAccess(CoSPolicy,AccessType,GPoP,AccessSupplier,AccessEnhancedServiceRestoration,SLA)

	'Decalaration of variables
	Dim blnResult,strMessage,objMsg
	Dim strCoSPolicy,strAccessType,strGPoP,strAccessSupplier,strAccessEnhancedServiceRestoration,strSLA

	'Assignment of variables
	strCoSPolicy = dCoSPolicy
	strAccessType = dAccessType
	strGPoP = dGPoP
	strAccessSupplier = dAccessSupplier
	strAccessEnhancedServiceRestoration = dAccessEnhancedServiceRestoration
	strSLA = dSLA

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If  dTypeOfOrder <> "OB_FULLPSTN_MODIFY" Then
		If objPage.WebList("lstCoSPolicy").Exist Then
		
			'Select CoS Policy from drop down list
			blnResult = selectValueFromPageList("lstCoSPolicy",strCoSPolicy)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		If objPage.WebList("lstAccessType").Exist Then
			'Selcting Access type from drop down list
			blnResult = selectValueFromPageList("lstAccessType",strAccessType)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		If objPage.WebList("lstGPoP").Exist Then
			'Selecting GPoP from drop down list
			blnResult = selectValueFromPageList("lstGPoP",strGPoP)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		If objPage.WebList("lstAccessSupplier").Exist Then
			'Selecting Access Supplier from drop down list
			blnResult = selectValueFromPageList("lstAccessSupplier",strAccessSupplier)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		If objPage.WebList("lstAccessEnhancedServiceRestoration").Exist Then
			'Selecting Access Enhanced Service Restoration from drop down
			blnResult = selectValueFromPageList("lstAccessEnhancedServiceRestoration",strAccessEnhancedServiceRestoration)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		If objPage.WebList("lstSLA").Exist Then
			'Select SLA from drop down list
			blnResult = selectValueFromPageList("lstSLA",strSLA)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If
		
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Else
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if navigated to Access details Page
	Set objMsg = objpage.WebElement("webElmAccessDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Configure Access","Should be navigated to Access Details page on clicking Next Buttton","Not navigated to Access Details page on clicking Next Buttton","FAIL","TRUE")
	Else
		strMessage = GetWebElementText("webElmAccessDetails")
		Call ReportLog("Configure Access","Should be navigated to Access Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

