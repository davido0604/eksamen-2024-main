FROM maven:3.9.4-eclipse-temurin-17 as builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package

FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY --from=builder /app/target/imagegenerator-0.0.1-SNAPSHOT.jar /app/imagegenerator.jar

ENV SQS_QUEUE_URL=""

ENTRYPOINT ["java", "-jar", "/app/imagegenerator.jar"]