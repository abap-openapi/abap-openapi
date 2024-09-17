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
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA ms_specification TYPE zif_oapi_specification_v3=>ty_specification.
    DATA ms_input TYPE ty_input.

    METHODS build_clas_icf_serv
      RETURNING
        VALUE(rv_abap) TYPE string.

    METHODS build_clas_icf_impl
      RETURNING
        VALUE(rv_abap) TYPE string.

    METHODS build_clas_client
      RETURNING
        VALUE(rv_abap) TYPE string.

    METHODS build_intf
      RETURNING
        VALUE(rv_abap) TYPE string.

    METHODS find_input_parameters
      IMPORTING
        is_operation   TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING
        VALUE(rv_abap) TYPE string.

    TYPES: BEGIN OF ty_returning,
             abap TYPE string,
             type TYPE string,
           END OF ty_returning.
    METHODS find_returning_parameter
      IMPORTING
        is_operation        TYPE zif_oapi_specification_v3=>ty_operation
      RETURNING
        VALUE(rs_returning) TYPE ty_returning.

    METHODS find_schema
      IMPORTING
        iv_name          TYPE string
      RETURNING
        VALUE(rs_schema) TYPE zif_oapi_specification_v3=>ty_component_schema.

    METHODS generation_information
      RETURNING
        VALUE(rv_info) TYPE string.

ENDCLASS.



CLASS zcl_oapi_generator_v2 IMPLEMENTATION.

  METHOD generation_information.

    rv_info =
      |* Auto generated by https://github.com/abap-openapi/abap-openapi\n|.

    IF ms_specification-info-title IS NOT INITIAL.
      rv_info = rv_info && |* Title: { ms_specification-info-title }\n|.
    ENDIF.
    IF ms_specification-info-description IS NOT INITIAL.
      rv_info = rv_info && |* Description: { ms_specification-info-description }\n|.
    ENDIF.
    IF ms_specification-info-version IS NOT INITIAL.
      rv_info = rv_info && |* Version: { ms_specification-info-version }\n|.
    ENDIF.

  ENDMETHOD.

  METHOD find_schema.
    DATA lv_name TYPE string.

    lv_name = iv_name.

    REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN lv_name WITH ''.
    READ TABLE ms_specification-components-schemas
      INTO rs_schema WITH KEY name = lv_name.             "#EC CI_SUBRC
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


  METHOD build_clas_icf_serv.
    DATA ls_operation  LIKE LINE OF ms_specification-operations.
    DATA lv_parameters TYPE string.
    DATA lv_typename   TYPE string.
    DATA lv_post       TYPE string.
    DATA lv_pre        TYPE string.
    DATA ls_response   LIKE LINE OF ls_operation-responses.
    DATA ls_content    LIKE LINE OF ls_response-content.
    DATA ls_parameter  LIKE LINE OF ls_operation-parameters.
    DATA lo_response_name TYPE REF TO zcl_oapi_response_name.
    DATA lv_response_name TYPE string.
    DATA lv_code TYPE string.

    CREATE OBJECT lo_response_name.

    rv_abap = |CLASS { ms_input-clas_icf_serv } DEFINITION PUBLIC.\n| &&
      generation_information( ) &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES if_http_extension.\n| &&
      |  PRIVATE SECTION.\n|.

    rv_abap = rv_abap &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-clas_icf_serv } IMPLEMENTATION.\n|.

    rv_abap = rv_abap &&
      |  METHOD if_http_extension~handle_request.\n| &&
      |    DATA li_handler      TYPE REF TO { ms_input-intf }.\n| &&
      |    DATA lv_method       TYPE string.\n| &&
      |    DATA lv_path         TYPE string.\n| &&
      |    CREATE OBJECT li_handler TYPE { ms_input-clas_icf_impl }.\n| &&
      |    lv_path = server->request->get_header_field( '~path' ).\n| &&
      |    REPLACE FIRST OCCURRENCE OF { ms_input-intf }=>base_path IN lv_path WITH ''.\n| &&
      |    lv_method = server->request->get_method( ).\n\n|.
    LOOP AT ms_specification-operations INTO ls_operation.
* todo, handing path parameters, do wildcard with CP?
      rv_abap = rv_abap &&
        |    TRY.\n| &&
        |        IF lv_path = '{ ls_operation-path }' AND lv_method = '{ to_upper( ls_operation-method ) }'.\n|.

      CLEAR lv_parameters.
      IF lines( ls_operation-parameters ) = 1 AND ls_operation-request_body-schema_ref IS INITIAL.
        READ TABLE ls_operation-parameters INDEX 1 INTO ls_parameter ##SUBRC_OK.
* todo, it might be a header parameter
        IF ls_parameter-in = 'path'.
          lv_parameters = | server->request->get_form_field( 'todo' )|.
        ELSE.
          lv_parameters = | server->request->get_form_field( '{ ls_parameter-name }' )|.
        ENDIF.
      ELSE.
        LOOP AT ls_operation-parameters INTO ls_parameter.
          CASE ls_parameter-in.
            WHEN 'query'.
              lv_parameters = lv_parameters &&
                |\n            { ls_parameter-abap_name } = server->request->get_form_field( '{ ls_parameter-name }' )|.
            WHEN OTHERS.
              lv_parameters = lv_parameters &&
                |\n            { ls_parameter-abap_name } = '{ ls_parameter-in }-todo'|.
          ENDCASE.
        ENDLOOP.


        IF ls_operation-request_body-schema_ref IS NOT INITIAL.
          rv_abap = rv_abap &&
            |          DATA { ls_operation-abap_name  } TYPE { ms_input-intf }=>{ find_schema( ls_operation-request_body-schema_ref )-abap_name }.\n| &&
            |          /ui2/cl_json=>deserialize(\n| &&
            |            EXPORTING\n| &&
            |              json = server->request->get_cdata( )\n| &&
            |            CHANGING\n| &&
            |              data = { ls_operation-abap_name } ).\n|.
          lv_parameters = lv_parameters &&
            |\n            body = { ls_operation-abap_name }|.
        ELSEIF ls_operation-request_body-schema IS NOT INITIAL.
          lv_parameters = lv_parameters &&
            |\n            body = 'todo'|.
        ENDIF.
      ENDIF.

      lv_typename = 'r_' && ls_operation-abap_name.

      CLEAR lv_post.
      LOOP AT ls_operation-responses INTO ls_response.
        IF ls_response-code = 'default'.
          READ TABLE ls_operation-responses WITH KEY code = '200' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_code = '400'.
          ELSE.
            lv_code = '200'.
          ENDIF.
        ELSE.
          lv_code = ls_response-code.
        ENDIF.
        LOOP AT ls_response-content INTO ls_content.

          lv_response_name = lo_response_name->generate_response_name( iv_content_type = ls_content-type
                                                                       iv_code         = ls_response-code ).

          lv_post = lv_post &&
            |          IF { lv_typename }-{ lv_response_name } IS NOT INITIAL.\n| &&
            |            server->response->set_content_type( '{ ls_content-type }' ).\n| &&
            |            server->response->set_cdata( /ui2/cl_json=>serialize( { lv_typename }-{ lv_response_name } ) ).\n| &&
            |            server->response->set_status( code = { lv_code } reason = '{ ls_response-description }' ).\n| &&
            |            RETURN.\n| &&
            |          ENDIF.\n|.
        ENDLOOP.
      ENDLOOP.
      IF lv_post IS NOT INITIAL.
        lv_pre =
          |          DATA { lv_typename } TYPE { ms_input-intf }=>{ lv_typename }.\n| &&
          |          { lv_typename } = |.
      ELSE.
        lv_pre = |          |.
        lv_post = |          RETURN.\n|.
      ENDIF.

      rv_abap = rv_abap &&
        lv_pre &&
        |li_handler->{ ls_operation-abap_name }({ lv_parameters } ).\n| &&
        lv_post &&
        |        ENDIF.\n| &&
        |      CATCH cx_static_check.\n| &&
        |        server->response->set_content_type( 'text/plain' ).\n| &&
        |        server->response->set_cdata( 'exception' ).\n| &&
        |        server->response->set_status( code = 500 reason = 'Error' ).\n| &&
        |    ENDTRY.\n|.
    ENDLOOP.
    rv_abap = rv_abap &&
      |\n| &&
      |    server->response->set_content_type( 'text/plain' ).\n| &&
      |    server->response->set_cdata( 'no handler found' ).\n| &&
      |    server->response->set_status( code = 500 reason = 'Error' ).\n| &&
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
    DATA ls_parameter LIKE LINE OF ls_operation-parameters.
    DATA ls_response  LIKE LINE OF ls_operation-responses.
    DATA ls_content   LIKE LINE OF ls_response-content.
    DATA lo_response_name TYPE REF TO zcl_oapi_response_name.
    DATA lv_name TYPE string.

    CREATE OBJECT lo_response_name.

    rv_abap = |CLASS { ms_input-clas_client } DEFINITION PUBLIC.\n| &&
      generation_information( ) &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { ms_input-intf }.\n| &&
      |    "! Supply http client and possibily extra http headers to instantiate the openAPI client\n| &&
      |    "! Use cl_http_client=>create_by_destination() or cl_http_client=>create_by_url() to create the client\n| &&
      |    "! the caller must close() the client\n| &&
      |    METHODS constructor\n| &&
      |      IMPORTING\n| &&
      |        ii_client        TYPE REF TO if_http_client\n| &&
      |        iv_uri_prefix    TYPE string OPTIONAL\n| &&
      |        it_extra_headers TYPE tihttpnvp OPTIONAL\n| &&
      |        iv_timeout       TYPE i DEFAULT if_http_client=>co_timeout_default.\n| &&
      |  PROTECTED SECTION.\n| &&
      |    DATA mi_client        TYPE REF TO if_http_client.\n| &&
      |    DATA mv_timeout       TYPE i.\n| &&
      |    DATA mv_uri_prefix    TYPE string.\n| &&
      |    DATA mt_extra_headers TYPE tihttpnvp.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { ms_input-clas_client } IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |    mi_client = ii_client.\n| &&
      |    mv_timeout = iv_timeout.\n| &&
      |    mv_uri_prefix = iv_uri_prefix.\n| &&
      |    mt_extra_headers = it_extra_headers.\n| &&
      |  ENDMETHOD.\n\n|.

    LOOP AT ms_specification-operations INTO ls_operation.
      rv_abap = rv_abap &&
        |  METHOD { ms_input-intf }~{ ls_operation-abap_name }.\n| &&
        |    DATA lv_code         TYPE i.\n| &&
        |    DATA lv_message      TYPE string.\n| &&
        |    DATA lv_uri          TYPE string.\n| &&
        |    DATA ls_header       LIKE LINE OF mt_extra_headers.\n| &&
        |    DATA lv_dummy        TYPE string.\n| &&
        |    DATA lv_content_type TYPE string.\n| &&
        |\n| &&
        |    mi_client->propertytype_logon_popup = if_http_client=>co_disabled.\n| &&
        |    mi_client->request->set_method( '{ to_upper( ls_operation-method ) }' ).\n| &&
        |    lv_uri = mv_uri_prefix && '{ ls_operation-path }'.\n|.

      LOOP AT ls_operation-parameters INTO ls_parameter.
        CASE ls_parameter-in.
          WHEN 'header'.
            rv_abap = rv_abap &&
              |    mi_client->request->set_header_field(\n| &&
              |      name  = '{ ls_parameter-name }'\n| &&
              |      value = { ls_parameter-abap_name } ).\n|.
          WHEN 'path'.
            rv_abap = rv_abap &&
              |    REPLACE FIRST OCCURRENCE OF '\{{ ls_parameter-name }\}' IN lv_uri WITH { ls_parameter-abap_name }.\n|.
          WHEN OTHERS.
            rv_abap = rv_abap &&
              |" todo, in={ ls_parameter-in } name={ ls_parameter-name }\n|.
        ENDCASE.
      ENDLOOP.

      rv_abap = rv_abap &&
        |    cl_http_utility=>set_request_uri(\n| &&
        |      request = mi_client->request\n| &&
        |      uri     = lv_uri ).\n| &&
        |    LOOP AT mt_extra_headers INTO ls_header.\n| &&
        |      mi_client->request->set_header_field(\n| &&
        |        name  = ls_header-name\n| &&
        |        value = ls_header-value ).\n| &&
        |    ENDLOOP.\n|.

      IF ls_operation-request_body-type IS NOT INITIAL.
        rv_abap = rv_abap && |    mi_client->request->set_content_type( '{ ls_operation-request_body-type }' ).\n|.
      ENDIF.

      IF ls_operation-request_body-schema IS NOT INITIAL.
        CASE ls_operation-request_body-schema->get_simple_type( ).
          WHEN 'xstring'.
            rv_abap = rv_abap && |    mi_client->request->set_data( body ).\n|.
          WHEN 'string'.
            rv_abap = rv_abap && |    mi_client->request->set_cdata( body ).\n|.
        ENDCASE.
      ENDIF.

      rv_abap = rv_abap &&
        |    mi_client->send( mv_timeout ).\n| &&
        |    mi_client->receive(\n| &&
        |      EXCEPTIONS\n| &&
        |        http_communication_failure = 1\n| &&
        |        http_invalid_state         = 2\n| &&
        |        http_processing_failed     = 3\n| &&
        |        OTHERS                     = 4 ).\n| &&
        |    IF sy-subrc <> 0.\n| &&
        |      mi_client->get_last_error(\n| &&
        |        IMPORTING\n| &&
        |          code    = lv_code\n| &&
        |          message = lv_message ).\n| &&
        |      ASSERT 1 = 2.\n| &&
        |    ENDIF.\n| &&
        |\n| &&
        |    lv_content_type = mi_client->response->get_content_type( ).\n| &&
        |    mi_client->response->get_status( IMPORTING code = lv_code ).\n| &&
        |    CASE lv_code.\n|.

      LOOP AT ls_operation-responses INTO ls_response.
        rv_abap = rv_abap &&
          |      WHEN '{ ls_response-code }'.\n|.

        IF lines( ls_response-content ) > 0.
          rv_abap = rv_abap &&
            |        SPLIT lv_content_type AT ';' INTO lv_content_type lv_dummy.\n| &&
            |        CASE lv_content_type.\n|.
          LOOP AT ls_response-content INTO ls_content.
            rv_abap = rv_abap &&
              |          WHEN '{ ls_content-type }'.\n|.
            IF ls_content-type = 'application/json'
                OR ls_content-type CP 'application/*#+json'.
              lv_name = lo_response_name->generate_response_name(
                iv_content_type = ls_content-type
                iv_code         = ls_response-code ).

              rv_abap = rv_abap &&
                |            /ui2/cl_json=>deserialize(\n| &&
                |              EXPORTING json = mi_client->response->get_cdata( )\n| &&
                |              CHANGING data = return-{ lv_name } ).\n|.
            ELSE.
              rv_abap = rv_abap &&
                |* todo, content type = '{ ls_content-type }'\n|.
            ENDIF.
          ENDLOOP.
          rv_abap = rv_abap &&
            |          WHEN OTHERS.\n| &&
            |* unexpected content type\n| &&
            |        ENDCASE.\n|.
        ELSE.
          rv_abap = rv_abap &&
            |* todo, no content types\n|.
        ENDIF.
      ENDLOOP.

      rv_abap = rv_abap &&
        |      WHEN OTHERS.\n| &&
        |* todo, error handling\n| &&
        |    ENDCASE.\n\n| &&
        |  ENDMETHOD.\n\n|.
    ENDLOOP.

    rv_abap = rv_abap && |ENDCLASS.|.
  ENDMETHOD.


  METHOD build_intf.
    DATA ls_operation LIKE LINE OF ms_specification-operations.
    DATA ls_returning TYPE ty_returning.
    DATA ls_component_schema LIKE LINE OF ms_specification-components-schemas.
    DATA ls_server LIKE LINE OF ms_specification-servers.

    rv_abap = |INTERFACE { ms_input-intf } PUBLIC.\n| &&
      generation_information( ) &&
      |\n|.

    IF ms_specification-servers IS NOT INITIAL.
      READ TABLE ms_specification-servers INDEX 1 INTO ls_server.
      IF sy-subrc = 0.
        rv_abap = rv_abap && |  CONSTANTS base_path TYPE string VALUE '{ ls_server-url }'.\n\n|.
      ENDIF.
    ELSE.
      rv_abap = rv_abap && |  CONSTANTS base_path TYPE string VALUE ''.\n\n|.
    ENDIF.


    LOOP AT ms_specification-components-schemas INTO ls_component_schema.
      rv_abap = rv_abap && |* { ls_component_schema-name }\n|.
      rv_abap = rv_abap && ls_component_schema-schema->build_type_definition2(
        iv_name          = ls_component_schema-abap_name
        is_specification = ms_specification ).
    ENDLOOP.
    IF sy-subrc = 0.
      rv_abap = rv_abap && |\n|.
    ENDIF.

    LOOP AT ms_specification-operations INTO ls_operation.
      ls_returning = find_returning_parameter( ls_operation ).
      rv_abap = rv_abap && ls_returning-type.
      IF ls_operation-summary IS NOT INITIAL.
        rv_abap = rv_abap && |  "! { ls_operation-summary }\n|.
      ENDIF.
      rv_abap = rv_abap && |  METHODS { ls_operation-abap_name }{
          find_input_parameters( ls_operation ) }{
          ls_returning-abap }\n    RAISING\n      cx_static_check.\n|.
    ENDLOOP.
    rv_abap = rv_abap && |ENDINTERFACE.|.
  ENDMETHOD.


  METHOD find_input_parameters.
    DATA lt_list        TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_str         TYPE string.
    DATA ls_parameter   LIKE LINE OF is_operation-parameters.
    DATA lv_simple_type TYPE string.

    LOOP AT is_operation-parameters INTO ls_parameter.
      IF ls_parameter-schema->type = 'array'.
        lv_simple_type = 'string_table'.
      ELSE.
        lv_simple_type = ls_parameter-schema->get_simple_type( ).
      ENDIF.

      lv_str = |      { ls_parameter-abap_name } TYPE { lv_simple_type }|.
      IF ls_parameter-required = abap_false.
        lv_str = lv_str && | OPTIONAL|.
      ENDIF.
      APPEND lv_str TO lt_list.
    ENDLOOP.

    IF is_operation-request_body-schema_ref IS NOT INITIAL.
      lv_str = |      body TYPE { find_schema( is_operation-request_body-schema_ref )-abap_name }|.
      APPEND lv_str TO lt_list.
    ELSEIF is_operation-request_body-schema IS NOT INITIAL.
      lv_str = |      body TYPE { is_operation-request_body-schema->get_simple_type( ) }|.
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
    DATA lv_typename TYPE char30.
    DATA lo_response_name TYPE REF TO zcl_oapi_response_name.
    DATA lv_response_name TYPE string.
    DATA lv_returning_type TYPE string.

    CREATE OBJECT lo_response_name.

    lv_typename = 'r_' && is_operation-abap_name.

    LOOP AT is_operation-responses INTO ls_response.
      LOOP AT ls_response-content INTO ls_content.
        lv_response_name = lo_response_name->generate_response_name( iv_content_type = ls_content-type
                                                                     iv_code         = ls_response-code ).
        IF ls_content-schema_ref = space.
          lv_returning_type = ls_content-schema->type.
        ELSE.
          lv_returning_type = find_schema( ls_content-schema_ref )-abap_name.
        ENDIF.
        rs_returning-type = rs_returning-type &&
              |           { lv_response_name } TYPE { lv_returning_type },\n|.
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
        RETURN. " exit method, as only one return parameter is allowed
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
