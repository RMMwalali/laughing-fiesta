FROM php:8.2-cli

# Install system dependencies with error handling
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        zip \
        unzip \
        libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) pdo_mysql mbstring exif pcntl bcmath gd intl zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy only composer files first for better caching
COPY composer.json composer.lock ./

# Debug: Show PHP and Composer versions
RUN php -v && composer --version

# Debug: List files in current directory
RUN ls -la

# Install dependencies with verbose output
RUN composer install --no-interaction --no-dev --prefer-dist -v --no-scripts --no-autoloader

# Copy the rest of the application
COPY . .

# Debug: Show directory structure
RUN ls -la /var/www/

# Generate optimized autoloader
RUN composer dump-autoload --optimize --no-dev

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expose port 8000 for PHP's built-in server
EXPOSE 8000

# Start PHP's built-in server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
