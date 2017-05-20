<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" encoding="utf-8" indent="yes"/>
    <xsl:template match="command-ref">
        <xsl:call-template name="renderCmdRef">
            <xsl:with-param name="name" select="@name"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="enum-ref">
        <xsl:call-template name="renderEnumRef">
            <xsl:with-param name="name" select="@name"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="struct-ref">
        <xsl:call-template name="renderStructRef">
            <xsl:with-param name="name" select="@name"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="code">
        <pre><xsl:value-of select="."/></pre>
    </xsl:template>
    <xsl:template match="sub">
        <sub><xsl:apply-templates select="node()"/></sub>
    </xsl:template>
    <xsl:template match="sup">
        <sup><xsl:apply-templates select="node()"/></sup>
    </xsl:template>
    <xsl:template match="em">
        <em><xsl:apply-templates select="node()"/></em>
    </xsl:template>
    <xsl:template match="strong">
        <strong><xsl:apply-templates select="node()"/></strong>
    </xsl:template>
    <xsl:template name="functionPrefixOldStyle">
        <!-- if plugin node defined a prefix attribute, we use it for
             functions prefix, otherwise we use the plugin's name attribute -->
        <xsl:text>simExt</xsl:text>
        <xsl:choose>
            <xsl:when test="/plugin/@prefix">
                <xsl:value-of select="/plugin/@prefix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="/plugin/@name"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>_</xsl:text>
    </xsl:template>
    <xsl:template name="functionPrefixNewStyle">
        <xsl:text>sim</xsl:text>
        <xsl:value-of select="/plugin/@short-name"/>
        <xsl:text>.</xsl:text>
    </xsl:template>
    <xsl:template name="renderCmdName">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="/plugin/@short-name">
                <xsl:call-template name="functionPrefixNewStyle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="functionPrefixOldStyle"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$name"/>
    </xsl:template>
    <xsl:template name="renderCmdRef">
        <xsl:param name="name"/>
        <a href="#cmd:{$name}"><xsl:call-template name="renderCmdName"><xsl:with-param name="name" select="$name"/></xsl:call-template></a>
    </xsl:template>
    <xsl:template name="renderEnumName">
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="/plugin/@short-name">
                <xsl:call-template name="functionPrefixNewStyle"/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$name"/>
    </xsl:template>
    <xsl:template name="renderEnumRef">
        <xsl:param name="name"/>
        <a href="#enum:{$name}"><xsl:call-template name="renderEnumName"><xsl:with-param name="name" select="$name"/></xsl:call-template></a>
    </xsl:template>
    <xsl:template name="renderStructName">
        <xsl:param name="name"/>
        <xsl:value-of select="$name"/>
    </xsl:template>
    <xsl:template name="renderStructRef">
        <xsl:param name="name"/>
        <a href="#struct:{$name}"><xsl:call-template name="renderStructName"><xsl:with-param name="name" select="$name"/></xsl:call-template></a>
    </xsl:template>
    <xsl:template name="renderParams">
        <xsl:param name="showDefault"/>
        <xsl:choose>
            <xsl:when test="param">
                <xsl:for-each select="param">
                    <div>
                        <strong><xsl:value-of select="@name"/></strong>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:if test="@type='table'">
                            <xsl:text> of </xsl:text>
                            <xsl:value-of select="@item-type"/>
                        </xsl:if>
                        <xsl:if test="@default and $showDefault='true'">
                            <xsl:text>, default: </xsl:text>
                            <xsl:value-of select="@default"/>
                        </xsl:if>
                        <xsl:text>): </xsl:text>
                        <xsl:apply-templates select="description/node()"/>
                    </div>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="renderRelated">
        <xsl:variable name="sname" select="@name"/>
        <!-- manual cross references (within tag <see-also>): -->
        <xsl:for-each select="see-also/*[name()='command-ref' or name()='enum-ref' or name()='struct-ref']">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
        <!-- autogenerated cross references from command in the same category -->
        <xsl:for-each select="categories/category">
            <xsl:variable name="cat" select="@name"/>
            <xsl:for-each select="/plugin/command">
                <xsl:sort select="@name"/>
                <xsl:variable name="cmd" select="@name"/>
                <xsl:if test="not($cmd = $sname)">
                    <xsl:for-each select="categories/category">
                        <xsl:if test="not(@indirect = 'true')">
                            <xsl:if test="$cat=@name">
                                <xsl:text> </xsl:text>
                                <xsl:call-template name="renderCmdRef">
                                    <xsl:with-param name="name" select="$cmd"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="/">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Strict//EN"&gt;</xsl:text>
        <html>
            <head>
                <meta http-equiv="Content-Language" content="en-us"/>
                <title>API Functions</title>
                <link rel="stylesheet" type="text/css" href="../../helpFiles/style.css"/>
            </head>
            <body>
                <div align="center">
                    <table class="allEncompassingTable">
                        <tr>
                            <td>
                                <h1><xsl:value-of select="/plugin/@name"/> Plugin API reference</h1>
                                <xsl:if test="/plugin/description and (/plugin/description != '')">
                                    <p class="infoBox">
                                        <xsl:apply-templates select="/plugin/description/node()"/>
                                    </p>
                                </xsl:if>
                                <xsl:for-each select="plugin/command">
                                    <xsl:sort select="@name"/>
                                    <xsl:if test="description != ''">
                                        <h3 class="subsectionBar"><a name="cmd:{@name}" id="cmd:{@name}"></a><xsl:call-template name="renderCmdName"><xsl:with-param name="name" select="@name"/></xsl:call-template></h3>
                                        <table class="apiTable">
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftDescr">
                                                    Description
                                                </td>
                                                <td class="apiTableRightDescr">
                                                    <xsl:apply-templates select="description/node()"/>
                                                </td>
                                            </tr>
                                            <!--
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftCSyn">C synopsis</td>
                                                <td class="apiTableRightCSyn">-</td>
                                            </tr>
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftCParam">C parameters</td>
                                                <td class="apiTableRightCParam">-</td>
                                            </tr>
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftCRet">C return value</td>
                                                <td class="apiTableRightCRet">-</td>
                                            </tr>
                                            -->
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftLSyn">Lua synopsis</td>
                                                <td class="apiTableRightLSyn">
                                                    <xsl:for-each select="return/param">
                                                        <xsl:value-of select="@type"/>
                                                        <xsl:text> </xsl:text>
                                                        <xsl:value-of select="@name"/>
                                                        <xsl:if test="not(position() = last())">, </xsl:if>
                                                    </xsl:for-each>
                                                    <xsl:if test="return/param">=</xsl:if>
                                                    <xsl:call-template name="renderCmdName">
                                                        <xsl:with-param name="name" select="@name"/>
                                                    </xsl:call-template>
                                                    <xsl:text>(</xsl:text>
                                                    <xsl:for-each select="params/param">
                                                        <xsl:value-of select="@type"/>
                                                        <xsl:text> </xsl:text>
                                                        <xsl:value-of select="@name"/>
                                                        <xsl:if test="@default">=<xsl:value-of select="@default"/></xsl:if>
                                                        <xsl:if test="not(position() = last())">, </xsl:if>
                                                    </xsl:for-each>
                                                    <xsl:text>)</xsl:text>
                                                    <br/>
                                                </td>
                                            </tr>
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftLParam">Lua parameters</td>
                                                <td class="apiTableRightLParam">
                                                    <xsl:for-each select="params">
                                                        <xsl:call-template name="renderParams">
                                                            <xsl:with-param name="showDefault" select="'true'"/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                                </td>
                                            </tr>
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftLRet">Lua return values</td>
                                                <td class="apiTableRightLRet">
                                                    <xsl:for-each select="return">
                                                        <xsl:call-template name="renderParams">
                                                            <xsl:with-param name="showDefault" select="'false'"/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                                </td>
                                            </tr>
                                            <tr class="apiTableTr">
                                                <td class="apiTableLeftDescr">
                                                    See also
                                                </td>
                                                <td class="apiTableRightDescr">
                                                    <xsl:call-template name="renderRelated"/>
                                                </td>
                                            </tr>
                                        </table>
                                        <br/>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:if test="plugin/enum/*">
                                    <br/>
                                    <br/>
                                    <h1>Constants</h1>
                                    <xsl:for-each select="plugin/enum">
                                        <h3 class="subsectionBar"><a name="enum:{@name}" id="enum:{@name}"></a><xsl:call-template name="renderEnumName"><xsl:with-param name="name" select="@name"/></xsl:call-template></h3>
                                    <table class="apiConstantsTable">
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <xsl:for-each select="item">
                                                        <div>
                                                            <strong>
                                                                <xsl:if test="not /plugin/@short-name">
                                                                <xsl:value-of select="../@item-prefix"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="@name"/>
                                                            </strong>
                                                            <xsl:if test="description">
                                                                <xsl:text>: </xsl:text>
                                                                <xsl:apply-templates select="description/node()"/>
                                                            </xsl:if>
                                                        </div>
                                                    </xsl:for-each>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                    </xsl:for-each>
                                </xsl:if>
                                <xsl:if test="plugin/struct/*">
                                    <br/>
                                    <br/>
                                    <h1>Data structures</h1>
                                    <p>Data structures are used to pass complex data around. Create data structures in Lua in the form of a hash table, e.g.: <code>{line_size=3, add_to_legend=false, selectable=true}</code></p>
                                    <xsl:for-each select="plugin/struct">
                                    <h3 class="subsectionBar"><a name="struct:{@name}" id="struct:{@name}"></a><xsl:call-template name="renderStructName"><xsl:with-param name="name" select="@name"/></xsl:call-template></h3>
                                    <table class="apiTable">
                                        <tr class="apiTableTr">
                                            <td class="apiTableLeftDescr">
                                                Description
                                            </td>
                                            <td class="apiTableRightDescr">
                                                <xsl:apply-templates select="description/node()"/>
                                                <br/>
                                            </td>
                                        </tr>
                                        <tr class="apiTableTr">
                                            <td class="apiTableLeftLParam">Fields</td>
                                            <td class="apiTableRightLParam">
                                                <xsl:call-template name="renderParams">
                                                    <xsl:with-param name="showDefault" select="'true'"/>
                                                </xsl:call-template>
                                            </td>
                                        </tr>
                                        <tr class="apiTableTr">
                                            <td class="apiTableLeftDescr">
                                                See also
                                            </td>
                                            <td class="apiTableRightDescr">
                                                <xsl:call-template name="renderRelated"/>
                                            </td>
                                        </tr>
                                    </table>
                                    <br/>
                                    </xsl:for-each>
                                </xsl:if>
                            </td>
                        </tr>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
