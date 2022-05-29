CLASS zcl_icf_serv007 DEFINITION PUBLIC.
* Auto generated by https://github.com/abap-openapi/abap-openapi
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PRIVATE SECTION.
    METHODS parse_resultstruct
      IMPORTING
        iv_prefix TYPE string OPTIONAL
      RETURNING
        VALUE(parsed) TYPE zif_interface007=>resultstruct.
    METHODS parse_string1andstring2
      IMPORTING
        iv_prefix TYPE string OPTIONAL
      RETURNING
        VALUE(parsed) TYPE zif_interface007=>string1andstring2.
    METHODS parse_posttestresponse
      IMPORTING
        iv_prefix TYPE string OPTIONAL
      RETURNING
        VALUE(parsed) TYPE zif_interface007=>posttestresponse.
    METHODS parse_posttestrequest
      IMPORTING
        iv_prefix TYPE string OPTIONAL
      RETURNING
        VALUE(parsed) TYPE zif_interface007=>posttestrequest.

    TYPES: BEGIN OF ty_json,
             parent    TYPE string,
             name      TYPE string,
             full_name TYPE string,
             value     TYPE string,
           END OF ty_json.
    TYPES ty_json_tt TYPE STANDARD TABLE OF ty_json WITH DEFAULT KEY.
    DATA mt_json TYPE ty_json_tt.
    METHODS json_parse
      IMPORTING iv_json TYPE string.
    METHODS json_value_boolean
      IMPORTING iv_path         TYPE string
      RETURNING VALUE(rv_value) TYPE abap_bool.
    METHODS json_value_integer
      IMPORTING iv_path         TYPE string
      RETURNING VALUE(rv_value) TYPE i.
    METHODS json_value_number
      IMPORTING iv_path         TYPE string
      RETURNING VALUE(rv_value) TYPE i.
    METHODS json_value_string
      IMPORTING iv_path         TYPE string
      RETURNING VALUE(rv_value) TYPE string.
    METHODS json_exists
      IMPORTING iv_path          TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.
    METHODS json_members
      IMPORTING iv_path           TYPE string
      RETURNING VALUE(rt_members) TYPE string_table.
ENDCLASS.

CLASS zcl_icf_serv007 IMPLEMENTATION.
  METHOD json_parse.
    CLEAR mt_json.
* todo.
  ENDMETHOD.

  METHOD json_value_boolean.
    rv_value = boolc( json_value_string( iv_path ) = 'true' ).
  ENDMETHOD.

  METHOD json_value_integer.
    rv_value = json_value_string( iv_path ).
  ENDMETHOD.

  METHOD json_value_number.
    rv_value = json_value_string( iv_path ).
  ENDMETHOD.

  METHOD json_value_string.
    DATA ls_data LIKE LINE OF mt_json.
    READ TABLE mt_json INTO ls_data WITH KEY full_name = iv_path.
    IF sy-subrc = 0.
      rv_value = ls_data-value.
    ENDIF.
  ENDMETHOD.

  METHOD json_exists.
    READ TABLE mt_json WITH KEY full_name = iv_path TRANSPORTING NO FIELDS.
    rv_exists = boolc( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD json_members.
    DATA ls_data LIKE LINE OF mt_json.
    LOOP AT mt_json INTO ls_data WHERE parent = iv_path.
      APPEND ls_data-name TO rt_members.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_resultstruct.
    parsed-result = json_value_string( iv_prefix && '/result' ).
  ENDMETHOD.

  METHOD parse_string1andstring2.
    parsed-string1 = json_value_string( iv_prefix && '/string1' ).
    parsed-string2 = json_value_string( iv_prefix && '/string2' ).
  ENDMETHOD.

  METHOD parse_posttestresponse.
* todo, array, levela1
* todo, array, levelb11
    parsed-levelc1 = json_value_string( iv_prefix && '/levelC1' ).
  ENDMETHOD.

  METHOD parse_posttestrequest.
* todo, array, levela1
* todo, array, levelb11
* todo, array, levelc1
  ENDMETHOD.

  METHOD if_http_extension~handle_request.
    DATA li_handler TYPE REF TO zif_interface007.
    DATA lv_method  TYPE string.
    DATA lv_path    TYPE string.

    CREATE OBJECT li_handler TYPE zcl_icf_impl007.
    lv_path = server->request->get_header_field( '~path' ).
    lv_method = server->request->get_method( ).

    CLEAR mt_json.
    TRY.
        IF lv_path = '/test' AND lv_method = 'POST'.
          json_parse( 'todo' ).
          li_handler->_test(
            separator = server->request->get_form_field( 'separator' )
            body = parse_posttestrequest( ) ).
        ENDIF.
      CATCH cx_static_check.
        ASSERT 1 = 'todo'.
    ENDTRY.

    server->response->set_content_type( 'text/html' ).
    server->response->set_cdata( 'todo' ).
    server->response->set_status( code = 200 reason = 'Success' ).
  ENDMETHOD.
ENDCLASS.