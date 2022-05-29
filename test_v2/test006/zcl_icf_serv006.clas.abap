CLASS zcl_icf_serv006 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
    METHODS parse_posttestresponse
      IMPORTING
        iv_prefix TYPE string OPTIONAL
      RETURNING
        VALUE(parsed) TYPE zif_interface006=>posttestresponse.
    METHODS parse_posttestrequest
      IMPORTING
        iv_prefix TYPE string OPTIONAL
      RETURNING
        VALUE(parsed) TYPE zif_interface006=>posttestrequest.
ENDCLASS.

CLASS zcl_icf_serv006 IMPLEMENTATION.
  METHOD parse_posttestresponse.
* todo
  ENDMETHOD.

  METHOD parse_posttestrequest.
* todo
  ENDMETHOD.

  METHOD if_http_extension~handle_request.
    DATA li_handler TYPE REF TO zif_interface006.
    DATA lv_method  TYPE string.
    DATA lv_path    TYPE string.

    CREATE OBJECT li_handler TYPE zcl_icf_impl006.
    lv_path = server->request->get_header_field( '~path' ).
    lv_method = server->request->get_method( ).

    TRY.
        IF lv_path = '/test' AND lv_method = 'POST'.
          li_handler->_test(
            separator = server->request->get_form_field( 'separator' )
            body = parse_posttestrequest( ) ).
        ENDIF.
      CATCH cx_static_check.
        ASSERT 1 = 'todo'.
    ENDTRY.

    server->response->set_content_type( 'text/html' ).
    server->response->set_cdata( 'todo' ).
    server->response->set_status( code = 200 reason = 'Success' ).
  ENDMETHOD.
ENDCLASS.