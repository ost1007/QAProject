'****************************************************************************************************************************
' Function Name	 : fn_eDCA_SIPTrunkingDetails_InternetAccess
' Purpose	 	 :  Adding a new trunk group and details for it
' History			: Nagaraj V || 18/11/2015 || NA
' Return values :	Nil
'****************************************************************************************************************************	
Public function fn_eDCA_SIPTrunkingDetails_InternetAccess(dTypeOfOrder, deDCAOrderId, dCodec, dSBCTransportProtocol, dUniqueTrunkGroupFriendlyName, dTrunkGroupCACLimit,_
		dTrunkGroupTrunkCallDistribution, dUniqueTrunkFriendlyName, dTrunkCACLimit, dPBXIPaddress, dIsRTPIPSameAsPBX, dRTPIPAddress, dMainSwitchBoardNumber, dPresentationFlag,_
		dNetworkCLIFlag, dScreenValue, dSiteResiliency, dAddMoreTrunkGroup, dAddMoreTrunkDetail, dUniqueTrunkGroupFriendlyName1,_
		dTrunkGroupCACLimit1, dUniqueTrunkFriendlyName1, dTrunkCACLimit1, dPBXIPaddress1, dMainSwitchBoardNumber1)

	'Decalration of variables
	Dim streDCAOrderID,strTypeOfOrder
	Dim blnResult,strRetrivedText
	Dim strCodec, strSBCTransportProtocol, strTrunkGroupToBeLinked, strUniqueTrunkGroupFriendlyName, strTrunkGroupCACLimit, strTrunkGroupTrunkCallDistribution, strUniqueTrunkFriendlyName, strPBXIPaddress, strPresentationFlag, strNetworkCLIFlag, strScreenValue, strMainSwitchBoardNumber, strSiteResiliency, strAddMoreTrunkGroup, strAddMoreTrunkDetail

	'Assignment of variables
	streDCAOrderID = deDCAOrderId
	strCodec = dCodec
	strSBCTransportProtocol = dSBCTransportProtocol
	strUniqueTrunkGroupFriendlyName = dUniqueTrunkGroupFriendlyName
	strTrunkGroupCACLimit = dTrunkGroupCACLimit
	strTrunkGroupTrunkCallDistribution = dTrunkGroupTrunkCallDistribution
	strUniqueTrunkFriendlyName = dUniqueTrunkFriendlyName
	strPBXIPaddress = dPBXIPaddress
	strMainSwitchBoardNumber = dMainSwitchBoardNumber
	strPresentationFlag = dPresentationFlag
	strNetworkCLIFlag = dNetworkCLIFlag
	strScreenValue = dScreenValue
	strTypeOfOrder = dTypeOfOrder
	strSiteResiliency = dSiteResiliency
	strAddMoreTrunkGroup = dAddMoreTrunkGroup
	strAddMoreTrunkDetail = dAddMoreTrunkDetail
	strUniqueTrunkGroupFriendlyName1 = dUniqueTrunkGroupFriendlyName1
	strTrunkGroupCACLimit1 = dTrunkGroupCACLimit1
	strUniqueTrunkFriendlyName1 = dUniqueTrunkFriendlyName1
	strPBXIPaddress1 = dPBXIPaddress1
	strMainSwitchBoardNumber1 = dMainSwitchBoardNumber1
	strTrunkCACLimit = dTrunkCACLimit
	strTrunkCACLimit1 = dTrunkCACLimit1

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'**********************************************************************************************************************************************
	'NOAS Root Details
	'**********************************************************************************************************************************************
	'Selecting Codec from drop drown list
	blnResult = selectValueFromPageList("lstCodec",strCodec)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
	'Selecting SBC Transport protocol from drop downlist
	blnResult = selectValueFromPageList("lstSBCTransportProtocol",strSBCTransportProtocol)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync		

	'**********************************************************************************************************************************************
	'Adding a new trunk group
	'**********************************************************************************************************************************************	
	Call fn_eDCA_AddTrunkGroup(streDCAOrderID,strCodec,strSBCTransportProtocol,strUniqueTrunkGroupFriendlyName,strTrunkGroupCACLimit,strTrunkGroupTrunkCallDistribution,strUniqueTrunkGroupFriendlyName1,strTrunkGroupCACLimit1,strSiteResiliency,strAddMoreTrunkGroup)
		If Not Environment("Action_Result") Then Exit Function
    
	'****************************************************************************************************************************************************
	'Adding a newTrunk detail 
	'***************************************************************************************************************************************************

	Call fn_eDCA_AddTrunkDetail_InternetAccess(streDCAOrderID, strUniqueTrunkFriendlyName, strTrunkCACLimit, strPBXIPaddress, dIsRTPIPSameAsPBX, dRTPIPAddress, strMainSwitchBoardNumber, strUniqueTrunkFriendlyName1, strTrunkCACLimit1, strPBXIPaddress1, strMainSwitchBoardNumber1, strSiteResiliency, strAddMoreTrunkDetail)
		If Not Environment("Action_Result") Then Exit Function

	'**********************************************************************************************************************************************
	'Trunk Screen List
	'***********************************************************************************************************************************************

	If objPage.WebButton("btnAddNewScreenList").Exist(60) Then
		'Click on Add New Screen List Button
		blnResult = clickButton("btnAddNewScreenList")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Select Trunk Name from drop down list
		strTrunkName = objPage.WebList("lstTrunkName").GetROProperty("all items")
		arrTrunkName = Split(strTrunkName,";")
		objPage.WebList("lstTrunkName").Select arrTrunkName(0)

		'Selecting Presentation flag from drop down
		blnResult = selectValueFromPageList("lstPresentationFlag",strPresentationFlag)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Selecting NetworkCLI flag from drop down
		blnResult = selectValueFromPageList("lstNetworkCLIFlag",strNetworkCLIFlag)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Entering Screen Value into the text box
		blnResult = enterText("txtScreenValue",strScreenValue)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		'Click on Save Button
		blnResult = clickButton("btnScreenListSave")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
	End If

	'*******************************************************************************************************************************************
	'Click on Save Button
	blnResult = clickButton("btnSave")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigated to additional features details page 
	Set objMsg = objpage.Webelement("webElmAdditionalFeaturesDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Not navigated to AdditionalFeaturesDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmAdditionalFeaturesDetails")
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
