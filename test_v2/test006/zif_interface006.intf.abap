INTERFACE zif_interface006 PUBLIC.
* auto generated, do not change
  TYPES: BEGIN OF subsubposttestrequest_levelb1_,
           string1 TYPE string,
           string2 TYPE string,
         END OF subsubposttestrequest_levelb1_.
  TYPES: BEGIN OF subposttestrequest_levelb1,
           levelb11 TYPE subsubposttestrequest_levelb1_,
         END OF subposttestrequest_levelb1.
  TYPES: BEGIN OF subposttestrequest_levela1,
           string1 TYPE string,
           string2 TYPE string,
         END OF subposttestrequest_levela1.
  TYPES: BEGIN OF posttestrequest,
           levela1 TYPE subposttestrequest_levela1,
           levelb1 TYPE subposttestrequest_levelb1,
         END OF posttestrequest.
  TYPES: BEGIN OF subsubposttestresponse_levelb1,
           result TYPE string,
         END OF subsubposttestresponse_levelb1.
  TYPES: BEGIN OF subposttestresponse_levelb1,
           levelb11 TYPE subsubposttestresponse_levelb1,
         END OF subposttestresponse_levelb1.
  TYPES: BEGIN OF subposttestresponse_levela1,
           result TYPE string,
         END OF subposttestresponse_levela1.
  TYPES: BEGIN OF posttestresponse,
           levela1 TYPE subposttestresponse_levela1,
           levelb1 TYPE subposttestresponse_levelb1,
         END OF posttestresponse.
  METHODS _test
    IMPORTING
      separator TYPE string
      body TYPE posttestrequest.
ENDINTERFACE.