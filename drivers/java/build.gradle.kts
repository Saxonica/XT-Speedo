buildscript {
  repositories {
    mavenLocal()
    mavenCentral()
    maven { url = uri("https://maven.saxonica.com/maven") }
  }
}

plugins {
  id("java-library")
}

repositories {
  mavenLocal()
  mavenCentral()
  maven { url = uri("https://maven.saxonica.com/maven") }
}

val speedo by configurations.creating {
  extendsFrom(configurations["implementation"])
}

dependencies {
  implementation("com.fasterxml:aalto-xml:1.3.4")
  implementation("org.jdom:jdom2:2.0.6.1")
  implementation("nu.validator:validator:20.7.2")
  implementation(fileTree("dir" to layout.projectDirectory.dir("lib"),
                          "include" to "*.jar"))
}

sourceSets {
  main {
    java {
      exclude("com/saxonica/xtspeedo/altova/**")
      exclude("com/saxonica/xtspeedo/saxonhe/SaxonEEAaltoDriver*")
    }
  }
}

java {
  sourceCompatibility = JavaVersion.VERSION_1_8
  targetCompatibility = JavaVersion.VERSION_1_8
}

tasks.jar {
  archiveBaseName.set("speedo")
}

tasks.register<JavaExec>("speedo") {
  classpath = sourceSets["main"].runtimeClasspath
  mainClass = "com.saxonica.xtspeedo.Speedo"

  val catalog = layout.projectDirectory.file("../../data/${findProperty("catalog")}")
  val drivers = layout.projectDirectory.file("../../data/${findProperty("drivers")}")
  val output = layout.projectDirectory.file("../../results/${findProperty("output")}")

  args("-cat:${catalog}",
       "-dr:${drivers}",
       "-out:${output}")
}
