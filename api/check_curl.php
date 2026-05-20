<?php
$ch = curl_init("https://google.com");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
$response = curl_exec($ch);
$error = curl_error($ch);
curl_close($ch);

if ($response) {
    echo "Kết nối ra ngoài THÀNH CÔNG!";
} else {
    echo "Kết nối ra ngoài BỊ CHẶN. Lỗi: " . $error;
}
?>