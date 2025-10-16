using System.Collections;
using System.ComponentModel;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.Xml;

namespace Speedo
{
    class RunSpeedo
    {
        public static int MIN_ITERATIONS = 5;
        public static long MAX_TOTAL_TIME = 1L * 1000L * 1000L * 1000L;

        private List<IDriver> drivers = new List<IDriver>();
        private IDriver baseline = null;
        private Boolean skipXslt3Tests = false;
        static void Main(string[] args)
        {
            try
            {
                Process.GetCurrentProcess().PriorityClass = ProcessPriorityClass.High;
            }
            catch (Win32Exception wex)
            {
                Console.WriteLine("Cannot set priority to high on this platform.");
            }

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
            //catalog = currentDirectory.FullName + "/" + catalog;
            String driverfile = (String)map["-dr"];
            if (driverfile == null)
            {
                driverfile = "drivers.xml";
            }
            //driverfile = currentDirectory.FullName + "/" + driverfile;
            String outputDir = (String)map["-out"];
            if (outputDir == null)
            {
                outputDir = "results";
            }
            //outputDir = currentDirectory.FullName + "/" + outputDir;
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
            skipXslt3Tests = ("no" == runXslt3Tests);

            Uri catalogUri = new Uri(catalogFile);

            XmlElement catalogElement = (XmlElement)doc.SelectSingleNode("*");
            foreach (IDriver driver in drivers)
            {
                String outputDir = Path.Combine(outputDirectory, "output");
                String driverOutputDir = Path.Combine(outputDir, driver.GetName());
                Directory.CreateDirectory(driverOutputDir);
                String outputFile = Path.Combine(outputDirectory, driver.GetName() + ".xml");                
                XmlWriter xmlStreamWriter = XmlWriter.Create(outputFile);
                xmlStreamWriter.WriteStartDocument();
                xmlStreamWriter.WriteStartElement("testResults");
                xmlStreamWriter.WriteAttributeString("driver", driver.GetName());

                DateTime now = DateTime.Now;
                Console.WriteLine("Date " + now);
                xmlStreamWriter.WriteAttributeString("on", "" + now.ToString("s"));
                xmlStreamWriter.WriteAttributeString("baseline", (driver == baseline ? "yes" : "no"));
                Console.WriteLine("Driver implemented: " + driver.GetName());
                Stopwatch stopwatch = Stopwatch.StartNew();
                double frequency = Stopwatch.Frequency;
                double nanosecPerTick = (1000 * 1000 * 1000) / frequency;
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
                    if ((testSkip != null) && (driver.GetTestRunOption(name) != null) && 
                        int.Parse(driver.GetTestRunOption(name)) >= int.Parse(testSkip))
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
                    driver.ResetVariables();
                    XmlElement schemaElement = (XmlElement)testCase.SelectSingleNode("test/schema");
                    String schema = schemaElement == null ? null : schemaElement.GetAttribute("file").ToString();   
                    Uri schemaUri = schema == null ? null : new Uri(catalogUri, schema);
                    XmlElement sourceElement = (XmlElement)testCase.SelectSingleNode("test/source");
                    String source = sourceElement == null ? null : sourceElement.GetAttribute("file").ToString();
                    Uri sourceUri = source == null ? null : new Uri(catalogUri, source);
                    String stylesheet = ((XmlElement)testCase.SelectSingleNode("test/stylesheet")).GetAttribute("file");
                    Uri stylesheetUri = new Uri(catalogUri, stylesheet);
                    if (xsltVersion <= driver.GetXsltVersion())
                    {
                        try
                        {
                            if (schema != null)
                            {
                                driver.LoadSchema(schemaUri);
                            }
                            if (source != null)
                            {
                                driver.BuildSource(sourceUri);
                            }    
                            int i;                          
                            double totalCompileStylesheet = 0;
                            for (i = 0; totalCompileStylesheet < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++)
                            {
                                double start = stopwatch.ElapsedTicks * nanosecPerTick;
                                driver.CompileStylesheet(stylesheetUri);
                                totalCompileStylesheet += stopwatch.ElapsedTicks * nanosecPerTick - start;
                            }
                            totalCompileStylesheet = 0;
                            GC.Collect();
                            // Wait for all finalizers to complete before continuing.
                            // Without this call to GC.WaitForPendingFinalizers, 
                            // the worker loop below might execute at the same time 
                            // as the finalizers.
                            // With this call, the worker loop executes only after
                            // all finalizers have been called.
                            GC.WaitForPendingFinalizers();
                            for (i = 0; totalCompileStylesheet < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++)
                            {
                                double start = stopwatch.ElapsedTicks * nanosecPerTick;
                                driver.CompileStylesheet(stylesheetUri);
                                totalCompileStylesheet += stopwatch.ElapsedTicks * nanosecPerTick - start;
                            }
                            double compileTime = totalCompileStylesheet / (1000000.0*i);
                            Console.WriteLine("Average time for stylesheet compile: " + compileTime +
                                    "ms. Number of iterations: " + i);
                            double totalTransformFileToFile = 0;
                            for (i = 0; totalTransformFileToFile < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++)
                            {
                                double start = stopwatch.ElapsedTicks * nanosecPerTick;
                                driver.FileToFileTransform(sourceUri, driverOutputDir + "/" + name + ".xml");
                                totalTransformFileToFile += stopwatch.ElapsedTicks * nanosecPerTick - start;
                            }
                            totalTransformFileToFile = 0;
                            GC.Collect();
                            GC.WaitForPendingFinalizers();
                            for (i = 0; totalTransformFileToFile < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++)
                            {
                                double start = stopwatch.ElapsedTicks * nanosecPerTick;
                                driver.FileToFileTransform(sourceUri, driverOutputDir + "/" + name + ".xml");
                                totalTransformFileToFile += stopwatch.ElapsedTicks * nanosecPerTick - start;
                            }
                            double transformTimeFileToFile = totalTransformFileToFile / (1000000.0 * i);
                            Console.WriteLine("Average time for FileToFileTransform: " + transformTimeFileToFile +
                                    "ms. Number of iterations: " + i);
                            double totalTransformTreeToTree = 0;
                            for (i = 0; totalTransformTreeToTree < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++)
                            {
                                double start = stopwatch.ElapsedTicks * nanosecPerTick;                                
                                driver.TreeToTreeTransform();
                                totalTransformTreeToTree += stopwatch.ElapsedTicks * nanosecPerTick - start;
                            }
                            totalTransformTreeToTree = 0;
                            GC.Collect();
                            GC.WaitForPendingFinalizers();
                            for (i = 0; totalTransformTreeToTree < MAX_TOTAL_TIME || i < MIN_ITERATIONS; i++)
                            {
                                double start = stopwatch.ElapsedTicks * nanosecPerTick;
                                driver.TreeToTreeTransform();
                                totalTransformTreeToTree += stopwatch.ElapsedTicks * nanosecPerTick - start;
                            }
                            double transformTimeTreeToTree = totalTransformTreeToTree / (1000000.0 * i);
                            Console.WriteLine("Average time for TreeToTreeTransform: " + transformTimeTreeToTree +
                                    "ms. Number of iterations: " + i);
                            bool ok = true;
                            foreach (XmlElement assertion in testCase.SelectNodes("result/assert"))
                            {
                                String xpath = assertion.InnerText;
                                ok &= driver.TestAssertion(xpath);
                            }
                            Console.WriteLine("Test run succeeded with " + driver.GetName());
                            String scale = testCase.GetAttribute("scale");
                            String scaleFactor = testCase.GetAttribute("scale-factor");
                            xmlStreamWriter.WriteStartElement("test");
                            xmlStreamWriter.WriteAttributeString("name", name);
                            if (scale != null && !scale.Equals(""))
                            {
                                xmlStreamWriter.WriteAttributeString("scale", scale);
                            }
                            if (scaleFactor != null && !scale.Equals(""))
                            {
                                xmlStreamWriter.WriteAttributeString("scale-factor", scaleFactor);
                            }
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
        * Load a schema document from a specified URI
        * @param schemaURI the location of the XSD document file
        */

        public virtual void LoadSchema(Uri schemaUri)
        {
            throw new TransformationException("Schema processing not supported with this driver");
        }

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
         * Reset all variables to initial state
         */

        public abstract void ResetVariables();

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
