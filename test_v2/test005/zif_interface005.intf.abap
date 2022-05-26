INTERFACE zif_interface005 PUBLIC.
* auto generated, do not change
  TYPES: BEGIN OF posttestrequest,
           string1 TYPE string,
           string2 TYPE string,
         END OF posttestrequest.
  TYPES: BEGIN OF posttestresponse,
           result TYPE string,
         END OF posttestresponse.
  METHODS _test
    IMPORTING
      separator TYPE string
      body TYPE posttestrequest.
ENDINTERFACE.