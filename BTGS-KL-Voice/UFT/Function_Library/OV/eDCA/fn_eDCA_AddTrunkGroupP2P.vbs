'****************************************************************************************************************************
' Function Name	 :  fn_eDCA_AddTrunkGroupP2P
' Purpose	 	 :  Adding a new trunk group and details for it
' Author	 	 : Vamshi Krishna G
' Creation Date    : 10/06/2013
' Return values :	NA
'****************************************************************************************************************************	

Public function fn_eDCA_AddTrunkGroupP2P(deDCAOrderID,dCodec,dSBCTransportProtocol,dUniqueTrunkGroupFriendlyName,dTrunkGroupCACLimit,dTrunkGroupTrunkCallDistribution,dUniqueTrunkGroupFriendlyName1,dTrunkGroupCACLimit1,dSiteResiliency,dAddMoreTrunkGroup)

	'Decalration of variables
		Dim streDCAOrderID,strSiteResiliency,strAddMoreTrunkGroup
		Dim blnResult,strRetrivedText
		Dim strCodec,strSBCTransportProtocol,strTrunkGroupToBeLinked,strUniqueTrunkGroupFriendlyName,strTrunkGroupCACLimit,strTrunkGroupTrunkCallDistribution
		Dim strUniqueTrunkGroupFriendlyName1,strTrunkGroupCACLimit1
	
	'Assignment of variables
		streDCAOrderID = deDCAOrderID
		strCodec = dCodec
		strSBCTransportProtocol = dSBCTransportProtocol
		strUniqueTrunkGroupFriendlyName = dUniqueTrunkGroupFriendlyName
		strTrunkGroupCACLimit = dTrunkGroupCACLimit
		strTrunkGroupTrunkCallDistribution = dTrunkGroupTrunkCallDistribution
		strUniqueTrunkGroupFriendlyName1 = dUniqueTrunkGroupFriendlyName1
		strTrunkGroupCACLimit1 = dTrunkGroupCACLimit1
		strSiteResiliency = dSiteResiliency
		strAddMoreTrunkGroup = dAddMoreTrunkGroup
	
		'**********************************************************************************************************************************************
		'Adding a new trunk group
		'**********************************************************************************************************************************************
		'Clicking on AddNewTrunkGroup Button
		blnResult = clickButton("btnAddNewTrunkGroup")
		If blnResult = False Then
			Environment.Value("Action_Result")=False 
			Call EndReport()
			Exit Function
		End If
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		' -----------------------------------------------------------Checking for Already Trunk Exist Error---------------------------------------------------------------------------------------------
		If Browser("brweDCAPortal").Page("pgeDCAPortal").WebElement("webElmTrunkExist").Exist(10) Then 
			' ----------------------------------------Clicking On Add New Trunk Button----------------------------------------------------------------------------------
			blnResult = clickButton("btnAddNewTrunk")
			If blnResult = False Then
				Environment.Value("Action_Result")=False 
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
    	
		'Enter the UniqueTrunkGroupFriendlyName 
		If strUniqueTrunkGroupFriendlyName <>"" Then
			strUniqueTrunkGroupFriendlyName = streDCAOrderID & strUniqueTrunkGroupFriendlyName
			blnResult = objPage.WebEdit("txtUniqueTrunkGroupFriendlyName").Exist
			If blnResult Then
				blnResult = enterText("txtUniqueTrunkGroupFriendlyName",strUniqueTrunkGroupFriendlyName)
				If blnResult = False then
					Call ReportLog("UniqueTrunkGroupFriendlyName","UniqueTrunkGroupFriendlyName should be entered","UniqueTrunkGroupFriendlyName is not eneterd","FAIL","TRUE")
					Environment.Value("Action_Result")=False 
					Call EndReport()
					Exit Function                                                                        	
				End If
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
		End If
    
		' --------------------------------Enter the CACLimit Value-------------------------------
		blnResult = objPage.WebEdit("txtTrunkGroupCACLimit").Exist
		If blnResult Then
			blnResult = enterText("txtTrunkGroupCACLimit", strTrunkGroupCACLimit)
				If blnResult = False then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
		'---------------------Select the TrunkGroupTrunkCallDistribution in drop down  limit  -------------------------

''''''''''''''''''''''		blnResult = objPage.WebList("lstTrunkGroupTrunkCallDistribution").Exist
''''''''''''''''''''''		If blnResult = "True" Then
''''''''''''''''''''''			blnResult = selectValueFromPageList("lstTrunkGroupTrunkCallDistribution",strTrunkGroupTrunkCallDistribution)
''''''''''''''''''''''			If blnResult= False Then
''''''''''''''''''''''				Environment.Value("Action_Result")=False 
''''''''''''''''''''''				Call EndReport()
''''''''''''''''''''''				Exit Function
''''''''''''''''''''''			End If
''''''''''''''''''''''		
''''''''''''''''''''''			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
''''''''''''''''''''''		End If
	
   	'	'Retriving the TrunkGroupTrunkCallDistribution in drop down 
	'		strRetrivedText = objPage.WebList("lstTrunkGroupTrunkCallDistribution").GetROProperty("value")
	'			If strRetrivedText<> ""  Then
	'				Call ReportLog("TrunkGroupTrunkCallDistribution","TrunkGroupTrunkCallDistribution should be populated","TrunkGroupTrunkCallDistribution should be populated with value- " &strRetrivedText,"PASS","")
	'			Else
	'				Call ReportLog("TrunkGroupTrunkCallDistribution","TrunkGroupTrunkCallDistribution should be populated","TrunkGroupTrunkCallDistribution not populated","FAIL","TRUE")
	'			End If
	
	'Clicking on Save button
	blnResult = clickButton("btnTrunkGroupSave")
	If blnResult = False Then
		Environment.Value("Action_Result")=False 
		Call EndReport()
		Exit Function
	End If

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

    blnResult = objPage.WebEdit("txtTrunkGroupCACLimit").Exist
	If blnResult = "True" Then
		'Retriving the TrunkGroupCACBandwidtth Limit
		strRetrivedText = objPage.WebEdit("txtTrunkGroupCACLimit").GetROProperty("value")
		If  strRetrivedText <> "" Then
			Call ReportLog("TrunkGroupCACLimit", "TrunkGroupCACLimit should be populated","TrunkGroupCACLimit is populated with the value - "&strRetrivedText,"PASS","")
		Else
			Call ReportLog("TrunkGroupCACLimit","TrunkGroupCACLimit should be populated","TrunkGroupCACLimit not populated","FAIL","TRUE")
		End If
	End If
	
	'Retriving the UniqueTrunkGroupFriendlyName value if it is not provided in data sheet
	If strUniqueTrunkGroupFriendlyName = ""  Then
		strRetrivedText = objPage.WebEdit("txtUniqueTrunkGroupFriendlyName").GetROProperty("value")
		If  strRetrivedText <> "" Then
			Call ReportLog("UniqueTrunkGroupFriendlyName", "UniqueTrunkGroupFriendlyName should be populated","UniqueTrunkGroupFriendlyName is populated with the value - "&strRetrivedText,"PASS","")
		Else
			Call ReportLog("UniqueTrunkGroupFriendlyName","UniqueTrunkGroupFriendlyName should be populated","UniqueTrunkGroupFriendlyName not populated","FAIL","TRUE")
		End If
	End If
	
	If ((strSiteResiliency = "Yes") and (strAddMoreTrunkGroup = "Yes")) Then
	
		'Clicking on AddNewTrunkGroup Button
		blnResult = clickButton("btnAddNewTrunkGroup")
		If blnResult = False Then
			Environment.Value("Action_Result")=False 
			Call EndReport()
			Exit Function
		End If
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		' -----------------------------------------------------------Checking for Already Trunk Exist Error---------------------------------------------------------------------------------------------
		If Browser("brweDCAPortal").Page("pgeDCAPortal").WebElement("webElmTrunkExist").Exist Then 
			' ----------------------------------------Clicking On Add New Trunk Button----------------------------------------------------------------------------------
			blnResult = clickButton("btnAddNewTrunk")
			If blnResult = False Then
				Environment.Value("Action_Result")=False 
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		'Enter the UniqueTrunkGroupFriendlyName 
		If strUniqueTrunkGroupFriendlyName1 <>"" Then
			strUniqueTrunkGroupFriendlyName1 = streDCAOrderID&strUniqueTrunkGroupFriendlyName1
			blnResult = enterText("txtUniqueTrunkGroupFriendlyName",strUniqueTrunkGroupFriendlyName1)
			If blnResult = False then
				Call ReportLog("UniqueTrunkGroupFriendlyName","UniqueTrunkGroupFriendlyName should be entered","UniqueTrunkGroupFriendlyName is not eneterd","FAIL","TRUE")
				Environment.Value("Action_Result")=False 
				Call EndReport()
				Exit Function
			End If
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	
		' --------------------------------Enter the CACLimit Value-------------------------------
		blnResult = objPage.Webedit("txtTrunkGroupCACLimit").Exist
		If blnresult = "True" Then
			blnResult = enterText("txtTrunkGroupCACLimit", strTrunkGroupCACLimit1)
			If blnResult = False then
				Environment.Value("Action_Result")=False 
				Call EndReport()
				Exit Function
			End If

		End If
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'---------------------Select the TrunkGroupTrunkCallDistribution in drop down  limit  -------------------------
		blnResult = objPage.WebList("lstTrunkGroupTrunkCallDistribution").Exist
		If blnResult = "True" Then
			blnResult = selectValueFromPageList("lstTrunkGroupTrunkCallDistribution",strTrunkGroupTrunkCallDistribution)
			If blnResult= False Then
				Environment.Value("Action_Result")=False 
				Call EndReport()
				Exit Function
			End If

			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
			
		'Clicking on Save button
		blnResult = clickButton("btnTrunkGroupSave")
		If blnResult = False Then
			Environment.Value("Action_Result")=False 
			Call EndReport()
			Exit Function	
		End If

		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'Retriving the TrunkGroupCACBandwidtth Limit
		strRetrivedText = objPage.WebEdit("txtTrunkGroupCACLimit").GetROProperty("value")
		If  strRetrivedText <> "" Then
			Call ReportLog("TrunkGroupCACLimit", "TrunkGroupCACLimit should be populated","TrunkGroupCACLimit is populated with the value - "&strRetrivedText,"PASS","")
		Else
			Call ReportLog("TrunkGroupCACLimit","TrunkGroupCACLimit should be populated","TrunkGroupCACLimit not populated","FAIL","TRUE")
			Environment("Action_Result") = False : Exit Function
		End If
	
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************

