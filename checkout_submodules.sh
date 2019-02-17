#!/bin/bash
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

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
