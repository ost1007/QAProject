
'****************************************************************************************************************************
' Function Name	 : fn_Expedio_Aactivity
' Purpose	 	 		: Function to click on Quick Link
' Author	 	 		: Anil Pal
' Creation Date  : 	17/07/2014
' Parameters	 : 	dTypeOfOrder,dExpedioRef
' Return Values	 : Not Applicable
'****************************************************************************************************************************
Public Function fn_Expedio_AddAttributes(dAttributesName)

   Dim strAttributesName
  strAttributesName =dAttributesName

  arrAttributesName = Split(strAttributesName,"|")

  For intCounter = 0 to ubound(arrAttributesName)

       If objPage.WebTable("tblattributesName").Exist then 
			strRow = objPage.WebTable("tblattributesName").Rowcount
			strcol = objPage.WebTable("tblattributesName").ColumnCount(strRow)

				For intinnercounter = 0 to strRow

					Case "1"
							strattributesname = objPage.WebTable("tblattributesName").GetCellData(strRow,strcol)
							If strattributesname = arrAttributesName(intinnercounter) Then
								objPage.WebTable("tblattributesName").object.rows(intinnercounter).cells(1).click
								If  objPage.WebTable("tblValuelist").ExistThen
									objPage.WebTable("tblValuelist").object.rows(1).cells(1).click

									blnResult  = clickLink("lnkAddattributes")
									If blnResult = "False" Then		
										Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
										Call EndReport()
										Exit Function
									End If
								End If
							End If

							If strattributesname = arrAttributesName(intinnercounter) Then
								objPage.WebTable("tblattributesName").object.rows(intinnercounter).cells(1).click
								If  objPage.WebTable("tblValuelist").ExistThen
									objPage.WebTable("tblValuelist").object.rows(1).cells(1).click

									blnResult  = clickLink("lnkAddattributes")
									If blnResult = "False" Then		
										Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
										Call EndReport()
										Exit Function
									End If
								End If
							End If

				Next


		                     blnResult = objPage.WebTable("class:=BaseTable").Exist
                                                If blnResult = "True" Then
                                                                Set objDesc = Description.Create
                                                                objDesc("micClass").Value = "WebElement"
                                                                Set objElm = objPage.WebTable("class:=BaseTable").childObjects(objDesc)
                                                                If objElm.Count >= 1 Then
																	For intCounter = 0 to objElm.Count -1
																					If arrAttributesName(intCounter) =objElm(intCounter).GetROProperty("innertext") then 
																					objElm(intCounter).Highlight
																					Wait 2
																					objElm(intCounter).FireEvent "onclick"
																					Exit For
                                                                                    End if
																					
																	Next
                                                                End If
                                                End If
                                End If
                Else
                                Call ReportLog("Contract Field","Contract field should exist","Contract field does not exist","FAIL","TRUE")
                                Environment.Value("Action_Result")=False 'Parameter("ActionOutPut")=constScrInstAbort
                                Call EndReport()
                                Exit Function
                End If

  Next