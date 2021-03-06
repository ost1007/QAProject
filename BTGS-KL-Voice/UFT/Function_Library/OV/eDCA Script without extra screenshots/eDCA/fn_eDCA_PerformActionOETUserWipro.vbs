'****************************************************************************************************************************
' Function Name	 : fn_eDCA_PerformActionOETUserWipro
' Purpose	 	 :  Retriving the order details and amending the order when logged in with OET  User Wipro
' Author	 	 : Vamshi Krishna Guddeti
' Creation Date  : 13/06/2013              					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_eDCA_PerformActionOETUserWipro(dSearch,deDCAOrderId,deDCAOETUserID1,dOETProfile1)

	'Declaration of variables
	Dim strSearch,strSearchOrderIdValue,streDCAOETUserID1,strOETProfile1

	'Assignment of variables
	strSearch = dSearch
	streDCAOrderId = deDCAOrderId
	streDCAOETUserID1 = deDCAOETUserID1
	strOETProfile1 = dOETProfile1

	'Function to set the browser and page objects by passing the respective logical names
	blnResult = BuildWebReference("brweDCAPortal","pgeDCAPortal","")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	'Selecting orderId to search the order
	wait 10
	blnResult = selectValueFromPageList("lstSearch",strSearch)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Enter the order id into search
	blnResult = enterText("txtSearch",streDCAOrderId)
		If Not blnResult Then Environment("Action_Result") = False : Exit Function

	'Click on Search button
	blnResult = clickButton("btnSearch")
		If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync

	If Browser("brweDCAPortal").Page("pgeDCAPortal").Link("lnkOrderId").Exist(60) Then
		'Click on Order Id link retrived
		blnResult = clickLink("lnkOrderId")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
		
		'Click on Write/Amend Order  link
		blnResult = clickLink("lnkWrite/AmendOrder")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	Else
		Call ReportLog("Order Search","Should retrive the order details after clicking on search button","Not retrived order details after clicking on search button.Hence searching th order by logging in with OET User Infosys","PASS", True)
		'Signing out from eDCA application
		blnResult = clickLink("lnkSignout")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function

		'Closing Browser
		Browser("brweDCAPortal").Close

		Call fn_eDCA_Login(GetAttributeValue("deDCAURL"),streDCAOETUserID1)
			If Not Environment("Action_Result") Then Exit Function
		Call fn_eDCA_SelectProfile(strOETProfile1)
			If Not Environment("Action_Result") Then Exit Function
		Call fn_eDCA_PerformActionOETUserWipro(strSearch,streDCAOrderId,streDCAOETUserID1,strOETProfile1)
			If Not Environment("Action_Result") Then Exit Function
	End If
	
	Browser("brweDCAPortal").Page("pgeDCAPortal").Sync
	'Check if navigated to Customer details page
	Set objMsg = objpage.WebElement("webElmCustomerDetails")
	'objMsg.WaitProperty "visible", True,1000*60*5
	If Not objMsg.Exist(60*5) Then
		Call ReportLog("PerformAction","Should be navigated to CustomerDetails page on clicking Write/Amend Order lilnk","Not navigated to CustomerDetails page on clicking Write/Amend Order link","FAIL","TRUE")
		Environment("Action_Result") = False : Exit Function
	Else
		strMessage = GetWebElementText("webElmCustomerDetails")
		Call ReportLog("PerformAction","Should be navigated to CustomerDetails page on clicking Write/Amend Order link","Navigated to the page - "&strMessage,"PASS","")
	End If

End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
