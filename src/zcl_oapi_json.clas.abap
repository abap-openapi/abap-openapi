CLASS zcl_oapi_json DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_json TYPE string.

    METHODS value_boolean
      IMPORTING
        iv_path        TYPE string
      RETURNING
        VALUE(rv_value) TYPE abap_bool.
    METHODS value_integer
      IMPORTING
        iv_path        TYPE string
      RETURNING
        VALUE(rv_value) TYPE i.
    METHODS value_number
      IMPORTING
        iv_path        TYPE string
      RETURNING
        VALUE(rv_value) TYPE i.
    METHODS value_string
      IMPORTING
        iv_path        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
    METHODS exists
      IMPORTING
        iv_path         TYPE string
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.
    METHODS members
      IMPORTING
        iv_path          TYPE string
      RETURNING
        VALUE(rt_members) TYPE string_table.

  PRIVATE SECTION.
    DATA mt_data TYPE lcl_parser=>ty_data_tt.

ENDCLASS.

CLASS zcl_oapi_json IMPLEMENTATION.
  METHOD constructor.
    DATA lo_parser TYPE REF TO lcl_parser.
    CREATE OBJECT lo_parser.
    mt_data = lo_parser->parse( iv_json ).
  ENDMETHOD.

  METHOD value_boolean.
    ASSERT 1 = 'todo'.
  ENDMETHOD.

  METHOD value_integer.
    ASSERT 1 = 'todo'.
  ENDMETHOD.

  METHOD value_number.
    ASSERT 1 = 'todo'.
  ENDMETHOD.

  METHOD value_string.
    ASSERT 1 = 'todo'.
  ENDMETHOD.

  METHOD exists.
    ASSERT 1 = 'todo'.
  ENDMETHOD.

  METHOD members.
    ASSERT 1 = 'todo'.
  ENDMETHOD.
ENDCLASS.