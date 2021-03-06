
'****************************************************************************************************************************
' Function Name 		:		fn_SQE_ConfigureProduct
'
' Purpose				: 		Function to configure Products added to the Quote
'
' Author				:		 Linta C.K.
'Modified by		  : 			
' Creation Date  		 : 		  07/7/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_SQE_ConfigureProduct_Cease_Site(dsiteID)

	'Declaring of variables
	Dim intQuantity

	'Assigning variables
	strQuantity = dQuantity
	strPlanName = dPlanName
      strTGFriendlyName = dTGFriendlyName
	strTGCACLimit = dTGCACLimit
	strTrunkFriendlyName = dTrunkFriendlyName
	strTrunkCACLimit = dTrunkCACLimit
	strTrunkCACBandwidthLimit = dTrunkCACBandwidthLimit

	'Function to set the browser and page objects by passing the respective logical names
		blnResult = BuildWebReference("brwSQE","pgSQE","")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If


      
'''''''''''''''''''	Select Checkbox
		blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems").Exist
		If blnResult = "True" Then
			objPage.WebCheckBox("chkListOfQuoteOptionItems").Set "ON"
		Else
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If


'''		If ObjPage.WebTable("webTblItems").Exist(10) Then
'''			strRowCnt = ObjPage.WebTable("webTblItems").RowCount
'''			For Intcnt = 2 to strRowCnt	
'''						strProductName = ObjPage.WebTable("webTblItems").GetCellData(Intcnt,2)
'''						If  strProductName = dsiteID Then
'''							Set ObjWebchkBox = ObjPage.WebTable("webTblItems").ChildItem(Intcnt,1,"WebCheckBox",0)
'''									ObjWebchkBox.Click
'''									Exit For
'''						End If
'''			Next
'''		End If


''''''''''''''''	Click on Configure Product
		blnResult = objPage.Link("lnkConfigureProduct").Exist
		If blnResult = "True" Then
			blnResult = clickLink("lnkConfigureProduct")
			If Not blnResult Then
				Environment.Value("Action_Result") = False  
				Call EndReport()
				Exit Function
			End If
		Else		
			Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link","User could not click on Configure Product link","FAIL","True")
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If

		For intCounter = 1 to 10
		blnResult = objPage.WebElement("webElmLoadingAssets").WaitProperty("Visible",False,10000)
				If not blnResult Then
					Exit for
				End If
		Next

		blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If

'''''''''''	'Check if navigated to Bulk Configuration Page
		blnResult = objPage.WebElement("webElmBulkConfiguration").Exist
		If blnResult = "True" Then
			Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link and navigated to Bulk configuration page","User succesfully navigated to Bulk Configuration page after clicking on Configure Product link","PASS","False")
		Else		
			Call ReportLog("Click on Configure Product","User should be able to click on Configure Product link and navigated to Bulk configuration page","User not navigated to Bulk Configuration page after clicking on Configure Product link","FAIL","True")
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If

		Set oDesc = Description.Create
		oDesc("micClass").value = "WebElement"
		oDesc("class").value = "label ng-scope ng-binding.*"
		
		Set oCol = objPage.ChildObjects(oDesc)
				oCol(0).Click

		wait(1)
		blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems1").Exist
		If blnResult = "True" Then
			objPage.WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
		Else
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If

		blnResult = objPage.WebButton("btnDeleteAsset").Exist
		wait(3)
		blnResult = clickbutton("btnDeleteAsset")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If

		For intCounter = 1 to 10
		blnResult = objPage.WebElement("WebelmPerformingdelete").WaitProperty("Visible",False,10000)
				If not blnResult Then
					Exit for
				End If
		Next
		
		strAction = ObjPage.WebTable("webTblBaseConfigQty").GetCellData(2,3)
		If Trim(strAction) = Trim("Delete") Then
			Call ReportLog("Action Status","Product Action Status should be Deleted","Action Status is Deleted","PASS","FALSE")
			Else
			Call ReportLog("Action Status","Product Action Status should be Deleted","Action Status is not Deleted","FAIL","TRUE")
		End If

		blnResult = objPage.WebElement("webElmQuoteDetails").Exist
		If blnResult = "True" Then
			blnResult = clickWebElement("webElmQuoteDetails")
			If Not blnResult Then
				Environment.Value("Action_Result") = False  
				Call EndReport()
				Exit Function
			End If
		End If

		If ObjPage.WebTable("webTblItems").Exist(30) Then
			ObjPage.WebTable("webTblItems").Highlight
			strOrderStatus = ObjPage.WebTable("webTblItems").GetCellData(2,5)
			If Trim(strOrderStatus) = Trim("Cease") Then
				Call ReportLog("Order Status","Product Order Status should be Cease","Product Order Status is--"&strOrderStatus,"PASS","TRUE")
				Else
				Call ReportLog("Order Status","Product Order Status should be Cease","Product Order Status is--"&strOrderStatus,"FAIL","TRUE")
			End If
		End If

		''	wait(1)
		''	blnResult = objPage.WebCheckBox("chkListOfQuoteOptionItems1").Exist
		''	If blnResult = "True" Then
		''		objPage.WebCheckBox("chkListOfQuoteOptionItems1").Set "ON"
		''	Else
		''		Environment.Value("Action_Result") = False  
		''		Call EndReport()
		''		Exit Function
		''	End If

		''	Set ObjShell = CreateObject("Wscript.Shell")
		''	ObjShell.SendKeys"{F5}"
		''	Set ObjShell = Nothing
 End Function

 '*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************
