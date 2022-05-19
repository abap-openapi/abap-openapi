CLASS zcl_icf_serv004 DEFINITION PUBLIC.
* auto generated, do not change
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS zcl_icf_serv004 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA li_handler TYPE REF TO zif_interface004.
    DATA lv_method  TYPE string.
    DATA lv_path    TYPE string.

    CREATE OBJECT li_handler TYPE zcl_icf_impl004.
    lv_path = server->request->get_header_field( '~path' ).
    lv_method = server->request->get_method( ).

    IF lv_path = '/test' AND lv_method = 'POST'.
      li_handler->_test( ).
    ENDIF.

    server->response->set_content_type( 'text/html' ).
    server->response->set_cdata( 'todo' ).
    server->response->set_status( code = 200 reason = 'Success' ).
  ENDMETHOD.
ENDCLASS.