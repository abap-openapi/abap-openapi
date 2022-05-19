CLASS zcl_oapi_generator_v2 DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             clas_icf_serv TYPE c LENGTH 30,
             clas_icf_impl TYPE c LENGTH 30,
             clas_client   TYPE c LENGTH 30,
             intf          TYPE c LENGTH 30,
             openapi_json  TYPE string,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
        clas_icf_serv TYPE string,
        clas_icf_impl TYPE string,
        clas_client   TYPE string,
        intf          TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING
        is_input TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS build_clas_icf_serv
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.
    METHODS build_clas_icf_impl
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.
    METHODS build_clas_client
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.
    METHODS build_intf
      IMPORTING
        is_input TYPE ty_input
      RETURNING VALUE(rv_abap) TYPE string.

ENDCLASS.

CLASS zcl_oapi_generator_v2 IMPLEMENTATION.

  METHOD run.
    rs_result-clas_icf_serv = build_clas_icf_serv( is_input ).
    rs_result-clas_icf_impl = build_clas_icf_impl( is_input ).
    rs_result-clas_client   = build_clas_client( is_input ).
    rs_result-intf          = build_intf( is_input ).
  ENDMETHOD.

  METHOD build_clas_icf_serv.
    rv_abap = |CLASS { is_input-clas_icf_serv } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES if_http_extension.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_serv } IMPLEMENTATION.\n| &&
      |  METHOD if_http_extension~handle_request.\n| &&
      |    DATA handler TYPE REF TO { is_input-intf }.\n| &&
      |    DATA method  TYPE string.\n| &&
      |    DATA path    TYPE string.\n\n| &&
      |    CREATE OBJECT handler TYPE { is_input-clas_icf_impl }.\n| &&
      |    path = server->request->get_header_field( '~path' ).\n| &&
      |    method = server->request->get_method( ).\n| &&
      |* todo, operations here\n| &&
      |  ENDMETHOD.\n| &&
      |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_clas_icf_impl.
    rv_abap = |CLASS { is_input-clas_icf_impl } DEFINITION PUBLIC.\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_impl } IMPLEMENTATION.\n| &&
      |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_clas_client.
    rv_abap = |CLASS { is_input-clas_client } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |    METHODS constructor IMPORTING host TYPE string.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_client } IMPLEMENTATION.\n| &&
      |  METHOD constructor.\n| &&
      |* todo, instantiate CL_HTTP_CLIENT here\n| &&
      |  ENDMETHOD.\n| &&
      |* todo, operations here\n| &&
      |ENDCLASS.|.
  ENDMETHOD.

  METHOD build_intf.
    rv_abap = |INTERFACE { is_input-intf } PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |* todo, operations here\n| &&
      |ENDINTERFACE.|.
  ENDMETHOD.

ENDCLASS.