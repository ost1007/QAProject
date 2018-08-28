#Select BT Customer
DD_SALES_CHANNEL="xpath=.//a[@class='btn btn3d menu']"
DD_CUSTOMER="arid_WIN_0_536870989"

#Verify Customer Existance
BTN_CREATE_CUSTOMER="WIN_0_536870910"
IFRAME="xpath=.//iframe[contains(@id,'P')]"
BTN_X="ardivcl"

#Go to Quote tab
TAB_QUOTE_DETAILS="xpath=.//*[@id='WIN_0_536870913']/div[2]/div[2]/div/dl/dd[3]/span[2]/a"

#Search and Select Quotation
TAB_SEARCH_QUOTE="xpath=.//*[@id='WIN_0_536880963']/div[2]/div[2]/div/dl/dd[2]/span[2]/a"

#Product Configuration
IMG_LOADING							="xpath=.//*[@id='creating-product-spinner']"
DD_DIRECT_CONNECT_SERVICE_PROVIDER	="xpath=.//select[@title='Mandatory']"
LINK_BASE_CONFIGURATION				="xpath=.//li[*]/div/div/span[@title='Base Configuration']"
BOX_INTERCONNECT_LOCATION			="xpath=.//div[@rel='INTERCONNECT LOCATION']/div[2]"
DD_INTERCONNECT_LOCATION			="xpath=.//div[@rel='INTERCONNECT LOCATION']/div[3]/select"
LINK_PROVIDER_CONNECTION			="xpath=.//li[*]/div/div/span[@title='Provider Connection']"
LINK_PROV_CONN_BASE_CONF			="xpath=.//ul[not(contains(@style,'none'))]/../span[@title='Base Configuration']"
TXT_SUMMARY							="xpath=.//div[@rel='summary']/div[2]"
STATUS_LOADING						="xpath=.//*[@id='statusBarModal']"
BOX_BANDWIDTH						="xpath=.//div[@rel='BANDWIDTH']/div[2]"
DD_BANDWIDTH						="xpath=.//div[@rel='BANDWIDTH']/div[3]/select"
LINK_VPN_SPEC						="xpath=.//li[*]/div/div/span[@title='VPN Specification']"
CONFIGURE							="xpath=.//div[2]/a[contains(text(),'Configure')]"
CONFIGURE_ALL						="xpath=(.//a[text()='Configure All'])"
LINK_TO_EXISTING					="choosable_rel_ctnr"
BTN_ADD								="xpath=.//button[@ng-click='addRelations()'][contains(text(),'Add')]"
BTN_OK								="xpath=.//div[@class='relationship-dialog ui-dialog-content ui-widget-content ui-resizable']/div[1]/div[2]/div/button[contains(text(),'Ok')]"
LINK_QUOTE_OPT_DETAILS				="xpath=.//*[@id='quoteOption']"
BTN_OK_RFO							="xpath=.//div[@role='dialog'][not(contains(@style,'display: none'))]//button"
STATUS_SUBMITTED					="xpath=.//*[text()='Submitted']"