'****************************************************************************************************************************
' Function Name 		:		fn_SQE_CreateOffer
'
' Purpose				: 		Function to Create Offer
'
' Author				:		 Linta C.K.
'Modified by		  : 			
' Creation Date  		 : 		  08/7/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************

Public Function fn_SQE_CreateOffer_ModifySoftChanges(dOfferName,dCustomerOrderReference,dActualConfigureProduct)

	'Declaring of variables
	Dim blnResult
	Dim strOfferName,strCustomerOrderReference

	'Assigning variables
	strOfferName = dOfferName
	strCustomerOrderReference = dCustomerOrderReference

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brwSQE","pgSQE","")
	If Not blnResult Then
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
'
	'Check for Offer Name
	blnResult = objPage.WebTable("webTblItems").Exist
	If blnResult = "True" Then
		strOfferNameDisplayed = objPage.WebTable("webTblItems").GetCellData(2,7)
		strOfferNameDisplayedtwo = objPage.WebTable("webTblItems").GetCellData(3,7)
		If strOfferNameDisplayed <>"" and strOfferNameDisplayedtwo <>"" Then
			Call ReportLog("Create Offer","Offer should be created with Offer name populated","Offer is created with Offer name populated as - "&strOfferNameDisplayed,"PASS","False")
'			Exit Function
		End If
	End If
''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''		If ObjPage.WebTable("webTblItems").Exist(10) Then
'''			strRowCnt = ObjPage.WebTable("webTblItems").RowCount
'''			For Intcnt = 1 to strRowCnt	
'''						strProductName = ObjPage.WebTable("webTblItems").GetCellData(Intcnt,3)
'''						If  strProductName = dActualConfigureProduct Then
'''							Set ObjWebchkBox = ObjPage.WebTable("webTblItems").ChildItem(Intcnt,1,"WebCheckBox",0)
'''									ObjWebchkBox.Click
'''									Exit For
'''						End If
'''			Next
'''		End If

	blnResult = objPage.WebCheckBox("html id:=selectAll").Exist
	If blnResult = "True" Then
		 objPage.WebCheckBox("html id:=selectAll").Set "ON"
	Else
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
''
'''''''''''''	'Click on Create Offer
	blnResult = objPage.Link("lnkCreateOffer").Exist
	If blnResult = "True" Then
		blnResult = clickLink("lnkCreateOffer")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	Else		
		Call ReportLog("Click on Create Offer","User should be able to click on Create Offer link","User could not click on Create Offer link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
''
''''''''''''''''''''	Enetr Offer Name
	blnResult = objPage.WebEdit("txtOfferName").Exist
	If blnResult = "True" Then
		blnResult = enterText("txtOfferName",strOfferName)
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If
''
'''''''''''''	'Enter Customer Order Reference
	blnResult = objPage.WebEdit("txtCustomerOrderReference").Exist
	If blnResult = "True" Then
		blnResult = enterText("txtCustomerOrderReference",strCustomerOrderReference)
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If
''
'''''''''''''''''	'Click on Save
	blnResult = objPage.WebButton("btnSave").Exist
	If blnResult = "True" Then
		blnResult = clickButton("btnSave")
		If Not blnResult Then
			Environment.Value("Action_Result") = False  
			Call EndReport()
			Exit Function
		End If
	End If

	Wait 5
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	StrRowCount = objPage.WebTable("webTblItems").RowCount
'	strColCount = objPage.WebTable("webTblItems").ColumnCount(StrRowCount)

	For Intcounter = 2 to StrRowCount
			strProductName = objPage.WebTable("webTblItems").GetCellData(Intcounter,3)
			If  strProductName = dActualConfigureProduct Then
				Set ObjWebchkBox = objPage.WebTable("webTblItems").childitem(Intcounter,1,"WebCheckBox",0)
						ObjWebchkBox.Set "ON"
						Exit For
			End If

	Next



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
'''''''''''''''''''	'Check if navigated to Offers Link
	For intCounter = 1 to 10
		blnResult = objPage.Link("lnkOffers").Exist
				objPage.Link("lnkOffers").HighLight
		If blnresult = "True" Then
			blnResult = ClickLink("lnkOffers")
			Call ReportLog("Save Offer Details","User should be able to save offer details and navigate to Offers link","User is able to save offer details and navigate to Offers link","PASS","False")
			Exit For
		Else
			Wait 5
		End If	
	Next
'
	If Not blnResult Then
		Call ReportLog("Save Offer Details","User should be able to save offer details and navigate to Offers link","User is able to save offer details and navigate to Offers link","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If
'
'''''''''''''''	'Check Offer Status
	blnResult = objPage.WebTable("webTblBaseConfigQty").Exist
	If blnResult = "True" Then
		strStatus = Trim(objPage.WebTable("webTblBaseConfigQty").GetCellData(2,4))
		If strStatus = "Active" Then
			blnResult = objPage.Image("imgCustomerApprove").Exist
			If blnResult = "True" Then
				blnResult = clickImage("imgCustomerApprove")
				If Not blnResult Then
					Environment.Value("Action_Result") = False
					Call EndReport()
					Exit Function
				End If
			Else
				Call ReportLog("Customer Approve","CustomerApprove image should exist","CustomerApprove image does not exist","FAIL","True")
				Exit Function
			End If
		ElseIf strStatus = "Approved" Then
			Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is Approved","PASS","False")
			Exit Function
		Else
			Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is not Approved, instead - "&strStatus,"FAIL","True")
			Exit Function
		End If
	End If

'''''''''''	'Check for Approved status after clicking on Customer Approve Image
	For intCounter = 1 to 10
		strStatus = Trim(objPage.WebTable("webTblBaseConfigQty").GetCellData(2,4))
		If strStatus = "Approved" Then
			Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is Approved","PASS","False")
                  Exit For
		Else
			Wait 5
		End If
	Next
'
	If strStatus <> "Approved" Then
		Call ReportLog("Customer Approve Status","CustomerApprove Status should be approved","CustomerApprove status is not displayed as - 'Approved'","FAIL","True")
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If

	'Set innertext for Offer Name
	Set oDesc = Description.Create
	oDesc("micClass").value = "WebElement"
	odesc("innertext").value = strOfferName

	For intCounter = 1 to 10
		Set objElm = objPage.ChildObjects(oDesc)
		If objElm.Count = 1 Then
			objElm(0).Click
            Exit For
		End IF
	Next

	If objElm.Count = 0 Then
		Call ReportLog("Offer Name","User should be able to click on Offer Name","Offer Name does not exist on page","FAIL","True")
		Environment.Value("Action_Result") = False  
		Call EndReport()
		Exit Function
	End If

''''''	objPage.WebElement("innertext:=" & strOfferName, "class:=name", "index:=0").HighLight
''''''	objPage.WebElement("innertext:=" & strOfferName, "class:=name", "index:=0").Click

	'check if navigated successfully to Offer Details tab
	For intCounter = 1 to 10
		blnResult = objPage.Link("lnkOfferDetails").Exist
		If blnResult = "True" Then
			Call ReportLog("Offer Details Tab","User should be able to navigate to Offer Details on clicking offer name","User is able to navigate to Offer Details on clicking offer name","PASS","False")
			Exit For
		Else
			Wait 5
		End If
	Next

	If Not blnResult Then
		Call ReportLog("Offer Details Tab","User should be able to navigate to Offer Details on clicking offer name","User is not able to navigate to Offer Details on clicking offer name","FAIL","True")
		Environment.Value("Action_Result") = False
		Call EndReport()
		Exit Function
	End If


End Function

'*************************************************************************************************************************************************************************************
'End of function
'***************************************************************************************************************************************************************************************

