//+------------------------------------------------------------------+
//|                                                     OnePiece.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#define OP_BUYSELL 999

enum onePieceType
  {
   BUY_SIGNAL = 1,  // BUY
   SELL_SIGNAL = 2, // SELL
   NONE_SIGNAL = 3, // Do nothing
  };

extern int MagicNumber = 628228;                   // Magic Number
input string ______Order_Settings______    = "========== Order Settings ==========";
extern double lotsize = 0.01;                      // Lot Size
extern double pipTP = 30;                          // PipTP
extern double pipSL = 20;                          // PipSL

input string ______Common_Settings______    = "========== Common Settings ==========";    
extern ENUM_TIMEFRAMES opTimeFrame = 0;            // Khung Thoi Gian Vao Lenh
extern double stopBuyPrice = 0;                    // Gia Ko Buy Nua
extern double stopSellPrice = 0;                   // Gia Ko Sell Nua

input string ______MA_Trend_Settings______    = "========== MA Trend Settings ==========";    
extern ENUM_MA_METHOD ema1Method = MODE_SMMA;      // MA Type
extern int ema1Period = 28;                        // MA Period 
extern ENUM_MA_METHOD ema2Method = MODE_SMMA;      // MA Type
extern int ema2Period = 50;                        // MA Period 

input string ______MA_Signal_Settings______    = "========== MA Signal Settings ==========";    
extern ENUM_MA_METHOD ema3Method = MODE_SMMA;      // MA Type
extern int ema3Period = 12;                        // MA Period 
extern ENUM_MA_METHOD ema4Method = MODE_SMMA;      // MA Type
extern int ema4Period = 21;                        // MA Period 

input string ______Close_Orders_Settings______    = "========== Close Orders Settings ==========";   
extern bool closeByProfit = false;                 // Cat Lenh Theo Profit
extern double positiveProfit = 5;                  // Cat Lenh Khi Duong ($)
extern double negativeProfit = -5;                 // Cat Lenh Khi Am ($)

extern string ________TimeFilter________ = "===== Time Filter (Setting Theo Gio Cua MT4) =====";
extern int StartHour = 0;                         // Gio Bat Dau Chay
extern int StartMinute = 0;                       // Phut Bat Dau Chay
extern int EndHour = 23;                          // Gio Ket Thuc
extern int EndMinute = 59;                        // Phut Ket Thuc

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void openOrd ( int oP, double entry, double sL, double tP, string cm, double lot)
{
   GetValLot (oP, lot);
   string col;
   if (oP == OP_BUY)
   {
      col = DoubleToStr(clrGreen, 0);
   }
   else if (oP == OP_SELL)
   {
      col = DoubleToStr(clrRed, 0);
   }
   
   int tk = OrderSend(Symbol(), oP, currentLots, entry, 5, sL, tP, cm, MagicNumber, 0, StringToColor(col));
   if (tk <= 0) { 
      Print("Error Open Order " + DoubleToStr(oP,0) + " : ",GetLastError());
   }
}// End void openOrd()

void GetValLot(int oP, double fixLots)
{   
   if (fixLots <= 0) {
      fixLots = MarketInfo(Symbol(), MODE_MINLOT);
   }
   
   if (fixLots < MarketInfo(Symbol(), MODE_MINLOT)) {
      fixLots = MarketInfo(Symbol(), MODE_MINLOT);
   }
   
   if (fixLots > MarketInfo(Symbol(), MODE_MAXLOT)) {
      fixLots = MarketInfo(Symbol(), MODE_MAXLOT);
   }
   
   currentLots = NormalizeDouble(fixLots, normalLotUnit);
} // End void GetValLot()

void GetNormalLotUnit()
{
   if(MarketInfo(Symbol(), MODE_MINLOT)== 0.01)
   {
      normalLotUnit = 2;
   }
   if(MarketInfo(Symbol(), MODE_MINLOT)== 0.1)
   {
      normalLotUnit = 1;
   }
   if(MarketInfo(Symbol(), MODE_MINLOT)== 0.001)
   {
      normalLotUnit = 3;
   }
}// End void GetNormalLotUnit()

bool isNewBar ()
{
   datetime curbar = iTime(Symbol(), opTimeFrame, 0);
   if(lastBar != curbar)
   {
      lastBar = curbar;
      return (true);
   }
   else
   {
      return(false);
   }
} // End void isNewBar()

int getEMATrend()
{
   double ma1 = iMA(NULL, opTimeFrame, ema1Period, 0, ema1Method, PRICE_CLOSE, 1);
   double ma2 = iMA(NULL, opTimeFrame, ema2Period, 0, ema2Method, PRICE_CLOSE, 1);
   
   // MA28 nam tren thi Buy
   if (ma1 > ma2) {
      return BUY_SIGNAL;
   } else if (ma1 < ma2) {
      return SELL_SIGNAL;
   }
   
   return NONE_SIGNAL;
} // End void getEMATrend()

int getEMASignal()
{
   double ma3_cur = iMA(NULL, opTimeFrame, ema3Period, 0, ema1Method, PRICE_CLOSE, 1);
   double ma3_prev = iMA(NULL, opTimeFrame, ema3Period, 0, ema1Method, PRICE_CLOSE, 2);
   double ma4_cur = iMA(NULL, opTimeFrame, ema4Period, 0, ema2Method, PRICE_CLOSE, 1);
   double ma4_prev = iMA(NULL, opTimeFrame, ema4Period, 0, ema2Method, PRICE_CLOSE, 2);
   
   // MA12 cat MA21 cho tin hieu BUY (sau khi cat MA12 nam tren)
   if (ma3_prev < ma4_prev && ma3_cur > ma4_cur) {
      return BUY_SIGNAL;
   } else if (ma3_prev > ma4_prev && ma3_cur < ma4_cur) { // MA12 cat MA21 cho tin hieu SELL (sau khi cat MA12 nam duoi)
      return SELL_SIGNAL;
   }
   
   return NONE_SIGNAL;
} // End void getEMASignal()