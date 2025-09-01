FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install dependencies with more memory
RUN composer install --no-interaction --no-dev --prefer-dist

# Set permissions
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Expose port 8000 for PHP's built-in server
EXPOSE 8000

# Start PHP's built-in server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
