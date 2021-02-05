INTERFACE zif_oapi_schema PUBLIC.

  TYPES: BEGIN OF ty_property,
           name      TYPE string,
           abap_name TYPE string,
           ref       TYPE string,
           schema    TYPE REF TO zif_oapi_schema,
         END OF ty_property.

  DATA:
    type       TYPE string,
    default    TYPE string,
    properties TYPE STANDARD TABLE OF ty_property WITH DEFAULT KEY,
    items_ref  TYPE string.

  METHODS is_simple_type
    RETURNING VALUE(rv_simple) TYPE abap_bool.
  METHODS get_simple_type
    RETURNING VALUE(rv_simple) TYPE string.
  METHODS build_type_definition
    IMPORTING iv_name TYPE string
    RETURNING VALUE(rv_abap) TYPE string.

ENDINTERFACE.