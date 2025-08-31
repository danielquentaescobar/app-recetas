# 📱 INSTALACIÓN EN DISPOSITIVO ANDROID

## 🚀 **GENERAR APK**

### **1. Comando para generar APK:**
```bash
flutter build apk --release
```

### **2. Ubicación del APK generado:**
```
📁 build/app/outputs/flutter-apk/app-release.apk
```

---

## 📲 **INSTALAR EN DISPOSITIVO ANDROID**

### **Método 1: Cable USB (Recomendado)**

1. **Conectar dispositivo por USB**
2. **Activar "Depuración USB"** en Configuración > Opciones de desarrollador
3. **Transferir APK** al dispositivo
4. **Instalar desde el explorador de archivos**

### **Método 2: ADB (Android Debug Bridge)**

```bash
# Verificar dispositivo conectado
adb devices

# Instalar APK directamente
adb install build/app/outputs/flutter-apk/app-release.apk
```

### **Método 3: Compartir por Email/WhatsApp**

1. **Enviar APK** por email o WhatsApp a tu dispositivo
2. **Descargar** en el dispositivo
3. **Activar "Fuentes desconocidas"** en Configuración
4. **Instalar** desde Descargas

---

## ⚙️ **CONFIGURACIÓN DEL DISPOSITIVO**

### **Activar Depuración USB:**
1. Ir a **Configuración** → **Acerca del teléfono**
2. Tocar **"Número de compilación"** 7 veces
3. Ir a **Configuración** → **Opciones de desarrollador**
4. Activar **"Depuración USB"**

### **Permitir Fuentes Desconocidas:**
1. Ir a **Configuración** → **Seguridad**
2. Activar **"Fuentes desconocidas"** o **"Instalar apps desconocidas"**

---

## 🔧 **SOLUCIÓN DE PROBLEMAS**

### **Error de Java Heap Space**
Si obtienes error de "Java heap space":
```bash
# Editar android/gradle.properties y agregar:
org.gradle.jvmargs=-Xmx4G -XX:MaxPermSize=512m

# O compilar solo para ARM64 (más eficiente):
flutter build apk --release --target-platform android-arm64
```

### **Error de Gradle AGP Version**
Si obtienes error de Android Gradle Plugin:
```bash
# Limpiar proyecto
flutter clean
flutter pub get

# Verificar versiones en android/settings.gradle:
# com.android.application version "8.6.0" or higher
```

### **Error: "App not installed"**
- Desinstalar versión anterior si existe
- Verificar espacio de almacenamiento
- Reiniciar dispositivo

### **Error: "Parse error"**
- Verificar que el APK no esté corrupto
- Asegurar compatibilidad con Android del dispositivo
- Regenerar APK si es necesario

### **La app se cierra inmediatamente**
- Verificar permisos de la app
- Comprobar logs con: `adb logcat`
- Asegurar que Firebase esté configurado correctamente

### **Error de Java Version**
Si aparece error de compatibilidad:
```groovy
// En android/app/build.gradle, usar:
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
```

---

## 📝 **INFORMACIÓN DEL APK**

- **Nombre**: app-recetas
- **Package**: com.recetas.app  
- **Versión**: 1.0.0
- **Min SDK**: Android 21 (5.0)
- **Target SDK**: Android 34 (14.0)

---

## 🎯 **PROGRESO DE COMPILACIÓN**

### ✅ **Problemas Resueltos:**
1. **Android Gradle Plugin**: Actualizado a versión 8.6.0
2. **Java Version**: Configurado para Java 17
3. **NDK Version**: Actualizado a 26.1.10909125
4. **Compatibilidad Web/Móvil**: Archivos simplificados para compilación

### ⏳ **Estado Actual:**
- 🔄 **Descargando NDK**: Android está instalando las herramientas necesarias
- 📦 **Preparando compilación**: Esto puede tomar 5-10 minutos la primera vez
- 🎯 **APK en proceso**: Una vez completo, el APK estará en `build/app/outputs/flutter-apk/`

### 📱 **Después de la Compilación:**

1. **Ubicación del APK:**
   ```
   📁 build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Tamaño aproximado:** 50-80 MB (incluye Firebase y todas las dependencias)

3. **Compatible con:** Android 5.0+ (API 21+)
