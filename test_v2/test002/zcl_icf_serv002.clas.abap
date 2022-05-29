CLASS zcl_icf_serv002 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS zcl_icf_serv002 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA li_handler TYPE REF TO zif_interface002.
    DATA lv_method  TYPE string.
    DATA lv_path    TYPE string.

    CREATE OBJECT li_handler TYPE zcl_icf_impl002.
    lv_path = server->request->get_header_field( '~path' ).
    lv_method = server->request->get_method( ).

    TRY.
        IF lv_path = '/test' AND lv_method = 'POST'.
          DATA ls_body TYPE zif_interface002=>posttestrequest.
          li_handler->_test(
            operation = server->request->get_form_field( 'operation' )
            body = ls_body ).
        ENDIF.
      CATCH cx_static_check.
        ASSERT 1 = 'todo'.
    ENDTRY.

    server->response->set_content_type( 'text/html' ).
    server->response->set_cdata( 'todo' ).
    server->response->set_status( code = 200 reason = 'Success' ).
  ENDMETHOD.
ENDCLASS.