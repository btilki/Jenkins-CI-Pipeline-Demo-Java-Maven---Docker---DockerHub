# Use a lightweight runtime image for Java 11
FROM eclipse-temurin:11-jre-jammy

# Application JAR (will be copied from build output)
ARG JAR_FILE=target/sample-java-app-1.0.0.jar
COPY ${JAR_FILE} /app/sample-java-app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/sample-java-app.jar"]