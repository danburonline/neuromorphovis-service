FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Update package lists and install xz-utils
RUN apt-get update && apt-get install -y \
    wget \
    libxi6 \
    libgl1 \
    libsm6 \
    xz-utils \
    libxfixes3 \
    libxrender1 \
    libdbus-1-3 \
    libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*