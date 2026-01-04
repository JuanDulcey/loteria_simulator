# 🎴 Lotería Simulator

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase&logoColor=black)
![Cloud Firestore](https://img.shields.io/badge/Cloud_Firestore-NoSQL-FFCA28?logo=firebase&logoColor=black)
![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-Authentication-FFCA28?logo=firebase&logoColor=black)

![Android](https://img.shields.io/badge/Android-SDK-3DDC84?logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-Swift-000000?logo=apple&logoColor=white)
![C++](https://img.shields.io/badge/C%2B%2B-Native-00599C?logo=c%2B%2B&logoColor=white)

![Google Cloud](https://img.shields.io/badge/Google_Cloud-Integrated-4285F4?logo=googlecloud&logoColor=white)
![Git](https://img.shields.io/badge/Git-Version_Control-F05032?logo=git&logoColor=white)

**Simulador de Lotería Colombiana profesional desarrollado con Flutter.**

Este proyecto digitaliza la experiencia de la lotería tradicional, permitiendo partidas rápidas con generación dinámica de cartones y validación automática de reglas clásicas. El desarrollo se concibió como un **MVP (Producto Mínimo Viable)** funcional, enfocado en explorar el ecosistema de Google y el desarrollo móvil de alto rendimiento.

## 🎯 Propósitos del Proyecto
1. **Exploración de Flutter & Dart:** Profundizar en el desarrollo multiplataforma utilizando Android Studio como IDE principal.
2. **Integración con Google Ecosystem:** Implementar servicios de Firebase para la persistencia de datos y gestión de usuarios.
3. **Optimización de Workflow:** Maximizar el uso de *Hot Reload* y pruebas en tiempo real mediante máquinas virtuales (AVD) de Android.
4. **Desafío Multilenguaje:** Gestionar un proyecto que, aunque centralizado en Dart, integra lógica en C++ y Swift para optimizaciones nativas.

## 🛠️ Tecnologías y Servicios
* **Frontend:** Flutter & Dart (UI Reactiva).
* **Backend (BaaS):**
  * **Cloud Firestore:** Base de datos NoSQL para el registro de partidas y resultados.
  * **Firebase Authentication:** Gestión de sesiones y seguridad de usuarios.
* **Google Cloud:** Integración de servicios en la nube para escalabilidad.
* **Arquitectura de Ambientes:** Configuración de 5 ambientes dependientes (Flavors) para un despliegue controlado (Dulceyson Edition).

## 📊 Composición del Código
El proyecto refleja un manejo versátil de diferentes lenguajes para la integración de plugins y optimización del motor:
- **Dart:** (Lógica de negocio y UI)
- **C++/C/CMake:** (Lógica nativa y bindings)
- **Swift:** (Integración iOS)
- **HTML/Otros:** (Soporte web y configuraciones)

## 🧩 Arquitectura

El proyecto sigue una arquitectura modular basada en capas:

- **Presentation:** Widgets y manejo de estado
- **Domain:** Reglas de negocio de la lotería
- **Data:** Firebase, simulación local y persistencia

## 🚀 Instalación y Configuración

### Requisitos Previos
* Flutter SDK instalado.
* Android Studio con un Emulador configurado.

### Pasos para Clonar
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/JuanDulcey/loteria_simulator.git
2. **Obtener dependencias:**
   ```bash
   flutter pub get

## ⚠️ Configuración Importante de Firebase

Para que las funciones de autenticación y base de datos operen correctamente, debes configurar tu propio proyecto en **Firebase**:

- Descarga tu archivo `google-services.json` y ubícalo en: android/app/
- Habilita **Google Authentication** y **Firestore** en la consola de Firebase.

### 🔓 Modo Invitado
Si no deseas configurar Firebase, el simulador permite el ingreso como **invitado** para probar la lógica local de la lotería sin dependencias externas.

---

## 🧠 Reflexión del Desarrollador

Este proyecto representó un reto agradable y enriquecedor. Programar en diferentes lenguajes y entornos de ejecución permitió una comprensión más profunda de cómo interactúan las capas de **hardware** y **software** en dispositivos móviles.

Es un ejemplo sólido de cómo una idea tradicional puede transformarse en una herramienta digital moderna y eficiente.

Desarrollado por Juan Dulcey.
