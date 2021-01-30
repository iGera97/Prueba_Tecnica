#Prueba técnica: Data Engineer

##Sección 1: Data pipeline

###1.1 Carga de información
Se decidio usar el software MySQL para realizar la sección de esta prueba, ya que es el que tenía instalado y es donde tengo más expereciencia, además al revisar el dataset determiné que podría hacer la transformación de los datos de manera más directa. Otro gestor de base de datos que usé, para hacer pruebas del data set, fue MongoDB, la ventaja de este ultimó es la velocidad de importación de datos.

El método para instalar MySQL fue a través del siguiente Link: https://dev.mysql.com/downloads/installer/ , se instaló MySQL Installer, MySQL WorkBench y se configuró un servidor local para almacenar la base de datos.

###1.2 Extracción
Para la extracción se usó el lenguaje de programación R y el IDE RStudio porque es un software en el que tengo más experiencia y donde la extracción, y procesamiento de información es muy eficiente, el formato de trabajo fue .CSV porque es un formato muy conocido, y lo pude exportar e importar en muchos otros software.

Para realizar algunas pruebas de comparación tambien usé Microsoft Excel, aquí pude percatarme de que existían filas en blanco en el documento y al subirlas a MongoDB las contaba como registros, pero al importarlo en R desaparecieron y  se obtuvieron 10000 registros almacenados en la variable prueba.

    prueba <- read.csv("data_prueba_tecnica.csv",header = T)

###1.3 Transformación
De acuerdo a los parametros para la información solicitados se realizarón las siguientes acciones:

1* Primero se analizó la columna created_at, se encontraron dos valores con un formato diferente y se modificaron, para que coincidiera con los demás, posteriormente se transformó en formato de fecha.(Para este último paso de instaló la biblioteca "dplyr" con el comando install.packaches)
    #Convertir columnas created_at y paid_at como fechas
    #install.packages("dplyr")
    library(dplyr)
    (grep("-|-",prueba$created_at,value = F,invert = T))
    prueba$created_at[c(735,831)]
    prueba$created_at[c(735,831)] <- c("2019-05-16","2019-01-21")
    prueba <- mutate(prueba,created_at = as.Date(created_at, "%Y-%m-%d")) 

2* Posteriormente se filtro la columna paid_at, basandome en las especificaciones, transformé todos los valores vacios en "NULL", para que al momento de cargar la información de MYSQL, no existieran errores.

3* Se analizó la columna Id, donde se encontraron 3 registros en blanco, al tratarse de  un identificador, no tendría que repetirse, por lo que los eliminé . **Esto para que en un futuro se pudiera tomar como PRIMARY KEY en la base de datos y no se tuviera que agregar una columna extra autoincrementable.**

4* Filtré la columna amount y, siguiendo los parametros solicitados, se eliminaron los registros donde se encontraron números con mas de 16 digitos, en total fueron 3.

5*En la columna status se encontraron dos valores anormales, pero al no afectar se conservaron.

6* Se analizó la columna name donde se encontraron tres valores anormales, al comparar los registros me percaté que coincidían con el id_company, así que se cambio su nombre por el de esa compañia "MiPasajefy".

    unique(prueba$name)
    (r<- which(prueba$name=="MiPas0xFFFF"));(r2<- which(prueba$name=="MiP0xFFFF"));(r3<- which(prueba$name==""))
    prueba[c(r,r2,r3),]
    prueba$name[c(r,r2,r3)] <- "MiPasajefy"

7* Se analizó la columna id_company y se encontaron dos valores  anormales, analizando los registro ví que coincidian con el nombre de la compañia""MiPasajefy". Al finalizar los dos últimos pasos se observó que solo exstían dos compañias y dos id en todo el dataset.

    #Se encunetran valores de nombre anormales,coinciden id_empresa, se reparan
    unique(prueba$company_id)
    (r<- which(prueba$company_id==""));(r2<-which(prueba$company_id=="*******"))
    prueba[c(r,r2),] 
    prueba$company_id[c(r,r2)] <- "cbf1c8b09cd5b549416d49d220a40cbd317f952e"

8* Siguiendo los parametros solicitados, se redujeron a 24 caracteres los Strings de las columnas "id" y "company_id":

    #se convierten los id a cadenas de 24 caracteres
    prueba$id <- substring(prueba$id,first = 1,last=24)
    prueba$company_id <- substring(prueba$company_id,first = 1,last=24)
    nchar(prueba$company_id[5])

Finalmente se exportó la tabla corregida en un formato CSV, obteniendo un total de 9993 registros.

    write.csv(prueba,"data_prueba_tecnica_corregida.csv",row.names = F)

###1.4 Dispersión de la información
Utilizando MySQL se creó la base datos pruebatecnica, después la tabla Cargo con los parametros solicitados.

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
Una vez creada la tabla se importó el dataset "data_prueba_tecnica_corregida.csv" mediante la herramienta Tabla Data Import Wizard de WorkBench:

![Importacion csv](https://github.com/iGera97/Prueba_Tecnica/blob/main/Importacion.png "Importacion csv")

Al haber tratado los datos en R la importación fue exitosa, teniendo un total de 9993 registros.(Se creó un backUp de la tabla)

Posteriormente se realizó otra base de datos llamada "tablas_separadas", donde se crearon las tablas charges y companies, donde se distribuyeron las columnas de la tabla original "Cargo".

Quedando de la siguiente manera:
companies
|company_id   |company_name   |
| ------------ | ------------ |
| 8f642dc67fccf861548dfe1c |Muebles chidos   |
| cbf1c8b09cd5b549416d49d2  |  MiPasajefy |

charges
|   id       | company_id  | amount   | status  | created_at | update_at  |
| ------------ | ------------ | ------------ | ------------ | ------------ | ------------ |


Se creo un variable foranea para interocnectar estas dos tablas, generando el siguiente esquema estructurado:

![Esquema](https://github.com/iGera97/Prueba_Tecnica/blob/main/ESquema%20estrcuturado.png "Esquema")

###1.5 SQL
Finalmente se creó un vista donde se unieronambas tablas y se obtuvo el total de transacción por emprsa y por día:

    CREATE VIEW transacciones_com AS
    SELECT  com.company_name AS Compañias,created_at, SUM(amount) AS "Total" FROM charges AS ch 
    JOIN companies AS com ON ch.company_id=com.company_id 
    GROUP BY Compañias,created_at;

##Sección 2
Se implemento una aplicación en Python que calculara el numero faltante de un conjunto de los primeros 100 números naturales del cuál se extrajo uno:

Especificaciones:
- La aplicación debe de implementarse en el lenguaje Scala
- Se debe de implementar una clase que represente al conjunto de los primero 100 números
- La clase implementada debe de tener el método Extract para extraer un cierto numero
deseado
- La clase implementada debe de poder calcular que numero se extrajo y presentarlo
- Debe de incluir validación del input de datos (numero, numero menor de 100)
- La aplicación debe de poder ejecutarse con un argumento introducido por el usuario que
haga uso de nuestra clase y muestre que pudo calcular que se extrajo ese número

