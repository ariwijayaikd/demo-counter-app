FROM maven as builder
WORKDIR /app
COPY . .
RUN mvn install

FROM openjdk:11.0
WORKDIR /app
COPY --from=builder /app/target/Uber.jar /app/
EXPOSE 8090
CMD [ "java","jar","Uber.jar" ]