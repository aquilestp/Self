# Habilitar HealthKit capability en el proyecto

## Problema

El entitlement `com.apple.developer.healthkit` está en el archivo de entitlements, pero el proyecto no tiene registrada la capability de HealthKit en su configuración. Esto hace que el perfil de provisioning no incluya HealthKit y la app falla en el dispositivo.

## Solución

Agregar la entrada `SystemCapabilities` para HealthKit en el `project.pbxproj`, dentro de los atributos del target principal. Esto le indica a Xcode que incluya HealthKit en el perfil de provisioning al compilar.

**Cambio específico:** En `TargetAttributes` → target `SelfSport`, agregar:

```
SystemCapabilities = {
    com.apple.HealthKit = {
        enabled = 1;
    };
};
```

Esto resuelve el error "Missing com.apple.developer.healthkit entitlement" sin tocar el App Store ni hacer ningún deploy.  
  
Esta ok. Solo no hagas deploy de build a la appstore!! 