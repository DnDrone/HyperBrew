plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    // Esta linha aplica o plugin do Google Services que lê o seu google-services.json
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // O Flutter Gradle Plugin deve ser aplicado após os plugins Android e Kotlin Gradle.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Configurações do namespace para seu aplicativo
    namespace = "com.example.hyperbrew" // Mantenha este valor conforme o seu projeto
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Opções de compilação para Java (Flutter usa Java 11 por padrão)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    // Opções para Kotlin
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Configurações padrão do aplicativo
    defaultConfig {
        // TODO: Especifique seu próprio ID de aplicativo exclusivo.
        applicationId = "com.example.hyperbrew" // Mantenha este valor conforme o seu projeto
        // Você pode atualizar os seguintes valores para corresponder às suas necessidades de aplicativo.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Tipos de build (release, debug)
    buildTypes {
        release {
            // TODO: Adicione sua própria configuração de assinatura para o build de release.
            // Assinando com as chaves de debug por enquanto, para que `flutter run --release` funcione.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// START: Dependências do Projeto
// Este bloco 'dependencies' é onde você adiciona todas as bibliotecas que seu aplicativo usa.
dependencies {
    // Firebase BoM (Bill of Materials) - Gerencia as versões das dependências do Firebase
    // Recomenda-se usar a versão mais recente para compatibilidade.
    // Verifique a documentação oficial do Firebase para a versão mais recente.
    implementation(platform("com.google.firebase:firebase-bom:32.7.4")) // Você pode atualizar esta versão

    // Dependência principal do Firebase Authentication
    implementation("com.google.firebase:firebase-auth")

    // Dependência para o Google Sign-In (necessário se você estiver usando o google_sign_in no Flutter)
    implementation("com.google.android.gms:play-services-auth:20.7.0") // Você pode precisar ajustar esta versão

    // Dependência para Firebase Analytics (opcional, mas bom para rastreamento)
    implementation("com.google.firebase:firebase-analytics")

    // Você pode adicionar outras dependências Android aqui, se o seu projeto as tiver.
    // Por exemplo:
    // implementation("androidx.appcompat:appcompat:1.6.1")
    // implementation("androidx.constraintlayout:constraintlayout:2.1.4")
}
// END: Dependências do Projeto