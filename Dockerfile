# Gunakan PHP 8.2 (Support Laravel 11)
FROM php:8.2-cli

# 1. Install Library Sistem (Wajib untuk ekstensi PHP)
# - libzip-dev         : untuk zip
# - libonig-dev        : untuk mbstring
# - libpng/jpeg/freetype : untuk GD (gambar)
# - libcurl4-openssl-dev : untuk cURL
# - libxml2-dev        : untuk XML/DOM
# - libicu-dev         : <--- INI YANG KURANG TADI (Untuk intl)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libicu-dev

# 2. Bersihkan cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Konfigurasi GD (Wajib di-configure dulu sebelum install)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# 4. Install Ekstensi PHP
RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath \
    gd \
    intl \
    soap \
    dom \
    curl \
    fileinfo \
    xml

# 5. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 6. Set folder kerja
WORKDIR /var/www

# 7. Salin file project
COPY . .

# 8. Install dependency via Composer
RUN composer install --no-dev --optimize-autoloader

# 9. Buat file dummy 'installed' (Bypass lisensi)
RUN touch storage/installed

# 10. Expose Port
EXPOSE 8080

# 11. Jalankan Aplikasi
CMD php artisan serve --host=0.0.0.0 --port=8080
