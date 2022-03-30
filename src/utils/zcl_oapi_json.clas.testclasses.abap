CLASS ltcl_json DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS object_two_keys FOR TESTING.
    METHODS basic_array FOR TESTING.
    METHODS nested_object FOR TESTING.
    METHODS test2 FOR TESTING.
ENDCLASS.

CLASS ltcl_json IMPLEMENTATION.
  METHOD object_two_keys.

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

  METHOD basic_array.

    DATA lo_json TYPE REF TO zcl_oapi_json.

    CREATE OBJECT lo_json EXPORTING iv_json = '[42, 43]'.

    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_json->members( '/' ) )
      exp = 2 ).

    cl_abap_unit_assert=>assert_true( lo_json->exists( '/1' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_json->value_string( '/1' )
      exp = '42' ).

  ENDMETHOD.

  METHOD nested_object.

    DATA lo_json TYPE REF TO zcl_oapi_json.

    CREATE OBJECT lo_json EXPORTING iv_json = '{"key1": {"key2": "value2"}}'.

    cl_abap_unit_assert=>assert_equals(
      act = lo_json->value_string( '/key1/key2' )
      exp = 'value2' ).

    cl_abap_unit_assert=>assert_equals(
       act = lines( lo_json->members( '/key1/' ) )
       exp = 1 ).

  ENDMETHOD.

  METHOD test2.

    DATA lo_json TYPE REF TO zcl_oapi_json.

    CREATE OBJECT lo_json EXPORTING iv_json = '{"key1": {"key2": "value2"}, "key3": 2}'.

    cl_abap_unit_assert=>assert_equals(
      act = lo_json->value_string( '/key3' )
      exp = '2' ).

  ENDMETHOD.
ENDCLASS.
