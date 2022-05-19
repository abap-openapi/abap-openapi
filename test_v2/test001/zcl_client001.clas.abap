CLASS zcl_client001 DEFINITION PUBLIC.
* auto generated, do not change
  PUBLIC SECTION.
    INTERFACES zif_interface001.
    METHODS constructor
      IMPORTING
        iv_url    TYPE string
        iv_ssl_id TYPE ssfapplssl OPTIONAL.
  PROTECTED SECTION.
    DATA mi_client TYPE REF TO if_http_client.
ENDCLASS.

CLASS zcl_client001 IMPLEMENTATION.
  METHOD constructor.
    cl_http_client=>create_by_url(
      EXPORTING
        url    = iv_url
        ssl_id = iv_ssl_id
      IMPORTING
        client = mi_client ).
  ENDMETHOD.

  METHOD zif_interface001~_ping.
    mi_client->request->set_method( 'POST' ).
* todo
  ENDMETHOD.

ENDCLASS.