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
    TYPES: BEGIN OF ty_value,
             full_name TYPE string,
             value     TYPE string,
           END OF ty_value.
    TYPES: BEGIN OF ty_members,
             parent  TYPE string,
             members TYPE string_table,
           END OF ty_members.
* indexes built once in the constructor, the lookups are called very often
    DATA mt_values TYPE HASHED TABLE OF ty_value WITH UNIQUE KEY full_name.
    DATA mt_members TYPE HASHED TABLE OF ty_members WITH UNIQUE KEY parent.
ENDCLASS.



CLASS zcl_oapi_json IMPLEMENTATION.


  METHOD constructor.
    DATA lo_parser  TYPE REF TO lcl_parser.
    DATA lt_data    TYPE ty_data_tt.
    DATA ls_data    LIKE LINE OF lt_data.
    DATA ls_value   TYPE ty_value.
    DATA ls_members TYPE ty_members.
    FIELD-SYMBOLS <ls_members> TYPE ty_members.

    CREATE OBJECT lo_parser.
    lt_data = lo_parser->parse( iv_json ).

    LOOP AT lt_data INTO ls_data.
* first occurrence wins, in case of duplicate keys
      ls_value-full_name = ls_data-full_name.
      ls_value-value = ls_data-value.
      INSERT ls_value INTO TABLE mt_values.

      READ TABLE mt_members ASSIGNING <ls_members> WITH TABLE KEY parent = ls_data-parent.
      IF sy-subrc <> 0.
        CLEAR ls_members.
        ls_members-parent = ls_data-parent.
        INSERT ls_members INTO TABLE mt_members ASSIGNING <ls_members>.
      ENDIF.
      APPEND ls_data-name TO <ls_members>-members.
    ENDLOOP.
  ENDMETHOD.


  METHOD exists.
    READ TABLE mt_values WITH TABLE KEY full_name = iv_path TRANSPORTING NO FIELDS.
    rv_exists = boolc( sy-subrc = 0 ).
  ENDMETHOD.


  METHOD members.
    DATA ls_members LIKE LINE OF mt_members.
    READ TABLE mt_members INTO ls_members WITH TABLE KEY parent = iv_path.
    IF sy-subrc = 0.
      rt_members = ls_members-members.
    ENDIF.
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
    DATA ls_value LIKE LINE OF mt_values.
    READ TABLE mt_values INTO ls_value WITH TABLE KEY full_name = iv_path.
    IF sy-subrc = 0.
      rv_value = ls_value-value.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
