class Num_1_100:
    
    domain = list(range(1,101))

        
    def Extract(self):
    #solo si es un nuemro nenor a 100 y mayor a 0
        while True:
            opc =int(input("Que numero del 1-100 quieres extraer"))
            if(opc<=100 and opc>=0):
                break
                    
        self.domain.remove(opc)  

        rango = range(1,101)
        for i in range(len(rango)):
            isNumeroFaltante=True
            
            for j in range(len(self.domain)):
                if (self.domain[j] == rango[i]):
                        isNumeroFaltante = False;
            #se imprime el numero que falta
            if (isNumeroFaltante):
                print("Falta el número ", rango[i])
                
        #se muestra el vector sin ese valor
        for i in range(len(self.domain)):
            print(self.domain[i])
                    
#asiganacion de clase
prueba =Num_1_100()
#uso del metodoExtract()
prueba.Extract()