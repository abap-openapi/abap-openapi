CLASS zcl_client011 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
  PUBLIC SECTION.
    INTERFACES zif_interface011.
    METHODS constructor
      IMPORTING
        iv_destination TYPE rfcdest.
  PROTECTED SECTION.
    DATA mi_client TYPE REF TO if_http_client.
ENDCLASS.

CLASS zcl_client011 IMPLEMENTATION.
  METHOD constructor.
    cl_http_client=>create_by_destination(
      EXPORTING
        destination = iv_destination
      IMPORTING
        client = mi_client ).
  ENDMETHOD.

  METHOD zif_interface011~_foo_param.
    DATA lv_code TYPE i.

    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_data( '112233AABBCCDDEEFF' ).
    mi_client->send( ).
    mi_client->receive( ).

    mi_client->response->get_status( IMPORTING code = lv_code ).
    mi_client->response->get_data( ).
* todo
  ENDMETHOD.

ENDCLASS.