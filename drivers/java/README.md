# Java README

This project builds the Speedo driver for SaxonJ. Place the jar file for the
version of Saxon that you want to use in the `lib` directory. If that version of
Saxon has other dependencies (JLine, ICU, XML Resolver, etc.) put all of the
relevant jar files in the `lib` directory as well.

The commands:

```
./gradlew clean
./gradlew jar
```

should succeed and create `build/libs/speedo.jar`.

Place all of the class files in the `lib` directory and the `speedo.jar` file on
your classpath to run the tests.

The task `speedo` will do this automatically. It uses the catalog, driver, and
output directories defined in `gradle.properties`. Override them on the command
line if you wish:

```
./gradlew -Pdrivers=drivers-alt.xml speedo
```
