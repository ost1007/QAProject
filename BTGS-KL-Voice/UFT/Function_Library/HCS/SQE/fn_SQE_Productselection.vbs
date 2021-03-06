'**	**************************************************************************************************************************
' Function Name 		:		fn_Expedio_SignOfOrder_ModifySoftChanges
'
' Purpose				: 		Function to Add Products to the Quote
'
' Author				:		 Anil/Nagaraj
'Modified by		  : 			
' Creation Date  		 : 			  04/7/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Function fn_SQE_Productselection(dProductName)

'  dProductName = "Google Apps Integration (quote)|Lync Integration RCC (quote)|Voice Lync Integration (quote)"
		On Error Resume Next
		blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
		Set ObjShell = CreateObject("Wscript.Shell")
		dProductName1 = split(dProductName, "|")
		arrUpperBound = UBound(dProductName1)
		arr = split(dProductName,"|")
		objPage.WebList("lstLinktoNew").HighLight
		objPage.WebList("lstLinktoNew").Click
		
		allitemscnt = objPage.WebList("lstLinktoNew").GetROProperty("items count")
		arrAllitems = Split(objPage.WebList("lstLinktoNew").GetROProperty("all items"), ";")
		
		If  objPage.WebList("lstLinktoNew").GetROProperty("selection") = "" Then
			ObjShell.SendKeys "{UP}"
		End If
		
		'For intCounter = 0 to uBound(arrAllitems)
		For intarritem = 0 to arrUpperBound
			strCurrentSelection =  objPage.WebList("lstLinktoNew").GetROProperty("selection")
			For intInnerCounter = 0 to UBound(arrAllitems)
				If strCurrentSelection =  arrAllitems(intInnerCounter) Then
					intSelection = intInnerCounter
					Exit For
				End If
			Next
		
			strActual = arr(intarritem)
			For intInnerCounter = 0 to UBound(arrAllitems)
				If strActual =  arrAllitems(intInnerCounter) Then
					intToBeSelected = intInnerCounter
		''			Msgbox intToBeSelected
					Exit For
				End If
			Next
		
			intDiff = intToBeSelected - intSelection
			If intDiff < 0 Then
				For intTraverseUp = 1 to Abs(intDiff)
					ObjShell.SendKeys "{DOWN}"
					Wait(1)	
				Next
			Else
				For intTraverseDown = 1 to Abs(intDiff)
					ObjShell.SendKeys "{DOWN}"
					Wait(1)
				Next
			End If
		'Next
			objPage.WebButton("btnAdd").Click
			Call ReportLog("Configure Product","Configuration Status should be shown as 'VALID' after bulk configuration.","Configuration Status is shown as 'VALID' after bulk configuration--"&strActual,"PASS","False")
			objPage.WebList("lstLinktoNew").Click
		
		Next
End Function
