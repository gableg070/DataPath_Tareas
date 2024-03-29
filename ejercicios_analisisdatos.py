# -*- coding: utf-8 -*-
"""Ejercicios_AnalisisDatos.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1VzKKn8bZ7k6QFRIerszlhxbrz1zZiqJZ

# **Ejercicios Calificado - Análisis de Datos con Python**
"""

import pandas as pd

df = pd.read_csv('sales_train.csv')

df['date'] = pd.to_datetime(df['date'], format='%d.%m.%Y')

df.dtypes

df['Ingresos'] = df['item_price']*df['item_cnt_day']
df['Year'] = df['date'].dt.year
df['Month'] = df['date'].dt.month
df['Day'] = df['date'].dt.day
#dfn = df[(df['date'].dt.year == 2013) & (df['date'].dt.month == 1)]
#dfn
df.head()

"""# **Ejercicio #5 Calificado**"""

# Ejercicio #5
p_constantes = df.groupby('item_id')['item_price'].nunique()
#p_constantes.shape
#p_constantes.dtypes
p_constantes = p_constantes[p_constantes == 1]
cifra = p_constantes.count()
print(f'La cantidad de artículos cuyo precio permanece constante son: {cifra} artículos.')
print(p_constantes)

"""# **Ejercicio #6 Calificado**"""

dfn = df[(df['Year'] == 2013) & (df['Month'] == 1)]
dfn = dfn[dfn['Ingresos']>0]
#df1=dfn['item_price']*dfn['item_cnt_day']
ventas_totales = dfn['Ingresos'].sum()
print(f'Las ventas totales registradas en el año 2023 para el mes de enero fueron: {ventas_totales} dólares')
#dfn.count()

"""# **Ejercicio #7 Calificado - Titanic.csv**"""

# Ejercicio #7
import matplotlib.pyplot as plt

df = pd.read_csv('titanic.csv')
df.tail(1)

#Mostrar por pantalla el hombre y mujeres (por separado) que sobrevivieron y murieron.

resultado = df.groupby('Sex')['Survived'].value_counts().unstack()

resultado.columns = ['Fallecidos', 'Sobrevivientes']

print(resultado)

# Mostrar Gráficos en Pantalla por Género y Sobrevivientes

resultado.plot(kind='bar', stacked=True, color=[ 'red', 'blue',])
plt.title('Sobrevivientes y fallecidos por género')
plt.xlabel('Género')
plt.ylabel('Cantidad de personas')
plt.xticks(ticks=[0, 1], labels=['Mujeres', 'Hombres'], rotation=0)
plt.legend(['Fallecidos', 'Sobrevivientes'])
plt.show()

# Mostrar por pantalla el porcentaje de personas que sobrevivieron en cada clase
resultados = df.groupby('Pclass')['Survived'].value_counts().unstack()

resultados.columns = ['Fallecidos', 'Sobrevivientes']

print(resultados)

# Mostrar por pantalla el porcentaje de personas que sobrevivieron en cada clase
sobrevivientes_clases = df.groupby('Pclass')['Survived'].mean() * 100
sobrevivientes_clases.plot(kind='bar' , color=[ 'red', 'green', 'blue',])
plt.title('Porcentaje % de sobrevivientes por clase')
plt.xlabel('Clase')
plt.ylabel('Porcentaje de sobrevivientes')
plt.xticks(ticks=[0, 1, 2], labels=['Primera clase', 'Segunda clase', 'Tercera clase'], fontsize=10, rotation=0)
plt.ylim(0, 100)
plt.show()