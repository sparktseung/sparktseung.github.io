# Can you make big money on Chinese stock IPO?

**Author**: [Spark Tseung](https://sparktseung.com)

**Source Code**: [github](https://github.com/sparktseung/Chinese-IPO) 

**Last Modified**: Sept 12, 2020

## Introduction

About two years ago, I started to have some extra money for investing. After a few trial-and-errors, I have resorted to regular purchase of a low-fee Exchange Traded Fund (ETF) tracking the US market index - the cost of "beating the market" just seems too high, and an average of 7~8% per year is already a very decent return.

I have been all content with that until a friend of mine mentioned the unbelievably high return on purchasing the Initial Public Offerings (IPO) of Chinese stocks. He claimed that, if you are lucky enough to be assigned some units during an IPO, the return on the first day of public trading is quite significant (e.g. 100%+). However, it is generally quite difficult to obtain those IPOs in the first place, so it is almost like buying a lottery.

Unfamiliar with, and intentially staying away from, the Chinese stock market, I was quite suspicious at first, but a quick search on the Internet has my confidence shaken. Therefore, being a student in statistics, I naturally started to dig into a pool of data, trying to find out if one can make some big money from Chinese stock IPOs. More specifically, I would like to see if one can make profits by obtaining stocks from IPOs and then selling them shortly after the public trading starts.

## Getting the data

There are not a lot of data source available for the issue prices of IPOs in the Chinese market. The best I can find is the `akshare` package in Python, which in turn pulls IPO data from [eastmoney](http://data.eastmoney.com/xg/xg/dxsyl.html), a Chinese stock broker. They have three datasets of IPO, `sh` for (mostly) bluechip stocks traded on the Shanghai Stock Exchange, and `zxb`/`cyb` for smaller companies traded on the Shenzhen Stock Exchange.


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
    

The first few rows of the data set are shown below. After a quick view of the website tells that they have IPO data starting from year 2010. I will combine the three datasets, and change the column names in English. Since the datasets are frequently updated, we will focus on the decade of 2010-2019 only.


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




```python
plt.hist(x = ipo_df['prob_online'], bins = 100, range = (0, 10))
```




    (array([840.,  53.,  80., 110., 123., 115., 105.,  69.,  56.,  45.,  40.,
             25.,  31.,  20.,  26.,  20.,  14.,  14.,  12.,   7.,  15.,   6.,
             15.,   9.,   9.,   9.,   2.,   5.,   5.,   2.,   3.,   4.,   2.,
              1.,   2.,   1.,   2.,   1.,   0.,   2.,   0.,   1.,   0.,   1.,
              1.,   0.,   1.,   0.,   2.,   1.,   0.,   0.,   0.,   0.,   0.,
              1.,   0.,   1.,   1.,   1.,   1.,   1.,   0.,   1.,   1.,   0.,
              0.,   0.,   0.,   0.,   0.,   1.,   1.,   1.,   0.,   1.,   0.,
              0.,   1.,   0.,   1.,   1.,   0.,   1.,   0.,   0.,   0.,   1.,
              1.,   1.,   0.,   0.,   1.,   0.,   0.,   1.,   2.,   0.,   0.,
              0.]),
     array([ 0. ,  0.1,  0.2,  0.3,  0.4,  0.5,  0.6,  0.7,  0.8,  0.9,  1. ,
             1.1,  1.2,  1.3,  1.4,  1.5,  1.6,  1.7,  1.8,  1.9,  2. ,  2.1,
             2.2,  2.3,  2.4,  2.5,  2.6,  2.7,  2.8,  2.9,  3. ,  3.1,  3.2,
             3.3,  3.4,  3.5,  3.6,  3.7,  3.8,  3.9,  4. ,  4.1,  4.2,  4.3,
             4.4,  4.5,  4.6,  4.7,  4.8,  4.9,  5. ,  5.1,  5.2,  5.3,  5.4,
             5.5,  5.6,  5.7,  5.8,  5.9,  6. ,  6.1,  6.2,  6.3,  6.4,  6.5,
             6.6,  6.7,  6.8,  6.9,  7. ,  7.1,  7.2,  7.3,  7.4,  7.5,  7.6,
             7.7,  7.8,  7.9,  8. ,  8.1,  8.2,  8.3,  8.4,  8.5,  8.6,  8.7,
             8.8,  8.9,  9. ,  9.1,  9.2,  9.3,  9.4,  9.5,  9.6,  9.7,  9.8,
             9.9, 10. ]),
     <BarContainer object of 100 artists>)




    
![svg](Chinese-IPO_files/Chinese-IPO_17_1.svg)
    



```python
ipo_df.head()
```




<div>
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
      <th>prob_all</th>
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
      <td>0.035136</td>
    </tr>
    <tr>
      <th>55</th>
      <td>603995</td>
      <td>甬金股份</td>
      <td>22.52</td>
      <td>33.26</td>
      <td>0.04462</td>
      <td>116334072000</td>
      <td>11366524</td>
      <td>2241.37</td>
      <td>0.012767</td>
      <td>45171000000</td>
      <td>6986</td>
      <td>7832.67</td>
      <td>57670000</td>
      <td>0.1998</td>
      <td>0.4401</td>
      <td>0.02</td>
      <td>2019-12-24</td>
      <td>sh</td>
      <td>0.044600</td>
    </tr>
    <tr>
      <th>56</th>
      <td>601512</td>
      <td>中新集团</td>
      <td>9.67</td>
      <td>11.56</td>
      <td>0.08831</td>
      <td>152755117000</td>
      <td>11257993</td>
      <td>1132.35</td>
      <td>0.039017</td>
      <td>38416500000</td>
      <td>6439</td>
      <td>2562.98</td>
      <td>149890000</td>
      <td>0.1996</td>
      <td>0.4395</td>
      <td>0.06</td>
      <td>2019-12-20</td>
      <td>sh</td>
      <td>0.088282</td>
    </tr>
    <tr>
      <th>57</th>
      <td>603053</td>
      <td>成都燃气</td>
      <td>10.45</td>
      <td>14.47</td>
      <td>0.06641</td>
      <td>120466360000</td>
      <td>10990417</td>
      <td>1505.81</td>
      <td>0.022430</td>
      <td>39629800000</td>
      <td>7226</td>
      <td>4458.30</td>
      <td>88890000</td>
      <td>0.2000</td>
      <td>0.4402</td>
      <td>0.06</td>
      <td>2019-12-17</td>
      <td>sh</td>
      <td>0.066381</td>
    </tr>
    <tr>
      <th>58</th>
      <td>601658</td>
      <td>邮储银行</td>
      <td>5.50</td>
      <td>4.58</td>
      <td>1.25915</td>
      <td>205383291000</td>
      <td>8882002</td>
      <td>79.42</td>
      <td>4.773505</td>
      <td>27087900000</td>
      <td>2399</td>
      <td>20.95</td>
      <td>5947988200</td>
      <td>0.0182</td>
      <td>0.0200</td>
      <td>0.02</td>
      <td>2019-12-10</td>
      <td>sh</td>
      <td>1.260099</td>
    </tr>
  </tbody>
</table>
</div>




```python
ipo_df['prob_online'][ipo_df['prob_online']>20]
```




    656     24.68644
    664     21.56808
    1088    65.52084
    Name: prob_online, dtype: float64




```python
ipo_df['prob_offline'][ipo_df['prob_offline']>60]
```




    632     66.666667
    634     70.000000
    680     63.391272
    1078    90.909090
    1868    66.670000
    Name: prob_offline, dtype: float64




```python
ipo_df['prob_all'][ipo_df['prob_all']>60]
```




    1088    65.508859
    Name: prob_all, dtype: float64


