INTERFACE zif_interface007 PUBLIC.
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
           levelc1 TYPE string,
         END OF posttestresponse.
  TYPES: BEGIN OF string1andstring2,
           string1 TYPE string,
           string2 TYPE string,
         END OF string1andstring2.
  TYPES: BEGIN OF resultstruct,
           result TYPE string,
         END OF resultstruct.
  METHODS _test
    IMPORTING
      separator TYPE string
      body TYPE #/components/schemas/POSTtestRequest.
ENDINTERFACE.