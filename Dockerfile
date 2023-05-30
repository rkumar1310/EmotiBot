# Start with a base image that includes Rust, set up Python and build your wheels
FROM python:3.8-slim as builder

WORKDIR /wheels

# Install Rust and build-essential tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential gcc curl && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    . $HOME/.cargo/env && \
    rustc --version

# Install your requirements and build wheels
COPY requirements.txt .
RUN . $HOME/.cargo/env && pip wheel -r requirements.txt

# Now, start a new stage with a slim base image, and only install your wheels
FROM python:3.8-slim

WORKDIR /app

# Copy only the compiled wheels from the previous stage
COPY --from=builder /wheels /wheels
COPY --from=builder /wheels /root/.cache/pip

# Install packages from pre-compiled wheels
RUN pip install --no-index --find-links=/wheels -r /wheels/requirements.txt

# Copy your application code
COPY app.py ./
COPY model ./model

# Expose the port
EXPOSE 5000

# Set the command
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]

