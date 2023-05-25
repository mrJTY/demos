package com.example.contacts_service.exception;


// Use a runtime exception to make use of application exception handler
// Exceptions are not caught at compile time but Spring is smart enough to handle it
public class NoContactException extends RuntimeException {
    public NoContactException(String message) {
        super(message);
    }
}
