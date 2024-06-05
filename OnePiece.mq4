//+------------------------------------------------------------------+
//|                                                     OnePiece.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#define OP_BUYSELL 999

extern int MagicNumber = 628228;                   // Magic Number
extern double Lotsize = 0.01;                      // Lot Size

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
