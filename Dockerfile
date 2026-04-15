# ---- Stage 1: Build ----multi stage---
#FROM maven:3.9.4-eclipse-temurin-17 AS builder
 
#WORKDIR /app
 
# Copy pom.xml first for dependency caching
#COPY pom.xml .
#RUN mvn dependency:go-offline -B
 
# Copy source and package
#COPY src ./src
#RUN mvn clean package -DskipTests
 
# ---- Stage 2: Runtime ----
# ---- Single Stage: Runtime only ----
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy JAR built by Jenkins (not Maven inside Docker)
COPY target/*.jar app.jar

RUN chown appuser:appgroup app.jar

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
