INTERFACE zif_interface005 PUBLIC.
* auto generated, do not change
  TYPES: BEGIN OF posttestrequest,
           string1 TYPE string,
           string2 TYPE string,
         END OF posttestrequest.
  TYPES: BEGIN OF posttestresponse,
           result TYPE string,
         END OF posttestresponse.
  TYPES: BEGIN OF ty__test,
           200 TYPE posttestresponse,
         END OF ty__test.
  METHODS _test
    IMPORTING
      separator TYPE string
      body TYPE posttestrequest
    RETURNING
      VALUE(return) TYPE ty__test
    RAISING cx_static_check.
ENDINTERFACE.