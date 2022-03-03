#! /usr/bin/env python3
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import plotly.express as px
import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('-I','--input',required=True, help='path of input file')
parser.add_argument('-IS','--inputSamples',required=True, help='path of input file')
parser.add_argument('-O','--output',required=True, help='path of output (plots)')
parser.add_argument('-S','--seperator',default='\t',help='column separator of your input csv, default = ,')
parser.add_argument('-C','--color',default='Plotly', help='color pallette (plotly Discrete Colors, https://plotly.com/python/discrete-color/)')
parser.add_argument('-CC','--colourCol',required=True, help='column name which indicates the column which will be used to colercode the PCA-plot.\nif a comma separated list is pased the programm will create a plot for each element')
parser.add_argument('-D','--dimensions',default=2,help='indicates wheather a 3 or 3 dimensional plot is created (default = 2)')
parser.add_argument('-AC','--annotationColumnsCounts',default=None, help='comma separated list fo column names with annotations, not variabl data (default = None')
parser.add_argument('-A','--annotationColumns',default=None, help='comma separated list fo column names with annotations, not variabl data (default = None')
parser.add_argument('-N','--plotName', default='PCA',help='Plot title (default = PCA')
parser.add_argument('-SN','--sampleName',default=None, help='Column name with names of samples wich are used as lables for the dots of the PCA-plot (default = None')
parser.add_argument('-F','--figureType',default='png',help='File type of the plots in the output (Default = png)')

args = parser.parse_args()
data_path = args.input
sample_sheet = args.inputSamples
output_path = args.output
sep = args.seperator
color = args.color
colc = args.colourCol
dim = args.dimensions
annotations_counts = args.annotationColumnsCounts
annotations = args.annotationColumns
name = args.plotName
sample = args.sampleName
figureType = args.figureType


data = pd.read_csv(data_path,sep=sep,index_col=0)
data = data.drop(columns=annotations_counts)
data = data.transpose()
samplesheet = pd.read_csv(sample_sheet,sep=',')
print(samplesheet)
print(data)
data = pd.merge(data,samplesheet,left_index=True,right_on='sample',how='left')
data = data.drop_duplicates()
print(data)
print(annotations)

cols = list(data.columns)
targetList = colc.split(',')
if annotations == None:
    annotationsList = []
else:
    annotationsList = annotations.split(sep=',')


sampleList = [sample]
NotFeature = targetList+annotationsList+sampleList
features = [i for i in cols if i not in NotFeature]
targets = targetList
print(NotFeature)

print(colc)
x = data.loc[:, features].values
print(x)
x = np.where(np.isnan(x),0,x)
y = data.loc[:,targets].values

x = StandardScaler().fit_transform(x)

if int(dim) == 2:
    pca = PCA(n_components=2)
    principalComponents = pca.fit_transform(x)
    principalDf = pd.DataFrame(data = principalComponents, columns = ['principal component 1', 'principal component 2'])
    #print(principalComponents)
    #print(principalDf)
    
    if sample == None:
        finalDf = pd.concat([principalDf, data[targetList]], axis = 1)
        print(finalDf)
        for i in targetList:
            colorList = finalDf[f'{i}']
            colorList = [str(i) for i in colorList if str(i) != 'nan']
            print(colorList)
            fig = px.scatter(principalComponents, x = 0 , y = 1, color = colorList, \
                labels={'0': 'PC 1', '1': 'PC 2'}, color_discrete_sequence=getattr(px.colors.qualitative, color))
            fig.write_image(f'{output_path}{name}_{i}.{figureType}')
    else:
        finalDf = pd.concat([principalDf, data[targetList+[sample]]], axis = 1)
        for i in targetList:
            colorList = finalDf[f'{i}']
            colorList = [str(i) for i in colorList]
            fig = px.scatter(principalComponents, x = 0 , y = 1, color = colorList,\
                labels={'0': 'PC 1', '1': 'PC 2'},text=finalDf[sample], color_discrete_sequence=getattr(px.colors.qualitative, color))
            fig.write_image(f'{output_path}{name}_{i}.{figureType}')

elif int(dim) == 3:
    pca = PCA(n_components=3)
    principalComponents = pca.fit_transform(x)
    principalDf = pd.DataFrame(data = principalComponents, columns = ['principal component 1', 'principal component 2' , 'principal component 3'])
    if sample == None:
        finalDf = pd.concat([principalDf, data[targetList]], axis = 1)
        for i in targetList:
            colorList = finalDf[f'{i}']
            colorList = [str(i) for i in colorList]
            fig = px.scatter_3d(principalComponents, x = 0 , y = 1, z= 2, color = colorList,\
                labels={'0': 'PC 1', '1': 'PC 2', '2': 'PC 3'}, color_discrete_sequence=getattr(px.colors.qualitative, color))
            fig.write_image(f'{output_path}{name}_{i}.{figureType}')

    else:
        finalDf = pd.concat([principalDf, data[targetList+[sample]]], axis = 1)
        for i in targetList:
            colorList = finalDf[f'{i}']
            colorList = [str(i) for i in colorList]
            fig = px.scatter_3d(principalComponents, x = 0 , y = 1, z= 2, color = colorList,\
                labels={'0': 'PC 1', '1': 'PC 2', '2': 'PC 3'},text=finalDf[sample], color_discrete_sequence=getattr(px.colors.qualitative, color))
            fig.write_image(f'{output_path}{name}_{i}.{figureType}')

else:
    print(f'Error possible values vor -D, --dimensions are 2 and 3\nyou have selected {dim}')
    exit
