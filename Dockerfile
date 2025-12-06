FROM python:3.12-slim

# Set environment variables to prevent Python from writing .pyc files & Ensure Python output is not buffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && mkdir -p /etc/apt/apt.conf.d \
    && echo 'Acquire::http::No-Cache "true";' > /etc/apt/apt.conf.d/no-cache \
    && echo 'Acquire::https::No-Cache "true";' >> /etc/apt/apt.conf.d/no-cache \
    && echo 'Acquire::CompressionTypes::Order "gz";' > /etc/apt/apt.conf.d/compress \
    && echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/retries



# Install system dependencies required by TensorFlow

RUN apt-get update --allow-insecure-repositories \
 && apt-get install -y --fix-missing \
    build-essential \
    libopenblas-dev \
    liblapack-dev \
    libhdf5-dev \
    libprotobuf-dev \
    protobuf-compiler \
    python3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libopenblas-dev \
#     liblapack-dev \
#     libhdf5-dev \
#     libprotobuf-dev \
#     protobuf-compiler \
#     python3-dev \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*


# Set the working directory
WORKDIR /app

# Copy the application code
COPY . .

# Install dependencies from requirements.txt
RUN pip install --no-cache-dir -e .

# Train the model before running the application
RUN python pipeline/training_pipeline.py

# Expose the port that Flask will run on
EXPOSE 5000

# Command to run the app
CMD ["python", "application.py"]


