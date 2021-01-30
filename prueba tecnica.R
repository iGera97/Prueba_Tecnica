#LIMPIEZA DE DATOS
prueba <- read.csv("data_prueba_tecnica.csv",header = T)
head(prueba,20)
summary(prueba)

#Convertir columnas created_at y paid_at como fechas
#install.packages("dplyr")
library(dplyr)
(grep("-|-",prueba$created_at,value = F,invert = T))
prueba$created_at[c(735,831)]
prueba$created_at[c(735,831)] <- c("2019-05-16","2019-01-21")
prueba <- mutate(prueba,created_at = as.Date(created_at, "%Y-%m-%d")) 

#Convertir datos NA en la columna de paid_at a NULL
(grep("-|-",prueba$paid_at,value = T,invert = T))
prueba$paid_at[prueba$paid_at==""] <- "NULL"

#identificar si hay VALORES NULOS EN EL ID
(r<- which(prueba$id==""))
prueba<- prueba[-c(r),]

#amount numeros menores a 16 digitos
mean(prueba$amount,na.rm = T) #vALOR Inf encontrado
(r <- which(prueba$amount==Inf))
prueba$amount[r] <- NA#Se convierte en NA
mean(prueba$amount,na.rm = T) #Error solucionado
(r2 <- which(prueba$amount>9999999999999999))#valores por encim de 16 degitos no entraran a la base de datos
prueba$amount[r2]
#se eliminaes datos erroneeos
prueba <- prueba[-c(r,r2),]


#Se encunetran valores de status anormales
unique(prueba$status)
which(prueba$status=="0xFFFF");which(prueba$status=="p&0x3fid")
prueba[c(3511,1309),]

#Se encunetran valores de nombre anormales,coinciden con una empresa, se reparan
unique(prueba$name)
(r<- which(prueba$name=="MiPas0xFFFF"));(r2<- which(prueba$name=="MiP0xFFFF"));(r3<- which(prueba$name==""))
prueba[c(r,r2,r3),]
prueba$name[c(r,r2,r3)] <- "MiPasajefy"

#Se encunetran valores de nombre anormales,coinciden id_empresa, se reparan
unique(prueba$company_id)
(r<- which(prueba$company_id==""));(r2<-which(prueba$company_id=="*******"))
prueba[c(r,r2),] 
prueba$company_id[c(r,r2)] <- "cbf1c8b09cd5b549416d49d220a40cbd317f952e"

#se convierten los id a cadenas de 24 caracteres
prueba$id <- substring(prueba$id,first = 1,last=24)
prueba$company_id <- substring(prueba$company_id,first = 1,last=24)
nchar(prueba$company_id[5])

str(prueba)
write.csv(prueba,"data_prueba_tecnica_corregida.csv",row.names = F)
