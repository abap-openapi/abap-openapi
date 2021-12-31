INTERFACE zif_oapi_specification_v3 PUBLIC.

* OpenAPI v3 specification

  TYPES: BEGIN OF ty_parameter,
           id          TYPE string,
           name        TYPE string,
           abap_name   TYPE string,
           in          TYPE string,
           description TYPE string,
           required    TYPE abap_bool,
           schema      TYPE REF TO zif_oapi_schema,
           schema_ref  TYPE string,
         END OF ty_parameter.

  TYPES ty_parameters TYPE STANDARD TABLE OF ty_parameter WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_media_type,
           type       TYPE string,
           schema     TYPE REF TO zif_oapi_schema,
           schema_ref TYPE string,
         END OF ty_media_type.

  TYPES ty_media_types TYPE STANDARD TABLE OF ty_media_type WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_response,
           code        TYPE string,
           description TYPE string,
           content     TYPE ty_media_types,
         END OF ty_response.

  TYPES ty_responses TYPE STANDARD TABLE OF ty_response WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_operation,
           path           TYPE string,
           method         TYPE string,
           summary        TYPE string,
           description    TYPE string,
           operation_id   TYPE string,
           deprecated     TYPE abap_bool,
           abap_name      TYPE string,
           body_schema     TYPE REF TO zif_oapi_schema,
           body_schema_ref TYPE string,
           parameters      TYPE ty_parameters,
           parameters_ref  TYPE string_table,
           responses       TYPE ty_responses,
           responses_ref   TYPE string_table, " ? todo
         END OF ty_operation.

  TYPES ty_operations TYPE STANDARD TABLE OF ty_operation WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_component_schema,
           name               TYPE string,
           abap_name          TYPE string,
           abap_parser_method TYPE string,
           abap_json_method   TYPE string,
           schema             TYPE REF TO zif_oapi_schema,
         END OF ty_component_schema.

  TYPES ty_schemas TYPE STANDARD TABLE OF ty_component_schema WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_components,
           schemas          TYPE ty_schemas,
           responses        TYPE string, " todo
           parameters       TYPE ty_parameters,
           examples         TYPE string, " todo
           request_bodies   TYPE string, " todo
           headers          TYPE string, " todo
           security_schemas TYPE string, " todo
           links            TYPE string, " todo
           callbacks        TYPE string, " todo
         END OF ty_components.

  TYPES: BEGIN OF ty_info,
           title TYPE string,
           version TYPE string,
           description TYPE string,
         END OF ty_info.

  TYPES: BEGIN OF ty_server,
           url TYPE string,
         END OF ty_server.

  TYPES ty_servers TYPE STANDARD TABLE OF ty_server WITH DEFAULT KEY.

  TYPES: BEGIN OF ty_specification,
           openapi    TYPE string,
           info       TYPE ty_info,
           servers    TYPE ty_servers,
           operations TYPE ty_operations,
           components TYPE ty_components,
         END OF ty_specification.
ENDINTERFACE.
