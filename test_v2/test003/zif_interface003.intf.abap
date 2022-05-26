INTERFACE zif_interface003 PUBLIC.
* auto generated, do not change
  TYPES: BEGIN OF subsubposttestrequest_levelb1_,
           number1 TYPE f,
           number2 TYPE f,
         END OF subsubposttestrequest_levelb1_.
  TYPES: BEGIN OF subposttestrequest_levelb1,
           levelb11 TYPE subsubposttestrequest_levelb1_,
         END OF subposttestrequest_levelb1.
  TYPES: BEGIN OF subposttestrequest_levela1,
           number1 TYPE f,
           number2 TYPE f,
         END OF subposttestrequest_levela1.
  TYPES: BEGIN OF posttestrequest,
           levela1 TYPE subposttestrequest_levela1,
           levelb1 TYPE subposttestrequest_levelb1,
         END OF posttestrequest.
  TYPES: BEGIN OF subsubposttestresponse_levelb1,
           result TYPE f,
         END OF subsubposttestresponse_levelb1.
  TYPES: BEGIN OF subposttestresponse_levelb1,
           levelb11 TYPE subsubposttestresponse_levelb1,
         END OF subposttestresponse_levelb1.
  TYPES: BEGIN OF subposttestresponse_levela1,
           result TYPE f,
         END OF subposttestresponse_levela1.
  TYPES: BEGIN OF posttestresponse,
           levela1 TYPE subposttestresponse_levela1,
           levelb1 TYPE subposttestresponse_levelb1,
         END OF posttestresponse.
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