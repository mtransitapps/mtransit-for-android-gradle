#!/bin/bash
source commons/commons.sh;

MT_CACHE_KEY="jars";
MT_CACHE_KEY="$MT_CACHE_KEY-{{ checksum \"build.gradle\" }}";
MT_CACHE_KEY="$MT_CACHE_KEY-{{ checksum \"commons-android/build.gradle\" }}";
MT_CACHE_KEY="$MT_CACHE_KEY-{{ checksum \"commons-android/commons-android.gradle\" }}";
MT_CACHE_KEY="$MT_CACHE_KEY-{{ checksum \"app-android/build.gradle\" }}";
if [ -d "parser" ]; then
    MT_CACHE_KEY="$MT_CACHE_KEY-{{ checksum \"parser/build.gradle\" }}";
    MT_CACHE_KEY="$MT_CACHE_KEY-{{ checksum \"agency-parser/build.gradle\" }}";
fi

echo "MT_CACHE_KEY: $MT_CACHE_KEY";

if [[ -z "${BASH_ENV}" ]]; then
    echo "BASH_ENV environment variable is NOT defined.";
else
    echo "BASH_ENV: $BASH_ENV";
    ls -l $BASH_ENV;
    cat $BASH_ENV;
    echo 'export MT_CACHE_KEY=$(echo $MT_CACHE_KEY)' >> $BASH_ENV
    echo "BASH_ENV: $BASH_ENV";
    ls -l $BASH_ENV;
    cat $BASH_ENV;
    source $BASH_ENV;
fi
