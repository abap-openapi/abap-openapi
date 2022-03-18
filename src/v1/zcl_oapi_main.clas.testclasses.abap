CLASS ltcl_find_prefix DEFINITION DEFERRED.
CLASS zcl_oapi_main DEFINITION LOCAL FRIENDS ltcl_find_prefix.

CLASS ltcl_find_prefix DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_oapi_main.
    METHODS setup.
    METHODS none_specified FOR TESTING RAISING cx_static_check.
    METHODS relative FOR TESTING RAISING cx_static_check.
    METHODS host_only FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_find_prefix IMPLEMENTATION.
  METHOD setup.
    CREATE OBJECT mo_cut.
  ENDMETHOD.

  METHOD none_specified.
    DATA lt_servers TYPE zif_oapi_specification_v3=>ty_servers.
    DATA lv_act TYPE string.
    lv_act = mo_cut->find_uri_prefix( lt_servers ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = '' ).
  ENDMETHOD.

  METHOD relative.
    DATA lt_servers TYPE zif_oapi_specification_v3=>ty_servers.
    DATA ls_server LIKE LINE OF lt_servers.
    DATA lv_act TYPE string.
    ls_server-url = '/api/v3'.
    APPEND ls_server TO lt_servers.
    lv_act = mo_cut->find_uri_prefix( lt_servers ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = '/api/v3' ).
  ENDMETHOD.

  METHOD host_only.
    DATA lt_servers TYPE zif_oapi_specification_v3=>ty_servers.
    DATA ls_server LIKE LINE OF lt_servers.
    DATA lv_act TYPE string.
    ls_server-url = 'https://api.foobar.com'.
    APPEND ls_server TO lt_servers.
    lv_act = mo_cut->find_uri_prefix( lt_servers ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_act
      exp = 'https://api.foobar.com' ).
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS test FOR TESTING.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.
  METHOD test.
    DATA ls_input TYPE zcl_oapi_main=>ty_input.
    DATA lo_main TYPE REF TO zcl_oapi_main.
    DATA ls_result TYPE zcl_oapi_main=>ty_result.

    ls_input-class_name = 'zcl_bar'.
    ls_input-interface_name = 'zcl_bar'.
    ls_input-json = '{' && |\n| &&
      '  "openapi": "3.0.2",' && |\n| &&
      '  "info": {' && |\n| &&
      '    "title": "test",' && |\n| &&
      '    "description": "test",' && |\n| &&
      '    "version": "1.0.0"' && |\n| &&
      '  },' && |\n| &&
      '  "paths": {' && |\n| &&
      '    "/zen": {' && |\n| &&
      '      "get": {' && |\n| &&
      '        "summary": "Get",' && |\n| &&
      '        "responses": {' && |\n| &&
      '          "200": {' && |\n| &&
      '            "description": "response",' && |\n| &&
      '            "content": {' && |\n| &&
      '              "text/plain": {' && |\n| &&
      '                "schema": {' && |\n| &&
      '                  "type": "string"' && |\n| &&
      '}}}}}}}}}'.

    CREATE OBJECT lo_main.
    ls_result = lo_main->run( ls_input ).

    cl_abap_unit_assert=>assert_not_initial( ls_result-clas ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-intf ).

  ENDMETHOD.
ENDCLASS.
