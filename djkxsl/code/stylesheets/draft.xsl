<!--
 ! Excerpted from "XSL Jumpstarter",
 ! published by The Pragmatic Bookshelf.
 ! Copyrights apply to this code. It may not be used to create training material, 
 ! courses, books, articles, and the like. Contact us if you are in doubt.
 ! We make no guarantees that this code is fit for any purpose. 
 ! Visit http://www.pragmaticprogrammer.com/titles/djkxsl for more book information.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
  xmlns="http://www.w3.org/1999/xhtml" version="1.0">

  <xsl:import href="main.xsl"/>
  <xsl:template match="reviewer">
    <p style="background-color:yellow">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="author">
    <p style="background-color:cyan">
      <xsl:apply-templates/>
    </p>    
  </xsl:template>
  <xsl:template match="editor">
    <p style="background-color:green">
      <xsl:apply-templates/>
    </p>    
  </xsl:template>
</xsl:stylesheet>
