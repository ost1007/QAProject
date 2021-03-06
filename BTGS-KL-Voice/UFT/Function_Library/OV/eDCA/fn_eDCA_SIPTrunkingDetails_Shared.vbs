Public function fn_eDCA_SIPTrunkingDetails_Shared(ByVal Codec, ByVal TrunkGroupCACLimit, ByVal TrunkGroupBandwidthCACLimit)

	'Variable Declaration
	Dim objMPLSVPNName, objElmError, objExistingTrunkTable
	Dim strMPLSVPNName

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Selecting Codec from drop drown list
	blnResult = objPage.WebList("lstCodec").Exist
	If blnResult Then
		blnResult = selectValueFromPageList("lstCodec", Codec)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End If
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Checl whether MPLS VPN Name is populated or not
	Set objMPLSVPNName = objPage.WebEdit("name:=.*txtMplsVpnName")
	strMPLSVPNName = objMPLSVPNName.GetROProperty("value")
	If strMPLSVPNName = "" Then
		Call ReportLog("MPLS VPN Name", "MPLS VPN Name should be populated", "MPLS VPN Name is not populated", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("MPLS VPN Name", "MPLS VPN Name should be populated", "MPLS VPN Name is found to be <B>" & strMPLSVPNName & "</B>", "PASS", True)
	End If

	'Click on Add New Trunk Group
	blnResult = clickButton("btnAddNewTrunkGroup")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Wait 30
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check for Error Response
	Set objElmError = objPage.WebElement("class:=form_error_font","innertext:=.*Please try after some time.*", "visible:=True")
	For intCounter = 1 To 15
		blnErrorExist = objElmError.Exist(10)
		If Not blnErrorExist Then
			Exit For '#intCounter
		
		ElseIf objPage.WebTable("html id:=.*dgExistingTrunk.*", "index:=0").Exist(10) Then
			blnErrorExist = False
			Exit For
		Else
			Wait 30
			objPage.WebButton("btnAddNewTrunkGroup").Click
			Wait 5
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	Next '#intCounter
	
	If blnErrorExist Then
		Call ReportLog("Error Response", "Reponse should be received for Add Trunk Group within 6 try", "Response received was <B>" & objElmError.GetROProperty("innertext") & "</B", "FAIL", True)
		Environment("Action_Result") = False : Exit Function
	End If

	'Add all the existing Trunks
	Set objExistingTrunkTable = objPage.WebTable("html id:=.*dgExistingTrunk.*", "index:=0")
	With objExistingTrunkTable
		If Not .Exist(10) Then
			Call ReportLog("Existing Trunk", "ExistingTrunk Table should be displayed", "ExistingTrunk is either not displayed or properties have changed", "FAIL", True)
			Environment("Action_Result") = False : Exit Function
		End If
		intRows = .RowCount
		For iRow = 2 To intRows - 1
			.ChildItem(iRow, 1, "WebCheckBox", 0).Set "ON"
			Wait 2
		Next
	End With
    
	'Click on Add Exiting Trunk
	blnResult = clickButton("btnAddExistingTrunk")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Add all the existing Trunks
	Set objTblModify = objPage.WbfGrid("html id:=UsrOneVoiceSIPTrunkingDetails_dgTrunkGrp")
	With objTblModify
		intRows = .RowCount
		'iOddNumber = 0
		For iRow = 2 To intRows
			.RefreshObject : Wait 2
			.ChildItem(iRow, 1, "WebButton", 0).Click
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			If objPage.WebEdit("txtTrunkGroupCACLimit").Exist(5) Then
				If Not objPage.WebEdit("txtTrunkGroupCACLimit").object.disabled Then
					objPage.WebEdit("txtTrunkGroupCACLimit").Set TrunkGroupCACLimit	
					Wait 1: Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End If	
			End If
			
			If objPage.WebEdit("txtRevisedTrunkGroupCACLimit").Exist(5) Then
				objPage.WebEdit("txtRevisedTrunkGroupCACLimit").Set TrunkGroupBandwidthCACLimit
				Wait 1: Browser("brweDCAPortal").Page("pgeDCAPortal").Sync	
			End If
			objPage.WebButton("btnSave").Click
			Wait 1: Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			'iOddNumber = iOddNumber + 2
		Next
	End With
    
	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	
	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
	'Workaround if Page doesn't Navigate to Next Page
	If Not objpage.Webelement("webElmAdditionalFeaturesDetails").Exist(10) Then
		objPage.WbfTreeView("html id:=TreeView1").Link("text:=Additional Features Details ").Click
		Wait 5 : Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		objPage.WbfTreeView("html id:=TreeView1").Link("text:=SIP Trunking Details ").Click
		Wait 5 : Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		'Click on Next Button
		blnResult = clickButton("btnNext")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync		
	End If

	'Check if navigated to additional features details page 
	Set objMsg = objpage.Webelement("webElmAdditionalFeaturesDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Not navigated to AdditionalFeaturesDetails page on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False
	Else
		strMessage = GetWebElementText("webElmAdditionalFeaturesDetails")
		Call ReportLog("SIPTrunkingDetails","Should be navigated to AdditionalFeaturesDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
		Environment("Action_Result") = True
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
