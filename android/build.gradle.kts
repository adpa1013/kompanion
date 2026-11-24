import com.android.build.api.variant.LibraryAndroidComponentsExtension

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

    // Native CMake plugins (e.g. package:jni -> libdartjni.so) link with
    // -Wl,--build-id=sha1 before AGP strips debug symbols. Because unstripped
    // DWARF info embeds host-specific PUB_CACHE and NDK paths, the resulting
    // 20-byte .note.gnu.build-id differs between GitHub Actions and F-Droid,
    // breaking reproducible builds. Disable build-id so stripped .so files
    // are byte-for-byte identical across build environments.
    plugins.withId("com.android.library") {
        extensions.configure<LibraryAndroidComponentsExtension> {
            finalizeDsl { extension ->
                if (extension.externalNativeBuild.cmake.path != null) {
                    extension.defaultConfig.externalNativeBuild.cmake.arguments.add(
                        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,--build-id=none"
                    )
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
