






-------- manager de preset pour Batiment ----------------------------------------------------------------------------------
struct str_mgr_batiment_presetsXML (
		
		------------ DEBUG	----------------------------------------------------------------------------------
-- 		m_debug = false,
		m_debug = true,		
		m_dbgPrefix ="",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		
		------------ MEMBRES	----------------------------------------------------------------------------------
	private
		fichier_dossier 		= "$userScripts\\cp-Urba\\lib\\",
		fichier_categorie		= "cp_urba_batiment",		
		fichier_extension		= "bati",		
		fichier_type 			= fichier_categorie + "(*." + fichier_extension + ")|*." + fichier_extension + "|All|*.*|",
		
		xmlPresets,
		
		----- parametres que l'on ne veut pas enregistrer (typiquement : la spline du batiment ) -------------
		params_a_ignorer 	= #("surface_node"),
		
		
		
		------------ FONCTIONS	----------------------------------------------------------------------------------
	private
		----------- divers ---------------------------------
		fn est_param_a_ignorer		_param_nom =(
			local result = false
			for param_a_ignorer in params_a_ignorer do
				if _param_nom as string == param_a_ignorer do result = true
			result
		),
		
		
		
		
		
		
	private
		fn enregistrer_parametre_dansNodeXML		_node	_xmlNode =(
			
			local parametres_noms 			=  getpropNames 	_node
			
			for param_nom in parametres_noms  where not est_param_a_ignorer	param_nom  do (
			
				local param_propriete 	= getProperty  _node 	param_nom 
				local param_class 		= classof	param_propriete
				
				case param_class of (
					ArrayParameter: (
								
							 	if param_propriete.count > 0 then (
									
									--- si c'est un plug -----
									if isMSPlugin	param_propriete[1] then (
										
										--- on creer le parametre ----- 
										local nv_nodeXML_param	=	xmlPresets.CreateElement		param_nom
										_xmlNode.appendChild 	nv_nodeXML_param
										
										for i = 1 to param_propriete.count do (
											
											--- on creer le l'item  ----- 
											local nv_nodeXML_item	=	xmlPresets.CreateElement		"item"
											nv_nodeXML_param.appendChild 	nv_nodeXML_item
											nv_nodeXML_item.SetAttribute 	"class"		( param_propriete[i] as string )
											
											enregistrer_parametre_dansNodeXML		param_propriete[i]		nv_nodeXML_item
											
										)
										 
									---- sinon c'est juste un tableau de trucs de base ----------
									) else	_xmlNode.SetAttribute 	param_nom		( param_propriete as string )
									
								---- sinon, le tableau est vide ------------
								) else 	_xmlNode.SetAttribute 	param_nom		( param_propriete as string )
								 
							)
					default:	(
						
						if isMSPlugin	param_propriete  then (
							
							--- on creer le parametre ----- 
							local nv_nodeXML_param	=	xmlPresets.CreateElement		param_nom
							_xmlNode.appendChild 	nv_nodeXML_param
							
							--- on creer le l'item  ----- 
							local nv_nodeXML_item	=	xmlPresets.CreateElement		"item"
							nv_nodeXML_param.appendChild 	nv_nodeXML_item
							nv_nodeXML_item.SetAttribute 	"class"		( param_propriete as string )
							
							enregistrer_parametre_dansNodeXML		param_propriete		nv_nodeXML_item
							
						) else (
							
							_xmlNode.SetAttribute 	param_nom		( param_propriete as string )
							
						)
						
					)
				) -- fin case param_class  ----
			) --- fin for param_nom	-------
		),
		
		
		fn charger_parametre_depuisNodeXML		_node	_xmlNode =(
			
			---- on charge les attributs --------------
			for i = 0 to _xmlNode.Attributes.count - 1 do (
				local attrib = _xmlNode.Attributes.itemOf[i]
				
				if attrib.name != "class" do (
					
					local prop_base 	= getProperty	_node	attrib.name
					case classOf prop_base of (
						string:	setProperty 	_node		attrib.name		attrib.value
						default:	setProperty 	_node		attrib.name		( execute attrib.value )
					)
					
				)
			)
			
			---- on charge les élements --------------
			for i = 0 to _xmlNode.ChildNodes.count - 1 do (
				
				local childNode = _xmlNode.ChildNodes.itemOf[i]
				
				local prop_base 	= getProperty	_node	childNode.name
				
				if isMSPlugin prop_base then (
					
					local childNodeItem 	= childNode.FirstChild		
					local classItem 			= childNodeItem.GetAttribute "class"
					
					local nv_item	=	createInstance	(execute classItem )					
					nv_item	=	charger_parametre_depuisNodeXML	nv_item		childNodeItem
					
					setProperty	_node	childNode.name	nv_item
					
				) else (
					
					local items_aAjouter = #()
					
					for i = 0 to childNode.ChildNodes.count - 1 do (
						
						local childNodeItem 	= childNode.ChildNodes.itemOf[i]
						local classItem 			= childNodeItem.GetAttribute "class"
						
						local nv_item	=	createInstance	(execute classItem )					
						nv_item	=	charger_parametre_depuisNodeXML	nv_item		childNodeItem
						
						append	items_aAjouter	nv_item
						
					)
					
					setProperty	_node	childNode.name	items_aAjouter
					
				)
				
			)
			
			_node
			
		),
		
		
		
		
	------- interface -------------------------------------
	public	
		fn enregistrer 		_node	fichier:		=(
			
			--- le dossier -----
			if not doesFileExist fichier_dossier do makeDir  fichier_dossier
			
			---- le fichier -----
			local fichierCible
			if fichier == unsupplied then
				fichierCible 	=	getSaveFileName 	caption:					"Enregistrer" 			\
																	filename:				fichier_dossier 		\
																	types:					fichier_type			\
																	historyCategory:		fichier_categorie
			else 	fichierCible	=	fichier
			
			
			---- l'enregistrement --------
			if fichierCible != undefined do (
				
				---- On creer le xml et son root 	-----------
				xmlPresets 				= dotNetObject "system.xml.xmlDocument"
				local xmlRoot		=	xmlPresets.CreateElement "Batiment"
				xmlPresets.appendChild xmlRoot
				
				---- parametres	-----
				enregistrer_parametre_dansNodeXML		_node	xmlRoot
				
				---- sauvegarder le xml -----------
				xmlPresets.save 		fichierCible
				
			)
			
			
			
		),
		
		
		fn charger  	_node 		fichier:		= (
			debug "charger"
			
			local fichierCible 	
			if fichier == unsupplied then
					fichierCible 	=	getopenFileName 		caption:				"Charger" 				\
																			filename:			fichier_dossier 		\
																			types:				fichier_type			\
																			historyCategory:	fichier_categorie
			else 	fichierCible	=	fichier
			
			if fichierCible != undefined do (
				
				---- On charge le xml 	-----------
				xmlPresets 				= dotNetObject "system.xml.xmlDocument"
				xmlPresets.load 		fichierCible
				
				---- on chope le premier noeud ----------
				local root_node = xmlPresets.FirstChild
				debug"root_node"var:root_node.Name
				
				
				charger_parametre_depuisNodeXML		_node	root_node 
				
			)
			
		)
		
		
) ------------- fin struct -------------------
	
	
	
	
	
	
mgr_preset_test = str_mgr_batiment_presetsXML ()
clearListener ()



mgr_preset_test.enregistrer		$cp_batiment001	fichier:"C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati"
mgr_preset_test.charger		 	$cp_batiment002	fichier:"C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati"

-- ShellLaunch "C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati" ""


	
	
	
	
	
	
	
	
/* 
	
	


---- creer le xml et son root 	-----------
xmlPresets 		= dotNetObject "system.xml.xmlDocument"
xmlRoot		=	xmlPresets.CreateElement "Batiment"
xmlPresets.appendChild xmlRoot



---- ajouter un element	------------
fn xml_ajouter_element	_xml_nodeParent		_element_nom	=(
	
	nvl_element	=	_xml_nodeParent.CreateElement		_element_nom
	_xml_nodeParent.appendChild 	nvl_element
	
	nvl_element
	
)

----- ajouter un attribut	-------
fn xml_ajouter_attribut	_xml_nodeParent	_attribut_nom		_attribut_valeur	=(
	_xml_nodeParent.SetAttribute 	_attribut_nom		_attribut_valeur
)







---- charger le xml -----------
xmlPresets.load  ("C:\\temp\\test.xml")

---- sauvegarder le xml -----------
xmlPresets.save ("C:\\temp\\test.xml")







ShellLaunch "C:\\temp\\test.xml" ""

-- ShellLaunch "C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati" ""

 */




/* 
show xmlPresets
showmethods xmlPresets

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

  .<System.Xml.XmlNode>		AppendChild <System.Xml.XmlNode>newChild
  .<System.Xml.XmlNode>	Clone()
  .<System.Xml.XmlNode		>CloneNode <System.Boolean>deep
  .<System.Xml.XmlAttribute		>CreateAttribute <System.String>name
  .<System.Xml.XmlAttribute>		CreateAttribute <System.String>qualifiedName <System.String>namespaceURI
  .<System.Xml.XmlAttribute>		CreateAttribute <System.String>prefix <System.String>localName <System.String>namespaceURI
  .<System.Xml.XmlCDataSection>		CreateCDataSection <System.String>data
  .<System.Xml.XmlComment		>CreateComment <System.String>data
  .<System.Xml.XmlDocumentFragment>		CreateDocumentFragment()
  .<System.Xml.XmlDocumentType>		CreateDocumentType <System.String>name <System.String>publicId <System.String>systemId <System.String>internalSubset
  .<System.Xml.XmlElement>			CreateElement <System.String>name
  .<System.Xml.XmlElement>			CreateElement <System.String>qualifiedName <System.String>namespaceURI
  .<System.Xml.XmlElement>			CreateElement <System.String>prefix <System.String>localName <System.String>namespaceURI
  .<System.Xml.XmlEntityReference>	CreateEntityReference <System.String>name
  .<System.Xml.XPath.XPathNavigator>	CreateNavigator()
  .<System.Xml.XmlNode>		CreateNode <System.String>nodeTypeString <System.String>name <System.String>namespaceURI
  .<System.Xml.XmlNode>		CreateNode <System.Xml.XmlNodeType>type <System.String>name <System.String>namespaceURI
  .<System.Xml.XmlNode>		CreateNode <System.Xml.XmlNodeType>type <System.String>prefix <System.String>name <System.String>namespaceURI
  .<System.Xml.XmlProcessingInstruction>			CreateProcessingInstruction <System.String>target <System.String>data
  .<System.Xml.XmlSignificantWhitespace>			CreateSignificantWhitespace <System.String>text
  .<System.Xml.XmlText>			CreateTextNode <System.String>text
  .<System.Xml.XmlWhitespace>			CreateWhitespace <System.String>text
  .<System.Xml.XmlDeclaration>			CreateXmlDeclaration <System.String>version <System.String>encoding <System.String>standalone
  .<System.Boolean>					Equals <System.Object>obj
  .[static]<System.Boolean>			Equals <System.Object>objA <System.Object>objB
  .<System.Xml.XmlElement>		GetElementById <System.String>elementId
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

 */


