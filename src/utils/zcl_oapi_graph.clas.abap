CLASS zcl_oapi_graph DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_edge,
             from TYPE string,
             to  TYPE string,
           END OF ty_edge.
    METHODS add_vertex IMPORTING iv_vertex TYPE string.
    METHODS add_edge
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string.
    METHODS is_empty RETURNING VALUE(rv_empty) TYPE abap_bool.
    METHODS pop RETURNING VALUE(rv_node) TYPE string.
    METHODS dump.
  PRIVATE SECTION.
    DATA mt_vertices TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA mt_edges TYPE STANDARD TABLE OF ty_edge WITH DEFAULT KEY.
ENDCLASS.

CLASS zcl_oapi_graph IMPLEMENTATION.
  METHOD is_empty.
    rv_empty = boolc( lines( mt_vertices ) = 0 ).
  ENDMETHOD.

  METHOD dump.
    DATA ls_edge LIKE LINE OF mt_edges.
    LOOP AT mt_edges INTO ls_edge.
      WRITE: / ls_edge-from, '->', ls_edge-to.
    ENDLOOP.
  ENDMETHOD.

  METHOD pop.
    DATA lv_vertex LIKE LINE OF mt_vertices.
    DATA lv_index TYPE i.
    ASSERT is_empty( ) = abap_false.
    LOOP AT mt_vertices INTO lv_vertex.
      lv_index = sy-tabix.
      READ TABLE mt_edges WITH KEY to = lv_vertex TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      DELETE mt_vertices INDEX lv_index.
      DELETE mt_edges WHERE from = lv_vertex.
      rv_node = lv_vertex.
      RETURN.
    ENDLOOP.
    ASSERT '' = 'graph has cycles'.
  ENDMETHOD.

  METHOD add_vertex.
    READ TABLE mt_vertices WITH KEY table_line = iv_vertex TRANSPORTING NO FIELDS.
    ASSERT sy-subrc <> 0.
    APPEND iv_vertex TO mt_vertices.
  ENDMETHOD.

  METHOD add_edge.
    DATA ls_edge TYPE ty_edge.
    ASSERT iv_from IS NOT INITIAL.
    ASSERT iv_to IS NOT INITIAL.
    READ TABLE mt_vertices WITH KEY table_line = iv_from TRANSPORTING NO FIELDS.
    ASSERT sy-subrc = 0.
    READ TABLE mt_vertices WITH KEY table_line = iv_to TRANSPORTING NO FIELDS.
    ASSERT sy-subrc = 0.
    READ TABLE mt_edges WITH KEY from = iv_from to = iv_to TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      ls_edge-from = iv_from.
      ls_edge-to = iv_to.
      INSERT ls_edge INTO TABLE mt_edges.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
