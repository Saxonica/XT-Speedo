<?xml version="1.0" encoding="UTF-8"?>
<!--   /* The Syncro Soft SRL License
  *
  *
  *  Copyright (c) 1998-2007 Syncro Soft SRL, Romania.  All rights
  *  reserved.
  *
  *  Redistribution and use in source and binary forms, with or without
  *  modification, are permitted provided that the following conditions
  *  are met:
  *
  *  1. Redistribution of source or in binary form is allowed only with
  *  the prior written permission of Syncro Soft SRL.
  *
  *  2. Redistributions of source code must retain the above copyright
  *  notice, this list of conditions and the following disclaimer.
  *
  *  2. Redistributions in binary form must reproduce the above copyright
  *  notice, this list of conditions and the following disclaimer in
  *  the documentation and/or other materials provided with the
  *  distribution.
  *
  *  3. The end-user documentation included with the redistribution,
  *  if any, must include the following acknowledgment:
  *  "This product includes software developed by the
  *  Syncro Soft SRL (http://www.sync.ro/)."
  *  Alternately, this acknowledgment may appear in the software itself,
  *  if and wherever such third-party acknowledgments normally appear.
  *
  *  4. The names "Oxygen" and "Syncro Soft SRL" must
  *  not be used to endorse or promote products derived from this
  *  software without prior written permission. For written
  *  permission, please contact support@oxygenxml.com.
  *
  *  5. Products derived from this software may not be called "Oxygen",
  *  nor may "Oxygen" appear in their name, without prior written
  *  permission of the Syncro Soft SRL.
  *
  *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
  *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
  *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  *  DISCLAIMED.  IN NO EVENT SHALL THE SYNCRO SOFT SRL OR
  *  ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
  *  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
  *  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  *  SUCH DAMAGE.
  */
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:XSLTExtensionIOUtil="java:ro.sync.io.XSLTExtensionIOUtil"
  xmlns:opf="http://www.idpf.org/2007/opf"
  exclude-result-prefixes="XSLTExtensionIOUtil"
  version="1.0">
  
  <!-- Dir of input XML. -->
  <xsl:param name="inputDir"/>
  
  <!-- Dir of output HTML. -->
  <xsl:param name="outputDir"/>
  
  <!-- Dir of images. -->
  <xsl:param name="imagesDir"/>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@src[parent::xhtml:img]">
    <xsl:variable name="imagePath" select="XSLTExtensionIOUtil:copyFile($inputDir, ., $outputDir, $imagesDir)"/>
    <xsl:attribute name="src"><xsl:value-of select="$imagePath"/></xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@data[parent::xhtml:object[@type='image/svg+xml']]">
    <xsl:variable name="imagePath" select="XSLTExtensionIOUtil:copyFile($inputDir, ., $outputDir, $imagesDir)"/>
    <xsl:attribute name="data"><xsl:value-of select="$imagePath"/></xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@href[parent::xhtml:link[@rel='stylesheet'][@type='text/css']]">
    <xsl:variable name="cssPath" select="XSLTExtensionIOUtil:copyFile($inputDir, ., $outputDir, 'css')"/>
    <xsl:attribute name="href"><xsl:value-of select="$cssPath"/></xsl:attribute>
  </xsl:template>
</xsl:stylesheet>