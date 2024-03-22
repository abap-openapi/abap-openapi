CLASS zcl_client007 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
  PUBLIC SECTION.
    INTERFACES zif_interface007.
    METHODS constructor
      IMPORTING
        ii_client  TYPE REF TO if_http_client
        iv_timeout TYPE i DEFAULT if_http_client=>co_timeout_default.
  PROTECTED SECTION.
    DATA mi_client  TYPE REF TO if_http_client.
    DATA mv_timeout TYPE i.
ENDCLASS.

CLASS zcl_client007 IMPLEMENTATION.
  METHOD constructor.
    " Use cl_http_client=>create_by_destination() or cl_http_client=>create_by_url() to create the client
    " the caller must close() the client
    mi_client = ii_client.
    mv_timeout = iv_timeout.
  ENDMETHOD.

  METHOD zif_interface007~_test.
    DATA lv_code TYPE i.

    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_data( '112233AABBCCDDEEFF' ).
    mi_client->send( mv_timeout ).
    mi_client->receive( ).

    mi_client->response->get_status( IMPORTING code = lv_code ).
    mi_client->response->get_data( ).
* todo
  ENDMETHOD.

ENDCLASS.