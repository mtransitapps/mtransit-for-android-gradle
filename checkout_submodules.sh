#!/bin/bash
# ORIGINAL FILE: https://github.com/mtransitapps/commons/tree/master/shared-overwrite
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

IS_SHALLOW=$(git rev-parse --is-shallow-repository);
if [[ "$IS_SHALLOW" == true ]]; then
	echo "> Fetching unshallow GIT repo...";
	git fetch --unshallow;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "> Error while fetching unshallow GIT repository!";
		exit ${RESULT};
	fi
	echo "> Fetching unshallow GIT repo... DONE";
else
	echo "> Not a shallow GIT repo.";
fi

declare -a SUBMODULES=(
	"commons"
	"commons-android"
	"app-android"
);
if [[ -d "parser" ]]; then
    SUBMODULES+=('parser');
    SUBMODULES+=('agency-parser');
fi
echo "Submodules:";
printf '* "%s"\n' "${SUBMODULES[@]}";

for SUBMODULE in "${SUBMODULES[@]}" ; do
	if ! [[ -d "$SUBMODULE" ]]; then
		echo "> Submodule does NOT exist '$SUBMODULE'!";
		exit 1;
	fi
	git submodule update --init --recursive ${SUBMODULE};
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while update GIT submodule '$SUBMODULE'!";
		exit ${RESULT};
	fi
	echo "'$SUBMODULE' updated successfully."
done
