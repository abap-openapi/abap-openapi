INTERFACE zif_interface004 PUBLIC.
* auto generated, do not change
  TYPES: BEGIN OF subposttestrequest_levelb1,
           levelb11 TYPE STANDARD TABLE OF string WITH DEFAULT KEY, " todo, handle array
         END OF subposttestrequest_levelb1.
  TYPES: BEGIN OF posttestrequest,
           levela1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY, " todo, handle array
           levelb1 TYPE subposttestrequest_levelb1,
           levelc1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY, " todo, handle array
         END OF posttestrequest.
  TYPES: BEGIN OF subposttestresponse_levelb1,
           levelb11 TYPE STANDARD TABLE OF string WITH DEFAULT KEY, " todo, handle array
         END OF subposttestresponse_levelb1.
  TYPES: BEGIN OF posttestresponse,
           levela1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY, " todo, handle array
           levelb1 TYPE subposttestresponse_levelb1,
           levelc1 TYPE f,
         END OF posttestresponse.
  TYPES: BEGIN OF number1andnumber2,
           number1 TYPE f,
           number2 TYPE f,
         END OF number1andnumber2.
  TYPES: BEGIN OF resultstruct,
           result TYPE f,
         END OF resultstruct.
  TYPES: BEGIN OF ty__test,
           200 TYPE posttestresponse,
         END OF ty__test.
  METHODS _test
    IMPORTING
      operation TYPE string
      body TYPE posttestrequest
    RETURNING
      VALUE(return) TYPE ty__test.
ENDINTERFACE.