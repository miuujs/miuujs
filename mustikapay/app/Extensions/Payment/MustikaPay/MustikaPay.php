<?php

namespace MustikaPay;

use MustikaPay\Exceptions\MustikaPayException;
use MustikaPay\Exceptions\MustikaPayAuthException;
use MustikaPay\Exceptions\MustikaPayValidationException;
use MustikaPay\Exceptions\MustikaPayNetworkException;

class MustikaPay {
    private $apiKey;
    private $baseUrl;
    private $timeout;
    private $userAgent = 'MustikaPay-PHP-SDK/1.1.0';

    public function __construct($apiKey, $baseUrl = "https://mustikapayment.com", $timeout = 30) {
        if (empty($apiKey) || strpos($apiKey, 'MP-') !== 0) {
            throw new MustikaPayValidationException("API Key tidak valid! Format API Key harus dimulai dengan 'MP-'.");
        }

        $this->apiKey = $apiKey;
        $this->baseUrl = rtrim($baseUrl, '/');
        $this->timeout = $timeout;
    }

    private function request($method, $endpoint, $data = null, $params = null, $isJson = false) {
        $url = $this->baseUrl . '/' . ltrim($endpoint, '/');
        if ($params) $url .= '?' . http_build_query($params);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeout);
        curl_setopt($ch, CURLOPT_USERAGENT, $this->userAgent);
        
        $headers = ['X-Api-Key: ' . $this->apiKey];
        if (strtoupper($method) === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            if ($data) {
                if ($isJson) {
                    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
                    $headers[] = 'Content-Type: application/json';
                } else {
                    $cleanData = array_filter($data, function($value) { return $value !== null; });
                    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($cleanData));
                    $headers[] = 'Content-Type: application/x-www-form-urlencoded';
                }
            }
        }
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) throw new MustikaPayNetworkException("Gagal terhubung ke MustikaPay: " . $error);
        return $this->handleResponse($response, $httpCode);
    }

    private function handleResponse($response, $httpCode) {
        $data = json_decode($response, true);
        if (json_last_error() !== JSON_ERROR_NONE) throw new MustikaPayException("Server mengembalikan format non-JSON. Status Code: " . $httpCode, 0, null, $response);
        if ($httpCode == 401 || $httpCode == 403) {
            $msg = isset($data['message']) ? $data['message'] : (isset($data['detail']) ? $data['detail'] : "Unauthorized");
            throw new MustikaPayAuthException($msg, $httpCode, null, $data);
        }
        if ($httpCode == 422) throw new MustikaPayValidationException("Validasi Data Gagal", $httpCode, null, $data);
        if ($httpCode < 200 || $httpCode >= 300) {
            $msg = isset($data['message']) ? $data['message'] : (isset($data['detail']) ? $data['detail'] : "HTTP Error " . $httpCode);
            throw new MustikaPayException($msg, $httpCode, null, $data);
        }
        return $data;
    }

    public function createQRIS($amount, $user = null) { return $this->request('POST', '/api/createpay', ['amount' => $amount, 'user' => $user]); }
    public function createVA($amount, $bankCode, $name, $phone = "08123456789") { return $this->request('POST', '/create/va', ['amount' => $amount, 'bank_code' => $bankCode, 'name' => $name, 'phone' => $phone]); }
    public function getBalance($username) { return $this->request('GET', '/api/saldo', null, ['user' => $username]); }
}
