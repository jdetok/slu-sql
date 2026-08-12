- 001272417
    - not admitted since 202410

- 001345515
    - 202610

- 001153065
    - 202310

- 001362077
    - if RORPRST_XHS is null for continuing student, default to on or off campus? 

- 001460652
    - higher than normal

- 001489613 - slightly higher
    - student has a SP app for BA and FR for SE - both admitted sig dec but no deposit
    - getting both fees currently, should fix itself once they get a sgastdn record

## lower than expected
- 001492224
    - is it ever possible for a madrid student to not have an attribute
    - student has SPDE attr in PROD but NOT in TEST
- 001491714
    - can madrid students have business tech fee?
- 001439853
    - has admissions app not dep for spring, but valid for fall. components not being added due to the spring app

## likely reviews
- 001412867 -- good, assigned WITHDR tracking
- 001426152 -- same
- 001474212 -- same

a few questions about some edge cases we found: 
- will a madrid direct admit ever NOT have an attribute? 
    - 001492224 fails in test because they don't have SPDE attribute, but they do have the attribute in prod
- can madrid student for BA have the business software fee? 
- 001489613 has two apps, both admitted not deposited. one FR BA, one SP SE
    - currently they're getting both the business software and SSE fee
    - once they have sgastdn they'll only have one or the other
    - do we need to change anything for how they're currently being budgeted? 
- 001439853 the weirdest one
    - has a valid UG 202710 app, budgeting for 202710 no problem
    - but they also have a 202720 app that isn't deposited, which is preventing components being added in spring
    - again, should be resolved once sgastdn record exists
    - we know the fix if it's necessary, but it would take a lot of work because we'd have to add a few lines in basically every sequence for every component

-- 

Good morning Anish and Gubendraraj! I have a few insert scripts I need to be run into prod, are either of you able to do that? Saravanan has been running these scripts and testing with me all week but I haven't been able to get in touch with him this morning. The scripts are just inserting some work we've done in TEST into PROD for the period budgeting process, which Janice needs in prod today. None of the effected tables are currently being used by any processes. If I send my scripts here can one of you run them for me and let me know if any errors occur?