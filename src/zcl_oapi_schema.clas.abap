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

  METHOD zif_oapi_schema~build_type_definition.

    DATA ls_property TYPE zif_oapi_schema=>ty_property.
    DATA lv_count TYPE i.

    IF zif_oapi_schema~type = 'object'.
      rv_abap = rv_abap && |  TYPES: BEGIN OF { iv_name },\n|.
      lv_count = 0.
      LOOP AT zif_oapi_schema~properties INTO ls_property.
        IF ls_property-schema IS INITIAL.
          rv_abap = rv_abap && |* todo, { ls_property-ref }, { ls_property-abap_name }, ref?\n|.
          CONTINUE.
        ENDIF.
        IF ls_property-schema->is_simple_type( ) = abap_true.
          rv_abap = rv_abap && |           | && ls_property-abap_name && | TYPE | && ls_property-schema->get_simple_type( ) && |,\n|.
        ELSE.
          rv_abap = rv_abap && |           | && ls_property-abap_name && | TYPE string, " not simple, todo\n|.
        ENDIF.
        lv_count = lv_count + 1.
      ENDLOOP.
      IF lv_count = 0. " temporary workaround
        rv_abap = rv_abap && |           dummy TYPE i,\n|.
      ENDIF.
      rv_abap = rv_abap && |         END OF { iv_name }.\n|.
    ELSEIF zif_oapi_schema~is_simple_type( ) = abap_true.
      rv_abap = rv_abap && |  TYPES { iv_name } TYPE { zif_oapi_schema~get_simple_type( ) }.\n|.
    ELSE.
      rv_abap = rv_abap && |  TYPES { iv_name } TYPE string. " { zif_oapi_schema~type }, todo\n|.
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