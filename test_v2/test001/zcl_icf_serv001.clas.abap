CLASS zcl_icf_serv001 DEFINITION PUBLIC.
* auto generated, do not change
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS zcl_icf_serv001 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA li_handler TYPE REF TO zif_interface001.
    DATA lv_method  TYPE string.
    DATA lv_path    TYPE string.

    CREATE OBJECT li_handler TYPE zcl_icf_impl001.
    lv_path = server->request->get_header_field( '~path' ).
    lv_method = server->request->get_method( ).

    IF lv_path = '/ping' AND lv_method = 'POST'.
      li_handler->_ping( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.