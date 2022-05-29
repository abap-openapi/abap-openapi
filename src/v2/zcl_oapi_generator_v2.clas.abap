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
    DATA ms_input TYPE ty_input.

    METHODS build_clas_icf_serv
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_clas_icf_impl
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_clas_client
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_intf
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

    METHODS dump_parser_methods
      RETURNING VALUE(rv_abap) TYPE string.
    METHODS dump_parser
      IMPORTING ii_schema TYPE REF TO zif_oapi_schema
                iv_abap_name TYPE string
                iv_hard_prefix TYPE string OPTIONAL
      RETURNING VALUE(rv_abap) TYPE string.
    METHODS find_parser_method
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_method) TYPE string.
    METHODS json_method_definitions RETURNING VALUE(rv_abap) TYPE string.
    METHODS json_method_implementations RETURNING VALUE(rv_abap) TYPE string.
ENDCLASS.

CLASS zcl_oapi_generator_v2 IMPLEMENTATION.

  METHOD find_parser_method.
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    ls_schema = find_schema( iv_name ).
    IF ls_schema IS NOT INITIAL.
      rv_method = ls_schema-abap_parser_method.
    ELSE.
      rv_method = 'unknown_not_found'.
    ENDIF.
  ENDMETHOD.

  METHOD dump_parser_methods.
* note: the parser methods might be called recursively, as the structures can be nested
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    LOOP AT ms_specification-components-schemas INTO ls_schema WHERE abap_parser_method IS NOT INITIAL.
      rv_abap = rv_abap &&
            |  METHOD { ls_schema-abap_parser_method }.\n|.
      rv_abap = rv_abap && dump_parser(
            ii_schema    = ls_schema-schema
            iv_abap_name = 'parsed' ).
      rv_abap = rv_abap && |  ENDMETHOD.\n\n|.
    ENDLOOP.
  ENDMETHOD.

  METHOD dump_parser.
    DATA ls_property TYPE zif_oapi_schema=>ty_property.
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lv_method TYPE string.

    CASE ii_schema->type.
      WHEN 'object'.
        LOOP AT ii_schema->properties INTO ls_property.
          IF ls_property-schema IS INITIAL AND ls_property-ref IS NOT INITIAL.
            lv_method = find_parser_method( ls_property-ref ).
            rv_abap = rv_abap && |    { iv_abap_name }-{ ls_property-abap_name } = { lv_method }( iv_prefix && '{ iv_hard_prefix }/{ ls_property-name }' ).\n|.
          ELSEIF ls_property-schema IS INITIAL.
            rv_abap = rv_abap && |* todo initial, hmm\n|.
          ELSEIF ls_property-schema->type = 'string'
              OR ls_property-schema->type = 'integer'.
            rv_abap = rv_abap && |    { iv_abap_name }-{ ls_property-abap_name } = json_value_string( iv_prefix && '{ iv_hard_prefix }/{ ls_property-name }' ).\n|.
          ELSEIF ls_property-schema->type = 'boolean'.
            rv_abap = rv_abap && |    { iv_abap_name }-{ ls_property-abap_name } = json_value_boolean( iv_prefix && '{ iv_hard_prefix }/{ ls_property-name }' ).\n|.
          ELSEIF ls_property-schema->type = 'object'.
            rv_abap = rv_abap && dump_parser(
              ii_schema    = ls_property-schema
              iv_hard_prefix = iv_hard_prefix && '/' && ls_property-name
              iv_abap_name = |{ iv_abap_name }-{ ls_property-abap_name }| ).
          ELSE.
            rv_abap = rv_abap && |* todo, { ls_property-schema->type }, { ls_property-abap_name }\n|.
          ENDIF.
        ENDLOOP.
      WHEN 'array'.
        IF ii_schema->items_ref IS NOT INITIAL.
          ls_schema = find_schema( ii_schema->items_ref ).
          rv_abap = rv_abap &&
            |    DATA lt_members TYPE string_table.\n| &&
            |    DATA lv_member LIKE LINE OF lt_members.\n| &&
            |    DATA { ls_schema-abap_name } TYPE { ms_input-intf }=>{ ls_schema-abap_name }.\n| &&
            |    lt_members = json_members( iv_prefix && '/' ).\n| &&
            |    LOOP AT lt_members INTO lv_member.\n| &&
            |      CLEAR { ls_schema-abap_name }.\n| &&
            |      { ls_schema-abap_name } = { ls_schema-abap_parser_method }( iv_prefix && '/' && lv_member ).\n| &&
            |      APPEND { ls_schema-abap_name } TO { iv_abap_name }.\n| &&
            |    ENDLOOP.\n|.
        ELSE.
          rv_abap = rv_abap && |* todo, handle type { ii_schema->type }, no item_ref\n|.
        ENDIF.
      WHEN 'integer'.
        rv_abap = rv_abap && |    { iv_abap_name } = json_value_integer( iv_prefix && '{ iv_hard_prefix }/{ ls_property-name }' ).\n|.
      WHEN OTHERS.
        rv_abap = rv_abap && |* todo, handle type { ii_schema->type }\n|.
    ENDCASE.
  ENDMETHOD.

  METHOD find_schema.
    DATA lv_name TYPE string.

    lv_name = iv_name.

    REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN lv_name WITH ''.
    READ TABLE ms_specification-components-schemas
      INTO rs_schema WITH KEY name = lv_name. "#EC CI_SUBRC
  ENDMETHOD.

  METHOD run.
    DATA lo_parser     TYPE REF TO zcl_oapi_parser.
    DATA lo_references TYPE REF TO zcl_oapi_references.

    ms_input = is_input.

    CREATE OBJECT lo_parser.
    ms_specification = lo_parser->parse( is_input-openapi_json ).

    CREATE OBJECT lo_references.
    ms_specification = lo_references->normalize( ms_specification ).

    rs_result-clas_icf_serv = build_clas_icf_serv( ).
    rs_result-clas_icf_impl = build_clas_icf_impl( ).
    rs_result-clas_client = build_clas_client( ).
    rs_result-intf = build_intf( ).
  ENDMETHOD.

  METHOD json_method_implementations.
    rv_abap = |  METHOD json_value_boolean.\n| &&
      |    rv_value = boolc( json_value_string( iv_path ) = 'true' ).\n| &&
      |  ENDMETHOD.\n| &&
      |\n| &&
      |  METHOD json_value_integer.\n| &&
      |    rv_value = json_value_string( iv_path ).\n| &&
      |  ENDMETHOD.\n| &&
      |\n| &&
      |  METHOD json_value_number.\n| &&
      |    rv_value = json_value_string( iv_path ).\n| &&
      |  ENDMETHOD.\n| &&
      |\n| &&
      |  METHOD json_value_string.\n| &&
      |    DATA ls_data LIKE LINE OF mt_json.\n| &&
      |    READ TABLE mt_json INTO ls_data WITH KEY full_name = iv_path.\n| &&
      |    IF sy-subrc = 0.\n| &&
      |      rv_value = ls_data-value.\n| &&
      |    ENDIF.\n| &&
      |  ENDMETHOD.\n| &&
      |\n| &&
      |  METHOD json_exists.\n| &&
      |    READ TABLE mt_json WITH KEY full_name = iv_path TRANSPORTING NO FIELDS.\n| &&
      |    rv_exists = boolc( sy-subrc = 0 ).\n| &&
      |  ENDMETHOD.\n| &&
      |\n| &&
      |  METHOD json_members.\n| &&
      |    DATA ls_data LIKE LINE OF mt_json.\n| &&
      |    LOOP AT mt_json INTO ls_data WHERE parent = iv_path.\n| &&
      |      APPEND ls_data-name TO rt_members.\n| &&
      |    ENDLOOP.\n| &&
      |  ENDMETHOD.\n| &&
      |\n|.
  ENDMETHOD.

  METHOD json_method_definitions.
    rv_abap = |\n| &&
      |    TYPES: BEGIN OF ty_json,\n| &&
      |             parent    TYPE string,\n| &&
      |             name      TYPE string,\n| &&
      |             full_name TYPE string,\n| &&
      |             value     TYPE string,\n| &&
      |           END OF ty_json.\n| &&
      |    TYPES ty_json_tt TYPE STANDARD TABLE OF ty_json WITH DEFAULT KEY.\n| &&
      |    DATA mt_json TYPE ty_json_tt.\n| &&
      |    METHODS json_value_boolean\n| &&
      |      IMPORTING iv_path         TYPE string\n| &&
      |      RETURNING VALUE(rv_value) TYPE abap_bool.\n| &&
      |    METHODS json_value_integer\n| &&
      |      IMPORTING iv_path         TYPE string\n| &&
      |      RETURNING VALUE(rv_value) TYPE i.\n| &&
      |    METHODS json_value_number\n| &&
      |      IMPORTING iv_path         TYPE string\n| &&
      |      RETURNING VALUE(rv_value) TYPE i.\n| &&
      |    METHODS json_value_string\n| &&
      |      IMPORTING iv_path         TYPE string\n| &&
      |      RETURNING VALUE(rv_value) TYPE string.\n| &&
      |    METHODS json_exists\n| &&
      |      IMPORTING iv_path          TYPE string\n| &&
      |      RETURNING VALUE(rv_exists) TYPE abap_bool.\n| &&
      |    METHODS json_members\n| &&
      |      IMPORTING iv_path           TYPE string\n| &&
      |      RETURNING VALUE(rt_members) TYPE string_table.\n|.
  ENDMETHOD.

  METHOD build_clas_icf_serv.
    DATA ls_operation  LIKE LINE OF ms_specification-operations.
    DATA lv_parameters TYPE string.
    DATA ls_parameter  LIKE LINE OF ls_operation-parameters.
    DATA ls_schema     LIKE LINE OF ms_specification-components-schemas.

    rv_abap = |CLASS { ms_input-clas_icf_serv } DEFINITION PUBLIC.\n| &&
      |* Auto generated by https://github.com/abap-openapi/abap-openapi\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES if_http_extension.\n| &&
      |  PRIVATE SECTION.\n|.

    LOOP AT ms_specification-components-schemas INTO ls_schema.
      rv_abap = rv_abap &&
        |    METHODS { ls_schema-abap_parser_method }\n| &&
        |      IMPORTING\n| &&
        |        iv_prefix TYPE string OPTIONAL\n| &&
        |      RETURNING\n| &&
        |        VALUE(parsed) TYPE { ms_input-intf }=>{ ls_schema-abap_name }.\n|.
    ENDLOOP.

    rv_abap = rv_abap &&
      json_method_definitions( ) &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-clas_icf_serv } IMPLEMENTATION.\n|.

    rv_abap = rv_abap
      && json_method_implementations( )
      && dump_parser_methods( ).

    rv_abap = rv_abap &&
      |  METHOD if_http_extension~handle_request.\n| &&
      |    DATA li_handler TYPE REF TO { ms_input-intf }.\n| &&
      |    DATA lv_method  TYPE string.\n| &&
      |    DATA lv_path    TYPE string.\n\n| &&
      |    CREATE OBJECT li_handler TYPE { ms_input-clas_icf_impl }.\n| &&
      |    lv_path = server->request->get_header_field( '~path' ).\n| &&
      |    lv_method = server->request->get_method( ).\n\n|.
    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |    CLEAR mt_json.\n| &&
        |    TRY.\n| &&
        |        IF lv_path = '{ ls_operation-path }' AND lv_method = '{ to_upper( ls_operation-method ) }'.\n|.

      CLEAR lv_parameters.
      LOOP AT ls_operation-parameters INTO ls_parameter WHERE in = 'query'.
        lv_parameters = lv_parameters &&
          |\n            { ls_parameter-abap_name } = server->request->get_form_field( '{ ls_parameter-name }' )|.
      ENDLOOP.
      IF ls_operation-body_schema_ref IS NOT INITIAL.
        lv_parameters = lv_parameters &&
          |\n            body = { find_schema( ls_operation-body_schema_ref )-abap_parser_method }( )|.
      ENDIF.

      rv_abap = rv_abap &&
        |          li_handler->{ ls_operation-abap_name }({ lv_parameters } ).\n| &&
        |        ENDIF.\n| &&
        |      CATCH cx_static_check.\n| &&
        |        ASSERT 1 = 'todo'.\n| &&
        |    ENDTRY.\n|.
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

    rv_abap = |CLASS { ms_input-clas_icf_impl } DEFINITION PUBLIC.\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { ms_input-intf }.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-clas_icf_impl } IMPLEMENTATION.\n\n|.

    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { ms_input-intf }~{ ls_operation-abap_name }.\n| &&
        |* Add implementation logic here\n| &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_clas_client.
    DATA ls_operation LIKE LINE OF ms_specification-operations.

    rv_abap = |CLASS { ms_input-clas_client } DEFINITION PUBLIC.\n| &&
      |* Auto generated by https://github.com/abap-openapi/abap-openapi\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { ms_input-intf }.\n| &&
      |    METHODS constructor\n| &&
      |      IMPORTING\n| &&
      |        iv_url    TYPE string\n| &&
      |        iv_ssl_id TYPE ssfapplssl OPTIONAL.\n| &&
      |  PROTECTED SECTION.\n| &&
      |    DATA mi_client TYPE REF TO if_http_client.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-clas_client } IMPLEMENTATION.\n| &&
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
        |  METHOD { ms_input-intf }~{ ls_operation-abap_name }.\n| &&
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

    rv_abap = |INTERFACE { ms_input-intf } PUBLIC.\n| &&
      |* Auto generated by https://github.com/abap-openapi/abap-openapi\n\n|.

    LOOP AT ms_specification-components-schemas INTO ls_component_schema.
      rv_abap = rv_abap && |* { ls_component_schema-name }\n|.
      rv_abap = rv_abap && ls_component_schema-schema->build_type_definition2(
        iv_name          = ls_component_schema-abap_name
        is_specification = ms_specification ).
    ENDLOOP.

    rv_abap = rv_abap && |\n|.

    LOOP AT ms_specification-operations INTO ls_operation.
      ls_returning = find_returning_parameter( ls_operation ).
      rv_abap = rv_abap && ls_returning-type &&
        |  METHODS { ls_operation-abap_name }{
          find_input_parameters( ls_operation ) }{
          ls_returning-abap }\n    RAISING\n      cx_static_check.\n|.
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

    lv_typename = 'ret_' && is_operation-abap_name.

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
        rs_returning-abap = rs_returning-abap &&
          |\n    RETURNING\n      VALUE(return) TYPE { lv_typename }|.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.