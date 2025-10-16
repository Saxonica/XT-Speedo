package com.saxonica.xtspeedo;

/**
 * Exception used to indicate that the transformation has failed
 */
public class TransformationException extends Exception {

    public TransformationException(String message) {
        super(message);
    };

    public TransformationException(Exception error) {
        super(error);
    }
}
