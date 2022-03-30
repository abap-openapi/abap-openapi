CLASS zcl_oapi_generator_v2 DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             clas_icf_serv TYPE c LENGTH 30,
             clas_icf_impl TYPE c LENGTH 30,
             clas_client   TYPE c LENGTH 30,
             intf          TYPE c LENGTH 30,
             json          TYPE string,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
        clas_icf_serv TYPE string,
        clas_icf_impl TYPE string,
        clas_client   TYPE string,
        intf          TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING is_input TYPE ty_input
      RETURNING VALUE(rs_result) TYPE ty_result.

ENDCLASS.

CLASS zcl_oapi_generator_v2 IMPLEMENTATION.

  METHOD run.

    rs_result-clas_icf_serv = |CLASS { is_input-clas_icf_serv } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES if_http_extension.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_serv } IMPLEMENTATION.\n| &&
      |  METHOD if_http_extension~handle_request.\n| &&
      |    DATA handler TYPE REF TO { is_input-intf }.\n| &&
      |    DATA path    TYPE string.\n| &&
      |    CREATE OBJECT handler TYPE { is_input-clas_icf_impl }.\n| &&
      |    path = server->request->get_header_field( '~path' ).\n| &&
      |    CASE path.\n| &&
      |    ENDCASE.\n| &&
      |  ENDMETHOD.\n| &&
      |ENDCLASS.|.

    rs_result-clas_icf_impl = |CLASS { is_input-clas_icf_impl } DEFINITION PUBLIC.\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_icf_impl } IMPLEMENTATION.\n| &&
      |ENDCLASS.|.

    rs_result-clas_client = |CLASS { is_input-clas_client } DEFINITION PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |  PUBLIC SECTION.\n| &&
      |    INTERFACES { is_input-intf }.\n| &&
      |ENDCLASS.\n\n| &&
      |CLASS { is_input-clas_client } IMPLEMENTATION.\n| &&
      |ENDCLASS.|.

    rs_result-intf = |INTERFACE { is_input-intf } PUBLIC.\n| &&
      |* auto generated, do not change\n| &&
      |ENDINTERFACE.|.

  ENDMETHOD.

ENDCLASS.