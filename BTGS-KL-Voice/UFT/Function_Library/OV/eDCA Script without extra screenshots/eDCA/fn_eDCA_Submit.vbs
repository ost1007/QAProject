'************************************************************************************************************************************
' Function Name	 :  fn_eDCA_Submit
' Purpose	 	 :  Submiting the order and checking the status 
' Author	 	 : Vamshi Krishna G
' Creation Date    : 12/06/2013
' Return values :	Nil
'**************************************************************************************************************************************	
Public Function fn_eDCA_Submit(dTypeOfOrder,dSearch,deDCAOrderId)

	'Decalaration of varaibles
	Dim blnResult,strRetrivedText
	Dim strSearch,streDCAOrderId,strTypeOfOrder,strEmailMessage

	'Assignment of variables
	strSearch = dSearch
	streDCAOrderId = deDCAOrderId
	strTypeOfOrder = dTypeOfOrder
	strEmailMessage = "Test"

	blnPrevNext = False
	For intCounter = 1 to 5

		If blnPrevNext Then
			objPage.Sync
			objPage.WbfTreeView("html id:=TreeView1").Link("innertext:=Distributor Contact Details.*", "index:=0").Click
			Wait 2
			objPage.Sync
		End If
	
		'Function to set the browser and page objects by passing the respective logical names
		blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		'Click on Submit link of Left hand isde
		Browser("brweDCAPortal").Page("pgeDCAPortal").ViewLink("treeview").Link("lnkSubmit").Click
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	
		If Ucase(strTypeOfOrder) = "GSIPPROVIDE" or  Ucase(strTypeOfOrder) = "ETHERNETPROVIDE"  or  Ucase(strTypeOfOrder) = "OUTBOUNDPROVIDE" or strTypeOfOrder = "P2PEtherNetProvide" OR Ucase(strTypeOfOrder) = "OVAPROVIDE" Then 
			'or Ucase(strTypeOfOrder) = "GVPNUNBUNDLEDPROVIDE" #Removed in R41
	
			'Click on btnValidateTrunkGroupAndTrunkFriendlyName button
			If objPage.WebButton("btnValidateTrunkGroupAndTrunkFriendlyName").Exist Then
				If objPage.WebButton("btnValidateTrunkGroupAndTrunkFriendlyName").GetROProperty("disabled") = 0 Then
					blnResult = clickButton("btnValidateTrunkGroupAndTrunkFriendlyName")
						If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
					Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
				Else
					Call ReportLog("Click on ValidateTrunkGroupAndTrunkFriendlyName","ValidateTrunkGroupAndTrunkFriendlyName should be clicked","ValidateTrunkGroupAndTrunkFriendlyName is not enabled","FAIL","TRUE")
					Environment("Action_Result") = False
					Exit Function
				End If
				Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
			End If
		End If 

		If Not objPage.WebButton("btnOrderValidation").WaitProperty("disabled", 0, 30000) Then
			blnPrevNext = True
		Else
			Exit For
		End If
	Next '#intCounter

	'Click on Order Validation
	If dTypeOfOrder = "OB_FULLPSTN_MODIFY"  or dTypeOfOrder = "GSIPPROVIDE" OR dTypeOfOrder =  "GSIPMODIFY" or dTypeOfOrder =  "GSIPCEASE" or dTypeOfOrder = "P2PEtherNetProvide" or  Ucase(strTypeOfOrder) = "OUTBOUNDPROVIDE" OR Ucase(strTypeOfOrder) = "OVAPROVIDE" OR strTypeOfOrder = "OMAPROVIDE"  OR dTypeOfOrder = "GVPNUNBUNDLEDPROVIDE" Then
		If objPage.WebButton("btnOrderValidation").Exist Then
			If objPage.WebButton("btnOrderValidation").GetROProperty("disabled") = 0 Then
				blnResult = clickButton("btnOrderValidation")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Else
				Call ReportLog("Click on OrderValidation","OrderValidation should be clicked","OrderValidation is not enabled","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			End If
		End If
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	Set objTable = objPage.WbfGrid("html id:=UsrTahitiSubmit_dgErrorList")

	If objTable.Exist Then
		Call ReportLog("OrderValidation","No Error Table should be populated","Encountered : </br>" & objTable.GetROProperty("innerhtml"),"FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	End If

	If dTypeOfOrder = "OB_FULLPSTN_MODIFY"  or dTypeOfOrder =  "GSIPMODIFY" or dTypeOfOrder =  "P2PEtherNetProvide" or  Ucase(strTypeOfOrder) = "OUTBOUNDPROVIDE"  OR  dTypeOfOrder = "OVAPROVIDE" OR dTypeOfOrder = "OMAPROVIDE" OR dTypeOfOrder = "GVPNUNBUNDLEDPROVIDE" Then
		If objPage.WebButton("btnSubmitToSDWithAutoEmail").Exist Then
			If objPage.WebButton("btnSubmitToSDWithAutoEmail").GetROProperty("disabled") = 0 Then
				blnResult = clickButton("btnSubmitToSDWithAutoEmail")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Else
				Call ReportLog("Click on SubmitToSDWithAutoEmail","SubmitToSDWithAutoEmail should be clicked","SubmitToSDWithAutoEmail is not enabled","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			End If
		End If
	End if

	'Click on button Submit to SD with auto email
	If dTypeOfOrder = "GSIPCEASE"  Then
		If objPage.WebButton("btnSubmitToSDWithManualEmail").Exist Then
			If objPage.WebButton("btnSubmitToSDWithManualEmail").GetROProperty("disabled") = 0 Then
				blnResult = clickButton("btnSubmitToSDWithManualEmail")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Else
				Call ReportLog("Click on SubmitToSDWithAutoEmail","SubmitToSDWithAutoEmail should be clicked","SubmitToSDWithAutoEmail is not enabled","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			End If
		End if
	Elseif dTypeOfOrder = "GSIPPROVIDE" Then
		If objPage.WebButton("btnSubmitToSDWithAutoEmail").Exist Then
			If objPage.WebButton("btnSubmitToSDWithAutoEmail").GetROProperty("disabled") = 0 Then
				blnResult = clickButton("btnSubmitToSDWithAutoEmail")
					If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
			Else
				Call ReportLog("Click on SubmitToSDWithAutoEmail","SubmitToSDWithAutoEmail should be clicked","SubmitToSDWithAutoEmail is not enabled","FAIL","TRUE")
				Environment("Action_Result") = False : Exit Function
			End If
		End If
	End if
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If cstr(dTypeOfOrder) = "GSIPCEASE"  Then
		If Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Exist then 
			Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Highlight
			Browser("brweDCAPortal").Dialog("MessageFromWebpage").WinButton("btnOK").Click
		End If
	End if

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If cstr(dTypeOfOrder) = "GSIPCEASE"  Then
		If ObjPage.WebEdit("txtemailmessage").Exist then 
			blnResult = enterText("txtemailmessage", strEmailMessage)
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
	End if

	If cstr(dTypeOfOrder) =  "GSIPCEASE"  Then
		If ObjPage.WebButton("btnSubmitOrder").Exist then
			blnResult = ClickButton("btnSubmitOrder")
				If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
		End if
	End if

	'Capturing submission order message from browser
	strRetrievedText = objPage.WebElement("webElmOrderSubmissionMessage").GetROProperty("innertext")
	If strRetrievedText <> "" Then
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is populated with the value - "&strRetrievedText,"PASS", True)
	Else
		Call ReportLog("OrderSubmissionMessage","OrderSubmissionMessage should be populated","OrderSubmissionMessage is not populated","FAIL","TRUE")
		Environment("Action_Result") = False
		Exit Function
	End If

	blnResult = selectValueFromPageList("lstSearch",strSearch)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	blnResult = enterText("txtSearch",streDCAOrderId)
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Click on Search button
	blnResult = clickButton("btnSearch")
		If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Retrive the order status
	strRetrivedText = objPage.Link("lnkSubmitToSd").GetROProperty("outertext")
	If strRetrivedText<>"" Then
		Call ReportLog("Submit To Sd","Submit To Sd link should be populated","Submit To Sd link is populated with value-"&strRetrievedText,"PASS","")
	Else
		Call ReportLog("Submit To Sd","Submit To Sd link should be populated","Submit To Sd is not populated","FAIL","TRUE")
		blnResult = clickLink("lnkSignout")
		Environment("Action_Result") = False
	End If

	'Signing out from appliaction
	If objPage.Link("lnkSignout").Exist Then
		blnResult = clickLink("lnkSignout")
			If Not blnResult Then Environment.Value("Action_Result") = False : Exit Function
	End if
	'Closing the browser after signing out

	Browser("brweDCAPortal").Close

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
