CLASS zcl_oapi_dereference DEFINITION PUBLIC.
  PUBLIC SECTION.
    METHODS dereference
      IMPORTING is_spec TYPE zif_oapi_specification_v3=>ty_specification
      RETURNING VALUE(rs_spec) TYPE zif_oapi_specification_v3=>ty_specification.

  PRIVATE SECTION.
    DATA ms_spec TYPE zif_oapi_specification_v3=>ty_specification.

    METHODS parameters.
ENDCLASS.

CLASS zcl_oapi_dereference IMPLEMENTATION.

  METHOD dereference.
    ms_spec = is_spec.
    parameters( ).
    rs_spec = ms_spec.
  ENDMETHOD.

  METHOD parameters.
    FIELD-SYMBOLS: <ls_operation> LIKE LINE OF ms_spec-operations.
    DATA ls_parameter TYPE zif_oapi_specification_v3=>ty_parameter.
    DATA lv_ref TYPE string.

    LOOP AT ms_spec-operations ASSIGNING <ls_operation>.
      LOOP AT <ls_operation>-parameters_ref INTO lv_ref.
        REPLACE FIRST OCCURRENCE OF '#/components/parameters/' IN lv_ref WITH ''.
*        WRITE '@KERNEL console.dir(lv_ref.get());'.
        READ TABLE ms_spec-components-parameters WITH KEY name = lv_ref INTO ls_parameter.
        IF sy-subrc = 0.
          APPEND ls_parameter TO <ls_operation>-parameters.
        ENDIF.
      ENDLOOP.
      CLEAR <ls_operation>-parameters_ref.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.