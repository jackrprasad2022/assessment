# python file to solve the challenge to obtain the nested values and key. 

dictv={'a':{'b':{'c':'d'}}}

#dictv={'x':{'y':{'z':'a'}}}

#dictv={'a': 'b'}

arr=[]

def recfunction(dicto, tarr):
    
    for key, value in dicto.items():
        #print(key)
        tarr.append(key)
        if type(value) is dict:
            recfunction(value, tarr)
        else: 
            print("the value is ",value)
            
    return  tarr

            
    
print("the keys are ", recfunction(dictv, arr))
