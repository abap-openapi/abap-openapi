INTERFACE zif_interface002 PUBLIC.
* auto generated, do not change
  TYPES: BEGIN OF posttestrequest,
           number1 TYPE f,
           number2 TYPE f,
         END OF posttestrequest.
  TYPES: BEGIN OF posttestresponse,
           result TYPE f,
         END OF posttestresponse.
  TYPES: BEGIN OF ty__test,
           200 TYPE posttestresponse,
         END OF ty__test.
  METHODS _test
    IMPORTING
      operation TYPE string
      body TYPE posttestrequest
    RETURNING
      VALUE(return) TYPE ty__test
    RAISING cx_static_check.
ENDINTERFACE.