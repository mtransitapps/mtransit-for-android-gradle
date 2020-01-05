#!/bin/bash
source commons/commons.sh;
echo "================================================================================";
echo "> RUN ALL...";
echo "--------------------------------------------------------------------------------";
BEFORE_DATE=$(date +%D-%X);
BEFORE_DATE_SEC=$(date +%s);

CURRENT_PATH=$(pwd);
CURRENT_DIRECTORY=$(basename ${CURRENT_PATH});
AGENCY_ID=$(basename -s -gradle ${CURRENT_DIRECTORY});

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
if [[ "$GIT_BRANCH" = "HEAD" ]]; then
	GIT_BRANCH="";
fi
if [[ -z "${GIT_BRANCH}" ]]; then
	GIT_BRANCH=${TRAVIS_PULL_REQUEST_BRANCH}; #TravicCI
	if [[ "$GIT_BRANCH" = "HEAD" ]]; then
		GIT_BRANCH="";
	fi
fi
if [[ -z "${GIT_BRANCH}" ]]; then
	GIT_BRANCH=${TRAVIS_BRANCH}; #TravicCI
	if [[ "$GIT_BRANCH" = "HEAD" ]]; then
		GIT_BRANCH="";
	fi
fi
if [[ -z "${GIT_BRANCH}" ]]; then
	GIT_BRANCH=${CI_COMMIT_REF_NAME}; #GitLab
	if [[ "$GIT_BRANCH" = "HEAD" ]]; then
		GIT_BRANCH="";
	fi
fi
if [[ -z "${GIT_BRANCH}" ]]; then
	echo "GIT_BRANCH not found!";
	exit 1;
fi
echo "GIT_BRANCH: $GIT_BRANCH.";

CONFIRM=false;

IS_CI=false;
if [[ ! -z "${CI}" ]]; then
	IS_CI=true;
fi
echo "/build.sh > IS_CI:'${IS_CI}'";

GRADLE_ARGS="";
if [[ ${IS_CI} = true ]]; then
	GRADLE_ARGS=" --console=plain";
fi

declare -a EXCLUDE=(".git" "test" "build" "gen" "gradle");

echo "> CLEANING FOR '$AGENCY_ID'...";
for d in ${PWD}/* ; do
	DIRECTORY=$(basename ${d});
	if ! [[ -d "$d" ]]; then
		echo "> Skip GIT cleaning (not a directory) '$DIRECTORY'.";
		echo "--------------------------------------------------------------------------------";
		continue;
	fi
	if contains ${DIRECTORY} ${EXCLUDE[@]}; then
		echo "> Skip GIT cleaning in excluded directory '$DIRECTORY'.";
		echo "--------------------------------------------------------------------------------";
		continue;
	fi
	if [[ -d "$d" ]]; then
		cd ${d} || exit;
		echo "> GIT cleaning in '$DIRECTORY'...";
		GIT_REV_PARSE_HEAD=$(git rev-parse HEAD);
		GIT_REV_PARSE_REMOTE_BRANCH=$(git rev-parse origin/${GIT_BRANCH});
		if [[ "$GIT_REV_PARSE_HEAD" != "$GIT_REV_PARSE_REMOTE_BRANCH" ]]; then
			echo "> GIT repo outdated in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
			exit 1;
		else
			echo "> GIT repo up-to-date in '$DIRECTORY' (local:$GIT_REV_PARSE_HEAD|origin/$GIT_BRANCH:$GIT_REV_PARSE_REMOTE_BRANCH).";
		fi

		git checkout ${GIT_BRANCH};
		checkResult $? ${CONFIRM};

		git pull;
		checkResult $? ${CONFIRM};
		echo "> GIT cleaning in '$DIRECTORY'... DONE";
		cd ..;
		echo "--------------------------------------------------------------------------------";
	fi
done

if [[ -d "agency-parser" ]]; then
	echo "> CLEANING FOR '$AGENCY_ID'... (GRADLE BUILD)";
	./gradlew :parser:clean :parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};

	./gradlew :agency-parser:clean :agency-parser:build ${GRADLE_ARGS};
	checkResult $? ${CONFIRM};
	echo "> CLEANING FOR '$AGENCY_ID'... DONE";

	echo "> PARSING DATA FOR '$AGENCY_ID'...";
	cd agency-parser || exit;

    chmod +x download.sh;
    checkResult $? ${CONFIRM};
	./download.sh;
	checkResult $? ${CONFIRM};

    chmod +x parse_current.sh;
    checkResult $? ${CONFIRM};
	./parse_current.sh;
	checkResult $? ${CONFIRM};

    chmod +x parse_next.sh;
    checkResult $? ${CONFIRM};
	./parse_next.sh;
	checkResult $? ${CONFIRM};

    chmod +x list_change.sh;
    checkResult $? ${CONFIRM};
	./list_change.sh;
	checkResult $? ${CONFIRM};

	cd ..;
	echo "> PARSING DATA FOR '$AGENCY_ID'... DONE";
else
	echo "> SKIP PARSING FOR '$AGENCY_ID'.";
fi

echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'...";
cd app-android || exit;

chmod +x bump_version.sh;
checkResult $? ${CONFIRM};
./bump_version.sh
checkResult $? ${CONFIRM};

chmod +x build.sh;
checkResult $? ${CONFIRM};
./build.sh
checkResult $? ${CONFIRM};

cd ..;
echo "> BUILDING ANDROID APP FOR '$AGENCY_ID'... DONE";
echo "--------------------------------------------------------------------------------";

AFTER_DATE=$(date +%D-%X);
AFTER_DATE_SEC=$(date +%s);
DURATION_SEC=$(($AFTER_DATE_SEC-$BEFORE_DATE_SEC));
echo "> $DURATION_SEC secs FROM $BEFORE_DATE TO $AFTER_DATE";
echo "> RUN ALL... DONE";
echo "================================================================================";
