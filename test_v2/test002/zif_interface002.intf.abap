INTERFACE zif_interface002 PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi

* POSTtestResponse
  TYPES: BEGIN OF posttestresponse,
           result TYPE f,
         END OF posttestresponse.
* POSTtestRequest
  TYPES: BEGIN OF posttestrequest,
           number1 TYPE f,
           number2 TYPE f,
         END OF posttestrequest.

  TYPES: BEGIN OF ret__test,
           200 TYPE posttestresponse,
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