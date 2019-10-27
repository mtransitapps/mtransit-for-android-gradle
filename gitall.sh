#!/bin/bash
#NO DEPENDENCY <= EXECUTED BEFORE GIT SUBMODULE

echo "================================================================================";
echo "> GIT COMMAND '$@' ON ALL GIT PROJECTS...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

if [[ -z "${@}" ]]; then
	echo "missing GIT command!";
	exit 1;
fi

# CURRENT GIT PROJECT

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});

echo "> Running GIT command '$@' in '$CURRENT_DIRECTORY'...";
git ${@};
RESULT=$?;
echo "> Running GIT command '$@' in '$CURRENT_DIRECTORY'... DONE";
if [[ ${RESULT} -ne 0 ]]; then
	echo "Error while runing GIT command '$@'!";
	exit ${RESULT};
fi
echo "--------------------------------------------------------------------------------";

# GIT SUBMODULES

declare -a SUBMODULES=(
	"commons"
	"commons-android"
	"app-android"
);
if [[ -d "parser" ]]; then
    SUBMODULES+=('parser');
    SUBMODULES+=('agency-parser');
fi
# cho "Submodules:"; #DEBUG
# printf '* "%s"\n' "${SUBMODULES[@]}"; #DEBUG

for SUBMODULE in "${SUBMODULES[@]}" ; do
	if ! [[ -d "$SUBMODULE" ]]; then
		echo "> Submodule does NOT exist '$SUBMODULE'!";
		exit 1;
	fi
	cd $SUBMODULE;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while entering GIT submodule '$SUBMODULE'!";
		exit ${RESULT};
	fi
	echo "> Running GIT command '$@' in '$SUBMODULE'...";
	git ${@};
	RESULT=$?;
	echo "> Running GIT command '$@' in '$SUBMODULE'... DONE";
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while runing GIT command '$@'!";
		exit ${RESULT};
	fi
	echo "--------------------------------------------------------------------------------";
	cd ../;
	RESULT=$?;
	if [[ ${RESULT} -ne 0 ]]; then
		echo "Error while leaving GIT submodule '$SUBMODULE'!";
		exit ${RESULT};
	fi
done

echo "--------------------------------------------------------------------------------";
AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> GIT COMMAND '$@' ON ALL GIT PROJECTS... DONE";
echo "================================================================================";
