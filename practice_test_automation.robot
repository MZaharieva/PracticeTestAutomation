*** Settings ***
Documentation  "ABN Test Numeric Mortgage Calculation" goes through the simplest choice 
...            path of the mortgage calculator and checks whether the output is a numeric 
...            mortgage estimate.  
...            "ABN Test Valid Age Input" checks whether the calculator flow stops for 
...            invalid age input. 
...            "ABN Test Ordinal Mortgage Calculation" checks whether relative mortgate 
...            estimates are correctly assigned given employment contract modifiers 
...            - Fixed, Flexible, Self-Employed - provided that other modifiers are fixed.  

Metadata  Version  1.2

Library  Browser  auto_closing_level=SUITE  # suite shares same browser context, etc.
Library  String  # for RegEx string manipulation

# Use to optimize script readibility for collaborators with non-tech background. 
#Test Setup  Browser  #
#Suite Setup  Get Browser  # across the whole test suite 

*** Keywords ***
Open Iframe
    [Documentation]  Get Iframe URL from src and open on new page.
    [Arguments]  ${selector}
      ${iframe}=  Get Attribute  ${selector}  src  # locate src attribute by some selector
                                                   # and get content (URL)
      Log  ${iframe}
      New Page  ${iframe}  # open the URL to the iframe as new page

*** Test Cases ***
ABN Test Numeric Mortgage Calculation
  Register Keyword To Run On Failure  Take Screenshot  failure-{index}  
  ...                                 fullPage=True  # take screenshot upon failure
  New Browser  browser=firefox  headless=false  # express browser preview for debugging,
                                                # suppress for production
  New Context  viewport={'width': 1920, 'height': 1080}  # set standard display resolution
                                                         # for the browser
  Set Browser Timeout  0:00:15  # wait time for last script action to unfold  
  
  # Page 1: Start Mortgage Calculation 
  New Page  https://www.abnamro.nl/nl/prive/hypotheken/maximale-hypotheek-berekenen.html  
  Log  Page opened.  
  ${title}=  Get Title  # get title of the page opened
  Should Be Equal  ${title}  
  ...              Hypotheek berekenen in 2023 - ABN AMRO  # check whether page title
                                                           # matches expected
  Wait For Elements State  //a[@id="aab-cookie-consent-agree"]  
  ...                      visible  timeout=2 s  # wait for cookies element to appear
  Click  //a[@id="aab-cookie-consent-agree"]  # accept cookies
  Open Iframe  selector=//iframe[@id="29789"]  # open the iframe in which the calculator 
                                               # function is embedded
  
  # Page 2: Wat is uw situatie?
  Click  //button[@data-element-label="Ik heb nog geen hypotheek bij ABN AMRO"]

  # Page 3: Koopt u alleen of samen?
  Click  //img[@alt="Alleen"]
  ${url_page_3}  Get Url  # get current page URL to reuse in another test case 
  Set Suite Variable  $url_page_3  # store page URL as SUITE variable

  # Page 4: Wat is uw leeftijd?
  Type Text  //input[@id="age"]  txt="30"  delay=200 ms
  Click  //button[@class="base-btn__inner-button"]  

  # Page 5: Wat is uw werksituatie?
  ${url_page_5}  Get Url  # get current URL to reuse in another test case 
  Set Suite Variable  $url_page_5  # store URL as SUITE variable
  Click  //button[@class="base-btn__inner-button"]  # by default option, skip the dropdown
  
  # Page 6: Wat is uw bruto inkomen per jaar?
  Type Text  css=input#inputId  txt="55555"  delay=200 ms  # Playwright supports CSS for 
                                                           # shadow DOM; Xpath alternative 
                                                           # in final test. 
  Click  //button[@class="base-btn__inner-button"] 
  
  # Page 7-9: Heeft u een studieschuld? >> Heeft u leningen? >> Betaalt u alimentatie? 
  Repeat Keyword  3  Click  //span[text()="Nee"]/parent::div
  
  # Page 10: Check whether the outputted mortgage estimate is numeric
  ${mortgage_estimate}  Get Text  
  ...                 //span[@class="calculation-total__amount"]  # get the text containing
                                                                  # the mortgage estimate
  Log  ${mortgage_estimate}  
  ${mortgage_estimate}=  Remove String  
  ...                  ${mortgage_estimate}  .  # remove decimals from the string
  ${mortgage_estimate_num}=  Convert to Number  
  ...                      ${mortgage_estimate}  # convert the string to numeric
  Run Keyword If  ${mortgage_estimate_num} >= 0  
  ...             Log  Mortgage estimate is numeric.  # evaluate whether the mortgage 
                                                      # estimateis a positive number or zero
  ...         ELSE  
  ...             Fail  Mortgage estimate is not numeric.  # test fails if string could 
                                                           # not be converted to number
  Set Suite Variable  $mortgage_estimate_num_fixed  
  ...                 ${mortgage_estimate_num}  # store mortgage estimate to compare to 
                                                # output from another test
  Sleep  1 s  # wait for N seconds before closing browser preview 

ABN Test Valid Age Input
  # An alternative approach is to test whether the button is deactivated after inputing 
  # invalid age: <button disabled type="button" data-v-655a9b73="" class=…>…</button>
  New Page  ${url_page_3}  # suite variables are not stored in memory - test requires to 
                           # run the whole suite
  # Page 4: Wat is uw leeftijd?
  Type Text  //input[@id="age"]  
  ...        txt="1000"  # invalid age input
  ...        delay=200 ms
  Run Keyword And Expect Error  
  ...  TimeoutError: locator.click:*  
  ...  Click  //button[@class="base-btn__inner-button"]  # button click fails upon 
                                                           # invalid age input  

ABN Test Ordinal Mortgage Calculation: Fixed >= Flexible Contract 
  # Test: Does the mortgage estimate for Flexible contract (<2 y. employment) < Fixed?
  New Page  ${url_page_5}  # suite variables are not stored in memory - test requires to 
                           # run the whole suite

  # Page 5: Wat is uw werksituatie?
  Click  //aab-select[@class="dropdown-input__dropdown"]  # Workaround for shadow DOM using
                                                          # Xpath to open dropdown menu
  Click  text=Flexibel
  Click  //button[@class="base-btn__inner-button"] 

  # Page 6-7: Werkt u al langer dan 2 jaar? Had u in de afgelopen 3 jaar ook inkomsten bij
  # andere werkgevers?
  Repeat Keyword  2  Click  //span[text()="Nee"]/parent::div  

  # Page 8: Vul het geschatte bruto jaarinkomen in
  Type Text  css=input#inputId  txt="55555"  delay=200 ms  
  Click  //button[@class="base-btn__inner-button"] 

  # Page 9-11: Heeft u een studieschuld? >> Heeft u leningen? >> Betaalt u alimentatie? 
  Repeat Keyword  3  Click  //span[text()="Nee"]/parent::div

  # Page 11: Check whether the outputted mortgage estimate is numeric
  ${mortgage_estimate}  Get Text  
  ...                 //span[@class="calculation-total__amount"]  # get the text containing
                                                                  # the mortgage estimate
  Log  ${mortgage_estimate}  
  ${mortgage_estimate}=  Remove String  
  ...                  ${mortgage_estimate}  .  # remove decimal dots from the string
  ${mortgage_estimate_num}=  Convert to Number  
  ...                      ${mortgage_estimate}  # convert the string to numeric
  Run Keyword If  ${mortgage_estimate_num} >= 0  
  ...             Log  Mortgage estimate is numeric.  # evaluate whether mortgage estimate
                                                      # is a positive number or zero
  ...         ELSE  
  ...             Fail  Mortgage estimate is not numeric.  # test fails when the string 
                                                           # cannot be converted to number
  Set Suite Variable  $mortgage_estimate_num_flex  
  ...                 ${mortgage_estimate_num}  # store mortgage estimate to compare to 
                                              # output from another test
  Log  ${mortgage_estimate_num_fixed}  # Log mortgage estimate for "Fixed" contract for
                                       # visual comparison in robot output; variable is 
                                       # computed in "ABN Test Numeric Mortgage Calculation"
  Run Keyword If  $mortgage_estimate_num_fixed >= $mortgage_estimate_num_flex  
  ...             Log  Test PASSED - greater/equal mortgage estimate for "Fixed" compared to "Flex" contract.  
  ...         ELSE  
  ...             Fail  Test FAILED - lower mortgage estimate for "Fixed" compared to "Flex" contract.  
                        # test fails whenever Fixed contract doesn't 
                        # yield higher/equal mortgage estimate, 
                        # provided other mopdifiers fixed
  Sleep  1 s  # wait for N seconds before closing browser preview  

ABN Test Ordinal Mortgage Calculation: Fixed >= Self-Employment >= Flex Contract 
# Does the mortgage estimate of Self-Employment contract (<2 years work experience) < Fixed?
  New Page  ${url_page_5}  # suite variables are not stored in memory - test requires to 
                           # run the whole suite
  # Page 5: Wat is uw werksituatie?
  Click  //aab-select[@class="dropdown-input__dropdown"]  # Workaround for shadow DOM using
                                                          # Xpath to open dropdown menu
  Click  text=Zelfstandig
  Click  //button[@class="base-btn__inner-button"] 

  # Page 6: Hoe lang bent u al zelfstandig ondernemer?
  Click  //aab-select[@class="dropdown-input__dropdown"]  # Workaround for shadow DOM using
                                                          # Xpath to open dropdown menu
  Click  text=Tussen 1 en 2 jaar
  Click  //button[@class="base-btn__inner-button"]  

  # Page 7: Wat is uw bruto inkomen per jaar i? 
  Repeat Keyword  2  Run Keywords  
  ...  Type Text  css=input#inputId  txt="55555"  delay=200 ms  
  ...  AND  Click  //button[@class="base-btn__inner-button"] 

  # Page 8-11: Had u in de afgelopen 3 jaar ook inkomsten bij andere werkgevers? >> 
  # Heeft u een studieschuld? >> Heeft u leningen? >> Betaalt u alimentatie? 
  Repeat Keyword  4  Click  //span[text()="Nee"]/parent::div

  # Page 12: Check whether the outputted mortgage estimate is numeric
  ${mortgage_estimate}  Get Text  
  ...                   //span[@class="calculation-total__amount"]  # get the text containing
                                                                    # the mortgage estimate
  Log  ${mortgage_estimate}  
  ${mortgage_estimate}=  Remove String    
  ...                    ${mortgage_estimate}  .  # remove decimal dots from the string
  ${mortgage_estimate_num}=  Convert to Number  
  ...                        ${mortgage_estimate}  # convert the string to numeric  

  Run Keyword If  ${mortgage_estimate_num} >= 0  
  ...             Log  Mortgage estimate is numeric.  # evaluate whether mortgage estimate
                                                      # is a positive number or zero
  ...         ELSE  
  ...             Fail  Mortgage estimate is not numeric.  # test fails when the string 
                                                           # cannot be converted to number
  Set Suite Variable  $mortgage_estimate_num_self
  ...                 ${mortgage_estimate_num}  # store mortgage estimate to compare to 
                                              # output from another test
  Log Many  ${mortgage_estimate_num_fixed}  
  ...       ${mortgage_estimate_num_self}  
  ...       ${mortgage_estimate_num_flex}  # Log all mortgage estimates
  Run Keyword If  
    ...  $mortgage_estimate_num_fixed >= $mortgage_estimate_num_self >= $mortgage_estimate_num_flex 
  ...             Log  Test PASSED - greater/equal mortgage estimate for "Fixed" compared to "Flex" and "Self-employed" contract.  
  ...           ELSE  
  ...             Fail  Test FAILED - "Self-employment" contract is either not lower than "Fixed" contract, and/or not greater than "Flex" contract.  
                        # test fails whenever >= 1 comparison fails.
  Sleep  1 s  # wait for N seconds before closing browser preview  

#Try Iframe Injection Approach
# Frame punching
#  #Try Click  xpath://iframe[@id="29789"] >> css:img[alt=Alleen]
#  Register Keyword To Run On Failure  Take Screenshot  failure-{index}  fullPage=True  # take screenshot upon each failure
# # Page 1: Start Mortgage Calculation 
# New Page  https://www.abnamro.nl/nl/prive/hypotheken/maximale-hypotheek-berekenen.html
#  Log  Page opened.  
# ${title}=  Get Title  
# Should Be Equal  ${title}  Hypotheek berekenen in 2023 - ABN AMRO
# Wait For Elements State  
#  ...  //a[@id="aab-cookie-consent-agree"]  visible  
#  ...  timeout=2 s  # wait for cookies element to appear
#  Click  //a[@id="aab-cookie-consent-agree"]  # accept cookies
#  # Page 2: Wat is uw situatie?
#  Click  xpath://iframe[@id="29789"] >>> css:img[alt=Have no mortgage]  
#        # Returns Error: locator.click: Unsupported token "@id" while parsing selector "xpath://iframe[@id="29789"]"
#  Sleep  5 s