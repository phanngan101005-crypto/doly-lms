# Sử dụng phiên bản PHP 8.2 với Apache
FROM php:8.2-apache

# 1. Cài đặt các extension PHP cần thiết cho Doly LMS
RUN docker-php-ext-install pdo pdo_mysql

# 2. Bật module rewrite của Apache (cực kỳ quan trọng nếu bạn dùng file .htaccess)
RUN a2enmod rewrite

# 3. Copy toàn bộ mã nguồn vào thư mục gốc của Apache
COPY . /var/www/html/

# 4. Phân quyền sở hữu thư mục cho user 'www-data' (user chạy Apache)
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# 5. Cấu hình Port linh hoạt cho Render:
# Sử dụng biến môi trường ${PORT} do Render cung cấp. 
# Nếu không có (chạy local), mặc định sẽ dùng port 80.
RUN sed -i 's/80/${PORT:-80}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

# 6. Thiết lập môi trường làm việc và cổng lắng nghe
WORKDIR /var/www/html
EXPOSE ${PORT:-80}

# 7. Khởi động Apache
CMD ["apache2-foreground"]