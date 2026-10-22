# =============================================================================
# Java, Maven and Gradle
# Gradle uses the Windows wrapper script (.\gradlew.bat) rather than the
# Unix ./gradlew so it works without Git Bash being on PATH.
# =============================================================================

function mvnt  { mvn test }
function mvnb  { mvn package }
function mvni  { mvn install }
function mvnc  { mvn clean }
function mvncb  { mvn clean package }
function mvndep { mvn dependency:tree }
function mvnskip { mvn install -DskipTests }

function gwb  { .\gradlew.bat build }
function gwt  { .\gradlew.bat test }
function gwr  { .\gradlew.bat run }
function gwc  { .\gradlew.bat clean }
function gwcb { .\gradlew.bat clean build }
function gwdep { .\gradlew.bat dependencies }
function gwtasks { .\gradlew.bat tasks }
