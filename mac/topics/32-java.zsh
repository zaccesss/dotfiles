# =============================================================================
# Java, Maven and Gradle
# I use Maven and Gradle depending on the project. Gradle aliases use the
# wrapper script (./gradlew) so they work with the project-specific version.
# =============================================================================

# Maven
alias mvnt="mvn test"
alias mvnb="mvn package"
alias mvni="mvn install"
alias mvnc="mvn clean"
alias mvncb="mvn clean package"
alias mvndep="mvn dependency:tree"
alias mvnskip="mvn install -DskipTests"

# Gradle wrapper - requires ./gradlew in the project root
alias gwb="./gradlew build"
alias gwt="./gradlew test"
alias gwr="./gradlew run"
alias gwc="./gradlew clean"
alias gwcb="./gradlew clean build"
alias gwdep="./gradlew dependencies"
alias gwtasks="./gradlew tasks"
