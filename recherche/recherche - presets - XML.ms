



xmlDoc = dotNetObject "system.xml.xmlDocument"
show xmlDoc
showmethods xmlDoc


dotNetObject:System.Xml.XmlDocument

ATTRIBUTES

  .Attributes : 																			<System.Xml.XmlAttributeCollection>, read-only
  .BaseURI : 																				<System.String>, read-only
  .ChildNodes : 																			<System.Xml.XmlNodeList>, read-only
  .DocumentElement : 																	<System.Xml.XmlElement>, read-only
  .DocumentType :																		<System.Xml.XmlDocumentType>, read-only
  .FirstChild : 																				<System.Xml.XmlNode>, read-only
  .HasChildNodes : 																		<System.Boolean>, read-only
  .Implementation : 																	<System.Xml.XmlImplementation>, read-only
  .InnerText : 																				<System.String>, write-only
  .InnerXml : 																				<System.String>
  .IsReadOnly : 																			<System.Boolean>, read-only
  .Item[<System.String>name] : 													<System.Xml.XmlElement>, read-only
  .Item[<System.String>localname, <System.String>ns] : 				<System.Xml.XmlElement>, read-only
  .LastChild : 																				<System.Xml.XmlNode>, read-only
  .LocalName : 																			<System.String>, read-only
  .Name : 																					<System.String>, read-only
  .NamespaceURI :																		<System.String>, read-only
  .NameTable : 																			<System.Xml.XmlNameTable>, read-only
  .NextSibling :																			<System.Xml.XmlNode>, read-only
  .NodeType : 																				<System.Xml.XmlNodeType>, read-only
  .OuterXml : 																				<System.String>, read-only
  .OwnerDocument : 																	<System.Xml.XmlDocument>, read-only
  .ParentNode : 																			<System.Xml.XmlNode>, read-only
  .Prefix : 																					<System.String>
  .PreserveWhitespace : 																<System.Boolean>
  .PreviousSibling : 																		<System.Xml.XmlNode>, read-only
  .PreviousText : 																			<System.Xml.XmlNode>, read-only
  .SchemaInfo : 																			<System.Xml.Schema.IXmlSchemaInfo>, read-only
  .Schemas : 																				<System.Xml.Schema.XmlSchemaSet>
  .Value : 																					<System.String>
  .XmlResolver :																		 	System.Xml.XmlResolver>, write-only
  


METHODS

  .<System.Xml.XmlNode>AppendChild <System.Xml.XmlNode>newChild
  .<System.Xml.XmlNode>Clone()
  .<System.Xml.XmlNode>CloneNode <System.Boolean>deep
  .<System.Xml.XmlAttribute>CreateAttribute <System.String>name
  .<System.Xml.XmlAttribute>CreateAttribute <System.String>qualifiedName <System.String>namespaceURI
  .<System.Xml.XmlAttribute>CreateAttribute <System.String>prefix <System.String>localName <System.String>namespaceURI
  .<System.Xml.XmlCDataSection>CreateCDataSection <System.String>data
  .<System.Xml.XmlComment>CreateComment <System.String>data
  .<System.Xml.XmlDocumentFragment>CreateDocumentFragment()
  .<System.Xml.XmlDocumentType>CreateDocumentType <System.String>name <System.String>publicId <System.String>systemId <System.String>internalSubset
  .<System.Xml.XmlElement>CreateElement <System.String>name
  .<System.Xml.XmlElement>CreateElement <System.String>qualifiedName <System.String>namespaceURI
  .<System.Xml.XmlElement>CreateElement <System.String>prefix <System.String>localName <System.String>namespaceURI
  .<System.Xml.XmlEntityReference>CreateEntityReference <System.String>name
  .<System.Xml.XPath.XPathNavigator>CreateNavigator()
  .<System.Xml.XmlNode>CreateNode <System.String>nodeTypeString <System.String>name <System.String>namespaceURI
  .<System.Xml.XmlNode>CreateNode <System.Xml.XmlNodeType>type <System.String>name <System.String>namespaceURI
  .<System.Xml.XmlNode>CreateNode <System.Xml.XmlNodeType>type <System.String>prefix <System.String>name <System.String>namespaceURI
  .<System.Xml.XmlProcessingInstruction>CreateProcessingInstruction <System.String>target <System.String>data
  .<System.Xml.XmlSignificantWhitespace>CreateSignificantWhitespace <System.String>text
  .<System.Xml.XmlText>CreateTextNode <System.String>text
  .<System.Xml.XmlWhitespace>CreateWhitespace <System.String>text
  .<System.Xml.XmlDeclaration>CreateXmlDeclaration <System.String>version <System.String>encoding <System.String>standalone
  .<System.Boolean>Equals <System.Object>obj
  .[static]<System.Boolean>Equals <System.Object>objA <System.Object>objB
  .<System.Xml.XmlElement>GetElementById <System.String>elementId
  .<System.Xml.XmlNodeList>GetElementsByTagName <System.String>name
  .<System.Xml.XmlNodeList>GetElementsByTagName <System.String>localName <System.String>namespaceURI
  .<System.Collections.IEnumerator>GetEnumerator()
  .<System.Int32>GetHashCode()
  .<System.String>GetNamespaceOfPrefix <System.String>prefix
  .<System.String>GetPrefixOfNamespace <System.String>namespaceURI
  .<System.Type>GetType()
  .<System.Xml.XmlNode>ImportNode <System.Xml.XmlNode>node <System.Boolean>deep
  .<System.Xml.XmlNode>InsertAfter <System.Xml.XmlNode>newChild <System.Xml.XmlNode>refChild
  .<System.Xml.XmlNode>InsertBefore <System.Xml.XmlNode>newChild <System.Xml.XmlNode>refChild
  .Load <System.String>filename
  .Load <System.IO.TextReader>txtReader
  .Load <System.IO.Stream>inStream
  .Load <System.Xml.XmlReader>reader
  .LoadXml <System.String>xml
  .Normalize()
  .<System.Xml.XmlNode>PrependChild <System.Xml.XmlNode>newChild
  .<System.Xml.XmlNode>ReadNode <System.Xml.XmlReader>reader
  .[static]<System.Boolean>ReferenceEquals <System.Object>objA <System.Object>objB
  .RemoveAll()
  .<System.Xml.XmlNode>RemoveChild <System.Xml.XmlNode>oldChild
  .<System.Xml.XmlNode>ReplaceChild <System.Xml.XmlNode>newChild <System.Xml.XmlNode>oldChild
  .Save <System.IO.TextWriter>writer
  .Save <System.String>filename
  .Save <System.Xml.XmlWriter>w
  .Save <System.IO.Stream>outStream
  .<System.Xml.XmlNodeList>SelectNodes <System.String>xpath
  .<System.Xml.XmlNodeList>SelectNodes <System.String>xpath <System.Xml.XmlNamespaceManager>nsmgr
  .<System.Xml.XmlNode>SelectSingleNode <System.String>xpath
  .<System.Xml.XmlNode>SelectSingleNode <System.String>xpath <System.Xml.XmlNamespaceManager>nsmgr
  .<System.Boolean>Supports <System.String>feature <System.String>version
  .<System.String>ToString()
  .Validate <System.Xml.Schema.ValidationEventHandler>validationEventHandler
  .Validate <System.Xml.Schema.ValidationEventHandler>validationEventHandler <System.Xml.XmlNode>nodeToValidate
  .WriteContentTo <System.Xml.XmlWriter>xw
  .WriteTo <System.Xml.XmlWriter>w
true