CLASS zcl_client020 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: any table body
* Version: 1
  PUBLIC SECTION.
    INTERFACES zif_interface020.
    "! Supply http client and possibily extra http headers to instantiate the openAPI client
    METHODS constructor
      IMPORTING
        ii_client        TYPE REF TO if_http_client
        iv_uri_prefix    TYPE string OPTIONAL
        it_extra_headers TYPE tihttpnvp OPTIONAL
        iv_timeout       TYPE i DEFAULT if_http_client=>co_timeout_default.
  PROTECTED SECTION.
    DATA mi_client        TYPE REF TO if_http_client.
    DATA mv_timeout       TYPE i.
    DATA mv_uri_prefix    TYPE string.
    DATA mt_extra_headers TYPE tihttpnvp.
ENDCLASS.

CLASS zcl_client020 IMPLEMENTATION.
  METHOD constructor.
    " Use cl_http_client=>create_by_destination() or cl_http_client=>create_by_url() to create the client
    " the caller must close() the client
    mi_client = ii_client.
    mv_timeout = iv_timeout.
    mv_uri_prefix = iv_uri_prefix.
    mt_extra_headers = it_extra_headers.
  ENDMETHOD.

  METHOD zif_interface020~send.
    DATA lv_code         TYPE i.
    DATA lv_message      TYPE string.
    DATA lv_uri          TYPE string.
    DATA ls_header       LIKE LINE OF mt_extra_headers.
    DATA lv_dummy        TYPE string.
    DATA lv_content_type TYPE string.

    mi_client->propertytype_logon_popup = if_http_client=>co_disabled.
    mi_client->request->set_method( 'POST' ).
    lv_uri = mv_uri_prefix && '/send'.
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
    mi_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).
    IF sy-subrc <> 0.
      mi_client->get_last_error(
        IMPORTING
          code    = lv_code
          message = lv_message ).
      ASSERT 1 = 2.
    ENDIF.

    lv_content_type = mi_client->response->get_content_type( ).
    mi_client->response->get_status( IMPORTING code = lv_code ).
    CASE lv_code.
      WHEN '200'.
* todo, no content types
      WHEN OTHERS.
* todo, error handling
    ENDCASE.

  ENDMETHOD.

ENDCLASS.