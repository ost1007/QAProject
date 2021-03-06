'****************************************************************************************************************************
' Function Name	 : fn_eDCA_DatePicker(dtDate)
'
' Purpose	 	 : Function to select Date in Customer details Page
'
' Author	 	 : Vamshi krishna & Linta CK
'
' Creation Date  	 : 05/06/2013
'
' Parameters	 : dtDate	- Contains value for Date Field
'                  					     
' Return Values	 : Not Applicable
'****************************************************************************************************************************

Public Function fn_eDCA_DatePicker(dtDate)
   'fncDatePicker(dtDate)

	'Declaring variables
	Dim strRetrievedText
	Dim arrText,arrOtherMonthDates(10)
	Dim intCounter
	Dim dtOrderFormSignDate

	'Assigning values to Variables
	dtOrderFormSignDate = dtDate

	arrdt = Split(dtOrderFormSignDate,"-")
	dtDay = arrdt(0)
	If Len(dtDay) = "2" Then
		If Left(dtDay,1) = "0" Then
			dtDay = Right(dtDay,1)
		End If
	End If

	arrdt = Split(dtOrderFormSignDate,"-")
	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebList("lstYear").Select arrdt(2)
	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebList("lstMonth").Select arrdt(1)
      
	strRetrievedText = Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").WebTable("MonthTable").GetROProperty("text")
	arrText = Split(strRetrievedText,"SMTWTFS")
	For intCounter = 0 to 10
		arrOtherMonthDates(intCounter) = Left(arrText(1),2)
		If arrOtherMonthDates(intCounter) = "12" Then
                  Exit For
		End If
		arrText(1) = Right(arrText(1),Len(arrText(1))-2)
	Next

	strIndex = 0
	If dtDay >= 23 Then
		For intCounter = 0 to UBound(arrOtherMonthDates)-1
			If dtDay = arrOtherMonthDates(intCounter) Then
				strIndex = 1
				Exit For
			End If
		Next
	End If

	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").Link("Day").SetTOProperty "text",dtDay
	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").Link("Day").SetTOProperty "index",strIndex
	Browser("brweDCAPortal").Window("SelectDateWebpage").Page("pgSelectDate").Link("Day").Click

End Function

