# Hyperion.ng Docker Image
# This Dockerfile builds Hyperion from source and creates a runnable container

# Use Debian Bookworm as base image (supports both amd64 and arm64)
FROM debian:bookworm-slim

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install build dependencies for Hyperion (Qt6 based)
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    ninja-build \
    qt6-base-dev \
    libqt6serialport6-dev \
    libqt6websockets6-dev \
    libxkbcommon-dev \
    libvulkan-dev \
    libgl1-mesa-dev \
    libusb-1.0-0-dev \
    python3-dev \
    libasound2-dev \
    libturbojpeg0-dev \
    libjpeg-dev \
    libssl-dev \
    pkg-config \
    libftdi1-dev \
    libxrandr-dev \
    libxrender-dev \
    libxcb-image0-dev \
    libxcb-util0-dev \
    libxcb-shm0-dev \
    libxcb-render0-dev \
    libxcb-randr0-dev \
    libcec-dev \
    libp8-platform-dev \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy Hyperion source code
COPY . /hyperion

# Build Hyperion (submodules already initialized by workflow)
WORKDIR /hyperion
RUN mkdir build && cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . -- -j$(nproc) && \
    cmake --build . --target install/strip

# Clean up build dependencies to reduce image size
RUN apt-get purge -y \
    git \
    cmake \
    build-essential \
    ninja-build \
    qt6-base-dev \
    libqt6serialport6-dev \
    libqt6websockets6-dev \
    libxkbcommon-dev \
    libvulkan-dev \
    libgl1-mesa-dev \
    libusb-1.0-0-dev \
    python3-dev \
    libasound2-dev \
    libturbojpeg0-dev \
    libjpeg-dev \
    libssl-dev \
    pkg-config \
    libftdi1-dev \
    libxrandr-dev \
    libxrender-dev \
    libxcb-image0-dev \
    libxcb-util0-dev \
    libxcb-shm0-dev \
    libxcb-render0-dev \
    libxcb-randr0-dev \
    libcec-dev \
    libp8-platform-dev \
    libudev-dev \
    && apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /hyperion

# Create a non-root user for running Hyperion
RUN useradd --create-home --shell /bin/bash hyperion

# Switch to non-root user
USER hyperion

# Set working directory
WORKDIR /home/hyperion

# Expose Hyperion's default ports
EXPOSE 8090 8091

# Set the default command to run Hyperion daemon
CMD ["/usr/local/bin/hyperiond"]