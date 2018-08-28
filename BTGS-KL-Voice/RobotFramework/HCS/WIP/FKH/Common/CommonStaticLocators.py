#####common static locators#####

#System URL
T3_EXPEDIO_URL="http://expediomt.t3.nat.bt.com/arsys/forms/aps06419t3app02/IPSDK+WEB+GUI/Default+Admin+View/"
T3_EXP_OrderTracker_URL="http://expediomt.t3.nat.bt.com/arsys/forms/aps06419t3app02/EXP%3A+IPSDK%3A+ROM+Display/Default+Admin+View/"
T3_CQM_URL="http://sqe.t3.nat.bt.com/cqm"


#Products in the quote
BLOCKER					="xpath=.//div[@class='blockUI blockMsg blockPage']"
CBOX_ADDITIONAL_PRODUCT="xpath=.//tr[3]//input[@id='checks']"
DD_ADDITONAL_PRODUCT_ORDER_TYPE="xpath=.//tr[3]/td[3]/div[2]/select[@class='form-control ng-pristine ng-valid']"
BTN_ADD_PRODUCT_TO_QUOTE="xpath=.//button[contains(text(),'Add Product to Quote')]"
LINK_ADDITIONAL_PRODUCT_PROVIDE_CONFIGURATION="xpath=.//tr[3]//a[contains(text(),'Provide')]"
LINK_ADDITIONAL_PRODUCT_CEASE_CONFIGURATION="xpath=.//tr[3]//a[contains(text(),'Cease')]"