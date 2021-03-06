'************************************************************************************************************************************
' Function Name	 : fn_eDCA_AdditionalFeaturesDetails
' Purpose	 	 :  Collecting additional details for the order
' Author	 	 : Vamshi Krishna G
' Creation Date    : 11/06/2013
' Return values :	Nil
'**************************************************************************************************************************************	
Function fn_eDCA_AdditionalFeaturesDetails(dTypeOfOrder, deDCAOrderId, dCallBarringDetailsRequired, dOCBCategoryLabel1, dCallFeatureDetailsRequired, dIncomingAnonymousCallRejection, dIncomingCLIWithheld, dCallDivertBusy, dCallDivertBusyDestination, dCallDivertUnreachable, dCallDivertUnreachableDestination, dNumberType, dBTSupplied, dPrivateNumberMapping, dBlockStartNumber, dNumberBlockSize, dAction, dNumberTypeone, dDirectoryListingRequired, dSupplier, dSelectThirdPartyCLI, dDonatingBTProductname, dDonatingProductServiceId, dSubServiceType)
	'Declaration of variables
	On Error Resume Next
	Dim blnResult,strSupplier,strDonatingBTProductname,strDonatingProductServiceId
	Dim streDCAOrderId,strTypeOfOrder
	Dim strCallBarringDetailsRequired,strOCBCategoryLabel1,strCallFeatureDetailsRequired,strIncomingCLIWithheld,strSelectThirdPartyCLI
	Dim strCallDivertBusy,strCallDivertBusyDestination,strCallDivertUnreachable,strCallDivertUnreachableDestination,strIncomingAnonymousCallRejection
	Dim strNumberType, strBTsupplied, strPrivateNumberMapping, strBlockStartNumber, strNumberBlockSize, strTrunkGroupToBeLinked, strNumberTypeone, strAction
	
	'Assignment of variables
	streDCAOrderId = deDCAOrderId
	strCallBarringDetailsRequired = dCallBarringDetailsRequired
	strOCBCategoryLabel1 = dOCBCategoryLabel1
	strCallFeatureDetailsRequired = dCallFeatureDetailsRequired
	strIncomingCLIWithheld = dIncomingCLIWithheld
	strCallDivertBusy = dCallDivertBusy
	strCallDivertBusyDestination = dCallDivertBusyDestination
	strCallDivertUnreachable = dCallDivertUnreachable
	strCallDivertUnreachableDestination = dCallDivertUnreachableDestination
	strDirectoryListingRequired = dDirectoryListingRequired
	strIncomingAnonymousCallRejection = dIncomingAnonymousCallRejection
	strNumberType = dNumberType
	strBTsupplied = dBTsupplied
	strPrivateNumberMapping = dPrivateNumberMapping
	strBlockStartNumber = dBlockStartNumber
	strNumberBlockSize = dNumberBlockSize
	strTypeOfOrder = dTypeOfOrder
	strAction = dAction
	strNumberTypeone = dNumberTypeone
	strSupplier = dSupplier
	strSelectThirdPartyCLI = dSelectThirdPartyCLI
    	strDonatingBTProductname = dDonatingBTProductname
	strDonatingProductServiceId = dDonatingProductServiceId
	strOCBCategoryLabel1 = split(dOCBCategoryLabel1, "|")

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Capturing the only notification message populated or GVPN Bundled 
	If UCase(strTypeOfOrder) = "GVPNBUNDLEDPROVIDE" Then
		'Retriving the notification message obtained
		strRetrivedText = objPage.WebElement("webElmConfigureVLANNotification").GetROProperty("innertext")
		If strRetrivedText <>" " Then
			Call ReportLog("Additional Features Details","Additional Features Details notification message should be retrived","Notification message obtained -" & strRetrivedText, "PASS", False)
		Else
			Call ReportLog("Additional Features Details","Additional Features Details notification message should be retrived","Additional Features Details notification message not retrived", "FAIL", True)
            Environment("Action_Result") = False : Exit Function
		End If
	End If

	'Entering the particualrs if the product type is of GSIP or Ethernet
	'UCase(strTypeOfOrder) = "GSIPPROVIDE"
	
	
	If  UCase(strTypeOfOrder) = "ETHERNETPROVIDE" OR 	UCase(strTypeOfOrder) ="OB_FULLPSTN_MODIFY" or strTypeOfOrder ="P2PEtherNetProvide" OR UCase(strTypeOfOrder) ="MPLSPLUSIA" OR UCase(strTypeOfOrder) = "OVAPROVIDE" OR UCase(strTypeOfOrder) = "GSIPPROVIDE" Then
		'If Instr(UCase(strTypeOfOrder), "PROVIDE") > 0 OR UCase(strTypeOfOrder) ="OB_FULLPSTN_MODIFY" OR UCase(strTypeOfOrder) ="MPLSPLUSIA"Then

			'================== Call barring details =============
			If dSubServiceType <> "One Voice Outbound" Then '#1
					blnResult = objPage.WebList("lstCallBarringDetailsRequired").Exist(30)
					If blnResult Then
						blnResult = selectValueFromPageList("lstCallBarringDetailsRequired",strCallBarringDetailsRequired)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
	
						If strCallBarringDetailsRequired = "Yes" Then '#2
							For intCounter = LBound(strOCBCategoryLabel1) to UBound(strOCBCategoryLabel1)
								'Selecting OCB category from drop down list
								blnResult = objPage.WebList("lstOCBCategoryLabel" & (intCounter + 1)).Exist(30)
								If blnResult Then '#3
									blnResult = selectValueFromPageList("lstOCBCategoryLabel" & (intCounter + 1),strOCBCategoryLabel1(0))
										If Not blnResult Then Environment("Action_Result") = False : Exit Function
								End If '#3
							Next '#intCounter
						End If '#2
					End If
			End If '#1

			'============ Call feature details  ==============
			blnResult = objPage.WebList("lstCallFeatureDetailsRequired").Exist(30)
			If blnResult Then
				blnResult = selectValueFromPageList("lstCallFeatureDetailsRequired",strCallFeatureDetailsRequired)
					If Not blnResult Then Environment("Action_Result") = False : Exit Function
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

				If strCallFeatureDetailsRequired = "Yes" Then
						'Incoming Anonymous Call Rejection
						If dSubServiceType <> "One Voice Outbound" Then
								blnResult = objPage.WebList("lstIncomingAnonymousCallRejection").Exist(30)
								If blnResult Then
									blnResult = selectValueFromPageList("lstIncomingAnonymousCallRejection",strIncomingAnonymousCallRejection)
										If Not blnResult Then Environment("Action_Result") = False : Exit Function
								End IF
					
								'Incoming CLI With held
								blnResult = objPage.WebList("lstIncomingCLIWithheld").Exist(30)
								If blnResult = "True" Then
									blnResult  =selectValueFromPageList("lstIncomingCLIWithheld",strIncomingCLIWithheld)
										If Not blnResult Then Environment("Action_Result") = False : Exit Function
								End IF
						End if
	
						'CallDivert Busy
						blnResult = objPage.WebList("lstCallDivertBusy").Exist(30)
						If blnResult = "True" Then
							blnResult  = selectValueFromPageList("lstCallDivertBusy",strCallDivertBusy)
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						End If
	
						If strCallDivertBusy = "Yes" Then
							'CallDivert Busy Destination
							blnResult = objPage.WebEdit("txtCallDivertBusyDestination").Exist(30)
							If blnResult = "True" Then
								blnResult  =enterText("txtCallDivertBusyDestination",strCallDivertBusyDestination)
									If Not blnResult Then Environment("Action_Result") = False : Exit Function
							End IF
						End If
	
						'CallDivert Unreachable
						blnResult = objPage.WebList("lstCallDivertUnreachable").Exist(30)
						If blnResult Then
							blnResult  = selectValueFromPageList("lstCallDivertUnreachable",strCallDivertUnreachable)
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						End if 
	
						If strCallDivertUnreachable = "Yes" Then
							'CallDivert Unreachable Destination
							blnResult = objPage.WebEdit("txtCallDivertUnreachableDestination").Exist(30)
							If blnResult Then
								blnResult  = enterText("txtCallDivertUnreachableDestination",strCallDivertUnreachableDestination)
									If Not blnResult Then Environment("Action_Result") = False : Exit Function
							End IF
	
							'Directory Listing required
							If dSubServiceType <> "One Voice Outbound" Then
								blnResult  = selectValueFromPageList("lstDirectoryListingRequired",strDirectoryListingRequired)
									If Not blnResult Then Environment("Action_Result") = False : Exit Function
							End if
						End If
	
						blnResult = objPage.WebList("lstTrunkGroupToBeLinked").Exist(30)
						If blnResult Then
							strdisabled		= objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("disabled")
							If strdisabled = 0 Then
								'Select trunk group to be linked from drop down list 
								strTrunkGroupToBeLinked = objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("all items")
								arrTrunkGroupToBeLinked = Split(strTrunkGroupToBeLinked,";")
								objPage.WebList("lstTrunkGroupToBeLinked").Select arrTrunkGroupToBeLinked(0)
								Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
							End If
						End if	
				End if 'strCallFeatureDetailsRequired
			End IF

			If dTypeOfOrder = "OB_FULLPSTN_MODIFY" or dTypeOfOrder = "P2PEtherNetProvide"  Or dTypeOfOrder = "GSIPPROVIDE" OR dTypeOfOrder = "OVAPROVIDE" OR _ 
				UCase(dTypeOfOrder) = "MPLSPLUSIA" Then
					'========================================================================================================================================
					If objPage.WbfGrid("grdService").Exist(30) And dTypeOfOrder <> "GSIPPROVIDE" And dTypeOfOrder <> "OVAPROVIDE" Then 
							strRowCnt = objPage.WbfGrid("grdService").RowCount
							strCellValue = objPage.WbfGrid("grdService").GetCellData(2,12)
							strCellValueone = objPage.WbfGrid("grdService").GetCellData(2,13)
							If  strCellValue = Trim(strAction) Then
								Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"PASS","")
							Else 
								Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"FAIL","")
								Environment("Action_Result") = False : Exit Function
							End If
					
							If  strCellValueone = Trim(strNumberTypeone) Then
								Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"PASS","")
							Else 
								Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"FAIL","")
								Environment("Action_Result") = False : Exit Function
							End If
					End if
					'========================================================================================================================================
					'Clicking on Add block details button
					If dSubServiceType <> "One Voice Outbound" Then
							objPage.WebButton("btnAddBlockDetails").WaitProperty "height", micGreaterThan(0), 1000*60*2
							blnResult = clickButton("btnAddBlockDetails")
							If blnResult = False Then
								Environment.Value("Action_Result")=False
								Exit Function
							Else
								'Click on dialog that appears
								If Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Exist(5) Then
									Browser("brweDCAPortal").Window("wndDialog").Page("pgInformation").WebButton("btnOk").Click
								End If
							End if 
					
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					
							'Select Number type from drop down list
							blnResult = objPage.WebList("lstNumberType").Exist(30)
							If blnResult = "True" Then
								blnResult  = selectValueFromPageList("lstNumberType",strNumberType)
									If Not blnResult Then Environment("Action_Result") = False : Exit Function
								Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
							End If
			
							If strNumberType = "New Number" Then
									blnResult = objPage.WebList("lstBTSupplied").Exist(30)
									If blnResult = "True" Then
										'Entering if it is BT supplied
										blnResult  = selectValueFromPageList("lstBTSupplied",strBTsupplied)
											If Not blnResult Then Environment("Action_Result") = False : Exit Function
										Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
									End If
					
									'Retriving 'Action' field value
									strRetrievedText = objPage.WebList("lstAction").GetROProperty("value")
									If strRetrievedText <> "" Then
										Call ReportLog("Action","Action should be populated","Action is populated with the value - "&strRetrievedText,"PASS","")
									Else
										Call ReportLog("Action","Action should be populated","Action is not populated","FAIL","TRUE")
										Environment("Action_Result") = False : Exit Function
									End If
					
									'Retriving the supplier name
									If strBTsupplied = "Yes" Then
									strRetrievedText = objPage.WebEdit("txtSupplier").GetROProperty("value")
									If strRetrievedText <> "" Then
										Call ReportLog("Supplier","Supplier should be populated","Supplier is populated with the value - "&strRetrievedText,"PASS","")
									Else
										Call ReportLog("Supplier","Supplier should be populated","Supplier is not populated","FAIL","TRUE")
                                    					Environment("Action_Result") = False : Exit Function
									End If	
					
									strRetrievedText = objPage.WebList("lstPortInOut").GetROProperty("value")
									If strRetrievedText <> "" Then
										Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is populated with the value - "&strRetrievedText,"PASS","")
									Else
										Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is not populated","FAIL","")
										Environment("Action_Result") = False : Exit Function
									End If		
					
									blnResult = objPage.WebEdit("txtBlockStartNumber").Exist(30)
									If blnResult = "True" Then
										blnResult  = enterText("txtBlockStartNumber",strBlockStartNumber)
											If Not blnResult Then Environment("Action_Result") = False : Exit Function
									End If
					
									blnResult = objPage.WebEdit("txtNumberBlockSize").Exist(30)
									If blnResult = "True" Then
										blnResult  = enterText("txtNumberBlockSize",strNumberBlockSize)
											If Not blnResult Then Environment("Action_Result") = False : Exit Function
									End If
					
									Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTrunkGroupToBeLinked").Select "#0"
					
									If objPage.WbfGrid("grdService").Exist(30) then 
										strRowCnt = objPage.WbfGrid("grdService").RowCount
										strCellValue = objPage.WbfGrid("grdService").GetCellData(2,12)
										strCellValueone = objPage.WbfGrid("grdService").GetCellData(2,13)
										If  strCellValue = Trim(strAction) Then
											Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"PASS","")
										Else 
											Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"FAIL","")
											Environment("Action_Result") = False : Exit Function
										End If

										If  strCellValueone = Trim(strNumberTypeone) Then
											Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"PASS","")
										Else 
											Call ReportLog("Additional Features Details","Field Action should be populated","Field Action is populated with the value - "&strCellValue,"FAIL","")
											Environment("Action_Result") = False : Exit Function
										End If
									End if
							Else 'strNumberType
									Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
									blnResult = objPage.WebEdit("txtSupplier").Exist(30)
									If blnResult Then
										blnResult = enterText("txtSupplier",strSupplier)
											If Not blnResult Then Environment("Action_Result") = False : Exit Function
									End if
					
									blnResult = objPage.WebList("lstThirdPartyCLI").Exist(30)
									If blnResult Then
										blnResult = selectValueFromPageList("lstThirdPartyCLI",strSelectThirdPartyCLI)
											If Not blnResult Then Environment("Action_Result") = False : Exit Function
									End if
						
									blnResult = objPage.WebEdit("txtBlockStartNumber").Exist(30)
									If blnResult Then
										blnResult  = enterText("txtBlockStartNumber",strBlockStartNumber)
											If Not blnResult Then Environment("Action_Result") = False : Exit Function
									End If
							End if 'strNumberType
			
							blnResult = clickButton("btnSave")
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
							
							If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
								Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
								Wait 5
							End If
			
							Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					End if 'dSubServiceType
	
					If strNumberType = "Porting" Then
						blnResult = objPage.WebList("lstBTSupplied").Exist(30)
						If blnResult = "True" Then
							'Entering if it is BT supplied
							strRetrievedText  = objPage.WebList("lstBTSupplied").GetROProperty("Value")
							If strRetrievedText <> "" Then
							Call ReportLog("BTSupplied","BTSupplied should be populated","BTSupplied is populated with the value - "&strRetrievedText,"PASS","")
						Else
							Call ReportLog("Supplier","Supplier should be populated","Supplier is not populated","FAIL","TRUE")
                            			Environment("Action_Result") = False : Exit Function
						End If	
						Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					End if
				
					strRetrievedText = objPage.WebList("lstAction").GetROProperty("value")
					If strRetrievedText <> "" Then
						Call ReportLog("Action","Action should be populated","Action is populated with the value - "&strRetrievedText,"PASS","")
					Else
						Call ReportLog("Action","Action should be populated","Action is not populated","FAIL","TRUE")
						Environment("Action_Result") = False : Exit Function
					End If
				
					blnResult = objPage.WebEdit("txtSupplier").Exist(30)
					If blnResult  = "True" Then
						blnResult  =enterText("txtSupplier",strSupplier)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					End if
				
					blnResult = objPage.WebEdit("txtBlockStartNumber").Exist(30)
					If blnResult = "True" Then
						blnResult  = enterText("txtBlockStartNumber",strBlockStartNumber)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function 
					End If
				
					blnResult = objPage.WebEdit("txtNumberBlockSize").Exist(30)
					If blnResult = "True" Then
						blnResult  = enterText("txtNumberBlockSize",strNumberBlockSize)
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
					End If
				
					Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTrunkGroupToBeLinked").Select "#0"
				
					blnResult = clickButton("btnSave")
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
					
					If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
						Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
						Wait 5
					End If
			End If
			''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
				If strNumberType = "Cutover" Then
						blnResult = objPage.WebList("lstBTSupplied").Exist(30)
						If blnResult = "True" Then
								'Entering if it is BT supplied
								strRetrievedText  = objPage.WebList("lstBTSupplied").GetROProperty("Value")
								If strRetrievedText <> "" Then
									Call ReportLog("BTSupplied","BTSupplied should be populated","BTSupplied is populated with the value - "&strRetrievedText,"PASS","")
								Else
									Call ReportLog("Supplier","Supplier should be populated","Supplier is not populated","FAIL","TRUE")
									Environment("Action_Result") = False : Exit Function
								End If	
								Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						End if
			
						strRetrievedText = objPage.WebList("lstAction").GetROProperty("value")
						If strRetrievedText <> "" Then
							Call ReportLog("Action","Action should be populated","Action is populated with the value - "&strRetrievedText,"PASS","")
						Else
							Call ReportLog("Action","Action should be populated","Action is not populated","FAIL","TRUE")
							Environment("Action_Result") = False : Exit Function
						End If
			
						strRetrievedText = objPage.WebEdit("txtSupplier").GetROProperty("value")
						If strRetrievedText <> "" Then
							Call ReportLog("Supplier","Supplier should be populated","Supplier is populated with the value - "&strRetrievedText,"PASS","")
						Else
							Call ReportLog("Supplier","Supplier should be populated","Supplier is not populated","FAIL","TRUE")
							Environment("Action_Result") = False : Exit Function
						End if
			
						strRetrievedText = objPage.WebList("lstPortInOut").GetROProperty("value")
						If strRetrievedText <> "" Then
							Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is populated with the value - "&strRetrievedText,"PASS","")
						Else
							Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is not populated","FAIL","TRUE")
							Environment("Action_Result") = False : Exit Function
						End If
			
						blnResult = objPage.WebEdit("txtBlockStartNumber").Exist(30)
						If blnResult = "True" Then
							blnResult  = enterText("txtBlockStartNumber",strBlockStartNumber)
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
						End If
			
						blnResult = objPage.WebEdit("txtNumberBlockSize").Exist(30)
						If blnResult = "True" Then
							blnResult  = enterText("txtNumberBlockSize",strNumberBlockSize)
								If Not blnResult Then Environment("Action_Result") = False : Exit Function 
						End If
			
						blnResult = objPage.WebEdit("txtDonatingBTProductname").Exist(30)
						If blnResult = "True" Then
							blnResult  = enterText("txtDonatingBTProductname",strDonatingBTProductname)
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
						End If
			
						blnResult = objPage.WebEdit("txtDonatingProductServiceId").Exist(30)
						If blnResult = "True" Then
							blnResult  = enterText("txtDonatingProductServiceId",strDonatingProductServiceId)
								If Not blnResult Then Environment("Action_Result") = False : Exit Function
						End If
			
						Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTrunkGroupToBeLinked").Select "#0"
			
						blnResult = clickButton("btnSave")
							If Not blnResult Then Environment("Action_Result") = False : Exit Function
						Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
						If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
							Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
							Wait 5
						End If
				End if
			End if
		End if

		'Entering particulars for Ethernet Product
		If  UCase(strTypeOfOrder) = "ETHERNETPROVIDE" OR UCase(strTypeOfOrder) = "MPLSPLUSIA" Then
				'Selecting Private Number Mapping from drop down list
				blnResult = objPage.WebList("lstPrivateNumberMapping").Exist(0)
				If blnResult Then
					blnResult  = selectValueFromPageList("lstPrivateNumberMapping",strPrivateNumberMapping)
						If Not blnResult Then Environment("Action_Result") = False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				End IF
		End if

		Rem *--------------------------------- To Be Monitored 25-08-2016
		'Entering particulars for GSIPProduct
		'If  UCase(strTypeOfOrder) = "GSIPPROVIDE" Then 'or UCase(strTypeOfOrder) = "OVAPROVIDE" Then
		'
		'	'Retriving the port IN/OUT status
		'	strRetrievedText = objPage.WebList("lstPortInOut").GetROProperty("value")
		'	If strRetrievedText <> "" Then
		'		Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is populated with the value - "&strRetrievedText,"PASS","")
		'	Else
		'		Call ReportLog("PortInOut","PortInOut should be populated","PortInOut is not populated","FAIL","")
		'		Environment("Action_Result") = False : Exit Function
		'	End If		
		'
		'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		'
		'	'Entering Block Start Number value
		'	blnResult = objPage.WebEdit("txtBlockStartNumber").Exist(30)
		'	If blnResult = "True" Then
		'		blnResult  = enterText("txtBlockStartNumber",strBlockStartNumber)
		'			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		'	End If
		'
		'	'Entering number block size
		'	blnResult = objPage.WebEdit("txtNumberBlockSize").Exist(30)
		'	If blnResult = "True" Then
		'		blnResult  = enterText("txtNumberBlockSize",strNumberBlockSize)
		'			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		'	End If
		'
		'	blnResult = objPage.WebList("lstTrunkGroupToBeLinked").Exist(30)
		'	If blnResult = "True" Then
		'		'Select trunk group to be linked from drop down list 
		'		strTrunkGroupToBeLinked = objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("all items")
		'		arrTrunkGroupToBeLinked = Split(strTrunkGroupToBeLinked,";")
		'		objPage.WebList("lstTrunkGroupToBeLinked").Select arrTrunkGroupToBeLinked(0)
		'	End If
		'
		'	'Click on Save Button
		'	blnResult = clickButton("btnSave")
		'		If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		'	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		'	
		'	If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
		'		Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
		'		Wait 5
		'	End If
		'End If
	End if

	'If UCase(strTypeOfOrder) = "OUTBOUNDPROVIDE" or  UCase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE" Then
	If UCase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE" Then
		'Call feature details 
		blnResult = objPage.WebList("lstCallFeatureDetailsRequired").Exist(30)
		If blnResult = "True" Then
			blnResult = selectValueFromPageList("lstCallFeatureDetailsRequired",strCallFeatureDetailsRequired)
				If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If

		blnResult = objPage.WebList("lstTrunkGroupToBeLinked").Exist(30)
		If blnResult = "True" Then
			'Select trunk group to be linked from drop down list 
			strTrunkGroupToBeLinked = objPage.WebList("lstTrunkGroupToBeLinked").GetROProperty("all items")
			arrTrunkGroupToBeLinked = Split(strTrunkGroupToBeLinked,";")
			objPage.WebList("lstTrunkGroupToBeLinked").Select arrTrunkGroupToBeLinked(0)
			Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		End If
	End If

	'Nagaraj - As per swdha's requirement ===== Add Block Details =====
	If UCase(strTypeOfOrder) = "OUTBOUNDPROVIDE" Then
		objPage.WebButton("btnAddBlockDetails").WaitProperty "height", micGreaterThan(0), 1000*60*2
		'Click on Add Block Details
		blnResult = clickButton("btnAddBlockDetails")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		
		Wait 5
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Entering if it is BT supplied
		blnResult  = selectValueFromPageList("lstBTSupplied",strBTsupplied)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		'Entering Start Block Number
		blnResult  = enterText("txtBlockStartNumber",strBlockStartNumber)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync	

		'Entering Start Block Size
		blnResult  = enterText("txtNumberBlockSize",strNumberBlockSize)
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync	
	
		Browser("brweDCAPortal").Page("pgeDCAPortal").WebList("lstTrunkGroupToBeLinked").Select "#0"
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

		blnResult = clickButton("btnSave")
			If Not blnResult Then Environment.Value("Action_Result")=False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		If Browser("brweDCAPortal").Dialog("dlgMsgWebPage").Exist(5) Then
			Browser("brweDCAPortal").Dialog("dlgMsgWebPage").WinButton("btnOK").Click
			Wait 5
		End If
	End If

	Call ReportLinerMessage("<a href='" & fGetFullBrowserImage(objBrowser) & "' target='_blank'>Click here to view screenshot</a>")
	Wait 5

	'Click on Next Button
	blnResult = clickButton("btnNext")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Check if navigfated to BillingDetails page
	Set objMsg = objpage.WebElement("webElmBillingDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to Billing Details page on clicking Next Buttton","Not navigated to Billing Detailspage on clicking Next Buttton","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmBillingDetails")
		Call ReportLog("AdditionalFeaturesDetails","Should be navigated to BillingDetails page on clicking Next Buttton","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
