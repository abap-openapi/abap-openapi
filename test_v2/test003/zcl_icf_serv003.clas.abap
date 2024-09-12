CLASS zcl_icf_serv003 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: c1_number_add_object
* Version: 1
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_icf_serv003 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA li_handler      TYPE REF TO zif_interface003.
    DATA lv_method       TYPE string.
    DATA lv_path         TYPE string.
    CREATE OBJECT li_handler TYPE zcl_icf_impl003.
    lv_path = server->request->get_header_field( '~path' ).
    REPLACE FIRST OCCURRENCE OF zif_interface003=>base_path IN lv_path WITH ''.
    lv_method = server->request->get_method( ).

    TRY.
        IF lv_path = '/test' AND lv_method = 'POST'.
          DATA _test TYPE zif_interface003=>posttestrequest.
          /ui2/cl_json=>deserialize(
            EXPORTING
              json = server->request->get_cdata( )
            CHANGING
              data = _test ).
          DATA r__test TYPE zif_interface003=>r__test.
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
