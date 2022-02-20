//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, TradingToolCrypto Corp"
#property link "https://github.com/TradingToolCrypto"
#property version     "1.2.1"
#property description "Telegram Chart Bot: "
#property description "Commands: /c EURUSD "
#property description "Commands: /p BTCUSD "
#property description "You must make a payment with the Payment_Bot before using"

#import "TTC_KEY.ex5"
void ttc_g_crt();
void ttc_g_basic();
void ttc_g_pro();
void ttc_g_elite();
void ttc_g_prime();
string ttc_e();
string ttc_d(string hexData);
#import


#include <TradingToolCrypto\TT\symbol_strings.mqh>
#include <TradingToolCrypto\MQL\Comments.mqh>
#include <TradingToolCrypto\MQL\Telegram.mqh>




#define CAPTION_COLOR   clrWhite
#define LOSS_COLOR      clrOrangeRed
#define ACSII_HASH 035    // #
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyBot: public CCustomBot
  {
private:
   string            m_symbol;
   long              chart_id;
   // int               auto_lotsize;
   ENUM_TIMEFRAMES   m_period;

public:
   /*
   int result=SendScreenShot(chat.m_id,symbol,DEFAULT_TIMEFRAME,DEFAULT_TEMPLATE);
   */

   int               SendScreenShot(const long _chat_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES _period,
                                    const string _template=NULL)
     {
      bool debug = false;
      if(debug)
         Print(" debug chat id " + _chat_id + "  symbol " + _symbol + " period " + _period + " template " + _template);
      string screen_id= "screen_id";
      string filename = "";
      filename=IntegerToString(TimeLocal()) + ".gif";
      if(debug)
         Print(" filename " + filename + " symbol " + _symbol + " period " + _period);




      chart_id=ChartOpen(_symbol,_period);
      // if not found, return now
      if(chart_id==0)
        {
         return(ERR_CHART_NOT_FOUND);
        }
      else
        {
         // get custom template
         // there is an error, when doing templates, if it doesn't match it will send the last image anyways.
         if(_template!=NULL)
           {

            // only place where I can match the _template names to the string that I mae containing all the template names.

            if(!ChartApplyTemplate(chart_id,_template))
              {
               PrintError(_LastError,InpLanguage);
              }
            else
              {
               // redraw after new template
               ChartSetInteger(chart_id,CHART_BRING_TO_TOP,true);//CHART_BRING_TO_TOP  -- // maybe the new chart goes to front automatically?
               ChartRedraw(chart_id);
               Sleep(2000);// mt5 is slower than mt4
              }
           }
        }

      // do screen shot
      if(ChartScreenShot(chart_id,filename,CHART_WIDTH,CHART_HEIGHT,ALIGN_RIGHT))
        {
         if(debug)
            Print("screenshot ok");
        }
      else
        {
         if(debug)
            Print("screenshot failed: Chart id " + chart_id + " filename " + filename);
        }

      // must sleep here
      Sleep(2500);

      // if the file exists
      bool successful_photo=false;
      if(FileIsExist(filename))
        {
         bot.SendChatAction(_chat_id,ACTION_UPLOAD_PHOTO);//========================================================================  ACTION
         // string screen_id="";
         string x=CharToString(ACSII_HASH);// or CharToString(35) == #
         char try
               ='#';// returns 35
         string test="";
         int hash=035;
         StringSetCharacter(test,0,hash);
         string caption="#"+_symbol + " @tradingtool";

         if(debug)
            Print("screen_id " + screen_id + " _chat id " + _chat_id + " filename " + filename + " capition " + caption);

         bot.SendPhoto(
            screen_id,
            _chat_id,
            filename,
            caption,
            false,
            10000);

         successful_photo=true;

         if(debug)
            Print("File exist ");

        }
      else
        {
         if(debug)
            Print("File does not exist ");
        }

      if(successful_photo)
        {
         // ALWAYS KEEP THE CHART OPEN ? NO, it takes up CPU,
         Sleep(500);
         if(debug)
            Print("chart_id " + chart_id);
         if(ChartClose(chart_id))
           {
            if(debug)
               Print("chart closed " + chart_id);
           }
         else
           {
            if(debug)
               Print("chart failed to closed " + chart_id + " error " + GetLastError());
           }
         // Delete the files
         if(FileIsExist(filename))
           {
            FileDelete(filename);// otherwise it sends the last screen shot () previous

           }

        }

      return(chart_id);
     }
   //+------------------------------------------------------------------+

   void              ProcessMessages(void)
     {

      string sym= "";
      string tf = "";

      for(int i=0; i<m_chats.Total(); i++)
        {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);

         if(!chat.m_new_one.done)
           {
            chat.m_new_one.done=true;

            string text=chat.m_new_one.message_text;


            if((text=="/start")   || (text=="Start"))
              {
               SendMessage(chat.m_id,"Commands:\n\n"+

                           "LIST MARKETS: /symbol\n"+
                           "Chart with specific timeframe\n"+
                           "CHART: /c_eurusd_m1 " + "\n" +
                           "CHART: /c_gbpusd_m60" + "\n" +
                           "CHART: /c_audusd_m240" + "\n" +
                           "CHART: /c_nzdusd_m1440"+ "\nChart with default timeframe\n" +
                           "CHART: /c eurusd or /c EURUSD"+ "\n" +
                           "QUOTE: /p_audusd or /p AUDUSD"+ "\n\n" +
                           "Use all of our trading tools for one small monthly fee.\nTo learn more and subscribe, please visit @tradingtool"+ "\n" +
                           "https://t.me/tradingtool"


                          );
              }
            string check_symbol=StringSubstr(text,0,7);
            if((check_symbol=="/symbol")   || (check_symbol=="/Symbol"))
              {
             
                  list_symbols(false,70);
                 

               if(GLOBAL_SYMBOL_LIST_1 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_1);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_2 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_2);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_3 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_3);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_4 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_4);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_5 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_5);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_6 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_6);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_7 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_7);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_8 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_8);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_9 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_9);
                  Sleep(1000);
                 }
               if(GLOBAL_SYMBOL_LIST_10 !="")
                 {
                  SendMessage(chat.m_id,GLOBAL_SYMBOL_LIST_10);
                  Sleep(1000);
                 }

              }



            string trythis=StringSubstr(text,0,2);// "/p"  0,1


            if(trythis=="/p")
              {
               chat.m_state=2;
              }

            if(trythis=="/c")
              {

               string trythis4=StringSubstr(text,0,3);// "/c_"  0,1,2

               if(trythis4=="/c_")
                 {
                  chat.m_state=4;
                 }
               else
                 {
                  chat.m_state=3;
                 }
              }

            if(trythis!="/c" && trythis!="/p")
              {
               Print("RETURN(): user text is not /c or /p |",trythis+"|");
               return;
              }


            /*
             Grab the string after the command
             the command is 3 characters such as "/p " or "/c_"
             the symbol will be the string after the 3 characters
            */
            string trythis2=StringSubstr(text,3);// "/p "  0,1,2


            //==============================================================================
            //  STAGE THREE  - QUOTES
            //===============================================================================
            if(chat.m_state==2)
              {
               string msg ="";
               string symbol="";

               if(trythis2=="")
                 {
                  symbol=DEFAULT_MARKET;
                 }
               else
                 {
                  symbol=  format_symbol_uppercase(trythis2, DEFAULT_SUFFIX_IDENTIFIER);
                 }


               if(SymbolSelect(symbol,true))
                 {
                  double open[1]= {0};


                  //--- upload history
                  for(int k=0; k<3; k++)
                    {
                     CopyOpen(symbol,PERIOD_D1,0,1,open);
                     if(open[0]>0.0)
                        break;
                    }

                  int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  double bid=SymbolInfoDouble(symbol,SYMBOL_BID);

                  CopyOpen(symbol,PERIOD_D1,0,1,open);
                  if(open[0]>0.0)
                    {
                     double percent=100*(bid-open[0])/open[0];
                     //--- sign
                     string sign=ShortToString(0x25B2);
                     if(percent<0.0)
                        sign=ShortToString(0x25BC);

                     msg="#"+symbol+"\n"+
                         "Price: "+DoubleToString(bid,digits)+"\n"+
                         "Daily: "+"("+DoubleToString(percent,2)+"%)";

                    }
                  else
                    {
                     msg="No history for "+symbol;
                    }
                  SendMessage(chat.m_id,msg);

                 }
              }


            //==========================================================================================================
            // CHARTS--> symbol --> timeFrame --> to go State 31(Templates)
            //==========================================================================================================
            if(chat.m_state==3)
              {
               string symbol ="";
               if(trythis2=="")
                 {
                  symbol=DEFAULT_MARKET;
                 }
               else
                 {
                  symbol=  format_symbol_uppercase(trythis2, DEFAULT_SUFFIX_IDENTIFIER);
                 }

               if(SymbolSelect(symbol,true))
                 {

                  int result=SendScreenShot(chat.m_id,symbol,DEFAULT_TIMEFRAME,DEFAULT_TEMPLATE);

                  if(result==0)
                    {
                     if(DEV_DEBUGGER)
                        Print(GetErrorDescription(result,InpLanguage)+" Error on ChatID # "+chat.m_id);
                    }
                 }

              }


            if(chat.m_state==4)
              {
               string symbol ="";
               /*

               July 22

               */
               string array_text[];           // An array to get strings
               string sep="_";                // A separator as a character
               ushort u_sep;                  // The code of the separator character
               //--- Get the separator code
               u_sep=StringGetCharacter(sep,0);
               int dash_count = StringSplit(text,u_sep,array_text);


               //what symbol
               string trythis4=array_text[1];
               symbol=  format_symbol_uppercase(trythis4, DEFAULT_SUFFIX_IDENTIFIER);

               //what timeframe
               string trythis3=array_text[2];
               // remove the "m" and find the @
               int at = StringFind(trythis3,"@",0);
               if(at != -1)
                 {
                  trythis3 = StringSubstr(trythis3,1,at-1);
                 }
               else
                 {
                  trythis3 = StringSubstr(trythis3,1,-1);
                 }

               int chart_TF=StringToInteger(trythis3);

               if(chart_TF==1)
                 {
                  m_period=PERIOD_M1;

                 }
               if(chart_TF==60)
                 {
                  m_period=PERIOD_H1;

                 }
               if(chart_TF==240)
                 {
                  m_period=PERIOD_H4;

                 }
               if(chart_TF==1440)
                 {
                  m_period=PERIOD_D1;

                 }



               if(SymbolSelect(symbol,true))
                 {
                  int result=SendScreenShot(chat.m_id,symbol,m_period,DEFAULT_TEMPLATE);
                  if(result==0)
                    {
                     if(DEV_DEBUGGER)
                        Print(GetErrorDescription(result,InpLanguage)+" Error on ChatID # "+chat.m_id);
                    }
                 }
              }



           }
        }
     }
  };
// END OF PUBLIC CLASS

//---
CComment       comment;
CMyBot         bot;
ENUM_RUN_MODE  run_mode;
datetime       time_check;
int            web_error;
int            init_error;
string         photo_id=NULL;
bool           Did_User_Push_Bitcoin=false;
bool           Did_User_Push_Usd=false;

string KEYB_SYMBOLS="\xF51D";
int timer_ms=0;


input  string           TELEGRAM_TOKEN       = "";
input  ENUM_LANGUAGES   InpLanguage=LANGUAGE_EN;     //Language
input string DEFAULT_SUFFIX_IDENTIFIER = ".";
input string DEFAULT_MARKET="EURUSD";
input ENUM_TIMEFRAMES DEFAULT_TIMEFRAME = PERIOD_M1;
input string DEFAULT_TEMPLATE = "default";
input string ScreenSize = "800x600 good | 1280x1024 good | | 1680x1200 ok | 1900x1200 good ";
input int CHART_WIDTH = 1900;
input int CHART_HEIGHT = 1200;
input bool DEV_DEBUGGER = false;



//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!search_license_key("TTC", "szlBOicLDU"))
     {
      Alert("License has expired, contact t.me/Hedgebitcoin");
      Print("License has expired, contact t.me/Hedgebitcoin");
      return (INIT_FAILED);
     }

//---
   run_mode=GetRunMode();

   if(DEV_DEBUGGER)
      Print(" CONFIG : GetRunMODE() : ",run_mode);

//--- stop working in tester
   if(run_mode!=RUN_LIVE)
     {
      if(DEV_DEBUGGER)
         PrintError(ERR_RUN_LIMITATION,InpLanguage);
      return(INIT_FAILED);
     }
   int y=40;
   if(ChartGetInteger(0,CHART_SHOW_ONE_CLICK))
      y=120;
   comment.Create("myPanel",20,y);
   comment.SetColor(clrDimGray,clrBlack,220);
   init_error=bot.Token(TELEGRAM_TOKEN);

//--- set timer

   timer_ms=1000;

   EventSetMillisecondTimer(timer_ms);
//==================================== GET LOOPING SPEED =====================================// END

//--- done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(reason==REASON_CLOSE ||
      reason==REASON_PROGRAM ||
      reason==REASON_PARAMETERS ||
      reason==REASON_REMOVE ||
      reason==REASON_RECOMPILE ||
      reason==REASON_ACCOUNT ||
      reason==REASON_INITFAILED)
     {
      time_check=0;
      comment.Destroy();
     }
//---
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//|   OnChartEvent                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   comment.OnChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------+
datetime global_time_now = 0;
void check_new_day()
  {

   static datetime last_check_time = 0;
   global_time_now = TimeLocal();
   if(global_time_now > last_check_time)
     {
      last_check_time = global_time_now + 86400;
      /*
      check license again on every day.
      */
      if(!search_license_key("TTC", "szlBOicLDU"))
        {
         Alert("License has expired, contact t.me/Hedgebitcoin");
         Print("License has expired, contact t.me/Hedgebitcoin");
         ExpertRemove();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   check_new_day();
//--- show init error
   if(init_error!=0)
     {
      //--- show error on display
      CustomInfo info;
      GetCustomInfo(info,init_error,InpLanguage);

      //---
      comment.Clear();
      comment.SetText(0,'-',CAPTION_COLOR);//Expert: %s v.%s
      comment.SetText(1,info.text1, LOSS_COLOR);
      if(info.text2!="")
         comment.SetText(2,info.text2,LOSS_COLOR);
      comment.Show();

      return;
     }

//--- show web error
   if(run_mode==RUN_LIVE)
     {

      //--- check bot registration
      if(time_check<TimeLocal()-PeriodSeconds(PERIOD_H1))
        {
         time_check=TimeLocal();
         if(TerminalInfoInteger(TERMINAL_CONNECTED))
           {
            //---
            web_error=bot.GetMe();
            if(web_error!=0)
              {
               //---
               if(web_error==ERR_NOT_ACTIVE)
                 {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+300;
                 }
               //---
               else
                 {
                  time_check=TimeCurrent()-PeriodSeconds(PERIOD_H1)+5;
                 }
              }
           }
         else
           {
            //---
            web_error=bot.GetMe();
            if(web_error!=0)
              {
               //---
               if(web_error==ERR_NOT_ACTIVE)
                 {
                  time_check=TimeLocal()-PeriodSeconds(PERIOD_H1)+300;
                 }
               //---
               else
                 {
                  time_check=TimeLocal()-PeriodSeconds(PERIOD_H1)+5;
                 }
              }
           }
        }

      //--- show error
      if(web_error!=0)
        {
         comment.Clear();
         comment.SetText(0,'-',CAPTION_COLOR);//StringFormat("%s v.%s")

         if(
#ifdef __MQL4__ web_error==ERR_FUNCTION_NOT_CONFIRMED #endif
#ifdef __MQL5__ web_error==ERR_FUNCTION_NOT_ALLOWED #endif
         )
           {
            time_check=0;

            CustomInfo info= {0};
            GetCustomInfo(info,web_error,InpLanguage);
            comment.SetText(1,info.text1,LOSS_COLOR);
            comment.SetText(2,info.text2,LOSS_COLOR);
           }
         else
            comment.SetText(1,GetErrorDescription(web_error,InpLanguage),LOSS_COLOR);

         comment.Show();
         return;
        }
     }

//---
   bot.GetUpdates();

//---

   if(run_mode==RUN_LIVE)
     {
      comment.Clear();
      comment.SetText(0,"MT5 Chart Bot",CAPTION_COLOR);//StringFormat("%s v.%s",EXPERT_NAME,EXPERT_VERSION)
      comment.SetText(1,"t.me/@"+bot.Name(),CAPTION_COLOR);
      comment.SetText(2,StringFormat("Chats: %d",bot.ChatsTotal()),CAPTION_COLOR);
      comment.Show();
     }

   bot.ProcessMessages();
//+------------------------------------------------------------------+
//|   GetCustomInfo                                                  |
//+------------------------------------------------------------------+

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetCustomInfo(CustomInfo &info,
                   const int _error_code,
                   const ENUM_LANGUAGES _lang)
  {
//--- функция для сообещний пользователей
   if(_lang==LANGUAGE_EN)
     {
      switch(_error_code)
        {
#ifdef __MQL5__
         case ERR_FUNCTION_NOT_ALLOWED:
            info.text1 = "The URL does not allowed for WebRequest";
            info.text2 = TELEGRAM_BASE_URL;
            break;
#endif
#ifdef __MQL4__
         case ERR_FUNCTION_NOT_CONFIRMED:
            info.text1 = "The URL does not allowed for WebRequest";
            info.text2 = TELEGRAM_BASE_URL;
            break;
#endif

         case ERR_TOKEN_ISEMPTY:
            info.text1 = "The 'Token' parameter is empty.";
            info.text2 = "Please fill this parameter.";
            break;
        }
     }
//---
   if(_lang==LANGUAGE_RU)
     {
      switch(_error_code)
        {
#ifdef __MQL5__
         case ERR_FUNCTION_NOT_ALLOWED:
            info.text1 = "Этого URL нет в списке для WebRequest.";
            info.text2 = TELEGRAM_BASE_URL;
            break;
#endif
#ifdef __MQL4__
         case ERR_FUNCTION_NOT_CONFIRMED:
            info.text1 = "Этого URL нет в списке для WebRequest.";
            info.text2 = TELEGRAM_BASE_URL;
            break;
#endif
         case ERR_TOKEN_ISEMPTY:
            info.text1 = "Параметр 'Token' пуст.";
            info.text2 = "Пожалуйста задайте значение для этого параметра.";
            break;
        }
     }
  }


/*
 match == TTC or PRO

 sends back the HASH
*/
long created_date = 0;
string created_name ="";
string get_global(string match)
  {
   int total=GlobalVariablesTotal();
   string order_info="";
   string name = "";
   int counterC=0;// COUNTER STARTS AT ZERO
   for(int i=0; i<total; i++)
     {
      name=GlobalVariableName(i);
      int dash1=StringFind(name,"_",0);// Dash Location within the string
      string coin_payment=StringSubstr(name,0,dash1);// This is the CP
      if(coin_payment==match && dash1!=-1)
        {
         string tx_id=StringSubstr(name,dash1+1,-1);// This is the complete Transaction ID
         created_date=GlobalVariableTime(name);
         created_name = name;
         return(tx_id);
        }
     }
   return("");
  }


MqlDateTime stm;
bool search_license_key(string license, string key)
  {
   const string decode = get_global(license);
   if(decode == "")
     {
      return (false);
     }
   const string match = key;

   if(license == "CRT")
     {
      ttc_g_crt();
     }
   if(license == "TTC")
     {
      ttc_g_basic();
     }
   if(license == "PRO")
     {
      ttc_g_pro();
     }
   if(license == "LIT")
     {
      ttc_g_elite();
     }
   if(license == "PRM")
     {
      ttc_g_prime();
     }

   const string hash = ttc_d(decode);
   if(hash == match)
     {

      datetime now = TimeLocal();
      TimeToStruct(now, stm);
      int day_of_month = stm.day;
      int month = stm.mon;
      int min = stm.min;
      int hour = stm.hour;

      TimeToStruct(created_date, stm);
      int g_day_of_month = stm.day;
      int g_month = stm.mon;
      int g_min = stm.min;
      int g_hour = stm.hour;

      if(month != g_month)
        {
         GlobalVariableDel(created_name);
         return (false);
        }
      return (true);
     }
   return (false);
  }

//+------------------------------------------------------------------+
