CLASS zcl_oapi_schema DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_oapi_schema.
  PROTECTED SECTION.
    METHODS lookup_ref
      IMPORTING
        iv_name       TYPE string
        it_refs       TYPE zif_oapi_specification_v3=>ty_schemas
      RETURNING
        VALUE(rs_ref) TYPE zif_oapi_specification_v3=>ty_component_schema.
    METHODS get_simple_type
      IMPORTING
        iv_type          TYPE string
        iv_format        TYPE string OPTIONAL
      RETURNING
        VALUE(rv_simple) TYPE string.
  PRIVATE SECTION.
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
        ELSEIF ls_property-schema->type = 'array' AND ls_property-schema->items_ref IS NOT INITIAL.
          ls_ref = lookup_ref( iv_name = ls_property-schema->items_ref
                               it_refs = it_refs ).
          rv_abap = rv_abap && |STANDARD TABLE OF { ls_ref-abap_name } WITH DEFAULT KEY,\n|.
        ELSEIF ls_property-schema->type = 'array' AND ls_property-schema->items_type IS NOT INITIAL.
          rv_abap = rv_abap && |STANDARD TABLE OF { get_simple_type(
            ls_property-schema->items_type ) } WITH DEFAULT KEY,\n|.
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


  METHOD zif_oapi_schema~build_type_definition2.
    DATA ls_schema LIKE LINE OF is_specification-components-schemas.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    LOOP AT is_specification-components-schemas INTO ls_schema.
      lo_names->add_used( ls_schema-abap_name ).
    ENDLOOP.

    rv_abap = zif_oapi_schema~build_type_definition(
      iv_name  = iv_name
      it_refs  = is_specification-components-schemas
      io_names = lo_names ).

  ENDMETHOD.


  METHOD zif_oapi_schema~get_simple_type.
    rv_simple = get_simple_type(
      iv_type   = zif_oapi_schema~type
      iv_format = zif_oapi_schema~format ).
  ENDMETHOD.


  METHOD get_simple_type.
    CASE iv_type.
      WHEN 'integer'.
        rv_simple = 'i'.
      WHEN 'number'.
        rv_simple = 'f'.
      WHEN 'string'.
* this is using released DDIC types, however I'd like to just use built-in
* so this is a quick and dirty workaround, also consider case sensitivity?
        CASE zif_oapi_schema~max_length.
          WHEN 1.
            rv_simple = 'char1'.
          WHEN 2.
            rv_simple = 'char2'.
          WHEN 4.
            rv_simple = 'char4'.
          WHEN 8.
            rv_simple = 'char8'.
          WHEN 30.
            rv_simple = 'char30'.
          WHEN 40.
            rv_simple = 'char40'.
          WHEN OTHERS.
            rv_simple = 'string'.
        ENDCASE.

        CASE iv_format.
          WHEN 'binary'.
            rv_simple = 'xstring'.
          WHEN 'date-time'.
            " https://abapedia.org/steampunk-2305-api/timestampl.dtel.html
            rv_simple = 'timestampl'.
          WHEN 'uuid'.
            " https://json-schema.org/understanding-json-schema/reference/string#resource-identifiers
            " https://abapedia.org/steampunk-2305-api/sysuuid_c36.dtel.html
            rv_simple = 'sysuuid_c36'.
        ENDCASE.
      WHEN 'array'.
        IF zif_oapi_schema~items_type = 'object' AND zif_oapi_schema~items_ref IS INITIAL.
          rv_simple = 'any'.
        ENDIF.
      WHEN 'boolean'.
        rv_simple = 'abap_bool'.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
