package com.saxonica.xtspeedo;

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
import java.util.ArrayList;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Pattern;


/**
 * Run the XT-Speedo benchmark
 */
public class Speedo {

    public static final int MIN_ITERATIONS = 5;
    public static final long MAX_TOTAL_TIME = 1L*1000L*1000L*1000L;
    private XMLOutputFactory xmlOutputFactory;

    private List<IDriver> drivers = new ArrayList<IDriver>();
    private IDriver baseline = null;
    private boolean skipXslt3Tests = false;

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
        String testSkip = map.get("-skip");
        String runXslt3Tests = map.get("-v3");

        new Speedo().run(new File(catalog), new File(driverfile), new File(map.get("-out")), testPattern, testSkip, runXslt3Tests);
    }

    public void run(File catalogFile, File driverFile, File outputDirectory, String testPattern, String testSkip, String runXslt3Tests) throws Exception {

        SAXBuilder builder = new SAXBuilder();
        buildDriverList(driverFile, builder);
        Document doc = null;

        Pattern testPat = Pattern.compile(testPattern);
        skipXslt3Tests = "no".equals(runXslt3Tests);

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
                    if ("no".equals(driver.getTestRunOption(name))){
                        continue;
                    }
                    if ((testSkip != null) && (driver.getTestRunOption(name) != null) &&
                            Integer.parseInt(driver.getTestRunOption(name)) >= Integer.parseInt(testSkip)){
                        continue;
                    }
                    String attributeValue = testCase.getAttributeValue("xslt-version");
                    double xsltVersion = (attributeValue == null) ? 1.0 : Double.parseDouble(attributeValue);
                    if (3.0 == xsltVersion && skipXslt3Tests){
                        continue;
                    }
                    System.err.println("Running " + name);
                    final Element schemaElement = testCase.getChild("test").getChild("schema");
                    String schema = schemaElement == null ? null : schemaElement.getAttributeValue("file");
                    URI schemaURI = schema == null ? null : catalogURI.resolve(schema);
                    String source = testCase.getChild("test").getChild("source").getAttributeValue("file");
                    URI sourceURI = catalogURI.resolve(source);
                    String stylesheet = testCase.getChild("test").getChild("stylesheet").getAttributeValue("file");
                    URI stylesheetURI = catalogURI.resolve(stylesheet);
                        if (xsltVersion <= driver.getXsltVersion()) {
                            try {
                                if (schemaURI != null) {
                                    driver.loadSchema(schemaURI);
                                }
                                driver.buildSource(sourceURI);
                                int i;
                                long totalCompileStylesheet = 0;
                                for (i = 0; totalCompileStylesheet < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++) {
                                    long start = System.nanoTime();
                                    driver.compileStylesheet(stylesheetURI);
                                    totalCompileStylesheet += System.nanoTime() - start;
                                }
                                totalCompileStylesheet = 0;
                                System.gc();
                                for (i = 0; totalCompileStylesheet < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++) {
                                    long start = System.nanoTime();
                                    driver.compileStylesheet(stylesheetURI);
                                    totalCompileStylesheet += System.nanoTime() - start;
                                }
                                double compileTime = totalCompileStylesheet/(1000000.0*i);
                                System.err.println("Average time for stylesheet compile: " + compileTime +
                                        "ms. Number of iterations: " + i);
                                long totalTransformFileToFile = 0;
                                for (i = 0; totalTransformFileToFile < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++) {
                                    long start = System.nanoTime();
                                    driver.fileToFileTransform(new File(sourceURI), new File(driverOutputDir, name + ".xml"));
                                    totalTransformFileToFile += System.nanoTime() - start;
                                }
                                totalTransformFileToFile = 0;
                                System.gc();
                                for (i = 0; totalTransformFileToFile < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++) {
                                    long start = System.nanoTime();
                                    driver.fileToFileTransform(new File(sourceURI), new File(driverOutputDir, name + ".xml"));
                                    totalTransformFileToFile += System.nanoTime() - start;
                                }
                                double transformTimeFileToFile = totalTransformFileToFile/(1000000.0*i);
                                System.err.println("Average time for fileToFileTransform: " + transformTimeFileToFile +
                                        "ms. Number of iterations: " + i);
                                double transformTimeTreeToTree;
                                try {
                                    long totalTransformTreeToTree = 0;
                                    for (i = 0; totalTransformTreeToTree < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++) {
                                        long start = System.nanoTime();
                                        driver.treeToTreeTransform();
                                        totalTransformTreeToTree += System.nanoTime() - start;
                                    }
                                    totalTransformTreeToTree = 0;
                                    System.gc();
                                    for (i = 0; totalTransformTreeToTree < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++) {
                                        long start = System.nanoTime();
                                        driver.treeToTreeTransform();
                                        totalTransformTreeToTree += System.nanoTime() - start;
                                    }
                                    transformTimeTreeToTree = totalTransformTreeToTree/(1000000.0*i);
                                    System.err.println("Average time for treeToTreeTransform: " + transformTimeTreeToTree +
                                            "ms. Number of iterations: " + i);
                                } catch (UnsupportedOperationException e) {
                                    transformTimeTreeToTree = Double.NaN;
                                }
                                boolean ok = true;
                                for (Element assertion : testCase.getChild("result").getChildren("assert")) {
                                    String xpath = assertion.getText();
                                    ok &= driver.testAssertion(xpath);
                                }
                                System.err.println("Test run succeeded with " + driver.getName());
                                xmlStreamWriter.writeEmptyElement("test");
                                xmlStreamWriter.writeAttribute("name", name);
                                xmlStreamWriter.writeAttribute("run", (ok ? "success" : "wrongAnswer"));
                                xmlStreamWriter.writeAttribute("compileTime", "" + compileTime);
                                xmlStreamWriter.writeAttribute("transformTimeFileToFile", "" + transformTimeFileToFile);
                                xmlStreamWriter.writeAttribute("transformTimeTreeToTree", "" + transformTimeTreeToTree);
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
                xmlStreamWriter.close();
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
        for (Element driverElement : driversElement.getChildren("driver")) {
            IDriver driver;
            String languageAttribute = driverElement.getAttributeValue("language");
            if ("java".equals(languageAttribute)) {
                String className = driverElement.getAttributeValue("class");
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
                driver.setName(driverElement.getAttributeValue("name"));
                String baselineAttribute = driverElement.getAttributeValue("baseline");
                if ("yes".equals(baselineAttribute)){
                    baseline = driver;
                }
                for (Element optionElement : driverElement.getChildren("option")) {
                    String optName = optionElement.getAttributeValue("name");
                    String optValue = optionElement.getAttributeValue("value");
                    driver.setOption(optName, optValue);
                }
                for (Element testOptionElement : driverElement.getChildren("test-run-option")) {
                    String testName = testOptionElement.getAttributeValue("name");
                    String testValue = testOptionElement.getAttributeValue("value");
                    driver.setTestRunOption(testName, testValue);
                }
            }
        }
    }
}
