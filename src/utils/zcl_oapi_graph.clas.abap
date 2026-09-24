CLASS zcl_oapi_graph DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_edge,
             from TYPE string,
             to   TYPE string,
           END OF ty_edge.
    TYPES ty_edges TYPE STANDARD TABLE OF ty_edge WITH DEFAULT KEY.
    METHODS add_vertex IMPORTING iv_vertex TYPE string.
    METHODS add_edge
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string.
    METHODS is_empty RETURNING VALUE(rv_empty) TYPE abap_bool.
    METHODS pop RETURNING VALUE(rv_node) TYPE string.
    "! Removes edges so the graph becomes acyclic, returns the removed edges
    METHODS remove_cycles RETURNING VALUE(rt_removed) TYPE ty_edges.
    METHODS dump.
  PRIVATE SECTION.
    TYPES ty_strings TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    DATA mt_vertices TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA mt_edges TYPE ty_edges.
    METHODS remove_cycles_dfs
      IMPORTING
        iv_vertex  TYPE string
      CHANGING
        ct_visited TYPE ty_strings
        ct_stack   TYPE ty_strings
        ct_removed TYPE ty_edges.
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

  METHOD remove_cycles.
    DATA lv_vertex  LIKE LINE OF mt_vertices.
    DATA ls_edge    LIKE LINE OF rt_removed.
    DATA lt_visited TYPE ty_strings.
    DATA lt_stack   TYPE ty_strings.

    LOOP AT mt_vertices INTO lv_vertex.
      READ TABLE lt_visited WITH TABLE KEY table_line = lv_vertex TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      remove_cycles_dfs(
        EXPORTING
          iv_vertex  = lv_vertex
        CHANGING
          ct_visited = lt_visited
          ct_stack   = lt_stack
          ct_removed = rt_removed ).
    ENDLOOP.

    LOOP AT rt_removed INTO ls_edge.
      DELETE mt_edges WHERE from = ls_edge-from AND to = ls_edge-to.
    ENDLOOP.
  ENDMETHOD.

  METHOD remove_cycles_dfs.
* depth first search, edges pointing back to a vertex on the current path close a cycle
    DATA ls_edge LIKE LINE OF mt_edges.

    INSERT iv_vertex INTO TABLE ct_visited.
    INSERT iv_vertex INTO TABLE ct_stack.

    LOOP AT mt_edges INTO ls_edge WHERE from = iv_vertex.
      READ TABLE ct_stack WITH TABLE KEY table_line = ls_edge-to TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND ls_edge TO ct_removed.
        CONTINUE.
      ENDIF.
      READ TABLE ct_visited WITH TABLE KEY table_line = ls_edge-to TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        remove_cycles_dfs(
          EXPORTING
            iv_vertex  = ls_edge-to
          CHANGING
            ct_visited = ct_visited
            ct_stack   = ct_stack
            ct_removed = ct_removed ).
      ENDIF.
    ENDLOOP.

    DELETE TABLE ct_stack WITH TABLE KEY table_line = iv_vertex.
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
