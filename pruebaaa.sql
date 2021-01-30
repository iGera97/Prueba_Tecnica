CREATE DATABASE pruebaTecnica;
USE pruebaTecnica;
#Creaciond etabla con parametros solicitados

CREATE TABLE pruebaTecnica.Cargo(
	id VARCHAR(24) NOT NULL,
    company_name VARCHAR(130) NULL,
    company_id VARCHAR(24) NOT NULL,
    amount DECIMAL(16,2) NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP  NOT NULL,
    update_at TIMESTAMP NULL,
    PRIMARY KEY(id)
);

#sE IMPORTARON LOS DATOS DEL archivo data_prueba_tecnica_corregida.csv mediante la herramienta:
#Tabla Data Import Wizard
SELECT count( *) FROM Cargo;
describe Cargo;
#DROP TABLE Cargo;

#copia de seguridad
CREATE TABLE pruebaTecnica.Cargo_BackUp SELECT * FROM pruebatecnica.cargo;
#DROP TABLE Cargo_BackUp;

describe Cargo_BackUp;
ALTER TABLE Cargo_BackUp ADD PRIMARY KEY(id);

#**************************************************************
CREATE DATABASE tablas_separadas;
USE tablas_separadas;
#CREACION DE LA TABLA COMPANIES con los datos de la compañia 
CREATE TABLE tablas_separadas.companies SELECT DISTINCT company_id,company_name FROM pruebatecnica.cargo; 
DESCRIBE companies;
select * from companies;
ALTER TABLE tablas_separadas.companies ADD PRIMARY KEY(company_id);#creacionde llave primaria

#CREACION DE LA TABLA CAHRGES con los datos de las transferencias
CREATE TABLE tablas_separadas.charges SELECT id,company_id,amount,status,created_at,update_at FROM pruebatecnica.cargo; 
DESCRIBE charges;
select * from charges;
#llaves primaria y foranea
ALTER TABLE tablas_separadas.charges ADD PRIMARY KEY(id);#llave primaria de la tabla charges
ALTER TABLE tablas_separadas.charges ADD CONSTRAINT fk_ComChar
FOREIGN KEY (company_id) REFERENCES companies(company_id)
ON DELETE CASCADE ON UPDATE CASCADE;#llave foranea de la tala charges

CREATE VIEW transacciones_com AS
SELECT  com.company_name AS Compañias,created_at, SUM(amount) AS "Total" FROM charges AS ch 
JOIN companies AS com ON ch.company_id=com.company_id 
GROUP BY Compañias,created_at;

SELECT * FROM transacciones_com;
