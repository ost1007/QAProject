
'****************************************************************************************************************************
' Function Name	 : fn_AIB_AllTaskCompletionCheck
'
' Purpose	 	 : Function to search completion status of order in AIB
'
' Author	 	 : Linta
'
' Creation Date  : 01/7/2014
'
' Modified By	 : Nagaraj V || 03/02/2015
'
' Parameters	 :dAIBURL,dAIBSearchData
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

	Public Function fn_AIB_AllTaskCompletionCheck(dAIBURL, dUserName, dPassword, dAIBSearchData)

		'Declarationof variables
		Dim strAIBURL,strAIBSearchData

		'Assigning variables
		strAIBURL = dAIBURL
		strAIBSearchData = dAIBSearchData

		blnResult = Browser("brwAIB").Exist(20)
          	If not blnResult Then
			Call fn_AIB_Login(dAIBURL, dUserName, dPassword)
			Call fn_AIB_OrderSearch(dAIBSearchData)
		End If

		'Build  web reference
		If Browser("brwAIB").Page("pgAIB").Exist Then
			blnResult = BuildWebReference("brwAIB","pgAIB","")
			If Not blnResult Then
				Environment.Value("Action_Result") = False  
				Call EndReport()
				Exit Function
			End If	
		End If
                    Wait 3
          	'Click on Fulfilment orders tab
		If objPage.Link("lnkFulfilmentOrders").Exist Then
                    	blnResult = clickLink("lnkFulfilmentOrders")
			If blnResult = "False" Then
				Environment.Value("Action_Result") = False  
				Call EndReport()
				Exit Function
			End If
			objPage.Sync
		End If
		Wait 6

		If objPage.WebTable("tblFulfilmentOrderNumber").Exist Then
			'Set main Order table under Fulfilment Tab
			Set objTable = objPage.WebTable("tblFulfilmentOrderNumber")
                              intRowCount = objTable.GetROProperty("rows")
			For intRow = 2 to intRowCount
				Call fn_AIB_CheckCompletionStatus(intRow,objTable,strOrderNumber)
			Next
		End If

	End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************