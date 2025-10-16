<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://www.saxonica.com/ns/xtspeedo/functions" exclude-result-prefixes="xs local"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:output method="xhtml" />
    
    
    <xsl:template name="driver-page">
        <xsl:param name="input-doc"/>
        <xsl:param name="baseline"/>
        <xsl:param name="driverSetDir"/>
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="../../../reportstyle.css"/>
                <title>XT-Speedo <xsl:value-of select="testResults/@driver"/> results</title>
            </head>
            <body>
                <ul class="nav">
                    <li><a href="../../report.html">XT-SPEEDO</a></li>
                    <li><a href="../../report-info.html">Reports explained</a></li>
                    <li><a href="../../diagram.html">XT-Speedo diagram</a></li>
                    <li><a href="https://github.com/Saxonica/XT-Speedo/">GitHub project</a></li>
                </ul>
        <nav>
          <a href="../../report.html">XTSpeedo</a>
                  <span> &gt; </span>
          <a href="../overview.html">
                    <xsl:text>Driver set </xsl:text>
            <xsl:value-of select="local:driver-set($driverSetDir)" />
          </a>
                  <span> &gt; </span>
          <a href="./overview.html">
                    <xsl:text>Baseline </xsl:text>
            <xsl:value-of select="local:baseline($baseline)" />
          </a>
                  <span> &gt; </span>
          <span>
                    <xsl:text>Comparison </xsl:text>
            <xsl:value-of select="testResults/@driver" />
          </span>
        </nav>
                                
                <h1>
                    <xsl:value-of
                        select="testResults/@driver, ' results at', 
                        format-dateTime(testResults/@on, '[H]:[m]:[s] on [D] [MNn] [Y]')"
                    />
                </h1>

                <h3> <i>Comparing performance to baseline driver: </i><xsl:value-of
                        select="$baseline/testResults/@driver"/>
                </h3>

                <xsl:variable name="scalable-tests"
                    select="testResults/test[xs:double(@scale-factor) ge 1]/@name"/>

                <p>
                    <ul>
                        <xsl:if test="not($baseline is .)">
                            <li>
                                <a href="#charts">Bar charts of relative speeds</a>
                            </li>
                        </xsl:if>
                        <li>
                            <a href="#driver-table">Full table of test results</a>
                        </li>
                        <xsl:if test="$scalable-tests != ''">
                            <li>
                                <a href="#scalable-table">Scalable test results</a>
                            </li>
                        </xsl:if>
                    </ul>
                </p>

                <xsl:variable name="tests"
                    select="testResults/test[@run='success']/@name[. = $baseline/testResults/test[@run='success']/@name]"/>

                <xsl:if test="not($baseline is .)">

                    <!--File to file transform-->
                    <xsl:variable name="times" as="xs:double*"
                        select="for $t in $tests return testResults/test[@name = $t]/@transformTimeFileToFile"/>
                    <xsl:variable name="baseline-times" as="xs:double*"
                        select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeFileToFile"/>

                    <h4>
                        <a id="charts"> File-to-file transform:
                             <xsl:value-of select="testResults/@driver"/> speeds relative to <xsl:value-of
                                select="$baseline/testResults/@driver"/></a>
                    </h4>
                    <xsl:copy-of select="local:chart($times, $baseline-times, $tests)"/>

                    <!--Tree to tree transform-->
                    <xsl:variable name="times" as="xs:double*"
                        select="for $t in $tests return testResults/test[@name = $t]/@transformTimeTreeToTree"/>
                    <xsl:variable name="baseline-times" as="xs:double*"
                        select="for $t in $tests return $baseline/testResults/test[@name = $t]/@transformTimeTreeToTree"/>
                    <xsl:choose>
                        <xsl:when test="not(every $t in $times satisfies string($t) eq 'NaN')">
                            <h4> Tree-to-tree transform: <xsl:value-of select="testResults/@driver"/>
                                 speeds relative to <xsl:value-of
                                    select="$baseline/testResults/@driver"/>
                            </h4>
                            <xsl:copy-of select="local:chart($times, $baseline-times, $tests)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <h4> No <xsl:value-of select="testResults/@driver"/> tree-to-tree
                                transform times are available. </h4>
                        </xsl:otherwise>
                    </xsl:choose>

                    <!--Stylesheet compile-->
                    <xsl:variable name="times" as="xs:double*"
                        select="for $t in $tests return testResults/test[@name = $t]/@compileTime"/>
                    <xsl:variable name="baseline-times" as="xs:double*"
                        select="for $t in $tests return $baseline/testResults/test[@name = $t]/@compileTime"/>
                    <h4> Stylesheet compile: <xsl:value-of select="testResults/@driver"/> 
                        speeds relative to <xsl:value-of select="$baseline/testResults/@driver"/>
                    </h4>
                    <xsl:copy-of select="local:chart($times, $baseline-times, $tests)"/>

                    <br/>
                    <br/>
                </xsl:if>
                
                <!-- Full table of test results for driver -->
                <h4>
                    <a id="driver-table">
                        <xsl:value-of
                            select="'Full table of test results for', testResults/@driver, 'relative to', 
                        $baseline/testResults/@driver"
                        />
                    </a>
                </h4>

                <table id="driver">
                    <thead>
                        <th/>
                        <th colspan="6"> <p>Times relative to <xsl:value-of
                            select="$baseline/testResults/@driver"/> driver <br/> (smaller
                            values represent faster times)</p> <p class="actual"> Actual times (in
                                milliseconds)</p>
                        </th>
                    </thead>
                    <thead>
                        <th>Test</th>
                        <th width="120px" colspan="2">File-to-file transform</th>
                        <th width="120px" colspan="2">Tree-to-tree transform</th>
                        <th width="120px" colspan="2">Stylesheet compile</th>
                    </thead>
                    <xsl:for-each select="./testResults/test">
                        <xsl:variable name="test-name" as="xs:string" select="./@name"/>
                        <tr>
                            <xsl:choose>
                                <xsl:when test="./@run = 'success'">
                                    <td>
                                        <xsl:value-of select="$test-name"/>
                                    </td>
                                    <td width="60px">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeFileToFile div $baseline/testResults/test[@name = $test-name]/@transformTimeFileToFile, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px" class="actual">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeFileToFile, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeTreeToTree div $baseline/testResults/test[@name = $test-name]/@transformTimeTreeToTree, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px" class="actual">
                                        <xsl:value-of
                                            select="format-number(./@transformTimeTreeToTree, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px">
                                        <xsl:value-of
                                            select="format-number(./@compileTime div $baseline/testResults/test[@name = $test-name]/@compileTime, '0.0##')"
                                        />
                                    </td>
                                    <td width="60px" class="actual">
                                        <xsl:value-of
                                            select="format-number(./@compileTime, '0.0##')"/>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <td bgcolor="#bbbbbb">
                                        <xsl:value-of select="$test-name"/>
                                    </td>
                                    <td colspan="6" bgcolor="#bbbbbb">
                                        <xsl:value-of select="./@run"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tr>
                    </xsl:for-each>
                </table>

                <br/>
                
                <!-- Scalable test results for driver -->

                <xsl:if test="$scalable-tests != ''">
                    <h4>
                        <a id="scalable-table">
                            <xsl:value-of
                                select="'Table of scalable test results for', testResults/@driver"/>
                        </a>
                    </h4>

                    <table id="scalable">
                        <thead>
                            <th colspan="2"/>
                            <th colspan="6"> Performance scale factor for test pair <p class="actual"> Actual
                                    times (in milliseconds)</p>
                            </th>
                        </thead>
                        <thead>
                            <th>Tests</th>
                            <th width="40px">Scale factor</th>
                            <th width="120px" colspan="2">File-to-file transform</th>
                            <th width="120px" colspan="2">Tree-to-tree transform</th>
                            <th width="120px" colspan="2">Stylesheet compile</th>
                        </thead>
                        <xsl:for-each select="./testResults/test[xs:double(@scale-factor) ge 1]">
                            <xsl:variable name="test-name" as="xs:string" select="./@name"/>
                            <tr>
                                <td class="actual">
                                    <!--<xsl:analyze-string select="./@scale" regex="^(.*)(-\d+)$">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(1)"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="regex-group(2)"/>
                                    </xsl:matching-substring>  
                                </xsl:analyze-string>
                                <xsl:analyze-string select="$test-name" regex="^(.*)(-\d+)$">
                                    <xsl:matching-substring>
                                        <xsl:text> &amp; </xsl:text>
                                        <xsl:value-of select="regex-group(2)"/>
                                    </xsl:matching-substring>  
                                </xsl:analyze-string> -->
                                    <xsl:value-of select="./@scale"/>
                                    <br/>
                                    <xsl:value-of select="$test-name"/>
                                </td>
                                <td>
                                    <xsl:value-of select="./@scale-factor"/>
                                </td>
                                <xsl:choose>
                                    <xsl:when test="./@run = 'success'">
                                        <td width="60px">
                                            <xsl:value-of
                                                select="format-number(./@transformTimeFileToFile div preceding-sibling::test[@name = current()/@scale]/@transformTimeFileToFile, '0.0##')"
                                            />
                                        </td>
                                        <td width="60px" class="actual">
                                            <xsl:value-of
                                                select="format-number(preceding-sibling::test[@name = current()/@scale]/@transformTimeFileToFile, '0.0##')"/>
                                            <br/>
                                            <xsl:value-of
                                                select="format-number(./@transformTimeFileToFile, '0.0##')"
                                            />
                                        </td>

                                        <td width="60px">
                                            <xsl:value-of
                                                select="format-number(./@transformTimeTreeToTree div preceding-sibling::test[@name = current()/@scale]/@transformTimeTreeToTree, '0.0##')"
                                            />
                                        </td>
                                        <td width="60px" class="actual">
                                            <xsl:value-of
                                                select="format-number(preceding-sibling::test[@name = current()/@scale]/@transformTimeTreeToTree, '0.0##')"/>
                                            <br/>
                                            <xsl:value-of
                                                select="format-number(./@transformTimeTreeToTree, '0.0##')"
                                            />
                                        </td>

                                        <td width="60px">
                                            <xsl:value-of
                                                select="format-number(./@compileTime div preceding-sibling::test[@name = current()/@scale]/@compileTime, '0.0##')"
                                            />
                                        </td>
                                        <td width="60px" class="actual">
                                            <xsl:value-of
                                                select="format-number(preceding-sibling::test[@name = current()/@scale]/@compileTime, '0.0##')"/>
                                            <br/>
                                            <xsl:value-of
                                                select="format-number(./@compileTime, '0.0##')"/>
                                        </td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td colspan="6" bgcolor="#bf6761">
                                            <xsl:value-of select="./@run"/>
                                        </td>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                        </xsl:for-each>
                    </table>
                </xsl:if>

            </body>
        </html>
    </xsl:template>


    <xsl:function name="local:percentile" as="xs:double">
        <xsl:param name="input" as="xs:double*"/>
        <xsl:param name="percent" as="xs:double"/>
        <xsl:variable name="sorted-input" as="xs:double*">
            <xsl:perform-sort select="$input[. ne 0 and string(.) ne 'NaN']">
                <xsl:sort select="."/>
            </xsl:perform-sort>
        </xsl:variable>
        <xsl:sequence
            select="($sorted-input[round(count($sorted-input)*$percent div 100)], $sorted-input[1], 1.1)[1]"
        />
    </xsl:function>
    
    <!-- Bar charts for test results-->
    <xsl:function name="local:chart">
        <xsl:param name="times" as="xs:double*"/>
        <xsl:param name="baseline-times" as="xs:double*"/>
        <xsl:param name="tests" as="xs:string*"/>
        <xsl:variable name="ratios" as="xs:double*"
            select="for $i in 1 to count($times) return $times[$i] div $baseline-times[$i]"/>
        <xsl:variable name="max-95" select="local:percentile($ratios,95)"/>
        <xsl:variable name="min-5" select="local:percentile($ratios,5)"/>
        <xsl:variable name="range-min5-max95"
            select="(if ($max-95 > 1) then (($max-95 - 1)) else (0)) + (if ($min-5 > 1) then (0) else (((1 div $min-5) - 1)))"/>
        <xsl:variable name="range-factor"
            select="(if ($max-95 > 1) then (($max-95 - 1) + $range-min5-max95*0.1) else (0)) + (if ($min-5 > 1) then (0) else (((1 div $min-5) - 1) + $range-min5-max95*0.1))"/>
        <xsl:variable name="baseline-axis"
            select="if ($max-95 > 1) then (($max-95 - 1) + $range-min5-max95*0.1) else (0)"/>
        <xsl:variable name="scale-factor" select="120 div $range-factor"/>
        <!--<p>
            number of tests: <xsl:value-of select="count($ratios)"/>, 
            max-95: <xsl:value-of select="format-number($max-95, '0.0#')"/>, 
            min-5: <xsl:value-of select="format-number($min-5, '0.0#')"/>, 
            range min5 to max95: <xsl:value-of select="format-number($range-min5-max95, '0.0#')"/>, 
            range factor: <xsl:value-of select="format-number($range-factor, '0.0#')"/>, 
            baseline axis to top of range: <xsl:value-of select="format-number($baseline-axis, '0.0#')"/>
        </p>-->

        <svg width="{count($ratios)*10 + 160}" height="160"
            viewBox="0 0 {count($ratios)*10 + 150} 160">
            <!--Boundary and borders-->
            <!--<line x1="0" y1="1" x2="{count($ratios)*10 + 150}" y2="1" style="stroke:blue; stroke-width:1"/>
            <line x1="0" y1="20" x2="{count($ratios)*10 + 150}" y2="20" style="stroke:blue; stroke-width:1"/>
            <line x1="0" y1="140" x2="{count($ratios)*10 + 150}" y2="140" style="stroke:blue; stroke-width:1"/>
            <line x1="0" y1="159" x2="{count($ratios)*10 + 150}" y2="159" style="stroke:blue; stroke-width:1"/>-->
            <!--Baseline-->
            <line x1="30" y1="{$baseline-axis*$scale-factor + 20}" x2="{count($ratios)*10 + 45}"
                y2="{$baseline-axis*$scale-factor + 20}" style="stroke:black; stroke-width:1"/>
            <text x="0" y="{$baseline-axis*$scale-factor + 24}" font-size="12px">1</text>
            <!--Gridlines-->
            <xsl:for-each select="1 to 4">
                <xsl:variable name="gridline"
                    select="if ($range-factor ge 4) then (current()*round($range-factor div 4)) 
                    else (if ($range-factor le 1) then (current() div 4) 
                    else (if ($range-factor le 2) then (current() div 2) else (current())))"/>
                <xsl:if test="$gridline le $baseline-axis">
                    <line x1="30" y1="{($baseline-axis - $gridline)*$scale-factor + 20}"
                        x2="{count($ratios)*10 + 45}"
                        y2="{($baseline-axis - $gridline)*$scale-factor + 20}"
                        style="stroke:grey; stroke-width:1"/>
                    <text x="0" y="{($baseline-axis - $gridline)*$scale-factor + 24}"
                        font-size="12px">
                        <xsl:value-of select="$gridline + 1"/>
                    </text>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="1 to 4">
                <xsl:variable name="line"
                    select="if ($range-factor ge 4) then (current()*round($range-factor div 4)) 
                    else (if ($range-factor le 1) then (current() div 4) 
                    else (if ($range-factor le 2) then (current() div 2) else (current())))"/>
                <xsl:if test="$line le $range-factor - $baseline-axis">
                    <line x1="30" y1="{($baseline-axis + $line)*$scale-factor + 20}"
                        x2="{count($ratios)*10 + 45}"
                        y2="{($baseline-axis + $line)*$scale-factor + 20}"
                        style="stroke:grey; stroke-width:1"/>
                    <text x="0" y="{($baseline-axis + $line)*$scale-factor + 24}" font-size="12px">
                        <xsl:value-of select="format-number(1 div ($line + 1), '.0##')"/>
                    </text>
                </xsl:if>
            </xsl:for-each>
            <!--Bars-->
            <xsl:for-each select="1 to count($ratios)">
                <xsl:if test="string($ratios[current()]) ne 'NaN'">
                    <xsl:variable name="slower"
                                  select="$ratios[current()] > 1" />
                    <xsl:choose>
                        <xsl:when
                            test="(($ratios[current()] ge 1) and ($ratios[current()] - 1 le $baseline-axis)) 
                            or (($ratios[current()] le 1) and ($ratios[current()] ne 0) and ((1 div $ratios[current()]) - 1 le $range-factor - $baseline-axis))">
                            <xsl:variable name="fill"
                                          select="if ($slower) 
                                                  then 'FFCEDE' 
                                                  else 'C1FFDE'" />
                            <xsl:variable name="stroke"
                                          select="if ($slower) 
                                                  then 'FF5B96' 
                                                  else '008800'" />
                            <rect x="{current()*10 + 30}"
                                y="{if ($slower) then (($baseline-axis - ($ratios[current()] - 1))*$scale-factor + 20) else ($baseline-axis*$scale-factor + 20)}"
                                width="5"
                                height="{if ($slower) then (($ratios[current()] - 1)*$scale-factor) else (((1 div $ratios[current()]) - 1)*$scale-factor)}"
                                style="fill:#{$fill}; stroke-width:1; stroke:#{$stroke}"
                                >
                              <title>
                                <xsl:value-of select="$tests[current()] || ': relative time = ' || format-number($ratios[current()], '0.0##')"/>
                              </title>
                            </rect>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="fill"
                                          select="if ($slower) 
                                                  then 'FF5B96' 
                                                  else '008800'" />
                            <rect x="{current()*10 + 30}"
                                y="{if ($slower) then (20) else ($baseline-axis*$scale-factor + 20)}"
                                width="5"
                                height="{if ($slower) then ($baseline-axis*$scale-factor) else (($range-factor - $baseline-axis)*$scale-factor)}"
                                style="fill:#{$fill}; stroke-width:1; stroke:#{$fill}">
                              <title>
                                <xsl:value-of select="$tests[current()] || ': relative time = ' || format-number($ratios[current()], '0.0##')"/>
                              </title>
                            </rect>
                            <xsl:choose>
                                <xsl:when test="$slower">
                                    <polygon
                                        points="{current()*10 + 29},{20} {current()*10 + 32.5},{17} {current()*10 + 36},{20}"
                                        style="fill:#{$fill}; stroke-width:1; stroke:#{$fill}">
                                      <title>
                                        <xsl:value-of select="$tests[current()] || ': relative time = ' || format-number($ratios[current()], '0.0##')"/>
                                      </title>
                                    </polygon>
                                </xsl:when>
                                <xsl:otherwise>
                                    <polygon
                                        points="{current()*10 + 29},{$range-factor*$scale-factor + 20} {current()*10 + 32.5},{$range-factor*$scale-factor + 23} {current()*10 + 36},{$range-factor*$scale-factor + 20}"
                                        style="fill:#{$fill}; stroke-width:1; stroke:#{$fill}">
                                      <title>
                                        <xsl:value-of select="$tests[current()] || ': relative time = ' || format-number($ratios[current()], '0.0##')"/>
                                      </title>
                                    </polygon>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
            <!--Labels-->
            <xsl:if test="$baseline-axis + 0.3*$range-factor le $range-factor">
                <text x="{count($ratios)*10 + 60 + 30}" y="{$baseline-axis*$scale-factor + 24 + 30}"
                    font-size="12px">Faster</text>
                <line x1="{count($ratios)*10 + 60 + 20}"
                    y1="{$baseline-axis*$scale-factor + 20 + 15}" x2="{count($ratios)*10 + 60 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 + 50}"
                    style="stroke:black; stroke-width:1"/>
                <line x1="{count($ratios)*10 + 60 + 20}"
                    y1="{$baseline-axis*$scale-factor + 20 + 50}"
                    x2="{count($ratios)*10 + 60 - 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 + 50 - 8}"
                    style="stroke:black; stroke-width:1"/>
                <line x1="{count($ratios)*10 + 60 + 20}"
                    y1="{$baseline-axis*$scale-factor + 20 + 50}"
                    x2="{count($ratios)*10 + 60 + 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 + 50 - 8}"
                    style="stroke:black; stroke-width:1"/>
            </xsl:if>
            <xsl:if test="$baseline-axis - 0.3*$range-factor ge 0">
                <text x="{count($ratios)*10 + 60 + 30}" y="{$baseline-axis*$scale-factor + 24 - 30}"
                    font-size="12px">Slower</text>
                <line x1="{count($ratios)*10 + 60 + 20}"
                    y1="{$baseline-axis*$scale-factor + 20 - 15}" x2="{count($ratios)*10 + 60 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 - 50}"
                    style="stroke:black; stroke-width:1"/>
                <line x1="{count($ratios)*10 + 60 + 20}"
                    y1="{$baseline-axis*$scale-factor + 20 - 50}"
                    x2="{count($ratios)*10 + 60 - 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 - 50 + 8}"
                    style="stroke:black; stroke-width:1"/>
                <line x1="{count($ratios)*10 + 60 + 20}"
                    y1="{$baseline-axis*$scale-factor + 20 - 50}"
                    x2="{count($ratios)*10 + 60 + 5 + 20}"
                    y2="{$baseline-axis*$scale-factor + 20 - 50 + 8}"
                    style="stroke:black; stroke-width:1"/>
            </xsl:if>
            <text x="{count($ratios)*10 + 60}" y="{$baseline-axis*$scale-factor + 24}"
                font-size="12px">Baseline speed</text>
        </svg>
    </xsl:function>


</xsl:stylesheet>
