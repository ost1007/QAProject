'****************************************************************************************************************************
' Function Name		   	: 			fn_AIB_CheckTaskClosureByTaskID
' Purpose					: 			Function to check closure status of tasks in AIB
' Author					:		  	Linta CK
' Creation Date   		: 			18/06/2014
' Modified by			  : 		Nagaraj V || 03/02/2015
' Parameters	 		 :			dAIBURL,dAIBSearchData,dTaskName
' Return Values	 		: 			Not Applicable
'****************************************************************************************************************************
Public function fn_AIB_CheckTaskClosureByTaskID(dAIBURL ,dUserName, dPassword, dAIBSearchData, dTaskID, dExpectedStatus)
		On Error Resume Next
		Dim StrColumnName,strColumnValue,strTaskName,strAIBURL,strAIBSearchData
		Dim blnSendMail
	
		'Assigning Variables
		strTaskID = dTaskID
		strAIBURL = dAIBURL
		strAIBSearchData = dAIBSearchData
		strExpectedStatus = dExpectedStatus

'		SystemUtil.CloseProcessByName "iexplore.exe"

		If Browser("brwAIB").Exist(2) Then
			'Browser("brwAIB").Close
			If Browser("brwAIB").Page("pgAIB").WebElement("elmExpand").Exist(2) Then
				Browser("brwAIB").Page("pgAIB").WebElement("elmExpand").Click
			End If

			'Page synchronize
			For intCounter = 1 to 40
				Set objMsg = Browser("brwAIB").Page("pgAIB").WebElement("ElmOrderSearch") 'Check if Order Search Element is populated or not
				If objMsg.Exist And  CInt(objMsg.GetROProperty("height")) > 0 Then
					Exit For
				Else
					Wait 2
				End If
			Next
		Else
			Call fn_AIB_Login(dAIBURL, dUserName, dPassword)
		End If

		Call fn_AIB_OrderSearch(dAIBSearchData)

		'Build  web reference
		If Browser("brwAIB").Page("pgAIB").Exist Then
			blnResult = BuildWebReference("brwAIB","pgAIB","")
			If Not blnResult Then
				Environment.Value("Action_Result") = False
				Exit Function
			End If	
		End If

		For intCounter = 1 to 10
			If Not (objPage.WebTable("tblFulfilmentOrderNumber").Exist(3) And  objPage.WebTable("tblFulfilmentOrderNumber").WaitProperty("height", micGreaterThan(0), 3000)) Then

				'Click on Fulfilment orders tab
				If objPage.Link("lnkFulfilmentOrders").Exist Then
					blnResult = clickLink("lnkFulfilmentOrders")
						If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
						objPage.Sync

					'If Uncaught Error Message Exists
					If Browser("brwAIB").Dialog("dlgMsgFromWeb").Exist(2) Then
						If Instr(Browser("brwAIB").Dialog("dlgMsgFromWeb").Static("msgText").GetVisibleText, "Uncaught Error") > 0 Then
							Browser("brwAIB").Dialog("dlgMsgFromWeb").WinButton("btnOK").Click
							Wait 2
						End If
					End If

				End If
			Else
				Exit For
			End If
		Next

		If objPage.WebTable("tblFulfilmentOrderNumber").Exist Then
			'Set main Order table under Fulfilment Tab
			Set objTable = objPage.WebTable("tblFulfilmentOrderNumber")
			intRowCount = objTable.GetROProperty("rows")
			For intRow = 2 to intRowCount
				strRetrievedText = objTable.GetCellData(intRow,2)
				If Trim(UCase(strRetrievedText)) = Trim(UCase(strTaskName)) Then
					Exit For
				End If
			Next
		Else
			Call ReportLog("WebTable - Fulfilment Orders","Table should be visible","Table is not populated", "FAIL", True)
			Environment("Action_Result") = False
			Exit Function
		End If

		blnSendMail = False
		'Call function to check Status ==== Returns False If Status is not achieved
		If fn_AIB_CheckCompletionStatus(intRow,objTable,strExpectedStatus,strOrderNumber) Then
            
			'To Capture And Click Order Item number
			If objPage.WebTable("tblFulfilmentOrderNumber").Exist Then
				Set objTable = objPage.WebTable("tblFulfilmentOrderNumber")								
			End If			
			Call fn_AIB_CaptureAndClickOrderItemNumber(objTable,strOrderNumber,MainOrderItemTable,objOrderItemNumber)
	
			'To capture and click on Product link
			dataTableIndex=MainOrderItemTable+1
			Call fn_AIB_CaptureAndClickProductLink(dataTableIndex,strTaskName,objProduct)
				
			dataTableIndex=dataTableIndex+1
			If objPage.WebTable("index:=" & dataTableIndex).Exist Then
				Set objTable = objPage.WebTable("index:=" & dataTableIndex)
			End If
	
			'Call function to capture Instance characteristics
			Call fn_AIB_CaptureInstanceCharacteristics(objTable)
	
			If objProduct(0).Exist Then
				objProduct(0).Click
				Wait 3
			End If
	
			If objOrderItemNumber(0).exist Then
				objOrderItemNumber(0).Click
				Wait 3		
			End If
	Else
		blnSendMail = True
	End If

	Select Case(strTaskName)
		Case "rPACS OSCS Cust Node", "rPACS NWInterconnection", "rPACS GVA IPC VLAN", "rPACS SIPT DNIS"

			'Call function to validate if Service ID is populated in Customer Details tab
			Call fn_AIB_CheckMainOrderServiceIDinCustomerDetails(strTaskName)
			If blnSendMail Then
				Call fCreateAndSendMail(Environment("ToList"), Environment("CcList"), Environment("BCcList"), "Manual Intervention Required for " & dAIBSearchData & " - " & strTaskName,_
					 "Please close the task <B>" & strTaskName &  " </B>manually in rPACS and re-run the script", "")
				Environment("Action_Result") = False
				Exit Function
			End If
			
		Case "SM OSCS Customer"
				
		Case "SBC NWInterconnection"

		Case "rPACS Trunk Group"
                              
			'To check if Service ID is populated
			Call fn_AIB_CheckOrderItemServiceIDinCustomerDetails(strTaskName,"Trunk Group")			

		Case "SM Trunk Group"
                              
		Case "rPACS Trunk"
			
		Case "SM Trunk"
                              
		Case "SBC Trunk"
                              
		Case "rPACS Destination Number"
                              
		Case "SM Destination Number"
                              
		Case "SIP Trunking Number Portability"
                              
		Case "SM Destination Number Active"
                    
		Case "Billing OSCS Customer"
                              
		Case "SIPT Directory Entry"
		
		End Select

		NumberOfProducts = 0
		intColsInstanceCharacteristics = 0
		intRowsInstanceCharacteristics = 0	

'		If Browser("brwAIB").Exist(2)Then
'			Browser("brwAIB").Close
'		End If
End Function
