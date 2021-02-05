CLASS zcl_oapi_schema DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_oapi_schema.
ENDCLASS.

CLASS zcl_oapi_schema IMPLEMENTATION.

  METHOD zif_oapi_schema~is_simple_type.

    DATA lv_type TYPE string.

    lv_type = zif_oapi_schema~get_simple_type( ).

    rv_simple = boolc( lv_type <> '' ).

  ENDMETHOD.

  METHOD zif_oapi_schema~get_simple_type.

    rv_simple = zif_oapi_schema~type.

    CASE rv_simple.
      WHEN 'integer'.
        rv_simple = 'i'.
      WHEN 'number'.
        rv_simple = 'f'.
      WHEN 'string'.
        rv_simple = 'string'.
      WHEN 'boolean'.
        rv_simple = 'abap_bool'.
      WHEN OTHERS.
        CLEAR rv_simple.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.