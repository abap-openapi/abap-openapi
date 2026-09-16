CLASS zcl_icf_impl025 DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_interface025.
ENDCLASS.

CLASS zcl_icf_impl025 IMPLEMENTATION.

  METHOD zif_interface025~search_v2.
* Add implementation logic here
  ENDMETHOD.

ENDCLASS.

CLASS zcl_icf_impl025_val DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS check IMPORTING iv_schema_name TYPE string iv_value TYPE string RETURNING VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_icf_impl025_val IMPLEMENTATION.
  METHOD check.
    DATA lo_regex TYPE REF TO cl_abap_regex.
    lo_regex = NEW #( pattern = ''.*'' ).
    rv_valid = abap_false.
    IF iv_schema_name = 'safe_identifier'.
      lo_regex = NEW #( pattern = '^[A-Za-z0-9.-]+$' ).
      rv_valid = lo_regex->create_matcher( text = iv_value )->match( ).
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
CLASS zcl_icf_impl025_tst DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
ENDCLASS.

CLASS zcl_icf_impl025_tst IMPLEMENTATION.
ENDCLASS.
