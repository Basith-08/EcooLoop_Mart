# Flutter Development Docker Image
FROM ubuntu:22.04

# Avoid timezone prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    cd $FLUTTER_HOME && \
    git checkout stable && \
    flutter precache && \
    flutter config --no-analytics

# Set up Android SDK (optional, for building APKs)
ENV ANDROID_HOME="/opt/android-sdk"
ENV ANDROID_SDK_ROOT="$ANDROID_HOME"
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

ENV ANDROID_CMDLINE_TOOLS=11076708

# Install Android command-line tools and SDK packages
RUN mkdir -p "$ANDROID_HOME/cmdline-tools" && \
    cd /tmp && \
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" && \
    unzip -q "commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" -d "$ANDROID_HOME/cmdline-tools" && \
    mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" && \
    yes | sdkmanager --licenses && \
    yes | sdkmanager --update && \
    yes | sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2" && \
    rm -f "/tmp/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip"

# Create working directory
WORKDIR /app

# Copy project files
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Run flutter doctor to verify setup
RUN flutter doctor

# Expose port for Flutter web (if needed)
EXPOSE 8080

# Default command
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
