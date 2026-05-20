FROM php:8.2-apache
# Copy toàn bộ file trong thư mục hiện tại vào thư mục web của apache
COPY . /var/www/html/
# Cấu hình để apache chạy đúng port mà Render yêu cầu
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
EXPOSE ${PORT}