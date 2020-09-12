# Can you make big money on Chinese stock IPO?

**Author**: [Spark Tseung](https://sparktseung.com)

**Source Code**: [github](https://github.com/sparktseung/Chinese-IPO) 

**Last Modified**: Sept 12, 2020

## Introduction

About two years ago, I started to have some extra money for investing. After a few trial-and-errors, I have resorted to regular purchase of a low-fee Exchange Traded Fund (ETF) tracking the US market index - the cost of "beating the market" just seems too high, and an average of 7~8% per year is already a very decent return.

I have been all content with that until a friend of mine mentioned the unbelievably high return on purchasing the Initial Public Offerings (IPO) of Chinese stocks. He claimed that, if you are lucky enough to be assigned some units during an IPO, the return on the first day of public trading is quite significant (e.g. 100%+). However, it is generally quite difficult to obtain those IPOs in the first place, so it is almost like buying a lottery.

![png](Chinese-IPO_files/chat.png)

Unfamiliar with, and intentially staying away from, the Chinese stock market, I was quite suspicious at first, but a quick search on the Internet has my confidence shaken. Therefore, being a student in statistics, I naturally started to dig into a pool of data, trying to find out if one can make some big money from Chinese stock IPOs. More specifically, I would like to see if one can make profits by obtaining stocks from IPOs and then selling them shortly after the public trading starts.

## Getting the data

There are not a lot of data sources available for the issue prices of IPOs in the Chinese market. The best I can find is the `akshare` package in Python, which in turn pulls IPO data from [eastmoney](http://data.eastmoney.com/xg/xg/dxsyl.html), a Chinese stock broker. They have three datasets of IPO, `sh` for (mostly) bluechip stocks traded on the Shanghai Stock Exchange, and `zxb`/`cyb` for smaller companies traded on the Shenzhen Stock Exchange.


```python
# Load required packages
import akshare as ak
import numpy as np
import pandas as pd
import datetime as dt
import matplotlib.pyplot as plt
%matplotlib inline
```


```python
# IPO data for stocks traded on Shanghai Stock Exchange
# Mostly blue-chip stocks
ipo_shzb_df = ak.stock_em_dxsyl(market="上海主板")
# IPO data for stocks traded on Shenzhen Stock Exchange
# Mostly smaller companies
ipo_szzx_df = ak.stock_em_dxsyl(market="中小板")
ipo_szcy_df = ak.stock_em_dxsyl(market="创业板")
```

    100%|██████████| 15/15 [00:07<00:00,  2.11it/s]
    100%|██████████| 13/13 [00:05<00:00,  2.42it/s]
    100%|██████████| 17/17 [00:07<00:00,  2.34it/s]
    

The first few rows of the data set are shown below. A quick view of the website tells that they have IPO data starting from year 2010. I will combine the three datasets, and change the column names in English. Since the datasets are frequently updated, we will focus on the decade of 2010-2019 only.


```python
ipo_shzb_df.head(3)
```




<div style="overflow-x:scroll">
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>股票代码</th>
      <th>股票简称</th>
      <th>发行价</th>
      <th>最新价</th>
      <th>网上发行中签率</th>
      <th>网上有效申购股数</th>
      <th>网上有效申购户数</th>
      <th>网上超额认购倍数</th>
      <th>网下配售中签率</th>
      <th>网下有效申购股数</th>
      <th>网下有效申购户数</th>
      <th>网下配售认购倍数</th>
      <th>总发行数量</th>
      <th>开盘溢价</th>
      <th>首日涨幅</th>
      <th>打新收益</th>
      <th>上市日期</th>
      <th>市场</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>605358</td>
      <td>N立昂微</td>
      <td>4.92</td>
      <td>7.08</td>
      <td>0.03197</td>
      <td>114224888000</td>
      <td>15990041</td>
      <td>3127.56</td>
      <td>0.00446855</td>
      <td>90812500000</td>
      <td>9112</td>
      <td>22378.63</td>
      <td>40580000</td>
      <td>0.1992</td>
      <td>0.4390</td>
      <td></td>
      <td>2020-09-11</td>
      <td>sh</td>
    </tr>
    <tr>
      <th>1</th>
      <td>605009</td>
      <td>N豪悦</td>
      <td>62.26</td>
      <td>89.65</td>
      <td>0.02382</td>
      <td>100758868000</td>
      <td>15783007</td>
      <td>4197.76</td>
      <td>0.01456494</td>
      <td>18311100000</td>
      <td>9316</td>
      <td>6865.8</td>
      <td>26670000</td>
      <td>0.2000</td>
      <td>0.4399</td>
      <td></td>
      <td>2020-09-11</td>
      <td>sh</td>
    </tr>
    <tr>
      <th>2</th>
      <td>605003</td>
      <td>众望布艺</td>
      <td>25.75</td>
      <td>31.38</td>
      <td>0.02346</td>
      <td>84382582000</td>
      <td>15347203</td>
      <td>4261.75</td>
      <td>0.01675539</td>
      <td>13130100000</td>
      <td>8208</td>
      <td>5968.23</td>
      <td>22000000</td>
      <td>0.4400</td>
      <td>0.4400</td>
      <td>0.01</td>
      <td>2020-09-08</td>
      <td>sh</td>
    </tr>
  </tbody>
</table>
</div>




```python
# Combine three datasets
ipo_df = pd.concat([ipo_shzb_df, ipo_szzx_df, ipo_szcy_df], ignore_index = True, sort = False)
# Rename columns in English
ipo_df.rename(columns={"股票代码": "ticker", "股票简称": "name",
                       "发行价": "price_issue", "最新价": "price_latest",
                       "网上发行中签率": "prob_online", "网上有效申购股数": "sub_size_online",
                       "网上有效申购户数": "subs_online","网上超额认购倍数": "over_online",
                       "网下配售中签率": "prob_offline", "网下有效申购股数": "sub_size_offline",
                       "网下有效申购户数": "subs_offline","网下配售认购倍数": "over_offline",
                       "总发行数量": "size_total", 
                       "开盘溢价": "list_premium", "首日涨幅": "return_firstday", 
                       "打新收益": "return_ipo", 
                       "上市日期": "list_date", "市场": "market"
                       }, inplace = True)
# The raw data are not in numeric
for i in range(2, 15):
    ipo_df.iloc[:, i] = pd.to_numeric(ipo_df.iloc[:, i])
# Filter by date: 2010-2019
ipo_df['list_date'] = pd.to_datetime(ipo_df['list_date'])
drop_idx = ipo_df[ (ipo_df['list_date'] > dt.datetime(2019, 12, 31)) ].index
ipo_df.drop(drop_idx , inplace = True)
ipo_df.dropna(inplace = True)
```

The combined and cleaned data set has 1942 records, and the variables are described as follows.

| Chinese          | English          | Description                                                                               |
|:------------------|:------------------|:-------------------------------------------------------------------------------------------|
| 股票代码         | ticker           | Ticker of the stock                                                                       |
| 股票简称         | name             | Name of the company                                                                       |
| 发行价           | price_issue      | Issue price (in CNY) of IPO, i.e. how much you pay per share before it goes public        |
| 最新价           | price_latest     | Latest trading price (in CNY)                                                             |
| 网上发行中签率   | prob_online      | Probability (in %) of successfully getting some IPO stocks, online application            |
| 网上有效申购股数 | sub_size_online  | Number of shares requested by potential IPO buyers, online application                    |
| 网上有效申购户数 | subs_online      | Number of potential IPO buyers, online application                                        |
| 网上超额认购倍数 | over_online      | How many people are competing for one successful online application, i.e. 1/prob_online   |
| 网下发行中签率   | prob_offline     | Probability (in %) of successfully getting some IPO stocks, offline application           |
| 网下有效申购股数 | sub_size_offline | Number of shares requested by potential IPO buyers, offline application                   |
| 网下有效申购户数 | subs_offline     | Number of potential IPO buyers, offline application                                       |
| 网下超额认购倍数 | subs_offline     | How many people are competing for one successful offline application, i.e. 1/prob_offline |
| 总发行数量       | size_total       | Total number of shares issued in IPO                                                      |
| 开盘溢价         | list_premium     | Premium (in decimal) of first-day trading, i.e. (first-day price / IPO price) - 1         |
| 首日涨幅         | return_firstday  | Price increase (in decimal) of first-day trading, i.e. (close/open) - 1 on the first day  |
| 打新收益         | return_ipo       | Return on IPO (according to some formula by eastmoney)                                    |
| 上市日期         | list_date        | Date of IPO                                                                               |
| 市场             | market           | Market of IPO                                                                             |

## A first look at the data

Let's have a look at one particular stock with ticker number 603109, which was first publicly traded on the Shanghai Stock Exchange (`market`) on the last day of 2019 (`list_date`). Before that, you can buy it at 18.38 per share (`price_issue`) by making an application, and its latest trading price is 26.48 (`price_latest`).

An average investor can get involved in its IPO through either online or offline application. For online applications, there are 12,131,674 potential subscribers who files an application (`subs_online`), and they are interested in buying 93,892,836,000 shares in total (`sub_size_online`). However, the demand is much higher than the supply, since it turns out that only 0.03515% of them (`prob_online`) actually ended up successfully getting some shares. In other words, the odds of a successful application is 1 to 2,284.98 (`over_online`). The same set of numbers for offline application are also provided. Despite a large number of interested investors, only 36,670,000 shares (`size_total`) were eventually issued.

For those who managed to get some IPO shares, they were in for a lucky treat. On the first day of trading, the stock opens at a premium of 20.02% (`list_premium`), or 22.06 per share, and it closed 44.02% (`return_firstday`) above the IPO price. The variable `return_ipo` is calculated by the eastmoney website according to their formula, so I will ignore it for the moment.


```python
ipo_df.head(1)
```




<div style="overflow-x:scroll">
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>ticker</th>
      <th>name</th>
      <th>price_issue</th>
      <th>price_latest</th>
      <th>prob_online</th>
      <th>sub_size_online</th>
      <th>subs_online</th>
      <th>over_online</th>
      <th>prob_offline</th>
      <th>sub_size_offline</th>
      <th>subs_offline</th>
      <th>over_offline</th>
      <th>size_total</th>
      <th>list_premium</th>
      <th>return_firstday</th>
      <th>return_ipo</th>
      <th>list_date</th>
      <th>market</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>54</th>
      <td>603109</td>
      <td>神驰机电</td>
      <td>18.38</td>
      <td>26.48</td>
      <td>0.03515</td>
      <td>93892836000</td>
      <td>12131674</td>
      <td>2844.98</td>
      <td>0.011563</td>
      <td>31714300000</td>
      <td>7312</td>
      <td>8648.57</td>
      <td>36670000</td>
      <td>0.2002</td>
      <td>0.4402</td>
      <td>0.03</td>
      <td>2019-12-31</td>
      <td>sh</td>
    </tr>
  </tbody>
</table>
</div>



## How hard is it to get some IPO shares?

Just after a first glance, we can already tell the probability of succesfully getting IPO shares is quite low. Let's look at a number of summary statistics and do some plotting.


```python
# Aggregate online and offline successful rate
ipo_df['prob_all'] = ( ipo_df['prob_online'] * ipo_df['subs_online'] + ipo_df['prob_offline'] * ipo_df['subs_offline'] ) / (ipo_df['subs_online'] + ipo_df['subs_offline'] )
```


```python
# Summary: online
ipo_df['prob_online'].describe()
```




    count    1942.000000
    mean        0.715079
    std         2.146782
    min         0.011570
    25%         0.031745
    50%         0.299550
    75%         0.730685
    max        65.520840
    Name: prob_online, dtype: float64




```python
# SummaryL offline
ipo_df['prob_offline'].describe()
```




    count    1942.000000
    mean        3.509657
    std         8.398939
    min         0.000000
    25%         0.010545
    50%         0.102908
    75%         2.691333
    max       100.000000
    Name: prob_offline, dtype: float64




```python
# Summary: overall
ipo_df['prob_all'].describe()
```




    count    1942.000000
    mean        0.715482
    std         2.147102
    min         0.011570
    25%         0.031740
    50%         0.299567
    75%         0.731566
    max        65.508859
    Name: prob_all, dtype: float64



There are obviously some outliers, we will exclude those from our the plots. Overall, the success probabilty is overwhelmingly low. The vast majority of online applications would be uncessessful, while the odds are better in some offline cases. For an average investor, I'd consider getting a successful application as a rare event.


```python
plt.hist(x = ipo_df['prob_online'], bins = 100, range = (0, 6));
plt.title('Histogram of Success Probability (%), Online');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_18_0.svg)
    



```python
plt.hist(x = ipo_df['prob_offline'], bins = 100, range = (0, 20));
plt.title('Histogram of Success Probability (%), Offline');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_19_0.svg)
    



```python
plt.hist(x = ipo_df['prob_all'], bins = 100, range = (0, 15));
plt.title('Histogram of Success Probability (%), Overall');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_20_0.svg)
    


## An unexpected lesson of history

Out of curiosity, I also plotted the probabilities against the listing date of stocks. There are two noticeable gaps without any new IPO: the entire year of 2013 and the end of 2015.


```python
plt.plot_date(ipo_df['list_date'], ipo_df['prob_online'], marker = '.');
plt.title('Trend of Success Probability (%), Online');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_22_0.svg)
    



```python
plt.plot_date(ipo_df['list_date'], ipo_df['prob_offline'], marker = '.');
plt.title('Trend of Success Probability (%), Offline');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_23_0.svg)
    



```python
plt.plot_date(ipo_df['list_date'], ipo_df['prob_all'], marker = '.');
plt.title('Trend of Success Probability (%), Overall');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_24_0.svg)
    


I suspect this might be due to the *[socialist charasteristics](https://en.wikipedia.org/wiki/Socialism_with_Chinese_characteristics)* (社会主义特色) of the Chinese capital market. After a bit of search on the Internet, I have learned a bit about the history of the Chinese stock market.

According to some news reports ([1](https://stock.gucheng.com/201606/3173448_2.shtml) and [2](http://finance.sina.com.cn/stock/y/20150704/195622592273.shtml)), there have been 9 halts of IPO in the past. What we see in the plots above are the latest two occurences.
* Nov 16, 2012 ~ Dec 30, 2013: The Chinese stock market has been declining for 3 years in a row, while western countries are recovering from the 2008 financial crisis (see [this chart of comparison](http://schrts.co/AxGcQBMZ)). The government decides to halt IPO, although there is no official statement of the rationales behind (I can't really see why).
* July 4, 2015 ~ Nov 6, 2015: The Shanghai Composite Index has dropped around 25% in just 20 days (see [this chart](http://schrts.co/RJeAxkFc)). The government halts all IPOs in an attempt to boost the market (again, I don't see why they think this would work).

There were more halts prior to these two (e.g. as you might have guessed, there was one during the financial crisis). While I will not delve into the details here, they are certainly quite interesting to read about. Such historical facts also shed lights on the influence of the government on the Chinese financial market, which contrasts the relatively freer markets in the west.

You might also have noticed that the success probabilities appear significantly lower after year 2014. I have not quite figured out why, even after a lot of search on the Internet. Never mind - I will just let this slip by and assume it probably also have something to do with government intervention. The key takeaway is that **getting shares from Chinese IPOs can be effectively considered as a rare event only for the luckiest few**. 

## Are Chinese IPOs profitable?

Now let's turn to profitability, which is actually more important. Let's assume an IPO investors sells all shares at the closing price on the first day of public trading. I will conduct the same set of analysis as above. It seems that most IPOs will generate quite attractive returns on the first day of trading. Meanwhile, there could also be a sizable loss of 20%.


```python
# Summary: return
ipo_df['return_firstday'].describe()
```




    count    1942.000000
    mean        0.394821
    std         0.270328
    min        -0.231600
    25%         0.364350
    50%         0.439900
    75%         0.440200
    max         6.267400
    Name: return_firstday, dtype: float64




```python
plt.hist(x = ipo_df['return_firstday'], bins = 100, range = (-0.5, 3));
plt.title('Histogram of First-Day Return');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_31_0.svg)
    


There is a peak around 40% of return. The following plot of `return_firstday` against `list_date` reveals a noticeable pattern: the "magic" number of return is 44%, and almost all of them occur starting from 2014.


```python
plt.plot_date(ipo_df['list_date'], ipo_df['return_firstday'], marker = '.');
plt.title('Trend of First-Day Return');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_33_0.svg)
    



```python
ipo_df['return_firstday'].mode()
```




    0    0.44
    dtype: float64



Again, this is due to a policy implemented by the government (see [here](https://stock.gucheng.com/201906/3742608.shtml)): trading for an IPO stock is halted after an increase of 44% (or a decrease of 36%, albeit not present in this data set) within a single day.

With this in mind, let's see which are the best-performing IPOs of the decade (obviously, they are all pre-2014). The following stocks will double the initial investment (displayed from highest to lowest return).


```python
goodstock = ipo_df[ ipo_df['return_firstday'] >=1 ]
with pd.option_context('display.max_rows', None, 'display.max_columns', goodstock.shape[1]):
    print(goodstock[['ticker', 'name', 'return_firstday']].sort_values(by = ['return_firstday'], ascending = False))
```

    	  ticker  name      return_firstday
    982   002703  浙江世宝           6.2674
    1264  002388  新亚制程           2.7533
    1191  002468  申通快递           2.3504
    613   603993  洛阳钼业           2.2100
    1947  300239  东宝生物           1.9889
    1159  002507  涪陵榨菜           1.9164
    1199  002460  赣锋锂业           1.8599
    1198  002461  珠江啤酒           1.7724
    1193  002466  天齐锂业           1.7683
    1263  002389  航天彩虹           1.7267
    1268  002384  东山精密           1.6758
    1144  002524  光正集团           1.6153
    2078  300106  西部牧业           1.5193
    1075  002600  领益智造           1.4938
    1269  002383  合众思壮           1.4730
    1948  300238  冠昊生物           1.4676
    626   603002  宏昌电子           1.3778
    1311  002338  奥普光电           1.3636
    1274  002378  章源钨业           1.3046
    2068  300116  坚瑞沃能           1.2788
    1052  002624  完美世界           1.2393
    1154  002514  宝馨科技           1.2304
    1189  002471  中超控股           1.2162
    2075  300109   新开源           1.2000
    2112  300070   碧水源           1.2000
    2082  300101  振芯科技           1.1847
    1913  300272  开能健康           1.1826
    685   601177  杭齿前进           1.1785
    1288  002364  中恒电气           1.1655
    1265  002387   维信诺           1.1459
    1195  002464  众应互联           1.0774
    1284  002368  太极股份           1.0762
    1077  002598  山东章鼓           1.0590
    617   603766  隆鑫通用           1.0304
    1230  002428  云南锗业           1.0200
    

Meanwhile, the following stocks will yield some loss on the first day (displayed from worst return to slighly better ones). I have to say, there are not quite a lot of them.


```python
badstock = ipo_df[ ipo_df['return_firstday'] <=0]
with pd.option_context('display.max_rows', None, 'display.max_columns', badstock.shape[1]):
    print(badstock[['ticker', 'name', 'return_firstday']].sort_values(by = ['return_firstday'], ascending = True))
```

    	  ticker  name     return_firstday
    664   601258  ST庞大          -0.2316
    1028  002651  利君股份          -0.1688
    2020  300165  天瑞仪器          -0.1668
    1881  300305  裕兴股份          -0.1650
    1906  300281  金明精机          -0.1576
    1096  002577  雷柏科技          -0.1555
    1849  300337  银邦股份          -0.1480
    674   601700  风范股份          -0.1440
    2018  300167   迪威迅          -0.1420
    1131  002540  亚太科技          -0.1375
    1880  300307  慈星股份          -0.1366
    2019  300166  东方国信          -0.1339
    658   601566   九牧王          -0.1305
    1132  002539  云图控股          -0.1263
    2017  300168  万达信息          -0.1214
    1062  002614   奥佳华          -0.1192
    1090  002583   海能达          -0.1181
    1976  300209  天泽信息          -0.1179
    1088  002585  双星新材          -0.1145
    663   601218  吉鑫科技          -0.1124
    1086  002588   史丹利          -0.1123
    1031  002648  卫星石化          -0.1088
    1833  300351  永贵电器          -0.1077
    1907  300280  紫天科技          -0.1018
    1100  002572   索菲亚          -0.1000
    2101  300082  奥克股份          -0.0991
    1972  300213  佳讯飞鸿          -0.0986
    1879  300306  远方信息          -0.0973
    993   002690  美亚光电          -0.0971
    1013  002667  鞍重股份          -0.0948
    1029  002649  博彦科技          -0.0941
    622   601339  百隆东方          -0.0934
    1097  002576  通达动力          -0.0921
    999   002685  华东重机          -0.0911
    1973  300212   易华录          -0.0906
    1057  002620  瑞和股份          -0.0893
    1093  002580  圣阳股份          -0.0888
    1842  300344  太空智造          -0.0887
    645   601633  长城汽车          -0.0885
    988   002695   煌上煌          -0.0883
    646   601677  明泰铝业          -0.0870
    656   601010  文峰股份          -0.0830
    1099  002573  清新环境          -0.0829
    983   002702  海欣食品          -0.0800
    1133  002538   司尔特          -0.0792
    998   002682  龙洲股份          -0.0792
    1030  002647  仁东控股          -0.0781
    623   601965  中国汽研          -0.0756
    1245  002408  齐翔腾达          -0.0755
    1990  300195  长荣股份          -0.0745
    1980  300205  天喻信息          -0.0740
    1954  300232  洲明科技          -0.0738
    1236  002419  天虹股份          -0.0735
    1107  002563  森马服饰          -0.0730
    630   603001  奥康国际          -0.0725
    670   601799  星宇股份          -0.0711
    1977  300208  青岛中程          -0.0700
    620   603008   喜临门          -0.0672
    625   603366  日出东方          -0.0670
    1128  002543  万和电气          -0.0657
    1130  002541  鸿路钢构          -0.0656
    1247  002406  远东传动          -0.0643
    1845  300342  天银机电          -0.0635
    619   603077  和邦生物          -0.0617
    632   601012  隆基股份          -0.0595
    1963  300223  北京君正          -0.0591
    2100  300083   创世纪          -0.0567
    657   601311  骆驼股份          -0.0565
    2097  300086  康芝药业          -0.0562
    644   601996  丰林集团          -0.0550
    1101  002571  德力股份          -0.0545
    655   601567  三星医疗          -0.0545
    1014  002665  首航高科          -0.0541
    1213  002444  巨星科技          -0.0534
    1861  300324  旋极信息          -0.0522
    1856  300329  海伦钢琴          -0.0519
    1217  002440  闰土股份          -0.0513
    1961  300225   金力泰          -0.0507
    1246  002407   多氟多          -0.0503
    1981  300204   舒泰神          -0.0501
    1971  300214  日科化学          -0.0500
    1027  002653   海思科          -0.0490
    1058  002616  长青集团          -0.0472
    673   601137  博威合金          -0.0463
    1987  300198  纳川股份          -0.0458
    1991  300194  福安药业          -0.0423
    662   601113  ST华鼎          -0.0414
    2025  300160  秀强股份          -0.0406
    1112  002559  亚威股份          -0.0400
    1844  300338  开元股份          -0.0400
    691   601000   唐山港          -0.0390
    1992  300193  佳士科技          -0.0374
    1860  300327  中颖电子          -0.0368
    1009  002672  东江环保          -0.0360
    2015  300170  汉得信息          -0.0359
    1964  300222  科大智能          -0.0355
    686   601018   宁波港          -0.0351
    1841  300345  华民股份          -0.0343
    2094  300080  易成新能          -0.0325
    697   601106  中国一重          -0.0316
    1216  002441   众业达          -0.0306
    1986  300199  翰宇药业          -0.0295
    1129  002542  中化岩土          -0.0292
    1003  002676  顺威股份          -0.0272
    1059  002617  露笑科技          -0.0250
    1083  002591  恒大高新          -0.0250
    1238  002416   爱施德          -0.0244
    2000  300185  通裕重工          -0.0244
    1243  002410   广联达          -0.0226
    1864  300325  德威新材          -0.0218
    1211  002414  高德红外          -0.0204
    1903  300284   苏交科          -0.0195
    1249  002404  嘉欣丝绸          -0.0191
    1301  002348  高乐股份          -0.0187
    699   601179  中国西电          -0.0139
    1965  300221  银禧科技          -0.0133
    1921  300263  隆华科技          -0.0130
    1877  300309  吉艾科技          -0.0065
    2089  300094  国联水产          -0.0063
    1865  300323  华灿光电          -0.0040
    1214  002443  金洲管道          -0.0018
    1102  002570   贝因美          -0.0005
    

Let's also take a look at the movement of the first-day price by plotting `return_firstday` against `list_premium`. The pattern is quite clear: if a stock opens above its IPO price, most likely it will close even higher on the first day of trading (points above the red line).


```python
plt.scatter(ipo_df['list_premium'], ipo_df['return_firstday'], marker = '.');
plt.axline((0, 0), (1, 1), linewidth=2, color='r');
plt.title('Firstday Close Return vs. Firstday Open Return');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_41_0.svg)
    


Finally, we will plot `return_firstday` against the IPO price `price_issue` and total value of issued shares `price_issue * size_total`, i.e. the market capitalization. It seems that exceptional first-day returns are mostly generated by cheaper stocks / small-cap companies.


```python
plt.scatter(ipo_df['price_issue'], ipo_df['return_firstday'], marker = '.');
plt.title('Firstday Close Return vs. IPO Price');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_43_0.svg)
    



```python
plt.scatter(ipo_df['price_issue']*ipo_df['size_total'], ipo_df['return_firstday'], marker = '.');
plt.title('Firstday Close Return vs. Market Cap');
```


    
![svg](Chinese-IPO_files/Chinese-IPO_44_0.svg)
    


The message is that **IPOs are quite profitable even if you sell it only on the first day of trading**. Anecdotal internet posts also suggest that, if the stock increases 44% on the first day, the following few trading days are very likely to be also bullish. This initial momentum certainly makes IPOs in the Chinese stock market extremely attrative, rendering them effectively "free lottery tickets" (since you will most likely end up with good profits). No wonder so many investors flock to IPOs as soon as those announcements come out! 

## Final remarks

Even though this is not a rich data set, there are certainly a lot of interesting questions to explore. For example:
* What are the 7-day, 1-year and up-to-date return of these stocks since IPO? Are people just speculating on the initial buying craze? How many of these stocks are really suitable for long-term investment?
* How about stock IPOs on the US market? I know it's a free market, and I have seen quite a number of IPOs that just drop and drop since the very first day of trading. It is definitely interesting to make a comparison between these two vastly different markets.
* Just a simple data analysis like this reveals the influence of governmemt regulations on the stock market. It could be interesting to qualitatively examine this topic (but this is beyond my strong suit).
* Unfortunately , we don't have access to more granular data sets, e.g. the size of each individual IPO application. With richer information, a more interesting study could be conducted.

Still, the simple analyses above have already answered my initial questions: **Yes, IPOs in the Chinese stock market are likely to bring you good money, but you are unlikely to get a chance in the first place** - the good old rule of supply and demand!
