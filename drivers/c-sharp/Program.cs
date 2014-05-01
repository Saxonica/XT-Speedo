﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections;
using System.IO;
using System.Text.RegularExpressions;
using System.Xml;

namespace Speedo
{
    class RunSpeedo
    {
        public static int MAX_ITERATIONS = 20;
        public static long MAX_TOTAL_TIME = 20L * 1000L * 1000L * 1000L;

        private List<IDriver> drivers = new List<IDriver>();
        private IDriver baseline = null;
        private Boolean skipSlowTests = false;
        private Boolean skipXslt3Tests = false;
        static void Main(string[] args)
        {
            Hashtable map = new Hashtable(16);
            foreach (String pair in args)
            {
                int colon = pair.IndexOf(':');
                String key = pair.Substring(0, colon);
                String value = pair.Substring(colon + 1);
                map.Add(key, value);
            }
            DirectoryInfo currentDirectory = new DirectoryInfo(".");
            String catalog = (String)map["-cat"];
            if (catalog == null)
            {
                catalog = "catalog.xml";
            }
            catalog = currentDirectory.FullName + "/" + catalog;
            String driverfile = (String)map["-dr"];
            if (driverfile == null)
            {
                driverfile = "drivers.xml";
            }
            driverfile = currentDirectory.FullName + "/" + driverfile;
            String outputDir = (String)map["-out"];
            if (outputDir == null)
            {
                outputDir = "results";
            }
            outputDir = currentDirectory.FullName + "/" + outputDir;
            String testPattern = (String)map["-t"];
            if (testPattern == null)
            {
                testPattern = ".*";
            }            
            String testSkip = (String)map["-skip"];                         
            String runXslt3Tests = (String)map["-v3"];
            new RunSpeedo().run(catalog, driverfile, outputDir, testPattern, testSkip, runXslt3Tests);
        }




        public void run(String catalogFile, String driverFile, String outputDirectory, String testPattern, String testSkip, String runXslt3Tests)
        {
            buildDriverList(driverFile);
            XmlReader reader = XmlReader.Create(catalogFile);
            XmlDocument doc = new XmlDocument();
            doc.Load(reader);

            Regex testPat = new Regex(testPattern);
            skipSlowTests = ("slow" == testSkip);
            skipXslt3Tests = ("no" == runXslt3Tests);

            System.Uri catalogUri = new System.Uri(catalogFile);

            XmlElement catalogElement = (XmlElement)doc.SelectSingleNode("*");
            foreach (IDriver driver in drivers)
            {
                String outputDir = System.IO.Path.Combine(outputDirectory, "output");
                String driverOutputDir = System.IO.Path.Combine(outputDir, driver.GetName());
                System.IO.Directory.CreateDirectory(driverOutputDir);
                String outputFile = System.IO.Path.Combine(outputDirectory, driver.GetName() + ".xml");                
                XmlWriter xmlStreamWriter = XmlWriter.Create(outputFile);
                xmlStreamWriter.WriteStartDocument();
                xmlStreamWriter.WriteStartElement("testResults");
                xmlStreamWriter.WriteAttributeString("driver", driver.GetName());

                DateTime now = DateTime.Now;
                Console.WriteLine("Date " + now);
                xmlStreamWriter.WriteAttributeString("on", "" + now.ToString("s"));
                xmlStreamWriter.WriteAttributeString("baseline", (driver == baseline ? "yes" : "no"));
                Console.WriteLine("Driver implemented: " + driver.GetName());
                System.Diagnostics.Stopwatch stopwatch = System.Diagnostics.Stopwatch.StartNew();
                foreach (XmlElement testCase in catalogElement.SelectNodes("test-case"))
                {
                    String name = testCase.GetAttribute("name");
                    Match match = testPat.Match(name);
                    if (!match.Success)
                    {
                        continue;
                    }
                    if ("no" == driver.GetTestRunOption(name))
                    {
                        continue;
                    }
                    if ("slow" == driver.GetTestRunOption(name) && skipSlowTests)
                    {
                        continue;
                    }
                    String attributeValue = testCase.GetAttribute("xslt-version");
                    double xsltVersion = (attributeValue == "") ? 1.0 : Convert.ToDouble(attributeValue);
                    if (3.0 == xsltVersion && skipXslt3Tests)
                    {
                        continue;
                    }
                    Console.WriteLine("Running " + name);                    

                    String source = ((XmlElement)testCase.SelectSingleNode("test/source")).GetAttribute("file");
                    Uri sourceUri = new Uri(catalogUri, source);
                    String stylesheet = ((XmlElement)testCase.SelectSingleNode("test/stylesheet")).GetAttribute("file");
                    Uri stylesheetUri = new Uri(catalogUri, stylesheet);
                    if (xsltVersion <= driver.GetXsltVersion())
                    {
                        try
                        {
                            driver.BuildSource(sourceUri);                            
                            int i;                          
                            double totalCompileStylesheet = 0;
                            for (i = 0; i < MAX_ITERATIONS && totalCompileStylesheet < MAX_TOTAL_TIME; i++)
                            {
                                double start = stopwatch.ElapsedMilliseconds;
                                driver.CompileStylesheet(stylesheetUri);
                                totalCompileStylesheet += stopwatch.ElapsedMilliseconds - start;
                            }
                            double compileTime = totalCompileStylesheet / i;
                            Console.WriteLine("Average time for stylesheet compile: " + compileTime +
                                    "ms. Number of iterations: " + i);
                            double totalTransformFileToFile = 0;
                            for (i = 0; i < MAX_ITERATIONS && totalTransformFileToFile < MAX_TOTAL_TIME; i++)
                            {
                                double start = stopwatch.ElapsedMilliseconds;
                                driver.FileToFileTransform(sourceUri, driverOutputDir + "/" + name + ".xml");
                                totalTransformFileToFile += stopwatch.ElapsedMilliseconds - start;
                            }
                            double transformTimeFileToFile = totalTransformFileToFile / i;
                            Console.WriteLine("Average time for FileToFileTransform: " + transformTimeFileToFile +
                                    "ms. Number of iterations: " + i);
                            double totalTransformTreeToTree = 0;
                            for (i = 0; i < MAX_ITERATIONS && totalTransformTreeToTree < MAX_TOTAL_TIME; i++)
                            {
                                double start = stopwatch.ElapsedMilliseconds;                                
                                driver.TreeToTreeTransform();
                                totalTransformTreeToTree += stopwatch.ElapsedMilliseconds - start;
                            }
                            double transformTimeTreeToTree = totalTransformTreeToTree / i;
                            Console.WriteLine("Average time for TreeToTreeTransform: " + transformTimeTreeToTree +
                                    "ms. Number of iterations: " + i);
                            bool ok = true;
                            foreach (XmlElement assertion in testCase.SelectNodes("result/assert"))
                            {
                                String xpath = assertion.InnerText;
                                ok &= driver.TestAssertion(xpath);
                            }
                            Console.WriteLine("Test run succeeded with " + driver.GetName());
                            xmlStreamWriter.WriteStartElement("test");
                            xmlStreamWriter.WriteAttributeString("name", name);
                            xmlStreamWriter.WriteAttributeString("run", (ok ? "success" : "wrongAnswer"));
                            xmlStreamWriter.WriteAttributeString("compileTime", "" + compileTime);
                            xmlStreamWriter.WriteAttributeString("transformTimeFileToFile", "" + transformTimeFileToFile);
                            xmlStreamWriter.WriteAttributeString("transformTimeTreeToTree", "" + transformTimeTreeToTree);
                            xmlStreamWriter.WriteEndElement();
                        }
                        catch (Exception e)
                        {
                            driver.DisplayResultDocument();
                            Console.WriteLine("Test run failed: " + e.Message);
                            xmlStreamWriter.WriteStartElement("test");
                            xmlStreamWriter.WriteAttributeString("name", name);
                            xmlStreamWriter.WriteAttributeString("run", "failure");
                            xmlStreamWriter.WriteEndElement();
                        }
                    }
                }
                xmlStreamWriter.WriteEndElement();
                xmlStreamWriter.WriteEndDocument();
                xmlStreamWriter.Close();

            }
        }
        private void buildDriverList(String driverFile)
        {
            XmlReader reader = XmlReader.Create(driverFile);
            XmlDocument doc = new XmlDocument();
            doc.Load(reader);

            XmlElement driversElement = (XmlElement)doc.SelectSingleNode("*");
            foreach (XmlElement driverElement in driversElement.SelectNodes("driver"))
            {
                IDriver driver;
                String languageAttribute = driverElement.GetAttribute("language");
                if ("c-sharp" == languageAttribute)
                {
                    String className = driverElement.GetAttribute("class");
                    Type type = Type.GetType(className);
                    driver = (IDriver)Activator.CreateInstance(type);             
                    drivers.Add(driver);

                    driver.SetName(driverElement.GetAttribute("name"));
                    String baselineAttribute = driverElement.GetAttribute("baseline");
                    if ("yes" == baselineAttribute)
                    {
                        baseline = driver;
                    }
                    foreach (XmlElement optionElement in driverElement.SelectNodes("option")) 
                    {
                        String optName = optionElement.GetAttribute("name");
                        String optValue = optionElement.GetAttribute("value");
                        driver.SetOption(optName, optValue);
                    }
                    foreach (XmlElement testOptionElement in driverElement.SelectNodes("test-run-option"))
                    {
                        String testName = testOptionElement.GetAttribute("name");
                        String testValue = testOptionElement.GetAttribute("value");
                        driver.SetTestRunOption(testName, testValue);
                    }
                }
            }
        }
    }



    public abstract class IDriver
    {
        private String driverName;
        private Hashtable options = new Hashtable();
        private Hashtable testOptions = new Hashtable();

        /**
         * Parse a source file and build a tree representation of the XML
         * @param sourceUri the location of the XML input file
         */

        public abstract void BuildSource(Uri sourceUri);

        /**
         * Compile a stylesheet
         * @param stylesheetUri the file containing the XSLT stylesheet
         */

        public abstract void CompileStylesheet(Uri stylesheetUri);

        /**
         * Run a transformation, transforming the supplied source document using the
         * supplied stylesheet
         */

        public abstract void TreeToTreeTransform();

        /**
         * Run a transformation, from an input file to an output file
         */

        public abstract void FileToFileTransform(Uri sourceUri, String resultFileLocation);

        /**
         * Test that the result of the transformation satisfies a given assertion
         * @param assertion the assertion, in the form of an XPath expression which
         *                  must evaluate to TRUE when executed with the transformation
         *                  result as the context item
         * @return the result of testing the assertion
         */

        public abstract bool TestAssertion(String assertion);

        /**
         * Show the result document
         */

        public abstract void DisplayResultDocument();

        /**
         * Gets version of XSLT processor supported
         * @return version of XSLT
         */

        public abstract double GetXsltVersion();

        /**
         * Set a short name for the driver to be used in reports
         * @param name the name to be used for driver
         */

        public void SetName(String name)
        {
            this.driverName = name;
        }

        /**
         * Get the short name for the driver to be used in reports
         * @return the name
         */

        public String GetName()
        {
            return this.driverName;
        }

        /**
         * Set an option for this driver
         * @param name the name of the option
         * @param value the value of the option
         */

        public virtual void SetOption(String name, String value)
        {
            options.Add(name, value);
        }

        /**
         * Get the value of an option that has been set
         * @param name the name of the option
         * @return the value of the option, or null if none has been set
         */

        public virtual String GetOption(String name)
        {
            return (String)options[name];
        }

        /**
        * Set a test run option for this driver
        * @param name the name of the test
        * @param value the value of the test run option
        */

        public void SetTestRunOption(String name, String value)
        {
            testOptions.Add(name, value);
        }

        /**
         * Get the value of a test run option that has been set
         * @param name the name of the test
         * @return the value of the test run option, or null if none has been set
         */

        public String GetTestRunOption(String name)
        {
            return (String)testOptions[name];
        }
    }


    public class TransformationException : ApplicationException
    {
        public TransformationException()
        { }
        public TransformationException(string message)
            : base(message)
        { }
        public TransformationException(string message, Exception inner)
            : base(message, inner)
        { }
    }
}