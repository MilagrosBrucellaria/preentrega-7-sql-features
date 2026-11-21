# preentrega-7-sql-features
Ingeniería de Features con SQL Analítico Avanzado para análisis de comportamiento de clientes y churn.

# Preentrega 7 - Ingeniería de Features con SQL Analítico Avanzado

## Objetivo

El objetivo de este proyecto es transformar datos transaccionales de e-commerce en un dataset de features por cliente utilizando SQL analítico avanzado.

Las variables generadas resumen el comportamiento de compra de cada cliente y pueden utilizarse posteriormente como entrada para modelos de Machine Learning orientados, por ejemplo, a la predicción de abandono de clientes (churn).

## Fuente de los datos

Se utilizó el dataset **Online Retail** del UCI Machine Learning Repository.

Fuente oficial:
https://archive.ics.uci.edu/dataset/352/online+retail

El dataset contiene transacciones de una tienda online del Reino Unido registradas entre diciembre de 2010 y diciembre de 2011.

Para reproducir el ejercicio:

1. Descargar el dataset desde la fuente oficial.
2. Extraer el archivo descargado.
3. Utilizar el archivo `Online Retail.xlsx`.
4. Cargar los datos para ejecutar el proceso de preparación y las consultas SQL.

La carpeta de datos no se incluye en el repositorio y está declarada en `.gitignore`.

## Features generadas

### Recency

Cantidad de días transcurridos desde la última compra del cliente.

Una recencia elevada indica que transcurrió más tiempo desde su última actividad y puede ser una señal relevante para detectar riesgo de churn.

### Frequency

Cantidad de pedidos únicos realizados por el cliente.

Permite medir la frecuencia de compra y el nivel de actividad del cliente.

### Monetary

Gasto total acumulado por el cliente durante el período analizado.

Permite medir el valor económico generado por cada cliente.

### Last Month Spending

Gasto correspondiente al último mes en el que el cliente registró actividad.

Permite analizar su comportamiento reciente.

### Historical Monthly Average

Promedio de gasto mensual anterior al último mes disponible.

Se calcula utilizando una función de ventana `AVG() OVER`.

### Spending Trend

Diferencia entre el gasto del último mes y el promedio mensual histórico:

`Spending Trend = Last Month Spending - Historical Monthly Average`

- Un valor positivo indica un gasto reciente superior al promedio histórico.
- Un valor negativo indica una disminución del gasto reciente.
- Una caída del gasto puede funcionar como una señal de riesgo de churn.

### Accumulated Spending

Gasto acumulado del cliente a través del tiempo.

Se calcula mediante la función de ventana `SUM() OVER`.

## SQL analítico

La consulta utiliza funciones de ventana con `OVER` y `PARTITION BY`.

Las principales funciones utilizadas son:

- `ROW_NUMBER() OVER`: identifica el último mes de actividad de cada cliente.
- `AVG() OVER`: calcula el promedio mensual histórico.
- `SUM() OVER`: calcula el gasto acumulado.

También se utilizan agregaciones, `GROUP BY`, funciones de fecha y filtros para asegurar la consistencia de las métricas.

## Limpieza y consistencia de datos

Antes de generar las features se eliminan:

- Registros sin identificador de cliente.
- Cancelaciones o devoluciones.
- Cantidades menores o iguales a cero.
- Precios menores o iguales a cero.

Los valores nulos generados durante los cálculos se reemplazan por valores coherentes mediante `COALESCE`.

También se valida que el dataset final contenga una única fila por cliente.

## Estructura del repositorio

- `features_clientes.sql`: consulta SQL utilizada para generar las features.
- `README.md`: documentación del proyecto.
- `requirements.txt`: dependencias necesarias con versiones específicas.
- `.gitignore`: archivos y carpetas excluidos del repositorio.

## Tecnologías utilizadas

- Python
- Pandas
- DuckDB
- SQL
- Google Colab
- GitHub

## Resultado

El proceso genera un dataset con una fila por cliente y las principales variables de comportamiento necesarias para posteriores análisis o modelos de Machine Learning orientados a la predicción de churn.
