
'****************************************************************************************************************************
' Function Name	 : fn_eDCA_OnevoiceAccessDetails()
' Purpose	 	 :  Checking the presence of  access details avialability  for MPLS
' Author	 	 : Vamshi Krishna G
' Modified By : Biswabharati Sahoo
' Creation Date    : 10/06/2013
' Modified Data:  06/09/2013
' Return values :	NA
'****************************************************************************************************************************		
Public function fn_eDCA_OnevoiceAccessDetails(dTypeOfOrder,dElectricalOpticalInterfaceEthernet,dAccessSpeedEthernet,dOLOInterfaceMTU,dAccessDeliveryType,dSupplierInterconnectionType,dCountry,dPhysicalConnector)

	'Declaration of variables
	Dim objMsg,strMessage
	Dim strElectricalOpticalInterfaceEthernet,strAccessSpeedEthernet,strOLOInterfaceMTU,strAccessDeliveryType,strSupplierInterconnectionType

	'Assignment of variables
	strElectricalOpticalInterfaceEthernet = dElectricalOpticalInterfaceEthernet
	strAccessSpeedEthernet = dAccessSpeedEthernet
	strOLOInterfaceMTU = dOLOInterfaceMTU
	strAccessDeliveryType = dAccessDeliveryType
	strSupplierInterconnectionType = dSupplierInterconnectionType
	strCountry = dCountry
	strPhysicalConnector = dPhysicalConnector

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Entering particulars for Ethernet Product
	Select Case UCase(dTypeOfOrder)
		Case "ETHERNETPROVIDE", "TDMPROVIDE", "P2PETHERNETPROVIDE", "ETHERNETMODIFY"
		
				'Selecting Electrical/Optical Interface from drop down
				blnResult = selectValueFromPageList("lstElectricalOpticalInterfaceEthernet",strElectricalOpticalInterfaceEthernet)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				
				'Retriving the Physical connector value
				strRetrivedText = objPage.WebList("lstPhysicalConnector").GetROProperty("value")
				If strCountry = "Germany" Then
					If  strRetrivedText = "RJ45" Then
						Call ReportLog("PhysicalConnector","PhysicalConnector should be retrived","PhysicalConnector retrived-"&strRetrivedText,"PASS","")
					Else
						Call ReportLog("PhysicalConnector","PhysicalConnector should be retrived","PhysicalConnector is not retrived","FAIL","TRUE")
						blnResult = selectValueFromPageList("lstPhysicalConnector",strPhysicalConnector)
							If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
					End If
				Else
					If strRetrivedText<> "" Then
						Call ReportLog("PhysicalConnector","PhysicalConnector should be retrived","PhysicalConnector retrived-"&strRetrivedText,"PASS","")
					Else
						Call ReportLog("PhysicalConnector","PhysicalConnector should be retrived","PhysicalConnector is not retrived","FAIL","TRUE")
						Environment("Action_Result") = False : Exit Function
					End If
				End If
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				
				'Selecting Access Speed from drop down list
				blnResult = selectValueFromPageList("lstAccessSpeedEthernet",strAccessSpeedEthernet)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End Select

	If  UCase(dTypeOfOrder) = "ETHERNETPROVIDE" or dTypeOfOrder = "P2PEtherNetProvide" Then
		'Retriving PortSpeed value
		strRetrivedText = objPage.WebList("lstPortSpeed").GetROProperty("value")
		If strRetrivedText<> "" Then
			Call ReportLog("PortSpeed","PortSpeed should be retrived","PortSpeed retrived-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("PortSpeed","PortSpeed should be retrived","PortSpeed is not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If

		'Selecting Access Delivery Type from drop down list
		blnResult = selectValueFromPageList("lstAccessDeliveryType",strAccessDeliveryType)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Entering valuein OLO Interface MTU
		blnResult = enterText("txtOLOInterfaceMTU",strOLOInterfaceMTU)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

		'Selecting Supplier Interconnection Type from drop down list
		blnResult = selectValueFromPageList("lstSupplierInterconnectionType",strSupplierInterconnectionType)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'One voice Access Details notification message for GSIP product

	If  UCase(dTypeOfOrder) = "GSIPPROVIDE" OR UCase(dTypeOfOrder) = "GSIPMODIFY" or UCase(dTypeOfOrder) = "GVPNBUNDLEDMODIFY"  Then
		'Retrive alert message in the browser 
		strRetrivedText = objPage.WebElement("webElmAccessDetailsNotification").GetROProperty("innertext")
		If strRetrivedText<> "" Then
			Call ReportLog("AccessDetailsNotification","AccessDetailsNotification should be retrived","AccessDetailsNotification retrived-"&strRetrivedText,"PASS","")
		Else
			Call ReportLog("AccessDetailsNotification","AccessDetailsNotification should be retrived","AccessDetailsNotification is not retrived","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Clicikng on Next button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(10) Then
		Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

	'Check if navigated to AccessDetails page
	Set objMsg = objpage.Webelement("webElmOnevoiceConfigureNTE")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("OnevoiceAccessDetails","Should be navigated to OnevoiceConfigureNTE page on clicking Next Buttton","Not navigated to OnevoiceConfigureNTE page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmOnevoiceConfigureNTE")
		Call ReportLog("OnevoiceAccessDetails","Should be navigated to OnevoiceConfigureNTE page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","TRUE")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
