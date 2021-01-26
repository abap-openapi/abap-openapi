CLASS lcl_abap_name DEFINITION.
  PUBLIC SECTION.
    METHODS to_abap_name
      IMPORTING iv_name TYPE string
      RETURNING VALUE(rv_name) TYPE string.
ENDCLASS.

CLASS lcl_abap_name IMPLEMENTATION.
  METHOD to_abap_name.
    rv_name = to_lower( iv_name ).
    REPLACE ALL OCCURRENCES OF '-' IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF '/' IN rv_name WITH '_'.
    IF strlen( rv_name ) > 30.
      rv_name = rv_name(30).
    ENDIF.
  ENDMETHOD.
ENDCLASS.