﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТипыДокументов = Новый Массив;
	
	Для Каждого Документ Из Параметры.МассивДокументов Цикл
		
		ТипДокумента = Документ.Метаданные().Имя;
		
		Если ТипыДокументов.Найти(ТипДокумента) = Неопределено Тогда
			
			ТипыДокументов.Добавить(ТипДокумента);
			
			НоваяСтрокаТипов = ТаблицаТиповДокументов.Добавить();
			
			НоваяСтрокаТипов.ТипДокумента = ТипДокумента;
			
		КонецЕсли;	
		
		НоваяСтрокаДокументов = ТаблицаДокументов.Добавить();
		
		НоваяСтрокаДокументов.Документ		= Документ;
		НоваяСтрокаДокументов.ТипДокумента	= ТипДокумента;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Не НастройкиЗагружены Тогда 
		
		ЗаполнитьТаблицуПечатныхФорм();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти 

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Печать(Команда)  
	
	ПараметрыПечати = УправлениеПечатьюКлиент.ПараметрыПечати();
	
	Результат = ПечатьНаСервере(ПараметрыПечати);
	
	Если Результат <> Неопределено Тогда
		
		ОткрытьФорму("ОбщаяФорма.ПечатьДокументов", Результат);
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Функция ПечатьНаСервере(ПараметрыПечати)  
	
	КоллекцияПечатныхФорм	= Неопределено;   
	ОбъектыПечати			= Неопределено;   
	ПараметрыВывода			= Неопределено;   
	
	ПараметрКоманды = Новый Массив;
	
	Для Каждого СтрокаТипа Из ТаблицаТиповДокументов Цикл
		
		ОтборПечатныхФорм = Новый Структура;
		
		ОтборПечатныхФорм.Вставить("ТипДокумента", СтрокаТипа.ТипДокумента);
		
		ОтборПечатныхФорм.Вставить("Пометка", Истина);
		
		НайденныеПечатныеФормы = ПечатныеФормы.НайтиСтроки(ОтборПечатныхФорм);
		
		Если Не НайденныеПечатныеФормы.Количество() Тогда
			
			Продолжить;	
			
		КонецЕсли;
		
		ОтборДокументов = Новый Структура;
		
		ОтборДокументов.Вставить("ТипДокумента", СтрокаТипа.ТипДокумента);
		
		НайденныеДокументы = ТаблицаДокументов.НайтиСтроки(ОтборДокументов);
		
		ДокументыНаПечать = Новый Массив;
		
		Для Каждого НайденныйДокумент Из НайденныеДокументы Цикл
			
			ДокументыНаПечать.Добавить(НайденныйДокумент.Документ);   
			
			ПараметрКоманды.Добавить(НайденныйДокумент.Документ);
			
		КонецЦикла;	   
		
		Если Не ДокументыНаПечать.Количество() Тогда
			
			Продолжить;
			
		КонецЕсли;	  
		
		ТипДокумента = СтрокаТипа.ТипДокумента;
		
		СформироватьПечатныеФормы(ОбъектыПечати, ТипДокумента, НайденныеПечатныеФормы, ДокументыНаПечать, КоллекцияПечатныхФорм, ПараметрыПечати, ПараметрыВывода); 
		
	КонецЦикла;	
	
	Результат = КоррекцияНомеровДокументов(КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода, ПараметрКоманды);
		
	Возврат Результат;
	
КонецФункции

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/19
//  
// Параметры:
//  
// ОбъектыПечати        	- СписокЗначений
// ТипДокумента 			- Строка
// ПечатныеФормы            - Массив
// ДокументыНаПечать        - Массив
// КоллекцияПечатныхФорм	- ТаблицаЗначений
// ПараметрыПечати          - Структура
// ПараметрыВывода			- Структура
//  
&НаСервере
Процедура СформироватьПечатныеФормы(ОбъектыПечати, ТипДокумента, ПечатныеФормы, ДокументыНаПечать, КоллекцияПечатныхФорм, ПараметрыПечати, ПараметрыВывода) 
	
	МетаданныеДокумента = Метаданные.Документы[ТипДокумента];
	
	КомандыПечати = УправлениеПечатью.КомандыПечатиОбъектаДоступныеДляВложений(МетаданныеДокумента);   
	
	Для Каждого ПечатнаяФорма Из ПечатныеФормы Цикл
		
		КомандаПечати = КомандыПечати.Найти(ПечатнаяФорма.ПечатнаяФорма, "Идентификатор");
		
		РезультатПечатныеФормы = УправлениеПечатью.СформироватьПечатныеФормы(КомандаПечати.МенеджерПечати, 
		КомандаПечати.Идентификатор, 
		ДокументыНаПечать,
		ПараметрыПечати);  
		
		Если КоллекцияПечатныхФорм = Неопределено Тогда
			
			КоллекцияПечатныхФорм	= РезультатПечатныеФормы.КоллекцияПечатныхФорм.Скопировать();	
			ОбъектыПечати			= РезультатПечатныеФормы.ОбъектыПечати;   
			ПараметрыВывода			= РезультатПечатныеФормы.ПараметрыВывода;
			
		Иначе
			
			ОбщегоНазначенияКлиентСервер.ДополнитьТаблицу(РезультатПечатныеФормы.КоллекцияПечатныхФорм, КоллекцияПечатныхФорм);	
			
			Для Каждого Элемент Из РезультатПечатныеФормы.ОбъектыПечати Цикл
				
				ОбъектыПечати.Добавить(Элемент.Значение, Элемент.Представление);
				
			КонецЦикла;	  
			
		КонецЕсли;	
		
	КонецЦикла;	
	
КонецПроцедуры// } #wortmann	 

&НаСервере
Функция КоррекцияНомеровДокументов(КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода, ПараметрКоманды)  
	
	Если КоллекцияПечатныхФорм = Неопределено Тогда
		
		Возврат Неопределено;
		
	КонецЕсли;                     
	
	Префикс					= "Документ_";     
	ДлинаПрефикса			= СтрДлина(Префикс); 
	КоличествоДокументов	= 0;
	
	НовыйНомер	= 1;
	
	Для Каждого ПечатнаяФорма Из КоллекцияПечатныхФорм Цикл
		
		Для Каждого Область Из ПечатнаяФорма.ТабличныйДокумент.Области Цикл
			
			Если Лев(Область, ДлинаПрефикса) = Префикс Тогда
				
				КоличествоДокументов = КоличествоДокументов + 1;
				
			КонецЕсли;	
			
		КонецЦикла;	 
		
		Для СтарыйНомер = 1 По КоличествоДокументов Цикл
			
			Область = ПечатнаяФорма.ТабличныйДокумент.Область("Документ_" + Формат(СтарыйНомер, "ЧН=; ЧГ="));
			
			Область.Имя = "Документ_" + Формат(НовыйНомер, "ЧН=; ЧГ=");
			
			НовыйНомер	= НовыйНомер + 1;
			
		КонецЦикла;	
		
	КонецЦикла;	
	
	НовыйНомер =  1;
	
	Для Каждого Элемент Из ОбъектыПечати Цикл    
		
		Элемент.Представление = "Документ_" + Формат(НовыйНомер, "ЧН=; ЧГ=");
		
		НовыйНомер	= НовыйНомер + 1;
		
	КонецЦикла;	
	
	Результат = Новый Структура();
	
	Результат.Вставить("КоллекцияПечатныхФорм", ОбщегоНазначения.ТаблицаЗначенийВМассив(КоллекцияПечатныхФорм));
	Результат.Вставить("ОбъектыПечати", ОбъектыПечати);
	Результат.Вставить("ПараметрКоманды", ПараметрКоманды);   
	Результат.Вставить("ПараметрыВывода", ПараметрыВывода);   
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти       

#Область СлужебныеПроцедурыИФункции

&НаСервере
// Заполняет таблицу доступных печатных форм
Процедура ЗаполнитьТаблицуПечатныхФорм() 
	
	ТаблицаТипов = ТаблицаТиповДокументов.Выгрузить(, "ТипДокумента");
	
	ТипыДокументов = ТаблицаТипов.ВыгрузитьКолонку("ТипДокумента");
	
	ПечатныеФормы.Очистить();
	
	Если Не ТипыДокументов.Количество() Тогда
		
		Возврат;
		
	КонецЕсли;		
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "
	|	ВЫБРАТЬ
	|	гф_ОтслеживаемыеОригиналыПервичныхДокументов.ВидДокумента КАК ВидДокумента,
	|	гф_ОтслеживаемыеОригиналыПервичныхДокументов.ПервичныйДокумент КАК ПервичныйДокумент,
	|	гф_ОтслеживаемыеОригиналыПервичныхДокументов.ПредставлениеПервичногоДокумента КАК ПредставлениеПервичногоДокумента,
	|	ИдентификаторыОбъектовМетаданных.Имя
	|ИЗ
	|	РегистрСведений.гф_ОтслеживаемыеОригиналыПервичныхДокументов КАК гф_ОтслеживаемыеОригиналыПервичныхДокументов
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ИдентификаторыОбъектовМетаданных КАК ИдентификаторыОбъектовМетаданных
	|		ПО гф_ОтслеживаемыеОригиналыПервичныхДокументов.ВидДокумента = ИдентификаторыОбъектовМетаданных.Ссылка
	|ГДЕ
	|	ИдентификаторыОбъектовМетаданных.Имя В (&ТипыДокументов)";
	
	Запрос.Параметры.Вставить("ТипыДокументов", ТипыДокументов);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ДоступныеФормы = Результат.Выгрузить();

	Для Каждого ДоступнаяФорма Из ДоступныеФормы Цикл 
		
		ОтборСтрок = Новый Структура;
		
		ОтборСтрок.Вставить("ПечатнаяФорма", ДоступнаяФорма.ПервичныйДокумент);
		ОтборСтрок.Вставить("ТипДокумента", ДоступнаяФорма.Имя);
		
		Если НастройкиЗагружены Тогда
			
			НайденныеСтроки = ВыбранныеПечатныеФормы.НайтиСтроки(ОтборСтрок);
		
			Пометка = НайденныеСтроки.Количество() > 0;
			
		Иначе
			
			Пометка = Истина;
			
		КонецЕсли;	
		
		ПредставлениеПервичногоДокумента = ДоступнаяФорма.ПредставлениеПервичногоДокумента 
											+ " ("
											+ ДоступнаяФорма.ВидДокумента.Синоним
											+ ")";
											
		ПечатнаяФорма = ПечатныеФормы.Добавить();
		
		ПечатнаяФорма.ПечатнаяФорма	= ДоступнаяФорма.ПервичныйДокумент;
		ПечатнаяФорма.ТипДокумента	= ДоступнаяФорма.Имя;
		ПечатнаяФорма.Пометка		= Пометка;
		ПечатнаяФорма.Представление	= ПредставлениеПервичногоДокумента;
											
	КонецЦикла;	 
	
КонецПроцедуры// } #wortmann

&НаКлиенте
// Добавляет или удаляет строки из сохраняемой в настройках таблицы ВыбранныеПечатныеФормы
// Параметры:
//
//	Элемент - ПолеФормы
//
Процедура ПечатныеФормыПометкаПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.ПечатныеФормы.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;	
	
	ОтборСтрок = Новый Структура;
	
	ОтборСтрок.Вставить("ПечатнаяФорма", ТекущиеДанные.ПечатнаяФорма);
	ОтборСтрок.Вставить("ТипДокумента", ТекущиеДанные.ТипДокумента);
		
	НайденныеСтроки = ВыбранныеПечатныеФормы.НайтиСтроки(ОтборСтрок);
	
	Если ТекущиеДанные.Пометка Тогда
		
		Если Не НайденныеСтроки.Количество() Тогда
			
			НоваяФорма = ВыбранныеПечатныеФормы.Добавить();
			
			ЗаполнитьЗначенияСвойств(НоваяФорма, ТекущиеДанные);
			
		КонецЕсли;
		
	Иначе	
		
		Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
			
			Индекс = ВыбранныеПечатныеФормы.Индекс(НайденнаяСтрока);
			
			ВыбранныеПечатныеФормы.Удалить(Индекс);
			
		КонецЦикла;
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	НастройкиЗагружены = Истина;	
	
	ЗаполнитьТаблицуПечатныхФорм();
	
КонецПроцедуры

#КонецОбласти 
