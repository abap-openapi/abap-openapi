CLASS zcl_oapi_generator_v2 DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             class_name     TYPE c LENGTH 30,
             interface_name TYPE c LENGTH 30,
             json           TYPE string,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
        clas TYPE string,
        intf TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING is_input TYPE ty_input
      RETURNING VALUE(rs_result) TYPE ty_result.

ENDCLASS.

CLASS zcl_oapi_generator_v2 IMPLEMENTATION.

  METHOD run.

    rs_result-clas = 'todoclas'.
    rs_result-intf = 'todointf'.

  ENDMETHOD.

ENDCLASS.