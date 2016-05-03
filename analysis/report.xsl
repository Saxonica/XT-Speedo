<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local">
    <xsl:include href="driver-module.xsl"/>

    <xsl:variable name="input-docs" as="document-node(element(testResults))*"
        select="collection(concat('../results/', $driverSetDir, '?*.xml'))"/>
           
    <xsl:variable name="input-baseline" select="$input-docs[testResults/@baseline='yes'][1]"/>               
    
    <!-- Update manually, but must contain the key word 'driverSet-' -->
    <xsl:variable name="driverSetDir" select="'driverSet-All/'" />
    <xsl:variable name="rootHTML" select="'html/'" />
    
    <xsl:output method="xhtml" />
    
    
    <!-- Update list of 'dirs' manually, to produce home-page with links to (previously produced) reports for sets of drivers -->
    <xsl:template name="home-page">
        
        <xsl:variable name="dirs" select="('driverSet-All', 'driverSet-Java','driverSet-SaxonHE-Java-vs-.NET', 'driverSet-SaxonEE-vs-XmlPrime',
            'driverSet-Saxon-9.5-vs-9.6', 'driverSet-SaxonEE', 'driverSet-SaxonEE-BC', 'driverSet-SaxonEE-noBC')" />
        <xsl:result-document href="{$rootHTML}report.html">
            <html>
                <head>
                    <link rel="stylesheet" type="text/css" href="../reportstyle.css"/>
                    <title>XT-Speedo results report</title>
                </head>
                <body>
                    <ul class="nav">
                        <li><a href="report.html">XT-SPEEDO</a></li>
                        <li><a href="report-info.html">Reports explained</a></li>
                        <li><a href="diagram.html">XT-Speedo diagram</a></li>
                        <li><a href="https://github.com/Saxonica/XT-Speedo/">GitHub project</a></li>
                    </ul>
                    <h1>XT-Speedo results reports</h1>    
                    <h3>Comparisons of results for selected sets of drivers:</h3>
                    <ul>
                        <xsl:for-each select="$dirs">                       
                            <li><a href="{.}/overview.html">
                                <xsl:analyze-string select="." regex="driverSet-(.+)|(.+)">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(1)" />
                                        <xsl:value-of select="regex-group(2)" />
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                                </a></li>
                        </xsl:for-each>
                    </ul>                    
                </body>
            </html>
        </xsl:result-document>        
    </xsl:template>

    <xsl:function name="local:baseline">
      <xsl:param name="baseline" />
      <xsl:sequence select="$baseline/testResults/string(@driver)"/>
    </xsl:function>

    <xsl:function name="local:driver-set">
      <xsl:param name="driverSetDir" />
      <xsl:analyze-string select="$driverSetDir" regex="driverSet-(.+)/|(.+)/">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(1)" />
      <xsl:value-of select="regex-group(2)" />
    </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:function>
    
    <!-- 'main' template produces reports for drivers: overview page and driver pages -->
    <xsl:template name="main">
        <xsl:result-document href="{$rootHTML}{$driverSetDir}overview.html">
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="../../reportstyle.css"/>
                <title>XT-Speedo results overview</title>
            </head>
            <body>
                <xsl:call-template name="nav-bar" />
        <nav>
          <a href="../report.html">XTSpeedo</a>
                  <span> &gt; </span>
          <span>
                    <xsl:text>Driver set </xsl:text>
            <xsl:value-of select="local:driver-set($driverSetDir)" />
          </span>
        </nav>
		<h1>XTSpeedo</h1>
		<p>Choose a baseline</p>
		<ul>
		  <xsl:for-each select="$input-docs">
	            <xsl:variable name="basename" select="testResults/@driver" />
		    <li>
		      <a href="{$basename}/overview.html">
			<xsl:value-of select="$basename" />
		      </a>
		    </li>
		  </xsl:for-each>
		</ul>
            </body>
        </html>
        </xsl:result-document>
      <xsl:for-each select="$input-docs">
	  <xsl:variable name="baseline" select="." />
	  <xsl:variable name="basename" select="testResults/@driver" />
        <xsl:result-document href="{$rootHTML}{$driverSetDir}{$basename}/overview.html">
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="../../../reportstyle.css"/>
                <title>XT-Speedo results overview</title>
            </head>
            <body>
                <xsl:call-template name="nav-bar">
          <xsl:with-param name="path" select="'../../'" />
        </xsl:call-template>
        <nav>
          <a href="../../report.html">XTSpeedo</a>
                  <span> &gt; </span>
          <a href="../overview.html">
                    <xsl:text>Driver set </xsl:text>
            <xsl:value-of select="local:driver-set($driverSetDir)" />
          </a>
                  <span> &gt; </span>
          <span>
                    <xsl:text>Baseline </xsl:text>
            <xsl:value-of select="local:baseline($baseline)" />
          </span>
        </nav>
                <xsl:call-template name="body">
		  <xsl:with-param name="baseline" select="$baseline" />
		</xsl:call-template>
            </body>
        </html>
        </xsl:result-document>
        <xsl:for-each select="$input-docs">
            <xsl:result-document href="{$rootHTML}{$driverSetDir}{$basename}/{testResults/@driver}.html">
                <xsl:call-template name="driver-page">
                    <xsl:with-param name="baseline" select="$baseline"/>
                    <xsl:with-param name="input-doc" select="."/>
                    <xsl:with-param name="driverSetDir" select="$driverSetDir"/>
                </xsl:call-template>
            </xsl:result-document>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="nav-bar">
      <xsl:param name="path" as="xs:string" select="'../'" />
        <ul class="nav">
            <li><a href="{$path}report.html">XT-SPEEDO</a></li>
            <li><a href="{$path}report-info.html">Reports explained</a></li>
            <li><a href="{$path}diagram.html">XT-Speedo diagram</a></li>
            <li><a href="https://github.com/Saxonica/XT-Speedo/">GitHub project</a></li>
        </ul>
    </xsl:template>
    
    <!-- Body of overview page -->
    <xsl:template name="body">        
      <xsl:param name="baseline" as="document-node()" />
        <h1>
            <xsl:value-of select="'Overview of results at', 
                format-dateTime($baseline/testResults/@on, '[H]:[m]:[s] on [D] [MNn] [Y]')"/>
        </h1>
        <h3> 
      <i>Set of drivers: </i> 
      <xsl:value-of select="local:driver-set($driverSetDir)" />
        </h3> 
        <h3> <i>Comparing performance to baseline driver: </i> 
      <xsl:value-of select="local:baseline($baseline)" />
        </h3>        
        <table id="overview">
            <thead>
                <th/>
                <th colspan="3"> Times relative to <xsl:value-of select="$baseline/testResults/@driver"/> driver <br/>
                    (smaller values represent faster times) 
                </th>                           
            </thead>
            <thead>
                <th>Driver</th>
                <th width="180px">File-to-file transform</th>
                <th width="180px">Tree-to-tree transform</th>
                <th width="180px">Stylesheet compile</th>
            </thead>
            <xsl:for-each select="$input-docs">
                <tr>
                    <td>
                        <a href="{testResults/@driver}.html">
                            <xsl:value-of select="testResults/@driver"/>
                        </a>
                    </td>                    
                    <xsl:variable name="tests" select="testResults/test[@run='success']/@name[. = $baseline/testResults/test[@run='success']/@name]"/>
                    <td>                        
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@transformTimeFileToFile"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeFileToFile"/>
                        <xsl:copy-of select="local:summary($times, $baseline-times)"/>
                    </td>
                    <td>
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@transformTimeTreeToTree"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeTreeToTree"/>
                        <xsl:copy-of select="local:summary($times, $baseline-times)"/>
                    </td>
                    <td>
                        <xsl:variable name="times" as="xs:double*"
                            select="for $t in $tests return testResults/test[@name = $t]/@compileTime"/>
                        <xsl:variable name="baseline-times" as="xs:double*"
                            select="for $t in $tests return $baseline/testResults/test[@name = $t]/@compileTime"/>
                        <xsl:copy-of select="local:summary($times, $baseline-times)"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <p>
            For further information about how these results were calculated, and what the numbers mean,
            see <a href="../../report-info.html">Reports explained</a>
        </p>
    </xsl:template>


    <xsl:function name="local:summary">
        <xsl:param name="times" as="xs:double*"/>
        <xsl:param name="baseline-times" as="xs:double*"/>
        <xsl:value-of select="format-number(sum($times) div sum($baseline-times), '0.0##')"/>
        <p class="minmax">
            <xsl:variable name="ratios" as="xs:double*"
                select="for $i in 1 to count($times) return $times[$i] div $baseline-times[$i]"/>
            <xsl:value-of select="'min =', format-number(min($ratios), '0.0##')"/>
            <xsl:value-of select="', max =', format-number(max($ratios), '0.0##')"/>
            <!--<xsl:for-each select="1 to count($times)">
                <xsl:value-of select="'-\-', format-number($ratios[current()], '0.0##')"/>
            </xsl:for-each>-->            
        </p>
    </xsl:function>    
    
</xsl:stylesheet>
