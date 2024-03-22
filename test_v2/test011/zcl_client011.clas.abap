CLASS zcl_client011 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
  PUBLIC SECTION.
    INTERFACES zif_interface011.
    METHODS constructor
      IMPORTING
        ii_client        TYPE REF TO if_http_client
        it_extra_headers TYPE tihttpnvp OPTIONAL
        iv_timeout       TYPE i DEFAULT if_http_client=>co_timeout_default.
  PROTECTED SECTION.
    DATA mi_client        TYPE REF TO if_http_client.
    DATA mv_timeout       TYPE i.
    DATA mt_extra_headers TYPE tihttpnvp.
ENDCLASS.

CLASS zcl_client011 IMPLEMENTATION.
  METHOD constructor.
    " Use cl_http_client=>create_by_destination() or cl_http_client=>create_by_url() to create the client
    " the caller must close() the client
    mi_client = ii_client.
    mv_timeout = iv_timeout.
    mt_extra_headers = it_extra_headers.
  ENDMETHOD.

  METHOD zif_interface011~_foo_param.
    DATA lv_code   TYPE i.
    DATA lv_uri    TYPE string.
    DATA ls_header LIKE LINE OF mt_extra_headers.

    mi_client->request->set_method( 'POST' ).
    lv_uri = '/foo/{param}'.
    REPLACE FIRST OCCURRENCE OF '{param}' IN lv_uri WITH param.
    cl_http_utility=>set_request_uri(
      request = mi_client->request
      uri     = lv_uri ).
    LOOP AT mt_extra_headers INTO ls_header.
      mi_client->request->set_header_field(
        name  = ls_header-name
        value = ls_header-value ).
    ENDLOOP.
    mi_client->request->set_data( '112233AABBCCDDEEFF' ).
    mi_client->send( mv_timeout ).
    mi_client->receive( ).

    mi_client->response->get_status( IMPORTING code = lv_code ).
    mi_client->response->get_data( ).
* todo
  ENDMETHOD.

ENDCLASS.