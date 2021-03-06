#Product Configuration
IMG_LOADING								= "xpath=.//*[@id='creating-product-spinner']"
DD_DIRECT_CONNECT_SERVICE_PROVIDER		= "xpath=.//select[@title='Mandatory']"
LINK_BASE_CONFIGURATION					= "xpath=.//li[*]/div/div/span[@title='Base Configuration']"
BOX_INTERCONNECT_LOCATION				= "xpath=.//div[@rel='INTERCONNECT LOCATION']/div[2]"
DD_INTERCONNECT_LOCATION				= "xpath=.//div[@rel='INTERCONNECT LOCATION']/div[3]/select"
LINK_CCD								= "xpath=.//span[contains(text(),'Cloud Connect Direct')]"
LINK_CFS								= "xpath=.//span[contains(text(),'Cloud Firewall Services')]"
LINK_CAS								= "xpath=.//i/../span[contains(text(),'Cloud Acceleration Service')]"
LINK_PROVIDER_CONNECTION				= "xpath=.//li[*]/div/div/span[@title='Provider Connection']"
LINK_PROV_CONN_BASE_CONF				= "xpath=.//ul[not(contains(@style,'none'))]/../span[@title='Base Configuration']"
LINK_MS_EXP_BASE_CONF					= "xpath=.//ul[not(contains(@style,'none'))]/../span[@title='Base Configuration']"
#LINK_MS_EXP_NAT						= "xpath=.//li[*]/div/i[contains(@class,'NOT_PRICED')]/../div/div/div/span[@title='NAT']"
LINK_MS_EXP_NAT							= "xpath=.//span[@title='MS Express Route Service Connection']/..//span[@title='NAT']"
LINK_MS_EXP_ROUTE_SVCONN				= "xpath=.//li[*]/div/div/span[@title='MS Express Route Service Connection']"
LINK_MS_EXP_CUS_ADD_SPACE				= "xpath=(.//li[*]/div/div/div/div/span[@title='Customer Address Space'])[last()]"
TXT_SUMMARY								= "xpath=.//div[@rel='summary']/div[2]"
STATUS_LOADING							= "xpath=.//*[@id='statusBarModal']"
BOX_BANDWIDTH							= "xpath=.//div[@rel='BANDWIDTH']/div[2]"
DD_BANDWIDTH							= "xpath=.//div[@rel='BANDWIDTH']/div[3]/select"
BOX_CONN_TYPE							= "xpath=.//div[@rel='CONNECTION TYPE']/div[2]"
DD_CONN_TYPE							= "xpath=.//div[@rel='CONNECTION TYPE']/div[3]/select"
BOX_AF									= "xpath=.//div[@rel='EF BANDWIDTH']/div[2]"
BOX_DE									= "xpath=.//div[@rel='AF BANDWIDTH']/div[2]"
DD_AF									= "xpath=.//div[@rel='EF BANDWIDTH']/div[3]/select"
DD_DE									= "xpath=.//div[@rel='AF BANDWIDTH']/div[3]/select"
LINK_NAT								= "xpath=.//li[*]/div/div/span[@title='NAT']"
LINK_CUSTOMER_ADD_SPACE					= "xpath=.//li[*]/div/div/span[@title='Customer Address Space']"
LINK_VPN_SPEC							= "xpath=.//li[*]/div/div/span[@title='VPN Specification']"
LINK_CLOUD_FW_SERVICE					= "xpath=.//li[*]/div/div/span[@title='Cloud Firewall Service']"
LINK_CLOUD_ACC_SERVICE					= "xpath=.//li[*]/div/div/span[@title='Cloud Acceleration Service']"
LINK_CLOUD_SERVICE_LEG					= "xpath=.//li[*]/div/div/span[@title='Cloud Service Leg']"
LINK_CSL_FW_SERVICE						= "xpath=.//li[*]/div/div/div/div/span[@title='Firewall Service']"
LINK_CSL_ACC_SERVICE					= "xpath=.//li[*]/div/div/div/div/span[@title='Acceleration Service']"
LINK_FW_SERVICE							= "xpath=.//li[*]/div/div/span[@title='Firewall Service']"
BOX_POLICY_CHANGE_MANAGEMENT_TYPE		= "xpath=.//div[@rel='POLICY CHANGE MANAGEMENT TYPE']/div[2]"
DD_POLICY_CHANGE_MANAGEMENT_TYPE		= "xpath=.//div[@rel='POLICY CHANGE MANAGEMENT TYPE']/div[3]/select"
BOX_MY_ACCOUNT_PORTAL_DCF_LINK			= "xpath=.//div[@rel='MY ACCOUNT PORTAL DCF LINK']/div[2]"
INPUT_MY_ACCOUNT_PORTAL_DCF_LINK		= "xpath=.//div[@rel='MY ACCOUNT PORTAL DCF LINK']/div[3]/input"
LINK_ACC_SERVICE						= "xpath=.//li[*]/div/div/span[@title='Acceleration Service']"
CONFIGURE								= "xpath=.//div[2]/a[contains(text(),'Configure')]"
CONFIGURE_ALL							= "xpath=(.//a[text()='Configure All'])"
LINK_TO_NEW								= "xpath=.//div[not(@class='pane')]/select[@id='creatable_rel_ctnr']"
LINK_TO_EXISTING						= "choosable_rel_ctnr"
BTN_ADD									= "xpath=.//button[@ng-click='addRelations()'][contains(text(),'Add')]"
BTN_OK									= "xpath=.//div[@class='relationship-dialog ui-dialog-content ui-widget-content ui-resizable']/div[1]/div[2]/div/button[contains(text(),'Ok')]"
LINK_QUOTE_OPT_DETAILS					= "xpath=.//*[@id='quoteOption']"
BTN_OK_RFO								= "xpath=.//div[@role='dialog'][not(contains(@style,'display: none'))]//button"
UPLOAD_SUCCESSFUL						= "xpath=.//*[text()='Upload Successful']"
STATUS_SUBMITTED						= "xpath=.//*[text()='Submitted']"

#Routing Advertisement with NAT
ROUTING_ADVERT_WITH_NAT_TAB							="xpath=.//a/span[contains(text(),'Routing Advertisement with NAT')]"
ROUTING_ADVERT_WITH_NAT_BASE_CONFIG					="xpath=.//a/span[contains(text(),'Routing Advertisement with NAT')]/../../..//span[@title='Base Configuration']"
ROUTING_ADVERT_WITH_NAT_CUST_NAT_IP_LABEL			="xpath=html/body/div[1]/div[3]/div[1]/div[5]/div[3]/div[1]/div[4]/table/tbody/tr[1]/td[7]/div/div[2]"
ROUTING_ADVERT_WITH_NAT_CUST_NAT_IP_LABEL_INPUT_TEXT="xpath=html/body/div[1]/div[3]/div[1]/div[5]/div[3]/div[1]/div[4]/table/tbody/tr[1]/td[7]/div/div[3]/input"
ROUTING_ADVERT_WITH_NAT_NAT_IP_LABEL				="xpath=//div[@id='grid-contents']/table/tbody/tr[1]/td[8]/div/div[2]"
MS_EXP_ROUTE_SVC_CONN_CUST_ADD_SPACE_WITH_IP_LABEL	="//div[@id='grid-contents']/table/tbody/tr[1]/td[6]/div/div[2]/a"

#Cutomer Address Space Tab 
CUST_ADD_SPACE_TAB						="xpath=.//a/span[contains(text(),'Customer Address Space')]"
#CUST_ADD_SPACE_BASE_CONFIG				="xpath=(.//li[*]/div/div/span[contains (text(),'Base Configuration')])"
CUST_ADD_SPACE_BASE_CONFIG				="xpath=.//a/span[contains(text(),'Customer Address Space')]/../../..//span[@title='Base Configuration']"
CUST_ADD_SPACE_NAT_IP_LABEL				="xpath=.//div[@id='grid-contents']/table/tbody/tr[1]/td[7]/div/div[2]"
ROUTING_ADVERT_WITH_NAT					="xpath=.//span[@title='Routing Advertisement with NAT']"
NAT_IP_ADDRESS_RA_BT_PROVIDED			="xpath=.//*[@id='creatable_rel_ctnr']/option"
LINK_TO_EXISTING_NAT_IP					="xpath=.//select[@id='choosable_rel_ctnr']/option[1]"

#Cloud Acceleration Service Tab
ADD_SUCCESS_LOADING						= "xpath=html/body/div[1]/div[3]/div[1]/div[5]/div[3]/div[2]/div[2]/p"
LINK_TO_EXISTING_LOADING				= "choosable_rel_spinner"
PRIMARY_ACC_SVC							= "xpath=.//div[@id='grid-contents']/table/tbody/tr[1]/td[6]/div/div[2]/a"
SEC_ACC_SVC								= "xpath=.//div[@id='grid-contents']/table/tbody/tr[1]/td[7]/div/div[2]/a"
PRIMARY_ACC_SVC_CONFIG_ALL				= "xpath=//div[@id='grid-contents']/table/thead/tr/th[6]/div/div/a[contains(text(),'Configure All')]"
SECONDARY_ACC_SVC_CONFIG_ALL			= "xpath=//div[@id='grid-contents']/table/thead/tr/th[7]/div/div/a[contains(text(),'Configure All')]"
ACC_SVC_LINK_TO_EXISTING				= "xpath=.//*[@id='choosable_rel_ctnr']/option"
BOX_BT_MANAGED_DEVICE					= "xpath=.//div[@rel='BT MANAGED DEVICE']/div[2]"
DD_BT_MANAGED_DEVICE					= "xpath=.//div[@rel='BT MANAGED DEVICE']/div[3]/select"

#AIB
PRODUCT_NAME							= "xpath=.//tr[2]/td[2]/div"

#Internet Gateway Tab
IG_BASE_CONFIG							= "xpath=(.//a/span[contains(text(),'Internet Gateway')]/../../..//span[@title='Base Configuration'])[1]"
IG_TAB									= "xpath=.//a/span[contains(text(),'Internet Gateway')]"
BOX_GATEWAY_LOCATION					= "xpath=.//div[@rel='GATEWAY LOCATION']/div[2]"
DD_GATEWAY_LOCATION						= "xpath=.//div[@rel='GATEWAY LOCATION']/div[3]/select"

#IG Cloud Firewall Services Tab
LINK_USER								= "xpath=.//span[@title='User']"
USER_BASE_CONFIG						= "xpath=(.//a/span[contains(text(),'Cloud Firewall Services')]/../../..//span[@title='Base Configuration'])[2]"
BOX_USER_EMAIL_ID						= "xpath=.//div[@rel='USER EMAIL ID']/div[2]"
INPUT_USER_EMAIL_ID						= "xpath=.//div[@rel='USER EMAIL ID']/div[3]/input"
