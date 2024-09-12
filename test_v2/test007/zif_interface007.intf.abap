INTERFACE zif_interface007 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: c1_string_concat_table
* Version: 1

  CONSTANTS base_path TYPE string VALUE ''.

* resultStruct
  TYPES: BEGIN OF resultstruct,
           result TYPE string,
         END OF resultstruct.
* string1andstring2
  TYPES: BEGIN OF string1andstring2,
           string1 TYPE string,
           string2 TYPE string,
         END OF string1andstring2.
* POSTtestResponse
  TYPES: BEGIN OF subposttestresponse_levelb1,
           levelb11 TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
         END OF subposttestresponse_levelb1.
  TYPES: BEGIN OF posttestresponse,
           levela1 TYPE STANDARD TABLE OF resultstruct WITH DEFAULT KEY,
           levelb1 TYPE subposttestresponse_levelb1,
           levelc1 TYPE string,
         END OF posttestresponse.
* POSTtestRequest
  TYPES: BEGIN OF subposttestrequest_levelb1,
           levelb11 TYPE STANDARD TABLE OF string1andstring2 WITH DEFAULT KEY,
         END OF subposttestrequest_levelb1.
  TYPES: BEGIN OF posttestrequest,
           levela1 TYPE STANDARD TABLE OF string1andstring2 WITH DEFAULT KEY,
           levelb1 TYPE subposttestrequest_levelb1,
           levelc1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
         END OF posttestrequest.

  TYPES: BEGIN OF r__test,
           _200_app_json TYPE posttestresponse,
         END OF r__test.
  METHODS _test
    IMPORTING
      separator TYPE string OPTIONAL
      body TYPE posttestrequest
    RETURNING
      VALUE(return) TYPE r__test
    RAISING
      cx_static_check.
ENDINTERFACE.