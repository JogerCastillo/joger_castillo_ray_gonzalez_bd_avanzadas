-- Extracción de empleados con departamento y cargo en formato XML
SELECT
  XMLELEMENT(
    "empleados",
    XMLAGG(
      XMLELEMENT(
        "empleado",
        XMLATTRIBUTES(e.employee_id AS "id"),
        XMLFOREST(
          e.first_name                         AS "nombre",
          e.last_name                          AS "apellido",
          e.email                              AS "email",
          e.phone_number                       AS "telefono",
          TO_CHAR(e.hire_date, 'YYYY-MM-DD')   AS "fecha_contratacion",
          e.salary                             AS "salario"
        ),
        XMLELEMENT(
          "departamento",
          XMLFOREST(
            d.department_id   AS "id",
            d.department_name AS "nombre"
          )
        ),
        XMLELEMENT(
          "cargo",
          XMLFOREST(
            j.job_id    AS "id",
            j.job_title AS "titulo"
          )
        )
      )
      ORDER BY e.employee_id
    )
  ).getClobVal() AS xml_resultado
FROM hr.employees   e
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.jobs        j ON e.job_id        = j.job_id;
