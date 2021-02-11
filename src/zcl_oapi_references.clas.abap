CLASS zcl_oapi_references DEFINITION PUBLIC.

  PUBLIC SECTION.
* todo, rename to "normalize"?
    METHODS fix
      IMPORTING is_spec TYPE zif_oapi_specification_v3=>ty_specification
      RETURNING VALUE(rs_spec) TYPE zif_oapi_specification_v3=>ty_specification.

  PRIVATE SECTION.
    DATA ms_spec TYPE zif_oapi_specification_v3=>ty_specification.

    METHODS dereference_parameters.
    METHODS create_body_references.
ENDCLASS.

CLASS zcl_oapi_references IMPLEMENTATION.

  METHOD fix.
    ms_spec = is_spec.

* always dereference all parameters
    dereference_parameters( ).

* if body schema is not simple, move to schema ref
    create_body_references( ).

* if response schema is not simple, move to schema ref
* todo

* sort component schemas so they are ordered with references being defined before used
* todo, use the jira spec for testing, https://developer.atlassian.com/cloud/jira/platform/swagger-v3.v3.json

    rs_spec = ms_spec.
  ENDMETHOD.

  METHOD create_body_references.
    FIELD-SYMBOLS <ls_operation> LIKE LINE OF ms_spec-operations.
    DATA ls_new TYPE zif_oapi_specification_v3=>ty_component_schema.
    DATA lo_names TYPE REF TO zcl_oapi_abap_name.
    CREATE OBJECT lo_names.

    LOOP AT ms_spec-operations ASSIGNING <ls_operation>.
      IF <ls_operation>-body_schema IS NOT INITIAL
          AND <ls_operation>-body_schema->is_simple_type( ) = abap_false.

        ls_new-name = lo_names->to_abap_name( |body{ <ls_operation>-abap_name }| ).
        ls_new-abap_name = ls_new-name.
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

    LOOP AT ms_spec-operations ASSIGNING <ls_operation>.
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