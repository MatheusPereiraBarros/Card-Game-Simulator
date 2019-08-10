#! /bin/sh

UNITY_PROJECT_NAME="Card Game Simulator"

if [ -z "${CI}" ]; then
    UNITY_PATH="/Applications/Unity/Hub/Editor/2018.4.0f1/Unity.app/Contents/MacOS/Unity"
else
    UNITY_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
fi
UNITY_BUILD_DIR=$(pwd)/builds
UNITY_ACTIVATION_LOG_FILE=$UNITY_BUILD_DIR/unity.activation.log
UNITY_RETURN_LOG_FILE=$UNITY_BUILD_DIR/unity.returnlicense.log
OSX_LOG_FILE=$UNITY_BUILD_DIR/OSX.log
IOS_LOG_FILE=$UNITY_BUILD_DIR/iOS.log

echo "Activating Unity license"
${UNITY_PATH} \
    -logFile "$UNITY_ACTIVATION_LOG_FILE" \
    -serial ${UNITY_SERIAL} \
    -username ${UNITY_USER} \
    -password ${UNITY_PWD} \
    -batchmode \
    -noUpm \
    -quit
echo "Unity activation log:"
cat $UNITY_ACTIVATION_LOG_FILE

echo "Attempting to build $UNITY_PROJECT_NAME for OSX"
${UNITY_PATH} \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile "$OSX_LOG_FILE" \
  -projectPath "$(pwd)" \
  -buildOSXUniversalPlayer "$UNITY_BUILD_DIR/OSX/$UNITY_PROJECT_NAME.app" \
  -quit
rc0=$?
echo 'OSX build logs:'
cat $OSX_LOG_FILE

echo "Attempting to build $UNITY_PROJECT_NAME for iOS"
${UNITY_PATH} \
    -batchmode \
    -silent-crashes \
    -logFile "$IOS_LOG_FILE" \
    -projectPath "$(pwd)" \
    -executeMethod BuildCGS.iOS \
    -quit
rc1=$?
echo 'iOS build logs:'
cat $IOS_LOG_FILE

echo "Returning Unity license"
${UNITY_PATH} \
    -logFile "$UNITY_RETURN_LOG_FILE" \
    -batchmode \
    -returnlicense \
    -quit
echo "Unity return log:"
cat $UNITY_RETURN_LOG_FILE

STATUS_CODE=$(($rc0|$rc1))
echo "Finishing with code $STATUS_CODE"
exit $STATUS_CODE