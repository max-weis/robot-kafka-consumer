*** Settings ***
Library     ConfluentKafkaLibrary
Library     Collections
Library     JSONLibrary


*** Variables ***
${GROUP_ID}     robot-consumer
${SERVER}       localhost
${PORT}         9093
${TOPIC}        todo


*** Test Cases ***
Teste Todo
    [Setup]    Create Consumer    group_id=${GROUP_ID}    server=${SERVER}    port=${PORT}    auto_offset_reset=latest

    Subscribe Topic    group_id=${GROUP_ID}    topics=${TOPIC}

    ${message}=    Konsumiere Bis    Todo Gefunden Wurde    ${GROUP_ID}
    Should Not Be Empty    ${message}

    [Teardown]    Close Consumer    ${GROUP_ID}


*** Keywords ***
Konsumiere Bis
    [Documentation]    Das Keyword akzeptiert ein "inner"-Keyword(BEDINGUNG), welches für jede Nachricht aufgerufen wird.
    ...    Das "inner"-Keyword muss genau ein Parameter annehmen, welcher ein JSON-Objekt ist. Der Konsument muss bereits das Topic konsumieren.
    [Arguments]    ${BEDINGUNG}    ${group_id}
    WHILE    True
        ${messages}=    Poll    group_id=${group_id}    max_records=1

        ${len}=    Get Length    ${messages}
        IF    ${len} == 0    CONTINUE

        ${condition_met}=    Run Keyword    ${BEDINGUNG}    ${messages}[0]
        IF    ${condition_met}==True    RETURN    ${messages[0]}
    END
    RETURN    ${messages[0]}

Todo Gefunden Wurde
    [Arguments]    ${message}

    ${json}=    Convert String to JSON    ${message}
    ${id}=    Get value from JSON    ${json}    $.id

    Log To Console    ${message}    stream=STDERR
    IF    ${id}[0] < 100    RETURN    ${True}

    RETURN    ${False}
