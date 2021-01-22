CLASS ltcl_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS test FOR TESTING.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.
  METHOD test.
    DATA ls_input TYPE zcl_aopi_main=>ty_input.
    DATA lo_main TYPE REF TO zcl_aopi_main.

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
    lo_main->run( ls_input ).
* todo, assertions

  ENDMETHOD.
ENDCLASS.