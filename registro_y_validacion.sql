-- Registro del esquema XSD en Oracle XML DB
DECLARE
  v_schema CLOB :=
    '<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xs:element name="empleados">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="empleado" type="TipoEmpleado" maxOccurs="unbounded"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>

  <xs:complexType name="TipoEmpleado">
    <xs:sequence>
      <xs:element name="nombre"             type="xs:string"/>
      <xs:element name="apellido"           type="xs:string"/>
      <xs:element name="email"              type="xs:string"/>
      <xs:element name="telefono"           type="xs:string" minOccurs="0"/>
      <xs:element name="fecha_contratacion" type="xs:date"/>
      <xs:element name="salario"            type="TipoSalario"/>
      <xs:element name="departamento"       type="TipoDepartamento"/>
      <xs:element name="cargo"              type="TipoCargo"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:positiveInteger" use="required"/>
  </xs:complexType>

  <xs:simpleType name="TipoSalario">
    <xs:restriction base="xs:decimal">
      <xs:minInclusive value="0"/>
    </xs:restriction>
  </xs:simpleType>

  <xs:complexType name="TipoDepartamento">
    <xs:sequence>
      <xs:element name="id"     type="xs:positiveInteger"/>
      <xs:element name="nombre" type="xs:string"/>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="TipoCargo">
    <xs:sequence>
      <xs:element name="id"     type="xs:string"/>
      <xs:element name="titulo" type="xs:string"/>
    </xs:sequence>
  </xs:complexType>

</xs:schema>';
BEGIN
  DBMS_XMLSCHEMA.registerSchema(
    SCHEMAURL => 'http://joger_castillo/empleados.xsd',
    SCHEMADOC => v_schema,
    LOCAL      => TRUE,
    GENTYPES   => TRUE,
    GENBEAN    => FALSE,
    GENTABLES  => FALSE
  );
END;
/


-- Tabla con columna XMLType vinculada al esquema registrado
CREATE TABLE empleados_xml (
  id_registro NUMBER GENERATED ALWAYS AS IDENTITY,
  datos       XMLTYPE,
  CONSTRAINT pk_empleados_xml PRIMARY KEY (id_registro)
) XMLTYPE COLUMN datos
  XMLSCHEMA "http://joger_castillo/empleados.xsd"
  ELEMENT "empleados";


-- Inserción válida
INSERT INTO empleados_xml (datos) VALUES (
  XMLTYPE('<?xml version="1.0" encoding="UTF-8"?>
<empleados>
  <empleado id="200">
    <nombre>Jennifer</nombre>
    <apellido>Whalen</apellido>
    <email>JWHALEN</email>
    <telefono>515.123.4444</telefono>
    <fecha_contratacion>1987-09-17</fecha_contratacion>
    <salario>4400</salario>
    <departamento>
      <id>10</id>
      <nombre>Administration</nombre>
    </departamento>
    <cargo>
      <id>AD_ASST</id>
      <titulo>Administration Assistant</titulo>
    </cargo>
  </empleado>
</empleados>')
);

COMMIT;


-- Inserción inválida: salario negativo viola xs:minInclusive value="0"
INSERT INTO empleados_xml (datos) VALUES (
  XMLTYPE('<?xml version="1.0" encoding="UTF-8"?>
<empleados>
  <empleado id="999">
    <nombre>Usuario</nombre>
    <apellido>Prueba</apellido>
    <email>UPRUEBA</email>
    <fecha_contratacion>2024-01-01</fecha_contratacion>
    <salario>-3000</salario>
    <departamento>
      <id>10</id>
      <nombre>Administration</nombre>
    </departamento>
    <cargo>
      <id>XX_TEST</id>
      <titulo>Test</titulo>
    </cargo>
  </empleado>
</empleados>')
);


-- Limpieza
-- DROP TABLE empleados_xml;
-- EXEC DBMS_XMLSCHEMA.deleteSchema('http://joger_castillo/empleados.xsd', DBMS_XMLSCHEMA.DELETE_CASCADE);
