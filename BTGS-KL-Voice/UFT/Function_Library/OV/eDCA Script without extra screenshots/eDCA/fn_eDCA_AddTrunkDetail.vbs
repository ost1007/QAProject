'****************************************************************************************************************************
' Function Name	 :  fn_eDCA_AddTrunkDetail
' Purpose	 	 :  Adding a new trunk details for  trunk group
' Author	 	 : Vamshi Krishna G
' Creation Date    : 21/11/13
' Return values :	NA
'****************************************************************************************************************************	

Public function fn_eDCA_AddTrunkDetail(deDCAOrderID, dUniqueTrunkFriendlyName, dTrunkCACLimit, dPBXIPaddress, dMainSwitchBoardNumber, dUniqueTrunkFriendlyName1, dTrunkCACLimit1, dPBXIPaddress1, dMainSwitchBoardNumber1, dSiteResiliency, dAddMoreTrunkDetail)

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
		If blnResult = "True" Then
			blnResult = enterText("txtUniqueTrunkFriendlyName",strUniqueTrunkFriendlyName)
			If blnResult = False then
				Call ReportLog("UniqueTrunkFriendlyName","UniqueTrunkFriendlyName should be entered","UniqueTrunkFriendlyName is not eneterd","FAIL","TRUE")
				Environment.Value("Action_Result")=False
				Exit Function
			End If
		End If
	End If

	blnResult = objPage.WebList("lstTrunkGroupToBeLinked").Exist
	If blnResult = "True" Then
		'Selecting the trunk group to be linked from drop down
		strTrunkGroupToBeLinked = objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("all items")
		arrTrunkGroupToBeLinked = Split(strTrunkGroupToBeLinked,";")
		objPage.WebList("lstTrunkGroupToBeLinked").Select arrTrunkGroupToBeLinked(0)

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	
	'Enter the Trunk CAC Limit - Rel40 New Requirement
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync 'add by FKH
	blnResult = enterText("txtTrunkCACLimit", strTrunkCACLimit)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	blnResult = objPage.WebEdit("txtPBXIPaddress").Exist
	If blnResult Then
		'Enter the PBXIPaddress
		blnResult = enterText("txtPBXIPaddress",strPBXIPaddress)
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

	If objPage.WebEdit("txtMainSwitchBoardNumber").Exist(30) Then
		'Enetring MainSwitchBoardNumber 
		blnResult = enterText("txtMainSwitchBoardNumber",strMainSwitchBoardNumber)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If

	If objPage.WebCheckBox("name:=.*ChkDefaultPub").Exist(30) Then
		objPage.WebCheckBox("name:=.*ChkDefaultPub").Set "ON"
	End If
        	
	'Click on Save Button
	blnResult = clickButton("btnTrunkDetailSave")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Trap Error if unable to Save the details of MSB
	With objPage.WebElement("class:=form_error_font","innertext:=For country .*, the Main SwitchBoard Number should start with Country code 90.*", "index:=0")
		If .Exist(10) Then
			If .GetROProperty("height") > 0 Then
				Call ReportLog("Main Switch Board Number", "Error while updating Main Switch Board Number", "<I>" & .GetROProperty("innertext") & "</I>", "FAIL", False)
				Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
				Environment("Action_Result") = False : Exit Function
			End If
		End If
	End With
	
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
		
		'Trap Error if unable to Save the details of MSB
		With objPage.WebElement("class:=form_error_font","innertext:=For country .*, the Main SwitchBoard Number should start with Country code 90.*", "index:=0")
			If .Exist(10) Then
				If .GetROProperty("height") > 0 Then
					Call ReportLog("Main Switch Board Number", "Error while updating Main Switch Board Number", "<I>" & .GetROProperty("innertext") & "</I>", "FAIL", False)
					Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
					Environment("Action_Result") = False : Exit Function
				End If
			End If
		End With
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
