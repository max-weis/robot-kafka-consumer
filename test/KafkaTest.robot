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
    Subscribe Topic  group_id=${GROUP_ID}  topics=${TOPIC}
    ${message}=  Consume Until  ${GROUP_ID}  Condition Keyword  ${TOPIC}
    Should Not Be Empty  ${message}
    Unsubscribe  ${GROUP_ID}

*** Keywords ***
Condition Keyword
    [Arguments]  ${message}
    ${condition}=  Run Keyword And Return Status  Is Number Greater Than 100   ${message}[id]
    [Return]  ${condition}

Is Number Greater Than 100
    [Arguments]  ${number}
    ${is_greater}=  Evaluate  ${number} > 100
    [Return]  ${is_greater}

Consume Until
    [Arguments]  ${group_id}  ${condition_keyword}  ${topic}
    WHILE    True
        ${result}=  Poll  group_id=${group_id}  max_records=1
        Log To Console        ${result}  stream=STDERR
        ${condition_met}=  Run Keyword  ${condition_keyword}  ${result[0]}
        Run Keyword If  ${condition_met}==True  Exit For Loop
    END
    [Return]  ${result[0]}
