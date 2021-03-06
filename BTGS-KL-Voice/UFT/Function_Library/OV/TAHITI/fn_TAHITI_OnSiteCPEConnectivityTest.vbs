'****************************************************************************************************************************
' Function Name	 : fn_TAHITI_OnSiteCPEConnectivityTest
' Purpose	 	 : Function to enter particulars for Onsite CPE  Connectivity Test
' Author	 	 : Vamshi Krishna G
' Creation Date  	 : 18/12/2013          					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public function fn_TAHITI_OnSiteCPEConnectivityTest(dONSITE_CPE_CONNECTIVITY_TEST)

	'Declaration of variables
	Dim strcurrentdate, strmonth, strcurrentmonth, strdate, stryear
	
	'Variable Assignment
	strcurrentdate =  Date
	strmonth = Split(strcurrentdate,"/")
	strcurrentmonth = strmonth(1)
	If strcurrentmonth = "06" OR strcurrentmonth = "07" Then
		strmonth =  MonthName(strcurrentmonth, False)
	ElseIf strcurrentmonth = "09" Then
		strmonth =  Left(MonthName(strcurrentmonth, False), 4)
	Else
		strmonth =  MonthName(strcurrentmonth, True)
	End If
	strdate = Day(Now)
	stryear = Year(Now)

	'Assigning values to an array
	Dim arrONSITE_CPE_CONNECTIVITY_TEST,arrValues
	arrONSITE_CPE_CONNECTIVITY_TEST = Split(dONSITE_CPE_CONNECTIVITY_TEST,",")
	intUBound = UBound(arrONSITE_CPE_CONNECTIVITY_TEST)
	ReDim arrValues(intUBound,1)

	For intCounter = 0 to intUBound
		arrValues(intCounter,0) = Split(arrONSITE_CPE_CONNECTIVITY_TEST(intCounter),":")(0)
		arrValues(intCounter,1) = Split(arrONSITE_CPE_CONNECTIVITY_TEST(intCounter),":")(1)
	Next

	'Building reference
	blnResult = BuildWebReference("brwTahitiPortal","pgTahitiPortal","frmMyTasks")
	If blnResult= False Then
		Environment.Value("Action_Result")=False 
		Exit Function
	End If
	
	'Onsite CPE Test  Executed

	If objFrame.WebList("lstOnsiteCPETestExecuted").Exist(10) Then
		For i = 1 to 5
			objFrame.WebList("lstOnsiteCPETestExecuted").Click
			objPage.Sync
			strListValues = objFrame.WebList("lstOnsiteCPETestExecuted").GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next		

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "OnsiteCPETestExecuted" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = selectValueFromList("lstOnsiteCPETestExecuted",strData)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	End If
	
	If objFrame.WebList("lstOnsiteCPETestResult").Exist(10) Then
		strCPE = "lstOnsiteCPETestResult"
		cldrCPE = "imgCldrExecutionOnSiteCPETestDate"
	ElseIf objFrame.WebList("lstOnsiteCPETestResult1").Exist(10) Then
		strCPE = "lstOnsiteCPETestResult1"
		cldrCPE = "imgCldrExecutionOnSiteCPETestDate1"
	End If
	
	If objFrame.WebList("lstOnsiteCPETestResult").Exist(0) OR objFrame.WebList("lstOnsiteCPETestResult1").Exist(0) Then
		For i = 1 to 5
			objFrame.WebList(strCPE).Click
			objPage.Sync
			strListValues = objFrame.WebList(strCPE).GetROProperty("all items")
			arrListValues = Split(strListValues,";")
			If UBound(arrListValues) >= 1 Then
				Wait 5
				Exit For
			Else 
				Wait 3
			End If
		Next

		'Onsite CPE Test Result
		objFrame.WebList(strCPE).Click
		objPage.Sync

		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "OnsiteCPETestResult" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next

		blnResult = selectValueFromList(strCPE,strData)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If

		'Execution OnsiteCPETest Date
		blnResult =  clickFrameImage(cldrCPE)
		If blnResult= False Then
			Environment.Value("Action_Result")=False 
			Exit Function
		End If
	
		'Clicking on todays date
		wait 3
		
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
	End If
	
	'Select Actual Installation Date
	If objFrame.Image("imgCldrActualInstallationDate").Exist(10) Then
		blnResult =  clickFrameImage("imgCldrActualInstallationDate")
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
		
		Browser("brwDateTimePicker").Page("pgDateTimePicker").WebList("MonthSelector").Select strmonth
		Browser("brwDateTimePicker").Page("pgDateTimePicker").Link("innertext:=" & strdate).Click
		Wait 2
	End If
	
	'Enter Tag No
	If objFrame.WebEdit("txtAssetTagNo").Exist(0) Then
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "AssetTagNo" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
		blnResult = enterFrameText("txtAssetTagNo", strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
	'Enter Serial Number
	If objFrame.WebEdit("txtSerialNo").Exist(0) Then
		For intLoop = 0 to intUBound
			If arrValues(intLoop,0) = "SerialNo" Then
				strData = arrValues(intLoop,1)
				Exit For
			End If
		Next
		blnResult = enterFrameText("txtSerialNo", strData)
			If Not blnResult Then Environment("Action_Result") = False : Exit Function
	End If
	
End Function

'***************************************************************************************************************************************************************************************
'End of Function
'***************************************************************************************************************************************************************************************
