//+------------------------------------------------------------------+
//|                                 HighCandlesFilter.mqh |
//|                                              Copyright 2017, JPO |
//|                                       januszopechowski@yahoo.com |
//+------------------------------------------------------------------+
#include <_my\utils\IndicatorGetter.mqh>
//#include <_my\SignalTools\IndicatorBased\MATrendSignal.mqh>
#include <_my\utils\LinearParameter.mqh>
#include <_my\utils\PriceGetter.mqh>
#include<_my\SignalTools\TrendSignal.mqh>
//#include <_my\utils\UtilsTimeFrame.mqh>
//
//
// #include <_my\SignalTools\NewBar\HighCandlesFilter.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HighCandlesFilter :public TrendSignal
  {
protected:
   string            _symbol;
   ENUM_TIMEFRAMES   _period;
   PriceGetter*      _price;
TrendSignal * _reva;
IndicatorGetter * _ig;
 
LinearParameter *_atrToClose;
 
int _nBarsCheck;
int _nBarsAvg;// avg for iv

int _baseSide;// jesli mniejsze to odpowiadac to
double _pip;
//int _nBarsAvg;// ir
public:

  
HighCandlesFilter(      
                        string symbol,
                        ENUM_TIMEFRAMES period,// n steps to make avg indicating trend
                        
                        double ivFractionToClose,
                        double constInPipsToClose,
                        int nBarsCheck,
                        TrendSignal * reva                    
                     )  
{                     
    _symbol = symbol;
   _period=period; // n steps to make avg indicating trend      
 //
   _price = new PriceGetter(symbol,period);
    double pip =  this._price.GetPipPriceFraction();
   _pip= pip;
   
    _nBarsAvg = 100;
   _ig               = new IndicatorGetter(symbol,period);
   _atrToClose       = new LinearParameter(ivFractionToClose,constInPipsToClose*pip);
   _nBarsCheck=nBarsCheck;
   _baseSide=1;//jak ok to to gadamy
   
   _reva=reva;
   
}
                     
 ~HighCandlesFilter();

  
      virtual int GetTrendSide();
      
   


  };// c
   
        
        

int HighCandlesFilter::GetTrendSide()
{  
   this._baseSide=_reva.GetTrendSide();
   if(this._baseSide!=0)
   {
 
      double iv = this._ig.GetIV_LWMA(_nBarsCheck+1,100);
      double minimumChangeInPips = this._price.GetNormalized(this._atrToClose.GetValue(iv))/this._pip;;
      double hi = this._price.HighestPrice(this._nBarsCheck)/this._pip;
      double lo = this._price.LowestPrice(this._nBarsCheck)/this._pip;
      double diff = this._price.GetNormalized(hi-lo);///this._price.GetPipPriceFraction();
      
      if(diff>minimumChangeInPips)
      {
        Print("Price speed too fast, turning off trade move: ",diff, " pips while allowed ",minimumChangeInPips);
         this._baseSide=0;
      }
      else
      {
            Print("Price speed not too fast, turning off trade move: ",diff, " pips while allowed ",minimumChangeInPips);

      }
      
   }   
   return this._baseSide;
}//M

 
 
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HighCandlesFilter::~HighCandlesFilter()
  {
  
   if (_ig!=NULL)
   {
    delete _ig;
   }
   
   if (_price!=NULL)
   {
      delete _price;
   }
    
   
   if(_atrToClose!=NULL)
   {
      delete _atrToClose;
   }
  
  }
  
//+------------------------------------------------------------------+
