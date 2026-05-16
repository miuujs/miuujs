<?php
namespace MustikaPay\Exceptions;
use Exception;
class MustikaPayException extends Exception {
    private $rawResponse;
    public function __construct($message, $code = 0, Exception $previous = null, $rawResponse = null) {
        parent::__construct($message, $code, $previous);
        $this->rawResponse = $rawResponse;
    }
    public function getRawResponse() { return $this->rawResponse; }
}
