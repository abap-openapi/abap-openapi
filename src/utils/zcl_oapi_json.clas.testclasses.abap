CLASS ltcl_json DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS object_two_keys FOR TESTING RAISING cx_static_check.
    METHODS basic_array FOR TESTING RAISING cx_static_check.
    METHODS nested_object FOR TESTING RAISING cx_static_check.
    METHODS test2 FOR TESTING RAISING cx_static_check.
    METHODS keys_with_slash FOR TESTING RAISING cx_static_check.
    METHODS escape_key FOR TESTING RAISING cx_static_check.
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

  METHOD keys_with_slash.
* "/a" + "/b" and "/a/b" must not end up as the same path
    DATA lo_json    TYPE REF TO zcl_oapi_json.
    DATA lt_members TYPE string_table.
    DATA lv_member  TYPE string.

    CREATE OBJECT lo_json EXPORTING iv_json = '{"/a": {"b": {"x": "1"}}, "/a/b": {"y": "2"}}'.

    lt_members = lo_json->members( '/~1a/b/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_members )
      exp = 1 ).
    READ TABLE lt_members INDEX 1 INTO lv_member.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_member
      exp = 'x' ).

    lt_members = lo_json->members( '/~1a~1b/' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_members )
      exp = 1 ).
    READ TABLE lt_members INDEX 1 INTO lv_member.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_member
      exp = 'y' ).

* members are returned unescaped
    lt_members = lo_json->members( '/' ).
    READ TABLE lt_members INDEX 2 INTO lv_member.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_member
      exp = '/a/b' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_json->value_string( '/' && zcl_oapi_json=>escape_key( lv_member ) && '/y' )
      exp = '2' ).

  ENDMETHOD.

  METHOD escape_key.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_oapi_json=>escape_key( '~a/b~1' )
      exp = '~0a~1b~01' ).
  ENDMETHOD.
ENDCLASS.
