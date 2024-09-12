CLASS ltcl_abap_name DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_oapi_abap_name.

    METHODS setup.
    METHODS normal FOR TESTING RAISING cx_static_check.
    METHODS with_space FOR TESTING RAISING cx_static_check.
    METHODS max_abap_name_length FOR TESTING RAISING cx_static_check.
    METHODS camel_to_snake1 FOR TESTING RAISING cx_static_check.
    METHODS camel_to_snake2 FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_abap_name IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT mo_cut.
  ENDMETHOD.

  METHOD normal.

    DATA lv_abap_name TYPE string.

    lv_abap_name = mo_cut->to_abap_name( 'foo_bar' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_abap_name
      exp = 'foo_bar' ).

  ENDMETHOD.

  METHOD with_space.

    DATA lv_abap_name TYPE string.

    lv_abap_name = mo_cut->to_abap_name( 'foo bar' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_abap_name
      exp = 'foo_bar' ).

  ENDMETHOD.

  METHOD max_abap_name_length.
    DATA lv_abap_name TYPE string.

    lv_abap_name = mo_cut->to_abap_name( 'a_long_name_longer_than_28_Characters' ).

    cl_abap_unit_assert=>assert_number_between(
      lower  = 1
      upper  = 28
      number = strlen( lv_abap_name ) ).

  ENDMETHOD.

  METHOD camel_to_snake1.

    DATA lv_abap_name TYPE string.

    lv_abap_name = mo_cut->to_abap_name( 'putData' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_abap_name
      exp = 'put_data' ).

  ENDMETHOD.

  METHOD camel_to_snake2.

    DATA lv_abap_name TYPE string.

    lv_abap_name = mo_cut->to_abap_name( 'PutData' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_abap_name
      exp = 'put_data' ).

  ENDMETHOD.

ENDCLASS.
