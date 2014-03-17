package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.JAXPDriver;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;

/**
 * Created by debbie on 17/03/14.
 */
public class XTDriver extends JAXPDriver {
    @Override
    public String getFactoryName() {
        return "com.jclark.xsl.trax.TransformerFactoryImpl";
    }

    public void fileToFileTransform(File source, File result) throws TransformationException {
        try {
            Transformer transformer = stylesheet.newTransformer();
            resultFile = result;
            transformer.transform(new StreamSource(source), new StreamResult(new FileOutputStream(result)));
        } catch (TransformerException e) {
            throw new TransformationException(e);
        } catch (FileNotFoundException e) {
            throw new TransformationException(e);
        }
    }
}
