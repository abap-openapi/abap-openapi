CLASS zcl_aopi_main DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
        clas TYPE string,
        intf TYPE string,
      END OF ty_result.

    METHODS run
      IMPORTING iv_json TYPE string
      RETURNING VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    DATA mo_json TYPE REF TO zcl_oapi_json.

ENDCLASS.

CLASS zcl_aopi_main IMPLEMENTATION.

  METHOD run.
    CREATE OBJECT mo_json EXPORTING iv_json = iv_json.

    rs_result-clas =
      |CLASS zcl_bar DEFINITION PUBLIC.\n| &&
      |ENDCLASS.\n| &&
      |CLASS zcl_bar IMPLEMENTATION.\n| &&
      |ENDCLASS.|.

    rs_result-intf = |INTERFACE zif_bar.\n| &&
      |ENDINTERFACE.|.
  ENDMETHOD.

ENDCLASS.