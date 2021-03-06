'****************************************************************************************************************************
' Function Name	   :  fn_eDCA_AccessDetails
' Purpose	 	 : Function to enter values in Access Details page
' Author	 	 : Sathish Lakshminarayana
' Creation Date    : 03/06/2013 					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_AccessDetails(dTypeOfOrder,dAccessCircuitResilienceAndDiversity,dElectricalOpticalInterface,dPhysicalConnector,dAccessBearerCircuitFramingStructure,dAccessSpeed,dPortSpeed)

	'Variable Declaration Section
    Dim strAccessCircuitResilienceAndDiversity,strElectricalOpticalInterface,strPhysicalConnector,strAccessBearerCircuitFramingStructure,strAccessSpeed,strPortSpeed	
    Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strAccessCircuitResilienceAndDiversity = dAccessCircuitResilienceAndDiversity
	strElectricalOpticalInterface = dElectricalOpticalInterface
	strPhysicalConnector = dPhysicalConnector
	strAccessBearerCircuitFramingStructure = dAccessBearerCircuitFramingStructure
	strAccessSpeed = dAccessSpeed
	strPortSpeed = dPortSpeed

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If  dTypeOfOrder <> "OB_FULLPSTN_MODIFY" Then
		
		If objPage.WebList("lstAccessType").Exist Then
			'Retriving Access Type 
			strRetrivedText = objPage.WebList("lstAccessType").GetROProperty("value")
			If strRetrivedText <> "" Then
				Call ReportLog("Access Type","Access Type should be populated","Access Type is populated with the value - "&strRetrivedText,"PASS","")
			Else
				Call ReportLog("Access Type","Access Type should be populated","Access Type is not populated","FAIL","FALSE")
				Environment.Value("Action_Result")=False
				Exit Function
			End If
		End If
		
	
		If objPage.WebList("lstAccessCircuitResilienceAndDiversity").Exist(5) Then
			'Select  AccessCircuitResilienceAndDiversity value  from drop down list  -   Access Details  page
			blnResult = selectValueFromPageList("lstAccessCircuitResilienceAndDiversity",strAccessCircuitResilienceAndDiversity)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		If objPage.WebList("lstElectricalOpticalInterface").Exist(5) Then
			'Select  Electrical Optical Interface from drop down list	- Access Details Page
			blnResult = selectValueFromPageList("lstElectricalOpticalInterface",strElectricalOpticalInterface)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
	
		If objPage.WebList("lstPhysicalConnector").Exist(5) Then
			'Select  PhysicalConnector  value  from drop down list    -   Access Details  page
			blnResult = selectValueFromPageList("lstPhysicalConnector",strPhysicalConnector)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		If objPage.WebList("lstAccessBearerCircuitFramingStructure").Exist(5) Then
			'Select  AccessBearerCircuitFramingStructure  value  from drop down list    -   Access Details  page
			blnResult = selectValueFromPageList("lstAccessBearerCircuitFramingStructure",strAccessBearerCircuitFramingStructure)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		If objPage.WebList("lstAccessSpeed").Exist(5) Then
			'Select  AccessSpeed  value  from drop down list    -   Access Details  page
			blnResult = selectValueFromPageList("lstAccessSpeed",strAccessSpeed)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		If objPage.WebList("lstPortSpeed").Exist(5) Then
			'Select  PortSpeed  value  from drop down list    -   Access Details  page
			blnResult = selectValueFromPageList("lstPortSpeed",strPortSpeed)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		For intCounter = 1 to 5
			If Browser("brweDCAPortal").Dialog("dlgVpnalert").Exist Then
				Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOK").Highlight
				Browser("brweDCAPortal").Dialog("dlgVpnalert").WinButton("btnOK").click
				Exit For
			End If
		Next
	Else
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	End if

	'Check if Navigated to Site Location Details Page
    Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Set objMsg = objpage.Webelement("webElmConfigureCPE")
    'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Configure CPE page","Should be navigated to Configure CPE   page on clicking Next Buttton","Not navigated to Configure CPE  page on clicking Next Buttton","FAIL","TRUE")
		Environment.Value("Action_Result")=False
		Exit Function
	Else
		strMessage = GetWebElementText("webElmConfigureCPE")
    	Call ReportLog("Configure CPE page","Should be navigated to Configure CPE  page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If


End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
