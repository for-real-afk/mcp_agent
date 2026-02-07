# 1. Use an official Python runtime as a parent image
# We use 'slim' to keep the image size small.
FROM python:3.11-slim

# 2. Set the working directory in the container
# This is like doing 'cd /app' inside the container.
WORKDIR /app

# 3. Install system dependencies if needed (e.g., git, curl)
# Some Python packages might need build tools.
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy the requirements file into the container
# We copy this first to leverage Docker's cache.
# This way, if you change your code but not your requirements, 
# Docker won't re-install everything.
COPY requirements.txt .
COPY server/requirements.txt ./server/requirements.txt

# 5. Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r server/requirements.txt

# 6. Copy the rest of your application's code
# This copies everything from your local directory into /app in the container.
COPY . .

# 7. Expose the port the app runs on
# This tells Docker which port the application is listening on.
EXPOSE 8000

# 8. Define the command to run your app
# uvicorn starts the FastAPI server.
# --host 0.0.0.0 makes it accessible from outside the container.
CMD ["uvicorn", "agents:app", "--host", "0.0.0.0", "--port", "8000"]
