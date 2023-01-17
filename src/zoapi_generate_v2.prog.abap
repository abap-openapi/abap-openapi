*&---------------------------------------------------------------------*
*& Report ZOAPI_GENERATE_V2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zoapi_generate_v2.

DATA ls_input  TYPE zcl_oapi_generator_v2=>ty_input.
DATA ls_result TYPE zcl_oapi_generator_v2=>ty_result.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_intf   LIKE ls_input-intf DEFAULT 'ZIF_INTERFACE',
              p_client LIKE ls_input-clas_client DEFAULT 'ZCL_CLIENT',
              p_serv   LIKE ls_input-clas_icf_serv DEFAULT 'ZCL_ICF_SERVER',
              p_impl   LIKE ls_input-clas_icf_impl DEFAULT 'ZCL_ICF_IMPLEMENTATION'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_file TYPE text255.
SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA: it_tab   TYPE filetable,
        wf_subrc TYPE i.
  DATA: wf_pcfile TYPE text255.

  DATA: wf_filter TYPE string,
        wf_dir    TYPE string,
        wf_title  TYPE string,
        wf_ext    TYPE string.

  FIELD-SYMBOLS: <fs_file> LIKE LINE OF it_tab.

*  if p_ml = 'X'.                  "Manula Load - PC File
  wf_ext  = '.JSON'.           "Extension of the file
  wf_filter = 'Text Files (*.JSON)|*.JSON'.         "File Type
  wf_dir = wf_pcfile.           "Directory

*Adds a GUI-Supported Feature
  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title      = wf_title
      default_extension = wf_ext
      file_filter       = wf_filter
      initial_directory = wf_dir
    CHANGING
      file_table        = it_tab
      rc                = wf_subrc ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF it_tab IS NOT INITIAL.
    READ TABLE it_tab ASSIGNING <fs_file> INDEX 1.
    IF sy-subrc = 0.
      p_file = <fs_file>-filename.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  DATA: filename TYPE string,
        data_tab TYPE TABLE OF text255.
  filename = p_file.
  cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = filename            " Name of file
        filetype                = 'ASC'              " File Type (ASCII, Binary)
        codepage                = '4110' " UTF-8
      CHANGING
        data_tab                = data_tab           " Transfer table for file contents
      EXCEPTIONS
        file_open_error         = 1                  " File does not exist and cannot be opened
        file_read_error         = 2                  " Error when reading file
        no_batch                = 3                  " Cannot execute front-end function in background
        gui_refuse_filetransfer = 4                  " Incorrect front end or error on front end
        invalid_type            = 5                  " Incorrect parameter FILETYPE
        no_authority            = 6                  " No upload authorization
        unknown_error           = 7                  " Unknown error
        bad_data_format         = 8                  " Cannot Interpret Data in File
        header_not_allowed      = 9                  " Invalid header
        separator_not_allowed   = 10                 " Invalid separator
        header_too_long         = 11                 " Header information currently restricted to 1023 bytes
        unknown_dp_error        = 12                 " Error when calling data provider
        access_denied           = 13                 " Access to File Denied
        dp_out_of_memory        = 14                 " Not enough memory in data provider
        disk_full               = 15                 " Storage medium is full.
        dp_timeout              = 16                 " Data provider timeout
        not_supported_by_gui    = 17                 " GUI does not support this
        error_no_gui            = 18                 " GUI not available
        OTHERS                  = 19 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'SOTR_SERV_TABLE_TO_STRING'
    IMPORTING
      text     = ls_input-openapi_json
    TABLES
      text_tab = data_tab.

  ls_input-intf = p_intf.
  ls_input-clas_client = p_client.
  ls_input-clas_icf_impl = p_serv.
  ls_input-clas_icf_serv = p_impl.

  ls_result = zcl_oapi_generator=>generate_v2( ls_input ).

  WRITE: / 'Interface:'.
  WRITE: / ls_result-intf.
