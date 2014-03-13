<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <!-- Stylesheet updated to produce elements rather than just text, DL 2014-03-12 -->

<xsl:decimal-format name="default"/>

<xsl:decimal-format name="funky" 
  decimal-separator="&amp;" 
  grouping-separator="/"
  infinity="unfunity"
  minus-sign="_"
  NaN="(c'est nes pas un nombre)"
  percent="@"
  per-mille="!"
  zero-digit="0"
  digit="#"
  pattern-separator=";"/> 

<xsl:decimal-format name="dumb" digit="@" pattern-separator="R"/>

<xsl:template match="numbertest">
<out><xsl:apply-templates select="number"/></out>
</xsl:template>

<xsl:template match="number">
<one><xsl:value-of select="format-number(., '##,##,00.##')"/></one>
<two><xsl:value-of select="format-number(., '####000,00.##;000.00000')"/></two>
<three><xsl:value-of select="format-number(., '%##0.00')"/></three>
<four><xsl:value-of select="format-number(., '?###0.00')"/></four>
<five><xsl:value-of select="format-number(., '##,##00,000.##;-000000000.0')"/></five>
<six><xsl:value-of select="format-number(., 'abc0.00123')"/></six>
<seven><xsl:value-of select="format-number(., '-0;0')"/></seven>
<eight><xsl:value-of select="format-number(., '-0;-0')"/></eight>
<nine><xsl:value-of select="format-number(., '-0')"/></nine>
</xsl:template>


</xsl:stylesheet>