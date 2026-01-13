# MySQL Docker Setup

This directory contains a Docker Compose configuration for running MySQL server with all basic setup.

## Prerequisites

- Docker installed on your system
- Docker Compose installed

## Quick Start

1. **Configure environment variables** (already done, but you can modify `.env` file):
   ```bash
   cp .env.example .env
   # Edit .env with your preferred values
   ```

2. **Start MySQL server**:
   ```bash
   docker compose up -d
   ```

3. **Check if MySQL is running**:
   ```bash
   docker compose ps
   ```

4. **View logs**:
   ```bash
   docker compose logs -f mysql
   ```

## Configuration

### Environment Variables

The following environment variables are configured in `.env`:

- `MYSQL_ROOT_PASSWORD`: Password for the root user (required)
- `MYSQL_DATABASE`: Name of the database to create on startup
- `MYSQL_USER`: Application user to create
- `MYSQL_PASSWORD`: Password for the application user

### Ports

- MySQL is exposed on port `3306` (host:container)

### Volumes

- `mysql_data`: Persistent storage for MySQL data
- `./mysql-config`: Optional directory for custom MySQL configuration files (*.cnf)
- `./init-scripts`: Optional directory for initialization scripts (*.sql, *.sh)

## Connecting to MySQL

### From Host Machine

```bash
mysql -h 127.0.0.1 -P 3306 -u dev_user -p
# Enter password: DevUserPass123!
```

Or using Docker:

```bash
docker compose exec mysql mysql -u dev_user -p
```

### From Application (Connection String)

```
Host: localhost (or mysql if within the same Docker network)
Port: 3306
Database: learning_db
Username: dev_user
Password: DevUserPass123!
```

Connection string example:
```
mysql://dev_user:DevUserPass123!@localhost:3306/learning_db
```

## Useful Commands

### Start services
```bash
docker compose up -d
```

### Stop services
```bash
docker compose down
```

### Stop and remove volumes (⚠️ deletes all data)
```bash
docker compose down -v
```

### Execute MySQL commands
```bash
docker compose exec mysql mysql -u root -p
```

### Create a database backup
```bash
docker compose exec mysql mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" --all-databases > backup.sql
```

### Restore from backup
```bash
docker compose exec -T mysql mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < backup.sql
```

### Access MySQL container shell
```bash
docker compose exec mysql bash
```

### View real-time logs
```bash
docker compose logs -f mysql
```

## Custom Configuration

### Add MySQL Configuration Files

Create custom configuration files in `./mysql-config/` directory:

```bash
mkdir -p mysql-config
```

Example `./mysql-config/custom.cnf`:
```ini
[mysqld]
max_connections = 200
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
```

### Add Initialization Scripts

Place SQL or shell scripts in `./init-scripts/` directory to run on first startup:

```bash
mkdir -p init-scripts
```

Example `./init-scripts/01-init.sql`:
```sql
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Scripts are executed in alphabetical order.

## Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs mysql

# Remove and recreate
docker compose down -v
docker compose up -d
```

### Connection refused
- Wait for MySQL to fully initialize (check with `docker compose logs -f mysql`)
- Verify MySQL is running: `docker compose ps`
- Check port 3306 is not already in use: `lsof -i :3306`

### Reset everything
```bash
docker compose down -v
docker volume rm sql_mysql_data
docker compose up -d
```

## Security Notes

⚠️ **Important**: 
- Never commit `.env` file with real passwords to version control
- Change default passwords in production
- Use strong passwords for production environments
- Consider using Docker secrets for production deployments

## Health Check

The MySQL service includes a health check that:
- Runs every 10 seconds
- Times out after 5 seconds
- Retries up to 5 times
- Waits 30 seconds before starting checks

Check health status:
```bash
docker compose ps
```

## Additional Resources

- [MySQL Docker Hub Documentation](https://hub.docker.com/_/mysql)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
