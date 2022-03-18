CLASS zcl_oapi_schema DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_oapi_schema.
  PROTECTED SECTION.
    METHODS lookup_ref
      IMPORTING
        iv_name TYPE string
        it_refs TYPE zif_oapi_specification_v3=>ty_schemas
      RETURNING
        VALUE(rs_ref) TYPE zif_oapi_specification_v3=>ty_component_schema.
ENDCLASS.

CLASS zcl_oapi_schema IMPLEMENTATION.

  METHOD zif_oapi_schema~is_simple_type.

    DATA lv_type TYPE string.

    lv_type = zif_oapi_schema~get_simple_type( ).

    rv_simple = boolc( lv_type <> '' ).

  ENDMETHOD.

  METHOD lookup_ref.
    DATA lv_name TYPE string.
    ASSERT iv_name IS NOT INITIAL.
    lv_name = iv_name.
    REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN lv_name WITH ''.
    READ TABLE it_refs INTO rs_ref WITH KEY name = lv_name.
    ASSERT sy-subrc = 0.
  ENDMETHOD.

  METHOD zif_oapi_schema~build_type_definition.

    DATA ls_property TYPE zif_oapi_schema=>ty_property.
    DATA ls_ref TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lv_count TYPE i.
    DATA lv_name TYPE string.

    IF zif_oapi_schema~type = 'object'.
      rv_abap = rv_abap && |  TYPES: BEGIN OF { iv_name },\n|.
      lv_count = 0.
      LOOP AT zif_oapi_schema~properties INTO ls_property.
        rv_abap = rv_abap && |           | && ls_property-abap_name && | TYPE |.
        IF ls_property-schema IS INITIAL.
          ls_ref = lookup_ref( iv_name = ls_property-ref
                               it_refs = it_refs ).
          rv_abap = rv_abap && ls_ref-abap_name && |,\n|.
        ELSEIF ls_property-schema->is_simple_type( ) = abap_true.
          rv_abap = rv_abap && ls_property-schema->get_simple_type( ) && |,\n|.
        ELSEIF ls_property-schema->type = 'array'.
          rv_abap = rv_abap && |STANDARD TABLE OF string WITH DEFAULT KEY, " todo, handle array\n|.
        ELSE.
          lv_name = io_names->to_abap_name( 'sub' && iv_name && '_' && ls_property-abap_name ).
          rv_abap = ls_property-schema->build_type_definition(
            iv_name  = lv_name
            io_names = io_names
            it_refs  = it_refs ) && rv_abap && lv_name && |,\n|.
        ENDIF.
        lv_count = lv_count + 1.
      ENDLOOP.
      IF lv_count = 0. " temporary workaround
        rv_abap = rv_abap && |           dummy_workaround TYPE i,\n|.
      ENDIF.
      rv_abap = rv_abap && |         END OF { iv_name }.\n|.
    ELSEIF zif_oapi_schema~type = 'array' AND zif_oapi_schema~items_ref IS NOT INITIAL.
      ls_ref = lookup_ref( iv_name = zif_oapi_schema~items_ref
                           it_refs = it_refs ).
      rv_abap = rv_abap && |  TYPES { iv_name } TYPE STANDARD TABLE OF { ls_ref-abap_name } WITH DEFAULT KEY.\n|.
    ELSEIF zif_oapi_schema~is_simple_type( ) = abap_true.
      rv_abap = rv_abap && |  TYPES { iv_name } TYPE { zif_oapi_schema~get_simple_type( ) }.\n|.
    ELSE.
      rv_abap = rv_abap && |  TYPES { iv_name } TYPE string. " { zif_oapi_schema~type } { zif_oapi_schema~items_ref } todo\n|.
    ENDIF.

  ENDMETHOD.

  METHOD zif_oapi_schema~get_simple_type.

    CASE zif_oapi_schema~type.
      WHEN 'integer'.
        rv_simple = 'i'.
      WHEN 'number'.
        rv_simple = 'f'.
      WHEN 'string'.
        rv_simple = 'string'.
      WHEN 'boolean'.
        rv_simple = 'abap_bool'.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
