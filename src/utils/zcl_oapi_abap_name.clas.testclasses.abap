CLASS ltcl_abap_name DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS max_abap_name_length FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_abap_name IMPLEMENTATION.

  METHOD max_abap_name_length.
    DATA lo_abap_name TYPE REF TO zcl_oapi_abap_name.
    DATA lv_abap_name TYPE string.

    CREATE OBJECT lo_abap_name.

    lv_abap_name = lo_abap_name->to_abap_name( 'a_long_name_longer_then_28_Characters' ).

    cl_abap_unit_assert=>assert_number_between(
        lower = 1
        upper = 28
        number = strlen( lv_abap_name ) ).

  ENDMETHOD.

ENDCLASS.
