# Local Development

This guide runs the project locally with Docker Compose.

## Quick Start

Copy the environment file:

```bash
cp .env.example .env
```

Start local dependencies and services:

```bash
docker compose up -d
```

Open the local gateway:

```text
http://localhost:8081
```

For database migration details, see:

```text
database/README.md
```

## Local Ports

```text
Gateway: http://localhost:8081
PostgreSQL: localhost:5433
Redis: localhost:6380
RabbitMQ: localhost:5673
RabbitMQ UI: http://localhost:15673
```
