'******************************************************************************************************************************************************
' Description: Function to Click on Logout and close the Browser
'******************************************************************************************************************************************************
Public Function fn_Expedio_Logout()

	If Browser("name:=IPSDK WEB GUI \(Search\)").Exist(10) Then
		If Browser("name:=IPSDK WEB GUI \(Search\)").Link("name:=Logout", "index:=0").Exist(5) Then
			Browser("name:=IPSDK WEB GUI \(Search\)").Link("name:=Logout", "index:=0").Click
		End If
	ElseIf Browser("name:=IPSDK Track Orders \(Search\)").Exist(10) Then
		If Browser("name:=IPSDK Track Orders \(Search\)").Link("name:=Logout", "index:=0").Exist(5) Then
			Browser("name:=IPSDK WEB GUI \(Search\)").Link("name:=Logout", "index:=0").Click
		End If
	End If
	
	If Browser("url:=.*expediomt.*logout.jsp.*", "creationtime:=0").Exist(10) Then
		Browser("url:=.*expediomt.*logout.jsp.*", "creationtime:=0").Close
	End If

End Function
