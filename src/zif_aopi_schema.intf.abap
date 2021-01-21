INTERFACE zif_aopi_schema PUBLIC.
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
ENDINTERFACE.