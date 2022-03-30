CLASS zcl_icf_serv001 DEFINITION PUBLIC.
* auto generated, do not change
  PUBLIC SECTION.
    INTERFACES if_http_extension.
ENDCLASS.

CLASS zcl_icf_serv001 IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA handler TYPE REF TO zif_interface001.
    DATA path    TYPE string.
    CREATE OBJECT handler TYPE zcl_icf_impl001.
    path = server->request->get_header_field( '~path' ).
    CASE path.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.