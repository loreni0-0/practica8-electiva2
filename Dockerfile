# Imagen base oficial de Ubuntu 22.04 LTS
FROM ubuntu:22.04

# Evitar diálogos interactivos durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instalar OpenSSH Server, sudo, python3 y paquetes necesarios para Ansible
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    python3 \
    python3-apt \
    iproute2 \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de ejecución requerido por sshd
RUN mkdir -p /var/run/sshd

# Crear el usuario 'ansible' con contraseña 'ansible'
RUN useradd -m -s /bin/bash ansible && \
    echo "ansible:ansible" | chpasswd

# Otorgar privilegios sudo sin contraseña al usuario 'ansible'
RUN echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible

# Configurar SSH para permitir autenticación por contraseña
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Exponer el puerto SSH estándar
EXPOSE 22

# Iniciar el servicio SSH en primer plano
CMD ["/usr/sbin/sshd", "-D"]
