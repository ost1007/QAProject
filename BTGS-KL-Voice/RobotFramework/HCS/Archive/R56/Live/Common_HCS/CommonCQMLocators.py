##CQM_CreateCustomer##
CREATE_CUST_TAB				="xpath=.//*[@id='manageCust']/div/ul/li[*]/a[contains(normalize-space(.), 'Create Customer')]"
OKBUTTON					="xpath=.//div[contains(@cqm-dialog,'show')]//button[contains(text(),'OK')]"
YESBUTTON					="xpath=.//div[contains(@cqm-dialog,'show')]//button[contains(text(),'Yes')]"

#added by Azry 06072018 - cater for extrating quote Ref ID
##CQM CreateQute##
QUOTE_SUCCESS_MESSAGE				="xpath=.//h5[contains(text(),'Quote successfully created')]"
#end added by Azry 06072018 - cater for extrating quote Ref ID