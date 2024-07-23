INTERFACE zif_interface006 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: c1_string_concat_object
* Version: 1

  CONSTANTS: base_path TYPE string VALUE ''.

* POSTtestResponse
  TYPES: BEGIN OF subsubposttestresponse_level,
           result TYPE string,
         END OF subsubposttestresponse_level.
  TYPES: BEGIN OF subposttestresponse_levelb1,
           levelb11 TYPE subsubposttestresponse_level,
         END OF subposttestresponse_levelb1.
  TYPES: BEGIN OF subposttestresponse_levela1,
           result TYPE string,
         END OF subposttestresponse_levela1.
  TYPES: BEGIN OF posttestresponse,
           levela1 TYPE subposttestresponse_levela1,
           levelb1 TYPE subposttestresponse_levelb1,
         END OF posttestresponse.
* POSTtestRequest
  TYPES: BEGIN OF subsubposttestrequest_levelb,
           string1 TYPE string,
           string2 TYPE string,
         END OF subsubposttestrequest_levelb.
  TYPES: BEGIN OF subposttestrequest_levelb1,
           levelb11 TYPE subsubposttestrequest_levelb,
         END OF subposttestrequest_levelb1.
  TYPES: BEGIN OF subposttestrequest_levela1,
           string1 TYPE string,
           string2 TYPE string,
         END OF subposttestrequest_levela1.
  TYPES: BEGIN OF posttestrequest,
           levela1 TYPE subposttestrequest_levela1,
           levelb1 TYPE subposttestrequest_levelb1,
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