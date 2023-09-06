*** Settings ***
Library     ConfluentKafkaLibrary
Library     Collections
Library     JSONLibrary
Library     DateTime


*** Variables ***
${GROUP_ID}             robot-consumer
${NICHT_ABGELAUFEN}     ${EMPTY}


*** Test Cases ***
Teste Todo
    [Setup]    Create Consumer    group_id=${GROUP_ID}    server=localhost    port=9093    auto_offset_reset=latest
    Subscribe Topic    group_id=${GROUP_ID}    topics=todo

    ${message}=    Konsumiere Bis    Todo Gefunden Wurde    ${GROUP_ID}
    Should Not Be Empty    ${message}

    [Teardown]    Close Consumer    ${GROUP_ID}


*** Keywords ***
Konsumiere Bis
    [Timeout]    1 minute
    [Arguments]    ${BEDINGUNG}    ${group_id}

    WHILE    ${True}
        ${messages}=    Poll    group_id=${group_id}    max_records=1

        ${len}=    Get Length    ${messages}
        IF    ${len} == 0    CONTINUE

        ${condition_met}=    Run Keyword    ${BEDINGUNG}    ${messages}[0]
        IF    ${condition_met}==True    RETURN    ${messages[0]}
    END

    Fail    msg=Die Kafka Message konnte nicht gefunden werden

Todo Gefunden Wurde
    [Arguments]    ${message}

    ${json}=    Convert String to JSON    ${message}
    ${id}=    Get value from JSON    ${json}    $.id

    Log To Console    ${message}    stream=STDERR
    IF    ${id}[0] == 100    RETURN    ${True}

    RETURN    ${False}
