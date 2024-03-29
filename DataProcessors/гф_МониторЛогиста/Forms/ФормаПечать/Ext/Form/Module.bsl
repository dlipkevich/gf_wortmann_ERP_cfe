﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ТипДокумента = Параметры.ТипДокумента;
	
	ВыбранныеПечатныеФормы.Загрузить(Параметры.ВыбранныеПечатныеФормы.Выгрузить());
	
	ЗаполнитьСписокВыбораПечатныхФорм();     
	
	Для Каждого Документ Из Параметры.МассивДокументов Цикл
		
		НоваяСтрока = ТаблицаДокументов.Добавить();
		
		НоваяСтрока.Документ = Документ;
		
	КонецЦикла;	
	
КонецПроцедуры

#КонецОбласти 

#Область ОбработчикиСобытийЭлементовШапкиФормы

#КонецОбласти       

#Область ОбработчикиКомандФормы

&НаСервере
Функция ПолучитьМенеджерыПечати(Идентификаторы)           
	
	Результат = Новый СписокЗначений;
	
	КомандыПечати = УправлениеПечатью.КомандыПечатиОбъектаДоступныеДляВложений(Метаданные.Документы[ТипДокумента]);
	
	Для Каждого Идентификатор Из Идентификаторы Цикл
		
		СтрокаКоманд = КомандыПечати.Найти(Идентификатор, "Идентификатор");
		
		Если СтрокаКоманд = Неопределено Тогда
			
			Продолжить;
			
		КонецЕсли;	
		
		ИмяМенеджера = СтрокаКоманд.МенеджерПечати;
		
		ЭлементСписка = Результат.НайтиПоЗначению(ИмяМенеджера);
		
		Если ЭлементСписка = Неопределено Тогда
			
			Результат.Добавить(ИмяМенеджера, СтрокаКоманд.Идентификатор);
			
		Иначе
			
			ЭлементСписка.Представление = ЭлементСписка.Представление + "," + СтрокаКоманд.Идентификатор;
			
		КонецЕсли;	
			
	КонецЦикла;	
	
	Возврат Результат;
	
КонецФункции


&НаКлиенте
Процедура Печать(Команда)
	
	Идентификаторы = Новый Массив;
	
	Для Каждого ПечатнаяФорма Из ПечатныеФормы Цикл
		
		Если ПечатнаяФорма.Пометка Тогда
			
			Идентификаторы.Добавить(ПечатнаяФорма.Значение);
			
		КонецЕсли;	
		
	КонецЦикла;	   
	
	МенеджерыПечати = ПолучитьМенеджерыПечати(Идентификаторы);
	
	ДокументыНаПечать = Новый Массив;
	
	Для Каждого СтрокаТаблицы Из ТаблицаДокументов Цикл
		
		ДокументыНаПечать.Добавить(СтрокаТаблицы.Документ);
		
	КонецЦикла;	   
	
	ПараметрыПечати = УправлениеПечатьюКлиент.ПараметрыПечати();  
	
	ПараметрыПечати.Вставить("ВыводитьУслуги",	Ложь);
	ПараметрыПечати.Вставить("ПечатьВВалюте",	Ложь);
	
	Если Команда.Имя = "ПечатьНаПринтер" Тогда  
		
		Для Каждого Менеджер Из МенеджерыПечати Цикл
		
			УправлениеПечатьюКлиент.ВыполнитьКомандуПечатиНаПринтер(Менеджер.Значение, Менеджер.Представление, ДокументыНаПечать, ПараметрыПечати);
		
		КонецЦикла;
		
	Иначе	
		
		Для Каждого Менеджер Из МенеджерыПечати Цикл
		
			УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(Менеджер.Значение, Менеджер.Представление, ДокументыНаПечать, ЭтотОбъект, ПараметрыПечати);
		
		КонецЦикла;
		
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти       

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьСписокВыбораПечатныхФорм() 
	
	ПечатныеФормы.Очистить();
	
	Если ЗначениеЗаполнено(ТипДокумента) Тогда
		
		ОтборСтрок = Новый Структура;
		
		ОтборСтрок.Вставить("ТипДокумента", ТипДокумента);
		
		КомандыПечати = УправлениеПечатью.КомандыПечатиОбъектаДоступныеДляВложений(Метаданные.Документы[ТипДокумента]);
		
		Для Каждого КомандаПечати Из КомандыПечати Цикл 
			
			Если Не ЗначениеЗаполнено(КомандаПечати.Обработчик) Тогда

				ОтборСтрок.Вставить("ПечатнаяФорма", КомандаПечати.Идентификатор);
	
				НайденныеСтроки = ВыбранныеПечатныеФормы.НайтиСтроки(ОтборСтрок);

				Пометка = НайденныеСтроки.Количество() > 0;
				
				ПечатныеФормы.Добавить(КомандаПечати.Идентификатор, КомандаПечати.Представление, Пометка);
				
			КонецЕсли;	
			
		КонецЦикла;	 
		
	КонецЕсли;	
	
КонецПроцедуры// } #wortmann

#КонецОбласти 
