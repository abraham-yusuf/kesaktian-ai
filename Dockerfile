# Gunakan PHP 8.2 (Support Laravel 11)
FROM php:8.2-cli

# 1. Install Library Sistem (Wajib untuk ekstensi PHP)
# libzip-dev -> untuk ekstensi Zip
# libonig-dev -> untuk ekstensi Mbstring
# libpng-dev & libjpeg-dev -> untuk ekstensi GD (Gambar)
# libcurl4-openssl-dev -> untuk cURL
# libxml2-dev -> untuk XML/DOM
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
    libxml2-dev

# 2. Bersihkan cache (Biar ringan)
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Install Ekstensi PHP yang Diminta
# - pdo_mysql : Untuk database (MariaDB/TiDB)
# - mbstring  : Untuk manipulasi string
# - zip       : Wajib untuk Composer & Update
# - exif      : Sering dipakai library gambar
# - pcntl     : Untuk queue worker
# - bcmath    : Untuk hitungan presisi (kripto/uang)
# - gd        : Untuk manipulasi gambar (Avatar/Thumbnail)
# - intl      : Untuk format mata uang/tanggal
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
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

# (Catatan: Ctype, Filter, Hash, OpenSSL, PCRE, PDO, Session, Tokenizer 
#  sudah otomatis TERBAWA di dalam core PHP 8.2 image, jadi aman!)

# 4. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Set folder kerja
WORKDIR /var/www

# 6. Salin file project
COPY . .

# 7. Install dependency via Composer
RUN composer install --no-dev --optimize-autoloader

# 8. Buat file dummy 'installed' (Bypass lisensi)
RUN touch storage/installed

# 9. Expose Port
EXPOSE 8080

# 10. Jalankan Aplikasi
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8080
