XT-Speedo
=========

Benchmarking framework for XSLT, developed by Saxonica. The project contains a set of test material, a set of test drivers for various XSLT processors, and tools for analyzing the test results.

This version is forked from [https://github.com/Saxonica/XT-Speedo](https://github.com/Saxonica/XT-Speedo)

=========

## What the Speedo does

### Running the Speedo

XT-Speedo benchmark packages (contained in the `drivers` directory) have been produced on different platforms, to test a range of products. The main input to run the Speedo is the tests catalog file `data/catalog.xml` and the drivers catalog file `data/drivers.xml` (command line `-cat:` and `-dr:` input). 

When the Speedo is run, for each driver (on the relevant platform) in the `drivers.xml` catalog, all (selected) test transformations in the `catalog.xml` are carried out (each test case basically consists of a source document and a stylesheet, and possibly a schema, for some transformation — all of this test material is found in the `data` directory). The output of each transformation is tested using an XPath test assertion to check that it has worked. For each successful test case, times are measured for: stylesheet compile, file-to-file transform, and tree-to-tree transform. For each of these processes (for each test), an average time over a number of runs is recorded.

### Speedo results

The Speedo is configured to save one result document (XML file) per driver. The location of the output directory for result files is given as a command line option `-out:` when the Speedo is run (currently `results`). The driver result document records the level of success of each test case: 'success' if the run is fine, 'wrong answer' if transforms take place but the assertion test fails (so the transformation result is not as expected), and 'failure' if the transformation fails at some point. For successful tests, process times are recorded in the driver's result document, while test output (the files resulting from each test transformation) is saved in the driver's directory under `results/output`.

### Analysing the results

The reporting stylesheet `analysis/report.xsl` produces HTML reports to view the results of a collection of drivers (currently set up to use the driver results XML files found in `results/selection`). The report consists of an index page which allows you to select a baseline against which to compare, for each baseline there exists overview page containing a table comparing the performance of all the drivers, with links (click on the driver name) to driver pages which contain further information. These driver pages contain bar charts for each of the three measured processes (file-to-file transform, tree-to-tree transform, and stylesheet compile) showing the driver's performance for each test compared to a selected baseline driver. Under the bar charts is the full table of results for the driver, giving process times for each test (performance relative to the baseline, and actual times).

=========

## Further details on using the Speedo

### Selecting which tests to run

Further command line options for the Speedo are provided to select which test cases from the catalog to use — primarily by providing a regular expression name pattern (`-t:` input), but also for example by choosing to skip tests which are particularly slow (`-skip:` input) by providing an upper bound for test times in milliseconds (see **Driver options** below for more details).

### Getting a full set of results

Collecting a full set of data for all processors requires more than one program run. As a minimum, there will be three runs, one for Java processors, one for .NET, and one for C/C++. To measure different versions of the same processor, or performance on different hardware or operating systems, then additional runs will be needed.

For the Java platform, the open source JAR files used by the drivers are contained in `drivers/java/lib` (for products which are not open source, these are stored externally).


### How to add drivers

In order to make fair comparisons, new drivers should be structured as closely as possible to the existing ones, as subclasses of IDriver. The IDriver interface defines methods to compile a stylesheet, to load a schema, to build a source document, to run tree-to-tree or file-to-file transformations, to test an assertion (using the transformation result output), to display the result document, and to get the version of XSLT processor; and as many of these methods as possible (as supported by the product) should be implemented. Access to any necessary JAR files should be added to the Speedo. 

To run the new driver in the Speedo, details should be added to the `data/drivers.xml` catalog, using the same form as the existing drivers. See the schema `data/drivers-schema.xsd` for details.

### Driver options

Initialization option settings and test run options can be added to the driver data in `data/drivers.xml`. Several entries in the drivers catalog can be used to run the same product with different configuration options (optimization on or off, bytecode generation on or off, and so on), using `<option>` elements. Similarly, `<test-run-option>` elements are used to indicate that particular tests should not be run with a particular driver (for example because they are known to crash), or that they are excessively slow and should sometimes be skipped. Setting the `value` attribute to 'no' for a specified test means the it will never run for this driver; alternatively the `value` can be set to an integer (the order of magnitude of the slowest process time in milliseconds, for example '1000' or '10000'), and then when the command line `-skip:` input is set to a corresponding integer, any tests with values greater than or equal to the input integer will not run.

###  How to add tests

A test case basically consists of a source XML file with an XSLT stylesheet file (which may of course link to a number of other stylesheets), and possibly an XSD schema file. These files should be added to the `data` directory. In order to add a new test to the benchmark, it must be added to `catalog.xml` as a new `<test-case>` element. New test-cases should take the same form as used for the existing test-cases, see the schema `data/catalog-schema.xsd` for details.

As well as providing paths to the source, stylesheet and schema documents, these `<test-case>` elements also contain one or more test assertions — XPath expressions to be applied to the output of the transformation to check the results are plausible. Furthermore, the `<test-case>` elements should contain a description of the test transformation, some creation information, and for tests which use XSLT version 2.0 or higher, an `xslt-version` attribute (without this attribute the version is assumed to be 1.0).

###  More on the test catalog

The tests in this benchmark collection are not representative of any real production workload. Although they are nearly all real programs designed to perform (or at least emulate) a useful task rather than to stress obscure corners of the processor, some of them perform rather untypical tasks, such as parsing XPath expressions.

It is positively encouraged to run the XT-Speedo benchmark with different test data files that better characterize the workload for which performance data is required. The benchmark is a resource that anyone can use to compare different workloads in different environments in any way that suits their purposes.
