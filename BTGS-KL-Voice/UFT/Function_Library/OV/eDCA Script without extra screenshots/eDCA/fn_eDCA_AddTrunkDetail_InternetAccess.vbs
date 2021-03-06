'****************************************************************************************************************************
' Function Name	 :  fn_eDCA_AddTrunkDetail
' Purpose	 	 :  Adding a new trunk details for trunk group for Internet Access
' Creation Date    :  19-Nov-2015
' Return values :	NA
'****************************************************************************************************************************	
Public function fn_eDCA_AddTrunkDetail_InternetAccess(deDCAOrderID, dUniqueTrunkFriendlyName, dTrunkCACLimit, dPBXIPaddress,  dIsRTPIPSameAsPBX, dRTPIPAddress, dMainSwitchBoardNumber, dUniqueTrunkFriendlyName1, dTrunkCACLimit1, dPBXIPaddress1, dMainSwitchBoardNumber1, dSiteResiliency, dAddMoreTrunkDetail)

	'Declaration of variables
	Dim strUniqueTrunkFriendlyName,strPBXIPaddress,strMainSwitchBoardNumber,streDCAOrderID
	
	'Assignment of values to variables
	streDCAOrderID = deDCAOrderID
	strUniqueTrunkFriendlyName = dUniqueTrunkFriendlyName
	strPBXIPaddress = dPBXIPaddress
	strMainSwitchBoardNumber = dMainSwitchBoardNumber
	strUniqueTrunkFriendlyName1 = dUniqueTrunkFriendlyName1
	strPBXIPaddress1 = dPBXIPaddress1
	strMainSwitchBoardNumber1 = dMainSwitchBoardNumber1
	strSiteResiliency = dSiteResiliency
	strAddMoreTrunkDetail = dAddMoreTrunkDetail
	strTrunkCACLimit = dTrunkCACLimit
	strTrunkCACLimit1 = dTrunkCACLimit1

	'Click on AddNewTrunkDetail button 
	blnResult = clickButton("btnAddNewTrunkDetail")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Enter the UniqueTrunkFriendlyName
	If strUniqueTrunkFriendlyName <> ""  Then
		strUniqueTrunkFriendlyName = streDCAOrderID&strUniqueTrunkFriendlyName
		blnResult = objPage.WebEdit("txtUniqueTrunkFriendlyName").Exist
		If blnResult Then
			blnResult = enterText("txtUniqueTrunkFriendlyName",strUniqueTrunkFriendlyName)
			If Not blnResult then
				Call ReportLog("UniqueTrunkFriendlyName","UniqueTrunkFriendlyName should be entered","UniqueTrunkFriendlyName is not eneterd","FAIL","TRUE")
				Environment.Value("Action_Result")=False
				Exit Function
			End If
		End If
	End If

	blnResult = objPage.WebList("lstTrunkGroupToBeLinked").Exist
	If blnResult Then
		'Selecting the trunk group to be linked from drop down
		strTrunkGroupToBeLinked = objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("all items")
		arrTrunkGroupToBeLinked = Split(strTrunkGroupToBeLinked,";")
		objPage.WebList("lstTrunkGroupToBeLinked").Select arrTrunkGroupToBeLinked(0)
		Wait 5
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Enter the Trunk CAC Limit - Rel40 New Requirement
	blnResult = enterText("txtTrunkCACLimit", strTrunkCACLimit)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	blnResult = objPage.WebEdit("txtPBXIPaddress").Exist
	If blnResult Then
		'Enter the PBXIPaddress
		blnResult = enterText("txtPBXIPaddress",strPBXIPaddress)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Wait 5
	
	'Select whether RTP IP address is same as PBX IP Address '#R41(19-Nov-2015)
	blnResult = selectValueFromPageList("lstIsRTPIPSameAsPBXIP", dIsRTPIPSameAsPBX)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Enter the RTP IP Address if PBX IP Address is not same as PBX IP Address '#R41(19-Nov-2015)
	If dIsRTPIPSameAsPBX = "No" Then
		blnResult = enterText("txtRTPIPAddress", dRTPIPAddress)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function	
	End If

	'Checking TrunkPriority  parameter
	strRetrivedText = objPage.WebEdit("txtTrunkPriority").GetROProperty("value")
	If strRetrivedText <> "" Then
		Call ReportLog("TrunkPriority","TrunkPriority should be populated","TrunkPriority should be populated with value - " & strRetrivedText,"PASS","")
	Else
		Call ReportLog("TrunkPriority","TrunkPriority should be populated","TrunkPriority is not populated","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

	If objPage.WebEdit("txtMainSwitchBoardNumber").Exist Then
		'Entering MainSwitchBoardNumber 
		blnResult = enterText("txtMainSwitchBoardNumber",strMainSwitchBoardNumber)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	If objPage.WebCheckBox("name:=.*ChkDefaultPub").Exist Then
		objPage.WebCheckBox("name:=.*ChkDefaultPub").Set "ON"
	End If
        	
	'Click on Save Button
	blnResult = clickButton("btnTrunkDetailSave")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Retriving the UniqueTrunkGroupFriendlyName value if it is not provided in data sheet
	If strUniqueTrunkFriendlyName = ""  Then
		strRetrivedText = objPage.WebEdit("txtUniqueTrunkFriendlyName").GetROProperty("value")
		If  strRetrivedText <> "" Then
			Call ReportLog("UniqueTrunkFriendlyName", "UniqueTrunkFriendlyName should be populated","UniqueTrunkFriendlyName is populated with the value - "&strRetrivedText,"PASS","")
		Else
			Call ReportLog("UniqueTrunkFriendlyName","UniqueTrunkFriendlyName should be populated","UniqueTrunkFriendlyName not populated","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	If strSiteResiliency = "Yes" and strAddMoreTrunkDetail = "Yes" Then

		'Click on AddNewTrunkDetail button 
		blnResult = clickButton("btnAddNewTrunkDetail")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'Enter the UniqueTrunkFriendlyName
		If strUniqueTrunkFriendlyName1 <> ""  Then
			strUniqueTrunkFriendlyName1 = streDCAOrderID & strUniqueTrunkFriendlyName1
			blnResult = objPage.WebEdit("txtUniqueTrunkFriendlyName").Exist
			If blnResult = "True" Then
				blnResult = enterText("txtUniqueTrunkFriendlyName",strUniqueTrunkFriendlyName1)
				If blnResult = False then
					Call ReportLog("UniqueTrunkFriendlyName","UniqueTrunkFriendlyName should be entered","UniqueTrunkFriendlyName is not eneterd","FAIL","TRUE")
					Environment("Action_Result")=False : Exit Function
				End If
			End IF
		End If

		blnResult = objPage.WebList("lstTrunkGroupToBeLinked").Exist
		If blnResult Then
			'Selecting the trunk group to be linked from drop down
			strTrunkGroupToBeLinked = objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("all items")
			arrTrunkGroupToBeLinked = Split(strTrunkGroupToBeLinked,";")
			objPage.WebList("lstTrunkGroupToBeLinked").Select arrTrunkGroupToBeLinked(1)
	
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		
		'Enter the Trunk CAC Limit - Rel40 New Requirement
		blnResult = enterText("txtTrunkCACLimit", strTrunkCACLimit1)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Enter the PBXIPaddress
		blnResult = objPage.WebEdit("txtPBXIPaddress").Exist
		If blnResult = "True" Then
			blnResult = enterText("txtPBXIPaddress",strPBXIPaddress1)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		End If
		
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		Wait 5
		
		'Select whether RTP IP address is same as PBX IP Address '#R41(19-Nov-2015)
		blnResult = selectValueFromPageList("lstIsRTPIPSameAsPBXIP", dIsRTPIPSameAsPBX)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
		'Enter the RTP IP Address if PBX IP Address is not same as PBX IP Address '#R41(19-Nov-2015)
		If dIsRTPIPSameAsPBX = "No" Then
			blnResult = enterText("txtRTPIPAddress", dRTPIPAddress)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function	
		End If

		'Checking TrunkPriority  parameter
		strRetrivedText = objPage.WebEdit("txtTrunkPriority").GetROProperty("value")
		If strRetrivedText <> "" Then
			Call ReportLog("TrunkPriority","TrunkPriority should be populated","TrunkPriority should be populated with value - "&strRetrivedText,"PASS","")
		Else
			Call ReportLog("TrunkPriority","TrunkPriority should be populated","TrunkPriority is not populated","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	
		'Enetring MainSwitchBoardNumber
		If objPage.WebEdit("txtMainSwitchBoardNumber").Exist Then
			blnResult = enterText("txtMainSwitchBoardNumber",strMainSwitchBoardNumber1)
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
    		End If

		'Click on Save Button
		blnResult = clickButton("btnTrunkDetailSave")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
