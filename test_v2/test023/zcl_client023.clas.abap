CLASS zcl_client023 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
* Title: text body
* Version: 1
  PUBLIC SECTION.
    INTERFACES zif_interface023.
    "! Supply http client and possibily extra http headers to instantiate the openAPI client
    "! Use cl_http_client=>create_by_destination() or cl_http_client=>create_by_url() to create the client
    "! the caller must close() the client
    METHODS constructor
      IMPORTING
        ii_client        TYPE REF TO if_http_client
        iv_uri_prefix    TYPE string OPTIONAL
        it_extra_headers TYPE tihttpnvp OPTIONAL
        iv_logon_popup   TYPE i DEFAULT if_http_client=>co_disabled
        iv_timeout       TYPE i DEFAULT if_http_client=>co_timeout_default.
  PROTECTED SECTION.
    DATA mi_client        TYPE REF TO if_http_client.
    DATA mv_timeout       TYPE i.
    DATA mv_logon_popup   TYPE i.
    DATA mv_uri_prefix    TYPE string.
    DATA mt_extra_headers TYPE tihttpnvp.
ENDCLASS.

CLASS zcl_client023 IMPLEMENTATION.
  METHOD constructor.
    mi_client = ii_client.
    mv_timeout = iv_timeout.
    mv_logon_popup = iv_logon_popup.
    mv_uri_prefix = iv_uri_prefix.
    mt_extra_headers = it_extra_headers.
  ENDMETHOD.

ENDCLASS.
