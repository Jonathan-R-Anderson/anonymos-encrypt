module Common.Xml;

import core.stdc.stdlib : malloc;
import core.stdc.string : strchr, strcmp, memcpy;
import core.stdc.string : strncpy, strlen;
import core.stdc.string : strcpy;
import core.stdc.wchar_ : wcslen, wcscpy;

bool BeginsWith(char* str, char* sub)
{
    while (*str++ == *sub++)
    {
        if (*sub == 0) return true;
        if (*str == 0) return false;
    }
    return false;
}

char* XmlNextNode(char* xmlNode)
{
    char* t = xmlNode + 1;
    while ((t = strchr(t, '<')) !is null)
    {
        if (t[1] != '/')
            return t;
        ++t;
    }
    return null;
}

char* XmlFindElement(char* xmlNode, char* nodeName)
{
    char* t = xmlNode;
    size_t nameLen = strlen(nodeName);
    do
    {
        if (BeginsWith(t + 1, nodeName) && (t[nameLen + 1] == '>' || t[nameLen + 1] == ' '))
            return t;
    } while ((t = XmlNextNode(t)) !is null);
    return null;
}

char* XmlFindElementByAttributeValue(char* xml, char* nodeName, const char* attrName, const char* attrValue)
{
    char[2048] attr;
    while ((xml = XmlFindElement(xml, nodeName)) !is null)
    {
        XmlGetAttributeText(xml, cast(char*)attrName, attr.ptr, attr.length);
        if (strcmp(attr.ptr, attrValue) == 0)
            return xml;
        ++xml;
    }
    return null;
}

char* XmlGetAttributeText(char* xmlNode, const char* xmlAttrName, char* xmlAttrValue, int xmlAttrValueSize)
{
    char* t = xmlNode;
    char* e = xmlNode;
    int l = 0;
    if (xmlAttrValueSize > 0)
        xmlAttrValue[0] = 0;
    if (t[0] != '<') return null;
    e = strchr(e, '>');
    if (e is null) return null;
    while ((t = strstr(t, xmlAttrName)) !is null && t < e)
    {
        char* o = t + strlen(xmlAttrName);
        if (t[-1] == ' ' && (BeginsWith(o, "=\"") || BeginsWith(o, "= \"") || BeginsWith(o, " =\"") || BeginsWith(o, " = \"")))
            break;
        t++;
    }
    if (t is null || t > e) return null;
    t = strchr(t, '"') + 1;
    e = strchr(t, '"');
    if (e is null) return null;
    l = cast(int)(e - t);
    if (l > xmlAttrValueSize) return null;
    memcpy(xmlAttrValue, t, l);
    xmlAttrValue[l] = 0;
    return xmlAttrValue;
}

char* XmlGetNodeText(char* xmlNode, char* xmlText, int xmlTextSize)
{
    char* t = xmlNode;
    char* e = xmlNode + 1;
    int l = 0; int i = 0; int j = 0;
    if (xmlTextSize > 0)
        xmlText[0] = 0;
    if (t[0] != '<')
        return null;
    t = strchr(t, '>');
    if (t is null) return null;
    ++t;
    e = strchr(e, '<');
    if (e is null) return null;
    l = cast(int)(e - t);
    if (l > xmlTextSize) return null;
    while (i < l)
    {
        if (BeginsWith(t + i, "&lt;"))
        { xmlText[j++] = '<'; i += 4; continue; }
        if (BeginsWith(t + i, "&gt;"))
        { xmlText[j++] = '>'; i += 4; continue; }
        if (BeginsWith(t + i, "&amp;"))
        { xmlText[j++] = '&'; i += 5; continue; }
        xmlText[j++] = t[i++];
    }
    xmlText[j] = 0;
    return t;
}

char* XmlQuoteText(const char* textSrc, char* textDst, int textDstMaxSize)
{
    char* textDstLast = textDst + textDstMaxSize - 1;
    if (textDstMaxSize == 0) return null;
    while (*textSrc != 0 && textDst <= textDstLast)
    {
        char c = *textSrc++;
        switch (c)
        {
            case '&':
                if (textDst + 6 > textDstLast) return null;
                strcpy(textDst, "&amp;");
                textDst += 5; textDstMaxSize -= 5; continue;
            case '>':
                if (textDst + 5 > textDstLast) return null;
                strcpy(textDst, "&gt;");
                textDst += 4; textDstMaxSize -= 4; continue;
            case '<':
                if (textDst + 5 > textDstLast) return null;
                strcpy(textDst, "&lt;");
                textDst += 4; textDstMaxSize -= 4; continue;
            default:
                *textDst++ = c; textDstMaxSize--; break;
        }
    }
    if (textDst > textDstLast) return null;
    *textDst = 0; return textDst;
}

wchar_t* XmlQuoteTextW(const wchar_t* textSrc, wchar_t* textDst, int textDstMaxSize)
{
    wchar_t* textDstLast = textDst + textDstMaxSize - 1;
    if (textDstMaxSize == 0) return null;
    while (*textSrc != 0 && textDst <= textDstLast)
    {
        wchar_t c = *textSrc++;
        switch (c)
        {
            case '&':
                if (textDst + 6 > textDstLast) return null;
                wcscpy(textDst, "&amp;"w.ptr);
                textDst += 5; textDstMaxSize -= 5; continue;
            case '>':
                if (textDst + 5 > textDstLast) return null;
                wcscpy(textDst, "&gt;"w.ptr);
                textDst += 4; textDstMaxSize -= 4; continue;
            case '<':
                if (textDst + 5 > textDstLast) return null;
                wcscpy(textDst, "&lt;"w.ptr);
                textDst += 4; textDstMaxSize -= 4; continue;
            default:
                *textDst++ = c; textDstMaxSize--; break;
        }
    }
    if (textDst > textDstLast) return null;
    *textDst = 0; return textDst;
}

int XmlWriteHeader(FILE* file)
{
    import core.stdc.wchar_ : fputws;
    return fputws("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<VeraCrypt>"w.ptr, file);
}

int XmlWriteFooter(FILE* file)
{
    import core.stdc.wchar_ : fputws;
    return fputws("\n</VeraCrypt>"w.ptr, file);
}
