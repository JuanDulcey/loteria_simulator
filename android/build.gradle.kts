plugins {
    // Es posible que ya tengas esta línea, si es así, déjala como la tenías.
    // Si no, usa esta versión segura (7.3.0 o superior):
    id("com.android.application") version "8.11.1" apply false

    // ⚠️ ESTA ES LA LÍNEA CLAVE: Asegura que Kotlin sea 2.2.20 o superior
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false

    // El plugin de Flutter (necesario)
    id("dev.flutter.flutter-gradle-plugin") apply false

    // El de Google Services que ya habías puesto
    id("com.google.gms.google-services") version "4.4.4" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
