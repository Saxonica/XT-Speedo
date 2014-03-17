package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.JAXPDriver;

/**
 * Created by debbie on 17/03/14.
 */
public class Saxon6Driver extends JAXPDriver {
    @Override
    public String getFactoryName() {
        return "com.icl.saxon.TransformerFactoryImpl";
    }
}
