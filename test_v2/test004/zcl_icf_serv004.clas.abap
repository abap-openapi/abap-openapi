CLASS zcl_icf_serv004 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: c1_string_concat_table
* Version: 1
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_icf_serv004 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA li_handler      TYPE REF TO zif_interface004.
    DATA lv_method       TYPE string.
    DATA lv_path         TYPE string.
    DATA lv_handler_path TYPE string.

    CREATE OBJECT li_handler TYPE zcl_icf_impl004.
    lv_path = server->request->get_header_field( '~path' ).
    lv_method = server->request->get_method( ).

    TRY.
        CONCATENATE zif_interface004=>base_path '/test' INTO lv_handler_path.
        IF lv_path = lv_handler_path AND lv_method = 'POST'.
          DATA _test TYPE zif_interface004=>posttestrequest.
          /ui2/cl_json=>deserialize(
            EXPORTING
              json = server->request->get_cdata( )
            CHANGING
              data = _test ).
          DATA r__test TYPE zif_interface004=>r__test.
          r__test = li_handler->_test(
            operation = server->request->get_form_field( 'operation' )
            body = _test ).
          IF r__test-_200_app_json IS NOT INITIAL.
            server->response->set_content_type( 'application/json' ).
            server->response->set_cdata( /ui2/cl_json=>serialize( r__test-_200_app_json ) ).
            server->response->set_status( code = 200 reason = 'OK' ).
            RETURN.
          ENDIF.
        ENDIF.
      CATCH cx_static_check.
        server->response->set_content_type( 'text/plain' ).
        server->response->set_cdata( 'exception' ).
        server->response->set_status( code = 500 reason = 'Error' ).
    ENDTRY.

    server->response->set_content_type( 'text/plain' ).
    server->response->set_cdata( 'no handler found' ).
    server->response->set_status( code = 500 reason = 'Error' ).
  ENDMETHOD.
ENDCLASS.