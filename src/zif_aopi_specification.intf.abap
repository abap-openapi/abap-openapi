INTERFACE zif_aopi_specification PUBLIC.

* OpenAPI v3 specification

  TYPES: BEGIN OF ty_parameter,
           name        TYPE string,
           abap_name   TYPE string,
           in          TYPE string,
           description TYPE string,
           required    TYPE abap_bool,
         END OF ty_parameter.

  TYPES ty_parameters TYPE STANDARD TABLE OF ty_parameter WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_operation,
           path         TYPE string,
           method       TYPE string,
           summary      TYPE string,
           description  TYPE string,
           operation_id TYPE string,
           abap_name    TYPE string,
           parameters   TYPE ty_parameters,
         END OF ty_operation.

  TYPES ty_operations TYPE STANDARD TABLE OF ty_operation WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_component_schema,
           name TYPE string,
           abap_name TYPE string,
         END OF ty_component_schema.

  TYPES ty_schemas TYPE STANDARD TABLE OF ty_component_schema WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_components,
           schemas TYPE ty_schemas,
         END OF ty_components.

  TYPES: BEGIN OF ty_info,
           title TYPE string,
           description TYPE string,
         END OF ty_info.

  TYPES: BEGIN OF ty_specification,
           openapi TYPE string,
           info TYPE ty_info,
           operations TYPE ty_operations,
           components TYPE ty_components,
         END OF ty_specification.
ENDINTERFACE.