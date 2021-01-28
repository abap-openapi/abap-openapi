CLASS zcl_oapi_parser DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS parse
      IMPORTING iv_json TYPE string
      RETURNING VALUE(rs_schema) TYPE zif_oapi_specification_v3=>ty_specification.

  PRIVATE SECTION.
    DATA mo_json TYPE REF TO zcl_oapi_json.

    METHODS parse_operations
      RETURNING VALUE(rt_operations) TYPE zif_oapi_specification_v3=>ty_operations.

    METHODS parse_servers
      RETURNING VALUE(rt_servers) TYPE zif_oapi_specification_v3=>ty_servers.

    METHODS parse_parameters
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(rt_parameters) TYPE zif_oapi_specification_v3=>ty_parameters.

    METHODS parse_parameters_ref
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(rt_parameters) TYPE string_table.

    METHODS parse_responses
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(rt_responses) TYPE zif_oapi_specification_v3=>ty_responses.

    METHODS parse_media_types
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(rt_media_types) TYPE zif_oapi_specification_v3=>ty_media_types.

    METHODS parse_components
      RETURNING VALUE(rs_components) TYPE zif_oapi_specification_v3=>ty_components.

    METHODS parse_schema
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(rs_schema) TYPE zif_oapi_specification_v3=>ty_schema.

    METHODS parse_schemas
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(rt_schemas) TYPE zif_oapi_specification_v3=>ty_schemas.

ENDCLASS.

CLASS zcl_oapi_parser IMPLEMENTATION.

  METHOD parse.

    CREATE OBJECT mo_json EXPORTING iv_json = iv_json.

    rs_schema-openapi = mo_json->value_string( '/openapi' ).
    ASSERT rs_schema-openapi CP '3*'.

    rs_schema-info-title = mo_json->value_string( '/info/title' ).
    rs_schema-info-description = mo_json->value_string( '/info/description' ).

    rs_schema-operations = parse_operations( ).
    rs_schema-servers = parse_servers( ).
    rs_schema-components = parse_components( ).

  ENDMETHOD.

  METHOD parse_schema.
    rs_schema-type = mo_json->value_string( iv_prefix && '/type' ).
    rs_schema-default = mo_json->value_string( iv_prefix && '/default' ).
  ENDMETHOD.

  METHOD parse_components.
    rs_components-parameters = parse_parameters( '/components/parameters/' ).
    rs_components-schemas = parse_schemas( '/components/schemas/' ).
  ENDMETHOD.

  METHOD parse_schemas.

    DATA lt_names TYPE string_table.
    DATA lv_name TYPE string.
    DATA ls_schema LIKE LINE OF rt_schemas.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    lt_names = mo_json->members( iv_prefix ).
    LOOP AT lt_names INTO lv_name.
      CLEAR ls_schema.
      ls_schema-name = lv_name.
      ls_schema-abap_name = lo_names->to_abap_name( ls_schema-name ).
      ls_schema-schema = parse_schema( iv_prefix && lv_name ).
      APPEND ls_schema TO rt_schemas.
    ENDLOOP.

  ENDMETHOD.

  METHOD parse_servers.

    DATA lt_array TYPE string_table.
    DATA lv_index TYPE string.
    DATA ls_server LIKE LINE OF rt_servers.

    lt_array = mo_json->members( '/servers/' ).
    LOOP AT lt_array INTO lv_index.
      CLEAR ls_server.
      ls_server-url = mo_json->value_string( '/servers/' && lv_index && '/url' ).
      APPEND ls_server TO rt_servers.
    ENDLOOP.

  ENDMETHOD.

  METHOD parse_operations.
    DATA lt_paths TYPE string_table.
    DATA lv_path LIKE LINE OF lt_paths.
    DATA lt_methods TYPE string_table.
    DATA lv_method LIKE LINE OF lt_methods.
    DATA lv_prefix TYPE string.
    DATA ls_operation LIKE LINE OF rt_operations.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    lt_paths = mo_json->members( '/paths/' ).
    LOOP AT lt_paths INTO lv_path.
      CLEAR ls_operation.
      ls_operation-path = lv_path.
      lt_methods = mo_json->members( '/paths/' && lv_path && '/' ).
      LOOP AT lt_methods INTO lv_method.
        ls_operation-method = lv_method.
        lv_prefix = '/paths/' && lv_path && '/' && lv_method.
        ls_operation-summary = mo_json->value_string( lv_prefix && '/summary' ).
        ls_operation-description = mo_json->value_string( lv_prefix && '/description' ).
        ls_operation-operation_id = mo_json->value_string( lv_prefix && '/operationId' ).
        ls_operation-parameters = parse_parameters( lv_prefix && '/parameters/' ).
        ls_operation-parameters_ref = parse_parameters_ref( lv_prefix && '/parameters/' ).
        ls_operation-responses = parse_responses( lv_prefix && '/responses/' ).
        ls_operation-abap_name = lo_names->to_abap_name( ls_operation-operation_id ).
        APPEND ls_operation TO rt_operations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_parameters.
    DATA lt_members TYPE string_table.
    DATA lv_member LIKE LINE OF lt_members.
    DATA ls_parameter LIKE LINE OF rt_parameters.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    lt_members = mo_json->members( iv_prefix ).
    LOOP AT lt_members INTO lv_member.
      CLEAR ls_parameter.
      ls_parameter-name = mo_json->value_string( iv_prefix && lv_member && '/name' ).
      IF ls_parameter-name IS NOT INITIAL.
        ls_parameter-in = mo_json->value_string( iv_prefix && lv_member && '/in' ).
        ls_parameter-description = mo_json->value_string( iv_prefix && lv_member && '/description' ).
        ls_parameter-required = mo_json->value_boolean( iv_prefix && lv_member && '/required' ).
        ls_parameter-abap_name = lo_names->to_abap_name( ls_parameter-name ).
        ls_parameter-schema = parse_schema( iv_prefix && lv_member && '/schema' ).
        APPEND ls_parameter TO rt_parameters.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_parameters_ref.
    DATA lt_members TYPE string_table.
    DATA lv_member LIKE LINE OF lt_members.
    DATA lv_ref TYPE string.

    lt_members = mo_json->members( iv_prefix ).
    LOOP AT lt_members INTO lv_member.
      lv_ref = mo_json->value_string( iv_prefix && lv_member && '/$ref' ).
      IF lv_ref IS NOT INITIAL.
        APPEND lv_ref TO rt_parameters.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_responses.
    DATA lt_members TYPE string_table.
    DATA lv_member LIKE LINE OF lt_members.
    DATA ls_response LIKE LINE OF rt_responses.

    lt_members = mo_json->members( iv_prefix ).
    LOOP AT lt_members INTO lv_member.
      CLEAR ls_response.
      ls_response-code = lv_member.
      ls_response-description = mo_json->value_string( iv_prefix && lv_member && '/description' ).
      ls_response-content = parse_media_types( iv_prefix && lv_member && '/content/' ).
      APPEND ls_response TO rt_responses.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_media_types.
    DATA lt_members TYPE string_table.
    DATA lv_member LIKE LINE OF lt_members.
    DATA ls_media_type LIKE LINE OF rt_media_types.

    lt_members = mo_json->members( iv_prefix ).
    LOOP AT lt_members INTO lv_member.
      CLEAR ls_media_type.
      ls_media_type-type = lv_member.
      ls_media_type-schema_ref = mo_json->value_string( iv_prefix && lv_member && '/schema/$ref' ).
      APPEND ls_media_type TO rt_media_types.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.