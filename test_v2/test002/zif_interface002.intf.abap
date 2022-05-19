INTERFACE zif_interface002 PUBLIC.
* auto generated, do not change
  TYPES: BEGIN OF posttestrequest,
           number1 TYPE f,
           number2 TYPE f,
         END OF posttestrequest.
  TYPES: BEGIN OF posttestresponse,
           result TYPE f,
         END OF posttestresponse.
  METHODS _test
    IMPORTING
      operation TYPE string.
ENDINTERFACE.