## General Info
Aim: Practice tutorials to use Robot Framework for web automation. 

## Test Questions & Answers: 
1) Primary test: When going through the simplest choice path of the [ABN mortgage calculator](https://www.abnamro.nl/nl/prive/hypotheken/maximale-hypotheek-berekenen.html), does the calculator output a numeric calculation for mortgage? 
   - Yes, see Report for ABN Test Numeric Mortgage Calculation.
2) Additional tests: 
   - Does the calculator correctly assign relative mortgate values given certain modifiers? 
      - The mortgage estimate given same annual income is as follows: Fixed contract >= Self-Employment (1-2 years) >= Flexible contract (<2 year)
   -  Does the calculator flow stop if invalid age is inputed? 
      - Yes, see ABN Test Valid Age Input.
   - Etc. 

## To-do:
- [x] Setup Python virtual environment with [poetry](https://michaelcurrin.github.io/dev-cheatsheets/cheatsheets/package-managers/python/poetry.html)
- [x] Re-install robotframework-browser & [Playwright](https://playwright.dev/docs/intro)
- [x] Test Q.1
- [x] Test Q.2a
- [x] Test Q.2b
- [x] Push v.1.0+ to Github repository 
- [ ] Wrap repetitive code into functions
- [ ] Search for example test flow for decision trees (e.g., from dropdown menus)
- [x] Look up a professional report for style & adapt the current script accordingly 
- [x] Check documentation content guide
- [x] Check whether there is a built-in function to repeat keyword sequences

## Resources: 
- [Quick Start in RobotFramework](https://github.com/robotframework/QuickStartGuide/blob/master/QuickStart.rst)
- [RobotFramework Documentation](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#installing-using-pip)
- [RobotFramework browser documentation](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [RobotFramework built-in documentation](https://robotframework.org/robotframework/6.0.2/libraries/BuiltIn.html?_ga=2.223392667.1631393726.1683372460-868379529.1683372460#library-documentation-top)
- [Articles on Test Automation](https://testersdock.com/)
- [XPath, CSS, HTML Syntax](https://www.w3schools.com/xml/xpath_syntax.asp#gsc.tab=0)
- [XPath vs. CSS selectors](https://www.scrapingbee.com/blog/xpath-vs-css-selector/)
- [Robot Framework (Roboco[r]p) style guide](https://github.com/MarketSquare/robotframework-robocop)
- [Robocorp Automation Stack](https://github.com/robocorp/rcc)
- [Documenting Workflow tests and Data-Driven tests](https://github.com/robotframework/HowToWriteGoodTestCases/blob/master/HowToWriteGoodTestCases.rst)


# Notes & General Tips for Web Test Automation

## Handling Risk Mitigation 

The primary goal of test automation is to mitigate risk for the client. Thus, every 
project starts off with mapping out the core functionality of an application, as well as 
what makes sense to automate in the first place. Following, priority weights are assigned 
to each core functionality based on several criteria, e.g., impact, failure, testibility, 
priority, etc. Finally, core functionality gets assigned to risk categories - low, mid, 
high - based on average weigthed scores. This serves as basis to devise an overall
strategy in terms of the actions that need to be undertaken to mitigate the desired % risk. 

To make sure that you dedicate efforts towards relevant end goals, it makes sense 
to iteratively touch base with clients, testers, etc. to reach agreement regarding 
priorities and communicate the general risk mitigation strategy.  

## Keeping Test Automation Projects Overseeable for Oneself and for Collaboration

In real-world projects, the Keyword section is kept apart. For own convenience and 
global overview, it is recommended to create custom keywords when the test flow 
requires parameters or when repetition of action sequences is encountered. 
 
Keywords also allow you to create an overseeable test flow for testers and other project
collaborators with minimal technical expertise. For instance, it is handy if testers
could assess parts of the application by filling out relevant parameters, without 
necessarily having to go into the technical details dealing with the behavior of the 
application. Clear documentation practices are key here too; e.g., describing the purpose 
of actions in the test sequence such that testers can understand the coupling between an 
action and specific elements searched on a webpage. Similarly, the Settings section can be 
used to take out redundancies and complexities from the Keyword section; e.g., that a 
browser is being started.

## Setting Up Collaborative Workflows

To ensure that you focus on working on the right project aspects and versions, it makes 
sense to keep a close, regular feedback loop with developers, testers, among others, and
explore ways to help each other get stuff done. As test automation engineer, you have 
considerable autonomy in setting up such collaborations! 

## Other Tips for Test Automation: 
- Aim to automate tests with reference to unique and stationary properties of the webpage. 
  E.g., Layout stays rather stable, process flow is more likely to change in terms of 
  action steps or behavior-input contingencies. 
- When installing new packages >> RESTART VS Code project 
- Use Mozilla Firefox for webpage automation 
- When test automation projects scale up, keep Test Cases and Keywords apart 
- Check out adding roadmaps to projects (i.e., longer-term project planning)
- For webpage automation, use Playwright within Robot Framework [stable alternative to Selenium]
- To locate an element within iframes, you need to search the element within the iframe (i.e., iframe punch-through)
- XML - user-defined tags; HTML - universal for building webpages
- Use CSS or XPath to query XML/HTML (can be also done via the web element inspector)
- CSS - most commonly used, less verbose, but excludes content
- XPath - great for searching tag content, handles hierarchy (parent, child, sibling, etc.); 
  //input[@id = "username"], where input is the tag name, [] defines a set of criteria, and @id = "username" specifies some attribute
- Avoid searching tags in the whole document via / 
- Could combine / and // expressions to allocate tags (but should be avoided) 
- Shadow DOM >> Handle with CSS rather than XPath in Playwright

## Learning trajectory: 
- CSS/Xpath
- HTML (+ understand webpage development)
- Improve Python (for custom functions in Robot Framework)
- Improve RegEx (for more precise text search)
