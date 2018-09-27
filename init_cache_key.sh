#!/bin/bash
source commons/commons.sh;

RESULT_FILE="gradle_cache_key_checksum.txt";

if [ -f ${RESULT_FILE} ]; then
  rm ${RESULT_FILE};
fi
touch ${RESULT_FILE};

checksum_file() {
  echo `openssl md5 $1 | awk '{print $2}'`
}

MT_CACHE_KEY="gradle-cache";
echo "gradle-cache" >> ${RESULT_FILE}
echo `checksum_file build.gradle` >> ${RESULT_FILE}
echo `checksum_file commons-android/build.gradle` >> ${RESULT_FILE}
echo `checksum_file commons-android/commons-android.gradle` >> ${RESULT_FILE}
echo `checksum_file app-android/build.gradle` >> ${RESULT_FILE}

if [ -d "parser" ]; then
    echo `checksum_file parser/build.gradle` >> ${RESULT_FILE}
    echo `checksum_file agency-parser/build.gradle` >> ${RESULT_FILE}
fi

echo "${RESULT_FILE}:";
echo "----------";
cat ${RESULT_FILE};
echo "----------";
