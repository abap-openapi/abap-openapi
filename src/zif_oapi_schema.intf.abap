INTERFACE zif_oapi_schema PUBLIC.

  TYPES: BEGIN OF ty_property,
           name      TYPE string,
           abap_name TYPE string,
           schema    TYPE REF TO zif_oapi_schema,
         END OF ty_property.

  DATA:
    type       TYPE string,
    default    TYPE string,
    properties TYPE STANDARD TABLE OF ty_property WITH DEFAULT KEY.

ENDINTERFACE.