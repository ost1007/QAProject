'''''''''****************************************************************************************************************************
' Function Name 		:		fn_SQE_Select_Product
'
' Purpose				: 		Function to configure Products added to the Quote
'
' Author				:		 Anil.
'Modified by		  : 			
' Creation Date  		 : 		  28/8/2014
'Modified Date  		 :		
' Parameters	  	:			
'                  					     
' Return Values	 	: 			Not Applicable
'****************************************************************************************************************************
Public Function fn_SQE_Select_Product()

 
'strProductName = Split(dProductName, "|")
'strCount = Ubound(strProductName)
'
'blnResult = BuildWebReference("brwShowingAddProduct","pgShowingAddProduct","")
'	If Not blnResult Then
'		Environment.Value("Action_Result") = False  
'		Call EndReport()
'		Exit Function
'	End If
'
'Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebElement("webElmConfigure").Click
'wait 2
'
'Set abc = createobject("Wscript.Shell")
' abc.SendKeys "+{TAB},4"
' abc.SendKeys "+{TAB},4"
' abc.SendKeys "+{TAB},4"
' abc.SendKeys "+{TAB},4"
'abc.SendKeys "{DOWN},4"
' abc.SendKeys "{TAB},4"
' Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebButton("btnAdd").Click
'' abc.SendKeys "+{TAB},4"
'' abc.SendKeys "{DOWN},4"
'' abc.SendKeys "{TAB},4"
''abc.SendKeys "{TAB},4"
''abc.SendKeys "{TAB},4"
''abc.SendKeys "{TAB},4"
''abc.SendKeys "{TAB},4"
'' Browser("brwSQE").Page("pgSQE").WebButton("btnAdd").Click
'abc.SendKeys "{TAB},4"
'abc.SendKeys "{TAB},4"
'abc.SendKeys "{TAB},4"
' Browser("brwShowingAddProduct").Page("pgShowingAddProduct").WebButton("btnOkRateScreen").Click
'
'For intCounter = 1 to 30
'		Wait 5
'		blnResult = objPage.WebElement("webElmLoadingAssets").Exist
'		If not blnResult Then
'			Exit For
'		End If
'	Next

'Wait 8

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'For Iterator = 1 to strCount+1
'	If ObjPage.WebList("lstLinktoNew").Exist Then
'		wait 5
''	Set oShell = CreateObject("Wscript.Shell")
''Browser("brwSQE").Page("pgSQE").WebList("lstLinktoNew").WaitProperty "visible","True",100000
'
'    blnResult = selectValueFromPageList("lstLinktoNew", strProductName(Iterator-1))
'	If Not blnResult Then
'		Environment.Value("Action_Result") = False  
'		Call EndReport()
'		Exit Function
'	End If
'	End if 
'
'Setting.WebPackage("ReplayType") = 2
'
'	If ObjPage.WebButton("btnAdd").Exist Then
'
''		 ObjPage.WebButton("btnAdd").HighLight
''Browser("brwSQE").Page("pgSQE").WebButton("btnAdd").Object.focus
'
''oShell.SendKeys "{TAB}"
''wait 3
''oShell.SendKeys "{ENTER}"
''wait 3
'	 blnResult = clickButton("btnAdd")
'	If Not blnResult Then
'		Environment.Value("Action_Result") = False  
'		Call EndReport()
'		Exit Function
'	End If
'	End if 
'Next
''Setting.WebPackage("ReplayType") = 1
'
''If ObjPage.WebList("lstCurrentselection").Exist Then
''	strcurrentselectioncount = ObjPage.WebList("lstCurrentselection").GetROProperty("items count")
''	If  cint(strcurrentselectioncount) = cint(strCount) Then
''		Call ReportLog("Rates Screen","All items selected on Rates Screen.","is properly gets added in Link to New Link","PASS","TRUE")
'		If ObjPage.WebButton("btnOkRateScreen").Exist Then
'			 blnResult = clickButton("btnOkRateScreen")
'			If Not blnResult Then
'				Environment.Value("Action_Result") = False  
'				Call EndReport()
'				Exit Function
'			End If
'		End if 
''		Else
''		Call ReportLog("Rates Screen","All items selected on Rates Screen.","is not exactly gets added in Link to New Link","FAIL","TRUE")
''   	End If
'' End if
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 End Function
