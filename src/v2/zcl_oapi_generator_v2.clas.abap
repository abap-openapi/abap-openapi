CLASS zcl_oapi_generator_v2 DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             clas_icf_serv TYPE c LENGTH 30,
             clas_icf_impl TYPE c LENGTH 30,
             clas_client   TYPE c LENGTH 30,
             intf          TYPE c LENGTH 30,
             openapi_json  TYPE string,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
        clas_icf_serv TYPE string,
        clas_icf_impl TYPE string,
        clas_client   TYPE string,
        intf          TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING
        is_input TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS build_clas_icf_serv
      IMPORTING
        is_input TYPE ty_input
        is_schema TYPE zif_oapi_specification_v3=>ty_specification
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_clas_icf_impl
      IMPORTING
        is_input TYPE ty_input
        is_schema TYPE zif_oapi_specification_v3=>ty_specification
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_clas_client
      IMPORTING
        is_input TYPE ty_input
        is_schema TYPE zif_oapi_specification_v3=>ty_specification
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_intf
      IMPORTING
        is_input TYPE ty_input
        is_schema TYPE zif_oapi_specification_v3=>ty_specification
      RETURNING VALUE(rv_abap) TYPE string.

ENDCLASS.

CLASS zcl_oapi_generator_v2 IMPLEMENTATION.

  METHOD run.
    DATA lo_parser TYPE REF TO zcl_oapi_parser.
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_specification.

    CREATE OBJECT lo_parser.
    ls_schema = lo_parser->parse( is_input-openapi_json ).

    rs_result-clas_icf_serv = build_clas_icf_serv(
      is_schema = ls_schema
      is_input  = is_input ).
    rs_result-clas_icf_impl = build_clas_icf_impl(
      is_schema = ls_schema
      is_input  = is_input ).
    rs_result-clas_client = build_clas_client(
      is_schema = ls_schema
      is_input  = is_input ).
    rs_result-intf = build_intf(
      is_schema = ls_schema
      is_input  = is_input ).
  ENDMETHOD.

  METHOD build_clas_icf_serv.
    DATA ls_operation LIKE LINE OF is_schema-operations.

    rv_abap = |CLASS { is_input-clas_icf_serv } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES if_http_extension.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_serv } IMPLEMENTATION.\n| &&
      |  METHOD if_http_extension~handle_request.\n| &&
      |    DATA handler TYPE REF TO { is_input-intf }.\n| &&
      |    DATA method  TYPE string.\n| &&
      |    DATA path    TYPE string.\n\n| &&
      |    CREATE OBJECT handler TYPE { is_input-clas_icf_impl }.\n| &&
      |    path = server->request->get_header_field( '~path' ).\n| &&
      |    method = server->request->get_method( ).\n\n|.
    LOOP AT is_schema-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |    IF path = '{ ls_operation-path }' AND method = '{ to_upper( ls_operation-method ) }'.\n| &&
        |      handler->{ ls_operation-abap_name }( ).\n| &&
        |    ENDIF.\n|.
    ENDLOOP.
    rv_abap = rv_abap && |  ENDMETHOD.\n| &&
      |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_clas_icf_impl.
    DATA ls_operation LIKE LINE OF is_schema-operations.

    rv_abap = |CLASS { is_input-clas_icf_impl } DEFINITION PUBLIC.\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_impl } IMPLEMENTATION.\n\n|.

    LOOP AT is_schema-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { is_input-intf }~{ ls_operation-abap_name }.\n| &&
        |* todo\n| &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_clas_client.
    DATA ls_operation LIKE LINE OF is_schema-operations.

    rv_abap = |CLASS { is_input-clas_client } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |    METHODS constructor IMPORTING host TYPE string.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_client } IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |* todo, instantiate CL_HTTP_CLIENT here\n| &&
      |  ENDMETHOD.\n\n|.

    LOOP AT is_schema-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { is_input-intf }~{ ls_operation-abap_name }.\n| &&
        |* todo\n| &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_intf.
    DATA ls_operation LIKE LINE OF is_schema-operations.

    rv_abap = |INTERFACE { is_input-intf } PUBLIC.\n| &&
      |* auto generated, do not change\n|.
    LOOP AT is_schema-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHODS { ls_operation-abap_name }.\n|.
    ENDLOOP.
    rv_abap = rv_abap && |ENDINTERFACE.|.
  ENDMETHOD.

ENDCLASS.