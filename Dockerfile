ARG PYTHON_VERSION=3.10.11
FROM python:${PYTHON_VERSION}-slim as base


ENV PYTHONDONTWRITEBYTECODE=1

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-privileged user that the app will run under.
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser


COPY requirements.txt requirements.txt

RUN python -m pip install -r requirements.txt

# Switch to the non-privileged user to run the application.
USER appuser

# Copy the source code into the container.
COPY ./server/ ./server/


# Expose the port that the application listens on.
EXPOSE 8000

# Run the application (--reload for Hot code reloading).
CMD uvicorn 'server.main:app' --host=0.0.0.0 --port=8000 --reload
