CLASS zcl_oapi_generator DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS generate_v1
      IMPORTING is_input TYPE zcl_oapi_main=>ty_input
      RETURNING VALUE(rs_result) TYPE zcl_oapi_main=>ty_result.

    CLASS-METHODS generate_v2
      IMPORTING is_input TYPE zcl_oapi_generator_v2=>ty_input
      RETURNING VALUE(rs_result) TYPE zcl_oapi_generator_v2=>ty_result.
ENDCLASS.

CLASS zcl_oapi_generator IMPLEMENTATION.
  METHOD generate_v1.
    DATA lo_generator TYPE REF TO zcl_oapi_main.
    CREATE OBJECT lo_generator.
    rs_result = lo_generator->run( is_input ).
  ENDMETHOD.

  METHOD generate_v2.
    DATA lo_generator TYPE REF TO zcl_oapi_generator_v2.
    CREATE OBJECT lo_generator.
    rs_result = lo_generator->run( is_input ).
  ENDMETHOD.
ENDCLASS.