# Changelog

---

## Julio de 2026

### Semana del 13 al 19 de julio
- 19 de julio:
    - Corrección del bug que hacia saltar los nodos cuando se trataban de dibujar dos aristas idénticas
    - Botón para aleatorizar grafos
    - Plantilla de exportación
- 18 de julio:
    - Eliminación de métodos innecesarios en `EdgeData` y `World`
    - Adición de un texto para el peso de las aristas, con color y posición autoajustable
    - Adición de botones para aristas dirigidas
    - Corrección del texto de la lista de nodos y panel de fondo para el mismo
    - Mejor feedback visual y comodidad al dibujar aristas

---

## Junio de 2026

### Semana del 22 al 28 de junio
- 24 de junio:
    - Eliminación de `VectorDisplay2D`
    - Actualización a Godot 4.7
    - Actualizaciones en el changelog y lista de tareas
    - Eliminación de la inicialización al azar de los nodos
    - Señales sin uso en edge_data eliminadas

---

## Mayo de 2026

### Semana del 18 al 24 de mayo
- 24 de mayo: Prototipo de dibujado de aristas
- 20 de mayo: 
    - Carga de grafos con aristas funcionales, sistema de archivos y nombre de archivo actual
    - Rediseño de los datos para meyor eficiencia
- 19 de mayo:
    - Refactorización masiva de físicas: centralización y optimización
    - Mejoras de robustez con validaciones de validez de instancias en procesos físicos y carga de datos
    - Refactor en la organización de la interfaz y el manejo de datos y físicas

### Semana del 11 al 17 de mayo
- 14 de mayo: Nuevo README con demostración visual y soporte para personalización del fondo
- 12 de mayo: Sistema de snapshots y carga de grafos desde archivos (v1)
- 11 de mayo: Marcador visual de "cambios no guardados" en la interfaz

### Semana del 4 al 10 de mayo
- 10 de mayo: 
    - Base de recursos para el almacenamiento persistente del grafo
    - Interfaz de usuario base: lista de nodos, botones de acción y contador de FPS
    - Sistema de guardado manual del estado del grafo
- 9 de mayo: Corrección en el sistema de posicionamiento al instanciar objetos

### Semana del 27 de abril al 3 de mayo
- 2 de mayo: Implementación de fuerzas físicas: repulsión de Coulomb, fuerza elástica de Hooke y gravedad inversa
- 3 de mayo: Mejoras en el sistema de centrado y optimización del sistema de desactivación

---

## Abril de 2026

### Semana del 27 de abril al 3 de mayo
- 29 de abril: 
    - Migración a un sistema basado en datos (NodeData y EdgeData) para desacoplar la lógica visual
    - Optimizaciones en el dibujado de curvas y gestión de señales en aristas

### Semana del 20 al 26 de abril
- 26 de abril: 
    - Prototipo inicial de aristas con soporte para aristas dirigidas y optimización de dibujado
    - Mejoras en el instanciador: cancelación de clics y ajustes de organización
- 25 de abril: Implementación funcional del sistema de instanciación por arrastre
- 24 de abril: 
    - Soporte para escala, peso y corrección de bugs en el arrastre de nodos
    - Eliminada la restricción de movimiento por bordes de pantalla
- 21 de abril: Prototipo de nodos con sprites, soporte de color y efectos de transición visual

### Semana del 13 al 19 de abril
- 17 de abril: 
    - Prototipo de objeto arrastable con el mouse
    - VectorDisplay2D instalado y configuración inicial
