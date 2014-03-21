package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.saxonhe.SaxonHEDriver;
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

    public static final int MAX_ITERATIONS = 20;
    public static final long MAX_TOTAL_TIME = 20L*1000L*1000L*1000L;
    private XMLOutputFactory xmlOutputFactory;

    private List<IDriver> drivers = new ArrayList<IDriver>();
    private IDriver baseline = null;

    public static void main(String[] args) throws Exception {
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
        String driverfile = map.get("-dr");
        if (driverfile == null) {
            driverfile = "drivers.xml";
        }
        String testPattern = map.get("-t");
        if (testPattern == null) {
            testPattern = ".*";
        }
        new Speedo().run(new File(catalog), new File(driverfile), new File(map.get("-out")), testPattern);
    }

    public void run(File catalogFile, File driverFile, File outputDirectory, String testPattern) throws Exception {

        SAXBuilder builder = new SAXBuilder();
        buildDriverList(driverFile, builder);
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
                File driverOutputDir = new File(outputDir, driver.getName());
                driverOutputDir.mkdir();
                File outputFile = new File(outputDirectory, driver.getName() + ".xml");
                XMLStreamWriter xmlStreamWriter = xmlOutputFactory.createXMLStreamWriter(new FileOutputStream(outputFile));
                xmlStreamWriter.writeStartDocument();
                xmlStreamWriter.writeStartElement("testResults");
                xmlStreamWriter.writeAttribute("driver", driver.getName());
                GregorianCalendar todaysDate = new GregorianCalendar();
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                System.err.println("Date " + dateFormat.format(todaysDate.getTime()));
                xmlStreamWriter.writeAttribute("on", "" + dateFormat.format(todaysDate.getTime()));
                xmlStreamWriter.writeAttribute("baseline", (driver==baseline? "yes" :"no"));
                System.err.println("Driver implemented: " + driver.getName());
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
                                System.err.println("Test run succeeded with " + driver.getName());
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
    private void buildDriverList(File driverFile, SAXBuilder builder) throws Exception{
        Document doc;
        try {
            doc = builder.build(driverFile);
        } catch (JDOMException e) {
            e.printStackTrace();
            return;
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }

        Element driversElement = doc.getRootElement();
        for (Element testCase : driversElement.getChildren("driver")) {
            IDriver driver;
            String className = testCase.getAttributeValue("class");
            try {
                Class theClass = Class.forName(className);
                driver = (IDriver)theClass.newInstance();
                drivers.add(driver);
            } catch (ClassNotFoundException e) {
                System.err.println("Failed to load" + className);
                throw e;
            } catch (InstantiationException e) {
                System.err.println("Failed to load" + className);
                throw e;
            } catch (IllegalAccessException e) {
                System.err.println("Failed to load" + className);
                throw e;
            }
            driver.setName(testCase.getAttributeValue("name"));
            String baselineAttribute = testCase.getAttributeValue("baseline");
            if ("yes".equals(baselineAttribute)){
                baseline = driver;
            }
        }
    }
}
