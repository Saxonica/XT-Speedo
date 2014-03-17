package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.JAXPDriver;

/**
 * Created by debbie on 17/03/14.
 */
public class XSLTCDriver extends JAXPDriver {
    @Override
    public String getFactoryName() {
        return "org.apache.xalan.xsltc.trax.TransformerFactoryImpl";
    }
}
