CLASS zcl_client004 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: c1_string_concat_table
* Version: 1
  PUBLIC SECTION.
    INTERFACES zif_interface004.
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

CLASS zcl_client004 IMPLEMENTATION.
  METHOD constructor.
    " Use cl_http_client=>create_by_destination() or cl_http_client=>create_by_url() to create the client
    " the caller must close() the client
    mi_client = ii_client.
    mv_timeout = iv_timeout.
    mt_extra_headers = it_extra_headers.
  ENDMETHOD.

  METHOD zif_interface004~_test.
    DATA lv_code         TYPE i.
    DATA lv_uri          TYPE string.
    DATA ls_header       LIKE LINE OF mt_extra_headers.
    DATA lv_content_type TYPE string.

    mi_client->request->set_method( 'POST' ).
    lv_uri = '/test'.
" todo, in=query name=operation
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

    lv_content_type = mi_client->response->get_content_type( ).
    mi_client->response->get_status( IMPORTING code = lv_code ).
    CASE lv_code.
      WHEN '200'.
        CASE lv_content_type.
          WHEN 'application/json'.
            mi_client->response->get_cdata( ).
        ENDCASE.
      WHEN OTHERS.
* todo, error handling
    ENDCASE.
  ENDMETHOD.

ENDCLASS.