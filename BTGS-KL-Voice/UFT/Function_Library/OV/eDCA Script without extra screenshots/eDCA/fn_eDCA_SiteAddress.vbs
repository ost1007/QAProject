'****************************************************************************************************************************
' Function Name	 :fn_eDCA_SiteAddress
' Purpose	 	 : Function to enter values in Site address
' Author	 	 : Sathish Lakshminarayana
' Creation Date    : 29/05/2013     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_SiteAddress(dOrderType,dFloor,dRoom,dBuildingNumber,dStreet,dCity,dPostOrZIPCode,dStateOrProvince)

	'Variable Declaration Section
	Dim strFloor,strRoom,strBuildingNumber,strStreet,strCity,strPostOrZIPCode,strStateOrProvince
	Dim objMsg
	Dim blnResult

	'Assignment of Variables
	strFloor = dFloor
	strRoom = dRoom
	strBuildingNumber = dBuildingNumber
	strStreet = dStreet
	strCity = dCity
	strPostOrZIPCode = dPostOrZIPCode
	strStateOrProvince = dStateOrProvince

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	
	'Enter floor  -  Site Address  page
	blnResult = objPage.WebEdit("txtFloor").Exist(5)
	If blnResult = "True" Then
		If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
			If  ObjPage.WebEdit("txtFloor").GetROProperty("disabled") = 0 then 
				strFloor = objpage.WebEdit("txtFloor").GetROProperty("Value")
				Call ReportLog("Site Address page","Field Floor is disabled and Default value displayed in field Floor","Default value is  - "&strFloor,"PASS","")
			Else
				blnResult = enterText("txtFloor",strFloor)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If
		Else
		blnResult = enterText("txtFloor",strFloor)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
	End if

	'Enter Room  -  Site Address  page
	blnResult = objPage.WebEdit("txtRoom").Exist(5)
	If blnResult = "True" Then
		If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
			If  ObjPage.WebEdit("txtRoom").GetROProperty("disabled") = 0 then 
				strRoom = objpage.WebEdit("txtRoom").GetROProperty("Value")
				Call ReportLog("Site Address page","Field Room is disabled and Default value displayed in field Room","Default value is  - "&strRoom,"PASS","")
			Else
        		blnResult = enterText("txtRoom",strRoom)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If
		Else
		blnResult = enterText("txtRoom",strRoom)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
	End if

	'Enter Building number-  Site Address  page		
	blnResult = objPage.WebEdit("txtBuildingNumber").Exist(5)
	If blnResult = "True" Then
		If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
			If  ObjPage.WebEdit("txtBuildingNumber").GetROProperty("disabled") = 0 then 
				strBuildingNumber = objpage.WebEdit("txtBuildingNumber").GetROProperty("Value")
				Call ReportLog("Site Address page","Field Building Number is disabled and Default value displayed in field Building Number","Default value is  - "&strBuildingNumber,"PASS","")
			Else
				blnResult = enterText("txtBuildingNumber",strBuildingNumber)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If
		 Else
			blnResult = enterText("txtBuildingNumber",strBuildingNumber)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
	End if

	'Enter Street  - Site Address  page
	blnResult = objPage.WebEdit("txtStreet").Exist(5)
	If blnResult = "True" Then
		If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
			If  ObjPage.WebEdit("txtStreet").GetROProperty("disabled") = 0 then 
				strStreet = objpage.WebEdit("txtStreet").GetROProperty("Value")
				Call ReportLog("Site Address page","Field Street is disabled and Default value displayed in field Street","Default value is  - "&strStreet,"PASS","")
			Else		
				blnResult = enterText("txtStreet",strStreet)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If
		Else
			blnResult = enterText("txtStreet",strStreet)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if 
	End if

	'Enter City -  Site Address  page				
	blnResult = objPage.WebEdit("txtCity").Exist(5)
	If blnResult = "True" Then
		If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
			If  ObjPage.WebEdit("txtCity").GetROProperty("disabled") = 0 then 
				strCity = objpage.WebEdit("txtCity").GetROProperty("Value")
				Call ReportLog("Site Address page","Field City is disabled and Default value displayed in field City","Default value is  - "&strCity,"PASS","")
			Else			
				blnResult = enterText("txtCity",strCity)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If	
		 Else
		blnResult = enterText("txtCity",strCity)
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
	End if

	'Enter Post / Zip Code -  Site Address  page
	blnResult = objPage.WebEdit("txtPostOrZIPCode").Exist(5)
	If blnResult = "True" Then
		If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
			If  ObjPage.WebEdit("txtPostOrZIPCode").GetROProperty("disabled") = 0 then 
				strPostOrZIPCode = objpage.WebEdit("txtPostOrZIPCode").GetROProperty("Value")
				Call ReportLog("Site Address page","Field PostOrZIPCode is disabled and Default value displayed in field PostOrZIPCode","Default value is  - "&strPostOrZIPCode,"PASS","")
			Else			
				blnResult = enterText("txtPostOrZIPCode",strPostOrZIPCode)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If	
		Else
			blnResult = enterText("txtPostOrZIPCode",strPostOrZIPCode)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
	End if

	'Enter State / Province -   Site Address  page
	If objPage.WebEdit("txtStateOrProvince").Exist(2) Then
			If dOrderType = "CEASE" or dOrderType = "MODIFY"Then
				If  ObjPage.WebEdit("txtStateOrProvince").GetROProperty("disabled") = 0 then 
					strtxtStateOrProvince = objpage.WebEdit("txtStateOrProvince").GetROProperty("Value")
					Call ReportLog("Site Address page","Field StateOrProvince is disabled and Default value displayed in field PostOrZIPCode","Default value is  - "&strtxtStateOrProvince,"PASS","")
				Else			
					blnResult = enterText("txtStateOrProvince",strStateOrProvince)
						If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				End If
			Else
				blnResult = enterText("txtStateOrProvince",strStateOrProvince)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End if
		
	ElseIf objPage.WebList("lstStateOrProvince").Exist(5) Then
			If dOrderType = "CEASE" Then
				If  ObjPage.WebEdit("txtStateOrProvince").GetROProperty("disabled") = 0 then 
					strtxtStateOrProvince = objpage.WebList("txtStateOrProvince").GetROProperty("Value")
					Call ReportLog("Site Address page","Field txtStateOrProvince is disabled and Default value displayed in field PostOrZIPCode","Default value is  - "&strtxtStateOrProvince,"PASS","")
				End If
			Else
				If Instr(objPage.WebList("lstStateOrProvince").GetROProperty("all items"), strStateOrProvince) <= 0 Then
					strStateOrProvince = objPage.WebList("lstStateOrProvince").GetItem(2)
				End If
	
				blnResult = SelectValueFromPageList("lstStateOrProvince",strStateOrProvince)
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			End If
	End If
	
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if Navigated to Site Location Details Page
	Set objMsg = objpage.Webelement("webElmSiteContactDetails")
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("Site Contact Details page","Should be navigated to Site Contact Details  page on clicking Next Buttton","Not navigated to Site Contact Details page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmSiteContactDetails")
		Call ReportLog("Site Contact Details page","Should be navigated to Site Contact Details page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If


End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
