CLASS zcl_oapi_json DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_json TYPE string.

    METHODS value_boolean
      IMPORTING
        iv_path         TYPE string
      RETURNING
        VALUE(rv_value) TYPE abap_bool.
    METHODS value_integer
      IMPORTING
        iv_path         TYPE string
      RETURNING
        VALUE(rv_value) TYPE i.
    METHODS value_number
      IMPORTING
        iv_path         TYPE string
      RETURNING
        VALUE(rv_value) TYPE i.
    METHODS value_string
      IMPORTING
        iv_path         TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
    METHODS exists
      IMPORTING
        iv_path          TYPE string
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.
    METHODS members
      IMPORTING
        iv_path           TYPE string
      RETURNING
        VALUE(rt_members) TYPE string_table.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mt_data TYPE ty_data_tt.
ENDCLASS.



CLASS zcl_oapi_json IMPLEMENTATION.


  METHOD constructor.
    DATA lo_parser TYPE REF TO lcl_parser.
    CREATE OBJECT lo_parser.
    mt_data = lo_parser->parse( iv_json ).
  ENDMETHOD.


  METHOD exists.
    READ TABLE mt_data WITH KEY full_name = iv_path TRANSPORTING NO FIELDS.
    rv_exists = boolc( sy-subrc = 0 ).
  ENDMETHOD.


  METHOD members.
    DATA ls_data LIKE LINE OF mt_data.
    LOOP AT mt_data INTO ls_data WHERE parent = iv_path.
      APPEND ls_data-name TO rt_members.
    ENDLOOP.
  ENDMETHOD.


  METHOD value_boolean.
    rv_value = boolc( value_string( iv_path ) = 'true' ).
  ENDMETHOD.


  METHOD value_integer.
    rv_value = value_string( iv_path ).
  ENDMETHOD.


  METHOD value_number.
    rv_value = value_string( iv_path ).
  ENDMETHOD.


  METHOD value_string.
    DATA ls_data LIKE LINE OF mt_data.
    READ TABLE mt_data INTO ls_data WITH KEY full_name = iv_path.
    IF sy-subrc = 0.
      rv_value = ls_data-value.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
