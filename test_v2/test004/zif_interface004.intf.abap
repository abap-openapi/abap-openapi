INTERFACE zif_interface004 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi

* resultStruct
  TYPES: BEGIN OF resultstruct,
           result TYPE f,
         END OF resultstruct.
* number1andnumber2
  TYPES: BEGIN OF number1andnumber2,
           number1 TYPE f,
           number2 TYPE f,
         END OF number1andnumber2.
* POSTtestResponse
  TYPES: BEGIN OF subposttestresponse_levelb1,
           levelb11 TYPE STANDARD TABLE OF f WITH DEFAULT KEY,
         END OF subposttestresponse_levelb1.
  TYPES: BEGIN OF posttestresponse,
           levela1 TYPE STANDARD TABLE OF resultstruct WITH DEFAULT KEY,
           levelb1 TYPE subposttestresponse_levelb1,
           levelc1 TYPE f,
         END OF posttestresponse.
* POSTtestRequest
  TYPES: BEGIN OF subposttestrequest_levelb1,
           levelb11 TYPE STANDARD TABLE OF number1andnumber2 WITH DEFAULT KEY,
         END OF subposttestrequest_levelb1.
  TYPES: BEGIN OF posttestrequest,
           levela1 TYPE STANDARD TABLE OF number1andnumber2 WITH DEFAULT KEY,
           levelb1 TYPE subposttestrequest_levelb1,
           levelc1 TYPE STANDARD TABLE OF f WITH DEFAULT KEY,
         END OF posttestrequest.

  TYPES: BEGIN OF ret__test,
           _200_app_json TYPE posttestresponse,
         END OF ret__test.
  METHODS _test
    IMPORTING
      operation TYPE string
      body TYPE posttestrequest
    RETURNING
      VALUE(return) TYPE ret__test
    RAISING
      cx_static_check.
ENDINTERFACE.