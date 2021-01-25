CLASS zcl_oapi_parser DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS parse
      IMPORTING iv_json TYPE string
      RETURNING VALUE(rs_schema) TYPE zif_oapi_specification=>ty_specification.

  PRIVATE SECTION.
    DATA mo_json TYPE REF TO zcl_oapi_json.

    METHODS to_abap_name
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_name) TYPE string.

    METHODS parse_operations
      RETURNING VALUE(rt_operations) TYPE zif_oapi_specification=>ty_operations.

    METHODS parse_servers
      RETURNING VALUE(rt_servers) TYPE zif_oapi_specification=>ty_servers.

    METHODS parse_parameters
      IMPORTING iv_prefix TYPE string
      RETURNING VALUE(rt_parameters) TYPE zif_oapi_specification=>ty_parameters.
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

  METHOD to_abap_name.
    rv_name = to_lower( iv_name ).
    REPLACE ALL OCCURRENCES OF '-' IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF '/' IN rv_name WITH '_'.
    IF strlen( rv_name ) > 30.
      rv_name = rv_name(30).
    ENDIF.
  ENDMETHOD.

  METHOD parse_operations.
    DATA lt_paths TYPE string_table.
    DATA lv_path LIKE LINE OF lt_paths.
    DATA lt_methods TYPE string_table.
    DATA lv_method LIKE LINE OF lt_methods.
    DATA lv_prefix TYPE string.
    DATA ls_operation LIKE LINE OF rt_operations.

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
        ls_operation-abap_name = to_abap_name( ls_operation-operation_id ).
        APPEND ls_operation TO rt_operations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_parameters.
    DATA lt_members TYPE string_table.
    DATA lv_member LIKE LINE OF lt_members.
    DATA ls_parameter LIKE LINE OF rt_parameters.

    lt_members = mo_json->members( iv_prefix ).
    LOOP AT lt_members INTO lv_member.
      CLEAR ls_parameter.
      ls_parameter-name = mo_json->value_string( iv_prefix && lv_member && '/name' ).
      ls_parameter-in = mo_json->value_string( iv_prefix && lv_member && '/in' ).
      ls_parameter-description = mo_json->value_string( iv_prefix && lv_member && '/description' ).
      ls_parameter-required = mo_json->value_boolean( iv_prefix && lv_member && '/required' ).
      ls_parameter-abap_name = to_abap_name( ls_parameter-name ).
      IF ls_parameter-name IS NOT INITIAL. " it might be a #ref
        APPEND ls_parameter TO rt_parameters.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.