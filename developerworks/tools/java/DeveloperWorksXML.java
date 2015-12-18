// DeveloperWorksXML class
//
// This sample class is designed to validate and transform 
// articles and tutorials for IBM developerWorks.
// The four possible arguments are:
//   xmlfile schemafile xslfile and outputfile. Defaults are:
//   xmlfile="index.xml"
//   schemafile = "../schema/dwVersion/dw-document-" + dwVersion + ".xsd"
//   xslfile = "../xsl/dwVersion/dw-document-html-" + dwVersion + ".xsl"
//   outputfile = "index.html"
//   where dwVersion is currently 5.0
// The default usage assumes the dw author template standard
// directory layout.
// See the "Author guidelines" tab at 
// http://www.ibm.com/developerworks/aboutdw/
// for more information on how to use this program.
// © Copyright IBM Corporation 2004. All rights reserved.


import java.lang.System;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.FactoryConfigurationError;
import javax.xml.transform.sax.SAXTransformerFactory;

import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.dom.DOMSource;

public class DeveloperWorksXML{

    // XMLErrorHandler handles parsing errors. It extends DefaultHandler. 
    // See http://xml.apache.org/xerces2-j/javadocs/api/org/xml/sax/helpers/DefaultHandler.html
    private class XMLErrorHandler extends DefaultHandler {
	public boolean  validationError = false;  
	public SAXParseException saxParseException = null; 
	public void error(SAXParseException exception) 
	    throws SAXException {
	    validationError=true;
	    saxParseException=exception;
	}     
	public void fatalError(SAXParseException exception) 
	    throws SAXException { 
	    validationError = true;
	    saxParseException=exception;
	}		    
	public void warning(SAXParseException exception) 
	    throws SAXException {
	    //	    validationError=true;
	    //	    saxParseException=exception;
	}	
    }   

    private DocumentBuilderFactory createDocBuilderFactory(boolean validating)
    {
        boolean rc = false;
	DocumentBuilderFactory docFactory = null;
	System.setProperty("javax.xml.parsers.DocumentBuilderFactory",
			   "org.apache.xerces.jaxp.DocumentBuilderFactoryImpl");
	try {
	    docFactory =  DocumentBuilderFactory.newInstance();
	    docFactory.setNamespaceAware(true); 
	    docFactory.setCoalescing(true); 
	    docFactory.setValidating(validating);
	} catch (FactoryConfigurationError fce) {
	    System.out.println(fce.getMessage());
	    System.out.println("Try adding xml-apis.jar and xercesImpl.jar to");
	    System.out.println("your classpath (See http://xml.apache.org/xerces2-j/)");
	}
	return docFactory;
    }

    private void transformXML(Node domdoc, 
			      String systemId,
			      String xslUrl,
			      String outputHtml) 
	throws TransformerException, TransformerConfigurationException, 
	       FileNotFoundException, IOException {

	// The javax.xml.transform.TransformerFactory system property 
	// determines the class to instantiate --
	// org.apache.xalan.transformer.TransformerImpl.
	TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Templates stylesheet = null;
	DocumentBuilderFactory docFactory = null;
	Document fragmentDoc = null;
        if (xslUrl != null) {
	    docFactory = createDocBuilderFactory(false);
	    if (docFactory != null) {
		try {
		    // Parse the stylesheet and also use the factory while we have it
		    // to create a doc that we will need later 
		    DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
		    Node xslDOM = docBuilder.parse(new InputSource(xslUrl));
		    stylesheet = transformerFactory.newTemplates(new DOMSource(xslDOM,
									       xslUrl));
		    fragmentDoc = docBuilder.newDocument();
		} catch (NoClassDefFoundError nce) {
		    System.out.println("Missing class "+nce.getMessage());
		    System.out.println("Try adding xml-apis.jar and xercesImpl.jar to");
		    System.out.println("your classpath (See http://xml.apache.org/xerces2-j/)");
		} catch(java.io.IOException ioe)    {        
		    System.out.println("IOException "+ioe.getMessage());
		} catch (SAXException e) {            
		    System.out.println("SAXException "+e.getMessage());
		} catch (ParserConfigurationException e) { 
		    System.out.println("ParserConfigurationException "+e.getMessage());
		}
	    }
	}

        StreamResult streamOut = new StreamResult(new FileOutputStream(outputHtml));
	streamOut.setSystemId(outputHtml);

	SAXTransformerFactory saxFactory = null;
	try {
	    TransformerFactory tfactory = TransformerFactory.newInstance();
	    saxFactory = (SAXTransformerFactory) tfactory;
	}
	catch (TransformerFactoryConfigurationError pfe) {
	    System.out.println("Transformer factory configuration error "+pfe.getMessage());
	}

        if ((saxFactory != null) && (stylesheet != null) && (fragmentDoc != null)) {
	    Transformer transformer = stylesheet.newTransformer();
	    // Set the output format
	    transformer.setOutputProperty(OutputKeys.METHOD, "xml");
	    org.w3c.dom.DocumentFragment domResult = fragmentDoc.createDocumentFragment();
	    // Transformer extensions don't work if SystemId is not specified.
	    transformer.transform(new DOMSource(domdoc, systemId),
				  new DOMResult(domResult));
	    // Serialize output to streamOut stream
	    Transformer serializer = saxFactory.newTransformer();
	    serializer.setOutputProperties(stylesheet.getOutputProperties());
	    // System.out.println("serializationPropertiess=" + serializer.getOutputProperties());
	    serializer.transform(new DOMSource(domResult), streamOut);
	}

	// Close output file
	if (streamOut != null) {
	    java.io.Writer writer = streamOut.getWriter(); // Java 1.3.1
	    java.io.OutputStream outputStream = streamOut.getOutputStream(); // Java 1.4.2
	    try {
		if (writer != null) writer.close();
		if (outputStream != null) outputStream.close();
	    }
	    catch(java.io.IOException ioe) {
		System.out.println("IOException "+ioe.getMessage());
	    }
	}        
    }

    private Node validateXML(String schemaUrl, 
			     String xmlDocumentUrl) 
    {
        boolean rc = false;
	Node domdoc = null;
        DocumentBuilderFactory docFactory = createDocBuilderFactory(true);
	if (docFactory != null) {
	    try {
		docFactory.setAttribute("http://java.sun.com/xml/jaxp/properties/schemaLanguage",
					"http://www.w3.org/2001/XMLSchema" );
		docFactory.setAttribute("http://java.sun.com/xml/jaxp/properties/schemaSource",
					schemaUrl);
		DocumentBuilder builder = docFactory.newDocumentBuilder();
		XMLErrorHandler handler = new XMLErrorHandler();
		builder.setErrorHandler(handler); 
		domdoc = builder.parse(new InputSource(xmlDocumentUrl));
		if(handler.validationError) {
		    System.out.println("handler found error");

		    domdoc = null;
		    // Ooops. Document has errors, so tell the user about 
		    // them (well, at least the first one). 
		    // Give location (line,col) plus error message
		    System.out.println("XML Document has Error: " + 
				       handler.validationError +
				       " at line " + 
				       handler.saxParseException.getLineNumber() +
				       " column " +
				       handler.saxParseException.getColumnNumber() 
				       );
		    System.out.println(handler.saxParseException.getMessage());
		} else {
		    System.out.println("XML document passed schema check");
		}
	    } catch (NoClassDefFoundError nce) {
		System.out.println("Missing class "+nce.getMessage());
		System.out.println("Try adding xml-apis.jar and xercesImpl.jar to");
		System.out.println("your classpath (See http://xml.apache.org/xerces2-j/)");
	    } catch(java.io.IOException ioe)    {        
		System.out.println("IOException "+ioe.getMessage());
	    } catch (SAXException e) {            
		System.out.println("XML Document has Error: "  );
		System.out.println("SAXException "+e.getMessage());
		domdoc = null;
	    } catch (ParserConfigurationException e) { 
		System.out.println("ParserConfigurationException "+e.getMessage());
	    }
	}
	return domdoc;
    }

    public static void main(String[] argv)
	throws TransformerException, TransformerConfigurationException, 
	       FileNotFoundException, IOException
    {  
	String minLevel = "1.4";
	String sysVersion = System.getProperty("java.specification.version");
        System.out.println("Using Java runtime version " +
			   System.getProperty("java.runtime.version") +
                           " from " +
			   System.getProperty("java.vm.vendor") );

	if (minLevel.compareTo(sysVersion) <= 0) {
	    String dwVersion = "5.0";
	    String xmlDocumentUrl;
	    String schemaUrl;
	    String transformUrl;
	    String outputFile;
	    if (argv.length >= 1) {
		xmlDocumentUrl=argv[0];
	    } else {
		xmlDocumentUrl="index.xml";
	    }
	    if (argv.length >= 2) {
		schemaUrl=argv[1];
	    } else {
		schemaUrl="../schema/" + dwVersion + "/dw-document-" + dwVersion + ".xsd";
	    }
	    if (argv.length >= 3) {
		transformUrl=argv[2];
	    } else {
		transformUrl="../xsl/" + dwVersion + "/dw-document-html-" + dwVersion + ".xsl";
	    }
	    if (argv.length >= 4) {
		outputFile=argv[3];
	    } else {
		String s1 = xmlDocumentUrl /* xfile.getCanonicalPath()*/;
		int periodPlace = s1.lastIndexOf(".");
		if(periodPlace > 0) {
		    outputFile = s1.substring(0,periodPlace) + ".html";
		} else {
		    outputFile = s1 + ".html";
		}
	    }
	    boolean filesExist = true;
	    File xfile = new File(xmlDocumentUrl);
	    filesExist = filesExist && xfile.exists() && xfile.canRead();
	    File sfile = new File(schemaUrl);
	    if(xfile.exists() && xfile.canRead()) {
		System.out.println("XML document is\n  " + xmlDocumentUrl);
	    } else {
		System.out.println("File\n  " + xmlDocumentUrl + 
				   "\ndoes not exist or cannot be read.");
		filesExist = false;
	    } 
	    if(sfile.exists() && sfile.canRead()) {
		System.out.println("Schema is\n  " + schemaUrl);
	    } else {
		System.out.println("File\n  " + schemaUrl + 
				   "\ndoes not exist or cannot be read.");
		filesExist = false;
	    } 
	    File tfile = new File(transformUrl);
	    if(tfile.exists() && tfile.canRead()) {
		System.out.println("XSL transform is\n  " + transformUrl);
	    } else {
		System.out.println("File\n  " + schemaUrl + 
				   "\ndoes not exist or cannot be read.");
		filesExist = false;
	    }

	    if (filesExist) {
		DeveloperWorksXML dwxml = new DeveloperWorksXML();
		Node domdoc = dwxml.validateXML(schemaUrl, xmlDocumentUrl);
		if(domdoc != null) {
		    System.out.println("Transforming to\n  " + outputFile);
		    dwxml.transformXML(domdoc, xmlDocumentUrl, transformUrl, outputFile);
		    File ofile = new File(outputFile);
		    if(ofile.exists() && ofile.canRead()) {
			System.out.println("Output file is\n  " + outputFile);
		    } else {
			System.out.println("Transformation failure creating\n  "
					   + outputFile);
		    }
		} else {

		    System.out.println("Transforming bypassed because of validation errors");
		}
	    }
	} else {
	    System.out.println("This program requires Java 1.4. You are using " + 
			       sysVersion + " from " + 
                               System.getProperty("java.vm.vendor"));
	}
    }
}
