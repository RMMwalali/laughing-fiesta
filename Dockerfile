# Build stage
FROM composer:2.6 as vendor
WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install dependencies without scripts
RUN composer install --no-scripts --no-autoloader --no-interaction --no-dev --prefer-dist

# Copy application files
COPY . .

# Dump autoloader
RUN composer dump-autoload --optimize --no-dev

# Application stage
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www

# Copy application files from vendor stage
COPY --from=vendor /app /var/www

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expose port 9000
EXPOSE 9000

# Start php-fpm
CMD ["php-fpm"]
