INTERFACE zif_spec01 PUBLIC.
* Generated by abap-openapi-client
* test, 1.2.3

* Component schema: ErrorMessage, object
  TYPES: BEGIN OF errormessage,
           message TYPE string,
         END OF errormessage.

* Component schema: QOS, integer
  TYPES qos TYPE i.

* POST - "Publish message to a queue"
* Operation id: publish-message-to-queue
* Parameter: queue-name, required, path
* Parameter: x-qos, required, header
* Parameter: x-message-expiration, optional, header
* Response: 204
* Response: 400
*     application/json, #/components/schemas/ErrorMessage
* Response: 404
*     application/json, #/components/schemas/ErrorMessage
* Body schema: string
  METHODS publish_message_to_queue
    IMPORTING
      queue_name TYPE string
      x_qos TYPE qos
      x_message_expiration TYPE i OPTIONAL
      body TYPE string
    RAISING cx_static_check.

ENDINTERFACE.
