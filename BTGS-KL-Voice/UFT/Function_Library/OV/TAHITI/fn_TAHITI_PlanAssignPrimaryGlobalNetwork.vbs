'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_PlanAssignPrimaryGlobalNetwork
' Purpose	 	 : Function to Configure GMV task
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 18/12/2013                                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_PlanAssignPrimaryGlobalNetwork(dPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK)

	'Declaration of variables
	Dim arrPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK,arrValues
	Dim oDesc
	Dim dictAttributes, arrSplitAttr, arrAttributeValues

	'Assigning values to an array
	arrPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK = Split(dPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK,",")
	intUBound = UBound(arrPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK(intCounter),":")(1)
	Next
	
	Set dictAttributes = CreateObject("Scripting.Dictionary")
	dictAttributes.RemoveAll
	arrAttributeValues = Split(dPLAN_ASSIGN_PRIMARY_GLOBAL_NETWORK, ",")
	For Each attrValue in arrAttributeValues
		arrSplitAttr = Split(Trim(attrValue), ":")
		dictAttributes(Trim(arrSplitAttr(0))) = Trim(arrSplitAttr(1))
	Next
	
	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
	If UCase(gTrigger_rPACS_Request) = "NO" Then
		Set oDesc = Description.Create
		oDesc("micclass").Value = "WebElement"
		oDesc("class").Value = "crudmand"
		oDesc("html tag").Value = "TD"
		oDesc("innertext").Value = "Trunk IP: \(\*\) "
		
		With objFrame
			Set TrunkIP = .ChildObjects(oDesc)
			MsgBox TrunkIP.Count
			For index = 0 To TrunkIP.Count - 1
				Set edtTrunkIP = .WebEdit("xpath:=//TR[normalize-space()='" & Trim(TrunkIP(index).GetROPRoperty("innertext")) & "']/TD[2]/INPUT[1]", "index:=0")
				If edtTrunkIP.GetROPRoperty("value") = "" Then
					edtTrunkIP.Set RandomNumber(10,224) & "." & RandomNumber(10,224) & "." & RandomNumber(10,224) & "." & RandomNumber(10,224)
				End If
			Next
		End With
		
		Set oDesc = Nothing
	End If
	
	If objFrame.WebElement("innertext:=Customer Switch/Trunk:.*Add value.*", "index:=0").Exist(0) Then
		If objFrame.Link("name:=Add value", "index:=0").Exist(0) Then
			objFrame.Link("name:=Add value", "index:=0").Click
			objPage.Sync
			'Enter Switch code
			If objFrame.WebTable("innerText:=.*Customer Switch/Trunk.*", "class:=outputText", "index:=0").WebEdit("index:=0").Exist(0) then
				For intLoop = 0 to intUBound
					If arrValues(intLoop,0) = "CustomerSwitchTrunk" Then
						strData = arrValues(intLoop,1)
						objFrame.WebTable("innerText:=.*Customer Switch/Trunk.*", "class:=outputText", "index:=0").WebEdit("index:=0").Set strData
						Exit For
					End If
				Next
			End if
		End If
	End If
	
	'added in R49 by BT FTE
	'Enter Trunk White List
	If objFrame.WebEdit("txtTrunkWhiteList").Exist(0) then
		strAttributeName = "TrunkWhiteList"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtTrunkWhiteList",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if

	'Enter Switch code
	If objFrame.WebEdit("txtSwitchCode").Exist(0) then
		If objFrame.WebEdit("txtSwitchCode").GetROProperty("value") = "" Then
			strAttributeName = "SwitchCode"
			If dictAttributes.Exists(strAttributeName) Then
				blnResult = enterFrameText("txtSwitchCode",dictAttributes.Item(strAttributeName))	
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
			Else
				Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
				Environment("Action_Result") = False : Exit Function
			End If
		End If
	End if

	'Enter  IPMSServiceRefenceNumber
	If objFrame.WebEdit("txtIPMSServiceRefernceNumber").Exist(0) then
		strAttributeName = "IPMSServiceRefernceNumber"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtIPMSServiceRefernceNumber",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if

	'Enter  IPMSEnterpriseId
	If objFrame.WebEdit("txtIPMSEnterpriseId").Exist(0) then
		strAttributeName = "IPMSEnterpriseId"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtIPMSEnterpriseId",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Enter  IPMSCorporateId
	If objFrame.WebEdit("txtIPMSCorporateId").Exist(0) then
		strAttributeName = "IPMSCorporateId"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtIPMSCorporateId",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if

	'Enter  IPMSOrderNumber
	If objFrame.WebEdit("txtIPMSOrderNumber").Exist(0) then
		strAttributeName = "IPMSOrderNumber"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtIPMSOrderNumber",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if


	'====================================Adding for OVAProvide - Task Closing'====================================
	'Enter  GMV Virtual Switch Allocation: 
	If objFrame.WebEdit("txtGMVVirtualSwitchAllocation").Exist(0) then
		strAttributeName = "GMVVirtualSwitchAllocation"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtGMVVirtualSwitchAllocation",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if
	
	'Enter OVA Trunk (Ribbit side): 
	If objFrame.WebEdit("txtOVATrunkRibbitSide").Exist(0) then
		strAttributeName = "OVATrunkRibbitSide"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtOVATrunkRibbitSide",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if
	
	'Enter OVA Trunk (CCC/Infrastructure side): 
	If objFrame.WebEdit("txtOVATrunkCCCorInfrastructureSide").Exist(0) then		
		strAttributeName = "OVATrunkCCCorInfrastructureSide"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtOVATrunkCCCorInfrastructureSide",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if

	'Enter OVA Client Registration (Ribbit side): 
	If objFrame.WebEdit("txtOVAClientRegnRibbitSide").Exist(0) then
		strAttributeName = "OVAClientRegnRibbitSide"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtOVAClientRegnRibbitSide",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if

	'Enter OVA Client Registration (Customer VPN)
	If objFrame.WebEdit("txtOVAClientRegnCustomerVPN").Exist(0) then
		strAttributeName = "OVAClientRegnCustomerVPN"
		If dictAttributes.Exists(strAttributeName) Then
			blnResult = enterFrameText("txtOVAClientRegnCustomerVPN",dictAttributes.Item(strAttributeName))	
				If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Else
			Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
			Environment("Action_Result") = False : Exit Function
		End If
	End if
'====================================Adding for OVAProvide - Task Closing'====================================

'====================================Adding for Closure of MPLS Task'====================================
			'Enter BT MPLS No Of BGP Sessions
'			If objFrame.WebList("lstBTMPLSNoOfBGPSessions").Exist(0) then
'
'				 wait 3
'				For i = 1 to 5
'					objFrame.WebList("lstBTMPLSNoOfBGPSessions").Click
'					objPage.Sync
'					strListValues = objFrame.WebList("lstBTMPLSNoOfBGPSessions").GetROProperty("all items")
'					arrListValues = Split(strListValues,";")
'					If UBound(arrListValues) >= 1 Then
'						Wait 5
'						Exit For
'					Else 
'						Wait 3
'					End If
'				Next		
'		
'				For intLoop = 0 to intUBound
'					If arrValues(intLoop,0) = "BTMPLSNoOfBGPSessions" Then
'						strData = arrValues(intLoop,1)
'						Exit For
'					End If
'				Next
'
'				blnResult = selectValueFromList("lstBTMPLSNoOfBGPSessions",strData)
'				If blnResult= False Then
'					Environment.Value("Action_Result")=False 
'					
'					Exit Function
'				End If
'			End if

			'Enter Node Id
'			If objFrame.WebEdit("txtNodeId").Exist(0) then
'				'Capture value of GPOP Node ID
'				If objFrame.WebList("lstMandatoryFilter").Exist(0) Then
'					blnResult = selectValueFromList("lstMandatoryFilter","All updatable fields")
'					If blnResult= False Then
'						Environment.Value("Action_Result")=False 
'						
'						Exit Function
'					End If
'				End If
'				objPage.Sync
'
'				If objFrame.WebEdit("txtGPOPNodeId").Exist Then
'					strGPOPNodeId = objFrame.webEdit("txtGPOPNodeId").GetROProperty("value")
'				End If
'
'				If objFrame.WebList("lstMandatoryFilter").Exist Then
'					blnResult = selectValueFromList("lstMandatoryFilter","Mandatory fields only")
'					If blnResult= False Then
'						Environment.Value("Action_Result")=False 
'						
'						Exit Function
'					End If
'				End If
'
'				For intLoop = 0 to intUBound
'					If arrValues(intLoop,0) = "NodeId" Then
'						strData = arrValues(intLoop,1)
'						Exit For
'					End If
'				Next
'
'				'For Node Id
'				strData = strData&"-"&strGPOPNodeId
'				blnResult = enterFrameText("txtNodeId",strData)
'				If blnResult= False Then
'					Environment.Value("Action_Result")=False 
'					
'					Exit Function
'				End If
'			End if

			blnPopulated = False

			'Enter Interface Descriptor
			If objFrame.WebEdit("txtInterfaceDescriptor").Exist(0) then
				If objFrame.WebEdit("txtInterfaceDescriptor").GetROProperty("value") = "" Then
					strAttributeName = "InterfaceDescriptor"
					If dictAttributes.Exists(strAttributeName) Then
						blnResult = enterFrameText("txtInterfaceDescriptor",dictAttributes.Item(strAttributeName))	
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
						Environment("Action_Result") = False : Exit Function
					End If
				Else
					blnPopulated = True
				End If
			End if

			'Enter Node ID
			If objFrame.WebEdit("txtNodeId").Exist(0) then
				If objFrame.WebEdit("txtNodeId").GetROProperty("value") = "" Then				
					strAttributeName = "NodeId"
					If dictAttributes.Exists(strAttributeName) Then
						blnResult = enterFrameText("txtNodeId",dictAttributes.Item(strAttributeName))	
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Else
						Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
						Environment("Action_Result") = False : Exit Function
					End If
				End If
			End if
			
			If Not blnPopulated Then '#Outer1
				'Trial for Ethernet Orders
				Set objEthernetServiceDescriptor = objFrame.WebTable("text:=.*Interface Descriptor.*", "class:=outputText","index:=0")
				If objEthernetServiceDescriptor.Exist(10) Then '#1
						With objEthernetServiceDescriptor
			
							'----------------------------------- Slot No -------------------------------------------
							strAttributeName = "SlotNo"
							If Not dictAttributes.Exists(strAttributeName) Then
								Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
								Environment("Action_Result") = False : Exit Function
							End If
							
							strCellValue = "Slot No.: (*)"
							iRow = .GetRowWithCellText(strCellValue)
							Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
							If iRow >=1 Then
								blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, dictAttributes.Item(strAttributeName))
									If Not blnResult Then 
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is not getting selected", "FAIL", True)
										Environment("Action_Result") = False : Exit Function
									Else
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is selected", "PASS", False)
									End If
							End If
							'----------------------------------- Card No -------------------------------------------
							strAttributeName = "CardNo"
							If Not dictAttributes.Exists(strAttributeName) Then
								Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
								Environment("Action_Result") = False : Exit Function
							End If
							
							strCellValue = "Card No.: (*)"
							iRow = .GetRowWithCellText(strCellValue)
							Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
							If iRow >=1 Then
								blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, dictAttributes.Item(strAttributeName))
									If Not blnResult Then 
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is not getting selected", "FAIL", True)
										Environment("Action_Result") = False : Exit Function
									Else
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is selected", "PASS", False)
									End If
							End If
							'----------------------------------- Port No -------------------------------------------
							strAttributeName = "PortNo"
							If Not dictAttributes.Exists(strAttributeName) Then
								Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
								Environment("Action_Result") = False : Exit Function
							End If
							
							strCellValue = "Port No: (*)"
							iRow = .GetRowWithCellText(strCellValue)
							Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
							If iRow >=1 Then
								blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, dictAttributes.Item(strAttributeName))
									If Not blnResult Then 
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is not getting selected", "FAIL", True)
										Environment("Action_Result") = False : Exit Function
									Else
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is selected", "PASS", False)
									End If
							End If
	
							'----------------------------------- Speed (Full port speed) -------------------------------------------
							strAttributeName = "FullPortSpeed"
							If Not dictAttributes.Exists(strAttributeName) Then
								Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
								Environment("Action_Result") = False : Exit Function
							End If
							
							strCellValue = "Speed (Full port speed): (*)"
							iRow = .GetRowWithCellText(strCellValue)
							Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
							If iRow >=1 Then
								blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, dictAttributes.Item(strAttributeName))
									If Not blnResult Then 
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is not getting selected", "FAIL", True)
										Environment("Action_Result") = False : Exit Function
									Else
										Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is selected", "PASS", False)
									End If
							End If
						End With '#objEthernetServiceDescriptor
	
						'Check for Trunk Group OSS ID
						Set objWebEdit = objFrame.WebEdit("xpath:=//TR[normalize-space()='Trunk Group OSS Id: (*)']/TD[2]/INPUT[1]", "index:=0")
						If objWebEdit.Exist(0) Then
							strRetrievedText = objWebEdit.GetROProperty("value")
							If strRetrievedText <> "" Then
								Call ReportLog("Check Trunk Group OSS Id", "Trunk Group OSS Id should be populated", "Trunk Group OSS Id is populated with:= " & strRetrievedText, "Information", False)
							Else
								Call ReportLog("Check Trunk Group OSS Id", "Trunk Group OSS Id should be populated", "Trunk Group OSS Id is blank", "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							End If
						End If
		
						'Check for Trunk OSS ID
						Set objWebEdit = objFrame.WebEdit("xpath:=//TR[normalize-space()='Trunk OSS Id: (*)']/TD[2]/INPUT[1]", "index:=0")
						If objWebEdit.Exist(0) Then
							strRetrievedText = objWebEdit.GetROProperty("value")
							If strRetrievedText <> "" Then
								Call ReportLog("Check Trunk OSS Id", "Trunk OSS Id should be populated", "Trunk OSS Id is populated with:= " & strRetrievedText, "Information", False)
							Else
								Call ReportLog("Check Trunk OSS Id", "Trunk OSS Id should be populated", "Trunk OSS Id is blank", "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							End If
						End If
		
						'Check for Trunk IP
						Set objWebEdit = objFrame.WebEdit("xpath:=//TR[normalize-space()='Trunk IP: (*)']/TD[2]/INPUT[1]", "index:=0")
						If objWebEdit.Exist(0) Then
							strRetrievedText = objWebEdit.GetROProperty("value")
							If strRetrievedText <> "" Then
								Call ReportLog("Check Trunk IP", "Trunk IP should be populated", "Trunk IP is populated with:= " & strRetrievedText, "Information", False)
							Else
								Call ReportLog("Check Trunk IP", "Trunk IP should be populated", "Trunk IP is blank", "FAIL", True)
								Environment("Action_Result") = False : Exit Function
							End If
						End If
				End If	'#1
			End If '#Outer1
			
			'Trial for Ethernet Orders
			Set objEthernetServiceDescriptor = objFrame.WebTable("text:=.*Interface Descriptor.*", "class:=outputText","index:=1")
			If objEthernetServiceDescriptor.Exist(10) Then '#2
					With objEthernetServiceDescriptor
					
						'----------------------------------- Interface Descriptor -------------------------------------------
						strAttributeName = "InterfaceDescriptor"
						If Not dictAttributes.Exists(strAttributeName) Then
							Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
							Environment("Action_Result") = False : Exit Function
						End If
						
						strCellValue = "Interface Descriptor: (*)"
						iRow = .GetRowWithCellText(strCellValue)
						Set objChildItem = .ChildItem(iRow, 2, "WebEdit", 0)
						If iRow >=1 Then
							blnResult = fn_TAHITI_EnterValueToObject(objChildItem, dictAttributes.Item(strAttributeName))
								If Not blnResult Then 
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be Entered", "value is not entered", "FAIL", True)
									Environment("Action_Result") = False : Exit Function
								Else
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be Entered", "value is entered", "PASS", False)
								End If
						End If
						
						'----------------------------------- Node Id -------------------------------------------
						strAttributeName = "NodeId"
						If Not dictAttributes.Exists(strAttributeName) Then
							Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
							Environment("Action_Result") = False : Exit Function
						End If
						
						strCellValue = "Node Id: (*)"
						iRow = .GetRowWithCellText(strCellValue)
						Set objChildItem = .ChildItem(iRow, 2, "WebEdit", 0)
						If iRow >=1 Then
							blnResult = fn_TAHITI_EnterValueToObject(objChildItem, dictAttributes.Item(strAttributeName))
								If Not blnResult Then 
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be Entered", "value is not entered", "FAIL", True)
									Environment("Action_Result") = False : Exit Function
								Else
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be Entered", "value is entered", "PASS", False)
								End If
						End If
		
						'----------------------------------- Slot No -------------------------------------------
						strAttributeName = "SlotNo"
						If Not dictAttributes.Exists(strAttributeName) Then
							Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
							Environment("Action_Result") = False : Exit Function
						End If
						
						strCellValue = "Slot No.: (*)"
						iRow = .GetRowWithCellText(strCellValue)
						Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
						If iRow >=1 Then
							blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, dictAttributes.Item(strAttributeName))
								If Not blnResult Then 
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is not getting selected", "FAIL", True)
									Environment("Action_Result") = False : Exit Function
								Else
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is selected", "PASS", False)
								End If
						End If
						'----------------------------------- Card No -------------------------------------------
						strAttributeName = "CardNo"
						If Not dictAttributes.Exists(strAttributeName) Then
							Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
							Environment("Action_Result") = False : Exit Function
						End If
						
						strCellValue = "Card No.: (*)"
						iRow = .GetRowWithCellText(strCellValue)
						Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
						If iRow >=1 Then
							blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, dictAttributes.Item(strAttributeName))
								If Not blnResult Then 
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is not getting selected", "FAIL", True)
									Environment("Action_Result") = False : Exit Function
								Else
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is selected", "PASS", False)
								End If
						End If
						'----------------------------------- Port No -------------------------------------------
						strAttributeName = "PortNo"
						If Not dictAttributes.Exists(strAttributeName) Then
							Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
							Environment("Action_Result") = False : Exit Function
						End If
						
						strCellValue = "Port No: (*)"
						iRow = .GetRowWithCellText(strCellValue)
						Set objChildItem = .ChildItem(iRow, 2, "WebList", 0)
						If iRow >=1 Then
							blnResult = fn_TAHITI_SelectValueFromObject(objChildItem, dictAttributes.Item(strAttributeName))
								If Not blnResult Then 
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is not getting selected", "FAIL", True)
									Environment("Action_Result") = False : Exit Function
								Else
									Call ReportLog(strCellValue, dictAttributes.Item(strAttributeName) & " value should be selected", "value is selected", "PASS", False)
								End If
						End If
					End With '#objEthernetServiceDescriptor
			End If	'#2
			
			'Enter Managed Device Name
			If objFrame.WebEdit("txtManagedDeviceName").Exist(5) Then				
				strAttributeName = "ManagedDeviceName"
				If dictAttributes.Exists(strAttributeName) Then
					blnResult = enterFrameText("txtManagedDeviceName",dictAttributes.Item(strAttributeName))	
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Else
					Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
			End If

			'Enter Management Loopback IP Address
			If objFrame.WebEdit("txtManagementLoopbackIPAddress").Exist(5) Then
				strAttributeName = "ManagementLoopbackIPAddress"
				If dictAttributes.Exists(strAttributeName) Then
					blnResult = enterFrameText("txtManagementLoopbackIPAddress",dictAttributes.Item(strAttributeName))	
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Else
					Call ReportLog(strAttributeName, strAttributeName & " - Attribute Name and Value should exist in DataSheet", strAttributeName & " - Attribute Name and Value doesn't exist in DataSheet", "FAIL", False)
					Environment("Action_Result") = False : Exit Function
				End If
			End If


'			'Enter Channelised
'			If objFrame.WebList("lstChannelised").Exist(0) then
'
'				wait 3
'				For i = 1 to 5
'					objFrame.WebList("lstChannelised").Click
'					objPage.Sync
'					strListValues = objFrame.WebList("lstChannelised").GetROProperty("all items")
'					arrListValues = Split(strListValues,";")
'					If UBound(arrListValues) >= 1 Then
'						Wait 5
'						Exit For
'					Else 
'						Wait 3
'					End If
'				Next
'
'				For intLoop = 0 to intUBound
'					If arrValues(intLoop,0) = "Channelised" Then
'						strData = arrValues(intLoop,1)
'						Exit For
'					End If
'				Next
'
'				blnResult = selectValueFromList("lstChannelised",strData)
'				If blnResult= False Then
'					Environment.Value("Action_Result")=False 
'					
'					Exit Function
'				End If
'			End if

			'Enter PE Router Type
'			If objFrame.WebList("lstPERouterType").Exist(0) then
'
'				wait 3
'				For i = 1 to 5
'					objFrame.WebList("lstPERouterType").Click
'					objPage.Sync
'					strListValues = objFrame.WebList("lstPERouterType").GetROProperty("all items")
'					arrListValues = Split(strListValues,";")
'					If UBound(arrListValues) >= 1 Then
'						Wait 5
'						Exit For
'					Else 
'						Wait 3
'					End If
'				Next
'
'				For intLoop = 0 to intUBound
'					If arrValues(intLoop,0) = "PERouterType" Then
'						strData = arrValues(intLoop,1)
'						Exit For
'					End If
'				Next
'
'				blnResult = selectValueFromList("lstPERouterType",strData)
'				If blnResult= False Then
'					Environment.Value("Action_Result")=False 
'					
'					Exit Function
'				End If
'			End if

			'Enter Port HW Type
'			If objFrame.WebList("lstPortHWType").Exist(0) then
'				wait 3
'				For i = 1 to 5
'					objFrame.WebList("lstPortHWType").Click
'					objPage.Sync
'					strListValues = objFrame.WebList("lstPortHWType").GetROProperty("all items")
'					arrListValues = Split(strListValues,";")
'					If UBound(arrListValues) >= 1 Then
'						Wait 5
'						Exit For
'					Else 
'						Wait 3
'					End If
'				Next
'
'				For intLoop = 0 to intUBound
'					If arrValues(intLoop,0) = "PortHWType" Then
'						strData = arrValues(intLoop,1)
'						Exit For
'					End If
'				Next
'
'				blnResult = selectValueFromList("lstPortHWType",strData)
'				If blnResult= False Then
'					Environment.Value("Action_Result")=False 
'					
'					Exit Function
'				End If
'			End if
'====================================Adding for Closure of MPLS Task'====================================
	If Trim(UCase(gTrigger_rPACS_Request)) = "YES" Then
		strTaskName = objPage.Frame("frmContent").WebElement("elmTaskDetails").GetROProperty("innertext")
		If Instr(strTaskName, "Plan & Assign Primary Global Network Resource (Change)") > 0  Then
				blnResult = clickFrameButton("btnSave")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function

				Wait 30
				
				If Not objFrame.WebButton("btnUpdaterPACS").Exist(10) Then Exit Function
				
				blnResult = clickFrameButton("btnUpdaterPACS")
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
				Wait 20
	
				strInnerText = objPage.Frame("frmContent").Object.documentElement.innertext
				If Instr(strInnerText, "Request has been send successfully to rPACS") > 0 Then
					Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has been send successfully to rPACS", "PASS", True)
				Else
					Call ReportLog("Update rPACS", "Request has to be sent successfully to rPACS", "Request has not been send successfully to rPACS", "FAIL", True)
					Environment("Action_Result") = False : Exit FUnction
				End If
	
				Message = "Successful Response Received from rPACS for Plan & Assign Primary Global Network Resource"
				blnVerification = False
				For intCounter = 1 To 10
					strText = objPage.Frame("name:=notesFrame").Object.documentElement.innerText
					strInnerHTML = objPage.Frame("name:=notesFrame").Object.documentElement.innerHtml
					If Instr(strText, Message) > 0 Then
						Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message exists</BR>" & strInnerHTML, "PASS", True)
						blnVerification = True
						Environment("Action_Result") = True : Exit Function
					Else
						Wait 30
						objPage.Link("name:=All", "index:=0").Click
						Wait 5
					End If
				Next
			
				If Not blnVerification Then
					Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message doesnt exist</BR>" & strInnerHTML, "FAIL", True)
					Environment("Action_Result") = False : Exit Function
				End If

		ElseIf Instr(strTaskName, "Plan & Assign Primary Global Network Resource (Provide)") Then
				
				Message1 = "Successful Response Received from rPACS for Plan & Assign Primary Global Network Resource"
				Message2 = "Successful Response Received from rPACS for Automatic Port Allocation"
				strText = objPage.Frame("name:=notesFrame").Object.documentElement.innerText
				strInnerHTML = objPage.Frame("name:=notesFrame").Object.documentElement.innerHtml
				If Instr(strText, Message1) > 0 Then
					Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message1 & "</B> message exists</BR>" & strInnerHTML, "PASS", True)
				ElseIf Instr(strText, Message2) > 0 Then
					Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message2 & "</B> message exists</BR>" & strInnerHTML, "PASS", True)
				ElseIf objFrame.WebButton("name:=Port Allocation", "index:=0").Exist(0) AND objFrame.WebButton("name:=Port Allocation", "index:=0").WaitProperty("disabled", 0, 1000) Then
					Call ReportLog("Task End", "Port Allocation Button is visble", "Ending the Task", "Information", True)
				Else
					Call ReportLog("Success Verification", Message & " should exist", "<B>" & Message & "</B> message exists</BR>" & strInnerHTML, "FAIL", True)
					Call fCreateAndSendMail(Environment("ToList"), Environment("CcList"), Environment("BCcList"), strTaskName & " - Failure", strInnerHTML, "")
					Environment("Action_Result") = False : Exit Function
				End If
		End If
	End If

	Environment("Action_Result") = True
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
