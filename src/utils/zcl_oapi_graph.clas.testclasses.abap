CLASS ltcl_graph DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS test FOR TESTING RAISING cx_static_check.
    METHODS remove_cycles_self FOR TESTING RAISING cx_static_check.
    METHODS remove_cycles_mutual FOR TESTING RAISING cx_static_check.
    METHODS remove_cycles_none FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_graph IMPLEMENTATION.
  METHOD test.
    DATA lo_graph TYPE REF TO zcl_oapi_graph.
    CREATE OBJECT lo_graph.
    lo_graph->add_vertex( |foo| ).
    lo_graph->add_vertex( |bar| ).
    lo_graph->add_edge(
      iv_from = |foo|
      iv_to   = |bar| ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_graph->pop( )
      exp = |foo| ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_graph->pop( )
      exp = |bar| ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_graph->is_empty( )
      exp = abap_true ).
  ENDMETHOD.

  METHOD remove_cycles_self.
    DATA lo_graph TYPE REF TO zcl_oapi_graph.
    DATA lt_removed TYPE zcl_oapi_graph=>ty_edges.
    DATA ls_removed LIKE LINE OF lt_removed.
    CREATE OBJECT lo_graph.
    lo_graph->add_vertex( |foo| ).
    lo_graph->add_edge(
      iv_from = |foo|
      iv_to   = |foo| ).

    lt_removed = lo_graph->remove_cycles( ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_removed )
      exp = 1 ).
    READ TABLE lt_removed INDEX 1 INTO ls_removed.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_removed-to
      exp = |foo| ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_graph->pop( )
      exp = |foo| ).
  ENDMETHOD.

  METHOD remove_cycles_mutual.
    DATA lo_graph TYPE REF TO zcl_oapi_graph.
    DATA lt_removed TYPE zcl_oapi_graph=>ty_edges.
    DATA ls_removed LIKE LINE OF lt_removed.
    CREATE OBJECT lo_graph.
    lo_graph->add_vertex( |foo| ).
    lo_graph->add_vertex( |bar| ).
    lo_graph->add_vertex( |baz| ).
    lo_graph->add_edge(
      iv_from = |foo|
      iv_to   = |bar| ).
    lo_graph->add_edge(
      iv_from = |bar|
      iv_to   = |baz| ).
    lo_graph->add_edge(
      iv_from = |baz|
      iv_to   = |foo| ).

    lt_removed = lo_graph->remove_cycles( ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_removed )
      exp = 1 ).
    READ TABLE lt_removed INDEX 1 INTO ls_removed.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_removed-from
      exp = |baz| ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_removed-to
      exp = |foo| ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_graph->pop( )
      exp = |foo| ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_graph->pop( )
      exp = |bar| ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_graph->pop( )
      exp = |baz| ).
  ENDMETHOD.

  METHOD remove_cycles_none.
    DATA lo_graph TYPE REF TO zcl_oapi_graph.
    CREATE OBJECT lo_graph.
    lo_graph->add_vertex( |foo| ).
    lo_graph->add_vertex( |bar| ).
    lo_graph->add_vertex( |baz| ).
    lo_graph->add_edge(
      iv_from = |foo|
      iv_to   = |baz| ).
    lo_graph->add_edge(
      iv_from = |bar|
      iv_to   = |baz| ).

    cl_abap_unit_assert=>assert_initial( lo_graph->remove_cycles( ) ).
  ENDMETHOD.
ENDCLASS.
