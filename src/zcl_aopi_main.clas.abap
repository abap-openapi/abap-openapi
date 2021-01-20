CLASS zcl_aopi_main DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
        clas TYPE string,
        intf TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING iv_json TYPE string
      RETURNING VALUE(rs_result) TYPE ty_result.
ENDCLASS.

CLASS zcl_aopi_main IMPLEMENTATION.
  METHOD run.
    rs_result-clas = 'TODO1' && iv_json(1).
    rs_result-intf = 'TODO2'.
  ENDMETHOD.
ENDCLASS.