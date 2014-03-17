package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.JAXPDriver;

/**
 * Created by debbie on 17/03/14.
 */
public class XalanDriver extends JAXPDriver {
    @Override
    public String getFactoryName() {
        return "org.apache.xalan.processor.TransformerFactoryImpl";
    }
}
