INTERFACE zif_oapi_schema PUBLIC.

  TYPES: BEGIN OF ty_properties,
           name      TYPE string,
           abap_name TYPE string,
           schema    TYPE REF TO zif_oapi_schema,
         END OF ty_properties.

  DATA:
    type       TYPE string,
    default    TYPE string,
    properties TYPE STANDARD TABLE OF ty_properties WITH DEFAULT KEY.

ENDINTERFACE.