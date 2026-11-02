# Práctica 8: Uso de Ansible para automatizar tareas en servidores

**Asignatura:** Electiva II  
**Objetivo:** Automatizar la configuración y el aprovisionamiento de 5 servidores virtuales Ubuntu ejecutándose en contenedores Docker mediante **Ansible**.

---

## 📋 Resumen de Requerimientos y Pasos Implementados

### 1) Imagen base de Ubuntu (`Dockerfile`)
- Basada en `ubuntu:22.04 LTS`.
- Servidor SSH (`openssh-server`) configurado y en ejecución.
- Usuario `ansible` creado con contraseña `ansible`.
- Privilegios `sudo` sin solicitud de contraseña (`NOPASSWD:ALL`).
- `python3` y utilidades del sistema preinstaladas (requisito para que los módulos de Ansible se ejecuten en los nodos gestionados).

### 2) Orquestación de 5 Servidores (`docker-compose.yml`)
- 5 servicios independientes: `server1`, `server2`, `server3`, `server4` y `server5`.
- Red virtual bridge dedicada (`ansible_net`, subred `172.20.0.0/16`).
- Direcciones IP estáticas asignadas:
  - `server1`: `172.20.0.11` (puerto host `2201`)
  - `server2`: `172.20.0.12` (puerto host `2202`)
  - `server3`: `172.20.0.13` (puerto host `2203`)
  - `server4`: `172.20.0.14` (puerto host `2204`)
  - `server5`: `172.20.0.15` (puerto host `2205`)

### 3) Instalación de Ansible (en WSL o Linux)
- En Windows mediante WSL (Subsistema de Windows para Linux con Ubuntu).
- Paquetes necesarios: `ansible` y `sshpass` (para autenticación SSH basada en contraseña).

### 4) Archivo de Inventario (`inventario.ini`) y Configuración (`ansible.cfg`)
- **`inventario.ini`**: Define el grupo `[servidores]`, sus nombres, direcciones IP, puertos y credenciales (`ansible` / `ansible`).
- **`ansible.cfg`**: Apunta al inventario predeterminado y desactiva la verificación de claves de host (`host_key_checking = False`, `StrictHostKeyChecking=no`).

### 5) Playbook de Automatización (`playbook.yml`)
Automatiza en los 5 servidores las siguientes tareas solicitadas:
1. Actualización de la caché de **APT** del sistema operativo.
2. Creación del usuario **`itla`** con su directorio *home* y shell `/bin/bash`.
3. Creación del directorio **`/app`** con permisos `0755` y propietario `itla`.
4. Creación del archivo **`/app/hola.txt`** con información personalizada del servidor y fecha.
5. Instalación de los paquetes **`cowsay`** y **`htop`** en cada servidor.
6. Verificación de ejecución con `cowsay`.

---

## 📁 Estructura del Repositorio

```text
practica8-electiva2/
├── .gitignore             # Archivos ignorados por Git
├── ansible.cfg            # Configuración de Ansible (ignora advertencias SSH)
├── Dockerfile             # Imagen de Ubuntu con SSH y usuario ansible sudo
├── docker-compose.yml     # Despliegue de los 5 servidores virtuales
├── inventario.ini         # Inventario con IPs internas de la red Docker (172.20.0.11 - 15)
├── inventario_local.ini   # Inventario alternativo usando puertos mapeados (localhost:2201 - 2205)
├── playbook.yml           # Tareas de automatización para los 5 servidores
└── README.md              # Documentación e instrucciones paso a paso
```

---

## 🚀 Guía de Ejecución Paso a Paso

### Paso 1: Iniciar los 5 Servidores en Docker

Abre una terminal en esta carpeta (`practica8-electiva2`) y ejecuta:

```bash
docker compose up -d --build
```

Comprueba que los 5 contenedores estén arriba y en estado `Up`:

```bash
docker compose ps
```

---

### Paso 2: Preparar Ansible en WSL (Ubuntu)

Si usas Windows, abre tu terminal de **WSL (Ubuntu)** ejecutando `wsl` en PowerShell o abriendo la app "Ubuntu":

1. Actualiza los paquetes e instala Ansible y `sshpass`:
   ```bash
   sudo apt update
   sudo apt install -y ansible sshpass
   ```

2. Navega a la carpeta de este proyecto dentro de WSL:
   ```bash
   cd /mnt/c/Users/loren/OneDrive/Desktop/practica8-electiva2
   ```

---

### Paso 3: Probar Conectividad con Ansible (Ping)

Ejecuta el módulo `ping` de Ansible para verificar la conexión con los 5 servidores:

```bash
ansible servidores -m ping
```

*Nota: Si ejecutas desde WSL directamente a las IPs internas usa `inventario.ini`. Si prefieres conectar mediante los puertos locales (`127.0.0.1:2201-2205`), puedes usar `-i inventario_local.ini`:*
```bash
ansible servidores -i inventario_local.ini -m ping
```

Debes ver una respuesta en color **verde** (`"ping": "pong"`) para cada uno de los 5 servidores (`server1` a `server5`).

---

### Paso 4: Ejecutar el Playbook de Automatización

Aplica todas las tareas en los 5 servidores con el siguiente comando:

```bash
ansible-playbook playbook.yml
```

*(O con inventario local: `ansible-playbook -i inventario_local.ini playbook.yml`)*

Verás cómo Ansible ejecuta de forma concurrente en los 5 servidores:
- Actualización de APT
- Creación del usuario `itla`
- Creación de la carpeta `/app`
- Generación de `/app/hola.txt`
- Instalación de `cowsay` y `htop`
- Prueba con `cowsay`

---

### Paso 5: Comprobar los Resultados en los Contenedores

Puedes entrar a cualquiera de los servidores creados o ejecutar comandos directos con Docker para constatar los cambios:

1. **Verificar el archivo `/app/hola.txt`:**
   ```bash
   docker exec -it server1 cat /app/hola.txt
   ```

2. **Verificar que el usuario `itla` fue creado:**
   ```bash
   docker exec -it server1 id itla
   ```

3. **Verificar la aplicación `cowsay`:**
   ```bash
   docker exec -it server1 cowsay "¡Ansible funcionó perfectamente!"
   ```

4. **Verificar la instalación de `htop`:**
   ```bash
   docker exec -it server1 which htop
   ```

---

### (Alternativa Opcional) Ejecutar Ansible usando Docker sin instalar nada en WSL

Si deseas correr Ansible directamente desde un contenedor que comparte la misma red Docker:

```bash
docker compose --profile tools run --rm ansible-controller ansible-playbook playbook.yml
```

---

## 🛑 Detener el Entorno

Cuando termines tu práctica, puedes detener y eliminar los contenedores ejecutando:

```bash
docker compose down
```

---


