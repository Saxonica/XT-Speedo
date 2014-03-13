package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.saxonhe.SaxonHEDriver;
import com.saxonica.xtspeedo.xalan.XalanDriver;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Pattern;


/**
 * Run the XT-Speedo benchmark
 */
public class Speedo {

    public static final int MAX_ITERATIONS = 1;
    public static final long MAX_TOTAL_TIME = 20L*1000L*1000L*1000L;
    private XMLOutputFactory xmlOutputFactory;

    List<IDriver> drivers = new ArrayList<IDriver>();

    public static void main(String[] args) {
        HashMap<String, String> map = new HashMap<String, String>(16);
        for (String pair : args) {
            int colon = pair.indexOf(':');
            String key = pair.substring(0, colon);
            String value = pair.substring(colon+1);
            map.put(key, value);
        }
        String catalog = map.get("-cat");
        if (catalog == null) {
            catalog = "catalog.xml";
        }
        String testPattern = map.get("-t");
        if (testPattern == null) {
            testPattern = ".*";
        }
        new Speedo().run(new File(catalog), new File(map.get("-out")), testPattern);
    }

    public void run(File catalogFile, File outputDirectory, String testPattern) {
        drivers.add(new SaxonHEDriver());
        drivers.add(new XalanDriver());
        SAXBuilder builder = new SAXBuilder();
        Document doc = null;

        Pattern testPat = Pattern.compile(testPattern);

        try {
            doc = builder.build(catalogFile);
        } catch (JDOMException e) {
            e.printStackTrace();
            return;
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }
        URI catalogURI = catalogFile.toURI();
        Element catalogElement = doc.getRootElement();
        for (IDriver driver : drivers) {
            try {
                xmlOutputFactory = XMLOutputFactory.newFactory();
                File outputDir = new File(outputDirectory, "output");
                File driverOutputDir = new File(outputDir, driver.getClass().getSimpleName());
                driverOutputDir.mkdir();
                File outputFile = new File(outputDirectory, driver.getClass().getSimpleName() + ".xml");
                XMLStreamWriter xmlStreamWriter = xmlOutputFactory.createXMLStreamWriter(new FileOutputStream(outputFile));
                xmlStreamWriter.writeStartDocument();
                xmlStreamWriter.writeStartElement("testResults");
                xmlStreamWriter.writeAttribute("driver", driver.getClass().getSimpleName());
                GregorianCalendar todaysDate = new GregorianCalendar();
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                System.err.println("Date " + dateFormat.format(todaysDate.getTime()));
                xmlStreamWriter.writeAttribute("on", "" + dateFormat.format(todaysDate.getTime()));
                System.err.println("Driver implemented: " + driver.getClass().getSimpleName());
                for (Element testCase : catalogElement.getChildren("test-case")) {
                    String name = testCase.getAttributeValue("name");
                    if (!testPat.matcher(name).matches()) {
                        continue;
                    }
                    System.err.println("Running " + name);
                    String attributeValue = testCase.getAttributeValue("xslt-version");
                    double xsltVersion = (attributeValue == null) ? 1.0 : Double.parseDouble(attributeValue);
                    String source = testCase.getChild("test").getChild("source").getAttributeValue("file");
                    URI sourceURI = catalogURI.resolve(source);
                    String stylesheet = testCase.getChild("test").getChild("stylesheet").getAttributeValue("file");
                    URI stylesheetURI = catalogURI.resolve(stylesheet);
                        if (xsltVersion <= driver.getXsltVersion()) {
                            try {
                                long totalBuildSource = 0;
                                int i;
                                for (i = 0; i < MAX_ITERATIONS && totalBuildSource < MAX_TOTAL_TIME; i++) {
                                    long start = System.nanoTime();
                                    driver.buildSource(sourceURI);
                                    totalBuildSource += System.nanoTime() - start;
                                }
                                double buildTime = totalBuildSource/(1000000.0*i);
                                System.err.println("Average time for source parse: " + buildTime +
                                        "ms. Number of iterations: " + i);
                                long totalCompileStylesheet = 0;
                                for (i = 0; i < MAX_ITERATIONS && totalCompileStylesheet < MAX_TOTAL_TIME; i++) {
                                    long start = System.nanoTime();
                                    driver.compileStylesheet(stylesheetURI);
                                    totalCompileStylesheet += System.nanoTime() - start;
                                }
                                double compileTime = totalCompileStylesheet/(1000000.0*i);
                                System.err.println("Average time for stylesheet compile: " + compileTime +
                                        "ms. Number of iterations: " + i);
                                long totalTransform = 0;
                                for (i = 0; i < MAX_ITERATIONS && totalTransform < MAX_TOTAL_TIME; i++) {
                                    long start = System.nanoTime();
                                    //driver.treeToTreeTransform();
                                    driver.fileToFileTransform(new File(sourceURI), new File(driverOutputDir, name + ".xml"));
                                    totalTransform += System.nanoTime() - start;
                                }
                                double transformTime = totalTransform/(1000000.0*i);
                                System.err.println("Average time for fileToFileTransform: " + transformTime +
                                        "ms. Number of iterations: " + i);
                                boolean ok = true;
                                for (Element assertion : testCase.getChild("result").getChildren("assert")) {
                                    String xpath = assertion.getText();
                                    ok &= driver.testAssertion(xpath);
                                }
                                System.err.println("Test run succeeded with " + driver.getClass().getSimpleName());
                                xmlStreamWriter.writeEmptyElement("test");
                                xmlStreamWriter.writeAttribute("name", name);
                                xmlStreamWriter.writeAttribute("run", (ok ? "success" : "wrongAnswer"));
                                xmlStreamWriter.writeAttribute("buildTime", "" + buildTime);
                                xmlStreamWriter.writeAttribute("compileTime", "" + compileTime);
                                xmlStreamWriter.writeAttribute("transformTime", "" + transformTime);
                            } catch (TransformationException e) {

                                driver.displayResultDocument();
                                System.err.println("Test run failed: " + e.getMessage());
                                xmlStreamWriter.writeEmptyElement("test");
                                xmlStreamWriter.writeAttribute("name", name);
                                xmlStreamWriter.writeAttribute("run", "failure");
                            }
                        }
                }
                xmlStreamWriter.writeEndElement();
                xmlStreamWriter.writeEndDocument();
            } catch (XMLStreamException e) {
                e.printStackTrace();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
        }

    }
}
