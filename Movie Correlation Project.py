#!/usr/bin/env python
# coding: utf-8

# In[1]:


#Import libraries

import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] =(12,8) #Adjusts the configuration of the plots we will create

#Read in the data

df= pd.read_csv(r'C:\Users\Bini\Downloads\movies.csv')


# In[2]:


# Let's look at the data

df.head()


# In[3]:


# Let's see if there is any missing data

for col in df.columns:
    pct_missing= np.mean(df[col].isnull())
    print('{} - {}%' .format(col,pct_missing))


# In[4]:


# Data types for our columns

df.dtypes


# In[5]:


# Change data type of columns

df['budget'] =df['budget'].fillna(0).astype('int64')

df['gross'] = df['gross'].fillna(0).astype('int64')


# In[19]:


df


# In[6]:


# Create correct year column

df['yearcorrect'] = df['released'].astype(str).str.split(',').str[-1].astype(str).str[:5]

df


# In[7]:


df = df.sort_values(by=['gross'],inplace = False,ascending =False)


# In[8]:


pd.set_option('display.max_rows',None)


# In[9]:


# Drop any duplicates

df['company'].drop_duplicates().sort_values(ascending=False)


# In[10]:


# Scatter plot with budget vs gross
  
plt.scatter(x=df['budget'],y=df['gross'])

plt.title('Budget vs Gross Earnings')

plt.xlabel('Gross Earnings')

plt.ylabel('Budget for Film')
plt.show ()


# In[11]:


df.head()


# In[12]:


# Plot budget vs gross using seaborn

sns.regplot(x='budget', y='gross', data=df,scatter_kws = {"color": "red"},line_kws={"color":"blue"})


# In[24]:


# Let's start looking at correlation


# In[13]:


df.corr(method ='pearson' ) #pearson, kendall, spearman


# In[30]:


#High correlation between budget and gross
# black = low correlation, bright color= high correlation


# In[14]:


correlation_matrix = df.corr(method ='pearson')

sns.heatmap(correlation_matrix, annot = True)

plt.title('Correlation Matrix for Numeric Feature')

plt.xlabel('Movie Features')

plt.ylabel('Movie Features')

plt.show ()


# In[15]:


# Looks at company

df.head()


# In[16]:


#Numerized

df_numerized = df 

for col_name in df_numerized.columns :
    if(df_numerized[col_name].dtype == 'object') :
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name]= df_numerized[col_name].cat.codes
        
df_numerized
        


# In[37]:


df


# In[17]:


correlation_matrix = df.corr(method ='pearson')

sns.heatmap(correlation_matrix, annot = True)

plt.title('Correlation Matrix for Numeric Feature')

plt.xlabel('Movie Features')

plt.ylabel('Movie Features')

plt.show ()


# In[18]:


df_numerized.corr()


# In[19]:


correlation_mat = df_numerized.corr()

corr_pairs = correlation_mat.unstack()

corr_pairs


# In[20]:


sorted_pairs = corr_pairs.sort_values()

sorted_pairs


# In[21]:


high_corr = sorted_pairs [(sorted_pairs) > 0.5 ]

high_corr


# In[ ]:


# Votes and budget have the highest correlation to gross earnings
 

