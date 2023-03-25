*&---------------------------------------------------------------------*
*& Report ZOPENAPI_GENERATOR_UI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zopenapi_generator_ui.

DATA input  TYPE zcl_oapi_generator_v2=>ty_input.
DATA result TYPE zcl_oapi_generator_v2=>ty_result.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS p_name TYPE c LENGTH 11 DEFAULT 'DEFAULT'.
SELECTION-SCREEN SKIP.
PARAMETERS: p_intf   TYPE zcl_oapi_generator_v2=>ty_input-intf,
            p_client TYPE zcl_oapi_generator_v2=>ty_input-clas_client,
            p_impl   TYPE zcl_oapi_generator_v2=>ty_input-clas_icf_impl,
            p_serv   TYPE zcl_oapi_generator_v2=>ty_input-clas_icf_serv.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS p_file TYPE string.
SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA files   TYPE filetable.
  DATA return_code TYPE i.

  DATA file_filter TYPE string.
  DATA initial_directory TYPE string.
  DATA window_title TYPE string.
  DATA default_extension TYPE string.

  FIELD-SYMBOLS <file> LIKE LINE OF files.

  default_extension  = '.JSON'.
  file_filter = 'Text Files (*.JSON)|*.JSON'.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title      = window_title
      default_extension = default_extension
      file_filter       = file_filter
      initial_directory = initial_directory
    CHANGING
      file_table        = files
      rc                = return_code ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF files IS NOT INITIAL.
    READ TABLE files ASSIGNING <file> INDEX 1.
    IF sy-subrc = 0.
      p_file = <file>-filename.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF p_name <> space.
    p_intf = |ZIF_{ p_name }|.
    p_client = |ZCL_{ p_name }|.
    p_serv = |ZCL_{ p_name }_SRVR|.
    p_impl = |ZCL_{ p_name }_IMPL|.
  ENDIF.

START-OF-SELECTION.
  TYPES ty_data_line TYPE c LENGTH 2000.
  DATA: filename TYPE string,
        data_table TYPE TABLE OF ty_data_line.
  FIELD-SYMBOLS <data_line> TYPE ty_data_line.
  filename = p_file.
  cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = filename            " Name of file
        filetype                = 'ASC'              " File Type (ASCII, Binary)
        codepage                = '4110' " UTF-8
      CHANGING
        data_tab                = data_table           " Transfer table for file contents
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

  DATA json_string TYPE string.

  LOOP AT data_table ASSIGNING <data_line>.
    json_string = json_string && <data_line>.
  ENDLOOP.

  input-openapi_json = json_string.
  input-intf = p_intf.
  input-clas_client = p_client.
  input-clas_icf_impl = p_impl.
  input-clas_icf_serv = p_serv.

  result = zcl_oapi_generator=>generate_v2( input ).

  cl_demo_output=>display( result-intf ).
  cl_demo_output=>display( result-clas_client ).
  cl_demo_output=>display( result-clas_icf_impl ).
  cl_demo_output=>display( result-clas_icf_serv ).