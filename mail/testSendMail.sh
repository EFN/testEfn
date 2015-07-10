#!/bin/bash

TESTFILE=testSendMail

FROM=$(echo $(grep 'From:' ${TESTFILE} | cut -d: -f2))

sendmail -vt -f ${FROM} < ${TESTFILE}
