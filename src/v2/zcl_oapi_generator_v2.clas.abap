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
    DATA ms_specification TYPE zif_oapi_specification_v3=>ty_specification.

    METHODS build_clas_icf_serv
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_clas_icf_impl
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_clas_client
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_intf
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_input_parameters
      IMPORTING
        is_operation TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING VALUE(rv_abap) TYPE string.

    TYPES: BEGIN OF ty_returning,
        abap TYPE string,
        type TYPE string,
      END OF ty_returning.
    METHODS find_returning_parameter
      IMPORTING
        is_operation TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING VALUE(rs_returning) TYPE ty_returning.

    METHODS find_schema
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rs_schema) TYPE zif_oapi_specification_v3=>ty_component_schema.

ENDCLASS.

CLASS zcl_oapi_generator_v2 IMPLEMENTATION.

  METHOD find_schema.
    DATA lv_name TYPE string.

    lv_name = iv_name.

    REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN lv_name WITH ''.
    READ TABLE ms_specification-components-schemas INTO rs_schema WITH KEY name = lv_name. "#EC CI_SUBRC
  ENDMETHOD.

  METHOD run.
    DATA lo_parser TYPE REF TO zcl_oapi_parser.

    CREATE OBJECT lo_parser.
    ms_specification = lo_parser->parse( is_input-openapi_json ).

    rs_result-clas_icf_serv = build_clas_icf_serv( is_input ).
    rs_result-clas_icf_impl = build_clas_icf_impl( is_input ).
    rs_result-clas_client = build_clas_client( is_input ).
    rs_result-intf = build_intf( is_input ).
  ENDMETHOD.

  METHOD build_clas_icf_serv.
    DATA ls_operation LIKE LINE OF ms_specification-operations.

    rv_abap = |CLASS { is_input-clas_icf_serv } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES if_http_extension.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_serv } IMPLEMENTATION.\n| &&
      |  METHOD if_http_extension~handle_request.\n| &&
      |    DATA li_handler TYPE REF TO { is_input-intf }.\n| &&
      |    DATA lv_method  TYPE string.\n| &&
      |    DATA lv_path    TYPE string.\n\n| &&
      |    CREATE OBJECT li_handler TYPE { is_input-clas_icf_impl }.\n| &&
      |    lv_path = server->request->get_header_field( '~path' ).\n| &&
      |    lv_method = server->request->get_method( ).\n\n|.
    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |    IF lv_path = '{ ls_operation-path }' AND lv_method = '{ to_upper( ls_operation-method ) }'.\n| &&
        |      li_handler->{ ls_operation-abap_name }( ).\n| &&
        |    ENDIF.\n|.
    ENDLOOP.
    rv_abap = rv_abap &&
      |\n| &&
      |    server->response->set_content_type( 'text/html' ).\n| &&
      |    server->response->set_cdata( 'todo' ).\n| &&
      |    server->response->set_status( code = 200 reason = 'Success' ).\n| &&
      |  ENDMETHOD.\n| &&
      |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_clas_icf_impl.
    DATA ls_operation LIKE LINE OF ms_specification-operations.

    rv_abap = |CLASS { is_input-clas_icf_impl } DEFINITION PUBLIC.\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_impl } IMPLEMENTATION.\n\n|.

    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { is_input-intf }~{ ls_operation-abap_name }.\n| &&
        |* Add implementation logic here\n| &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_clas_client.
    DATA ls_operation LIKE LINE OF ms_specification-operations.

    rv_abap = |CLASS { is_input-clas_client } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |    METHODS constructor\n| &&
      |      IMPORTING\n| &&
      |        iv_url    TYPE string\n| &&
      |        iv_ssl_id TYPE ssfapplssl OPTIONAL.\n| &&
      |  PROTECTED SECTION.\n| &&
      |    DATA mi_client TYPE REF TO if_http_client.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_client } IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |    cl_http_client=>create_by_url(\n| &&
      |      EXPORTING\n| &&
      |        url    = iv_url\n| &&
      |        ssl_id = iv_ssl_id\n| &&
      |      IMPORTING\n| &&
      |        client = mi_client ).\n| &&
      |  ENDMETHOD.\n\n|.

    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { is_input-intf }~{ ls_operation-abap_name }.\n| &&
        |    DATA lv_code TYPE i.\n| &&
        |\n| &&
        |    mi_client->request->set_method( '{ to_upper( ls_operation-method ) }' ).\n| &&
        |    mi_client->request->set_data( '112233AABBCCDDEEFF' ).\n| &&
        |    mi_client->send( ).\n| &&
        |    mi_client->receive( ).\n| &&
        |\n| &&
        |    mi_client->response->get_status( IMPORTING code = lv_code ).\n| &&
        |    mi_client->response->get_data( ).\n| &&
        |* todo\n| &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_intf.
    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_returning TYPE ty_returning.
    DATA ls_component_schema LIKE LINE OF ms_specification-components-schemas.

    rv_abap = |INTERFACE { is_input-intf } PUBLIC.\n| &&
      |* auto generated, do not change\n|.

    LOOP AT ms_specification-components-schemas INTO ls_component_schema.
      rv_abap = rv_abap && ls_component_schema-schema->build_type_definition2(
        iv_name          = ls_component_schema-abap_name
        is_specification = ms_specification ).
    ENDLOOP.

    LOOP AT ms_specification-operations INTO ls_operation.
      ls_returning = find_returning_parameter( ls_operation ).
      rv_abap = rv_abap && ls_returning-type &&
        |  METHODS { ls_operation-abap_name }{
          find_input_parameters( ls_operation ) }{
          ls_returning-abap }\n    RAISING cx_static_check.\n|.
    ENDLOOP.
    rv_abap = rv_abap && |ENDINTERFACE.|.
  ENDMETHOD.

  METHOD find_input_parameters.
    DATA lt_list TYPE STANDARD TABLE OF string.
    DATA lv_str TYPE string.
    DATA ls_parameter LIKE LINE OF is_operation-parameters.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'query'.
      lv_str = |      { ls_parameter-abap_name } TYPE { ls_parameter-schema->get_simple_type( ) }|.
      APPEND lv_str TO lt_list.
    ENDLOOP.

    IF is_operation-body_schema_ref IS NOT INITIAL.
      lv_str = |      body TYPE { find_schema( is_operation-body_schema_ref )-abap_name }|.
      APPEND lv_str TO lt_list.
    ENDIF.

    rv_abap = concat_lines_of( table = lt_list sep = |\n| ).

    IF rv_abap IS NOT INITIAL.
      rv_abap = |\n    IMPORTING\n{ rv_abap }|.
    ENDIF.

  ENDMETHOD.

  METHOD find_returning_parameter.
    DATA ls_response LIKE LINE OF is_operation-responses.
    DATA ls_content LIKE LINE OF ls_response-content.
    DATA lv_typename TYPE string.

    lv_typename = 'ty_' && is_operation-abap_name.

    LOOP AT is_operation-responses INTO ls_response.
      LOOP AT ls_response-content INTO ls_content.
        rs_returning-type = rs_returning-type &&
          |           { ls_response-code } TYPE { find_schema( ls_content-schema_ref )-abap_name },\n|.
      ENDLOOP.
    ENDLOOP.
    IF rs_returning-type IS NOT INITIAL.
      rs_returning-type =
        |  TYPES: BEGIN OF { lv_typename },\n| &&
        |{ rs_returning-type }| &&
        |         END OF { lv_typename }.\n|.
    ENDIF.

    LOOP AT is_operation-responses INTO ls_response.
      LOOP AT ls_response-content INTO ls_content.
        rs_returning-abap = rs_returning-abap && |\n    RETURNING\n      VALUE(return) TYPE { lv_typename }|.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.