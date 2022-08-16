CLASS zcl_oapi_references DEFINITION PUBLIC.

  PUBLIC SECTION.
* todo, rename to "normalize"?
    METHODS normalize
      IMPORTING is_spec TYPE zif_oapi_specification_v3=>ty_specification
      RETURNING VALUE(rs_spec) TYPE zif_oapi_specification_v3=>ty_specification.

  PRIVATE SECTION.
    DATA ms_spec TYPE zif_oapi_specification_v3=>ty_specification.

    METHODS dereference_parameters.
    METHODS create_body_references.
    METHODS create_response_references.
    METHODS sort_schemas.
    METHODS sort_traverse
      IMPORTING
        iv_parent TYPE string
        io_graph  TYPE REF TO zcl_oapi_graph
        ii_schema TYPE REF TO zif_oapi_schema.
ENDCLASS.

CLASS zcl_oapi_references IMPLEMENTATION.

  METHOD normalize.
    ms_spec = is_spec.

* always dereference all parameters
    dereference_parameters( ).

* if body schema is not simple, move to schema ref
    create_body_references( ).

* if response schema is not simple, move to schema ref
    create_response_references( ).

* sort component schemas so they are ordered with references being defined before used
    sort_schemas( ).

    rs_spec = ms_spec.
  ENDMETHOD.

  METHOD sort_traverse.
    DATA ls_property TYPE zif_oapi_schema=>ty_property.
    DATA lv_name TYPE string.

    IF ii_schema->items_ref IS NOT INITIAL.
      lv_name = ii_schema->items_ref.
      REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN lv_name WITH ''.
      io_graph->add_edge(
        iv_from = iv_parent
        iv_to   = lv_name ).
    ENDIF.
    LOOP AT ii_schema->properties INTO ls_property.
      IF ls_property-ref IS NOT INITIAL.
        lv_name = ls_property-ref.
        REPLACE FIRST OCCURRENCE OF '#/components/schemas/' IN lv_name WITH ''.
        io_graph->add_edge(
          iv_from = iv_parent
          iv_to   = lv_name ).
      ELSEIF ls_property-schema IS NOT INITIAL.
        sort_traverse( iv_parent = iv_parent
                       io_graph  = io_graph
                       ii_schema = ls_property-schema ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sort_schemas.
    DATA ls_schema LIKE LINE OF ms_spec-components-schemas.
    DATA lt_copy LIKE ms_spec-components-schemas.
    DATA ls_copy LIKE LINE OF lt_copy.
    DATA lv_name TYPE string.
    DATA lo_graph TYPE REF TO zcl_oapi_graph.
    CREATE OBJECT lo_graph.

    LOOP AT ms_spec-components-schemas INTO ls_schema.
      lo_graph->add_vertex( ls_schema-name ).
    ENDLOOP.
    LOOP AT ms_spec-components-schemas INTO ls_schema.
      sort_traverse( iv_parent = ls_schema-name
                     io_graph  = lo_graph
                     ii_schema = ls_schema-schema ).
    ENDLOOP.

    lt_copy = ms_spec-components-schemas.
    CLEAR ms_spec-components-schemas.
    WHILE lo_graph->is_empty( ) = abap_false.
      lv_name = lo_graph->pop( ).
      READ TABLE lt_copy INTO ls_copy WITH KEY name = lv_name.
      ASSERT sy-subrc = 0.
      INSERT ls_copy INTO TABLE ms_spec-components-schemas INDEX 1.
    ENDWHILE.

  ENDMETHOD.

  METHOD create_response_references.

    FIELD-SYMBOLS <ls_operation> LIKE LINE OF ms_spec-operations.
    FIELD-SYMBOLS <ls_response> LIKE LINE OF <ls_operation>-responses.
    FIELD-SYMBOLS <ls_content> LIKE LINE OF <ls_response>-content.
    DATA ls_new TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    LOOP AT ms_spec-operations ASSIGNING <ls_operation> WHERE deprecated = abap_false.
      LOOP AT <ls_operation>-responses ASSIGNING <ls_response>.
        LOOP AT <ls_response>-content ASSIGNING <ls_content> WHERE type = 'application/json' AND schema_ref IS INITIAL AND schema IS NOT INITIAL.
          IF <ls_content>-schema->is_simple_type( ) = abap_true.
            CONTINUE.
          ENDIF.

          ls_new-name = |response_{ <ls_operation>-abap_name }|.
          ls_new-abap_name = lo_names->to_abap_name( ls_new-name ).
          ls_new-abap_parser_method = lo_names->to_abap_name( |parse_{ <ls_operation>-abap_name }| ).
          CLEAR ls_new-abap_json_method. " dumping json not needed, this is a response
          ls_new-schema = <ls_content>-schema.
          APPEND ls_new TO ms_spec-components-schemas.

          <ls_content>-schema_ref = '#/components/schemas/' && ls_new-name.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD create_body_references.
    FIELD-SYMBOLS <ls_operation> LIKE LINE OF ms_spec-operations.
    DATA ls_new TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    LOOP AT ms_spec-operations ASSIGNING <ls_operation> WHERE deprecated = abap_false.
      IF <ls_operation>-body_schema IS NOT INITIAL
          AND <ls_operation>-body_schema->is_simple_type( ) = abap_false.

        ls_new-name = lo_names->to_abap_name( |body{ <ls_operation>-abap_name }| ).
        ls_new-abap_name = ls_new-name.
        ls_new-abap_json_method = lo_names->to_abap_name( |json_{ <ls_operation>-abap_name }| ).
        CLEAR ls_new-abap_parser_method. " parser method is not needed for body which is input
        ls_new-schema = <ls_operation>-body_schema.
        APPEND ls_new TO ms_spec-components-schemas.

        <ls_operation>-body_schema_ref = '#/components/schemas/' && ls_new-name.
        CLEAR <ls_operation>-body_schema.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD dereference_parameters.
    FIELD-SYMBOLS: <ls_operation> LIKE LINE OF ms_spec-operations.
    DATA ls_parameter TYPE zif_oapi_specification_v3=>ty_parameter.
    DATA lv_ref TYPE string.

    LOOP AT ms_spec-operations ASSIGNING <ls_operation> WHERE deprecated = abap_false.
      LOOP AT <ls_operation>-parameters_ref INTO lv_ref.
        REPLACE FIRST OCCURRENCE OF '#/components/parameters/' IN lv_ref WITH ''.
        READ TABLE ms_spec-components-parameters WITH KEY id = lv_ref INTO ls_parameter.
        IF sy-subrc = 0.
          APPEND ls_parameter TO <ls_operation>-parameters.
        ELSE.
          ASSERT 0 = 1.
*        ELSE.
*          WRITE '@KERNEL console.dir(lv_ref.get() + "not found");'.
        ENDIF.
      ENDLOOP.
      CLEAR <ls_operation>-parameters_ref.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
