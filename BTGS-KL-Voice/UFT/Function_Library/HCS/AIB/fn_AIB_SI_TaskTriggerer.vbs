'===================================================================================================================================================================
' Description	: Function to check for the pending tasks and handle their execution in SI
' History	  	  :		Name				Date			Changes Implemented
' Created By	:  Nagaraj			03/07/2015 			NA
' Example		: fn_AIB_SI_TaskTriggerer(dAIBURL, dUserName, dPassword, dAIBSearchData, dCompletedTasks, dAccessPrimaryMainVLAN, dAccessSecondaryMainVLAN, dCommittedDateTime, dCPETemplate, dCustomerNetworkID1, dCustomerNetworkID2)
'===================================================================================================================================================================
Public Function fn_AIB_SI_TaskTriggerer(dAIBURL, dUserName, dPassword, dAIBSearchData, dCompletedTasks, dAccessPrimaryMainVLAN, dAccessSecondaryMainVLAN, dCommittedDateTime, dCPETemplate, dCustomerNetworkID1, dCustomerNetworkID2)
	Dim intCounter
	Dim dictTasks
	
	Call fn_AIB_Login(dAIBURL, dUserName, dPassword)
		If Not Environment("Action_Result") Then Exit Function

	Call fn_AIB_OrderSearch(dAIBSearchData)
		If Not Environment("Action_Result") Then Exit Function

	'Build  web reference
	blnResult = BuildWebReference("brwAIB","pgAIB","")
		If Not blnResult Then Environment.Value("Action_Result") : Exit Function

	Call fn_AIB_HandleFulfillmentOperation
	
	Set dictTasks = CreateObject("Scripting.Dictionary")
	'Run the loop for Minimum 25Mins if Tasks are not free to execute
	For intCounter = 1 To 25
			'Check and Report the Tasks that are completed and Set the For Loop Counter to "1" if the
			'Tasks completed are differing the Passed Data and Application displayed Data
			blnChange = fn_AIB_CheckCompletionTasks(dCompletedTasks)
				If blnChange Then  
					intCounter = 1
				ElseIf fn_AIB_CheckOrderCompletion Then
					Call ReportLog("Order Completion", "Order has been Completed", "Order has been completed", "PASS", True)
					Environment("Action_Result") = True : Exit Function
				End If
	
			blnExecutablesPresent = fn_AIB_GetExecutablesTasks(dictTasks, dCompletedTasks)
			'If Executables are not present then wait for 60Sec
			If Not blnExecutablesPresent Then
					Wait 60
					Call fn_AIB_OrderSearch(dAIBSearchData)
						If Not Environment("Action_Result") Then Exit Function
					Call fn_AIB_HandleFulfillmentOperation
			Else
					pORNAme = "SI"
					fLoadOR
					Call fn_AIB_SI_ExecuteTriggeredTasks(dictTasks, dAccessPrimaryMainVLAN, dAccessSecondaryMainVLAN, dCommittedDateTime, dCompletedTasks, dCPETemplate, dCustomerNetworkID1, dCustomerNetworkID2)
						If Not Environment("Action_Result") Then Exit Function
			End If
	Next
	
End Function
'=======================================================================================================================================================================================
' Description : Function to Expand the fulfillment Link tab and handle unwanted pop up
'=======================================================================================================================================================================================
Public Function fn_AIB_HandleFulfillmentOperation()
	Dim ontCounter
	For intCounter = 1 to 10
		If Not (objPage.WebTable("tblFulfilmentOrderNumber").Exist(3) And  objPage.WebTable("tblFulfilmentOrderNumber").WaitProperty("height", micGreaterThan(0), 3000)) Then

			'Click on Fulfilment orders tab
			If objPage.Link("lnkFulfilmentOrders").Exist Then
				blnResult = clickLink("lnkFulfilmentOrders")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
				objPage.Sync

				'If Uncaught Error Message Exists
				If Browser("brwAIB").Dialog("dlgMsgFromWeb").Exist(2) Then
					If Instr(Browser("brwAIB").Dialog("dlgMsgFromWeb").Static("msgText").GetVisibleText, "Uncaught") > 0 Then
						Browser("brwAIB").Dialog("dlgMsgFromWeb").WinButton("btnOK").Click
						Wait 2
					End If
				End If

			End If
		Else
			Exit For
		End If
	Next
End Function

'============================================================================================================================================================
' Description: Check if Order is Completed Or Not
'============================================================================================================================================================
Public Function fn_AIB_CheckOrderCompletion()
	With Browser("brwAIB").Page("pgAIB").WebTable("column names:=Order Number;Version;Source;Customer Name;Order Status;Order Sub-status")
		If .Exist Then
			If .GetCellData(2, 5) = "Complete" Then
				fn_AIB_CheckOrderCompletion = True
			Else
				fn_AIB_CheckOrderCompletion = False
			End If
		End If
	End With
End Function
