# Glue Job Setup Imports
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import *

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Glue Job Setup
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

############################################################
############### BRONZE LAYER TO SILVER LAYER ############### 
############################################################

# 1 - Read csv files from bronze-layer
rais = (
    spark
    .read
    .format("csv")
    .option("header", True)
    .option("inferSchema", True)
    .option("encoding", "latin1")
    .option("delimiter", ";")
    .load("s3://datalake-desafio-igti-caique-garcia-development/bronze-layer/")
)

# 2 - Rename only the usables columns
rais = (
    rais
    .withColumnRenamed('Município', 'municipio')
    .withColumnRenamed('Motivo Desligamento', 'motivo_desligamento')
    .withColumnRenamed('Faixa Hora Contrat', 'faixa_hora_contrat')
    .withColumnRenamed('Qtd Hora Contr', 'qtd_hora_contr')
    .withColumnRenamed('Sexo Trabalhador', 'sexo_trabalhador')
    .withColumnRenamed('CNAE 2.0 Classe', 'cnae_2_0_classe')
    .withColumnRenamed('Vl Remun Média Nom', 'vlr_remun_media_nom')
    .withColumnRenamed('Vl Remun Média (SM)', 'vlr_remun_media_sm')
)

# 3 - Replace "," to "." before converting to float
rais = (
    rais
    .withColumn("vlr_remun_media_nom", regexp_replace("vlr_remun_media_nom", ',', '.'))
    .withColumn("vlr_remun_media_sm", regexp_replace("vlr_remun_media_sm", ',', '.'))
)

# 4 - Select only the usables columns
rais = (
    rais.select(
        col('municipio'),
        col('motivo_desligamento'),
        col('faixa_hora_contrat').cast("double"),
        col('qtd_hora_contr').cast("double"),
        col('sexo_trabalhador'),
        col('cnae_2_0_classe'),
        col('vlr_remun_media_nom').cast("double"),
        col('vlr_remun_media_sm').cast("double")
    )
)

# 5 - Create column "uf" from column "municipio"
rais = (
    rais
    .withColumn(
        'uf',
        col('municipio').cast("string").substr(1,2).cast("int")
    )
)
    
# 6 - Write parquet files on silver-layer
(
    rais
    .write
    .mode("overwrite")
    .format("parquet")
    .save("s3://datalake-desafio-igti-caique-garcia-development/silver-layer/")
)

############################################################
############################################################
############################################################
    
# Job commit
job.commit()