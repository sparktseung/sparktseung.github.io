# Can you make big money on Chinese stock IPO?

**Author**: [Spark Tseung](https://sparktseung.com)

**Source Code**: [github](https://github.com/sparktseung/Chinese-IPO) 

**Last Modified**: Sept 12, 2020

## Introduction

About two years ago, I started to have some extra money for investing. After a few trial-and-errors, I have resorted to regular purchase of a low-fee Exchange Traded Fund (ETF) tracking the US market index - the cost of "beating the market" just seems too high, and an average of 7~8% per year is already a very decent return.

I have been all content with that until a friend of mine mentioned the unbelievably high return on purchasing the Initial Public Offerings (IPO) of Chinese stocks. He claimed that, if you are lucky enough to be assigned some units during an IPO, the return on the first day of public trading is quite significant (e.g. 100%+). However, it is generally quite difficult to obtain those IPOs in the first place, so it is almost like buying a lottery.

Unfamiliar with, and intentially staying away from, the Chinese stock market, I was quite suspicious at first, but a quick search on the Internet has my confidence shaken. Therefore, being a student in statistics, I naturally started to dig into a pool of data, trying to find out if one can make some big money from Chinese stock IPOs. More specifically, I would like to see if one can make profits by obtaining stocks from IPOs and then selling them shortly after the public trading starts.

## Getting the Data

There are not a lot of data source available for the issue prices of IPOs in the Chinese market. The best I can find is the `akshare` package in Python, which in turn pulls IPO data from [eastmoney](http://data.eastmoney.com/xg/xg/dxsyl.html), a Chinese stock broker. They have three datasets of IPO, `sh` for (mostly) bluechip stocks traded on the Shanghai Stock Exchange, and `zxb`/`cyb` for smaller companies traded on the Shenzhen Stock Exchange.


```python
# Load required packages
import akshare as ak
import numpy as np
import pandas as pd
import datetime as dt
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

    100%|██████████| 15/15 [00:07<00:00,  2.09it/s]
    100%|██████████| 13/13 [00:05<00:00,  2.30it/s]
    100%|██████████| 17/17 [00:06<00:00,  2.63it/s]
    

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
# Filter by date: 2010-2019
ipo_df['list_date'] = pd.to_datetime(ipo_df['list_date'])
drop_idx = ipo_df[ipo_df['list_date'] > dt.datetime(2019, 12, 31)].index
ipo_df.drop(drop_idx , inplace = True)
```

The combined and cleaned data set has 1967 records, and the variables are described as follows.

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

## How hard is it to get some IPO shares?
