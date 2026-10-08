# Alt Loan Automation discovery
- .SP2 Response files – The  .SP2  file  contains  @1C  certification  request  Response  file  records  from  
lenders.
- Header rows start with @H, trailer with @T

## NCHER file layouts/documentation website
https://ncher.org/initiatives/commonline/#74-126-commonline-r4-r5-docs

## Header record layout
| Field | Field Name | Required Field | Start Position | Length | Data Type | Justify | Padding |
|------:|------------|:--------------:|---------------:|-------:|-----------|---------|---------|
| 1 | Record Code | R | 1 | 2 | X(002) | | |
| 2 | Software Product Code | O | 3 | 4 | X(004) | Left | Spaces |
| 3 | Software Version | O | 7 | 4 | X(004) | Left | Spaces |
| 4 | Batch ID | O | 11 | 12 | X(012) | Left | Spaces |
| 5 | File Creation Date (CCYYMMDD) | R | 23 | 8 | 9(008) | | |
| 6 | File Creation Time (HHMMSS) | O | 31 | 6 | 9(006) | | |
| 7 | File Transmission Date (CCYYMMDD) | R | 37 | 8 | 9(008) | | |
| 8 | File Transmission Time (HHMMSS) | O | 45 | 6 | 9(006) | | |
| 9 | File Identifier Name | R | 51 | 19 | X(019) | Left | Spaces |
| 10 | File Identifier Code | R | 70 | 5 | X(005) | | |
| 11 | Recipient Name | R | 75 | 32 | X(032) | Left | Spaces |
| 12 | Recipient ID | R | 107 | 8 | X(008) | Left | Spaces |
| 13 | Filler² | — | 115 | 2 | X(002) | | |
| 14 | Recipient Non-ED Branch ID | R¹ | 117 | 4 | X(004) | Left | Spaces |
| 15 | Recipient Type Code | R | 121 | 1 | X(001) | | |
| 16 | Source Name | R | 122 | 32 | X(032) | Left | Spaces |
| 17 | Source ID | R | 154 | 8 | X(008) | Left | Spaces |
| 18 | Filler² | — | 162 | 2 | X(002) | | |
| 19 | Source Non-ED Branch ID | R¹ | 164 | 4 | X(004) | Left | Spaces |
| 20 | Media Type Code | R | 168 | 1 | X(001) | | |
| 21 | DUNS Recipient ID | O | 169 | 9 | X(009) | | |
| 22 | DUNS Source ID | O | 178 | 9 | X(009) | | |
| 23 | Filler | — | 187 | 853 | X(853) | | |
| 24 | Record Terminator | R | 1040 | 1 | X(001) | | |

## Detail record layout (@1)
| Field | Field Name | Required (M and R Records) | Required (All Other Records) | Start Position | Length | Data Type | Justify | Padding | SCR Use |
|------:|------------|:--------------------------:|:----------------------------:|---------------:|-------:|-----------|---------|---------|:-------:|
| 1 | Record Code | R | R | 1 | 2 | X(002) | | | R |
| 2 | Record Status Code | R | R | 3 | 1 | X(001) | | | R |
| 3 | Date Record Status Last Updated (CCYYMMDD) | R | R | 4 | 8 | 9(008) | | | O |
| 4 | Borrower Last Name | R | R | 12 | 35 | X(035) | Left | Spaces | R |
| 5 | Borrower First Name | R | R | 47 | 12 | X(012) | Left | Spaces | R |
| 6 | Borrower Middle Initial | R¹ | R¹ | 59 | 1 | X(001) | | | R¹ |
| 7 | Borrower SSN | R | R | 60 | 9 | 9(009) | | | R |
| 8 | Permanent Borrower Address (line 1) | R | R | 69 | 30 | X(030) | Left | Spaces | R |
| 9 | Permanent Borrower Address (line 2) | R¹ | R¹ | 99 | 30 | X(030) | Left | Spaces | R¹ |
| 10 | Permanent Borrower City | R | R | 129 | 24 | X(024) | Left | Spaces | R |
| 11 | Filler² | — | — | 153 | 6 | X(006) | | | - |
| 12 | Permanent Borrower State | R | R | 159 | 2 | X(002) | | | R |
| 13 | Permanent Borrower Zip Code | R¹ | R¹ | 161 | 5 | 9(005) | | | R¹ |
| 14 | Permanent Borrower Zip Code Suffix | R¹ | R¹ | 166 | 4 | 9(004) | | | R¹ |
| 15 | Borrower Telephone Number | R¹ | R¹ | 170 | 10 | X(010) | * | * | R¹ |
| 16 | Borrower Date of Birth (CCYYMMDD) | R¹ | R¹ | 180 | 8 | 9(008) | | | R |
| 17 | Loan Type Code | R | R¹ | 188 | 2 | X(002) | | | R¹ |
| 18 | Requested Loan Amount | R¹ | R¹ | 190 | 6 | 9(006) | Right | Zeros | R¹ |
| 19 | Deferment Request Code | R¹ | R¹ | 196 | 1 | X(001) | | | - |
| 20 | Borrower Interest Indicator | O⁴ | R¹ | 197 | 1 | X(001) | | | R¹ |
| 21 | EFT Authorization Code | R¹ | R¹ | 198 | 1 | X(001) | | | R¹ |
| 22 | Borrower Signature Code | R¹ | R¹ | 199 | 1 | X(001) | | | R¹ |
| 23 | Borrower Signature Date (CCYYMMDD) | R¹ | R¹ | 200 | 8 | 9(008) | | | R¹ |
| 24 | CommonLine Unique Identifier | R | R | 208 | 17 | X(017) | | | R |
| 25 | CommonLine Loan Sequence Number | R | R¹ | 225 | 2 | 9(002) | | | - |
| 26 | Filler² | — | — | 227 | 1 | X(001) | | | - |
| 27 | PLUS/Alternative Borrower U.S. Citizenship Status Code | O⁴ | R¹ | 228 | 1 | X(001) | | | R¹ |
| 28 | PLUS Borrower State of Legal Residence | O⁴ | R¹ | 229 | 2 | X(002) | | | - |
| 29 | PLUS Borrower State Resident Since Date (CCYYMM) | O⁴ | R¹ | 231 | 6 | 9(006) | | | - |
| 30 | PLUS/Alternative Borrower Default/Refund Code | O | R¹ | 237 | 1 | X(001) | | | R¹ |
| 31 | PLUS Borrower Outstanding Loans Code | O⁴ | R¹ | 238 | 1 | X(001) | | | - |
| 32 | Alternative Student/Borrower Indicator Code | R¹ | R¹ | 239 | 1 | X(001) | | | R¹ |
| 33 | PLUS/Alternative Borrower Alien Registration Number | O | O | 240 | 19 | X(019) | Left | Spaces | O |
| 34 | PLUS/Alternative Student Last Name | R¹ | R¹ | 259 | 35 | X(035) | Left | Spaces | R¹ |
| 35 | PLUS/Alternative Student First Name | R¹ | R¹ | 294 | 12 | X(012) | Left | Spaces | R¹ |
| 36 | PLUS/Alternative Student Middle Initial | R¹ | R¹ | 306 | 1 | X(001) | | | R¹ |
| 37 | PLUS/Alternative Student SSN | R¹ | R¹ | 307 | 9 | 9(009) | | | R¹ |
| 38 | PLUS/Alternative Student Date of Birth (CCYYMMDD) | O⁴ | R¹ | 316 | 8 | 9(008) | | | R¹ |
| 39 | PLUS/Alternative Student U.S. Citizenship Status Code | O⁴ | R¹ | 324 | 1 | X(001) | | | R¹ |
| 40 | PLUS/Alternative Student Default/Refund Code | R¹ | R¹ | 325 | 1 | X(001) | | | R¹ |
| 41 | PLUS/Alternative Student Signature Code | O | R¹ | 326 | 1 | X(001) | | | R¹ |
| 42 | Servicer Code | R¹ | R¹ | 327 | 8 | X(008) | Left | Spaces | - |
| 42a | Filler² | — | — | 335 | 12 | X(012) | | | - |
| 43 | School ID | R | R | 347 | 8 | 9(008) | | | R |
| 44a | Borrower Self Certification Code | R¹ | R¹ | 355 | 1 | X(001) | | | R¹ |
| 44b | Filler² | — | — | 356 | 1 | X(001) | | | - |
| 45 | Loan Period Begin Date (CCYYMMDD) | R¹ | R¹ | 357 | 8 | 9(008) | | | R¹ |
| 46 | Loan Period End Date (CCYYMMDD) | R¹ | R¹ | 365 | 8 | 9(008) | | | R¹ |
| 47 | Grade Level Code | R | R | 373 | 1 | X(001) | | | - |
| 48 | Borrower Electronic Signature Indicator Code | R¹ | R¹ | 374 | 1 | X(001) | | | R¹ |
| 49 | Enrollment Status Code | O | R | 375 | 1 | X(001) | | | - |
| 50 | Anticipated Completion Date (CCYYMMDD) | R | R | 376 | 8 | 9(008) | | | - |
| 51 | Cost of Attendance | O⁴ | O⁴ | 384 | 5 | 9(005) | Right | Zeros | - |
| 52 | Student Aid Index | O⁴ | O⁴ | 389 | 5 | X(005)⁵ | Right | Zeros | - |
| 53 | Other Financial Assistance Amount | O⁴ | O⁴ | 394 | 5 | 9(005) | Right | Zeros | - |
| 54 | Subsidized Federal Stafford Certified Amount | O⁴ | R¹ | 399 | 5 | 9(005) | Right | Zeros | - |
| 55 | Unsubsidized Federal Stafford Certified Amount | O⁴ | R¹ | 404 | 5 | 9(005) | Right | Zeros | - |
| 56 | Federal PLUS Certified Amount | O⁴ | R¹ | 409 | 5 | 9(005) | Right | Zeros | - |
| 57 | School Certification Date (CCYYMMDD) | O | R | 414 | 8 | 9(008) | | | - |
| 58 | Adjustment Cutoff Date | R¹ | R¹ | 422 | 8 | X(008) | | | - |
| 59 | Anticipated PUT Date | R¹ | R¹ | 430 | 8 | X(008) | | | - |
| 60 | Alternative Loan Certified Amount | O³ | R¹ | 438 | 5 | 9(005) | Right | Zeros | - |
| 61 | Alternative Loan Application Version Code | R¹ | R¹ | 443 | 4 | 9(004) | | | R¹ |
| 62 | School Designated Branch/Division Code | R¹ | R¹ | 447 | 2 | X(002) | | | R¹ |
| 63 | E-Signature Source Type Code | R¹ | R¹ | 449 | 9 | X(009) | | | R¹ |
| 64 | Lender ID | R | R | 458 | 6 | X(006) | | | R |
| 65 | Subsidized Federal Stafford Approved Amount | S³ | S³ | 464 | 5 | 9(005) | Right | Zeros | O |
| 66 | Unsubsidized Federal Stafford Approved Amount | S³ | S³ | 469 | 5 | 9(005) | Right | Zeros | O |
| 67 | Federal PLUS Approved Amount | S³ | S³ | 474 | 5 | 9(005) | Right | Zeros | O |
| 68 | Lender Approved/Denied Date (CCYYMMDD) | S³ | S³ | 479 | 8 | 9(008) | | | O |
| 69 | Lender Approved/Denied Code | S³ | S³ | 487 | 1 | X(001) | | | O |
| 70 | Alternative Loan Approved Amount | S³ | S³ | 488 | 5 | 9(005) | Right | Zeros | O |
| 71 | DUNS Lender ID | O | O | 493 | 9 | X(009) | | | - |
| 72 | Filler² | — | — | 502 | 5 | X(005) | | | - |
| 73 | Guarantor ID | R | R | 507 | 3 | X(003) | | | R¹ |
| 74 | Federal Application Form Code | R¹ | R¹ | 510 | 1 | X(001) | | | R¹ |
| 75 | DUNS Guarantor ID | O | O | 511 | 9 | X(009) | | | - |
| 76a | Filler² | — | — | 520 | 2 | X(002) | | | - |
| 76b | Lender Blanket Guarantee Indicator Code | O | R¹ | 522 | 1 | X(001) | | | - |
| 76c | Lender Blanket Guarantee Approval Date | O | O | 523 | 8 | X(008) | | | - |
| 77 | Guarantee Adjustment Indicator Code | O | R¹ | 531 | 1 | X(001) | | | - |
| 78 | Filler² | — | — | 532 | 4 | X(004) | | | - |
| 79 | Disbursement Date 1 (CCYYMMDD) | R¹ | R¹ | 536 | 8 | 9(008) | | | O |
| 80 | Disbursement Amount 1 | R¹ | R¹ | 544 | 7 | 9(005)V99 | Right | Zeros | - |
| 81 | Origination Fee 1 | R¹ | R¹ | 551 | 7 | 9(005)V99 | Right | Zeros | - |
| 82 | Guarantee/Federal Default Fee 1 | R¹ | R¹ | 558 | 7 | 9(005)V99 | Right | Zeros | - |
| 83 | Net Disbursement Amount 1 | R¹ | R¹ | 565 | 7 | 9(005)V99 | Right | Zeros | - |
| 84 | Disbursement Date 2 (CCYYMMDD) | R¹ | R¹ | 572 | 8 | 9(008) | | | O |
| 85 | Disbursement Amount 2 | R¹ | R¹ | 580 | 7 | 9(005)V99 | Right | Zeros | - |
| 86 | Origination Fee 2 | R¹ | R¹ | 587 | 7 | 9(005)V99 | Right | Zeros | - |
| 87 | Guarantee/Federal Default Fee 2 | R¹ | R¹ | 594 | 7 | 9(005)V99 | Right | Zeros | - |
| 88 | Net Disbursement Amount 2 | R¹ | R¹ | 601 | 7 | 9(005)V99 | Right | Zeros | - |
| 89 | Disbursement Date 3 (CCYYMMDD) | R¹ | R¹ | 608 | 8 | 9(008) | | | O |
| 90 | Disbursement Amount 3 | R¹ | R¹ | 616 | 7 | 9(005)V99 | Right | Zeros | - |
| 91 | Origination Fee 3 | R¹ | R¹ | 623 | 7 | 9(005)V99 | Right | Zeros | - |
| 92 | Guarantee/Federal Default Fee 3 | R¹ | R¹ | 630 | 7 | 9(005)V99 | Right | Zeros | - |
| 93 | Net Disbursement Amount 3 | R¹ | R¹ | 637 | 7 | 9(005)V99 | Right | Zeros | - |
| 94 | Disbursement Date 4 (CCYYMMDD) | R¹ | R¹ | 644 | 8 | 9(008) | | | O |
| 95 | Disbursement Amount 4 | R¹ | R¹ | 652 | 7 | 9(005)V99 | Right | Zeros | - |
| 96 | Origination Fee 4 | R¹ | R¹ | 659 | 7 | 9(005)V99 | Right | Zeros | - |
| 97 | Guarantee/Federal Default Fee 4 | R¹ | R¹ | 666 | 7 | 9(005)V99 | Right | Zeros | - |
| 98 | Net Disbursement Amount 4 | R¹ | R¹ | 673 | 7 | 9(005)V99 | Right | Zeros | - |
| 99 | Guarantee Date (CCYYMMDD) | R | R¹ | 680 | 8 | 9(008) | | | - |
| 100 | Guarantee Amount | R¹ | R¹ | 688 | 5 | 9(005) | Right | Zeros | - |
| 101 | Serial Loan Code | O | R¹ | 693 | 1 | X(001) | | | - |
| 102 | MPN Confirmation Code | O | R¹ | 694 | 1 | X(001) | | | - |
| 103 | Borrower Confirmation Indicator | R¹ | R¹ | 695 | 1 | X(001) | | | - |
| 104 | Origination Fees Paid 1 | R¹ | R¹ | 696 | 5 | 9(003)V99 | | | - |
| 104a | Guarantee/Federal Default Fees Paid 1 | R¹ | R¹ | 701 | 5 | 9(003)V99 | | | - |
| 104b | Direct Disbursement to Borrower Indicator 1 | R¹ | R¹ | 706 | 1 | X(001) | | | - |
| 104c | Direct Disbursement to Borrower Indicator 2 | R¹ | R¹ | 707 | 1 | X(001) | | | - |
| 104d | Direct Disbursement to Borrower Indicator 3 | R¹ | R¹ | 708 | 1 | X(001) | | | - |
| 104e | Direct Disbursement to Borrower Indicator 4 | R¹ | R¹ | 709 | 1 | X(001) | | | - |
| 104f | Filler | — | — | 710 | 5 | X(005) | | | - |
| 105 | Borrower Driver's License State | S | R¹ | 715 | 2 | X(002) | | | R¹ |
| 106 | Borrower Driver's License Number | S | R¹ | 717 | 20 | X(020) | Left | Spaces | R¹ |
| 107 | Borrower References Code | R¹ | R¹ | 737 | 1 | X(001) | | | R¹ |
| 108 | School Use Only | R¹ | R¹ | 738 | 23 | X(023) | | | - |
| 109 | Disbursement 1 Hold/Release Indicator Code | R | R | 761 | 1 | X(001) | | | - |
| 110 | Disbursement 2 Hold/Release Indicator Code | R¹ | R¹ | 762 | 1 | X(001) | | | - |
| 111 | Disbursement 3 Hold/Release Indicator Code | R¹ | R¹ | 763 | 1 | X(001) | | | - |
| 112 | Disbursement 4 Hold/Release Indicator Code | R¹ | R¹ | 764 | 1 | X(001) | | | - |
| 113 | Promissory Note Delivery Code | O⁴ | R¹ | 765 | 1 | X(001) | | | R¹ |
| 114 | Foreign Postal Code | R¹ | R¹ | 766 | 14 | X(014) | Left | Spaces | R¹ |
| 115 | PLUS/Alternative Student Electronic Signature Indicator Code | R¹ | R¹ | 780 | 1 | X(001) | | | R¹ |
| 116 | Lender Non-ED Branch ID | R¹ | R¹ | 781 | 4 | X(004) | Left | Spaces | R¹ |
| 117 | Lender Use Only | R¹ | R¹ | 785 | 20 | X(020) | | | R¹ |
| 118 | Lender of Last Resort Code | O⁴ | O⁴ | 805 | 1 | X(001) | | | - |
| 119 | Origination Fees Paid 2 | R¹ | R¹ | 806 | 5 | 9(003)V99 | | | - |
| 119a | Guarantee/Federal Default Fees Paid 2 | R¹ | R¹ | 811 | 5 | 9(003)V99 | | | - |
| 119b | Origination Fees Paid 3 | R¹ | R¹ | 816 | 5 | 9(003)V99 | | | - |
| 119c | Guarantee/Federal Default Fees Paid 3 | R¹ | R¹ | 821 | 5 | 9(003)V99 | | | - |
| 120 | Disbursement Status Code 1 | R¹ | R¹ | 826 | 1 | X(001) | | | - |
| 121 | Disbursement Status Code 2 | R¹ | R¹ | 827 | 1 | X(001) | | | - |
| 122 | Disbursement Status Code 3 | R¹ | R¹ | 828 | 1 | X(001) | | | - |
| 123 | Disbursement Status Code 4 | R¹ | R¹ | 829 | 1 | X(001) | | | - |
| 124 | Response to Originator Code | R | R | 830 | 1 | X(001) | | | - |
| 125 | Application Send Error Message Code 1 | R¹ | R¹ | 831 | 3 | X(003) | | | - |
| 126 | Application Send Error Message Code 2 | R¹ | R¹ | 834 | 3 | X(003) | | | - |
| 127 | Application Send Error Message Code 3 | R¹ | R¹ | 837 | 3 | X(003) | | | - |
| 128 | Application Send Error Message Code 4 | R¹ | R¹ | 840 | 3 | X(003) | | | - |
| 129 | Application Send Error Message Code 5 | R¹ | R¹ | 843 | 3 | X(003) | | | - |
| 130 | Guarantee Amount Reduction Code | O⁴ | R¹ | 846 | 2 | X(002) | | | - |
| 131 | Total Outstanding Federal Stafford/SLS Loan Amount | R¹ | R¹ | 848 | 8 | 9(006)V99 | Right | Zeros | - |
| 132 | Total Outstanding Federal PLUS Loan Amount | R¹ | R¹ | 856 | 8 | 9(006)V99 | Right | Zeros | - |
| 133 | Application/Loan Phase Code | R | R | 864 | 4 | X(004) | | | R |
| 134 | Date Application/Loan Phase Code Last Updated (CCYYMMDD) | O | O | 868 | 8 | 9(008) | | | O |
| 135 | Guarantor Use Only | R¹ | R¹ | 876 | 23 | X(023) | | | R¹ |
| 136 | Date Permanent Address Last Updated (CCYYMMDD) | S | S | 899 | 8 | 9(008) | | | - |
| 137 | Alternative Loan Program Type Code | R¹ | R¹ | 907 | 3 | X(003) | | | R¹ |
| 138 | Alternative Borrower Total Student Loan Debt | S³ | S³ | 910 | 7 | 9(007) | Right | Zeros | - |
| 139 | Origination Fees Paid 4 | R¹ | R¹ | 917 | 5 | 9(003)V99 | | | - |
| 139a | Guarantee/Federal Default Fees Paid 4 | R¹ | R¹ | 922 | 5 | 9(003)V99 | | | - |
| 139b | Filler² | — | — | 927 | 2 | X(002) | | | - |
| 140 | Fees Paid 1 | R¹ | R¹ | 929 | 7 | 9(005)V99 | Right | Zeros | - |
| 141 | Fees Paid 2 | R¹ | R¹ | 936 | 7 | 9(005)V99 | Right | Zeros | - |
| 142 | Fees Paid 3 | R¹ | R¹ | 943 | 7 | 9(005)V99 | Right | Zeros | - |
| 143 | Fees Paid 4 | R¹ | R¹ | 950 | 7 | 9(005)V99 | Right | Zeros | - |
| 144 | Actual Interest Rate | — | R¹ | 957 | 5 | 9(002)V999 | Right | Zeros | - |
| 145 | Processing Type Code | — | R¹ | 962 | 2 | X(002) | | | R |
| 146 | Service Type Code | — | R¹ | 964 | 2 | X(002) | | | - |
| 147 | Revised Notice of Guarantee Indicator Code | R¹ | — | 966 | 1 | X(001) | | | - |
| 148 | School Refund Amount | R¹ | — | 967 | 7 | 9(005)V99 | Right | Zeros | - |
| 149 | Date of Refund to Lender (CCYYMMDD) | R¹ | — | 974 | 8 | 9(008) | | | - |
| 150 | Unique Layout Vendor Code | R¹ | R¹ | 982 | 4 | X(004) | Left | Spaces | - |
| 151 | Unique Layout Identifier Code | R¹ | R¹ | 986 | 2 | X(002) | | | - |
| 152 | Filler | — | — | 988 | 52 | X(052) | | | - |
| 153 | Record Terminator | R | R | 1040 | 1 | X(001) | | | R |

**Notes**

A 2-character end-of-record indicator (carriage-return and line-feed characters) will follow each physical record. It is not included in determining the fixed length of the record, and is in addition to Record Terminator [field 153].

¹ This data is required based on condition(s) listed in the field description.
² This field is reserved for future use.
³ This data is strongly recommended based on condition(s) listed in the field description.
⁴ This data is optional based on condition(s) listed in the field description.
⁵ Minus symbol will be in the left most position followed by right justified numeric values and padded with 0's (i.e., -0500 for negative five hundred dollars).
\* Justification and padding are determined by field content; see field description for details.

## Unique supplemental detail records (@2)
| Field | Field Name | Required Field | Start Position | Length | Data Type | Justify | Padding |
|------:|------------|:--------------:|---------------:|-------:|-----------|---------|---------|
| 1 | Record Code | R | 1 | 2 | X(002) | | |
| 2 | Unique Supplemental Vendor Code | R | 3 | 4 | X(004) | Left | Spaces |
| 3 | Unique Supplemental Layout Identifier Code | R | 7 | 2 | X(002) | | |
| 4 | Filler | — | 9 | 1031 | X(1031) | | | |
| 5 | Record Terminator | R | 1040 | 1 | X(001) | |

## Special Messages detail records (@3)
| Field | Field Name | Required Field | Start Position | Length | Data Type | Justify | Padding |
|------:|------------|:--------------:|---------------:|-------:|-----------|---------|---------|
| 1 | Record Code | R | 1 | 2 | X(002) | | |
| 2 | Message 1 | R | 3 | 160 | X(160) | Left | Spaces |
| 3 | Message 2 | R | 163 | 160 | X(160) | | |
| 4 | Message 3 | R | 323 | 160 | X(160) | | |
| 5 | Message 4 | R | 483 | 160 | X(160) | | |
| 6 | Message 5 | R | 643 | 160 | X(160) | | |
| 7 | Filler | — | 803 | 237 | X(237) | | | |
| 8 | Record Terminator | R | 1040 | 1 | X(001) | |

## Look into whether we need the change transaction error layout

## Trailing record layout
| Field | Field Name | Required Field | Start Position | Length | Data Type | Justify | Padding |
|------:|------------|:--------------:|---------------:|-------:|-----------|---------|---------|
| 1 | Record Code | R | 1 | 2 | X(002) | | |
| 2 | Response (@1) Detail Record Count | R | 3 | 6 | 9(006) | Right | Zeros |
| 3 | Unique Supplemental (@2) Detail Record Count | R¹ | 9 | 6 | 9(006) | Right | Zeros |
| 4 | Special Messages (@3) Detail Record Count | R¹ | 15 | 6 | 9(006) | Right | Zeros |
| 5 | File Creation Date (CCYYMMDD) | R | 21 | 8 | 9(008) | | |
| 6 | File Creation Time (HHMMSS) | O | 29 | 6 | 9(006) | | |
| 7 | File Identifier Code | R | 35 | 5 | X(005) | | |
| 8 | Recipient Name | R | 40 | 32 | X(032) | Left | Spaces |
| 9 | Recipient ID | R | 72 | 8 | X(008) | Left | Spaces |
| 10 | Filler² | — | 80 | 2 | X(002) | | |
| 11 | Recipient Non-ED Branch ID | R¹ | 82 | 4 | X(004) | Left | Spaces |
| 12 | Source Name | R | 86 | 32 | X(032) | Left | Spaces |
| 13 | Source ID | R | 118 | 8 | X(008) | Left | Spaces |
| 14 | Filler² | — | 126 | 2 | X(002) | | |
| 15 | Source Non-ED Branch ID | R¹ | 128 | 4 | X(004) | Left | Spaces |
| 16 | Alternative Loan Response (@4) Detail Record Count | R¹ | 132 | 6 | 9(006) | Right | Zeros |
| 17 | Reference Response (@5) Detail Record Count | R¹ | 138 | 6 | 9(006) | Right | Zeros |
| 18 | Change Transaction Error (@6) Detail Record Count | R¹ | 144 | 6 | 9(006) | Right | Zeros |
| 19 | Supplemental Borrower Information Response (@7) Detail Record Count | R¹ | 150 | 6 | 9(006) | Right | Zeros |
| 20 | DUNS Recipient ID | O | 156 | 9 | X(009) | | |
| 21 | DUNS Source ID | O | 165 | 9 | X(009) | | |
| 22 | Filler | — | 174 | 866 | X(866) | | |
| 23 | Record Terminator | R | 1040 | 1 | X(001) | | |

**Note**

A 2-character end-of-record indicator (carriage-return and line-feed characters) will follow each physical record. It is not included in determining the fixed length of the record, and must be included in addition to Record Terminator [field 23].

¹ This data is required based on condition(s) listed in the field description.
² This field is reserved for future use.