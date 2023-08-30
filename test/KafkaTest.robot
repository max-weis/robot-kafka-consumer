*** Settings ***
Library  ConfluentKafkaLibrary
Library  Collections
Library  JSONLibrary


*** Variables ***
${GROUP_ID}  my-consumer-group
${SERVER}  localhost
${PORT}  9093
${ENABLE_AUTO_COMMIT}  True
${AUTO_OFFSET_RESET}  latest
${TOPIC}  todo

*** Test Cases ***
Test Incoming Messages On Todo Topic
    [Setup]  Create Consumer  group_id=${GROUP_ID}  server=${SERVER}  port=${PORT}  enable_auto_commit=${ENABLE_AUTO_COMMIT}  auto_offset_reset=${AUTO_OFFSET_RESET}
    [Teardown]  Close Consumer  ${GROUP_ID}
    Subscribe Topic  group_id=${group_id}  topics=${TOPIC}
    ${result}=  Poll  group_id=${group_id}  max_records=5
    Should Not Be Empty  ${result}
    ${message_dict}=  Evaluate  json.loads($result[0])  json
    Dictionary Should Contain Key  ${message_dict}  id
    Dictionary Should Contain Key  ${message_dict}  todo
    Unsubscribe  ${group_id}
