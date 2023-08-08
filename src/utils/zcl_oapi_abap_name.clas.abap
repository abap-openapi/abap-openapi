CLASS zcl_oapi_abap_name DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS to_abap_name
      IMPORTING
        !iv_name       TYPE string
      RETURNING
        VALUE(rv_name) TYPE string.
    METHODS add_used
      IMPORTING
        !iv_name TYPE string.
    METHODS is_used
      IMPORTING
        !iv_name       TYPE string
      RETURNING
        VALUE(rv_used) TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES ty_name TYPE c LENGTH 28.
    DATA mt_used TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    METHODS numbering IMPORTING iv_name TYPE string RETURNING VALUE(rv_name) TYPE ty_name.
    METHODS sanitize_name
      IMPORTING iv_name        TYPE string
      RETURNING VALUE(rv_name) TYPE string.
ENDCLASS.



CLASS zcl_oapi_abap_name IMPLEMENTATION.


  METHOD add_used.
    READ TABLE mt_used WITH KEY table_line = iv_name TRANSPORTING NO FIELDS.
    ASSERT sy-subrc <> 0.
    APPEND iv_name TO mt_used.
  ENDMETHOD.


  METHOD is_used.
    DATA lv_name TYPE string.
    IF iv_name IS INITIAL.
      RETURN.
    ENDIF.
    lv_name = sanitize_name( iv_name ).
    READ TABLE mt_used WITH KEY table_line = lv_name TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      rv_used = abap_true.
      RETURN.
    ENDIF.
    rv_used = abap_false.
  ENDMETHOD.


  METHOD numbering.
    DATA lv_number TYPE n LENGTH 2.
    DATA lv_offset TYPE i.
    lv_offset = strlen( iv_name ).
    IF lv_offset > 26.
      lv_offset = 26.
    ENDIF.
    DO 99 TIMES.
      lv_number = sy-index.
      rv_name = iv_name.
      rv_name+lv_offset = lv_number.
      READ TABLE mt_used WITH KEY table_line = rv_name TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDDO.
    ASSERT 0 = 1.
  ENDMETHOD.


  METHOD sanitize_name.
    rv_name = to_lower( iv_name ).
    REPLACE ALL OCCURRENCES OF '-' IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF ` ` IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF '.' IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF '/' IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF '$' IN rv_name WITH '_'.
    REPLACE ALL OCCURRENCES OF '@' IN rv_name WITH ''.
    REPLACE ALL OCCURRENCES OF '+' IN rv_name WITH ''.
    IF rv_name CO '0123456789'.
      rv_name = 'n' && rv_name.
    ENDIF.
    IF strlen( rv_name ) > 28.
      rv_name = rv_name(28).
    ENDIF.
  ENDMETHOD.


  METHOD to_abap_name.
    IF iv_name IS INITIAL.
      RETURN.
    ENDIF.
    rv_name = sanitize_name( iv_name ).
    IF is_used( rv_name ) = abap_true.
      rv_name = numbering( rv_name ).
    ENDIF.
    APPEND rv_name TO mt_used.
  ENDMETHOD.
ENDCLASS.
