#!/usr/bin/env python
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import plotly.express as px
import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('-I','--input',required=True, help='path of input file (csv)')
parser.add_argument('-O','--output',required=True, help='path of output (plots)')
parser.add_argument('-S','--seperator',default=',',help='column separator of your input csv, default = ,')
parser.add_argument('-C','--color',default='Plotly', help='color pallette (plotly Discrete Colors, https://plotly.com/python/discrete-color/)')
parser.add_argument('-CC','--colourCol',required=True, help='column name which indicates the column which will be used to colercode the PCA-plot.\nif a comma separated list is pased the programm will create a plot for each element')
parser.add_argument('-D','--dimensions',default=2,help='indicates wheather a 3 or 3 dimensional plot is created (default = 2)')
parser.add_argument('-A','--annotationColumns',default=None, help='comma separated list fo column names with annotations, not variabl data (default = None')
parser.add_argument('-N','--plotName', default='PCA',help='Plot title (default = PCA')
parser.add_argument('-SN','--sampleName',default=None, help='Column name with names of samples wich are used as lables for the dots of the PCA-plot (default = None')
parser.add_argument('-F','--figureType',default='png',help='File type of the plots in the output (Default = png)')

args = parser.parse_args()
data_path = args.input
output_path = args.output
sep = args.seperator
color = args.color
colC = args.colourCol
dim = args.dimensions
Annotations = args.annotationColumns
name = args.plotName
sample = args.sampleName
figureType = args.figureType


data = pd.read_csv(data_path,sep=sep)
cols = list(data.columns)
targetList = colC.split(',')
if Annotations == None:
    AnnotationsList = []
else:
    AnnotationsList = Annotations.split(sep=',')
sampleList = [sample]
NotFeature = targetList+AnnotationsList+sampleList
features = [i for i in cols if i not in NotFeature]
targets = targetList

x = data.loc[:, features].values
x = np.where(np.isnan(x),0,x)
y = data.loc[:,targets].values
x = StandardScaler().fit_transform(x)

if int(dim) == 2:
    pca = PCA(n_components=2)
    principalComponents = pca.fit_transform(x)
    principalDf = pd.DataFrame(data = principalComponents, columns = ['principal component 1', 'principal component 2'])
    
    if sample == None:
        finalDf = pd.concat([principalDf, data[targetList]], axis = 1)
        for i in targetList:
            colorList = finalDf[f'{i}']
            colorList = [str(i) for i in colorList]
            fig = px.scatter(principalComponents, x = 0 , y = 1, color = colorList,labels={'0': 'PC 1', '1': 'PC 2'}, color_discrete_sequence=getattr(px.colors.qualitative, color))
            fig.write_image(f'{output_path}{name}_{i}.{figureType}')
    else:
        finalDf = pd.concat([principalDf, data[targetList+[sample]]], axis = 1)
        for i in targetList:
            colorList = finalDf[f'{i}']
            colorList = [str(i) for i in colorList]
            fig = px.scatter(principalComponents, x = 0 , y = 1, color = colorList,labels={'0': 'PC 1', '1': 'PC 2'},text=finalDf[sample], color_discrete_sequence=getattr(px.colors.qualitative, color))
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
            fig = px.scatter_3d(principalComponents, x = 0 , y = 1, z= 2, color = colorList,labels={'0': 'PC 1', '1': 'PC 2', '2': 'PC 3'}, color_discrete_sequence=getattr(px.colors.qualitative, color))
            fig.write_image(f'{output_path}{name}_{i}.{figureType}')

    else:
        finalDf = pd.concat([principalDf, data[targetList+[sample]]], axis = 1)
        for i in targetList:
            colorList = finalDf[f'{i}']
            colorList = [str(i) for i in colorList]
            fig = px.scatter_3d(principalComponents, x = 0 , y = 1, z= 2, color = colorList,labels={'0': 'PC 1', '1': 'PC 2', '2': 'PC 3'},text=finalDf[sample], color_discrete_sequence=getattr(px.colors.qualitative, color))
            fig.write_image(f'{output_path}{name}_{i}.{figureType}')

else:
    print(f'Error possible valuse vor -D, --dimensions are 2 and 3\nyou have selected {dim}')
    exit


