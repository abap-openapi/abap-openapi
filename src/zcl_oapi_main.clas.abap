CLASS zcl_oapi_main DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             class_name     TYPE c LENGTH 30,
             interface_name TYPE c LENGTH 30,
             json           TYPE string,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
        clas TYPE string,
        intf TYPE string,
* todo, skip_deprecated default true
      END OF ty_result.

    METHODS run
      IMPORTING is_input TYPE ty_input
      RETURNING VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    DATA ms_specification TYPE zif_oapi_specification_v3=>ty_specification.
    DATA ms_input TYPE ty_input.

    METHODS operation_implementation
      IMPORTING is_operation TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_return
      IMPORTING is_operation TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING VALUE(rs_type) TYPE zif_oapi_specification_v3=>ty_component_schema.

    METHODS build_abap_parameters
      IMPORTING is_operation TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_class
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS build_interface
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS dump_types
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS dump_parser_methods
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS dump_json_methods
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS dump_json
      IMPORTING ii_schema TYPE REF TO zif_oapi_schema
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_parser_method
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_method) TYPE string.

    METHODS abap_schema_to_json
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_schema
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rs_schema) TYPE zif_oapi_specification_v3=>ty_component_schema.

    METHODS dump_parser
      IMPORTING ii_schema TYPE REF TO zif_oapi_schema
                iv_abap_name TYPE string
                iv_hard_prefix TYPE string OPTIONAL
      RETURNING VALUE(rv_abap) TYPE string.

    METHODS find_uri_prefix
      IMPORTING is_servers LIKE ms_specification-servers
      RETURNING VALUE(rv_prefix) TYPE string.

ENDCLASS.

CLASS zcl_oapi_main IMPLEMENTATION.

  METHOD run.
    DATA lo_parser TYPE REF TO zcl_oapi_parser.
    DATA lo_references TYPE REF TO zcl_oapi_references.

    ASSERT is_input-class_name IS NOT INITIAL.
    ASSERT is_input-interface_name IS NOT INITIAL.
    ASSERT is_input-json IS NOT INITIAL.
    ms_input = is_input.

    CREATE OBJECT lo_parser.
    ms_specification = lo_parser->parse( is_input-json ).

    CREATE OBJECT lo_references.
    ms_specification = lo_references->fix( ms_specification ).

    rs_result-clas = build_class( ).
    rs_result-intf = build_interface( ).

  ENDMETHOD.

  METHOD build_class.

    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_parameter TYPE zif_oapi_specification_v3=>ty_parameter.
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.

    rv_abap =
      |CLASS { ms_input-class_name } DEFINITION PUBLIC.\n| &&
      |* Generated by abap-openapi-client\n| &&
      |* { ms_specification-info-title }, { ms_specification-info-version }\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { ms_input-interface_name }.\n| &&
      |    METHODS constructor IMPORTING ii_client TYPE REF TO if_http_client.\n| &&
      |  PROTECTED SECTION.\n| &&
      |    DATA mi_client TYPE REF TO if_http_client.\n| &&
      |    DATA mo_json TYPE REF TO zcl_oapi_json.\n| &&
      |    METHODS send_receive RETURNING VALUE(rv_code) TYPE i.\n|.

    LOOP AT ms_specification-components-schemas INTO ls_schema.
      IF ls_schema-abap_parser_method IS NOT INITIAL.
        rv_abap = rv_abap &&
          |    METHODS { ls_schema-abap_parser_method }\n| &&
          |      IMPORTING iv_prefix TYPE string\n| &&
          |      RETURNING VALUE({ ls_schema-abap_name }) TYPE { ms_input-interface_name }=>{ ls_schema-abap_name }\n| &&
          |      RAISING cx_static_check.\n|.
      ENDIF.
      IF ls_schema-abap_json_method IS NOT INITIAL.
        rv_abap = rv_abap &&
          |    METHODS { ls_schema-abap_json_method }\n| &&
          |      IMPORTING data TYPE { ms_input-interface_name }=>{ ls_schema-abap_name }\n| &&
          |      RETURNING VALUE(json) TYPE string\n| &&
          |      RAISING cx_static_check.\n|.
      ENDIF.
    ENDLOOP.

    rv_abap = rv_abap &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-class_name } IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |    mi_client = ii_client.\n| &&
      |  ENDMETHOD.\n\n| &&
      |  METHOD send_receive.\n| &&
      |    mi_client->send( ).\n| &&
      |    mi_client->receive( ).\n| &&
      |    mi_client->response->get_status( IMPORTING code = rv_code ).\n| &&
      |  ENDMETHOD.\n\n|.

    rv_abap = rv_abap && dump_parser_methods( ) && dump_json_methods( ).

    LOOP AT ms_specification-operations INTO ls_operation WHERE deprecated = abap_false.
      rv_abap = rv_abap &&
        |  METHOD { ms_input-interface_name }~{ ls_operation-abap_name }.\n| &&
        operation_implementation( ls_operation ) &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.\n|.

  ENDMETHOD.

  METHOD dump_json_methods.
* note: the parser methods might be called recursively, as the structures can be nested

    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.


    LOOP AT ms_specification-components-schemas INTO ls_schema WHERE abap_json_method IS NOT INITIAL.
      rv_abap = rv_abap && |  METHOD { ls_schema-abap_json_method }.\n|.
      rv_abap = rv_abap && dump_json( ls_schema-schema ).
      rv_abap = rv_abap && |  ENDMETHOD.\n\n|.
    ENDLOOP.

  ENDMETHOD.

  METHOD dump_json.
    DATA ls_property TYPE zif_oapi_schema=>ty_property.

    CASE ii_schema->type.
      WHEN 'object'.
        rv_abap = rv_abap && |    json = json && '\{'.\n|.
        LOOP AT ii_schema->properties INTO ls_property.
          IF ls_property-schema IS NOT INITIAL
              AND ls_property-schema->is_simple_type( ) = abap_true.
            CASE ls_property-schema->type.
              WHEN 'integer'.
                rv_abap = rv_abap && |    IF data-{ ls_property-abap_name } <> cl_abap_math=>max_int4.\n|.
                rv_abap = rv_abap && |      json = json && \|"{ ls_property-name }": \{ data-{ ls_property-abap_name } \},\|.\n|.
                rv_abap = rv_abap && |    ENDIF.\n|.
              WHEN 'boolean'.
                rv_abap = rv_abap && |    IF data-{ ls_property-abap_name } = abap_true.\n|.
                rv_abap = rv_abap && |      json = json && \|"{ ls_property-name }": true,\|.\n|.
                rv_abap = rv_abap && |    ELSEIF data-{ ls_property-abap_name } = abap_false.\n|.
                rv_abap = rv_abap && |      json = json && \|"{ ls_property-name }": false,\|.\n|.
                rv_abap = rv_abap && |    ENDIF.\n|.
              WHEN OTHERS.
                rv_abap = rv_abap && |    json = json && \|"{ ls_property-name }": "\{ data-{ ls_property-abap_name } \}",\|.\n|.
            ENDCASE.
          ELSE.
            rv_abap = rv_abap && |*  json = json && '"{ ls_property-name }":' not simple\n|.
          ENDIF.
        ENDLOOP.
        rv_abap = rv_abap && |    json = substring( val = json off = 0 len = strlen( json ) - 1 ).\n|.
        rv_abap = rv_abap && |    json = json && '\}'.\n|.
      WHEN 'array'.
        rv_abap = rv_abap && |    json = json && '['.\n|.
        rv_abap = rv_abap && |* todo, array\n|.
        rv_abap = rv_abap && |    json = json && ']'.\n|.
      WHEN OTHERS.
        rv_abap = rv_abap && |* todo, { ii_schema->type }\n|.
    ENDCASE.
  ENDMETHOD.

  METHOD dump_parser_methods.
* note: the parser methods might be called recursively, as the structures can be nested

    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.


    LOOP AT ms_specification-components-schemas INTO ls_schema WHERE abap_parser_method IS NOT INITIAL.
      rv_abap = rv_abap &&
        |  METHOD { ls_schema-abap_parser_method }.\n|.
      rv_abap = rv_abap && dump_parser(
        ii_schema    = ls_schema-schema
        iv_abap_name = ls_schema-abap_name ).
      rv_abap = rv_abap && |  ENDMETHOD.\n\n|.
    ENDLOOP.

  ENDMETHOD.

  METHOD find_schema.

    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lv_name TYPE string.

    lv_name = iv_name.

    REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN lv_name WITH ''.
    READ TABLE ms_specification-components-schemas INTO rs_schema WITH KEY name = lv_name. "#EC CI_SUBRC

  ENDMETHOD.

  METHOD find_parser_method.

    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.

    ls_schema = find_schema( iv_name ).
    IF ls_schema IS NOT INITIAL.
      rv_method = ls_schema-abap_parser_method.
    ELSE.
      rv_method = 'unknown_not_found'.
    ENDIF.

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
            rv_abap = rv_abap && |    { iv_abap_name }-{ ls_property-abap_name } = { lv_method }( iv_prefix ).\n|.
          ELSEIF ls_property-schema IS INITIAL.
            rv_abap = rv_abap && |* todo initial, hmm\n|.
          ELSEIF ls_property-schema->type = 'string'
              OR ls_property-schema->type = 'integer'.
            rv_abap = rv_abap && |    { iv_abap_name }-{ ls_property-abap_name } = mo_json->value_string( iv_prefix && '{ iv_hard_prefix }/{ ls_property-name }' ).\n|.
          ELSEIF ls_property-schema->type = 'boolean'.
            rv_abap = rv_abap && |    { iv_abap_name }-{ ls_property-abap_name } = mo_json->value_boolean( iv_prefix && '{ iv_hard_prefix }/{ ls_property-name }' ).\n|.
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
            |    DATA { ls_schema-abap_name } TYPE { ms_input-interface_name }=>{ ls_schema-abap_name }.\n| &&
            |    lt_members = mo_json->members( iv_prefix && '/' ).\n| &&
            |    LOOP AT lt_members INTO lv_member.\n| &&
            |      CLEAR { ls_schema-abap_name }.\n| &&
            |      { ls_schema-abap_name } = { ls_schema-abap_parser_method }( iv_prefix && '/' && lv_member ).\n| &&
            |      APPEND { ls_schema-abap_name } TO { iv_abap_name }.\n| &&
            |    ENDLOOP.\n|.
        ELSE.
          rv_abap = rv_abap && |* todo, handle type { ii_schema->type }, no item_ref\n|.
        ENDIF.
      WHEN 'integer'.
        rv_abap = rv_abap && |    { iv_abap_name } = mo_json->value_integer( iv_prefix && '{ iv_hard_prefix }/{ ls_property-name }' ).\n|.
      WHEN OTHERS.
        rv_abap = rv_abap && |* todo, handle type { ii_schema->type }\n|.
    ENDCASE.
  ENDMETHOD.

  METHOD dump_types.

    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA ls_property TYPE zif_oapi_schema=>ty_property.
    DATA lv_count TYPE i.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    LOOP AT ms_specification-components-schemas INTO ls_schema.
      lo_names->add_used( ls_schema-abap_name ).
    ENDLOOP.

    LOOP AT ms_specification-components-schemas INTO ls_schema.
      rv_abap = rv_abap && |* Component schema: { ls_schema-name }, { ls_schema-schema->type }\n|.
      rv_abap = rv_abap && ls_schema-schema->build_type_definition(
        iv_name  = ls_schema-abap_name
        io_names = lo_names
        it_refs  = ms_specification-components-schemas ).
      rv_abap = rv_abap && |\n|.
    ENDLOOP.

  ENDMETHOD.

  METHOD build_interface.

    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_parameter LIKE LINE OF ls_operation-parameters.
    DATA ls_response LIKE LINE OF ls_operation-responses.
    DATA ls_content LIKE LINE OF ls_response-content.
    DATA ls_return TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lv_required TYPE string.
    DATA lv_extra TYPE string.
    DATA lv_ref TYPE string.

    rv_abap = |INTERFACE { ms_input-interface_name } PUBLIC.\n| &&
      |* Generated by abap-openapi-client\n| &&
      |* { ms_specification-info-title }, { ms_specification-info-version }\n\n|.

    rv_abap = rv_abap && dump_types( ).

    LOOP AT ms_specification-operations INTO ls_operation WHERE deprecated = abap_false.
      rv_abap = rv_abap &&
        |* { to_upper( ls_operation-method ) } - "{ ls_operation-summary }"\n|.
      IF ls_operation-operation_id IS NOT INITIAL.
        rv_abap = rv_abap && |* Operation id: { ls_operation-operation_id }\n|.
      ENDIF.
      LOOP AT ls_operation-parameters INTO ls_parameter.
        IF ls_parameter-required = abap_true.
          lv_required = 'required'.
        ELSE.
          lv_required = 'optional'.
        ENDIF.
        rv_abap = rv_abap &&
          |* Parameter: { ls_parameter-name }, { lv_required }, { ls_parameter-in }\n|.
      ENDLOOP.
      LOOP AT ls_operation-responses INTO ls_response.
        rv_abap = rv_abap &&
          |* Response: { ls_response-code }\n|.
        LOOP AT ls_response-content INTO ls_content.
          IF ls_content-schema_ref IS NOT INITIAL.
            lv_extra = |, { ls_content-schema_ref }|.
          ELSE.
            lv_extra = |, { ls_content-schema->type }|.
          ENDIF.
          rv_abap = rv_abap &&
            |*     { ls_content-type }{ lv_extra }\n|.
        ENDLOOP.
      ENDLOOP.
      IF ls_operation-body_schema_ref IS NOT INITIAL.
        rv_abap = rv_abap &&
          |* Body ref: { ls_operation-body_schema_ref }\n|.
      ELSEIF ls_operation-body_schema IS NOT INITIAL.
        rv_abap = rv_abap &&
          |* Body schema: { ls_operation-body_schema->type }\n|.
      ENDIF.
      rv_abap = rv_abap &&
        |  METHODS { ls_operation-abap_name }{ build_abap_parameters( ls_operation ) }|.
      ls_return = find_return( ls_operation ).
      IF ls_return IS NOT INITIAL.
        rv_abap = rv_abap &&
          |    RETURNING\n| &&
          |      VALUE(return_data) TYPE { ls_return-abap_name }\n|.
      ENDIF.
      rv_abap = rv_abap && |    RAISING cx_static_check.\n\n|.
    ENDLOOP.
    rv_abap = rv_abap && |ENDINTERFACE.\n|.

  ENDMETHOD.

  METHOD find_uri_prefix.
    DATA ls_server LIKE LINE OF ms_specification-servers.
    READ TABLE is_servers INDEX 1 INTO ls_server.
    IF sy-subrc = 0.
      rv_prefix = ls_server-url.
      IF rv_prefix CP 'http*'.
        FIND REGEX '\w(\/[\w\d\.\-\/]+)' IN ls_server-url SUBMATCHES rv_prefix. "#EC CI_SUBRC
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD operation_implementation.

    DATA ls_parameter LIKE LINE OF is_operation-parameters.
    DATA ls_return TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lv_value TYPE string.

    rv_abap =
      |    DATA lv_code TYPE i.\n| &&
      |    DATA lv_temp TYPE string.\n| &&
      |    DATA lv_uri TYPE string VALUE '{ find_uri_prefix( ms_specification-servers ) }{ is_operation-path }'.\n|.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'path'.
      IF ls_parameter-schema->type = 'string'.
        rv_abap = rv_abap &&
          |    REPLACE ALL OCCURRENCES OF '\{{ ls_parameter-name }\}' IN lv_uri WITH { ls_parameter-abap_name }.\n|.
      ELSE.
        rv_abap = rv_abap &&
          |    lv_temp = { ls_parameter-abap_name }.\n| &&
          |    CONDENSE lv_temp.\n| &&
          |    REPLACE ALL OCCURRENCES OF '\{{ ls_parameter-name }\}' IN lv_uri WITH lv_temp.\n|.
      ENDIF.
    ENDLOOP.

    LOOP AT is_operation-parameters INTO ls_parameter WHERE in = 'query'.
      lv_value = ls_parameter-abap_name.
      IF ls_parameter-schema->type <> 'string'.
* todo, booleans and other types should also be converted
        rv_abap = rv_abap && |    lv_temp = { lv_value }.\n|.
        rv_abap = rv_abap && |    CONDENSE lv_temp.\n|.
        lv_value = 'lv_temp'.
      ENDIF.
      IF ls_parameter-required = abap_false.
        rv_abap = rv_abap &&
          |    IF { ls_parameter-abap_name } IS SUPPLIED.\n| &&
          |      mi_client->request->set_form_field( name = '{ ls_parameter-name }' value = { lv_value } ).\n| &&
          |    ENDIF.\n|.
      ELSE.
        rv_abap = rv_abap &&
          |    mi_client->request->set_form_field( name = '{ ls_parameter-name }' value = { lv_value } ).\n|.
      ENDIF.
    ENDLOOP.

    rv_abap = rv_abap &&
      |    mi_client->request->set_method( '{ to_upper( is_operation-method ) }' ).\n| &&
      |    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).\n|.
*      |    mi_client->request->set_header_field( name = 'Content-Type' value = 'todo' ).\n| &&
*      |    mi_client->request->set_header_field( name = 'Accept'       value = 'todo' ).\n| &&

    IF is_operation-body_schema_ref IS NOT INITIAL.
      rv_abap = rv_abap && abap_schema_to_json( is_operation-body_schema_ref ).
    ELSEIF is_operation-body_schema IS NOT INITIAL AND is_operation-body_schema->type = 'string'.
      rv_abap = rv_abap && |    mi_client->request->set_cdata( body ).\n|.
    ENDIF.

    rv_abap = rv_abap &&
      |    lv_code = send_receive( ).\n| &&
      |    WRITE / lv_code.\n|.
* todo, accept and check content types

    ls_return = find_return( is_operation ).
    IF ls_return IS NOT INITIAL.
      rv_abap = rv_abap &&
        |    CREATE OBJECT mo_json EXPORTING iv_json = mi_client->response->get_cdata( ).\n| &&
        |    return_data = { ls_return-abap_parser_method }( '' ).\n|.
    ELSE.
      rv_abap = rv_abap &&
        |    WRITE / mi_client->response->get_cdata( ).\n| &&
        |* todo, handle more responses\n|.
    ENDIF.

  ENDMETHOD.

  METHOD abap_schema_to_json.
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    ls_schema = find_schema( iv_name ).
    IF ls_schema IS NOT INITIAL.
      IF ls_schema-abap_json_method IS NOT INITIAL.
        rv_abap = |    mi_client->request->set_cdata( { ls_schema-abap_json_method }( body ) ).\n|.
      ELSE.
        rv_abap = |* todo, set body, { iv_name }\n|.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD find_return.

    DATA ls_response LIKE LINE OF is_operation-responses.
    DATA ls_content LIKE LINE OF ls_response-content.

    LOOP AT is_operation-responses INTO ls_response.
      IF ls_response-code = '200'
          OR ls_response-code = '201'
          OR ls_response-code = '204'.
* todo, handle basic types
        READ TABLE ls_response-content INTO ls_content WITH KEY type = 'application/json'.
        IF sy-subrc = 0 AND ls_content-schema_ref IS NOT INITIAL.
          rs_type = find_schema( ls_content-schema_ref ).
          IF rs_type IS NOT INITIAL.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD build_abap_parameters.

    DATA ls_parameter TYPE zif_oapi_specification_v3=>ty_parameter.
    DATA lt_tab TYPE string_table.
    DATA ls_schema TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lv_type TYPE string.
    DATA lv_text TYPE string.
    DATA lv_default TYPE string.

    LOOP AT is_operation-parameters INTO ls_parameter.
      lv_type = ls_parameter-schema->get_simple_type( ).
      IF lv_type IS INITIAL.
        lv_type = 'string'. " todo, at this point there should only be simple or referenced types?
      ENDIF.

      CLEAR lv_default.
      IF ls_parameter-schema IS NOT INITIAL AND ls_parameter-schema->default IS NOT INITIAL.
        IF ls_parameter-schema->default CO '0123456789'.
          lv_default = | DEFAULT { ls_parameter-schema->default }|.
        ELSEIF ls_parameter-schema->type = 'boolean'.
          lv_default = | DEFAULT abap_{ ls_parameter-schema->default }|.
        ELSE.
          lv_default = | DEFAULT '{ ls_parameter-schema->default }'|.
        ENDIF.
      ENDIF.

      lv_text = |      | && ls_parameter-abap_name && | TYPE | && lv_type && lv_default.
      IF ls_parameter-required = abap_false AND lv_default IS INITIAL.
        lv_text = lv_text && | OPTIONAL|.
      ENDIF.
      APPEND lv_text TO lt_tab.
    ENDLOOP.

    IF lines( lt_tab ) > 0.
      lv_text = concat_lines_of( table = lt_tab
                                 sep = |\n| ).
    ENDIF.

    IF is_operation-body_schema_ref IS NOT INITIAL.
      ls_schema = find_schema( is_operation-body_schema_ref ).
      IF ls_schema IS NOT INITIAL.
        IF lv_text IS NOT INITIAL.
          lv_text = lv_text && |\n|.
        ENDIF.
        lv_text = lv_text &&
          |      body TYPE { ls_schema-abap_name }|.
      ENDIF.
    ELSEIF is_operation-body_schema IS NOT INITIAL AND is_operation-body_schema->type = 'string'.
      IF lv_text IS NOT INITIAL.
        lv_text = lv_text && |\n|.
      ENDIF.
      lv_text = lv_text &&
        |      body TYPE string|.
    ENDIF.

    IF lv_text IS NOT INITIAL.
      rv_abap = |\n    IMPORTING\n| && lv_text && |\n|.
    ELSE.
      rv_abap = |\n|.
    ENDIF.

  ENDMETHOD.

ENDCLASS.