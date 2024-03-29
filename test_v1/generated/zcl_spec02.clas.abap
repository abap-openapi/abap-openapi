CLASS zcl_spec02 DEFINITION PUBLIC.
* Generated by abap-openapi-client
* ping, 1
  PUBLIC SECTION.
    INTERFACES zif_spec02.
    METHODS constructor IMPORTING ii_client TYPE REF TO if_http_client.
  PROTECTED SECTION.
    DATA mi_client TYPE REF TO if_http_client.
    DATA mo_json TYPE REF TO zcl_oapi_json.
    METHODS send_receive RETURNING VALUE(rv_code) TYPE i.
ENDCLASS.

CLASS zcl_spec02 IMPLEMENTATION.
  METHOD constructor.
    mi_client = ii_client.
  ENDMETHOD.

  METHOD send_receive.
    mi_client->send( ).
    mi_client->receive( ).
    mi_client->response->get_status( IMPORTING code = rv_code ).
  ENDMETHOD.

  METHOD zif_spec02~_ping.
    DATA lv_code TYPE i.
    DATA lv_temp TYPE string.
    DATA lv_uri TYPE string VALUE '/ping'.
    mi_client->request->set_method( 'POST' ).
    mi_client->request->set_header_field( name = '~request_uri' value = lv_uri ).
    lv_code = send_receive( ).
    WRITE / lv_code.
    CASE lv_code.
      WHEN 200. " ping
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
