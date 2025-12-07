# FROM python:3.12-slim-bookworm

# # Set environment variables to prevent Python from writing .pyc files & Ensure Python output is not buffered
# ENV PYTHONDONTWRITEBYTECODE=1 \
#     PYTHONUNBUFFERED=1

# # Install system dependencies required by TensorFlow

# RUN apt-get update --allow-insecure-repositories \
#  && apt-get install -y --fix-missing \
#     build-essential \
#     libopenblas-dev \
#     liblapack-dev \
#     libhdf5-dev \
#     libprotobuf-dev \
#     protobuf-compiler \
#     python3-dev \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*

# # Set the working directory
# WORKDIR /app

# # Copy the application code
# COPY . .

# # Install dependencies from requirements.txt
# RUN pip install --no-cache-dir -e .

# # Train the model before running the application
# RUN python pipeline/training_pipeline.py

# # Expose the port that Flask will run on
# EXPOSE 5000

# # Command to run the app
# CMD ["python", "application.py"]



# FROM python:3.12-slim-bookworm

# # Prevent Python writing .pyc files, unbuffer output
# ENV PYTHONDONTWRITEBYTECODE=1 \
#     PYTHONUNBUFFERED=1

# # Replace mirrors in the new .sources file
# RUN sed -i 's|http://deb.mirror.kernel.org/debian|http://deb.debian.org/debian|g' /etc/apt/sources.list


# # Clean APT and ensure fresh update
# RUN apt-get update && \
#     apt-get install -y \
#         build-essential \
#         libopenblas-dev \
#         liblapack-dev \
#         libhdf5-dev \
#         libprotobuf-dev \
#         protobuf-compiler \
#         python3-dev \
#     && apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# WORKDIR /app
# COPY . .

# RUN pip install --no-cache-dir -e .

# # If you actually want training inside the image (not recommended)
# RUN python pipeline/training_pipeline.py

# EXPOSE 5000
# CMD ["python", "application.py"]

#######################################

# FROM python:3.12-slim-bookworm
# Use the full Python image (includes pip, etc.)
FROM python:3.12-bookworm

# Set working directory
WORKDIR /app

# Force IPv4 and clean APT caches
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/partial \
    && echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

# Use Debian snapshot mirror to avoid hash mismatches
RUN echo "deb http://snapshot.debian.org/archive/debian/20251201T000000Z bookworm main contrib non-free" > /etc/apt/sources.list \
    && echo "deb http://snapshot.debian.org/archive/debian/20251201T000000Z bookworm-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://snapshot.debian.org/archive/debian-security/20251201T000000Z bookworm-security main contrib non-free" >> /etc/apt/sources.list

# Update and install all required system packages in one go
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        build-essential \
        gfortran \
        libgfortran5 \
        libopenblas-dev \
        liblapack-dev \
        libhdf5-dev \
        libprotobuf-dev \
        protobuf-compiler \
        python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Copy your application code
COPY . .

# Install Python dependencies from your local setup
RUN pip install --no-cache-dir -e .

# Optional: run the training pipeline inside the image (not recommended for production)
# Comment this out if you only want to serve the model
RUN python pipeline/training_pipeline.py

# Expose your app port
EXPOSE 5000

# Command to start your application
CMD ["python", "application.py"]

