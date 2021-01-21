CLASS ltcl_json DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS test1 FOR TESTING.
ENDCLASS.

CLASS ltcl_json IMPLEMENTATION.
  METHOD test1.
    DATA lo_json TYPE REF TO zcl_oapi_json.

    CREATE OBJECT lo_json EXPORTING iv_json = '{"key1": "value1", "key2": "value2"}'.

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_json->members( '/' ) )
      exp = 2 ).

    cl_abap_unit_assert=>assert_true( lo_json->exists( '/key1' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_json->value_string( '/key1' )
      exp = 'value1' ).

  ENDMETHOD.
ENDCLASS.